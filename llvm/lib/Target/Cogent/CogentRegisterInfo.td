//===-- CogentRegisterInfo.td - RISC-V Register defs --------- tablegen -===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the Cogent RISC-V register files
//===----------------------------------------------------------------------===//

let Namespace = "Cogent" in {
class CogentReg<bits<5> Enc, string n, list<string> alt = []> : Register<n> {
  let HWEncoding{4-0} = Enc;
  let AltNames = alt;
}

def ABIRegAltName : RegAltNameIndex;

} // Namespace = "Cogent"

// Integer registers
// CostPerUse is set higher for registers that may not be compressible as they
// are not part of GPRC, the most restrictive register class used by the
// compressed instruction set. This will influence the greedy register
// allocator to reduce the use of registers that can't be encoded in 16 bit
// instructions.

let RegAltNameIndices = [ABIRegAltName] in {
  let isConstant = true in
  def X0  : CogentReg<0, "x0", ["zero"]>, DwarfRegNum<[0]>;
  let CostPerUse = [0, 1] in {
  def X1  : CogentReg<1, "x1", ["ra"]>, DwarfRegNum<[1]>;
  def X2  : CogentReg<2, "x2", ["sp"]>, DwarfRegNum<[2]>;
  def X3  : CogentReg<3, "x3", ["gp"]>, DwarfRegNum<[3]>;
  def X4  : CogentReg<4, "x4", ["tp"]>, DwarfRegNum<[4]>;
  def X5  : CogentReg<5, "x5", ["t0"]>, DwarfRegNum<[5]>;
  def X6  : CogentReg<6, "x6", ["t1"]>, DwarfRegNum<[6]>;
  def X7  : CogentReg<7, "x7", ["t2"]>, DwarfRegNum<[7]>;
  }
  def X8  : CogentReg<8, "x8", ["s0"]>, DwarfRegNum<[8]>;
  def X9  : CogentReg<9, "x9", ["s1"]>, DwarfRegNum<[9]>;
  def X10 : CogentReg<10,"x10", ["a0"]>, DwarfRegNum<[10]>;
  def X11 : CogentReg<11,"x11", ["a1"]>, DwarfRegNum<[11]>;
  def X12 : CogentReg<12,"x12", ["a2"]>, DwarfRegNum<[12]>;
  def X13 : CogentReg<13,"x13", ["a3"]>, DwarfRegNum<[13]>;
  def X14 : CogentReg<14,"x14", ["a4"]>, DwarfRegNum<[14]>;
  def X15 : CogentReg<15,"x15", ["a5"]>, DwarfRegNum<[15]>;
  let CostPerUse = [0, 1] in {
  def X16 : CogentReg<16,"x16", ["a6"]>, DwarfRegNum<[16]>;
  def X17 : CogentReg<17,"x17", ["a7"]>, DwarfRegNum<[17]>;
  def X18 : CogentReg<18,"x18", ["s2"]>, DwarfRegNum<[18]>;
  def X19 : CogentReg<19,"x19", ["s3"]>, DwarfRegNum<[19]>;
  def X20 : CogentReg<20,"x20", ["s4"]>, DwarfRegNum<[20]>;
  def X21 : CogentReg<21,"x21", ["s5"]>, DwarfRegNum<[21]>;
  def X22 : CogentReg<22,"x22", ["s6"]>, DwarfRegNum<[22]>;
  def X23 : CogentReg<23,"x23", ["s7"]>, DwarfRegNum<[23]>;
  def X24 : CogentReg<24,"x24", ["s8"]>, DwarfRegNum<[24]>;
  def X25 : CogentReg<25,"x25", ["s9"]>, DwarfRegNum<[25]>;
  def X26 : CogentReg<26,"x26", ["s10"]>, DwarfRegNum<[26]>;
  def X27 : CogentReg<27,"x27", ["s11"]>, DwarfRegNum<[27]>;
  def X28 : CogentReg<28,"x28", ["t3"]>, DwarfRegNum<[28]>;
  def X29 : CogentReg<29,"x29", ["t4"]>, DwarfRegNum<[29]>;
  def X30 : CogentReg<30,"x30", ["t5"]>, DwarfRegNum<[30]>;
  def X31 : CogentReg<31,"x31", ["t6"]>, DwarfRegNum<[31]>;
  }
}

// The order of registers represents the preferred allocation sequence.
// Registers are listed in the order caller-save, callee-save, specials.
def GPR : RegisterClass<"Cogent", [i32], 32, (add
    (sequence "X%u", 10, 17),
    (sequence "X%u", 5, 7),
    (sequence "X%u", 28, 31),
    (sequence "X%u", 8, 9),
    (sequence "X%u", 18, 27),
    (sequence "X%u", 0, 4)
  )>;

def GPRX0 : RegisterClass<"Cogent", [i32], 32, (add X0)>;

def GPRNoX0 : RegisterClass<"Cogent", [i32], 32, (sub GPR, X0)>;

def GPRNoX0X2 : RegisterClass<"Cogent", [i32], 32, (sub GPR, X0, X2)>;

// Don't use X1 or X5 for JALR since that is a hint to pop the return address
// stack on some microarchitectures. Also remove the reserved registers X0, X2,
// X3, and X4 as it reduces the number of register classes that get synthesized
// by tablegen.
def GPRJALR : RegisterClass<"Cogent", [i32], 32, (sub GPR, (sequence "X%u", 0, 5))>;

def GPRC : RegisterClass<"Cogent", [i32], 32, (add
    (sequence "X%u", 10, 15),
    (sequence "X%u", 8, 9)
  )>;

// For indirect tail calls, we can't use callee-saved registers, as they are
// restored to the saved value before the tail call, which would clobber a call
// address. We shouldn't use x5 since that is a hint for to pop the return
// address stack on some microarchitectures.
def GPRTC : RegisterClass<"Cogent", [i32], 32, (add
    (sequence "X%u", 6, 7),
    (sequence "X%u", 10, 17),
    (sequence "X%u", 28, 31)
  )>;

def SP : RegisterClass<"Cogent", [i32], 32, (add X2)>;

def GPROpnd : RegisterOperand<GPR>;
