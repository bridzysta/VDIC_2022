/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
module coverage(tinyalu_bfm bfm);
import tinyalu_pkg::*;
	
//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------
covergroup operations_cov;
  option.name = "cg_operations";

  //TODO use typedefs here and cast it to
  commands : coverpoint bfm.command[8:1] iff(!bfm.enable_n){
    bins A1_CMD_NOP          = {8'b00000000};
    bins A1_CMD_AND          = {8'b00000001};
    bins A1_CMD_OR           = {8'b00000010};
    bins A1_CMD_XOR          = {8'b00000011};
    bins A1_CMD_ADD          = {8'b00010000};
    bins A1_CMD_SUB          = {8'b00100000};
    bins A1_invalid_commands = {[8'h00 : 8'hff]}
           with (!(item inside {8'b00000000, 8'b00000001, 8'b00000010, 8'b00000011, 8'b00010000, 8'b00100000}));
  }
endgroup

covergroup data_cov;
  option.name = "cg_data";

  number_of_sent_data_packets : coverpoint bfm.data_fifo.size() iff(!bfm.enable_n){
    bins B1_zero_data_packets                = {0};
    bins B2_correct_number_of_data_packets[] = {[1:9]};
  }

  input_data : coverpoint bfm.sent_data iff(!bfm.enable_n){
    bins B3_only_ones	= {8'hff};
    bins B4_only_zeros  = {8'h00};
    bins B5_others    	= {[8'h01 : 8'hfe]};
    bins B6_two_zeros 	= (8'h00 [*2]);
    bins B7_two_ones  	= (8'hff [*2]);
  }

endgroup

operations_cov    operations_c;
data_cov          data_c;

initial begin : coverage
  operations_c    = new();
  data_c          = new();
	//TODO we should wait here for some time in case of protection
  forever begin : sample_cov
        @(posedge bfm.clk);
        if(!bfm.enable_n) begin
            operations_c.sample();
            data_c.sample();
        end
  end
end : coverage

endmodule : coverage





