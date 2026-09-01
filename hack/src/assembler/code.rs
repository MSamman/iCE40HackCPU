use anyhow::Result;
use std::str::FromStr;

pub(super) const MAX_ADDRESS: u16 = 0x7FFF;

#[allow(clippy::upper_case_acronyms)]
#[derive(Debug, PartialEq, Eq, Clone, Copy)]
#[repr(u8)]
pub(super) enum Dest {
    Null = 0b000,
    M = 0b001,
    D = 0b010,
    DM = 0b011,
    A = 0b100,
    AM = 0b101,
    AD = 0b110,
    ADM = 0b111,
}

impl FromStr for Dest {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(match s {
            "" | "null" => Dest::Null,
            "M" => Dest::M,
            "D" => Dest::D,
            "DM" | "MD" => Dest::DM,
            "A" => Dest::A,
            "AM" | "MA" => Dest::AM,
            "AD" | "DA" => Dest::AD,
            "ADM" | "AMD" | "DMA" | "DAM" | "MAD" | "MDA" => Dest::ADM,
            other => anyhow::bail!("{other} is not a valid dest"),
        })
    }
}

pub(super) fn dest(symbol: &str) -> Result<Dest> {
    symbol.parse()
}

#[test]
fn test_parse_dest() {
    let dest_tests: [(&str, Dest); 17] = [
        ("", Dest::Null),
        ("null", Dest::Null),
        ("M", Dest::M),
        ("D", Dest::D),
        ("DM", Dest::DM),
        ("MD", Dest::DM),
        ("A", Dest::A),
        ("AM", Dest::AM),
        ("MA", Dest::AM),
        ("AD", Dest::AD),
        ("DA", Dest::AD),
        ("ADM", Dest::ADM),
        ("AMD", Dest::ADM),
        ("DMA", Dest::ADM),
        ("DAM", Dest::ADM),
        ("MAD", Dest::ADM),
        ("MDA", Dest::ADM),
    ];

    for &(symbol, want) in dest_tests.iter() {
        assert_eq!(dest(symbol).unwrap(), want, "{symbol}");
    }

    assert!(dest("bad").is_err());
}

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
#[repr(u8)]
pub(super) enum Comp {
    Zero = 0b0_101010,
    PosOne = 0b0_111111,
    NegOne = 0b0_111010,
    D = 0b0_001100,
    A = 0b0_110000,
    M = 0b1_110000,
    NotD = 0b0_001101,
    NotA = 0b0_110001,
    NotM = 0b1_110001,
    NegD = 0b0_001111,
    NegA = 0b0_110011,
    NegM = 0b1_110011,
    DPlus1 = 0b0_011111,
    APlus1 = 0b0_110111,
    MPlus1 = 0b1_110111,
    DMin1 = 0b0_001110,
    AMin1 = 0b0_110010,
    MMin1 = 0b1_110010,
    DPlusA = 0b0_000010,
    DPlusM = 0b1_000010,
    DMinA = 0b0_010011,
    DMinM = 0b1_010011,
    AMinD = 0b0_000111,
    MMinD = 0b1_000111,
    DAndA = 0b0_000000,
    DAndM = 0b1_000000,
    DOrA = 0b0_010101,
    DOrM = 0b1_010101,
}

impl FromStr for Comp {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(match s {
            "0" => Comp::Zero,
            "1" => Comp::PosOne,
            "-1" => Comp::NegOne,
            "D" => Comp::D,
            "A" => Comp::A,
            "M" => Comp::M,
            "!D" => Comp::NotD,
            "!A" => Comp::NotA,
            "!M" => Comp::NotM,
            "-D" => Comp::NegD,
            "-A" => Comp::NegA,
            "-M" => Comp::NegM,
            "D+1" => Comp::DPlus1,
            "A+1" => Comp::APlus1,
            "M+1" => Comp::MPlus1,
            "D-1" => Comp::DMin1,
            "A-1" => Comp::AMin1,
            "M-1" => Comp::MMin1,
            "D+A" => Comp::DPlusA,
            "D+M" => Comp::DPlusM,
            "D-A" => Comp::DMinA,
            "D-M" => Comp::DMinM,
            "A-D" => Comp::AMinD,
            "M-D" => Comp::MMinD,
            "D&A" => Comp::DAndA,
            "D&M" => Comp::DAndM,
            "D|A" => Comp::DOrA,
            "D|M" => Comp::DOrM,
            other => anyhow::bail!("{other} is not a valid comp"),
        })
    }
}

pub(super) fn comp(symbol: &str) -> Result<Comp> {
    symbol.parse()
}

#[test]
fn test_parse_comp() {
    let comp_tests: [(&str, Comp); 28] = [
        ("0", Comp::Zero),
        ("1", Comp::PosOne),
        ("-1", Comp::NegOne),
        ("D", Comp::D),
        ("A", Comp::A),
        ("M", Comp::M),
        ("!D", Comp::NotD),
        ("!A", Comp::NotA),
        ("!M", Comp::NotM),
        ("-D", Comp::NegD),
        ("-A", Comp::NegA),
        ("-M", Comp::NegM),
        ("D+1", Comp::DPlus1),
        ("A+1", Comp::APlus1),
        ("M+1", Comp::MPlus1),
        ("D-1", Comp::DMin1),
        ("A-1", Comp::AMin1),
        ("M-1", Comp::MMin1),
        ("D+A", Comp::DPlusA),
        ("D+M", Comp::DPlusM),
        ("D-A", Comp::DMinA),
        ("D-M", Comp::DMinM),
        ("A-D", Comp::AMinD),
        ("M-D", Comp::MMinD),
        ("D&A", Comp::DAndA),
        ("D&M", Comp::DAndM),
        ("D|A", Comp::DOrA),
        ("D|M", Comp::DOrM),
    ];

    for &(symbol, want) in comp_tests.iter() {
        assert_eq!(comp(symbol).unwrap(), want, "{symbol}");
    }

    assert!(comp("bad").is_err());
}

