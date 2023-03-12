//===-- Cogent.td - RISC-V target definitions --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This is a target description file for RISSC-V
///
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Cogent RISC-V Subtarget features
//===----------------------------------------------------------------------===//
//===----------------------------------------------------------------------===//
// Cogent RISC-V processors supported.
//===----------------------------------------------------------------------===//

include "CogentSchedule.td"

// defines -mcpu= option apart from defining other things
def : ProcessorModel<"cogent", CogentSchedModel, []>;

//===----------------------------------------------------------------------===//
// Register File Description
//===----------------------------------------------------------------------===//

include "CogentRegisterInfo.td"

//===----------------------------------------------------------------------===//
// Instruction Descriptions
//===----------------------------------------------------------------------===//

include "CogentInstrInfo.td"

def CogentInstrInfo : InstrInfo;

//===----------------------------------------------------------------------===//
// Calling Conventions
//===----------------------------------------------------------------------===//

include "CogentCallingConv.td"

//===---------------------------------------------------------------------===//
// Assembly Printers
//===---------------------------------------------------------------------===//

def CogentAsmWriter : AsmWriter {
 string AsmWriterClassName = "InstPrinter";
 bit isMCAsmWriter = 1;
}

//===---------------------------------------------------------------------===//
// Assembly Parsers
//===---------------------------------------------------------------------===//

def CogentAsmParser : AsmParser;

def CogentAsmParserVariant : AsmParserVariant {
  let RegisterPrefix = "%";
}

//===----------------------------------------------------------------------===//
// Target
//===----------------------------------------------------------------------===//

def Cogent : Target {
  let InstructionSet = CogentInstrInfo;
  let AssemblyParsers = [CogentAsmParser];
  let AssemblyWriters = [CogentAsmWriter];
  let AssemblyParserVariants = [CogentAsmParserVariant];
  let AllowRegisterRenaming = 1;
}
