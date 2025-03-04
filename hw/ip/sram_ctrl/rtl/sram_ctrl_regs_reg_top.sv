// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`

`include "prim_assert.sv"

module sram_ctrl_regs_reg_top
  # (
    parameter bit          EnableRacl           = 1'b0,
    parameter bit          RaclErrorRsp         = 1'b1,
    parameter top_racl_pkg::racl_policy_sel_t RaclPolicySelVec[sram_ctrl_reg_pkg::NumRegsRegs] =
      '{sram_ctrl_reg_pkg::NumRegsRegs{0}}
  ) (
  input clk_i,
  input rst_ni,
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,
  // To HW
  output sram_ctrl_reg_pkg::sram_ctrl_regs_reg2hw_t reg2hw, // Write
  input  sram_ctrl_reg_pkg::sram_ctrl_regs_hw2reg_t hw2reg, // Read

  // RACL interface
  input  top_racl_pkg::racl_policy_vec_t racl_policies_i,
  output top_racl_pkg::racl_error_log_t  racl_error_o,

  // Integrity check errors
  output logic intg_err_o
);

  import sram_ctrl_reg_pkg::* ;

  localparam int AW = 6;
  localparam int DW = 32;
  localparam int DBW = DW/8;                    // Byte Width

  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  logic          addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;
  logic reg_busy;

  tlul_pkg::tl_h2d_t tl_reg_h2d;
  tlul_pkg::tl_d2h_t tl_reg_d2h;


  // incoming payload check
  logic intg_err;
  tlul_cmd_intg_chk u_chk (
    .tl_i(tl_i),
    .err_o(intg_err)
  );

  // also check for spurious write enables
  logic reg_we_err;
  logic [8:0] reg_we_check;
  prim_reg_we_check #(
    .OneHotWidth(9)
  ) u_prim_reg_we_check (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .oh_i  (reg_we_check),
    .en_i  (reg_we && !addrmiss),
    .err_o (reg_we_err)
  );

  logic err_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      err_q <= '0;
    end else if (intg_err || reg_we_err) begin
      err_q <= 1'b1;
    end
  end

  // integrity error output is permanent and should be used for alert generation
  // register errors are transactional
  assign intg_err_o = err_q | intg_err | reg_we_err;

  // outgoing integrity generation
  tlul_pkg::tl_d2h_t tl_o_pre;
  tlul_rsp_intg_gen #(
    .EnableRspIntgGen(1),
    .EnableDataIntgGen(1)
  ) u_rsp_intg_gen (
    .tl_i(tl_o_pre),
    .tl_o(tl_o)
  );

  assign tl_reg_h2d = tl_i;
  assign tl_o_pre   = tl_reg_d2h;

  tlul_adapter_reg #(
    .RegAw(AW),
    .RegDw(DW),
    .EnableDataIntgGen(0)
  ) u_reg_if (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),

    .tl_i (tl_reg_h2d),
    .tl_o (tl_reg_d2h),

    .en_ifetch_i(prim_mubi_pkg::MuBi4False),
    .intg_error_o(),

    .we_o    (reg_we),
    .re_o    (reg_re),
    .addr_o  (reg_addr),
    .wdata_o (reg_wdata),
    .be_o    (reg_be),
    .busy_i  (reg_busy),
    .rdata_i (reg_rdata),
    // Translate RACL error to TLUL error if enabled
    .error_i (reg_error | (RaclErrorRsp & racl_error_o.valid))
  );

  // cdc oversampling signals

  assign reg_rdata = reg_rdata_next ;
  assign reg_error = addrmiss | wr_err | intg_err;

  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic alert_test_we;
  logic alert_test_wd;
  logic status_bus_integ_error_qs;
  logic status_init_error_qs;
  logic status_escalated_qs;
  logic status_scr_key_valid_qs;
  logic status_scr_key_seed_valid_qs;
  logic status_init_done_qs;
  logic status_readback_error_qs;
  logic status_sram_alert_qs;
  logic exec_regwen_we;
  logic exec_regwen_qs;
  logic exec_regwen_wd;
  logic exec_we;
  logic [3:0] exec_qs;
  logic [3:0] exec_wd;
  logic ctrl_regwen_we;
  logic ctrl_regwen_qs;
  logic ctrl_regwen_wd;
  logic ctrl_we;
  logic ctrl_renew_scr_key_wd;
  logic ctrl_init_wd;
  logic scr_key_rotated_we;
  logic [3:0] scr_key_rotated_qs;
  logic [3:0] scr_key_rotated_wd;
  logic readback_regwen_we;
  logic readback_regwen_qs;
  logic readback_regwen_wd;
  logic readback_we;
  logic [3:0] readback_qs;
  logic [3:0] readback_wd;

  // Register instances
  // R[alert_test]: V(True)
  logic alert_test_qe;
  logic [0:0] alert_test_flds_we;
  assign alert_test_qe = &alert_test_flds_we;
  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_wd),
    .d      ('0),
    .qre    (),
    .qe     (alert_test_flds_we[0]),
    .q      (reg2hw.alert_test.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.alert_test.qe = alert_test_qe;


  // R[status]: V(False)
  //   F[bus_integ_error]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_bus_integ_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.bus_integ_error.de),
    .d      (hw2reg.status.bus_integ_error.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status.bus_integ_error.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_bus_integ_error_qs)
  );

  //   F[init_error]: 1:1
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_init_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.init_error.de),
    .d      (hw2reg.status.init_error.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status.init_error.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_init_error_qs)
  );

  //   F[escalated]: 2:2
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_escalated (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.escalated.de),
    .d      (hw2reg.status.escalated.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status.escalated.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_escalated_qs)
  );

  //   F[scr_key_valid]: 3:3
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_scr_key_valid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.scr_key_valid.de),
    .d      (hw2reg.status.scr_key_valid.d),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (status_scr_key_valid_qs)
  );

  //   F[scr_key_seed_valid]: 4:4
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_scr_key_seed_valid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.scr_key_seed_valid.de),
    .d      (hw2reg.status.scr_key_seed_valid.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status.scr_key_seed_valid.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_scr_key_seed_valid_qs)
  );

  //   F[init_done]: 5:5
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_init_done (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.init_done.de),
    .d      (hw2reg.status.init_done.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status.init_done.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_init_done_qs)
  );

  //   F[readback_error]: 6:6
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_readback_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.readback_error.de),
    .d      (hw2reg.status.readback_error.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status.readback_error.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_readback_error_qs)
  );

  //   F[sram_alert]: 7:7
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_sram_alert (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.sram_alert.de),
    .d      (hw2reg.status.sram_alert.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status.sram_alert.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_sram_alert_qs)
  );


  // R[exec_regwen]: V(False)
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW0C),
    .RESVAL  (1'h1),
    .Mubi    (1'b0)
  ) u_exec_regwen (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (exec_regwen_we),
    .wd     (exec_regwen_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (exec_regwen_qs)
  );


  // R[exec]: V(False)
  // Create REGWEN-gated WE signal
  logic exec_gated_we;
  assign exec_gated_we = exec_we & exec_regwen_qs;
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h9),
    .Mubi    (1'b1)
  ) u_exec (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (exec_gated_we),
    .wd     (exec_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.exec.q),
    .ds     (),

    // to register interface (read)
    .qs     (exec_qs)
  );


  // R[ctrl_regwen]: V(False)
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW0C),
    .RESVAL  (1'h1),
    .Mubi    (1'b0)
  ) u_ctrl_regwen (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (ctrl_regwen_we),
    .wd     (ctrl_regwen_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (ctrl_regwen_qs)
  );


  // R[ctrl]: V(False)
  logic ctrl_qe;
  logic [1:0] ctrl_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_ctrl0_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&ctrl_flds_we),
    .q_o(ctrl_qe)
  );
  // Create REGWEN-gated WE signal
  logic ctrl_gated_we;
  assign ctrl_gated_we = ctrl_we & ctrl_regwen_qs;
  //   F[renew_scr_key]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_ctrl_renew_scr_key (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (ctrl_gated_we),
    .wd     (ctrl_renew_scr_key_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (ctrl_flds_we[0]),
    .q      (reg2hw.ctrl.renew_scr_key.q),
    .ds     (),

    // to register interface (read)
    .qs     ()
  );
  assign reg2hw.ctrl.renew_scr_key.qe = ctrl_qe;

  //   F[init]: 1:1
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_ctrl_init (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (ctrl_gated_we),
    .wd     (ctrl_init_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (ctrl_flds_we[1]),
    .q      (reg2hw.ctrl.init.q),
    .ds     (),

    // to register interface (read)
    .qs     ()
  );
  assign reg2hw.ctrl.init.qe = ctrl_qe;


  // R[scr_key_rotated]: V(False)
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (4'h9),
    .Mubi    (1'b1)
  ) u_scr_key_rotated (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (scr_key_rotated_we),
    .wd     (scr_key_rotated_wd),

    // from internal hardware
    .de     (hw2reg.scr_key_rotated.de),
    .d      (hw2reg.scr_key_rotated.d),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (scr_key_rotated_qs)
  );


  // R[readback_regwen]: V(False)
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW0C),
    .RESVAL  (1'h1),
    .Mubi    (1'b0)
  ) u_readback_regwen (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (readback_regwen_we),
    .wd     (readback_regwen_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (readback_regwen_qs)
  );


  // R[readback]: V(False)
  // Create REGWEN-gated WE signal
  logic readback_gated_we;
  assign readback_gated_we = readback_we & readback_regwen_qs;
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h9),
    .Mubi    (1'b1)
  ) u_readback (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (readback_gated_we),
    .wd     (readback_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.readback.q),
    .ds     (),

    // to register interface (read)
    .qs     (readback_qs)
  );



  logic [8:0] addr_hit;
  top_racl_pkg::racl_role_vec_t racl_role_vec;
  top_racl_pkg::racl_role_t racl_role;

  logic [8:0] racl_addr_hit_read;
  logic [8:0] racl_addr_hit_write;

  if (EnableRacl) begin : gen_racl_role_logic
    // Retrieve RACL role from user bits and one-hot encode that for the comparison bitmap
    assign racl_role = top_racl_pkg::tlul_extract_racl_role_bits(tl_i.a_user.rsvd);

    prim_onehot_enc #(
      .OneHotWidth( $bits(top_racl_pkg::racl_role_vec_t) )
    ) u_racl_role_encode (
      .in_i ( racl_role     ),
      .en_i ( 1'b1          ),
      .out_o( racl_role_vec )
    );
  end else begin : gen_no_racl_role_logic
    assign racl_role     = '0;
    assign racl_role_vec = '0;
  end

  always_comb begin
    addr_hit = '0;
    racl_addr_hit_read  = '0;
    racl_addr_hit_write = '0;
    addr_hit[0] = (reg_addr == SRAM_CTRL_ALERT_TEST_OFFSET);
    addr_hit[1] = (reg_addr == SRAM_CTRL_STATUS_OFFSET);
    addr_hit[2] = (reg_addr == SRAM_CTRL_EXEC_REGWEN_OFFSET);
    addr_hit[3] = (reg_addr == SRAM_CTRL_EXEC_OFFSET);
    addr_hit[4] = (reg_addr == SRAM_CTRL_CTRL_REGWEN_OFFSET);
    addr_hit[5] = (reg_addr == SRAM_CTRL_CTRL_OFFSET);
    addr_hit[6] = (reg_addr == SRAM_CTRL_SCR_KEY_ROTATED_OFFSET);
    addr_hit[7] = (reg_addr == SRAM_CTRL_READBACK_REGWEN_OFFSET);
    addr_hit[8] = (reg_addr == SRAM_CTRL_READBACK_OFFSET);

    if (EnableRacl) begin : gen_racl_hit
      for (int unsigned slice_idx = 0; slice_idx < 9; slice_idx++) begin
        racl_addr_hit_read[slice_idx] =
            addr_hit[slice_idx] & (|(racl_policies_i[RaclPolicySelVec[slice_idx]].read_perm
                                      & racl_role_vec));
        racl_addr_hit_write[slice_idx] =
            addr_hit[slice_idx] & (|(racl_policies_i[RaclPolicySelVec[slice_idx]].write_perm
                                      & racl_role_vec));
      end
    end else begin : gen_no_racl
      racl_addr_hit_read  = addr_hit;
      racl_addr_hit_write = addr_hit;
    end
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;
  // A valid address hit, access, but failed the RACL check
  assign racl_error_o.valid = |addr_hit & ((reg_re & ~|racl_addr_hit_read) |
                                           (reg_we & ~|racl_addr_hit_write));
  assign racl_error_o.request_address = top_pkg::TL_AW'(reg_addr);
  assign racl_error_o.racl_role       = racl_role;
  assign racl_error_o.overflow        = 1'b0;

  if (EnableRacl) begin : gen_racl_log
    assign racl_error_o.ctn_uid     = top_racl_pkg::tlul_extract_ctn_uid_bits(tl_i.a_user.rsvd);
    assign racl_error_o.read_access = tl_i.a_opcode == tlul_pkg::Get;
  end else begin : gen_no_racl_log
    assign racl_error_o.ctn_uid     = '0;
    assign racl_error_o.read_access = 1'b0;
  end

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((racl_addr_hit_write[0] & (|(SRAM_CTRL_REGS_PERMIT[0] & ~reg_be))) |
               (racl_addr_hit_write[1] & (|(SRAM_CTRL_REGS_PERMIT[1] & ~reg_be))) |
               (racl_addr_hit_write[2] & (|(SRAM_CTRL_REGS_PERMIT[2] & ~reg_be))) |
               (racl_addr_hit_write[3] & (|(SRAM_CTRL_REGS_PERMIT[3] & ~reg_be))) |
               (racl_addr_hit_write[4] & (|(SRAM_CTRL_REGS_PERMIT[4] & ~reg_be))) |
               (racl_addr_hit_write[5] & (|(SRAM_CTRL_REGS_PERMIT[5] & ~reg_be))) |
               (racl_addr_hit_write[6] & (|(SRAM_CTRL_REGS_PERMIT[6] & ~reg_be))) |
               (racl_addr_hit_write[7] & (|(SRAM_CTRL_REGS_PERMIT[7] & ~reg_be))) |
               (racl_addr_hit_write[8] & (|(SRAM_CTRL_REGS_PERMIT[8] & ~reg_be)))));
  end

  // Generate write-enables
  assign alert_test_we = racl_addr_hit_write[0] & reg_we & !reg_error;

  assign alert_test_wd = reg_wdata[0];
  assign exec_regwen_we = racl_addr_hit_write[2] & reg_we & !reg_error;

  assign exec_regwen_wd = reg_wdata[0];
  assign exec_we = racl_addr_hit_write[3] & reg_we & !reg_error;

  assign exec_wd = reg_wdata[3:0];
  assign ctrl_regwen_we = racl_addr_hit_write[4] & reg_we & !reg_error;

  assign ctrl_regwen_wd = reg_wdata[0];
  assign ctrl_we = racl_addr_hit_write[5] & reg_we & !reg_error;

  assign ctrl_renew_scr_key_wd = reg_wdata[0];

  assign ctrl_init_wd = reg_wdata[1];
  assign scr_key_rotated_we = racl_addr_hit_write[6] & reg_we & !reg_error;

  assign scr_key_rotated_wd = reg_wdata[3:0];
  assign readback_regwen_we = racl_addr_hit_write[7] & reg_we & !reg_error;

  assign readback_regwen_wd = reg_wdata[0];
  assign readback_we = racl_addr_hit_write[8] & reg_we & !reg_error;

  assign readback_wd = reg_wdata[3:0];

  // Assign write-enables to checker logic vector.
  always_comb begin
    reg_we_check = '0;
    reg_we_check[0] = alert_test_we;
    reg_we_check[1] = 1'b0;
    reg_we_check[2] = exec_regwen_we;
    reg_we_check[3] = exec_gated_we;
    reg_we_check[4] = ctrl_regwen_we;
    reg_we_check[5] = ctrl_gated_we;
    reg_we_check[6] = scr_key_rotated_we;
    reg_we_check[7] = readback_regwen_we;
    reg_we_check[8] = readback_gated_we;
  end

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      racl_addr_hit_read[0]: begin
        reg_rdata_next[0] = '0;
      end

      racl_addr_hit_read[1]: begin
        reg_rdata_next[0] = status_bus_integ_error_qs;
        reg_rdata_next[1] = status_init_error_qs;
        reg_rdata_next[2] = status_escalated_qs;
        reg_rdata_next[3] = status_scr_key_valid_qs;
        reg_rdata_next[4] = status_scr_key_seed_valid_qs;
        reg_rdata_next[5] = status_init_done_qs;
        reg_rdata_next[6] = status_readback_error_qs;
        reg_rdata_next[7] = status_sram_alert_qs;
      end

      racl_addr_hit_read[2]: begin
        reg_rdata_next[0] = exec_regwen_qs;
      end

      racl_addr_hit_read[3]: begin
        reg_rdata_next[3:0] = exec_qs;
      end

      racl_addr_hit_read[4]: begin
        reg_rdata_next[0] = ctrl_regwen_qs;
      end

      racl_addr_hit_read[5]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[1] = '0;
      end

      racl_addr_hit_read[6]: begin
        reg_rdata_next[3:0] = scr_key_rotated_qs;
      end

      racl_addr_hit_read[7]: begin
        reg_rdata_next[0] = readback_regwen_qs;
      end

      racl_addr_hit_read[8]: begin
        reg_rdata_next[3:0] = readback_qs;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  // shadow busy
  logic shadow_busy;
  assign shadow_busy = 1'b0;

  // register busy
  assign reg_busy = shadow_busy;

  // Unused signal tieoff

  // wdata / byte enable are not always fully used
  // add a blanket unused statement to handle lint waivers
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;
  logic unused_policy_sel;
  assign unused_policy_sel = ^racl_policies_i;

  // Assertions for Register Interface
  `ASSERT_PULSE(wePulse, reg_we, clk_i, !rst_ni)
  `ASSERT_PULSE(rePulse, reg_re, clk_i, !rst_ni)

  `ASSERT(reAfterRv, $rose(reg_re || reg_we) |=> tl_o_pre.d_valid, clk_i, !rst_ni)

  `ASSERT(en2addrHit, (reg_we || reg_re) |-> $onehot0(addr_hit), clk_i, !rst_ni)

  // this is formulated as an assumption such that the FPV testbenches do disprove this
  // property by mistake
  //`ASSUME(reqParity, tl_reg_h2d.a_valid |-> tl_reg_h2d.a_user.chk_en == tlul_pkg::CheckDis)

endmodule
