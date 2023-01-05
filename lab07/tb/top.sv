module top;
import uvm_pkg::*;
`include "uvm_macros.svh"
import alu_pkg::*;
`include "alu_macros.svh"

vdic_dut_2022 DUT (.clk(bfm.clk), .rst_n(bfm.rst_n), .din(bfm.din),
    .enable_n(bfm.enable_n), .dout(bfm.dout), .dout_valid(bfm.dout_valid));

alu_bfm bfm();
	
initial begin
    uvm_config_db #(virtual alu_bfm)::set(null, "*", "bfm", bfm);
    run_test();
end
	
endmodule : top
