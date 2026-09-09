use std::collections::HashMap;

use anyhow::{Context, Result};
use serde::Deserialize;

use crate::assembler::symbol;

#[derive(Deserialize, Eq, PartialEq, Debug)]
#[serde(rename_all = "kebab-case", deny_unknown_fields)]
pub struct Board<'a> {
    pub name: &'a str,
    pub rom_words: u16,
    pub ram_words: u16,
    #[serde(default, borrow)]
    pub symbols: HashMap<symbol::Symbol<'a>, u16>,
}

impl<'a> Board<'a> {
    pub fn parse_config(config_str: &'a str) -> Result<Board<'a>> {
        toml::from_str(config_str).context("parsing board file")
    }
}

impl<'a> Default for Board<'a> {
    fn default() -> Self {
        Board {
            name: "nand2tetris-simulator",
            rom_words: 0x8000,
            ram_words: 0x4000,
            symbols: HashMap::from([
                (symbol::Symbol("SCREEN"), 0x4000),
                (symbol::Symbol("KBD"), 0x6000),
            ]),
        }
    }
}

#[cfg(test)]
mod tests {
    use std::collections::HashMap;

    use crate::assembler::symbol;
    use crate::board::Board;

    #[test]
    fn test_default_board() {
        let board = Board::default();
        assert_eq!(board.name, "nand2tetris-simulator");
        assert_eq!(board.rom_words, 0x8000);
        assert_eq!(board.ram_words, 0x4000);
        assert_eq!(
            board.symbols,
            HashMap::from([
                (symbol::Symbol("SCREEN"), 0x4000),
                (symbol::Symbol("KBD"), 0x6000),
            ])
        );
    }

    #[test]
    fn test_parse_config() {
        let test_string = r#"
        name      = "go-board"
        rom-words = 0xC00    # 12 EBRs
        ram-words = 0x400    # 4 EBRS

        [symbols]
        LED_ADDR = 0x400
        SEG_ADDR = 0x401
        BTN_ADDR = 0x402
        UART_TX_ADDR = 0x403
        UART_RX_ADDR = 0x404
        UART_ST_ADDR = 0x405
    "#;

        let board = Board::parse_config(test_string);
        assert!(board.is_ok());

        let board = board.unwrap();
        assert_eq!(board.name, "go-board");
        assert_eq!(board.rom_words, 0xC00);
        assert_eq!(board.ram_words, 0x400);
        assert_eq!(
            board.symbols,
            HashMap::from([
                (symbol::Symbol("LED_ADDR"), 0x400),
                (symbol::Symbol("SEG_ADDR"), 0x401),
                (symbol::Symbol("BTN_ADDR"), 0x402),
                (symbol::Symbol("UART_TX_ADDR"), 0x403),
                (symbol::Symbol("UART_RX_ADDR"), 0x404),
                (symbol::Symbol("UART_ST_ADDR"), 0x405),
            ])
        );
    }
}
