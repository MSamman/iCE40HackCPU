mod code;
mod parser;
mod symbol_table;

use std::fmt::Write;
use std::path::Path;

use anyhow::Result;
use symbol_table::SymbolTable;

pub fn assemble(file: &Path) -> Result<String> {
    let asm_code = std::fs::read_to_string(file)?;

    let instructions = parser::parse(&asm_code)?;

    let mut symbol_table = SymbolTable::new();

    // First pass
    let mut rom_len = 0;
    for inst in &instructions {
        match inst {
            parser::Instruction::L {
                label: parser::Symbol(s),
            } => {
                symbol_table.add(s, rom_len)?;
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
                value: parser::Value::Symbol(parser::Symbol(s)),
            } => {
                if !symbol_table.contains(s) {
                    symbol_table.allocate(s)?;
                }

                symbol_table.get(s).unwrap()
            }
            parser::Instruction::A {
                value: parser::Value::Constant(v),
            } => *v,
            &parser::Instruction::C { dest, comp, jump } => code::encode_c(dest, comp, jump),
            parser::Instruction::L { .. } => continue,
        };

        writeln!(hack_string, "{bitcode:016b}")?;
    }

    Ok(hack_string)
}
