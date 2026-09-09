//! Golden-file tests: every `tests/fixtures/*.asm` is checked against the
//! `.hack` file beside it. Each pair runs as its own test case.

use std::{
    fs,
    path::{Path, PathBuf},
    process::ExitCode,
};

use libtest_mimic::{Arguments, Failed, Trial};

fn main() -> ExitCode {
    let args = Arguments::from_args();
    let trials = collect_trials();
    assert!(
        !trials.is_empty(),
        "no .asm fixtures found in {}",
        fixtures().display()
    );
    libtest_mimic::run(&args, trials).exit_code()
}

fn fixtures() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures")
}

fn collect_trials() -> Vec<Trial> {
    let dir = fixtures();
    let mut paths: Vec<PathBuf> = fs::read_dir(&dir)
        .unwrap_or_else(|e| panic!("{}: {e}", dir.display()))
        .map(|entry| entry.expect("read fixture dir entry").path())
        .filter(|p| p.extension().and_then(|e| e.to_str()) == Some("asm"))
        .collect();
    paths.sort();

    paths
        .into_iter()
        .map(|asm| {
            let name = asm.file_stem().unwrap().to_string_lossy().into_owned();
            Trial::test(name, move || check(&asm))
        })
        .collect()
}

fn check(asm: &Path) -> Result<(), Failed> {
    let expected_path = asm.with_extension("hack");
    let expected = fs::read_to_string(&expected_path)
        .map_err(|e| format!("{}: {e}", expected_path.display()))?;
    let asm_string = std::fs::read_to_string(&asm)?;
    let got = hack::assembler::assemble(asm_string.as_str(), &hack::board::Board::default())
        .map_err(|e| format!("{}: {e}", asm.display()))?;

    if got.to_string().trim_end() != expected.trim_end() {
        let (line, g, w) = first_diff(&got.to_string(), &expected);
        return Err(format!(
            "mismatch vs {} at line {line}:\n  got:      {g}\n  expected: {w}",
            expected_path.display()
        )
        .into());
    }
    Ok(())
}

/// Line number and contents of the first differing line, for a readable failure.
fn first_diff(got: &str, expected: &str) -> (usize, String, String) {
    let mut g = got.lines();
    let mut e = expected.lines();
    let mut n = 0;
    loop {
        n += 1;
        match (g.next(), e.next()) {
            (Some(a), Some(b)) if a.trim_end() == b.trim_end() => continue,
            (a, b) => {
                return (
                    n,
                    a.unwrap_or("<eof>").to_string(),
                    b.unwrap_or("<eof>").to_string(),
                );
            }
        }
    }
}
