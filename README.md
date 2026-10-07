# Elmish Clay

A small cross-language UI core built on Clay. This project wraps Clay's macro-oriented layout builder behind a C ABI and defines version 1 of a semantic UI contract. The upstream Clay header is vendored in `third_party/clay/` so the project builds as a standalone checkout; it remains unmodified and retains its own license.

## Contract

`EclDocument`/`EclElement` define a deterministic IR shape. IDs are app-provided stable 64-bit values, action IDs are opaque symbols dispatched by the language runtime, and model state and closures stay in each app. Elements carry layout intent, control kind/role, accessible name, state flags, and style measurements. Accessibility validation belongs to the language-level lowering layer: actionable controls need a role, accessible name, and action ID unless the app has explicitly opted out or a reasoned subtree exemption applies. Diagnostics retain source and affected element indexes.

Version 1 ABI currently exposes the Clay frame builder and render command/geometry readers. Each target adapter advertises semantic capabilities; browser output is the visual reference and uses semantic DOM peers, while native/TUI use platform peers and adapt geometry. This C ABI is deliberately narrower than the IR and is not a DOM or Elm runtime.

## Build

```sh
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```

To install the C library and public header, run `cmake --install build --prefix <install-prefix>` after building. A CMake consumer can then use:

```cmake
find_package(elmish_clay 0.1 CONFIG REQUIRED)
target_link_libraries(my_app PRIVATE elmish_clay::elmish_clay)
```

The host must provide a text measurement callback for real font metrics. The fallback is deterministic approximate measurement for smoke tests only. The caller owns and must retain the Clay arena memory for the initialized context.

For the C core and all C, F#, and Haskell browser demos, use `make build`. Run the native C test and browser-driven parity checks with `make test`. Browser checks need Node.js/npm, Playwright, and Chrome (macOS) or a Playwright Chromium installation. See `make help` for individual build and serve stages.

## Roadmap boundaries

The current deliverable includes the C core and matching C, F#, and Haskell browser showcases. Bolero and Miso browser hosts are implemented; Terminal.Gui/Avalonia.FuncUI, Brick/GTK4/Miso Native, platform accessibility audits, and full WCAG verification remain follow-on work. Wavelet remains a future IR consumer.

## Browser examples

C, F#, and Haskell browser examples follow the shared contract in `examples/browser/showcase.json` and render the same semantic DOM, content, actions, and layout using one stylesheet. See `examples/browser/README.md` for launch commands. The C target owns model/action state in WebAssembly and runs the Clay C ABI layout pass; F# uses Bolero WebAssembly and Haskell uses Miso WebAssembly.

## Accessibility and target profile

The contract sets WCAG 2.2 AA as the default app profile. An app-level opt-out is an explicit runtime configuration, and component exemptions carry a required reason, source component, and inherited subtree scope. Reports should attach affected descendant IDs and roll exemption diagnostics up through ancestor and whole-app reports. Required semantic omissions are errors by default; detectable heuristic concerns are warnings. Web pages require complete-page WCAG review; native adapters verify names, roles, focus, and actions through platform accessibility APIs; TUI adapters keep navigation keyboard-driven and states independent of color.

The intended full host matrix is Bolero plus Terminal.Gui and Avalonia.FuncUI for F#, and Miso plus Brick, GTK4/haskell-gi, and Miso Native/Lynx for Haskell. The IR and Clay ABI do not claim those adapters are already implemented. Browser DOM is the visual reference. Canvas is reserved for decorative/custom drawing, while native peers map semantics and TUI may adapt dimensions to terminal cells.
