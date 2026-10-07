import { WASI, OpenFile, File, ConsoleStdout } from "https://cdn.jsdelivr.net/npm/@bjorn3/browser_wasi_shim@0.3.0/dist/index.js";
const fds = [new OpenFile(new File([])), ConsoleStdout.lineBuffered(console.log), ConsoleStdout.lineBuffered(console.warn)];
const wasi = new WASI([], ["GHCRTS=-H32m"], fds, { debug: false });
const { instance } = await WebAssembly.instantiateStreaming(fetch("./eclaire-c.wasm"), {
  wasi_snapshot_preview1: wasi.wasiImport,
});
const exitCode = wasi.start(instance);
if (exitCode !== 0) throw new Error(`C WASI startup returned ${exitCode}`);
const { demo_count, demo_expanded, demo_action, demo_init, demo_layout } = instance.exports;
const root = document.querySelector("#app");
const count = document.querySelector("#counter");
const details = document.querySelector(".details");
const checkbox = document.querySelector("#show-details");
function frame() {
  const result = demo_layout(window.innerWidth, window.innerHeight);
  if (result !== 0) console.error(`Clay layout returned ${result}`);
}
function render() {
  count.textContent = `Count: ${demo_count()}`;
  checkbox.checked = demo_expanded() !== 0;
  details.hidden = demo_expanded() === 0;
  frame();
}
const initialized = demo_init(window.innerWidth, window.innerHeight);
if (initialized !== 0) throw new Error(`Clay initialization returned ${initialized}`);
render();
root.addEventListener("click", event => {
  const button = event.target.closest("button[data-action]");
  if (!button) return;
  demo_action(Number(button.dataset.action));
  render();
});
checkbox.addEventListener("change", () => {
  demo_action(Number(checkbox.dataset.action));
  render();
});
window.addEventListener("resize", frame, { passive: true });
