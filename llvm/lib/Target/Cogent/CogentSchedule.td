//===-- CogentSchedule.td - Cogent Scheduling Definitions ------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file contains Cogent RISC-V scheduler definitions.
///
//===----------------------------------------------------------------------===//

// This is a very general Cogent RISC-V Scheduling Model.
class CogentSchedModel : SchedMachineModel {
  let LoadLatency = 4;  // Word (Rn)
  let HighLatency = 4; // Dummy
  let PostRAScheduler = 0;
  let CompleteModel = 0;

  let IssueWidth = 2;
  let MicroOpBufferSize = 0;
  let NoModel = 1;
}
