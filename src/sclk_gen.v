`timescale 1ns / 1ps

// CLK generator
// BTN3 -> 2.5 MHz
// BTN2 -> 1.25 MHz
// BTN1 -> stop
// Base frequency 12.5 MHz

module sclk_gen(
    input clk,
    input rst,
    input [3:0] BTN,
    output sclk
    );

reg [18:0] cnt_0;
always@(posedge clk)
begin
	if(rst || cnt_0 == 19'd400000)
		cnt_0<=0;
	else
		cnt_0<=cnt_0+1;
end
wire x0;
assign x0=(cnt_0==19'd400000)?1'b1:1'b0;


reg [19:0] cnt_1;
always@(posedge clk)
begin
	if(rst || cnt_1 == 20'd1000000)
		cnt_1<=0;
	else
		cnt_1<=cnt_1+1;
end
wire x1;
assign x1=(cnt_1==20'd1000000)?1'b1:1'b0;


reg [20:0] cnt_2;
always@(posedge clk)
begin
	if(rst || cnt_2 == 21'd2000000)
		cnt_2<=0;
	else
		cnt_2<=cnt_2+1;
end
wire x2;
assign x2=(cnt_2==21'd2000000)?1'b1:1'b0;


assign sclk=(BTN==4'b1000)?x1:(BTN==4'b0100)?x2:(BTN==4'b0010)?1'b0:(BTN==4'b0001)?x0:x0;

endmodule
