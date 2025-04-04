// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_${xbar.name} module generated by `tlgen.py` tool
// all reset signals should be generated from one reset signal to not make any deadlock
//
// Interconnect
<%
  import tlgen.lib as lib
  from tlgen.item import Host, Device, AsyncFifo, Socket1N, SocketM1
%>\
% for host in xbar.hosts:
${xbar.repr_tree(host, 0)}
% endfor

module xbar_${xbar.name} (
% for c in xbar.clocks:
  input ${c},
% endfor
% for r in xbar.resets:
  input ${r},
% endfor

  // Host interfaces
% for node in xbar.hosts:
  input  tlul_pkg::tl_h2d_t tl_${node.name.replace('.', '__')}_i,
  output tlul_pkg::tl_d2h_t tl_${node.name.replace('.', '__')}_o,
% endfor

  // Device interfaces
% for node in xbar.devices:
  output tlul_pkg::tl_h2d_t tl_${node.name.replace('.', '__')}_o,
  input  tlul_pkg::tl_d2h_t tl_${node.name.replace('.', '__')}_i,
% endfor

  input prim_mubi_pkg::mubi4_t scanmode_i
);

  import tlul_pkg::*;
  import tl_${xbar.name}_pkg::*;

  // scanmode_i is currently not used, but provisioned for future use
  // this assignment prevents lint warnings
  logic unused_scanmode;
  assign unused_scanmode = ^scanmode_i;

% for block in xbar.nodes:
  ## Create enum type for Upstream and Downstream ports connection
  % if isinstance(block, AsyncFifo):
    ## One US, one DS
  tl_h2d_t tl_${block.name}_us_h2d ;
  tl_d2h_t tl_${block.name}_us_d2h ;
  tl_h2d_t tl_${block.name}_ds_h2d ;
  tl_d2h_t tl_${block.name}_ds_d2h ;

  % elif isinstance(block, Socket1N):
    ## One US, multiple DS
  tl_h2d_t tl_${block.name}_us_h2d ;
  tl_d2h_t tl_${block.name}_us_d2h ;

  ##typedef enum int {
  ##  % for port in block.ds:
  ##    % if loop.last:
  ##    % else:
  ##    % endif
  ##  % endfor
  ##} socket_${block.name}_ds_e;

  tl_h2d_t tl_${block.name}_ds_h2d [${len(block.ds)}];
  tl_d2h_t tl_${block.name}_ds_d2h [${len(block.ds)}];

  // Create steering signal
  logic [${len(block.ds).bit_length()-1}:0] dev_sel_${block.name};

  % elif isinstance(block, SocketM1):
    ## Multiple US, one DS
    ## typedef enum int {
    ##   % for port in block.us:
    ##     % if loop.last:
    ##     % else:
    ##     % endif
    ##   % endfor
    ## } socket_${block.name}_us_e;

  tl_h2d_t tl_${block.name}_us_h2d [${len(block.us)}];
  tl_d2h_t tl_${block.name}_us_d2h [${len(block.us)}];

  tl_h2d_t tl_${block.name}_ds_h2d ;
  tl_d2h_t tl_${block.name}_ds_d2h ;

  % else:
    ## block is either HOST or DEVICE. Ignore
  % endif
% endfor

% for conn in xbar.edges:
  ## sweep each entry of edges and find each end (us, ds) then connect between
  ## Connect upstream
