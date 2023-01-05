class scoreboard extends uvm_subscriber#(result_transaction);
    `uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typdefs
//------------------------------------------------------------------------------
    typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result_t;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    uvm_tlm_analysis_fifo #(random_command) cmd_f;

    protected test_result_t test_result = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
 

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    protected function void print_test_result (test_result_t test_result);
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

//-
	//------------------------------------------------------------------------------
	// calculate expected result
	//------------------------------------------------------------------------------	
	function automatic received_words_t get_expected(parity_correctness_t cmd_parity, parity_correctness_t data_parity, 
                                                           bit [9:0] cmd_word, int nb_of_packets, data_array_t data_array);
	  bit[7:0] expected_status = S_NO_ERROR;
	  automatic logic [15:0] expected_data = 16'b0;
	  command_t cmd;
	  if($cast(cmd, cmd_word[8:1])) begin
	    case(cmd)
	      CMD_NOP : begin
	        expected_data = 16'b0;
	        expected_status = S_NO_ERROR;
		  end
	      CMD_AND : begin
		      expected_data = 16'hffff;
	        for(int i = 0; i < nb_of_packets; i++)
	          expected_data = data_array[i][8:1] & expected_data;
	        expected_status = S_NO_ERROR;
	      end 
	      CMD_OR  : begin
	        for(int i = 0; i < nb_of_packets; i++)
	          expected_data = data_array[i][8:1] | expected_data;
	        expected_status = S_NO_ERROR;
	      end 
	      CMD_XOR : begin
	        for(int i = 0; i < nb_of_packets; i++)
	          expected_data = data_array[i][8:1] ^ expected_data;
	        expected_status = S_NO_ERROR;
	      end 
	      CMD_ADD : begin
	        for(int i = 0; i < nb_of_packets; i++)
	          expected_data = data_array[i][8:1] + expected_data;
	        expected_status = S_NO_ERROR;
	      end
	      CMD_SUB : begin
	        expected_data[7:0] = data_array[0][8:1];
	        for(int i = 1; i < nb_of_packets; i++)
	          expected_data = expected_data - data_array[i][8:1];
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
	    if(data_parity == PARITY_INCORRECT) begin
	      expected_data = 16'b0;
	      expected_status = expected_status | S_DATA_PARITY_ERROR;
	    end
	    if(cmd_parity == PARITY_INCORRECT) begin
	      expected_data = 16'b0;
	      expected_status = expected_status | S_COMMAND_PARITY_ERROR;
	    end	  
	    
		  return {1'b1, expected_status,     ^{1'b1, expected_status},
		          1'b0, expected_data[15:8], ^{1'b0, expected_data[15:8]},
		          1'b0, expected_data[ 7:0], ^{1'b0, expected_data[ 7:0]}};
		endfunction
	
	//------------------------------------------------------------------------------
	// build phase
	//------------------------------------------------------------------------------
	  function void build_phase(uvm_phase phase);
	    cmd_f = new("cmd_f", this);
	  endfunction : build_phase
	
	//------------------------------------------------------------------------------
	// subscriber write function
	//------------------------------------------------------------------------------
	  function void write(result_transaction t);
	    result_transaction expected;
	    random_command cmd;
		expected = new("expected");
		cmd = new("cmd");
	    if(!cmd_f.try_get(cmd))
	      $fatal(1, "Missing command in self checker");
	
	    expected.received_words_t = get_expected(cmd.cmd_parity, cmd.data_parity, cmd.cmd, cmd.nb_of_packets, cmd.data_array);
	
	    SCOREBOARD_CHECK:
	    assert(t.compare(expected)) begin
	    
	    `ifdef DEBUG
	      $display("Test PASSED for \ncommand: %b", cmd.cmd);
	      $display("Expected: %b", expected);
	      $display("Received: %b", t);
	    `endif
	    end
	    else begin
	      $display("Test FAILED for \ncommand: %b", cmd.cmd);
	      $display("Expected: %b", expected);
	      $display("Received: %b", t);
	      test_result = TEST_FAILED;
	    end
	  endfunction : write

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(test_result);
    endfunction : report_phase

endclass : scoreboard

