#![deny(unsafe_op_in_unsafe_fn)]

use std::ffi::c_void;

unsafe extern "C" {
    fn eclaire_ir_version() -> u32;
    fn eclaire_min_memory_size(max_elements: u32) -> usize;
}

/// Returns the semantic IR version exposed by the native Eclaire core.
pub fn ir_version() -> u32 {
    // The C function has no preconditions and returns a scalar value.
    unsafe { eclaire_ir_version() }
}

/// Returns the minimum Clay arena size for the requested element capacity.
pub fn min_memory_size(max_elements: u32) -> usize {
    // The C function has no pointer arguments and returns a scalar value.
    unsafe { eclaire_min_memory_size(max_elements) }
}

/// A marker for APIs that cross the native Eclaire ABI.
pub type NativeHandle = *mut c_void;

/// Clay revision compiled into this Eclaire package.
pub const CLAY_COMMIT: &str = "e6cc36941ab2af5d81107617039d6f527a1c660b";
