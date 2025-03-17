CAPI=2:
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
name: ${instance_vlnv("lowrisc:dv:clkmgr_env:0.1")}
description: "CLKMGR DV UVM environment"
filesets:
  files_dv:
    depend:
      - lowrisc:dv:ralgen
      - lowrisc:dv:cip_lib
      - ${instance_vlnv("lowrisc:ip:pwrmgr_pkg")}
      - ${instance_vlnv("lowrisc:ip:clkmgr_pkg")}
      - ${top_pkg_vlnv}
    files:
      - clkmgr_csrs_if.sv
      - clkmgr_env_pkg.sv
      - clkmgr_env_cfg.sv: {is_include_file: true}
      - clkmgr_env_cov.sv: {is_include_file: true}
      - clkmgr_virtual_sequencer.sv: {is_include_file: true}
      - clkmgr_scoreboard.sv: {is_include_file: true}
      - clkmgr_env.sv: {is_include_file: true}
      - seq_lib/clkmgr_vseq_list.sv: {is_include_file: true}
      - seq_lib/clkmgr_base_vseq.sv: {is_include_file: true}
      - seq_lib/clkmgr_clk_status_vseq.sv: {is_include_file: true}
      - seq_lib/clkmgr_common_vseq.sv: {is_include_file: true}
      - seq_lib/clkmgr_extclk_vseq.sv: {is_include_file: true}
      - seq_lib/clkmgr_frequency_timeout_vseq.sv: {is_include_file: true}
      - seq_lib/clkmgr_frequency_vseq.sv: {is_include_file: true}
      - seq_lib/clkmgr_peri_vseq.sv: {is_include_file: true}
      - seq_lib/clkmgr_regwen_vseq.sv: {is_include_file: true}
      - seq_lib/clkmgr_smoke_vseq.sv: {is_include_file: true}
      - seq_lib/clkmgr_stress_all_vseq.sv: {is_include_file: true}
      - seq_lib/clkmgr_trans_vseq.sv: {is_include_file: true}
      - clkmgr_if.sv
    file_type: systemVerilogSource

generate:
  ral:
    generator: ralgen
    parameters:
      name: clkmgr
      ip_hjson: ../../data/clkmgr.hjson

targets:
  default:
    filesets:
      - files_dv
    generate:
      - ral
