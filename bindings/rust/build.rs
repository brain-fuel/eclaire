use std::{env, fs, path::PathBuf};

fn main() {
    let root = PathBuf::from(env::var_os("CARGO_MANIFEST_DIR").expect("manifest directory"));
    let lock = fs::read_to_string(root.join("eclaire.toml")).expect("read eclaire.toml");
    let expected_version = lock
        .lines()
        .find_map(|line| line.strip_prefix("version = \""))
        .and_then(|value| value.strip_suffix('\"'))
        .expect("eclaire.toml version");
    let package_version = env::var("CARGO_PKG_VERSION").expect("Cargo package version");
    assert_eq!(package_version, expected_version, "Cargo.toml must use the Eclaire release version");
    cc::Build::new()
        .file(root.join("src/eclaire.c"))
        .include(root.join("include"))
        .include(root.join("third_party/clay"))
        .warnings(true)
        .compile("eclaire");
    for file in ["eclaire.toml", "src/eclaire.c", "include/eclaire.h", "third_party/clay/clay.h"] {
        println!("cargo:rerun-if-changed={}", root.join(file).display());
    }
}
