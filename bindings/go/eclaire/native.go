package eclaire

/*
#cgo CFLAGS: -I../../../include -I../../../third_party/clay
#cgo linux LDFLAGS: -lm
#include "../../../include/eclaire.h"
*/
import "C"

// Version is the Eclaire release represented by this Go package.
const Version = "0.1.0"

// ClayCommit is the upstream Clay revision pinned by this Eclaire release.
const ClayCommit = "e6cc36941ab2af5d81107617039d6f527a1c660b"

// IRVersion reports the semantic IR version exposed by the native core.
func IRVersion() uint32 { return uint32(C.eclaire_ir_version()) }

// MinMemorySize returns the minimum Clay arena size for maxElements.
func MinMemorySize(maxElements uint32) uintptr {
	return uintptr(C.eclaire_min_memory_size(C.uint32_t(maxElements)))
}
