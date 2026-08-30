use std::collections::HashMap;

use anyhow::{Context, Result};
use serde::Deserialize;

use crate::assembler::symbol;

#[derive(Deserialize, Eq, PartialEq, Debug)]
#[serde(rename_all = "kebab-case", deny_unknown_fields)]
pub(super) struct Board<'a> {
    pub name: &'a str,
    pub ram_words: u16,
    pub rom_words: u16,
    #[serde(default, borrow)]
    pub symbols: HashMap<symbol::Symbol<'a>, u16>,
}

impl<'a> Default for Board<'a> {
    fn default() -> Self {
        Board {
            name: "nand2tetris-simulator",
            ram_words: 32768,
            rom_words: 32768,
            symbols: HashMap::from([
                (symbol::Symbol("SCREEN"), 16384),
                (symbol::Symbol("KBD"), 24576),
            ]),
        }
    }
}

pub(super) fn load(config_str: &str) -> Result<Board<'_>> {
    toml::from_str(config_str).context("parsing board file")
}

#[test]
fn test_real_config_path() {
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

    let board = load(test_string);
    assert!(board.is_ok());

    let board = board.unwrap();
    assert_eq!(board.name, "go-board");
    assert_eq!(board.rom_words, 3072);
    assert_eq!(board.ram_words, 1024);
    assert_eq!(
        board.symbols,
        HashMap::from([
            (symbol::Symbol("LED"), 0x03FA),
            (symbol::Symbol("SEG"), 0x03FB),
            (symbol::Symbol("BTN"), 0x03FC),
            (symbol::Symbol("UART_TX"), 0x03FD),
            (symbol::Symbol("UART_RX"), 0x03FE),
            (symbol::Symbol("UART_ST"), 0x03FF),
        ])
    );
}
