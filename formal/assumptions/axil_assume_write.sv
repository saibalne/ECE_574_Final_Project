module axil_assume_write#(parameter int ADDR_WIDTH = 8,
  parameter int DATA_WIDTH = 32,
  parameter int NUM_REGS   = 4)(
    input  logic                      aclk,
    input  logic                      aresetn,
    // Write address channel
    input  logic [ADDR_WIDTH-1:0]     s_axil_awaddr,
    input  logic [2:0]                s_axil_awprot,       
    input  logic                      s_axil_awvalid,
    // Write data channel
    input  logic [DATA_WIDTH-1:0]     s_axil_wdata,
    input  logic [DATA_WIDTH/8-1:0]   s_axil_wstrb,
    input  logic                      s_axil_wvalid,
    // Write response channel
    input  logic                      s_axil_bready,
 

  );

  // AW channel assumptions
  // Assume that the address is aligned to the data width
  
  // Assume that the address is within the range of the registers


endmodule