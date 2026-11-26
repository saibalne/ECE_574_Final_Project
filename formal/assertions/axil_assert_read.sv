module axil_assert_read#(parameter int ADDR_WIDTH = 8,
  parameter int DATA_WIDTH = 32,
  parameter int NUM_REGS   = 4)(

    input  logic                      aclk,
    input  logic                      aresetn,
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

// Address is both valid and has been received. Internal variable
logic ar_handshake;
assign ar_handshake = s_axil_arvalid && s_axil_arready;

// Read output is both valid and has been received. Internal variable
logic r_handshake;
assign r_handshake = s_axil_rvalid && s_axil_rready;

// Definitions of read operation responses
localparam logic [1:0] RESP_OKAY   = 2'b00;
localparam logic [1:0] RESP_SLVERR = 2'b10;

// Check to make sure the output data is valid when read handshake has ocurred (rvalid and rready)
a_read_data_valid: assert property (@(posedge aclk) disable iff (!aresetn) r_handshake |-> !$isunknown(s_axil_rdata));

// Check to make sure the output response is valid when read handshake has ocurred (rvalid and rready)
a_read_response_valid: assert property (@(posedge aclk) disable iff (!aresetn) r_handshake |-> !$isunknown(s_axil_rresp));

// If address is in range then result is OKAY
a_read_result_okay: assert property (@(posedge aclk) disable iff (!aresetn) (
                    s_axil_araddr < NUM_REGS*DATA_WIDTH/8) && ar_handshake |=> !s_axil_rvalid s_until (s_axil_rvalid && s_axil_rresp==RESP_OKAY));

// If address is out of range then result is SLVERR
a_read_result_err: assert property (@(posedge aclk) disable iff (!aresetn) (
                   s_axil_araddr >= NUM_REGS*DATA_WIDTH/8) && ar_handshake |=> !s_axil_rvalid s_until (s_axil_rvalid && s_axil_rresp==RESP_SLVERR));

// Valid data is held on the line until the master is ready
a_read_data_stable: assert property (@(posedge aclk) disable iff (!aresetn) s_axil_rvalid && !s_axil_rready |=> $stable(s_axil_rdata));

// Valid response is held on the line until the master is ready
a_read_response_stable: assert property (@(posedge aclk) disable iff (!aresetn) s_axil_rvalid && !s_axil_rready |=> $stable(s_axil_rresp));

// Valid is not deasserted until handshake occurs
a_read_valid_until_handshake: assert property (@(posedge aclk) disable iff (!aresetn) s_axil_rvalid && !s_axil_rready |=> s_axil_rvalid);

// Keep track of number of outstanding read requests
int outstanding;
always_ff @(posedge aclk) begin
    if (ar_handshake && !r_handshake)
        outstanding <= outstanding + 1;
    else if (r_handshake && !ar_handshake)
        outstanding <= outstanding - 1;
    if (!aresetn)
        outstanding <= 0;
end

// If there is a read response then there must have been an outstanding request
a_read_response_outstanding: assert property (@(posedge aclk) disable iff (!aresetn) s_axil_rvalid |-> outstanding > 0);

// Liveness properties
// Reads always complete
a_read_eventually_completes: assert property (@(posedge aclk) disable iff (!aresetn) ar_handshake |-> s_eventually s_axil_rvalid);

// Address is always accepted
a_read_address_eventually_accepted: assert property (@(posedge aclk) disable iff (!aresetn) s_axil_arvalid |-> s_eventually s_axil_arready);

endmodule
