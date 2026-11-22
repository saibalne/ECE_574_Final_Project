module axil_assume_write#(parameter int ADDR_WIDTH = 8,
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
    input  logic                      s_axil_bready,
    input logic [1:0]                s_axil_bresp,
    input logic                      s_axil_bvalid
 

  );

    // AW channel assumptions
    // Assume that the address is aligned to the data width
   addr_aligned_asm: assume property (@(posedge aclk) disable iff (!aresetn) s_axil_awvalid |-> (s_axil_awaddr % (DATA_WIDTH/8) == 0));
    // Assume that the address is within the range of the registers
    addr_in_range_asm: assume property (@(posedge aclk) disable iff (!aresetn) s_axil_awvalid |-> (s_axil_awaddr < NUM_REGS*DATA_WIDTH/8));

    // Assuming that the address and protection signals are stable when awvalid is high and awready is low
    aw_stable_asm: assume property (@(posedge aclk) disable iff(!aresetn) s_axil_awvalid && !s_axil_awready |=> s_axil_awvalid && $stable({s_axil_awaddr,s_axil_awprot}));

    // Assume that awready will eventually be high after awvalid is high
    aw_ready_eventually_asm: assume property (@(posedge aclk) disable iff(!aresetn) s_axil_awvalid |-> s_eventually(s_axil_awready));


    // W channel assumptions
    // Assuming that the data and strobe signals are stable when wvalid is high and wready is low
    w_stable_asm: assume property (@(posedge aclk) disable iff(!aresetn) s_axil_wvalid && !s_axil_wready |=> s_axil_wvalid && $stable({s_axil_wdata,s_axil_wstrb}));

    // assuming that the write strobe is not zero when wvalid is high, if wstrb is zero, it means that no bytes are being written, which is not a valid operation
    w_strb_nonzero_asm: assume property (@(posedge aclk) disable iff(!aresetn) s_axil_wvalid |-> (s_axil_wstrb != 0));

    // Assume that wready will eventually be high after wvalid is high
    w_ready_eventually_asm: assume property (@(posedge aclk) disable iff(!aresetn) s_axil_wvalid |-> s_eventually(s_axil_wready));

    // B channel assumptions
    b_ready_eventually_asm: assume property (@(posedge aclk) disable iff(!aresetn) s_axil_bvalid |-> s_eventually(s_axil_bready));

    // Assume that all the signals have known values
    known_asm: assume property (@(posedge aclk) $isunknown({s_axil_awaddr,s_axil_awprot,s_axil_awvalid,s_axil_wdata,s_axil_wstrb,s_axil_wvalid,s_axil_bready})==0);
   

    



endmodule       
