module axil_cover#(parameter int ADDR_WIDTH = 8,
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


  // Cover properties for AXI4-Lite interface
  // cover that a AW transfer occurs
  cover_aw_transfer: cover property (@(posedge aclk) disable iff(!aresetn) s_axil_awvalid && s_axil_awready);
  // cover that a W transfer occurs
  cover_w_transfer: cover property (@(posedge aclk) disable iff(!aresetn) s_axil_wvalid && s_axil_wready);
  // Cover that a write transaction occurs
  cover_write_transaction: cover property (@(posedge aclk) disable iff(!aresetn) s_axil_awvalid && s_axil_awready && s_axil_wvalid && s_axil_wready);
  // cover that response is valid
  cover_b_valid: cover property (@(posedge aclk) disable iff(!aresetn) s_axil_bvalid && s_axil_bready);
  // Cover that a read transaction occurs
  cover_read_transaction: cover property (@(posedge aclk) disable iff(!aresetn) s_axil_arvalid && s_axil_arready);
  // Cover that a read response occurs
  cover_read_response: cover property (@(posedge aclk) disable iff(!aresetn) s_axil_rvalid && s_axil_rready);

  



  



endmodule