<%
    ds_name = conn.ds.name.replace('.', '__')
    us_name = conn.us.name.replace('.', '__')

    if isinstance(conn.ds, AsyncFifo):
      ds_h2d_name = 'tl_' + ds_name + '_us_h2d'
      ds_d2h_name = 'tl_' + ds_name + '_us_d2h'
      ds_index = -1
    elif isinstance(conn.ds, Socket1N):
      ds_h2d_name = 'tl_' + ds_name + '_us_h2d'
      ds_d2h_name = 'tl_' + ds_name + '_us_d2h'
      ds_index = -1
    elif isinstance(conn.ds, SocketM1):
      ds_h2d_name = 'tl_' + ds_name + '_us_h2d'
      ds_d2h_name = 'tl_' + ds_name + '_us_d2h'
      ds_index = conn.ds.us.index(conn)
    elif isinstance(conn.ds, Device):
      ds_h2d_name = 'tl_' + ds_name + '_o'
      ds_d2h_name = 'tl_' + ds_name + '_i'
      ds_index = -1

    if isinstance(conn.us, AsyncFifo):
      us_h2d_name = 'tl_' + us_name + '_ds_h2d'
      us_d2h_name = 'tl_' + us_name + '_ds_d2h'
      us_index = -1
    elif isinstance(conn.us, Socket1N):
      us_h2d_name = 'tl_' + us_name + '_ds_h2d'
      us_d2h_name = 'tl_' + us_name + '_ds_d2h'
      us_index = conn.us.ds.index(conn)
    elif isinstance(conn.us, SocketM1):
      us_h2d_name = 'tl_' + us_name + '_ds_h2d'
      us_d2h_name = 'tl_' + us_name + '_ds_d2h'
      us_index = -1
    elif isinstance(conn.us, Host):
      us_h2d_name = 'tl_' + us_name + '_i'
      us_d2h_name = 'tl_' + us_name + '_o'
      us_index = -1
%>\

% if us_index == -1 and ds_index == -1:
  assign ${ds_h2d_name} = ${us_h2d_name};
  assign ${us_d2h_name} = ${ds_d2h_name};
% elif us_index == -1 and ds_index != -1:
  assign ${ds_h2d_name}[${ds_index}] = ${us_h2d_name};
  assign ${us_d2h_name} = ${ds_d2h_name}[${ds_index}];
% elif us_index != -1 and ds_index == -1:
  assign ${ds_h2d_name} = ${us_h2d_name}[${us_index}];
  assign ${us_d2h_name}[${us_index}] = ${ds_d2h_name};
% else:
  assign ${ds_h2d_name}[${ds_index}] = ${us_h2d_name}[${us_index}];
  assign ${us_d2h_name}[${us_index}] = ${ds_d2h_name}[${ds_index}];
% endif
% endfor

% for block in xbar.socket_1ns:
<%
  addr_sig = "tl_" + block.name + "_us_h2d.a_address"
  sel_len = len(block.ds).bit_length()
  assert len(block.addr_spaces) == 1
  asid = list(block.addr_spaces)[0]
  asid_name = asid.upper()
%>\
  always_comb begin
    // default steering to generate error response if address is not within the range
    dev_sel_${block.name} = ${"%d'd%d" % (sel_len, len(block.ds))};
% for i in block.ds:
<%
  leaf = xbar.get_leaf_from_s1n(block, loop.index);
  leaf_name = leaf.name.upper().replace('.', '__')

  assert asid in leaf.addr_spaces
  # TODO: Add support for xbars with multiple ASIDs
  # name_space = "ADDR_SPACE_" + asid_name + "__" + leaf_name;
  name_space = "ADDR_SPACE_" + leaf_name;
  name_mask  = "ADDR_MASK_" + leaf_name;
  prefix = "if (" if loop.first else "end else if ("
%>\
  % if len(leaf.addr_ranges[asid]) == 1:
      % if lib.is_pow2((leaf.addr_ranges[asid][0][1]-leaf.addr_ranges[asid][0][0])+1):
    ${prefix}(${addr_sig} &
    ${" " * len(prefix)} ~(${name_mask})) == ${name_space}) begin
      % else:
    ${prefix}((${addr_sig} <= (${name_mask} + ${name_space})) &&
       (${addr_sig} >= ${name_space}))) begin
      % endif
      dev_sel_${block.name} = ${"%d'd%d" % (sel_len, loop.index)};
${"end" if loop.last else ""}
  % else:
    ## Xbar device port
<%
  num_range = len(leaf.addr_ranges[asid])
%>\
    ${prefix}
    % for i in range(num_range):
      % if lib.is_pow2(leaf.addr_ranges[asid][i][1]-leaf.addr_ranges[asid][i][0]+1):
      ((${addr_sig} & ~(${name_mask}[${i}])) == ${name_space}[${i}])${" ||" if not loop.last else ""}
      % else:
      ((${addr_sig} <= (${name_mask}[${i}] + ${name_space}[${i}])) &&
       (${addr_sig} >= ${name_space}[${i}]))${" ||" if not loop.last else ""}
      % endif
    % endfor
    ) begin
      dev_sel_${block.name} = ${"%d'd%d" % (sel_len, loop.index)};
