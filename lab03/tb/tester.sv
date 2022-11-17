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
module tester(tinyalu_bfm bfm);
    
import tinyalu_pkg::*;

//------------------------------------------------------------------------------
// get_command function
//------------------------------------------------------------------------------

function automatic byte get_command();
    bit [2:0] command_choice;
    command_choice = 3'($random);
    case (command_choice)
        3'b000 : return CMD_NOP;
        3'b001 : return CMD_AND;
        3'b010 : return CMD_OR;
        3'b011 : return CMD_XOR;
        3'b100 : return CMD_ADD;
        3'b101 : return CMD_SUB;
	    default: return 8'($random);
    endcase // case (command_choice)
endfunction : get_command

//------------------------------------------------------------------------------
// get_data function
//------------------------------------------------------------------------------

function byte get_data();
    bit [1:0] zero_ones;
    zero_ones = 2'($random);
    if (zero_ones == 2'b00)
        return 8'h00;
    else if (zero_ones == 2'b11)
        return 8'hFF;
    else
        return 8'($random);
endfunction : get_data

//------------------------------------------------------------------------------
// calc_parity function
//------------------------------------------------------------------------------

function bit calc_parity(bit [8:0] word);
  return ^word;
endfunction : calc_parity

//------------------------------------------------------------------------------
// get_control_word function
//------------------------------------------------------------------------------

function bit [9:0] get_control_word();
  automatic byte cmd = get_command();
  return {1'b1, cmd, calc_parity({1'b1, cmd})};
endfunction : get_control_word

//------------------------------------------------------------------------------
// get_data_word function
//------------------------------------------------------------------------------

function bit [9:0] get_data_word();
  automatic byte data = get_data();
  return {1'b0, data, calc_parity({1'b0, data})};
endfunction : get_data_word

//------------------------------------------------------------------------------
// fill_data_fifo function
//------------------------------------------------------------------------------

function void fill_data_fifo();
  bit [3:0] number_of_data;
  number_of_data = $urandom_range(9, 2);
  repeat(number_of_data) bfm.data_fifo.push_front(get_data_word());
endfunction

//------------------------------------------------------------------------------
// Tester main
//------------------------------------------------------------------------------

initial begin : tester
  bfm.enable_n = 1'b1;
  bfm.reset_alu();
  repeat(100) begin
    fill_data_fifo();
    bfm.command = get_control_word();
    foreach(bfm.data_fifo[i]) begin
      bfm.sent_data = bfm.data_fifo[i][8:1];
      bfm.send_word(bfm.data_fifo[i]);
    end
    bfm.send_word(bfm.command);
    @(negedge bfm.clk);
    bfm.enable_n = 1'b1;
    wait(bfm.dout_valid);
    //TODO make some task for below six commands 
    bfm.receive_word(bfm.received_status);
    bfm.receive_word(bfm.received_data[0]);
    bfm.receive_word(bfm.received_data[1]);
    bfm.result_fifo.push_front({bfm.received_status, bfm.received_data[0], bfm.received_data[1]});
    bfm.expected_fifo.push_front(scoreboard_i.get_expected(bfm.command));
    bfm.data_fifo = {};
  end
  $finish;
end : tester


endmodule : tester
