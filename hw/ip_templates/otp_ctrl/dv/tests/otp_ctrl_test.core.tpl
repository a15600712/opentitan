CAPI=2:
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
name: ${instance_vlnv("lowrisc:dv:otp_ctrl_test:0.1")}
description: "OTP_CTRL DV UVM test"

filesets:
  files_dv:
    depend:
      - ${instance_vlnv("lowrisc:dv:otp_ctrl_env")}
    files:
      - otp_ctrl_test_pkg.sv
      - otp_ctrl_base_test.sv: {is_include_file: true}
    file_type: systemVerilogSource

targets:
  default:
    filesets:
      - files_dv
