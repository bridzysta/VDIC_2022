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
module top;
tinyalu_bfm bfm();
tester tester_i (bfm);
coverage coverage_i (bfm);
scoreboard scoreboard_i(bfm);

vdic_dut_2022 DUT(.clk(bfm.clk), .rst_n(bfm.rst_n), 
	.enable_n(bfm.enable_n), .din(bfm.din), 
	.dout(bfm.dout), .dout_valid(bfm.dout_valid));

endmodule : top


