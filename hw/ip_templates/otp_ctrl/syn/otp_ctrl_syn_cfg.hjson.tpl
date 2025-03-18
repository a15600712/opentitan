// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
{
  // Top level dut name (sv module).
  name: otp_ctrl

  // Fusesoc core file used for building the file list.
  fusesoc_core: lowrisc:${topname}_ip:{name}:0.1

  import_cfgs: [// Project wide common synthesis config file
                "{proj_root}/hw/syn/tools/dvsim/common_syn_cfg.hjson"]

  overrides: [
    {
      name: design_level
      value: "top"
    }
  ]

  // Timing constraints for this module
  sdc_file: "{proj_root}/hw/top_${topname}/ip_autogen/{name}/syn/constraints.sdc"

  // This is not needed for this module
  foundry_sdc_file: ""
}
