use anyhow::{Context, Result};

use crate::assembler::code;

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub(super) struct Symbol<'a>(pub &'a str);

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

pub(super) fn parse_symbol(symbol: &str) -> Result<Symbol<'_>> {
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

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(super) enum Instruction<'a> {
    A {
        value: Value<'a>,
    },
    C {
        dest: code::Dest,
        comp: code::Comp,
        jump: code::Jump,
    },
    L {
        label: Symbol<'a>,
    },
}

pub(super) fn parse(asm_code: &str) -> Result<Vec<Instruction<'_>>> {
    let mut instructions: Vec<Instruction<'_>> = Vec::new();
    let mut address: u16 = 0;
    let max_address = code::MAX_ADDRESS;

    for (mut line_no, line) in asm_code.lines().enumerate() {
        line_no += 1;

        // Throw error if we ran out of addressable ROM
        if address > max_address {
            anyhow::bail!(
                "ROM size max address is {max_address} but we exceed this by line {line_no}"
            )
        }

        // Ignore comment lines
        let inst = match line.split_once("//") {
            Some((inst, _)) => inst.trim(),
            None => line.trim(),
        };

        match inst.as_bytes() {
            [] => {}
            [b'(', .., b')'] => {
                instructions.push(parse_l_inst(inst).with_context(|| format!("line {line_no}"))?);
            }
            [b'@', ..] => {
                instructions.push(parse_a_inst(inst).with_context(|| format!("line {line_no}"))?);
                address += 1;
            }
            _ => {
                instructions.push(parse_c_inst(inst).with_context(|| format!("line {line_no}"))?);
                address += 1;
            }
        }
    }

    Ok(instructions)
}

fn parse_l_inst(inst: &str) -> Result<Instruction<'_>> {
    let symbol = inst
        .trim()
        .strip_prefix('(')
        .with_context(|| format!("not an L instruction: missing leading '(': {inst}"))?
        .strip_suffix(')')
        .with_context(|| format!("not an L instruction: missing trailing ')': {inst}"))?
        .trim();

    parse_symbol(symbol)
        .map(|symbol| Instruction::L { label: symbol })
        .with_context(|| format!("bad L instruction provided {inst}"))
}

fn parse_a_inst(inst: &str) -> Result<Instruction<'_>> {
    let symbol = inst
        .trim()
        .strip_prefix('@')
        .with_context(|| format!("not an A instruction: missing leading '@': {inst}"))?
        .trim();

    parse_value(symbol)
        .map(|value| Instruction::A { value })
        .with_context(|| format!("bad A instruction provided {inst}"))
}

fn parse_c_inst(inst: &str) -> Result<Instruction<'_>> {
    let (rest_str, jump_str) = match inst.trim().split_once(";") {
        Some((_, j)) if j.trim().is_empty() => {
            anyhow::bail!("missing jump in C instruction: {inst}")
        }
        Some((r, j)) => (r, j),
        None => (inst, ""),
    };

    let (dest_str, comp_str) = match rest_str.trim().split_once("=") {
        Some((d, _)) if d.trim().is_empty() => {
            anyhow::bail!("missing dest in C instruction: {inst}")
        }
        Some((_, c)) if c.trim().is_empty() => {
            anyhow::bail!("missing comp in C instruction: {inst}")
        }
        Some((d, c)) => (d, c),
        None => ("", rest_str),
    };

    let dest = code::dest(dest_str.trim()).with_context(|| format!("bad C instruction: {inst}"))?;
    let comp = code::comp(comp_str.trim()).with_context(|| format!("bad C instruction: {inst}"))?;
    let jump = code::jump(jump_str.trim()).with_context(|| format!("bad C instruction: {inst}"))?;

    Ok(Instruction::C { dest, comp, jump })
}

