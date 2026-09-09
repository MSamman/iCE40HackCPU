use std::fmt;

use anyhow::Result;
use serde::Deserialize;

use crate::assembler::code;

#[derive(Debug, PartialEq, Eq, Clone, Copy, Hash, Deserialize)]
#[serde(try_from = "&'a str")]
pub struct Symbol<'a>(pub &'a str);

impl<'a> TryFrom<&'a str> for Symbol<'a> {
    type Error = anyhow::Error;

    fn try_from(symbol: &'a str) -> Result<Self> {
        let is_symbol_char =
            |c: char| c.is_ascii_alphanumeric() || matches!(c, '_' | '.' | '$' | ':');

        match symbol.chars().next() {
            None => anyhow::bail!("empty symbol: {symbol}"),
            Some(c) if c.is_ascii_digit() => {
                anyhow::bail!("symbol can't start with a digit: {symbol}")
            }
            Some(c) if symbol.chars().all(is_symbol_char) => Ok(Symbol(symbol)),
            Some(_) => anyhow::bail!("bad symbol provided: {symbol}"),
        }
    }
}

impl fmt::Display for Symbol<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.0)
    }
}

pub(crate) fn parse_symbol(symbol: &str) -> Result<Symbol<'_>> {
    symbol.try_into()
}

#[test]
fn test_good_symbol_parse() {
    let want_symbols = [
        ("LOOP", Symbol("LOOP")),
        ("LOOP1", Symbol("LOOP1")),
        ("_LO.OP$", Symbol("_LO.OP$")),
    ];

    for (s, want) in want_symbols {
        assert_eq!(parse_symbol(s).unwrap(), want);
    }
}

#[test]
fn test_bad_symbol_parse() {
    let test_symbols = ["1LOOP", "*LOOP", "LOO?P", "100", "32768", "-1"];

    for s in test_symbols {
        assert!(parse_symbol(s).is_err());
    }
}

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub(super) enum Value<'a> {
    Symbol(Symbol<'a>),
    Constant(u16),
}

impl<'a> TryFrom<&'a str> for Value<'a> {
    type Error = anyhow::Error;

    fn try_from(s: &'a str) -> Result<Self> {
        let max_address = code::MAX_ADDRESS;
        match s.parse::<u16>() {
            Ok(value) if value > max_address => {
                anyhow::bail!("{value} exceeds maximum value {max_address}")
            }
            Ok(value) => Ok(Value::Constant(value)),
            Err(_) => parse_symbol(s).map(Value::Symbol),
        }
    }
}

pub(super) fn parse_value(symbol: &str) -> Result<Value<'_>> {
    symbol.try_into()
}

#[test]
fn test_good_value_parse() {
    let want_values = [
        ("LOOP", Value::Symbol(Symbol("LOOP"))),
        ("LOOP1", Value::Symbol(Symbol("LOOP1"))),
        ("_LOOP", Value::Symbol(Symbol("_LOOP"))),
        ("1", Value::Constant(1)),
        ("32767", Value::Constant(32767)),
    ];

    for (v, want) in want_values {
        assert_eq!(parse_value(v).unwrap(), want);
    }
}

#[test]
fn test_bad_value_parse() {
    let test_values = ["1LOOP", "*LOOP", "LOO?P", "32768", "-1"];

    for v in test_values {
        assert!(parse_value(v).is_err());
    }
}
