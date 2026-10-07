{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Miso
import Miso.Html.Element as H
import Miso.Html.Event as E
import Miso.Html.Property as P
import Miso.Lens (this, (%=))

#ifdef WASM
foreign export javascript "hs_start" main :: IO ()
#endif

data Model = Model { count :: Int, expanded :: Bool } deriving (Eq, Show)
data Action = Increment | Decrement | SetExpanded Bool deriving (Eq, Show)

main :: IO ()
main = startApp defaultEvents app

app :: App Model Action
app = component (Model 0 True) updateModel viewModel

updateModel :: Action -> Effect parent props Model Action
updateModel = \case
  Increment -> this %= \m -> m { count = count m + 1 }
  Decrement -> this %= \m -> m { count = count m - 1 }
  SetExpanded value -> this %= \m -> m { expanded = value }

scrollCopy :: MisoString
scrollCopy = "Resize the browser to see the responsive card. Use Tab to move through the controls, then Space or Enter to activate them. The counter updates in a polite live region. The checkbox controls this details section. The image has alternative text, and this notes panel scrolls independently when its content is taller than the panel. All three runtimes use the same action IDs: 100 decreases, 101 increases, and 102 toggles details."

viewModel :: Model -> View context props Model Action
viewModel m = H.div_ [P.id_ "app", P.class_ "page"]
  [ H.header_ []
      [ H.p_ [P.class_ "eyebrow"] ["ECLAIRE SHOWCASE"]
      , H.h1_ [] ["One model, three runtimes"]
      , H.p_ [P.class_ "lede"] ["The same state, controls, content, and actions in C, F#, and Haskell."]
      ]
  , H.main_ [P.class_ "showcase", P.aria_ "labelledby" "showcase-title"]
      [ H.h2_ [P.id_ "showcase-title"] ["Counter showcase"]
      , H.p_ [P.class_ "count", P.id_ "counter", P.aria_ "live" "polite"] [text (ms ("Count: " ++ show (count m)))]
      , H.div_ [P.class_ "actions"]
          [ H.button_ [P.id_ "decrease", P.type_ "button", P.data_ "action" "100", P.aria_ "label" "Decrease", E.onClick Decrement] ["−"]
          , H.button_ [P.id_ "increase", P.type_ "button", P.data_ "action" "101", P.aria_ "label" "Increase", E.onClick Increment] ["+"]
          ]
      , H.label_ [P.class_ "check-row"]
          [ H.input_ [P.id_ "show-details", P.type_ "checkbox", P.checked_ (expanded m), P.data_ "action" "102", E.onChecked (\(Checked value) -> SetExpanded value)]
          , "Show details"
          ]
      , H.section_ [P.class_ "details", P.aria_ "label" "Details", P.hidden_ (not (expanded m))]
          [ H.p_ [] ["Clay solves layout; each host preserves control semantics."]
          , H.img_ [P.src_ "/night-sky.svg", P.alt_ "A starry sky above a mountain ridge", P.class_ "hero-image"]
          , H.section_ [P.class_ "scroll-area", P.role_ "region", P.aria_ "label" "Scrollable layout notes"]
              [ H.p_ [] [text scrollCopy] ]
          ]
      ]
  , H.footer_ [] ["Eclaire cross-language showcase · actions 100–102"]
  ]
