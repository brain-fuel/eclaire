namespace ElmishClay.Showcase

open System

type Msg = Increment | Decrement | Toggle

type Model = { Count: int; Expanded: bool }
type Cmd = NoCommand
type AccessibilityExemption = { Reason: string; Component: string }

type Kind = Container | Text | Button | Checkbox | Image | Scroll
type Role = Group | ButtonRole | CheckboxRole | ImageRole
type Layout = { Direction: string; Width: string; Height: string; Padding: float; Gap: float }
type Element = { Id: uint64; Kind: Kind; Role: Role option; Name: string option; Action: uint64 option; Text: string option; Layout: Layout; Children: Element list }

module App =
    let init () = { Count = 0; Expanded = true }, NoCommand

    let update msg model =
        match msg with
        | Increment -> { model with Count = model.Count + 1 }, NoCommand
        | Decrement -> { model with Count = model.Count - 1 }, NoCommand
        | Toggle -> { model with Expanded = not model.Expanded }, NoCommand

    // Pure view: action IDs are mapped to Msg by this host, never serialized as closures.
    let view model : Element =
        let leaf id kind role name action text =
            { Id=id; Kind=kind; Role=role; Name=Some name; Action=action; Text=Some text
              Layout={ Direction="column"; Width="fit"; Height="fit"; Padding=0.; Gap=0. }; Children=[] }
        let actions =
            { Id=3UL; Kind=Container; Role=Some Group; Name=Some "Counter actions"; Action=None; Text=None
              Layout={ Direction="row"; Width="grow"; Height="fit"; Padding=0.; Gap=12. }
              Children=[leaf 4UL Button (Some ButtonRole) "Decrease" (Some 100UL) "−"
                        leaf 5UL Button (Some ButtonRole) "Increase" (Some 101UL) "+"] }
        let details =
            { Id=7UL; Kind=Container; Role=Some Group; Name=Some "Details"; Action=None; Text=None
              Layout={ Direction="column"; Width="grow"; Height="fit"; Padding=0.; Gap=14. }
              Children=[leaf 8UL Text None "Details" None "Clay solves layout; each host preserves control semantics."
                        leaf 9UL Image (Some ImageRole) "A starry sky above a mountain ridge" None "A starry sky above a mountain ridge"
                        { Id=10UL; Kind=Scroll; Role=Some Group; Name=Some "Scrollable layout notes"; Action=None; Text=None
                          Layout={ Direction="column"; Width="grow"; Height="fixed"; Padding=12.; Gap=8. }
                          Children=[leaf 11UL Text None "Layout notes" None "Resize the browser to see the responsive card. Use Tab to move through the controls, then Space or Enter to activate them. The counter updates in a polite live region. The checkbox controls this details section. The image has alternative text, and this notes panel scrolls independently when its content is taller than the panel. All three runtimes use the same action IDs: 100 decreases, 101 increases, and 102 toggles details."] }] }
        { Id=1UL; Kind=Container; Role=Some Group; Name=Some "Counter showcase"; Action=None; Text=None
          Layout={ Direction="column"; Width="grow"; Height="grow"; Padding=24.; Gap=16. }
          Children=[
            leaf 2UL Text None "Counter" None (sprintf "Count: %d" model.Count)
            actions
            leaf 6UL Checkbox (Some CheckboxRole) "Show details" (Some 102UL) (string model.Expanded)
            if model.Expanded then details
          ] }

    let dispatch action =
        match action with 100UL -> Some Decrement | 101UL -> Some Increment | 102UL -> Some Toggle | _ -> None
