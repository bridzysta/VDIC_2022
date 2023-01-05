class coverage extends uvm_subscriber#(random_command);
    `uvm_component_utils(coverage)

	
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	protected bit [9:0] cmd;
	protected int nb_of_packets;
	protected data_array_t data_array;
	protected parity_correctness_t cmd_parity;
    protected parity_correctness_t data_parity;
	protected bit [7:0] data;

//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

// Covergroup checking the op codes and theri sequences

	covergroup cmd_cov;
	
	    option.name = "cg_cmd_or_twice_cmd_cov";
	
	    command: coverpoint cmd[8:1]{
		    bins A1_CMD_NOP          = {8'b00000000};
	    	bins A1_CMD_AND          = {8'b00000001};
	    	bins A1_CMD_OR           = {8'b00000010};
	    	bins A1_CMD_XOR          = {8'b00000011};
	    	bins A1_CMD_ADD          = {8'b00010000};
	    	bins A1_CMD_SUB          = {8'b00100000};
	    	
	    }
	    
	    command_twice: coverpoint cmd[8:1]{
		    bins A2_CMD_NOP_twice          = (8'b00000000 [*2]);
	    	bins A2_CMD_AND_twice          = (8'b00000001 [*2]);
	    	bins A2_CMD_OR_twice           = (8'b00000010 [*2]);
	    	bins A2_CMD_XOR_twice          = (8'b00000011 [*2]);
	    	bins A2_CMD_ADD_twice          = (8'b00010000 [*2]);
	    	bins A2_CMD_SUB_twice          = (8'b00100000 [*2]);
	    
	  	}
	endgroup
	
	covergroup data_cov;
		
	  	option.name = "cg_data";
	
	   command_inv: coverpoint cmd[8:1]{
	    	bins B1_INVALID_COMMAND  = {[8'h00 : 8'hff]}
	           	with (!(item inside {8'b00000000, 8'b00000001, 8'b00000010, 8'b00000011, 8'b00010000, 8'b00100000}));
	    }
	
	  	num_data_packets : coverpoint nb_of_packets{
	    	bins B2_zero_data_packets        = {0};
	    	bins B3_correct_num_data_packets = {[1:9]};
	    	bins B4_over_nine_data_packets   = {[10:$]};
	  	}
	
	  	in_data : coverpoint data {
	    	bins B5_data_zeros     = {8'h00};
	    	bins B6_data_ones      = {8'hff};
	    	bins B7_data_others    = {[8'h01 : 8'hfe]};
	
	  	}
	
	endgroup
	
	covergroup parity_cov;
    
    	option.name = "cg_parity";
  
    data_parity : coverpoint data_parity{
        bins C1_correct   = {PARITY_CORRECT};
      		bins C2_incorrect = {PARITY_INCORRECT};
    }

    command_parity : coverpoint cmd_parity{
        bins C3_correct   = {PARITY_CORRECT};
      		bins C4_incorrect = {PARITY_INCORRECT};
    }
  endgroup
	
	//------------------------------------------------------------------------------
	// constructor
	//------------------------------------------------------------------------------
    
	function new (string name, uvm_component parent);
		super.new(name, parent);
		cmd_cov			  = new();
		data_cov		  = new();
		parity_cov        = new();
//		bfm			= b;
	endfunction : new
	


//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
  function void write(random_command t);
    nb_of_packets = t.nb_of_packets;
    data_array    = t.data_array;
	data_parity   = t.data_parity;
    cmd           = t.cmd;

    for(int i = 0; i < nb_of_packets; i++) begin
      data = data_array[i][8:1];
      data_cov.sample();
    end
    parity_cov.sample();
    cmd_cov.sample();
  endfunction : write

endclass : coverage
