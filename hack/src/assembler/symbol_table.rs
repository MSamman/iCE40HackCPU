use std::collections::HashMap;

use anyhow::Result;

use crate::assembler::code;

pub(super) const STARTING_VARIABLE_VALUE: u16 = 16;

pub struct SymbolTable<'a> {
    allocation_address: u16,
    table: HashMap<&'a str, u16>,
}

impl<'a> Default for SymbolTable<'a> {
    fn default() -> Self {
        Self::new()
    }
}

impl<'a> SymbolTable<'a> {
    pub fn new() -> SymbolTable<'a> {
        SymbolTable {
            allocation_address: STARTING_VARIABLE_VALUE,
            table: HashMap::from([
                ("R0", 0),
                ("R1", 1),
                ("R2", 2),
                ("R3", 3),
                ("R4", 4),
                ("R5", 5),
                ("R6", 6),
                ("R7", 7),
                ("R8", 8),
                ("R9", 9),
                ("R10", 10),
                ("R11", 11),
                ("R12", 12),
                ("R13", 13),
                ("R14", 14),
                ("R15", 15),
                ("SP", 0),
                ("LCL", 1),
                ("ARG", 2),
                ("THIS", 3),
                ("THAT", 4),
                ("SCREEN", 16384),
                ("KBD", 24576),
            ]),
        }
    }

    pub fn add(&mut self, symbol: &'a str, value: u16) -> Result<()> {
        let max_address = code::MAX_ADDRESS;
        if value > max_address {
            anyhow::bail!("symbol {symbol} has value {value} which exceeds {max_address}")
        }

        if let Some(existing) = self.table.get(symbol) {
            anyhow::bail!("symbol {symbol} already defined as {existing}")
        }

        self.table.insert(symbol, value);
        Ok(())
    }

    pub fn allocate(&mut self, symbol: &'a str) -> Result<()> {
        let max_address = code::MAX_ADDRESS;
        if self.allocation_address > max_address {
            anyhow::bail!("variable allocation addresses have been exhausted")
        }

        if let Some(existing) = self.table.get(symbol) {
            anyhow::bail!("symbol {symbol} already defined as {existing}")
        }

        self.table.insert(symbol, self.allocation_address);
        self.allocation_address += 1;

        Ok(())
    }

    pub fn get(&self, symbol: &str) -> Option<u16> {
        self.table.get(symbol).copied()
    }

    pub fn contains(&self, symbol: &str) -> bool {
        self.table.contains_key(symbol)
    }
}

#[test]
fn test_get_and_contains_default_symbol_table() {
    let default_symbols = [
        ("R0", Some(0u16)),
        ("R1", Some(1)),
        ("R2", Some(2)),
        ("R3", Some(3)),
        ("R4", Some(4)),
        ("R5", Some(5)),
        ("R6", Some(6)),
        ("R7", Some(7)),
        ("R8", Some(8)),
        ("R9", Some(9)),
        ("R10", Some(10)),
        ("R11", Some(11)),
        ("R12", Some(12)),
        ("R13", Some(13)),
        ("R14", Some(14)),
        ("R15", Some(15)),
        ("SP", Some(0)),
        ("LCL", Some(1)),
        ("ARG", Some(2)),
        ("THIS", Some(3)),
        ("THAT", Some(4)),
        ("MISSING", None),
    ];

    let symbol_table = SymbolTable::default();

    for &(symbol, value) in default_symbols.iter() {
        assert_eq!(symbol_table.get(symbol), value, "{symbol}");
        match value {
            Some(_) => assert!(symbol_table.contains(symbol), "does not contain {symbol}"),
            None => assert!(!symbol_table.contains(symbol), "contains {symbol}"),
        }
    }
}

#[test]
fn test_screen_enabled() {
    let symbol_table = SymbolTable::default();
    assert_eq!(symbol_table.get("SCREEN"), Some(16384));
    assert!(symbol_table.contains("SCREEN"));
}

#[test]
fn test_keyboard_enabled() {
    let symbol_table = SymbolTable::default();
    assert_eq!(symbol_table.get("KBD"), Some(24576));
    assert!(symbol_table.contains("KBD"));
}
#[test]
fn test_add_symbol() -> anyhow::Result<()> {
    let mut symbol_table = SymbolTable::default();

    let i = "i";
    symbol_table.add(i, 16)?;
    assert_eq!(symbol_table.get(i), Some(16));

    let j = "j";
    symbol_table.add(j, 17)?;
    assert_eq!(symbol_table.get(j), Some(17));

    let k = "k";
    symbol_table.add(k, 18)?;
    assert_eq!(symbol_table.get(k), Some(18));

    Ok(())
}

#[test]
fn test_add_existing_symbol_errors() -> anyhow::Result<()> {
    let mut symbol_table = SymbolTable::default();

    let i = "i";
    symbol_table.add(i, 16)?;
    assert!(symbol_table.add(i, 16).is_err());

    Ok(())
}

#[test]
fn test_add_symbol_bounds() -> anyhow::Result<()> {
    let mut symbol_table = SymbolTable::default();

    symbol_table.add("OK", code::MAX_ADDRESS)?;
    assert_eq!(symbol_table.get("OK"), Some(code::MAX_ADDRESS));

    assert!(symbol_table.add("BAD", code::MAX_ADDRESS + 1).is_err());

    Ok(())
}