#[allow(clippy::upper_case_acronyms)]
#[derive(Debug, PartialEq, Eq, Clone, Copy)]
#[repr(u8)]
pub(super) enum Jump {
    Null = 0b000,
    JGT = 0b001,
    JEQ = 0b010,
    JGE = 0b011,
    JLT = 0b100,
    JNE = 0b101,
    JLE = 0b110,
    JMP = 0b111,
}

impl FromStr for Jump {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(match s {
            "" | "null" => Jump::Null,
            "JGT" => Jump::JGT,
            "JEQ" => Jump::JEQ,
            "JGE" => Jump::JGE,
            "JLT" => Jump::JLT,
            "JNE" => Jump::JNE,
            "JLE" => Jump::JLE,
            "JMP" => Jump::JMP,
            other => anyhow::bail!("{other} is not a valid jump"),
        })
    }
}

pub(super) fn jump(symbol: &str) -> Result<Jump> {
    symbol.parse()
}

#[test]
fn test_parse_jump() {
    let jump_tests: [(&str, Jump); 9] = [
        ("", Jump::Null),
        ("null", Jump::Null),
        ("JGT", Jump::JGT),
        ("JEQ", Jump::JEQ),
        ("JGE", Jump::JGE),
        ("JLT", Jump::JLT),
        ("JNE", Jump::JNE),
        ("JLE", Jump::JLE),
        ("JMP", Jump::JMP),
    ];

    for &(symbol, want) in jump_tests.iter() {
        assert_eq!(jump(symbol).unwrap(), want, "{symbol}");
    }

    assert!(jump("bad").is_err());
}

pub(super) fn encode_c(dest: Dest, comp: Comp, jump: Jump) -> u16 {
    (0b111 << 13) | ((comp as u16) << 6) | ((dest as u16) << 3) | (jump as u16)
}

#[test]
#[allow(clippy::unusual_byte_groupings)]
fn test_encode_c() {
    let test_c_instructions = [
        (Comp::Zero, Dest::M, Jump::JGT, 0b111_0_101010_001_001_u16),
        (Comp::PosOne, Dest::D, Jump::JEQ, 0b111_0_111111_010_010),
        (Comp::NegOne, Dest::DM, Jump::JGE, 0b111_0_111010_011_011),
        (Comp::D, Dest::A, Jump::JLT, 0b111_0_001100_100_100),
        (Comp::A, Dest::AM, Jump::JNE, 0b111_0_110000_101_101),
        (Comp::M, Dest::AD, Jump::JLE, 0b111_1_110000_110_110),
        (Comp::NotD, Dest::ADM, Jump::JMP, 0b111_0_001101_111_111),
        (Comp::NotA, Dest::Null, Jump::Null, 0b111_0_110001_000_000),
        (Comp::NotM, Dest::Null, Jump::Null, 0b111_1_110001_000_000),
        (Comp::NegD, Dest::Null, Jump::Null, 0b111_0_001111_000_000),
        (Comp::NegA, Dest::Null, Jump::Null, 0b111_0_110011_000_000),
        (Comp::NegM, Dest::Null, Jump::Null, 0b111_1_110011_000_000),
        (Comp::DPlus1, Dest::Null, Jump::Null, 0b111_0_011111_000_000),
        (Comp::APlus1, Dest::Null, Jump::Null, 0b111_0_110111_000_000),
        (Comp::MPlus1, Dest::Null, Jump::Null, 0b111_1_110111_000_000),
        (Comp::DMin1, Dest::Null, Jump::Null, 0b111_0_001110_000_000),
        (Comp::AMin1, Dest::Null, Jump::Null, 0b111_0_110010_000_000),
        (Comp::MMin1, Dest::Null, Jump::Null, 0b111_1_110010_000_000),
        (Comp::DPlusA, Dest::Null, Jump::Null, 0b111_0_000010_000_000),
        (Comp::DPlusM, Dest::Null, Jump::Null, 0b111_1_000010_000_000),
        (Comp::DMinA, Dest::Null, Jump::Null, 0b111_0_010011_000_000),
        (Comp::DMinM, Dest::Null, Jump::Null, 0b111_1_010011_000_000),
        (Comp::AMinD, Dest::Null, Jump::Null, 0b111_0_000111_000_000),
        (Comp::MMinD, Dest::Null, Jump::Null, 0b111_1_000111_000_000),
        (Comp::DAndA, Dest::Null, Jump::Null, 0b111_0_000000_000_000),
        (Comp::DAndM, Dest::Null, Jump::Null, 0b111_1_000000_000_000),
        (Comp::DOrA, Dest::Null, Jump::Null, 0b111_0_010101_000_000),
        (Comp::DOrM, Dest::Null, Jump::Null, 0b111_1_010101_000_000),
    ];

    for &(comp, dest, jump, want) in test_c_instructions.iter() {
        let got = encode_c(dest, comp, jump);
        assert_eq!(
            got, want,
            "{dest:?} {comp:?} {jump:?} -> got:{got:016b} != want:{want:016b}"
        );
    }
}
