class result_monitor extends uvm_component;
  `uvm_component_utils(result_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
  protected virtual alu_bfm bfm;
  uvm_analysis_port #(result_transaction) ap;

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
    bfm.result_monitor_h = this;
    ap = new("ap",this);
  endfunction : build_phase

//------------------------------------------------------------------------------
// monitoring function called from BFM
//------------------------------------------------------------------------------
  function void write_to_monitor(received_words_t result);
	result_transaction transaction_h;
	transaction_h = new("transaction_h");
	transaction_h.received_words_t = result;
    `ifdef DEBUG
      $display ("RESULT MONITOR: %b", result);
    `endif
    ap.write(transaction_h);
  endfunction : write_to_monitor

endclass : result_monitor