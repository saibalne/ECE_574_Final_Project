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

  logic aw_hs, w_hs, b_hs, ar_hs, r_hs;
  assign aw_hs = s_axil_awvalid && s_axil_awready;
  assign w_hs  = s_axil_wvalid && s_axil_wready;
  assign b_hs  = s_axil_bvalid && s_axil_bready;
  assign ar_hs = s_axil_arvalid && s_axil_arready;
  assign r_hs  = s_axil_rvalid && s_axil_rready;

  // Cover properties for AXI4-Lite interface
  // ============================ Handshake signals ============================
  // cover that a AW transfer occurs
  cover_aw_transfer: cover property (@(posedge aclk) disable iff(!aresetn) aw_hs);
  // cover that a W transfer occurs
  cover_w_transfer: cover property (@(posedge aclk) disable iff(!aresetn) w_hs);
  // Cover that a write transaction occurs
  cover_write_transaction: cover property (@(posedge aclk) disable iff(!aresetn) aw_hs && w_hs);
  // cover that response is valid
  cover_b_valid: cover property (@(posedge aclk) disable iff(!aresetn) b_hs);
  // Cover that a read transaction occurs
  cover_read_transaction: cover property (@(posedge aclk) disable iff(!aresetn) ar_hs);
  // Cover that a read response occurs
  cover_read_response: cover property (@(posedge aclk) disable iff(!aresetn) r_hs);



  // ============================ Transaction sequences ============================
  // Cover that a read trnasaction, followed by a read response occurs
  cover_read_read_response: cover property (@(posedge aclk) disable iff(!aresetn) ar_hs ##[1:$] r_hs);

  // Cover that a write transaction, followed by a write response occurs
  cover_write_write_response: cover property (@(posedge aclk) disable iff(!aresetn) aw_hs && w_hs ##[1:$] b_hs);
  
  // Cover that a write transaction, followed by a read transaction occurs
  cover_write_read_transaction: cover property (@(posedge aclk) disable iff(!aresetn) (aw_hs && w_hs) ##[1:$] (ar_hs && r_hs));

  // cover that a write and read trasaction occurs in the same clock cycle on same address
  cover_write_read_same_address: cover property (@(posedge aclk) disable iff(!aresetn) (aw_hs && w_hs && ar_hs) && (s_axil_awaddr == s_axil_araddr));  

  // cover that a write and read trasaction occurs in the same clock cycle on different address
  cover_write_read_different_address: cover property (@(posedge aclk) disable iff(!aresetn) (aw_hs && w_hs && ar_hs) && (s_axil_awaddr != s_axil_araddr));  

  // cover that a write followed by a read occurs on the same address
  cover_write_read_same_address_sequence: cover property (@(posedge aclk) disable iff(!aresetn) 
    logic [ADDR_WIDTH-1:0] addr; 
    (aw_hs ,addr = s_axil_awaddr) 
    ##[1:$] 
    (ar_hs && (s_axil_araddr == addr))
  );

  // cover that a write followed by a read occurs on the same address on same clock cycle
  cover_write_read_same_address_same_cycle: cover property (@(posedge aclk) disable iff(!aresetn) 
    logic [ADDR_WIDTH-1:0] addr; 
    (aw_hs ,addr = s_axil_awaddr) 
    ##[0:$] 
    (ar_hs && (s_axil_araddr == addr))
  );


  // cover that a write followed by a read occur on same address, and the read data is equal to the write data
  cover_write_read_data_match: cover property (@(posedge aclk) disable iff(!aresetn) 
    logic [ADDR_WIDTH-1:0] addr; logic [DATA_WIDTH-1:0] data; 
    (aw_hs && s_axil_awaddr != 0 ,addr = s_axil_awaddr)
    ##[0:$] (w_hs ,data = s_axil_wdata)
    ##[1:$] 
    (ar_hs && (s_axil_araddr == addr)
    ##[1:$]
    (r_hs && (s_axil_rdata == data)))
  ); 







endmodule