use std::process::ExitCode;

fn main() -> ExitCode {
    let args: Vec<_> = std::env::args().skip(1).collect();
    match args.as_slice() {
        [] => print_version(),
        [arg] if arg == "--version" || arg == "version" => print_version(),
        [arg] if arg == "--help" || arg == "help" => {
            println!("Usage: eclaire [version|--version|--help]");
            ExitCode::SUCCESS
        }
        _ => {
            eprintln!("Usage: eclaire [version|--version|--help]");
            ExitCode::from(2)
        }
    }
}

fn print_version() -> ExitCode {
            println!("Eclaire {} (IR {}, Clay {})", env!("CARGO_PKG_VERSION"), eclaire::ir_version(), eclaire::CLAY_COMMIT);
            ExitCode::SUCCESS
}
