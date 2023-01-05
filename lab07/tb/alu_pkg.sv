package alu_pkg;
	 
	import uvm_pkg::*;
    `include "uvm_macros.svh"
    
	//------------------------------------------------------------------------------
	// Type definitions
	//------------------------------------------------------------------------------
	typedef bit [9:0][11:0] data_array_t;
  	typedef bit [29:0] received_words_t;
	
	
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
	 
	     // terminal print colors
    typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
    } print_color;
	
	typedef enum bit {
	    PARITY_CORRECT,
	    PARITY_INCORRECT
	} parity_correctness_t;

  	typedef struct packed{
	    bit rst_n;
	    bit [9:0] cmd;
	    int nb_of_packets;
	    data_array_t data_array;
	  	parity_correctness_t cmd_parity;
    	parity_correctness_t data_parity;
	} command_s;

//------------------------------------------------------------------------------
// package functions
//------------------------------------------------------------------------------

    // used to modify the color of the text printed on the terminal

    function void set_print_color ( print_color c );
        string ctl;
        case(c)
            COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
            COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
            COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
            COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
            COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
            COLOR_DEFAULT : ctl              = "\033\[0m\n";
            default : begin
                $error("set_print_color: bad argument");
                ctl                          = "";
            end
        endcase
        $write(ctl);
    endfunction

//------------------------------------------------------------------------------
// testbench classes
//------------------------------------------------------------------------------
`include "random_command.svh"
`include "minmax_command.svh"
`include "result_transaction.svh"
`include "coverage.svh"
`include "scoreboard.svh"
`include "base_tester.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
`include "env.svh"

//------------------------------------------------------------------------------
// test classes
//------------------------------------------------------------------------------
`include "random_test.svh"
`include "minmax_test.svh"


endpackage : alu_pkg
