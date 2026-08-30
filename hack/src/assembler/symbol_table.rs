use std::collections::HashMap;

use anyhow::Result;

use crate::assembler::{board, code, symbol};

pub(super) const STARTING_VARIABLE_VALUE: u16 = 16;

pub struct SymbolTable<'a> {
    allocation_address: u16,
    table: HashMap<symbol::Symbol<'a>, u16>,
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
                (symbol::Symbol("R0"), 0u16),
                (symbol::Symbol("R1"), 1),
                (symbol::Symbol("R2"), 2),
                (symbol::Symbol("R3"), 3),
                (symbol::Symbol("R4"), 4),
                (symbol::Symbol("R5"), 5),
                (symbol::Symbol("R6"), 6),
                (symbol::Symbol("R7"), 7),
                (symbol::Symbol("R8"), 8),
                (symbol::Symbol("R9"), 9),
                (symbol::Symbol("R10"), 10),
                (symbol::Symbol("R11"), 11),
                (symbol::Symbol("R12"), 12),
                (symbol::Symbol("R13"), 13),
                (symbol::Symbol("R14"), 14),
                (symbol::Symbol("R15"), 15),
                (symbol::Symbol("SP"), 0),
                (symbol::Symbol("LCL"), 1),
                (symbol::Symbol("ARG"), 2),
                (symbol::Symbol("THIS"), 3),
                (symbol::Symbol("THAT"), 4),
            ]),
        }
    }

    pub fn for_board(&mut self, board: board::Board<'a>) {
        self.table.extend(board.symbols.iter().map(|(k, v)| (k, v)));
    }

    pub fn add(&mut self, symbol: &'a symbol::Symbol, value: u16) -> Result<()> {
        let max_address = code::MAX_ADDRESS;
        if value > max_address {
            anyhow::bail!("symbol {symbol} has value {value} which exceeds {max_address}")
        }

        if let Some(existing) = self.table.get(symbol) {
            anyhow::bail!("symbol {symbol} already defined as {existing}")
        }

        self.table.insert(*symbol, value);
        Ok(())
    }

    pub fn allocate(&mut self, symbol: &'a symbol::Symbol) -> Result<()> {
        let max_address = code::MAX_ADDRESS;
        if self.allocation_address > max_address {
            anyhow::bail!("variable allocation addresses have been exhausted")
        }

        if let Some(existing) = self.table.get(symbol) {
            anyhow::bail!("symbol {symbol} already defined as {existing}")
        }

        self.table.insert(*symbol, self.allocation_address);
        self.allocation_address += 1;

        Ok(())
    }

    pub fn get(&self, symbol: &symbol::Symbol) -> Option<u16> {
        self.table.get(symbol).copied()
    }

    pub fn contains(&self, symbol: &symbol::Symbol) -> bool {
        self.table.contains_key(symbol)
    }
}

#[test]
fn test_get_and_contains_default_symbol_table() {
    let default_symbols = [
        (symbol::Symbol("R0"), Some(0u16)),
        (symbol::Symbol("R1"), Some(1)),
        (symbol::Symbol("R2"), Some(2)),
        (symbol::Symbol("R3"), Some(3)),
        (symbol::Symbol("R4"), Some(4)),
        (symbol::Symbol("R5"), Some(5)),
        (symbol::Symbol("R6"), Some(6)),
        (symbol::Symbol("R7"), Some(7)),
        (symbol::Symbol("R8"), Some(8)),
        (symbol::Symbol("R9"), Some(9)),
        (symbol::Symbol("R10"), Some(10)),
        (symbol::Symbol("R11"), Some(11)),
        (symbol::Symbol("R12"), Some(12)),
        (symbol::Symbol("R13"), Some(13)),
        (symbol::Symbol("R14"), Some(14)),
        (symbol::Symbol("R15"), Some(15)),
        (symbol::Symbol("SP"), Some(0)),
        (symbol::Symbol("LCL"), Some(1)),
        (symbol::Symbol("ARG"), Some(2)),
        (symbol::Symbol("THIS"), Some(3)),
        (symbol::Symbol("THAT"), Some(4)),
        (symbol::Symbol("MISSING"), None),
    ];

    let symbol_table = SymbolTable::default();

    for (symbol, value) in default_symbols.iter() {
        assert_eq!(symbol_table.get(symbol), *value, "{symbol}");
        match value {
            Some(_) => assert!(symbol_table.contains(symbol), "does not contain {symbol}"),
            None => assert!(!symbol_table.contains(symbol), "contains {symbol}"),
        }
    }
}

