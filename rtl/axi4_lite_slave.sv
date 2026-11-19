// -----------------------------------------------------------------------------
// File        : axi4_lite_slave.sv
// Description : AXI4-Lite slave with a NUM_REGS x DATA_WIDTH register file.
//               - AW and W channels are accepted independently (any order).
//               - One write and one read in flight per channel.
//               - WSTRB byte-lane writes.
//               - Accesses outside the register map return SLVERR.
//
// Bug injection (for proving the property set catches real bugs):
//   +define+BUG_WSTRB_IGNORED   : write ignores WSTRB (full-word write)
//   +define+BUG_BVALID_DROP     : BVALID deasserts without BREADY
//   +define+BUG_RDATA_UNSTABLE  : RDATA changes while RVALID && !RREADY
// -----------------------------------------------------------------------------
module axi4_lite_slave #(
  parameter int ADDR_WIDTH = 8,
  parameter int DATA_WIDTH = 32,
  parameter int NUM_REGS   = 4
) (
  input  logic                      aclk,
  input  logic                      aresetn,

  // Write address channel
  input  logic [ADDR_WIDTH-1:0]     s_axil_awaddr,
  input  logic [2:0]                s_axil_awprot,
  input  logic                      s_axil_awvalid,
  output logic                      s_axil_awready,

  // Write data channel
  input  logic [DATA_WIDTH-1:0]     s_axil_wdata,
  input  logic [DATA_WIDTH/8-1:0]   s_axil_wstrb,
  input  logic                      s_axil_wvalid,
  output logic                      s_axil_wready,

  // Write response channel
  output logic [1:0]                s_axil_bresp,
  output logic                      s_axil_bvalid,
  input  logic                      s_axil_bready,

  // Read address channel
  input  logic [ADDR_WIDTH-1:0]     s_axil_araddr,
  input  logic [2:0]                s_axil_arprot,
  input  logic                      s_axil_arvalid,
  output logic                      s_axil_arready,

  // Read data channel
  output logic [DATA_WIDTH-1:0]     s_axil_rdata,
  output logic [1:0]                s_axil_rresp,
  output logic                      s_axil_rvalid,
  input  logic                      s_axil_rready
);

  localparam int STRB_WIDTH = DATA_WIDTH / 8;
  localparam int ADDR_LSB   = $clog2(STRB_WIDTH);
  localparam int IDX_W      = (NUM_REGS > 1) ? $clog2(NUM_REGS) : 1;

  localparam logic [1:0] RESP_OKAY   = 2'b00;
  localparam logic [1:0] RESP_SLVERR = 2'b10;

  // ---------------------------------------------------------------------------
  // Register file
  // ---------------------------------------------------------------------------
  logic [DATA_WIDTH-1:0] regs [NUM_REGS];

  // Byte-offset bits addr[ADDR_LSB-1:0] are intentionally ignored (word access)
  /* verilator lint_off UNUSEDSIGNAL */
  function automatic logic addr_in_range(input logic [ADDR_WIDTH-1:0] addr);
    return (32'(addr[ADDR_WIDTH-1:ADDR_LSB]) < NUM_REGS);
  endfunction

  function automatic logic [IDX_W-1:0] addr_to_idx(input logic [ADDR_WIDTH-1:0] addr);
    return addr[ADDR_LSB +: IDX_W];
  endfunction
  /* verilator lint_on UNUSEDSIGNAL */

  // ---------------------------------------------------------------------------
  // Write path
  // ---------------------------------------------------------------------------
  logic                  aw_full, w_full;
  logic [ADDR_WIDTH-1:0] awaddr_q;
  logic [DATA_WIDTH-1:0] wdata_q;
  logic [STRB_WIDTH-1:0] wstrb_q;

  logic aw_hs, w_hs, b_hs, do_write;

  assign s_axil_awready = !aw_full;
  assign s_axil_wready  = !w_full;

  assign aw_hs    = s_axil_awvalid && s_axil_awready;
  assign w_hs     = s_axil_wvalid  && s_axil_wready;
  assign b_hs     = s_axil_bvalid  && s_axil_bready;
  // Commit when both address and data are held and the B channel is free
  assign do_write = aw_full && w_full && (!s_axil_bvalid || s_axil_bready);

  // Control (reset)
  always_ff @(posedge aclk) begin
    if (!aresetn) begin
      aw_full       <= 1'b0;
      w_full        <= 1'b0;
      s_axil_bvalid <= 1'b0;
      s_axil_bresp  <= RESP_OKAY;
    end else begin
      if (aw_hs) aw_full <= 1'b1;
      if (w_hs)  w_full  <= 1'b1;
`ifdef BUG_BVALID_DROP
      if (s_axil_bvalid) s_axil_bvalid <= 1'b0;
`else
      if (b_hs)  s_axil_bvalid <= 1'b0;
`endif
      if (do_write) begin
        aw_full       <= 1'b0;
        w_full        <= 1'b0;
        s_axil_bvalid <= 1'b1;
        s_axil_bresp  <= addr_in_range(awaddr_q) ? RESP_OKAY : RESP_SLVERR;
      end
    end
  end

  // Datapath (no reset needed)
  always_ff @(posedge aclk) begin
    if (aw_hs) awaddr_q <= s_axil_awaddr;
    if (w_hs) begin
      wdata_q <= s_axil_wdata;
      wstrb_q <= s_axil_wstrb;
    end
  end

  // Register file update
  always_ff @(posedge aclk) begin
    if (!aresetn) begin
      for (int i = 0; i < NUM_REGS; i++) regs[i] <= '0;
    end else if (do_write && addr_in_range(awaddr_q)) begin
      for (int b = 0; b < STRB_WIDTH; b++) begin
`ifdef BUG_WSTRB_IGNORED
        regs[addr_to_idx(awaddr_q)][b*8 +: 8] <= wdata_q[b*8 +: 8];
`else
        if (wstrb_q[b]) regs[addr_to_idx(awaddr_q)][b*8 +: 8] <= wdata_q[b*8 +: 8];
`endif
      end
    end
  end

  // ---------------------------------------------------------------------------
  // Read path
  // ---------------------------------------------------------------------------
  logic ar_hs;

  assign s_axil_arready = !s_axil_rvalid || s_axil_rready;
  assign ar_hs          = s_axil_arvalid && s_axil_arready;

  always_ff @(posedge aclk) begin
    if (!aresetn) begin
      s_axil_rvalid <= 1'b0;
      s_axil_rresp  <= RESP_OKAY;
    end else if (ar_hs) begin
      s_axil_rvalid <= 1'b1;
      s_axil_rresp  <= addr_in_range(s_axil_araddr) ? RESP_OKAY : RESP_SLVERR;
    end else if (s_axil_rready) begin
      s_axil_rvalid <= 1'b0;
    end
  end

  always_ff @(posedge aclk) begin
    if (ar_hs) begin
      s_axil_rdata <= addr_in_range(s_axil_araddr) ? regs[addr_to_idx(s_axil_araddr)] : '0;
    end
`ifdef BUG_RDATA_UNSTABLE
    else if (s_axil_rvalid && !s_axil_rready) begin
      s_axil_rdata <= ~s_axil_rdata;
    end
`endif
  end

  // Unused inputs (AxPROT is accepted but not decoded)
  /* verilator lint_off UNUSEDSIGNAL */
  logic unused;
  assign unused = ^{s_axil_awprot, s_axil_arprot};
  /* verilator lint_on UNUSEDSIGNAL */

endmodule : axi4_lite_slave