${"end" if loop.last else ""}
  % endif
% endfor
  end

% endfor

  // Instantiation phase
% for block in xbar.nodes:
<%
  stripped_name = block.name.replace('.', '__')
  # TODO #15754: Pass this parameter through the tlgen script instead of hardcoding
%>\
  % if isinstance(block, AsyncFifo):
  tlul_fifo_async #(
    .ReqDepth        (1),
    .RspDepth        (1)
  ) u_${stripped_name} (
    .clk_h_i      (${block.clocks[0]}),
    .rst_h_ni     (${block.resets[0]}),
    .clk_d_i      (${block.clocks[1]}),
    .rst_d_ni     (${block.resets[1]}),
    .tl_h_i       (tl_${stripped_name}_us_h2d),
    .tl_h_o       (tl_${stripped_name}_us_d2h),
    .tl_d_o       (tl_${stripped_name}_ds_h2d),
    .tl_d_i       (tl_${stripped_name}_ds_d2h)
  );
  % elif isinstance(block, Socket1N):
  tlul_socket_1n #(
    % if block.hreq_pass != 1:
    .HReqPass  (1'b${block.hreq_pass}),
    % endif
    % if block.hrsp_pass != 1:
    .HRspPass  (1'b${block.hrsp_pass}),
    % endif
    % if block.hdepth != 1:
    .HReqDepth (4'h${block.hdepth}),
    .HRspDepth (4'h${block.hdepth}),
    % endif
    % if block.dreq_pass != 2**(len(block.ds)) -1:
    .DReqPass  (${len(block.ds)}'h${"%x" % block.dreq_pass}),
    % endif
    % if block.drsp_pass != 2**(len(block.ds)) -1:
    .DRspPass  (${len(block.ds)}'h${"%x" % block.drsp_pass}),
    % endif
    % if block.ddepth != 1:
    .DReqDepth (${len(block.ds)*4}'h${"%x" % block.ddepth}),
    .DRspDepth (${len(block.ds)*4}'h${"%x" % block.ddepth}),
    % endif
    .N         (${len(block.ds)})
  ) u_${stripped_name} (
    .clk_i        (${block.clocks[0]}),
    .rst_ni       (${block.resets[0]}),
    .tl_h_i       (tl_${stripped_name}_us_h2d),
    .tl_h_o       (tl_${stripped_name}_us_d2h),
    .tl_d_o       (tl_${stripped_name}_ds_h2d),
    .tl_d_i       (tl_${stripped_name}_ds_d2h),
    .dev_select_i (dev_sel_${stripped_name})
  );
  % elif isinstance(block, SocketM1):
  tlul_socket_m1 #(
    % if block.hreq_pass != 2**(len(block.us)) - 1:
    .HReqPass  (${len(block.us)}'h${"%x" % block.hreq_pass}),
    % endif
    % if block.hrsp_pass != 2**(len(block.us)) - 1:
    .HRspPass  (${len(block.us)}'h${"%x" % block.hrsp_pass}),
    % endif
    % if block.hdepth != 1:
    .HReqDepth (${len(block.us)*4}'h${"%x" % block.hdepth}),
    .HRspDepth (${len(block.us)*4}'h${"%x" % block.hdepth}),
    % endif
    % if block.dreq_pass != 1:
    .DReqPass  (1'b${block.dreq_pass}),
    % endif
    % if block.drsp_pass != 1:
    .DRspPass  (1'b${block.drsp_pass}),
    % endif
    % if block.ddepth != 1:
    .DReqDepth (4'h${block.ddepth}),
    .DRspDepth (4'h${block.ddepth}),
    % endif
    .M         (${len(block.us)})
  ) u_${stripped_name} (
    .clk_i        (${block.clocks[0]}),
    .rst_ni       (${block.resets[0]}),
    .tl_h_i       (tl_${stripped_name}_us_h2d),
    .tl_h_o       (tl_${stripped_name}_us_d2h),
    .tl_d_o       (tl_${stripped_name}_ds_h2d),
    .tl_d_i       (tl_${stripped_name}_ds_d2h)
  );
  % endif
% endfor

endmodule
