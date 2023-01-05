class driver extends uvm_component;
  `uvm_component_utils(driver)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
  protected virtual alu_bfm bfm;
  uvm_get_port #(random_command) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
      $fatal(1, "Failed to get BFM");
    command_port = new("command_port", this);
  endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    
    random_command command;

    forever begin
	        //  command_port.get(command);
      
      command_port.get(command);

      bfm.send_sequence(command);
    end
  endtask : run_phase

endclass : driver