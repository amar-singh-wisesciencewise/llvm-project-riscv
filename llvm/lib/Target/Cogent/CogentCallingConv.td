//===-- CogentCallingConv.td - Calling Conventions Cogent ----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This describes the calling conventions for the Cogent RISC-V architecture.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Cogent RISC-V 32-bit.
//===----------------------------------------------------------------------===//

def CC_Cogent : CallingConv<[
  // All small integers are promoted to i32 by the caller.
  CCIfType<[i1, i8, i16], CCPromoteToType<i32>>,
  // i32 arguments get passed in integer registers if there is space.
  CCIfType<[i32], CCAssignToReg<[X1, X2, X3, X4]>>,
  //CCIfSRet<CCIfType<[i32], CCAssignToReg<[X1]>>>,

  // Alternatively, they are assigned to the stack in 4-byte aligned units.
  CCAssignToStack<4, 4>
]>;

def RetCC_Cogent : CallingConv<[
  CCIfType<[i32], CCAssignToReg<[X1]>>,
]>;


// Callee-saved registers are handled by the register window mechanism.
def CSR_Cogent : CalleeSavedRegs<(add)> {
  let OtherPreserved = (add (sequence "X%u", 1, 7));
}

