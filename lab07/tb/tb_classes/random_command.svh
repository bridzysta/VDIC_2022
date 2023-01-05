class random_command extends uvm_transaction;
	`uvm_object_utils(random_command)
	
		rand bit rst_n;
	    rand bit [9:0] cmd;
	    rand int nb_of_packets;
	    rand data_array_t data_array;
	  	rand parity_correctness_t cmd_parity;
    	rand parity_correctness_t data_parity;
	

	
	extern function new(string name = "random_command");
	
	extern function void do_copy(uvm_object rhs);
	extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
	extern function string convert2string();

endclass : random_command

function random_command::new(string name = "random_command");
	super.new(name);
endfunction : new

function void random_command::do_copy(uvm_object rhs);
	random_command random_command_h;
	
	if(rhs == null)
    `uvm_fatal(get_name(), "Tried to copy from a null pointer")

  super.do_copy(rhs);
  
  if(!$cast(random_command_h, rhs))
	  `uvm_fatal(get_name(), "Could not cast - wrong type")
	  
  this.cmd = random_command_h.cmd;
  this.cmd_parity = random_command_h.cmd_parity;
  this.data_array = random_command_h.data_array;
  this.data_parity = random_command_h.data_parity;
  this.nb_of_packets = random_command_h.nb_of_packets;
  this.rst_n = random_command_h.rst_n;
  
	
endfunction : do_copy

function bit random_command::do_compare(uvm_object rhs, uvm_comparer comparer);
	random_command random_command_h;
	
	if(rhs == null)
		`uvm_fatal(get_name(), "Tried to comparison to a null pointer")
		
	if(!$cast(random_command_h, rhs)) begin
		return 1'b0;
	end else begin
		return super.do_compare(rhs, comparer) && (random_command_h.cmd == this.cmd)
												&& (random_command_h.cmd_parity == this.cmd_parity) 
												&& (random_command_h.data_array == this.data_array)
												&& (random_command_h.data_parity == this.data_parity) 
												&& (random_command_h.nb_of_packets == this.nb_of_packets)
												&& (random_command_h.rst_n == this.rst_n);
	end
	
endfunction : do_compare

function string random_command::convert2string();

	return $sformatf("cmd=%d nb_of_packets=%d cmd_parity=%s data_parity=%s", this.cmd, nb_of_packets, cmd_parity.name(), data_parity.name());
endfunction : convert2string
