//===-- CogentInstrFormats.td - RISCV Instruction Formats ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//
//===----------------------------------------------------------------------===//

// Format specifies the encoding used by the instruction. This is used by
// RISCVMCCodeEmitter to determine which form of fixup to use. These
// definitions must be kept in-sync with RISCVBaseInfo.h.
class InstFormat<bits<5> val> {
  bits<5> Value = val;
}
def InstFormatPseudo : InstFormat<0>;
def InstFormatR      : InstFormat<1>;
def InstFormatI      : InstFormat<3>;
def InstFormatS      : InstFormat<4>;
def InstFormatB      : InstFormat<5>;
def InstFormatU      : InstFormat<6>;
def InstFormatJ      : InstFormat<7>;

// The following opcode names match those given in Table 19.1 in the
// RISC-V User-level ISA specification ("RISC-V base opcode map").
class RISCVOpcode<string name, bits<7> val> {
  string Name = name;
  bits<7> Value = val;
}
def OPC_LOAD      : RISCVOpcode<"LOAD",      0b0000011>;
def OPC_MISC_MEM  : RISCVOpcode<"MISC_MEM",  0b0001111>;
def OPC_OP_IMM    : RISCVOpcode<"OP_IMM",    0b0010011>;
def OPC_AUIPC     : RISCVOpcode<"AUIPC",     0b0010111>;
def OPC_OP_IMM_32 : RISCVOpcode<"OP_IMM_32", 0b0011011>;
def OPC_STORE     : RISCVOpcode<"STORE",     0b0100011>;
def OPC_AMO       : RISCVOpcode<"AMO",       0b0101111>;
def OPC_OP        : RISCVOpcode<"OP",        0b0110011>;
def OPC_LUI       : RISCVOpcode<"LUI",       0b0110111>;
def OPC_OP_32     : RISCVOpcode<"OP_32",     0b0111011>;
def OPC_MADD      : RISCVOpcode<"MADD",      0b1000011>;
def OPC_MSUB      : RISCVOpcode<"MSUB",      0b1000111>;
def OPC_NMSUB     : RISCVOpcode<"NMSUB",     0b1001011>;
def OPC_NMADD     : RISCVOpcode<"NMADD",     0b1001111>;
def OPC_BRANCH    : RISCVOpcode<"BRANCH",    0b1100011>;
def OPC_JALR      : RISCVOpcode<"JALR",      0b1100111>;
def OPC_JAL       : RISCVOpcode<"JAL",       0b1101111>;
def OPC_SYSTEM    : RISCVOpcode<"SYSTEM",    0b1110011>;

class CogentInst<dag outs, dag ins, string opcodestr, string argstr,
             list<dag> pattern, InstFormat format>
    : Instruction {
  field bits<32> Inst;
  let Size = 4;

  bits<7> Opcode = 0;

  let Inst{6-0} = Opcode;

  let Namespace = "Cogent";

  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = opcodestr # "\t" # argstr;
  let Pattern = pattern;
}


// Instruction formats are listed in the order they appear in the RISC-V
// instruction set manual (R, I, S, B, U, J)
class CogentInstR<bits<7> funct7, bits<3> funct3, RISCVOpcode opcode, dag outs,
              dag ins, string opcodestr, string argstr>
    : CogentInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> rd;

  let Inst{31-25} = funct7;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = rd;
  let Opcode = opcode.Value;
}

class CogentInstI<bits<3> funct3, RISCVOpcode opcode, dag outs, dag ins,
              string opcodestr, string argstr>
    : CogentInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<12> imm12;
  bits<5> rs1;
  bits<5> rd;

  let Inst{31-20} = imm12;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = rd;
  let Opcode = opcode.Value;
}


class CogentInstS<bits<3> funct3, RISCVOpcode opcode, dag outs, dag ins,
              string opcodestr, string argstr>
    : CogentInst<outs, ins, opcodestr, argstr, [], InstFormatS> {
  bits<12> imm12;
  bits<5> rs2;
  bits<5> rs1;

  let Inst{31-25} = imm12{11-5};
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = imm12{4-0};
  let Opcode = opcode.Value;
}

