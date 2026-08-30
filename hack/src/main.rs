use std::path::PathBuf;

use anyhow::Result;
use clap::{Parser, Subcommand};
use hack::assembler::assemble;

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Assemble {
        file: PathBuf,

        #[arg(short, long)]
        board: Option<PathBuf>,

        #[arg(short, long)]
        outfile: Option<PathBuf>,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Assemble {
            file,
            board,
            outfile,
        } => {
            let file_display = file.display();
            println!("Assembling {file_display}...");

            let hack_string = assemble(file, board)?;

            match outfile {
                Some(_) => {}
                None => {
                    println!("{}", hack_string);
                }
            }
        }
    }

    Ok(())
}
