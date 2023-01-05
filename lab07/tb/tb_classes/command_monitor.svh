class command_monitor extends uvm_component;
  `uvm_component_utils(command_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
  protected virtual alu_bfm bfm;
  uvm_analysis_port #(random_command) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
      $fatal(1, "Failed to get BFM");
    bfm.command_monitor_h = this;
    ap = new("ap",this);
  endfunction : build_phase

//------------------------------------------------------------------------------
// monitoring function called from BFM
//------------------------------------------------------------------------------
  function void write_to_monitor(command_s cmd);
	random_command command_h;
	command_h = new("command_h");
	command_h.cmd = cmd.cmd;
	command_h.cmd_parity = cmd.cmd_parity;
	command_h.data_array = cmd.data_array;
	command_h.data_parity = cmd.data_parity;
	command_h.nb_of_packets = cmd.nb_of_packets;
	command_h.rst_n = cmd.rst_n;
    `ifdef DEBUG
      for(int i = 0; i < cmd.nb_of_packets; i++)
        $display("COMMAND MONITOR: data: %b", cmd.data_array[i][WORD_WIDTH-1:0]);
      $display("COMMAND MONITOR: cmd: %b", cmd.cmd);
    `endif
    ap.write(command_h);
  endfunction : write_to_monitor

endclass : command_monitor