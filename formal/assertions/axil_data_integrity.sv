module axil_data_integrity #(
  parameter int ADDR_WIDTH = 8,
  parameter int DATA_WIDTH = 32,
  parameter int NUM_REGS   = 4
) (
  input logic                      aclk,
  input logic                      aresetn,

  // Write address channel
  input logic [ADDR_WIDTH-1:0]     s_axil_awaddr,
  input logic [2:0]                s_axil_awprot,
  input logic                      s_axil_awvalid,
  input logic                      s_axil_awready,

  // Write data channel
  input logic [DATA_WIDTH-1:0]     s_axil_wdata,
  input logic [DATA_WIDTH/8-1:0]   s_axil_wstrb,
  input logic                      s_axil_wvalid,
  input logic                      s_axil_wready,

  // Write response channel
  input logic [1:0]                s_axil_bresp,
  input logic                      s_axil_bvalid,
  input logic                      s_axil_bready,

  // Read address channel
  input logic [ADDR_WIDTH-1:0]     s_axil_araddr,
  input logic [2:0]                s_axil_arprot,
  input logic                      s_axil_arvalid,
  input logic                      s_axil_arready,

  // Read data channel
  input logic [DATA_WIDTH-1:0]     s_axil_rdata,
  input logic [1:0]                s_axil_rresp,
  input logic                      s_axil_rvalid,
  input logic                      s_axil_rready,

  input logic [DATA_WIDTH-1:0]     sym_reg,
  input logic [$clog2(NUM_REGS)-1:0] sym_addr
);

localparam logic [1:0] RESP_OKAY   = 2'b00;

localparam int STRB_WIDTH = DATA_WIDTH / 8;
localparam int ADDR_LSB   = $clog2(STRB_WIDTH);

logic ar_handshake;
assign ar_handshake = s_axil_arvalid && s_axil_arready;

// Data integrity assertion
property p_data_integrity;
    // a read from the correct address
    ar_handshake && (sym_addr == (s_axil_araddr >> ADDR_LSB))
    // will return the value from the write
    |=> s_axil_rdata == $past(sym_reg,1) && s_axil_rresp == RESP_OKAY && s_axil_rvalid;

endproperty
a_data_integrity: assert property (@(posedge aclk) disable iff (!aresetn) p_data_integrity);

endmodule
