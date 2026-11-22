module axil_assert_write#(parameter int ADDR_WIDTH = 8,
  parameter int DATA_WIDTH = 32,
  parameter int NUM_REGS   = 4)(

    input  logic                      aclk,
    input  logic                      aresetn,
    // Write address channel
    input  logic [ADDR_WIDTH-1:0]     s_axil_awaddr,
    input  logic [2:0]                s_axil_awprot,       
    input  logic                      s_axil_awvalid,
    input logic                       s_axil_awready,
    // Write data channel
    input  logic [DATA_WIDTH-1:0]     s_axil_wdata,
    input  logic [DATA_WIDTH/8-1:0]   s_axil_wstrb,
    input  logic                      s_axil_wvalid,
    input logic                       s_axil_wready,
    // Write response channel
    input logic [1:0]                 s_axil_bresp,
    input logic                       s_axil_bvalid,
    input  logic                      s_axil_bready,
  );

  // AW channel assertions
  // Assert that the address is aligned to the data width
  assert property (@(posedge aclk) disable iff (!aresetn) s_axil_awvalid |-> (s_axil_awaddr % (DATA_WIDTH/8) == 0));

  // Assert that the address is within the range of the registers
  assert property (@(posedge aclk) disable iff (!aresetn) s_axil_awvalid |-> (s_axil_awaddr < NUM_REGS*DATA_WIDTH/8));

  // Assert that the address and protection signals are stable when awvalid is high and awready is low
  assert property (@(posedge aclk) disable iff(!aresetn) s_axil_awvalid && !s_axil_awready |=> s_axil_awvalid && $stable({s_axil_awaddr,s_axil_awprot}));

  // Assert that awready will eventually be high after awvalid is high
  assert property (@(posedge aclk) disable iff(!aresetn) s_axil_awvalid |-> s_eventually(s_axil_awready));

  // W channel assertions
  // Assert that the data and strobe signals are stable when wvalid is high and wready is low
  assert property (@(posedge aclk) disable iff(!aresetn) s_axil_wvalid && !s_axil_wready |=> s_axil_wvalid && $stable({s_axil_wdata,s_axil_wstrb}));

  // Assert that the write strobe is not zero when wvalid is high, if wstrb is zero, it means that no bytes are being written, which is not a valid operation
  assert property (@(posedge aclk) disable iff(!aresetn) s_axil_wvalid |-> (s_axil_wstrb != 0));
  
  // Assert that wready will eventually be high after wvalid is high
  assert property (@(posedge aclk) disable iff(!aresetn) s_axil_wvalid |-> s_eventually(s_axil_wready));


  // B channel assertions
  // Assert that bready will eventually be high after bvalid is high
  assert property (@(posedge aclk) disable iff(!aresetn) s_axil_bvalid |-> s_eventually(s_axil_bready));

  // Assert that the write response is either OKAY or SLVERR
  assert property (@(posedge aclk) disable iff(!aresetn) s_axil_bvalid |-> (s_axil_bresp == 2'b00 || s_axil_bresp == 2'b10));

  // Assert that the write response is stable when bvalid is high and bready is low
  assert property (@(posedge aclk) disable iff(!aresetn) s_axil_bvalid && !s_axil_bready |-> s_axil_bvalid && $stable(s_axil_bresp));


  // Assert that if awvalid and wvalid are high, then bvalid will eventually be high
  assert property (@(posedge aclk) disable iff(!aresetn) (s_axil_awvalid && s_axil_awready) |=> s_eventually(s_axil_bvalid && s_axil_bready));

  // Assert that if wvalid and wready are high, then bvalid will eventually be high
  assert property (@(posedge aclk) disable iff(!aresetn) (s_axil_wvalid && s_axil_wready) |=> s_eventually(s_axil_bvalid && s_axil_bready));


endmodule