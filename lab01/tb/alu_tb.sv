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

 History:
 2021-10-05 RSz, AGH UST - test modified to send all the data on negedge clk
 and check the data on the correct clock edge (covergroup on posedge
 and scoreboard on negedge). Scoreboard and coverage removed.
 */
module alu_tb;

//------------------------------------------------------------------------------
// Type definitions
//------------------------------------------------------------------------------

typedef enum bit[7:0] {
  CMD_NOP = 8'b00000000,
  CMD_AND = 8'b00000001,
  CMD_OR  = 8'b00000010,
  CMD_XOR = 8'b00000011,
  CMD_ADD = 8'b00010000,
  CMD_SUB = 8'b00100000
} command_t;

typedef enum bit[7:0] {
  S_NO_ERROR             = 8'b00000000,
  S_MISSING_DATA         = 8'b00000001,
  S_DATA_STACK_OVERFLOW  = 8'b00000010,
  S_OUTPUT_FIFO_OVERFLOW = 8'b00000100,
  S_DATA_PARITY_ERROR    = 8'b00100000,
  S_COMMAND_PARITY_ERROR = 8'b01000000,
  S_INVALID_COMMAND      = 8'b10000000
} status_t;

typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

typedef enum {
  COLOR_BOLD_BLACK_ON_GREEN,
  COLOR_BOLD_BLACK_ON_RED,
  COLOR_BOLD_BLACK_ON_YELLOW,
  COLOR_BOLD_BLUE_ON_WHITE,
  COLOR_BLUE_ON_WHITE,
  COLOR_DEFAULT
} print_color_t;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------
bit         clk;
bit         rst_n;
bit         enable_n;
bit         din;
wire        dout;
wire        dout_valid;
bit [9:0] 	data_fifo[$];
bit [9:0] 	command;
bit [9:0] 	received_status;
bit [9:0] 	received_data[2];
bit [3*9:0] result;
bit [3*9:0] expected;
	
test_result_t test_result = TEST_PASSED;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

vdic_dut_2022 DUT(.clk, .rst_n, .enable_n, .din, .dout, .dout_valid);

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen_blk
  clk = 0;
  forever begin : clk_frv_blk
    #10;
    clk = ~clk;
  end
end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

function automatic byte get_command();
    bit [2:0] command_choice;
    command_choice = 3'($random);
    case (command_choice)
        //3'b000 : return CMD_NOP;
        3'b001 : return CMD_AND;
        //3'b010 : return CMD_OR;
        //3'b011 : return CMD_XOR;
        3'b100 : return CMD_ADD;
        //3'b101 : return CMD_SUB;
        3'b110 : return CMD_AND;
        3'b111 : return CMD_ADD;
	    default: return 8'($random);
    endcase // case (command_choice)
endfunction : get_command

//---------------------------------
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

//---------------------------------

function bit calc_parity(bit [8:0] word);
  return ^word;
endfunction : calc_parity

//---------------------------------

function bit [9:0] get_control_word();
  automatic byte cmd = get_command();
  return {1'b1, cmd, calc_parity({1'b1, cmd})};
endfunction : get_control_word

//---------------------------------

function bit [9:0] get_data_word();
  automatic byte data = get_data();
  return {1'b0, data, calc_parity({1'b0, data})};
endfunction : get_data_word

//---------------------------------

function void fill_data_fifo();
  bit [3:0] number_of_data;
  number_of_data = $urandom_range(8, 3);
  repeat(number_of_data) data_fifo.push_front(get_data_word());
endfunction
//---------------------------------
// Send task

