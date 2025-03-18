// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//==================================================
// This file contains the Excluded objects
// Generated By User: root
// Format Version: 2
// Date: Fri Nov 11 23:31:21 2022
// ExclMode: default
//==================================================
CHECKSUM: "3217127264 1123521396"
INSTANCE: tb.dut.top_darjeeling.u_rv_plic.u_gateway
ANNOTATION: "[UNR] The le_i input is tied off to 0 (only level interrupts supported)."
Condition 1 "3875741545" "(le_i[i] ? ((src_i[i] & (~src_q[i]))) : src_i[i]) 1 -1" (2 "1")
CHECKSUM: "3217127264 92756088"
INSTANCE: tb.dut.top_darjeeling.u_rv_plic.u_gateway
ANNOTATION: "[UNR] The le_i input is tied off to 0 (only level interrupts supported)."
Branch 1 "1296482561" "le_i[i]" (0) "le_i[i] 1"
