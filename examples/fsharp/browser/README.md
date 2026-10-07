# F# browser showcase

This Bolero WebAssembly host follows the shared content, element/action IDs, DOM structure, layout, and interactions in [the showcase contract](../../browser/showcase.json). It lowers the F# Elmish model into native browser buttons, a checkbox, a live counter, and a scrollable details panel.

```sh
cd eclaire/examples/fsharp/browser
dotnet run --no-launch-profile --project Eclaire.Browser.fsproj --urls http://127.0.0.1:5093
```

Open <http://127.0.0.1:5093>. Stop the server with Ctrl-C. The project synchronizes the shared CSS and image into `wwwroot` before each build, where the Blazor development server reads static assets. Build without running it with `dotnet build Eclaire.Browser.fsproj`.
