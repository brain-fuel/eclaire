{-# LANGUAGE DeriveGeneric #-}
module Main where

import Data.Word (Word64)

data Msg = Increment | Decrement | Toggle deriving (Eq, Show)
data Model = Model { count :: Int, expanded :: Bool } deriving (Eq, Show)
data Cmd = NoCommand deriving (Eq, Show)
data Kind = Container | Text | Image | Button | Checkbox | Scroll deriving (Eq, Show)
data Role = Group | ButtonRole | CheckboxRole | ImageRole deriving (Eq, Show)
data Layout = Layout { direction :: String, width :: String, height :: String, padding :: Float, gap :: Float } deriving (Eq, Show)
data Element = Element { stableId :: Word64, kind :: Kind, role :: Maybe Role, accessibleName :: Maybe String, actionId :: Maybe Word64, text :: Maybe String, layout :: Layout, children :: [Element] } deriving (Eq, Show)

initModel :: (Model, Cmd)
initModel = (Model 0 True, NoCommand)

update :: Msg -> Model -> (Model, Cmd)
update Increment m = (m { count = count m + 1 }, NoCommand)
update Decrement m = (m { count = count m - 1 }, NoCommand)
update Toggle m = (m { expanded = not (expanded m) }, NoCommand)

leaf :: Word64 -> Kind -> Maybe Role -> String -> Maybe Word64 -> String -> Element
leaf i k r name action value = Element i k r (Just name) action (Just value) (Layout "column" "fit" "fit" 0 0) []

scrollCopy :: String
scrollCopy = "Resize the browser to see the responsive card. Use Tab to move through the controls, then Space or Enter to activate them. The counter updates in a polite live region. The checkbox controls this details section. The image has alternative text, and this notes panel scrolls independently when its content is taller than the panel. All three runtimes use the same action IDs: 100 decreases, 101 increases, and 102 toggles details."

-- Pure semantic tree, using the same stable element/action IDs as the F# and C showcases.
view :: Model -> Element
view m = Element 1 Container (Just Group) (Just "Counter showcase") Nothing Nothing
  (Layout "column" "grow" "grow" 24 16)
  ([ leaf 2 Text Nothing "Counter" Nothing ("Count: " ++ show (count m))
   , Element 3 Container (Just Group) (Just "Counter actions") Nothing Nothing (Layout "row" "grow" "fit" 0 12)
       [ leaf 4 Button (Just ButtonRole) "Decrease" (Just 100) "−"
       , leaf 5 Button (Just ButtonRole) "Increase" (Just 101) "+"
       ]
   , leaf 6 Checkbox (Just CheckboxRole) "Show details" (Just 102) (show (expanded m))
   ] ++ [Element 7 Container (Just Group) (Just "Details") Nothing Nothing (Layout "column" "grow" "fit" 0 14)
       [ leaf 8 Text Nothing "Details" Nothing "Clay solves layout; each host preserves control semantics."
       , leaf 9 Image (Just ImageRole) "A starry sky above a mountain ridge" Nothing "A starry sky above a mountain ridge"
       , Element 10 Scroll (Just Group) (Just "Scrollable layout notes") Nothing Nothing (Layout "column" "grow" "fixed" 12 8)
           [leaf 11 Text Nothing "Layout notes" Nothing scrollCopy]
       ] | expanded m])

dispatch :: Word64 -> Maybe Msg
dispatch 100 = Just Decrement
dispatch 101 = Just Increment
dispatch 102 = Just Toggle
dispatch _ = Nothing

main :: IO ()
main = print (view (fst initModel))
