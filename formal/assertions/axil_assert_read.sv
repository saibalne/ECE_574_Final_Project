module axil_assert_write#(parameter int ADDR_WIDTH = 8,
  parameter int DATA_WIDTH = 32,
  parameter int NUM_REGS   = 4)(

    input  logic                      aclk,
    input  logic                      aresetn,
    // Write address channel
    input  logic [ADDR_WIDTH-1:0]     s_axil_awaddr,
    input  logic [2:0]                s_axil_awprot,       
    input  logic                      s_axil_awvalid,
    input logic                      s_axil_awready,
    // Write data channel
    input  logic [DATA_WIDTH-1:0]     s_axil_wdata,
    input  logic [DATA_WIDTH/8-1:0]   s_axil_wstrb,
    input  logic                      s_axil_wvalid,
    input logic                      s_axil_wready,
    // Write response channel
    input logic [1:0]                s_axil_bresp,
    input logic                      s_axil_bvalid,
    input  logic                      s_axil_bready,
    // Read address channel
    input  logic [ADDR_WIDTH-1:0]     s_axil_araddr,
    input  logic [2:0]                s_axil_arprot,
    input  logic                      s_axil_arvalid,
    input logic                      s_axil_arready,
    // Read data channel
    input logic [DATA_WIDTH-1:0]     s_axil_rdata,
    input logic [1:0]                s_axil_rresp,
    input logic                      s_axil_rvalid,
    input  logic                      s_axil_rready
  );


endmodule