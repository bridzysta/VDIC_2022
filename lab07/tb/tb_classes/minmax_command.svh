class minmax_command extends random_command;
	`uvm_object_utils(minmax_command)
	
/*	constraint c_data_range {
		Data_number dist {2:/49, [3:MAX_NB_TR-1]:/2, MAX_NB_TR:/49};
	}
	*/
	extern function new(string name = "minmax_command");

endclass : minmax_command

function minmax_command::new(string name = "minmax_command");
	super.new(name);
endfunction : new
