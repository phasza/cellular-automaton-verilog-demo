`timescale 1ns / 1ps

// Initializer module. Resets the screen by filling the ram with 0s.
// Initialize ends with init_rdy

module init(
	input clk,
	input rst,
   output reg [6:0] wr_addr,
   output reg [99:0] wr_data,
	output reg init_rdy
    );


reg [6:0] cnt_addr;

always@(posedge clk)
begin
	if(rst)
	begin
		cnt_addr <=0;
		init_rdy <= 0;
	end
	else if(cnt_addr==7'd74)
		init_rdy <= 1;
	else if(~init_rdy)
		cnt_addr <= cnt_addr+1;
end

always@(posedge clk)
begin
	wr_addr <= cnt_addr;
	wr_data <= 100'd0 ;
end

endmodule