class CogentInstB<bits<3> funct3, RISCVOpcode opcode, dag outs, dag ins,
              string opcodestr, string argstr>
    : CogentInst<outs, ins, opcodestr, argstr, [], InstFormatB> {
  bits<12> imm12;
  bits<5> rs2;
  bits<5> rs1;

  let Inst{31} = imm12{11};
  let Inst{30-25} = imm12{9-4};
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-8} = imm12{3-0};
  let Inst{7} = imm12{10};
  let Opcode = opcode.Value;
}

class CogentInstU<RISCVOpcode opcode, dag outs, dag ins, string opcodestr,
              string argstr>
    : CogentInst<outs, ins, opcodestr, argstr, [], InstFormatU> {
  bits<20> imm20;
  bits<5> rd;

  let Inst{31-12} = imm20;
  let Inst{11-7} = rd;
  let Opcode = opcode.Value;
}

class CogentInstJ<RISCVOpcode opcode, dag outs, dag ins, string opcodestr,
              string argstr>
    : CogentInst<outs, ins, opcodestr, argstr, [], InstFormatJ> {
  bits<20> imm20;
  bits<5> rd;

  let Inst{31} = imm20{19};
  let Inst{30-21} = imm20{9-0};
  let Inst{20} = imm20{10};
  let Inst{19-12} = imm20{18-11};
  let Inst{11-7} = rd;
  let Opcode = opcode.Value;
}

//===----------------------------------------------------------------------===//
// Instruction classes for .insn directives
//===----------------------------------------------------------------------===//

class DirectiveInsnR<dag outs, dag ins, string argstr>
  : CogentInst<outs, ins, "", "", [], InstFormatR> {
  bits<7> opcode;
  bits<7> funct7;
  bits<3> funct3;

  bits<5> rs2;
  bits<5> rs1;
  bits<5> rd;

  let Inst{31-25} = funct7;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = rd;
  let Opcode = opcode;

  let AsmString = ".insn r " # argstr;
}


class DirectiveInsnI<dag outs, dag ins, string argstr>
  : CogentInst<outs, ins, "", "", [], InstFormatI> {
  bits<7> opcode;
  bits<3> funct3;

  bits<12> imm12;
  bits<5> rs1;
  bits<5> rd;

  let Inst{31-20} = imm12;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = rd;
  let Opcode = opcode;

  let AsmString = ".insn i " # argstr;
}

class DirectiveInsnS<dag outs, dag ins, string argstr>
  : CogentInst<outs, ins, "", "", [], InstFormatS> {
  bits<7> opcode;
  bits<3> funct3;

  bits<12> imm12;
  bits<5> rs2;
  bits<5> rs1;

  let Inst{31-25} = imm12{11-5};
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = imm12{4-0};
  let Opcode = opcode;

  let AsmString = ".insn s " # argstr;
}

class DirectiveInsnB<dag outs, dag ins, string argstr>
  : CogentInst<outs, ins, "", "", [], InstFormatB> {
  bits<7> opcode;
  bits<3> funct3;

  bits<12> imm12;
  bits<5> rs2;
  bits<5> rs1;

  let Inst{31} = imm12{11};
  let Inst{30-25} = imm12{9-4};
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-8} = imm12{3-0};
  let Inst{7} = imm12{10};
  let Opcode = opcode;

  let AsmString = ".insn b " # argstr;
}

class DirectiveInsnU<dag outs, dag ins, string argstr>
  : CogentInst<outs, ins, "", "", [], InstFormatU> {
  bits<7> opcode;

  bits<20> imm20;
  bits<5> rd;

  let Inst{31-12} = imm20;
  let Inst{11-7} = rd;
  let Opcode = opcode;

  let AsmString = ".insn u " # argstr;
}

class DirectiveInsnJ<dag outs, dag ins, string argstr>
  : CogentInst<outs, ins, "", "", [], InstFormatJ> {
  bits<7> opcode;

  bits<20> imm20;
  bits<5> rd;

  let Inst{31-12} = imm20;
  let Inst{11-7} = rd;
  let Opcode = opcode;

  let AsmString = ".insn j " # argstr;
}