#[test]
fn test_good_l_instructions() {
    let test_instructions = [
        (
            "(LOOP)",
            Instruction::L {
                label: (Symbol("LOOP")),
            },
        ),
        (
            "(LOOP) ",
            Instruction::L {
                label: (Symbol("LOOP")),
            },
        ),
        (
            " (LOOP)",
            Instruction::L {
                label: (Symbol("LOOP")),
            },
        ),
        (
            "( LOOP)",
            Instruction::L {
                label: (Symbol("LOOP")),
            },
        ),
        (
            "(LOOP )",
            Instruction::L {
                label: (Symbol("LOOP")),
            },
        ),
        (
            " ( LOOP ) ",
            Instruction::L {
                label: (Symbol("LOOP")),
            },
        ),
        (
            "(_LOOP_LOOP_)",
            Instruction::L {
                label: (Symbol("_LOOP_LOOP_")),
            },
        ),
        (
            "(.LOOP.LOOP.)",
            Instruction::L {
                label: (Symbol(".LOOP.LOOP.")),
            },
        ),
        (
            "($LOOP$LOOP$)",
            Instruction::L {
                label: (Symbol("$LOOP$LOOP$")),
            },
        ),
        (
            "(:LOOP:LOOP:)",
            Instruction::L {
                label: (Symbol(":LOOP:LOOP:")),
            },
        ),
        (
            "(LOOP1LOOP2)",
            Instruction::L {
                label: (Symbol("LOOP1LOOP2")),
            },
        ),
        (
            "(loop)",
            Instruction::L {
                label: (Symbol("loop")),
            },
        ),
    ];

    for &(instruction, want) in test_instructions.iter() {
        assert_eq!(
            parse_l_inst(instruction).unwrap(),
            want,
            "{instruction:?} != {want:?}"
        );
    }
}

#[test]
fn test_bad_l_instructions() {
    let test_instructions = ["(L O O P)", "(1LOOP)", "(+LOOP)", "LOOP)", "(LOOP"];

    for &instruction in test_instructions.iter() {
        assert!(parse_l_inst(instruction).is_err());
    }
}

#[test]
fn test_good_a_instructions() {
    let test_instructions = [
        (
            "@LOOP",
            Instruction::A {
                value: Value::Symbol(Symbol("LOOP")),
            },
        ),
        (
            "@LOOP ",
            Instruction::A {
                value: Value::Symbol(Symbol("LOOP")),
            },
        ),
        (
            " @LOOP",
            Instruction::A {
                value: Value::Symbol(Symbol("LOOP")),
            },
        ),
        (
            "@ LOOP",
            Instruction::A {
                value: Value::Symbol(Symbol("LOOP")),
            },
        ),
        (
            " @ LOOP",
            Instruction::A {
                value: Value::Symbol(Symbol("LOOP")),
            },
        ),
        (
            "@_LOOP_LOOP_",
            Instruction::A {
                value: Value::Symbol(Symbol("_LOOP_LOOP_")),
            },
        ),
        (
            "@.LOOP.LOOP.",
            Instruction::A {
                value: Value::Symbol(Symbol(".LOOP.LOOP.")),
            },
        ),
        (
            "@$LOOP$LOOP$",
            Instruction::A {
                value: Value::Symbol(Symbol("$LOOP$LOOP$")),
            },
        ),
        (
            "@:LOOP:LOOP:",
            Instruction::A {
                value: Value::Symbol(Symbol(":LOOP:LOOP:")),
            },
        ),
        (
            "@LOOP1LOOP2",
            Instruction::A {
                value: Value::Symbol(Symbol("LOOP1LOOP2")),
            },
        ),
        (
            "@loop",
            Instruction::A {
                value: Value::Symbol(Symbol("loop")),
            },
        ),
        (
            "@100",
            Instruction::A {
                value: Value::Constant(100),
            },
        ),
        (
            "@100",
            Instruction::A {
                value: Value::Constant(100),
            },
        ),
    ];

    for &(instruction, want) in test_instructions.iter() {
        assert_eq!(
            parse_a_inst(instruction).unwrap(),
            want,
            "{instruction:?} != {want:?}"
        );
    }
}

#[test]
fn test_bad_a_instructions() {
    let test_instructions = ["@L O O P)", "@1LOOP)", "@+LOOP)", "LOOP"];

    for &instruction in test_instructions.iter() {
        assert!(parse_a_inst(instruction).is_err());
    }
}

