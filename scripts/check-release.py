#!/usr/bin/env python3
"""Check that a release pins one Eclaire version to one vendored Clay revision."""
from __future__ import annotations

import hashlib
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
manifest = (ROOT / "eclaire.toml").read_text()

def field(name: str) -> str:
    match = re.search(rf'^{re.escape(name)} = "([^"]+)"$', manifest, re.M)
    assert match, f"missing {name} in eclaire.toml"
    return match.group(1)

version = field("version")
clay_commit = field("clay_commit")
header_hash = hashlib.sha256((ROOT / "third_party/clay/clay.h").read_bytes()).hexdigest()
assert header_hash == field("clay_header_sha256"), "vendored Clay header differs from eclaire.toml"
assert len(clay_commit) == 40 and all(c in "0123456789abcdef" for c in clay_commit), "invalid Clay commit"

checks = {
    "CMakeLists.txt": rf"project\(eclaire VERSION {re.escape(version)} LANGUAGES C\)",
    "Cargo.toml": rf'name = "eclaire"\s+version = "{re.escape(version)}"',
    "eclaire.cabal": rf"name: eclaire\s+version: {re.escape(version)}\.0",
    "bindings/fsharp/Eclaire.fsproj": rf"<PackageId>Eclaire</PackageId>\s+<Version>{re.escape(version)}</Version>",
    "bindings/fsharp/buildTransitive/Eclaire.targets": rf"<EclairePackageVersion Condition=.*>{re.escape(version)}</EclairePackageVersion>",
    "bindings/go/eclaire/native.go": rf'const Version = "{re.escape(version)}"',
    "bindings/haskell-cli/Main.hs": rf'packageVersion = "{re.escape(version)}"',
    "go.mod": r"module github\.com/brain-fuel/eclaire",
    "bindings/go/quicken/go.mod": rf"github\.com/brain-fuel/eclaire v{re.escape(version)}",
    "eclaire.toml": rf'version = "{re.escape(version)}"',
}
for relative, pattern in checks.items():
    content = (ROOT / relative).read_text()
    assert re.search(pattern, content), f"{relative} does not match Eclaire version {version}"

for relative in ["third_party/clay/README.md", "bindings/haskell/Eclaire.hs", "bindings/rust/lib.rs", "bindings/fsharp/Eclaire.fs", "bindings/go/eclaire/native.go"]:
    assert clay_commit in (ROOT / relative).read_text(), f"{relative} does not record Clay commit {clay_commit}"

for stale_name in ["Elmish" + " Clay", "elmish" + "-clay", "elmish" + "_clay", "ECL" + "_"]:
    for path in ROOT.rglob("*"):
        if not path.is_file() or any(part in {".git", "build", "target", ".stack-work", "node_modules"} for part in path.parts):
            continue
        if path.suffix in {".lock", ".wasm", ".png", ".svg", ".dll", ".dylib", ".a", ".o", ".hi"}:
            continue
        try:
            content = path.read_text()
        except (UnicodeDecodeError, OSError):
            continue
        assert stale_name not in content, f"stale project name {stale_name!r} remains in {path.relative_to(ROOT)}"

print(f"Eclaire {version} pins Clay {clay_commit} ({header_hash})")
