// Package quicken adapts Cadence semantic elements to Quicken Native using
// Eclaire/Clay for geometry and Quicken's native Gio controls for interaction.
package quicken

import (
	"fmt"
	"image"
	"strings"

	"gioui.org/layout"
	"gioui.org/op"
	"gioui.org/widget/material"
	"github.com/brain-fuel/eclaire/bindings/go/eclaire"
	"goforge.dev/cadence/sel"
	cadencestyle "goforge.dev/cadence/style"
	"goforge.dev/quicken/native"
)

// SELView returns a Quicken Native view whose element rectangles come from
// Eclaire's pinned Clay core. Quicken continues to own Gio widgets and events.
func SELView[State any, Msg any](
	render func(State) sel.Element[Msg],
	palette native.Palette,
) native.View[State, Msg] {
	return func(gtx layout.Context, state State, ui *native.UI[Msg]) layout.Dimensions {
		root := render(state)
		if err := sel.Validate(root, sel.TargetGio{}); err != nil {
			return ui.Label(gtx, "render error: "+err.Error())
		}
		scale := float32(gtx.Metric.PxPerDp)
		layoutRoot, paths := toLayout(root, "root", scale)
		boxes, err := eclaire.Layout(layoutRoot, float32(gtx.Constraints.Max.X), float32(gtx.Constraints.Max.Y))
		if err != nil {
			return ui.Label(gtx, "layout error: "+err.Error())
		}
		byKey := make(map[string]eclaire.Rect, len(boxes))
		for _, box := range boxes {
			byKey[box.Key] = box.Rect
		}
		drawTree(gtx, root, "root", paths, byKey, ui, palette)
		return layout.Dimensions{Size: gtx.Constraints.Max}
	}
}

func toLayout[Msg any](element sel.Element[Msg], path string, scale float32) (eclaire.LayoutNode, map[string]string) {
	key := semanticKey(element, path)
	name := sel.KindName(element.Kind)
	node := eclaire.LayoutNode{
		Key: key, Kind: layoutKind(name), Width: float32(element.Style.Width) * scale,
		Height: float32(element.Style.Height) * scale, Padding: float32(maxSpacing(element.Style.Padding)) * scale,
		Sizing: eclaire.SizingGrow,
	}
	if node.Width > 0 || node.Height > 0 {
		node.Sizing = eclaire.SizingFixed
	}
	if name == "row" {
		node.Direction = eclaire.DirectionRow
	} else {
		node.Direction = eclaire.DirectionColumn
	}
	if name == "text" || name == "heading" || name == "status" {
		node.Text = element.Text
	}
	paths := map[string]string{path: key}
	for index, child := range element.Children {
		if child.Style.Hidden {
			continue
		}
		childPath := fmt.Sprintf("%s/%d", path, index)
		childNode, childPaths := toLayout(child, childPath, scale)
		node.Children = append(node.Children, childNode)
		for childPath, childKey := range childPaths {
			paths[childPath] = childKey
		}
	}
	return node, paths
}

func layoutKind(name string) uint16 {
	switch name {
	case "text", "heading", "paragraph", "status":
		return eclaire.KindText
	case "image":
		return eclaire.KindImage
	case "button", "link":
		return eclaire.KindButton
	case "checkbox":
		return eclaire.KindCheckbox
	case "text-input", "text-area", "select":
		return eclaire.KindTextInput
	case "scroll":
		return eclaire.KindScroll
	default:
		return eclaire.KindContainer
	}
}

func maxSpacing(spacing cadencestyle.Spacing) int {
	// Cadence spacing has independent edges; Clay's v1 Eclaire ABI accepts one
	// inset, so use the largest edge to avoid clipping any side.
	return max(spacing.Top, spacing.Right, spacing.Bottom, spacing.Left)
}

func semanticKey[Msg any](element sel.Element[Msg], path string) string {
	if element.Key == "" {
		return path
	}
	return path + ":" + element.Key
}