#[test]
fn test_good_c_instructions() {
    let test_instructions = [
        (
            "1",
            Instruction::C {
                dest: code::Dest::Null,
                comp: code::Comp::PosOne,
                jump: code::Jump::Null,
            },
        ),
        (
            "-1",
            Instruction::C {
                dest: code::Dest::Null,
                comp: code::Comp::NegOne,
                jump: code::Jump::Null,
            },
        ),
        (
            "D",
            Instruction::C {
                dest: code::Dest::Null,
                comp: code::Comp::D,
                jump: code::Jump::Null,
            },
        ),
        (
            "D+1",
            Instruction::C {
                dest: code::Dest::Null,
                comp: code::Comp::DPlus1,
                jump: code::Jump::Null,
            },
        ),
        (
            "D&A",
            Instruction::C {
                dest: code::Dest::Null,
                comp: code::Comp::DAndA,
                jump: code::Jump::Null,
            },
        ),
        (
            "A=1",
            Instruction::C {
                dest: code::Dest::A,
                comp: code::Comp::PosOne,
                jump: code::Jump::Null,
            },
        ),
        (
            "M=-1",
            Instruction::C {
                dest: code::Dest::M,
                comp: code::Comp::NegOne,
                jump: code::Jump::Null,
            },
        ),
        (
            "AM=D",
            Instruction::C {
                dest: code::Dest::AM,
                comp: code::Comp::D,
                jump: code::Jump::Null,
            },
        ),
        (
            "AD=D+1",
            Instruction::C {
                dest: code::Dest::AD,
                comp: code::Comp::DPlus1,
                jump: code::Jump::Null,
            },
        ),
        (
            "ADM=D&A",
            Instruction::C {
                dest: code::Dest::ADM,
                comp: code::Comp::DAndA,
                jump: code::Jump::Null,
            },
        ),
        (
            "A=1;JGT",
            Instruction::C {
                dest: code::Dest::A,
                comp: code::Comp::PosOne,
                jump: code::Jump::JGT,
            },
        ),
        (
            "M=-1;JEQ",
            Instruction::C {
                dest: code::Dest::M,
                comp: code::Comp::NegOne,
                jump: code::Jump::JEQ,
            },
        ),
        (
            "AM=D;JGE",
            Instruction::C {
                dest: code::Dest::AM,
                comp: code::Comp::D,
                jump: code::Jump::JGE,
            },
        ),
        (
            "AD=D+1;JLT",
            Instruction::C {
                dest: code::Dest::AD,
                comp: code::Comp::DPlus1,
                jump: code::Jump::JLT,
            },
        ),
        (
            "ADM=D&A;JMP",
            Instruction::C {
                dest: code::Dest::ADM,
                comp: code::Comp::DAndA,
                jump: code::Jump::JMP,
            },
        ),
        (
            "1;JGT",
            Instruction::C {
                dest: code::Dest::Null,
                comp: code::Comp::PosOne,
                jump: code::Jump::JGT,
            },
        ),
        (
            "-1;JEQ",
            Instruction::C {
                dest: code::Dest::Null,
                comp: code::Comp::NegOne,
                jump: code::Jump::JEQ,
            },
        ),
        (
            "D;JGE",
            Instruction::C {
                dest: code::Dest::Null,
                comp: code::Comp::D,
                jump: code::Jump::JGE,
            },
        ),
        (
            "D+1;JLT",
            Instruction::C {
                dest: code::Dest::Null,
                comp: code::Comp::DPlus1,
                jump: code::Jump::JLT,
            },
        ),
        (
            "D&A;JMP",
            Instruction::C {
                dest: code::Dest::Null,
                comp: code::Comp::DAndA,
                jump: code::Jump::JMP,
            },
        ),
    ];

    for &(instruction, want) in test_instructions.iter() {
        assert_eq!(
            parse_c_inst(instruction).unwrap(),
            want,
            "{instruction:?} != {want:?}"
        );
    }
}

#[test]
fn test_bad_c_instructions() {
    let test_instructions = [
        "0=",
        "=M",
        "0;",
        "=M;",
        ";JMP",
        "JMP",
        "JMP=M;JMP",
        "0=M;0",
        "D=JMP",
    ];

    for &instruction in test_instructions.iter() {
        assert!(parse_c_inst(instruction).is_err());
    }
}
