module axil_assume_read#(parameter int ADDR_WIDTH = 8,
  parameter int DATA_WIDTH = 32,
  parameter int NUM_REGS   = 4)(
    input  logic                      aclk,
    input  logic                      aresetn,
   
    // Read address channel
    input  logic [ADDR_WIDTH-1:0]     s_axil_araddr,
    input  logic [2:0]                s_axil_arprot,
    input  logic                      s_axil_arvalid,
    input  logic                      s_axil_arready,
    // Read data channel
    input logic [DATA_WIDTH-1:0]      s_axil_rdata,
    input logic [1:0]                 s_axil_rresp,
    input logic                       s_axil_rvalid,

    input  logic                      s_axil_rready

  );

// Address is stable while valid
w_read_address_stable: assume property (@(posedge aclk) disable iff (!aresetn) s_axil_arvalid && !s_axil_arready |=> s_axil_arvalid && $stable(s_axil_araddr));

// Valid address is valid until handshake occurs
w_read_valid_stable: assume property (@(posedge aclk) disable iff (!aresetn) s_axil_arvalid && !s_axil_arready |=> s_axil_arvalid);


// Master will eventually accept a handshake
w_read_accept_handshake: assume property (@(posedge aclk) disable iff (!aresetn) s_axil_rvalid |-> s_eventually s_axil_rready);

// Inputs are not unknown
w_read_inputs_not_unknown: assume property (@(posedge aclk) disable iff (!aresetn) 
                           !$isunknown({s_axil_arvalid,s_axil_arready,s_axil_rvalid,s_axil_rready}));

	`ifdef OVER_CONSTRAINT
		// Assume that the address is aligned to the data width
		w_read_addr_aligned: assume property (@(posedge aclk) disable iff (!aresetn) s_axil_arvalid |-> (s_axil_araddr % (DATA_WIDTH/8) == 0));

	`endif
endmodule
