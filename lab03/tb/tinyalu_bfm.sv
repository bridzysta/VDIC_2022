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
interface tinyalu_bfm;
import tinyalu_pkg::*;

bit         clk;
bit         rst_n;
bit         enable_n;
bit         din;
wire        dout;
wire        dout_valid;
bit [9:0] 	data_fifo[$];
bit [9:0] 	command;
bit [7:0] 	sent_data;	
bit [9:0] 	received_status;
bit [9:0] 	received_data[2];
bit [3*9:0] result_fifo[$];
bit [3*9:0] expected_fifo[$];

modport tlm (import reset_alu, send_word, receive_word);
    
//------------------------------------------------------------------------------
// clock generator  
//------------------------------------------------------------------------------
initial begin
    clk = 0;
    forever begin
        #10;
        clk = ~clk;
    end
end

//------------------------------------------------------------------------------
// reset_alu
//------------------------------------------------------------------------------

task reset_alu();
  @(negedge clk);
  rst_n = 1'b0;
  @(negedge clk);
  rst_n = 1'b1;
  enable_n = 1'b1;
endtask : reset_alu

//------------------------------------------------------------------------------
// Send task
//------------------------------------------------------------------------------

task send_word(bit [9:0] word);
  repeat(10) begin
    @(negedge clk);
    enable_n = 1'b0;
    din = word[9];
    word = word << 1;
  end
endtask : send_word

//------------------------------------------------------------------------------
// Receive task
//------------------------------------------------------------------------------

task receive_word(output bit [9:0] received_word);
  repeat(10) begin
    @(negedge clk);
    if(dout_valid) begin
      received_word = {received_word[8:0], dout};
    end
  end
endtask : receive_word



endinterface : tinyalu_bfm