func drawTree[Msg any](
	gtx layout.Context,
	element sel.Element[Msg],
	path string,
	paths map[string]string,
	boxes map[string]eclaire.Rect,
	ui *native.UI[Msg],
	palette native.Palette,
) {
	key := paths[path]
	rect, ok := boxes[key]
	if !ok || element.Style.Hidden {
		return
	}
	position := op.Offset(image.Pt(int(rect.X), int(rect.Y))).Push(gtx.Ops)
	childContext := gtx
	size := image.Pt(max(0, int(rect.Width)), max(0, int(rect.Height)))
	childContext.Constraints = layout.Exact(size)
	drawLeaf := func(ctx layout.Context) layout.Dimensions {
		name := sel.KindName(element.Kind)
		switch name {
		case "text", "status":
			label := material.Body1(ui.Theme, element.Text)
			label.Color = native.ColorFor(element.Style.Foreground, palette)
			return label.Layout(ctx)
		case "heading":
			label := material.H6(ui.Theme, element.Text)
			label.Color = native.ColorFor(element.Style.Foreground, palette)
			return label.Layout(ctx)
		case "button", "link":
			if message, found := eventMessage(element.Events, "activate"); found {
				return ui.Button(ctx, key, childText(element), message)
			}
			return ui.Label(ctx, childText(element))
		case "checkbox":
			if message, found := eventMessage(element.Events, "change"); found {
				return ui.Checkbox(ctx, key, childText(element), element.Checked, message)
			}
			return ui.Label(ctx, childText(element))
		case "text-input", "text-area":
			return ui.Editor(ctx, key, element.Value, element.Description, name == "text-input", inputDecoder(element.Events))
		case "image":
			return ui.Label(ctx, "[image: "+element.Description+"]")
		case "progress":
			return ui.Label(ctx, element.Description+" "+element.Attributes["value"]+"/"+element.Attributes["max"])
		case "select":
			return ui.Label(ctx, element.Description+": "+element.Value)
		default:
			return layout.Dimensions{}
		}
	}
	name := sel.KindName(element.Kind)
	switch name {
	case "text", "heading", "status", "button", "link", "checkbox", "text-input", "text-area", "image", "progress", "select":
		native.Styled(childContext, element.Style, palette, drawLeaf)
	}
	position.Pop()
	if name == "button" || name == "link" || name == "checkbox" || name == "text-input" || name == "text-area" || name == "select" {
		return
	}
	for index, child := range element.Children {
		childPath := fmt.Sprintf("%s/%d", path, index)
		drawTree(gtx, child, childPath, paths, boxes, ui, palette)
	}
}

func childText[Msg any](element sel.Element[Msg]) string {
	if element.Text != "" {
		return element.Text
	}
	var text strings.Builder
	for _, child := range element.Children {
		text.WriteString(child.Text)
	}
	return text.String()
}

func eventMessage[Msg any](events []sel.Event[Msg], want string) (Msg, bool) {
	for _, event := range events {
		name := sel.EventKindFold(event.Kind, sel.EventKindCases[string]{
			EventActivate: func() string { return "activate" },
			EventInput:    func() string { return "input" },
			EventChange:   func() string { return "change" },
			EventSubmit:   func() string { return "submit" },
			EventFocus:    func() string { return "focus" },
			EventBlur:     func() string { return "blur" },
		})
		if name == want {
			return event.Message, true
		}
	}
	var zero Msg
	return zero, false
}

func inputDecoder[Msg any](events []sel.Event[Msg]) func(string) Msg {
	for _, event := range events {
		name := sel.EventKindFold(event.Kind, sel.EventKindCases[string]{
			EventActivate: func() string { return "activate" },
			EventInput:    func() string { return "input" },
			EventChange:   func() string { return "change" },
			EventSubmit:   func() string { return "submit" },
			EventFocus:    func() string { return "focus" },
			EventBlur:     func() string { return "blur" },
		})
		if (name == "input" || name == "change") && event.Decode != nil {
			return event.Decode
		}
	}
	return nil
}
