interface alu_bfm;
	
import alu_pkg::*;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

bit                 clk;
bit                 rst_n;
bit                 din;
bit                 enable_n;

//int					numb_packets;

wire                dout;
wire                dout_valid;

//bit 		[7:0] 	data;

//bit 		[9:0]	data_fifo_sb[$];
//bit 		[9:0]	command;
//bit 		[9:0]	command_sb[$];
bit 		[9:0]	received_status;
bit 		[9:0]	received_data[2];
	
//bit 		[29:0]	result[$];
	
command_s bfm_command;
event send_to_cmd_monitor;
event send_to_result_monitor;
	
command_monitor command_monitor_h;
result_monitor  result_monitor_h;

modport tlm(import reset_alu, send_sequence);
    
//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen_blk
  clk = 0;
  forever begin : clk_frv_blk
    #10;
    clk = ~clk;
  end
end

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------
task reset_alu();
  @(negedge clk);
  rst_n = 1'b0;
  @(negedge clk);
  rst_n = 1'b1;
  enable_n = 1'b1;
endtask : reset_alu

//---------------------------------
// Send task

task send_data(bit [9:0] data);
  repeat(10) begin
    @(negedge clk);
    enable_n = 1'b0;
    din = data[9];
    data = {data[8:0], 1'b0};
  end
endtask : send_data

//---------------------------------
// Receive tasks

task receive_data(output bit [9:0] received_data);
  repeat(10) begin
    @(negedge clk);
    if(dout_valid) begin
      received_data = {received_data[8:0], dout};
    end
  end
endtask : receive_data



//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------
initial begin : command_monitor_thread
  forever begin
    @(send_to_cmd_monitor);
    command_monitor_h.write_to_monitor(bfm_command);
  end
end : command_monitor_thread

//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------
initial begin : result_monitor_thread
  forever begin
    @(send_to_result_monitor);
    result_monitor_h.write_to_monitor({received_status, received_data[0], received_data[1]});
  end
end : result_monitor_thread

//------------------------------------------------------------------------------
// send_sequence
//------------------------------------------------------------------------------
task send_sequence(random_command cmd);
  if(!cmd.rst_n)
    reset_alu();
  else begin
	bfm_command.cmd = cmd.cmd;
	bfm_command.cmd_parity = cmd.cmd_parity;
	bfm_command.data_array = cmd.data_array;
	bfm_command.data_parity = cmd.data_parity;
	bfm_command.nb_of_packets = cmd.nb_of_packets;
	bfm_command.rst_n = cmd.rst_n;
    for(int i = 0; i < cmd.nb_of_packets; i++)
      send_data(cmd.data_array[i][9:0]);
    send_data(cmd.cmd);
    ->send_to_cmd_monitor;
    @(negedge clk);
    enable_n = 1'b1;
    wait(dout_valid);
    receive_data(received_status);
    receive_data(received_data[0]);
    receive_data(received_data[1]);
    ->send_to_result_monitor;
  end
endtask

endinterface : alu_bfm