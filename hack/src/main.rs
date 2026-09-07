use io::Write;
use std::fs::OpenOptions;
use std::{io, path::PathBuf};

use anyhow::Result;
use clap::{CommandFactory, Parser, Subcommand, ValueEnum, error::ErrorKind};
use hack::assembler::assemble;

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Copy, Clone, PartialEq, Eq, Debug, ValueEnum)]
enum OutKind {
    Stdout,
    File,
}

#[derive(Subcommand)]
enum Commands {
    Assemble {
        target_file: PathBuf,

        #[arg(short, long)]
        board: Option<PathBuf>,

        #[arg(long, value_enum, default_value_t = OutKind::Stdout)]
        out: OutKind,

        #[arg(long, value_name = "PATH")]
        filename: Option<PathBuf>,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Assemble {
            target_file,
            board,
            out,
            filename,
        } => {
            let file_display = target_file.display();
            println!("Assembling {file_display}...");

            let hack_string = assemble(target_file, board)?;

            match out {
                OutKind::File => {
                    let default_name = target_file.with_extension("bin");
                    let out_path = filename.as_deref().unwrap_or(default_name.as_path());
                    println!("Writing to {out_path:?}...");

                    let mut out_file =
                        OpenOptions::new().write(true).create(true).open(out_path)?;
                    write!(out_file, "{}", hack_string)?;
                }
                OutKind::Stdout => {
                    if filename.is_some() {
                        Cli::command()
                            .error(
                                ErrorKind::ArgumentConflict,
                                "--filename cannot be used with --out std",
                            )
                            .exit();
                    }
                    println!("{}", hack_string);
                }
            }
        }
    }

    Ok(())
}
