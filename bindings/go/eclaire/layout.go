package eclaire

/*
#include <stdlib.h>
#include "../../../include/eclaire.h"
*/
import "C"

import (
	"fmt"
	"hash/fnv"
	"unsafe"
)

const (
	KindContainer uint16 = iota
	KindText
	KindImage
	KindButton
	KindCheckbox
	KindTextInput
	KindScroll
)

const (
	DirectionRow uint8 = iota
	DirectionColumn
)

const (
	SizingFixed uint8 = iota
	SizingGrow
	SizingFit
)

// LayoutNode describes one semantic node for a Clay layout pass. Kind,
// Direction, and Sizing use the ECLAIRE_* constants from eclaire.h.
type LayoutNode struct {
	Key       string
	Kind      uint16
	Text      string
	Width     float32
	Height    float32
	Padding   float32
	Gap       float32
	Direction uint8
	Sizing    uint8
	Children  []LayoutNode
}

// LayoutBox is the computed pixel rectangle for one semantic node.
type LayoutBox struct {
	Key  string
	ID   uint64
	Rect Rect
}

// Rect is an Eclaire pixel-space rectangle.
type Rect struct {
	X, Y, Width, Height float32
}

var nativeMemory unsafe.Pointer
var nativeStrings []*C.char

// Layout computes rectangles for a semantic tree using the pinned Clay core.
// Eclaire's native context is process-global, so layout calls are serialized.
func Layout(root LayoutNode, width, height float32) ([]LayoutBox, error) {
	nativeMu.Lock()
	defer nativeMu.Unlock()

	count, err := countNodes(root)
	if err != nil {
		return nil, err
	}
	if count == 0 || count > 65535 {
		return nil, fmt.Errorf("eclaire: layout requires 1..65535 elements, got %d", count)
	}
	memorySize := C.eclaire_min_memory_size(C.uint32_t(count))
	if memorySize == 0 {
		return nil, fmt.Errorf("eclaire: Clay rejected an arena capacity of %d", count)
	}
	memory := C.malloc(memorySize)
	if memory == nil {
		return nil, fmt.Errorf("eclaire: could not allocate %d bytes for Clay", uint64(memorySize))
	}
	if status := C.eclaire_init(memory, memorySize, C.uint32_t(count), C.float(width), C.float(height), nil, nil, nil, nil); status != C.ECLAIRE_OK {
		C.free(memory)
		return nil, fmt.Errorf("eclaire: native initialization failed with status %d", int(status))
	}
	if nativeMemory != nil {
		C.free(nativeMemory)
	}
	for _, value := range nativeStrings {
		C.free(unsafe.Pointer(value))
	}
	nativeMemory = memory
	nativeStrings = nil
	if status := C.eclaire_begin_frame(C.float(width), C.float(height), 0, 0, 0); status != C.ECLAIRE_OK {
		return nil, fmt.Errorf("eclaire: native frame start failed with status %d", int(status))
	}

	var strings []*C.char
	defer func() { nativeStrings = strings }()
	boxes := make([]LayoutBox, 0, count)
	if err := pushTree(root, "root", &strings, &boxes); err != nil {
		return nil, err
	}
	if status := C.eclaire_end_frame(0); status != C.ECLAIRE_OK {
		return nil, fmt.Errorf("eclaire: native layout failed with status %d (error %d)", int(status), uint32(C.eclaire_last_error()))
	}
	for index := range boxes {
		var rect C.EclaireRect
		if C.eclaire_get_element_rect(C.uint64_t(boxes[index].ID), &rect) == 0 {
			return nil, fmt.Errorf("eclaire: Clay did not return a rectangle for %q", boxes[index].Key)
		}
		boxes[index].Rect = Rect{X: float32(rect.x), Y: float32(rect.y), Width: float32(rect.width), Height: float32(rect.height)}
	}
	return boxes, nil
}

func countNodes(root LayoutNode) (int, error) {
	type pendingNode struct {
		node  LayoutNode
		depth int
	}
	pending := []pendingNode{{node: root, depth: 1}}
	count := 0
	for len(pending) > 0 {
		last := len(pending) - 1
		current := pending[last]
		pending = pending[:last]
		if current.depth > 256 {
			return 0, fmt.Errorf("eclaire: semantic tree exceeds Clay's 256-element nesting limit")
		}
		count++
		if count > 65535 {
			return 0, fmt.Errorf("eclaire: semantic tree exceeds the 65535-element limit")
		}
		for _, child := range current.node.Children {
			pending = append(pending, pendingNode{node: child, depth: current.depth + 1})
		}
	}
	return count, nil
}

func pushTree(node LayoutNode, path string, strings *[]*C.char, boxes *[]LayoutBox) error {
	key := node.Key
	if key == "" {
		key = path
	}
	hash := fnv.New64a()
	_, _ = hash.Write([]byte(key))
	id := hash.Sum64()
	var text *C.char
	if node.Text != "" {
		text = C.CString(node.Text)
		*strings = append(*strings, text)
	}
	element := C.EclaireElement{
		stable_id: C.uint64_t(id), kind: C.uint16_t(node.Kind), text: text,
		width: C.float(node.Width), height: C.float(node.Height),
		padding: C.float(node.Padding), gap: C.float(node.Gap),
		direction: C.uint8_t(node.Direction), sizing: C.uint8_t(node.Sizing),
	}
	if status := C.eclaire_push_element(&element); status != C.ECLAIRE_OK {
		return fmt.Errorf("eclaire: could not add %q to the native layout (status %d)", key, int(status))
	}
	*boxes = append(*boxes, LayoutBox{Key: key, ID: id})
	for index, child := range node.Children {
		childPath := fmt.Sprintf("%s/%d", path, index)
		if err := pushTree(child, childPath, strings, boxes); err != nil {
			return err
		}
	}
	if status := C.eclaire_pop_element(); status != C.ECLAIRE_OK {
		return fmt.Errorf("eclaire: could not close %q in the native layout (status %d)", key, int(status))
	}
	return nil
}