task send_word(bit [9:0] word);
  repeat(10) begin
    @(negedge clk);
    enable_n = 1'b0;
    din = word[9];
    word = {word[8:0], 1'b0};
  end
endtask : send_word

//---------------------------------
// Receive tasks

task receive_word(output bit [9:0] received_word);
  repeat(10) begin
    @(posedge clk);
    if(dout_valid) begin
      received_word = {received_word[8:0], dout};
    end
  end
endtask : receive_word

//------------------------
// Tester main

initial begin : tester
  reset_alu();
  repeat(100) begin
    fill_data_fifo();
    command = get_control_word();
    foreach(data_fifo[i]) begin
      send_word(data_fifo[i]);
    end
    send_word(command);
    @(negedge clk);
    enable_n = 1'b1;
    wait(dout_valid);
    receive_word(received_status);
    receive_word(received_data[0]);
    receive_word(received_data[1]);
    result = {received_status, received_data[0], received_data[1]};
    expected = get_expected(command);
    assert(result === expected) begin
    end
    else begin
      $display("Test FAILED for \ncommand: %b", command);
      foreach(data_fifo[i])
        $display("%0d data: %b", i, data_fifo[i]);
      $display("Expected: %b", expected);
      $display("Received: %b", result);
      test_result = TEST_FAILED;
    end
    data_fifo = {};
  end
  $finish;
end : tester

final begin : finish_of_the_test
  print_test_result(test_result);
end : finish_of_the_test

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------

task reset_alu();
  @(negedge clk);
  rst_n = 1'b0;
  @(negedge clk);
  rst_n = 1'b1;
  enable_n = 1'b1;
endtask : reset_alu

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

function automatic logic [3*9:0] get_expected(bit [9:0] cmd_word);
  status_t expected_status;
  automatic logic [15:0] expected_data = 16'b0;
  command_t cmd;
  if($cast(cmd, cmd_word[8:1])) begin
    case(cmd)
      //CMD_NOP :
      CMD_AND : begin
        expected_data = data_fifo[data_fifo.size()-1][8:1] & data_fifo[data_fifo.size()-2][8:1];
        expected_status = S_NO_ERROR;
      end
      //CMD_OR  :
      //CMD_XOR :
      CMD_ADD : begin
        foreach(data_fifo[i])
          expected_data = data_fifo[i][8:1] + expected_data;
        expected_status = S_NO_ERROR;
      end
      //CMD_SUB :
      default : begin
         expected_data = 16'b0;
         expected_status = S_INVALID_COMMAND;
      end
    endcase
  end
  else begin
    expected_data = 16'b0;
    expected_status = S_INVALID_COMMAND;
  end

  return {1'b1, expected_status,     calc_parity({1'b1, expected_status}),
          1'b0, expected_data[15:8], calc_parity({1'b0, expected_data[15:8]}),
          1'b0, expected_data[ 7:0], calc_parity({1'b0, expected_data[ 7:0]})};
endfunction

//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------

// used to modify the color of the text printed on the terminal
function void set_print_color (print_color_t c);
  string ctl;
  case(c)
    COLOR_BOLD_BLACK_ON_GREEN  : ctl = "\033\[1;30m\033\[102m";
    COLOR_BOLD_BLACK_ON_RED    : ctl = "\033\[1;30m\033\[101m";
    COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
    COLOR_BOLD_BLUE_ON_WHITE   : ctl = "\033\[1;34m\033\[107m";
    COLOR_BLUE_ON_WHITE        : ctl = "\033\[0;34m\033\[107m";
    COLOR_DEFAULT              : ctl = "\033\[0m\n";
    default : begin
      $error("set_print_color: bad argument");
      ctl = "";
    end
  endcase
  $write(ctl);
endfunction

function void print_test_result (test_result_t r);
  if(r == TEST_PASSED) begin
    set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
    $write ("-----------------------------------\n");
    $write ("----------- Test PASSED -----------\n");
    $write ("-----------------------------------");
    set_print_color(COLOR_DEFAULT);
    $write ("\n");
  end
  else begin
    set_print_color(COLOR_BOLD_BLACK_ON_RED);
    $write ("-----------------------------------\n");
    $write ("----------- Test FAILED -----------\n");
    $write ("-----------------------------------");
    set_print_color(COLOR_DEFAULT);
    $write ("\n");
  end
endfunction


endmodule : alu_tb
