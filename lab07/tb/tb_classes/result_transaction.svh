class result_transaction extends uvm_transaction;
	`uvm_object_utils(result_transaction)
	
	bit [29:0] received_words_t;
	
	extern function new(string name = "result_transaction");
	
	extern function void do_copy(uvm_object rhs);
	extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
	extern function string convert2string();

endclass : result_transaction

function result_transaction::new(string name = "result_transaction");
	super.new(name);
endfunction : new

function void result_transaction::do_copy(uvm_object rhs);
	result_transaction result_transaction_h;
	
	if(rhs == null)
    `uvm_fatal(get_name(), "Tried to copy from a null pointer")

  super.do_copy(rhs);
  
  if(!$cast(result_transaction_h, rhs))
	  `uvm_fatal(get_name(), "Could not cast - wrong type")
	  
  this.received_words_t = result_transaction_h.received_words_t;
	
endfunction : do_copy

function bit result_transaction::do_compare(uvm_object rhs, uvm_comparer comparer);
	result_transaction result_transaction_h;
	
	if(rhs == null)
		`uvm_fatal(get_name(), "Tried to comparison to a null pointer")
		
	if(!$cast(result_transaction_h, rhs)) begin
		return 1'b0;
	end else begin
		return super.do_compare(rhs, comparer) && (result_transaction_h.received_words_t == this.received_words_t);
	end
	
endfunction : do_compare

function string result_transaction::convert2string();
	return $sformatf("received_words_t=%30b", received_words_t);
endfunction : convert2string
