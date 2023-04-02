//===-- CogentTargetMachine.h - Define TargetMachine for Cogent RISCV -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file declares the Cogent-RISCV specific subclass of TargetMachine.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_COGENT_COGENTTARGETMACHINE_H
#define LLVM_LIB_TARGET_COGENT_COGENTTARGETMACHINE_H

#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class CogentTargetMachine : public LLVMTargetMachine {
   std::unique_ptr<TargetLoweringObjectFile> TLOF;

public:
  CogentTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                    StringRef FS, const TargetOptions &Options,
                    std::optional<Reloc::Model> RM,
                    std::optional<CodeModel::Model> CM, CodeGenOpt::Level OL,
                    bool JIT);

  ~CogentTargetMachine() override;

  const CogentSubtarget *getSubtargetImpl() const = delete;

  //const CogentSubtarget *getSubtargetImpl(const Function &F) const override;

  // Pass Pipeline Configuration
  TargetPassConfig *createPassConfig(PassManagerBase &PM) override;

  TargetLoweringObjectFile *getObjFileLowering() const override {
    return TLOF.get();
  }

};
} // namespace llvm

#endif // LLVM_LIB_TARGET_COGENT_COGENTTARGETMACHINE_H
