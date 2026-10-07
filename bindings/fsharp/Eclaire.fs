namespace Eclaire

open System.Runtime.InteropServices

module private Native =
    [<DllImport("eclaire", EntryPoint = "eclaire_ir_version", CallingConvention = CallingConvention.Cdecl)>]
    extern uint32 irVersion()

    [<DllImport("eclaire", EntryPoint = "eclaire_min_memory_size", CallingConvention = CallingConvention.Cdecl)>]
    extern unativeint minMemorySize(uint32 maxElements)

[<RequireQualifiedAccess>]
module Core =
    /// Semantic IR version exposed by the native Eclaire core.
    let irVersion () = Native.irVersion ()

    /// Minimum Clay arena size for the requested element capacity.
    let minMemorySize maxElements = Native.minMemorySize maxElements

    /// Clay revision compiled into this Eclaire package.
    [<Literal>]
    let clayCommit = "e6cc36941ab2af5d81107617039d6f527a1c660b"