#[test]
fn test_nand2tetris_simulator_symbols() {
    let mut symbol_table = SymbolTable::default();
    let board = board::Board::default();
    symbol_table.for_board(board);

    let screen = symbol::Symbol("SCREEN");
    assert_eq!(symbol_table.get(&screen), Some(16384));
    assert!(symbol_table.contains(&screen));

    let kbd = symbol::Symbol("KBD");
    assert_eq!(symbol_table.get(&kbd), Some(24576));
    assert!(symbol_table.contains(&kbd));
}

#[test]
fn test_go_board_symbols() {
    let mut symbol_table = SymbolTable::default();
    let test_string = r#"
    name      = "go-board"
    rom-words = 3072    # 12 EBRs
    ram-words = 1024    # 4 EBRS

    [symbols]
    LED = 0x03FA
    SEG = 0x03FB
    BTN = 0x03FC
    UART_TX = 0x03FD
    UART_RX = 0x03FE
    UART_ST = 0x03FF
    "#;

    let board = board::load(test_string);
    assert!(board.is_ok());
    let board = board.unwrap();

    symbol_table.for_board(board);

    let screen = symbol::Symbol("LED");
    assert_eq!(symbol_table.get(&screen), Some(0x03FA));
    assert!(symbol_table.contains(&screen));

    let kbd = symbol::Symbol("SEG");
    assert_eq!(symbol_table.get(&kbd), Some(0x03FB));
    assert!(symbol_table.contains(&kbd));

    let screen = symbol::Symbol("BTN");
    assert_eq!(symbol_table.get(&screen), Some(0x03FC));
    assert!(symbol_table.contains(&screen));

    let kbd = symbol::Symbol("UART_TX");
    assert_eq!(symbol_table.get(&kbd), Some(0x03FD));
    assert!(symbol_table.contains(&kbd));

    let screen = symbol::Symbol("UART_RX");
    assert_eq!(symbol_table.get(&screen), Some(0x03FE));
    assert!(symbol_table.contains(&screen));

    let kbd = symbol::Symbol("UART_ST");
    assert_eq!(symbol_table.get(&kbd), Some(0x03FF));
    assert!(symbol_table.contains(&kbd));
}

#[test]
fn test_add_symbol() -> anyhow::Result<()> {
    let mut symbol_table = SymbolTable::default();

    let i = symbol::Symbol("i");
    symbol_table.add(&i, 16)?;
    assert_eq!(symbol_table.get(&i), Some(16));

    let j = symbol::Symbol("j");
    symbol_table.add(&j, 17)?;
    assert_eq!(symbol_table.get(&j), Some(17));

    let k = symbol::Symbol("k");
    symbol_table.add(&k, 18)?;
    assert_eq!(symbol_table.get(&k), Some(18));

    Ok(())
}

#[test]
fn test_add_existing_symbol_errors() -> anyhow::Result<()> {
    let mut symbol_table = SymbolTable::default();

    let i = symbol::Symbol("i");
    symbol_table.add(&i, 16)?;
    assert!(symbol_table.add(&i, 16).is_err());

    Ok(())
}

#[test]
fn test_add_symbol_bounds() -> anyhow::Result<()> {
    let mut symbol_table = SymbolTable::default();

    let ok = symbol::Symbol("OK");
    symbol_table.add(&ok, code::MAX_ADDRESS)?;
    assert_eq!(symbol_table.get(&ok), Some(code::MAX_ADDRESS));

    assert!(
        symbol_table
            .add(&symbol::Symbol("BAD"), code::MAX_ADDRESS + 1)
            .is_err()
    );

    Ok(())
}
