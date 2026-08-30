mod board;
mod code;
mod parser;
mod symbol;
mod symbol_table;

use std::fmt::Write;
use std::path::{Path, PathBuf};

use anyhow::Result;
use symbol_table::SymbolTable;

pub fn assemble(file: &Path, board: &Option<PathBuf>) -> Result<String> {
    let config_string: String;
    let board = match board {
        None => board::Board::default(),
        Some(p) => {
            config_string = std::fs::read_to_string(p)?;
            board::load(config_string.as_str())?
        }
    };

    let mut symbol_table = SymbolTable::new();
    symbol_table.for_board(board);

    let asm_code = std::fs::read_to_string(file)?;
    let instructions = parser::parse(&asm_code)?;

    // First pass
    let mut rom_len = 0;
    for inst in &instructions {
        match inst {
            parser::Instruction::L { label: l } => {
                symbol_table.add(l, rom_len)?;
            }
            _ => {
                rom_len += 1;
            }
        }
    }

    // Second pass
    let mut hack_string = String::with_capacity(rom_len as usize * 17);
    for inst in &instructions {
        let bitcode: u16 = match inst {
            parser::Instruction::A {
                value: symbol::Value::Symbol(s),
            } => {
                if !symbol_table.contains(s) {
                    symbol_table.allocate(s)?;
                }

                symbol_table.get(s).unwrap()
            }
            parser::Instruction::A {
                value: symbol::Value::Constant(v),
            } => *v,
            &parser::Instruction::C { dest, comp, jump } => code::encode_c(dest, comp, jump),
            parser::Instruction::L { .. } => continue,
        };

        writeln!(hack_string, "{bitcode:016b}")?;
    }

    Ok(hack_string)
}
