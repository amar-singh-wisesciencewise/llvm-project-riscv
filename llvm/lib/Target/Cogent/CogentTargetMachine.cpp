//===-- CogentTargetMachine.cpp - Cogent RISCV Target Machine -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file contains implementation for Cogent RISCV target machine.
///
//===----------------------------------------------------------------------===//

#include "CogentTargetMachine.h"
#include "Cogent.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/CodeGen/Passes.h"
#include "TargetInfo/M88kTargetInfo.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeCogentTarget() {
  // Register the target.
  RegisterTargetMachine<CogentTargetMachine> X(getTheCogentTarget());
}

//TODO:
std::string computeDataLayout(const Triple &TT, StringRef CPU, StringRef FS) {
  std::string Ret;

  // Big endian.
  Ret += "e";

  // Data mangling.
  Ret += DataLayout::getManglingComponent(TT);

  // Pointers are 32 bit.
  Ret += "-p:32:8:32";

  // Make sure that global data has at least 16 bits of alignment by
  // default, so that we can refer to it using LARL.  We don't have any
  // special requirements for stack variables though.
  Ret += "-i1:8:16-i8:8:16";

  // 64-bit integers are naturally aligned.
  Ret += "-i64:64";

  // 128-bit floats are aligned only to 64 bits.
  Ret += "-f128:64";

  // We prefer 16 bits of aligned for all globals; see above.
  Ret += "-a:8:16";

  // Integer registers are 32bits.
  Ret += "-n32";

  return Ret;
}

// TODO:
Reloc::Model getEffectiveRelocModel(Optional<Reloc::Model> RM) {
  if (!RM.hasValue() || *RM == Reloc::DynamicNoPIC)
    return Reloc::Static;
  return *RM;
}

CogentTargetMachine::CogentTargetMachine(const Target &T, const Triple &TT,
                                     StringRef CPU, StringRef FS,
                                     const TargetOptions &Options,
                                     std::optional<Reloc::Model> RM,
                                     std::optional<CodeModel::Model> CM,
                                     CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T, computeDataLayout(TT, CPU, FS), TT, CPU, FS,
                        Options, getEffectiveRelocModel(TT, RM),
                        ::getEffectiveCodeModel(CM, JIT), OL),
      TLOF(std::make_unique<M68kELFTargetObjectFile>()) {
	  initAsmInfo();
}

CogentTargetMachine::~CogentTargetMachine() {}


//===----------------------------------------------------------------------===//
// Pass Pipeline Configuration
//===----------------------------------------------------------------------===//

namespace {
class CogentPassConfig : public TargetPassConfig {
public:
  CogentPassConfig(CogentTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  CogentTargetMachine &getCogentTargetMachine() const {
    return getTM<CogentTargetMachine>();
  }

  bool addInstSelector() override;
};
} // namespace

TargetPassConfig *CogentTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new CogentPassConfig(*this, PM);
}

bool CogentPassConfig::addInstSelector() {
  // Install an instruction selector.
  addPass(createCogentISelDag(getCogentTargetMachine()));
  //addPass(createCogentGlobalBaseRegPass());
  return false;
}

