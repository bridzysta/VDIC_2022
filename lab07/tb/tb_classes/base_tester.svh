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
class base_tester extends uvm_component;
`uvm_component_utils(base_tester)
// The macro is not there as we never instantiate/use the base_tester
//    `uvm_component_utils(base_tester)


//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
  uvm_put_port #(random_command) command_port;
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    command_port = new("command_port",this);
  endfunction : build_phase
  
      protected function bit calculate_parity(bit [8:0] word, output parity_correctness_t parity);
	    randcase
	      14: begin
	        parity = PARITY_CORRECT;
	        return ^word;
	      end
	      1 : begin
	        parity = PARITY_INCORRECT;
	        return ~^word;
	      end
	    endcase
    endfunction : calculate_parity

//------------------------------------------------------------------------------
// function: get_data - generate random data for the tester
//------------------------------------------------------------------------------
	protected function byte get_data();
	        return 8'($random);
	endfunction : get_data

//------------------------------------------------------------------------------
// function: get_command - generate random opcode for the tester
//------------------------------------------------------------------------------
	protected function automatic byte get_command();
		bit [2:0] get_cmd;
		get_cmd = 3'($random);
	  	case(get_cmd)
		  	3'b000  : return CMD_NOP;
	    	3'b001 	: return CMD_AND;
		  	3'b010 	: return CMD_OR;
		  	3'b011 	: return CMD_XOR;
	    	3'b100 	: return CMD_ADD;
			3'b101 	: return CMD_SUB;
	    	default : return 8'($random);
	  	endcase
	endfunction : get_command
	
	
//---------------------------------
	  protected function bit [9:0] get_control_word(output parity_correctness_t cmd_parity);
	    automatic byte cmd = get_command();
	    cmd_parity = PARITY_CORRECT;
	    return {1'b1, cmd, ^{1'b1, cmd}};
	  endfunction : get_control_word
	
//---------------------------------
	
	  protected function bit [9:0] get_data_word(output parity_correctness_t data_parity);
	    automatic byte data = get_data();
	    return {1'b0, data, calculate_parity({1'b0, data}, data_parity)};
	  endfunction : get_data_word
	
//---------------------------------
	
	  protected function int fill_data_array(output data_array_t data_array, output parity_correctness_t data_parity);
	    parity_correctness_t temp_parity;
	    int number_of_data;
	
	    number_of_data = $urandom_range(9, 2);
	    data_parity = PARITY_CORRECT;
	    for(int i = 0; i < number_of_data; i++) begin
	      data_array[i][9:0] = get_data_word(temp_parity);
	      data_parity = parity_correctness_t'(data_parity | temp_parity);
	    end
	    return number_of_data;
	  endfunction : fill_data_array


//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------

	task run_phase(uvm_phase phase);
		random_command command;
		command = new("command");

	    phase.raise_objection(this);
	
	    command.rst_n = 1'b0;
	    command_port.put(command);
		command = random_command::type_id::create("command",this);
	    repeat(300) begin

	      command.rst_n = 1'b1;
		    
	      command.nb_of_packets = fill_data_array(command.data_array, command.data_parity);
	      command.cmd = get_control_word(command.cmd_parity);
	      command_port.put(command);
		    
	    end
	    #10000;
	    phase.drop_objection(this);

	endtask : run_phase


endclass : base_tester
