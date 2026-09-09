mod code;
mod parser;
pub(crate) mod symbol;
mod symbol_table;

use std::fmt;
use std::fmt::{Display, Formatter};
use std::io::Write;

use crate::board::Board;
use anyhow::Result;
use symbol_table::SymbolTable;

pub fn assemble(asm_code: &str, board: &Board) -> Result<Bitcodes> {
    let mut symbol_table = SymbolTable::new();
    symbol_table.for_board(board);

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
    let mut bitcodes = Vec::with_capacity(rom_len as usize * 17);
    for inst in &instructions {
        let bitcode: u16 = match inst {
            parser::Instruction::A {
                value: symbol::Value::Symbol(s),
            } => {
                if !symbol_table.contains(&s) {
                    symbol_table.allocate(&s)?;
                }

                symbol_table.get(&s).unwrap()
            }
            parser::Instruction::A {
                value: symbol::Value::Constant(v),
            } => *v,
            parser::Instruction::C { dest, comp, jump } => code::encode_c(*dest, *comp, *jump),
            parser::Instruction::L { .. } => continue,
        };

        bitcodes.push(bitcode);
    }

    Ok(Bitcodes(bitcodes))
}

pub struct Bitcodes(pub Vec<u16>);

/// `.hack` text format
impl Display for Bitcodes {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        for word in &self.0 {
            writeln!(f, "{word:016b}")?;
        }
        Ok(())
    }
}

impl Bitcodes {
    pub fn write_bin<W: Write>(&self, writer: &mut W) -> anyhow::Result<()> {
        for word in self.words() {
            writer.write_all(&word.to_be_bytes())?;
        }

        Ok(())
    }

    pub fn words(&self) -> &[u16] {
        &self.0
    }
}
