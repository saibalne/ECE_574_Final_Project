
// SMALL=3/16/2, MEDIUM=5/32/4, FULL=8/32/4 (ADDR/DATA/NUM_REGS)
`ifdef SMALL
	//small
    `define ADDR_WIDTH 3
    `define DATA_WIDTH 16
    `define NUM_REGS   2
`elsif  MEDIUM
	//Medium
	`define ADDR_WIDTH 5
    `define DATA_WIDTH 32
    `define NUM_REGS   4
`else
	// Full
	`define ADDR_WIDTH 32
    `define DATA_WIDTH 32
    `define NUM_REGS   1024
`endif

module axil_fv_top#(parameter int ADDR_WIDTH = `ADDR_WIDTH,
  parameter int DATA_WIDTH = `DATA_WIDTH,
  parameter int NUM_REGS   = `NUM_REGS)(

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
  input  logic                      s_axil_rready,
    
  input logic [$clog2(NUM_REGS)-1:0] sym_addr
  );
    // Shadow register logic
    logic [DATA_WIDTH-1:0]     sym_reg;
    assign sym_reg = dut.regs[sym_addr];
    // Shadow register address should stay constant
    assume property (@(posedge aclk) ##1 sym_addr == $past(sym_addr));

    axi4_lite_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) dut (
        .aclk(aclk),
        .aresetn(aresetn),
    
        .s_axil_awaddr(s_axil_awaddr),
        .s_axil_awprot(s_axil_awprot),
        .s_axil_awvalid(s_axil_awvalid),
        .s_axil_awready(s_axil_awready),
    
        .s_axil_wdata(s_axil_wdata),
        .s_axil_wstrb(s_axil_wstrb),
        .s_axil_wvalid(s_axil_wvalid),
        .s_axil_wready(s_axil_wready),
    
        .s_axil_bresp(s_axil_bresp),
        .s_axil_bvalid(s_axil_bvalid),
        .s_axil_bready(s_axil_bready),
    
        .s_axil_araddr(s_axil_araddr),
        .s_axil_arprot(s_axil_arprot),
        .s_axil_arvalid(s_axil_arvalid),
        .s_axil_arready(s_axil_arready),
    
        .s_axil_rdata(s_axil_rdata),
        .s_axil_rresp(s_axil_rresp),
        .s_axil_rvalid(s_axil_rvalid),
        .s_axil_rready(s_axil_rready)
    );

    axil_assert_write #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) write_assertions (
        .aclk(aclk),
        .aresetn(aresetn),
    
        .s_axil_awaddr(s_axil_awaddr),
        .s_axil_awprot(s_axil_awprot),
        .s_axil_awvalid(s_axil_awvalid),
        .s_axil_awready(s_axil_awready),
    
        .s_axil_wdata(s_axil_wdata),
        .s_axil_wstrb(s_axil_wstrb),
        .s_axil_wvalid(s_axil_wvalid),
        .s_axil_wready(s_axil_wready),
    
        .s_axil_bresp(s_axil_bresp),
        .s_axil_bvalid(s_axil_bvalid),
        .s_axil_bready(s_axil_bready)
    );

    axil_assert_read #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) read_assertions (
        .aclk(aclk),
        .aresetn(aresetn),
    
        .s_axil_araddr(s_axil_araddr),
        .s_axil_arprot(s_axil_arprot),
        .s_axil_arvalid(s_axil_arvalid),
        .s_axil_arready(s_axil_arready),
    
        .s_axil_rdata(s_axil_rdata),
        .s_axil_rresp(s_axil_rresp),
        .s_axil_rvalid(s_axil_rvalid),
        .s_axil_rready(s_axil_rready)
    );

    axil_cover #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) cover_properties (
        .aclk(aclk),
        .aresetn(aresetn),
    
        .s_axil_awaddr(s_axil_awaddr),
        .s_axil_awprot(s_axil_awprot),
        .s_axil_awvalid(s_axil_awvalid),
        .s_axil_awready(s_axil_awready),
    
        .s_axil_wdata(s_axil_wdata),
        .s_axil_wstrb(s_axil_wstrb),
        .s_axil_wvalid(s_axil_wvalid),
        .s_axil_wready(s_axil_wready),
    
        .s_axil_bresp(s_axil_bresp),
        .s_axil_bvalid(s_axil_bvalid),
        .s_axil_bready(s_axil_bready),
    
        .s_axil_araddr(s_axil_araddr),
        .s_axil_arprot(s_axil_arprot),
        .s_axil_arvalid(s_axil_arvalid),
        .s_axil_arready(s_axil_arready),
    
        .s_axil_rdata(s_axil_rdata),
        .s_axil_rresp(s_axil_rresp),
        .s_axil_rvalid(s_axil_rvalid),
        .s_axil_rready(s_axil_rready)
    );
    
    axil_assume_write #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) write_assumptions (
        .aclk(aclk),
        .aresetn(aresetn),
    
        .s_axil_awaddr(s_axil_awaddr),
        .s_axil_awprot(s_axil_awprot),
        .s_axil_awvalid(s_axil_awvalid),
        .s_axil_awready(s_axil_awready),
    
        .s_axil_wdata(s_axil_wdata),
        .s_axil_wstrb(s_axil_wstrb),
        .s_axil_wvalid(s_axil_wvalid),
        .s_axil_wready(s_axil_wready),
    
        .s_axil_bresp(s_axil_bresp),
        .s_axil_bvalid(s_axil_bvalid),
        .s_axil_bready(s_axil_bready)
    );

    axil_assume_read #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) read_assumptions (
        .aclk(aclk),
        .aresetn(aresetn),
    
        .s_axil_araddr(s_axil_araddr),
        .s_axil_arprot(s_axil_arprot),
        .s_axil_arvalid(s_axil_arvalid),
        .s_axil_arready(s_axil_arready),
    
        .s_axil_rdata(s_axil_rdata),
        .s_axil_rresp(s_axil_rresp),
        .s_axil_rvalid(s_axil_rvalid),
        .s_axil_rready(s_axil_rready)
    );

    axil_data_integrity #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) data_integrity ( .* );
endmodule
