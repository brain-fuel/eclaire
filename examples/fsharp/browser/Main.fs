module ElmishClayBrowser.Client.Main

open Elmish
open Bolero
open Bolero.Html
open ElmishClay.Showcase

let private scrollCopy =
    "Resize the browser to see the responsive card. Use Tab to move through the controls, then Space or Enter to activate them. The counter updates in a polite live region. The checkbox controls this details section. The image has alternative text, and this notes panel scrolls independently when its content is taller than the panel. All three runtimes use the same action IDs: 100 decreases, 101 increases, and 102 toggles details."

let view model dispatch =
    concat {
        header {
            p { attr.``class`` "eyebrow"; "ELMISH CLAY SHOWCASE" }
            h1 { "One model, three runtimes" }
            p { attr.``class`` "lede"; "The same state, controls, content, and actions in C, F#, and Haskell." }
        }
        main {
            attr.``class`` "showcase"
            "aria-labelledby" => "showcase-title"
            h2 { attr.id "showcase-title"; "Counter showcase" }
            p { attr.``class`` "count"; attr.id "counter"; "aria-live" => "polite"; $"Count: {model.Count}" }
            div {
                attr.``class`` "actions"
                button {
                    attr.id "decrease"
                    attr.``type`` "button"
                    "data-action" => "100"
                    "aria-label" => "Decrease"
                    on.click (fun _ -> dispatch Decrement)
                    "−"
                }
                button {
                    attr.id "increase"
                    attr.``type`` "button"
                    "data-action" => "101"
                    "aria-label" => "Increase"
                    on.click (fun _ -> dispatch Increment)
                    "+"
                }
            }
            label {
                attr.``class`` "check-row"
                input {
                    attr.id "show-details"
                    attr.``type`` "checkbox"
                    attr.``checked`` model.Expanded
                    "data-action" => "102"
                    on.change (fun _ -> dispatch Toggle)
                }
                "Show details"
            }
            section {
                attr.``class`` "details"
                attr.hidden (not model.Expanded)
                "aria-label" => "Details"
                p { "Clay solves layout; each host preserves control semantics." }
                img {
                    attr.src "/night-sky.svg"
                    attr.alt "A starry sky above a mountain ridge"
                    attr.``class`` "hero-image"
                }
                section {
                    attr.``class`` "scroll-area"
                    "role" => "region"
                    "aria-label" => "Scrollable layout notes"
                    p { scrollCopy }
                }
            }
        }
        footer { "Elmish Clay cross-language showcase · actions 100–102" }
    }

type MyApp() =
    inherit ProgramComponent<Model, Msg>()
    override this.Program = Program.mkSimple (fun _ -> fst (App.init())) (fun msg model -> fst (App.update msg model)) view
