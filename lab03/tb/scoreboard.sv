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
 
// Last modified: 10-11-2022 by RSz, AGH UST

// NOTE: scoreboard uses bfm signals directly - this is a temporary solution
 
module scoreboard(tinyalu_bfm bfm);
    
import tinyalu_pkg::*;

//------------------------------------------------------------------------------
// local typdefs
//------------------------------------------------------------------------------
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
// local variables
//------------------------------------------------------------------------------

test_result_t test_result = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

function automatic logic [3*9:0] get_expected(bit [9:0] cmd_word);
  status_t expected_status;
  automatic logic [15:0] expected_data = 16'b0;
  command_t cmd;
  if($cast(cmd, cmd_word[8:1])) begin
    case(cmd)
      CMD_NOP : begin
	    expected_data = 16'b0;
	    expected_status = S_NO_ERROR; 
	  end
      CMD_AND : begin
        expected_data = bfm.data_fifo[bfm.data_fifo.size()-1][8:1] & bfm.data_fifo[bfm.data_fifo.size()-2][8:1];
        expected_status = S_NO_ERROR;
      end
      CMD_OR  : begin
		foreach(bfm.data_fifo[i])
        	expected_data = bfm.data_fifo[i][8:1] | expected_data;
		expected_status = S_NO_ERROR;	  
	  end
      CMD_XOR : begin
	    foreach(bfm.data_fifo[i])
        	expected_data = bfm.data_fifo[i][8:1] ^ expected_data;        
	    expected_status = S_NO_ERROR;	  
	  end
      CMD_ADD : begin
        foreach(bfm.data_fifo[i])
          expected_data += bfm.data_fifo[i][8:1];
        expected_status = S_NO_ERROR;
      end
      CMD_SUB : begin
	    expected_data[7:0] = bfm.data_fifo[0][8:1];
	    bfm.data_fifo.delete(0);
	    foreach(bfm.data_fifo[i])
        	expected_data -= bfm.data_fifo[i][8:1];
        expected_status = S_NO_ERROR;	  
	  end
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

  return {1'b1, expected_status,     tester_i.calc_parity({1'b1, expected_status}),
          1'b0, expected_data[15:8], tester_i.calc_parity({1'b0, expected_data[15:8]}),
          1'b0, expected_data[ 7:0], tester_i.calc_parity({1'b0, expected_data[ 7:0]})};
endfunction

//------------------------------------------------------------------------------
// data registering and checking
//------------------------------------------------------------------------------

always @(negedge bfm.clk) begin : scoreboard
  if(bfm.result_fifo.size() && bfm.expected_fifo.size()) begin
    bit [3*9:0] expected;
    bit [3*9:0] result;
    result = bfm.result_fifo.pop_back();
    expected = bfm.expected_fifo.pop_back();
    if(result === expected) begin
    end
    else begin
      $display("Test FAILED for \ncommand: %b", bfm.command);
      foreach(bfm.data_fifo[i])
        $display("%0d data: %b", i, bfm.data_fifo[i]);
      $display("Expected: %b", expected);
      $display("Received: %b", result);
      test_result <= TEST_FAILED;
    end
  end
end : scoreboard

//------------------------------------------------------------------------------
// used to modify the color printed on the terminal
//------------------------------------------------------------------------------

function void set_print_color ( print_color_t c );
    string ctl;
    case(c)        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
        COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
        COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
        COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
        COLOR_DEFAULT : ctl              = "\033\[0m\n";
        default : begin
            $error("set_print_color: bad argument");
            ctl                         = "";
        end
    endcase
    $write(ctl);
endfunction

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
function void print_test_result (test_result_t r);
    if(test_result == TEST_PASSED) begin
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

//------------------------------------------------------------------------------
// print the test result at the simulation end
//------------------------------------------------------------------------------
final begin : finish_of_the_test
    print_test_result(test_result);
end

endmodule : scoreboard






