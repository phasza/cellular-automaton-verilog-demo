`timescale 1ns / 1ps

// VGA controller
// Generates the hsync, vsync for driving the display schedules reading the next value from memory accordingly.
//
// Resolution: 800x600 @ 72 Hz
// Pixel frequency: 50 Mhz
// Signal lvl: active high

// Horizontal timing:
// 	800 px
//			Front porch: 				56 px
//			Synch impulse: 			120 px
//			Back porch:					64 px
//			Sum:								1040 px

// Vertical timing:
// 	600 px
//			Front porch: 				37 px
//			Synch impulse:	 		6 px
//			Back porch:					23 px
//			Sum:								666 px


module vga_control(
    input clk,
    input rst,
	 	input init_rdy,	// processing starts after ready signal
    output hsync,
    output vsync,		
	 	output de,			// data enable
	 	output [7:0] h_out,
    output [6:0] rd_addr
);


reg [10:0] h_count;
reg [9:0] v_count;
wire hen;

always@(posedge clk)
begin
	if(rst || hen)
		h_count<=0;
	else if(init_rdy)
		h_count<=h_count+1;
end
assign hen=(h_count==(1039));


wire ven;
always@(posedge clk)
begin
	if(rst || ven)
		v_count<=0;
	else if(hen)
		v_count<=v_count+1;
end
assign ven=(v_count==(665)&& hen);

reg hs;
reg vs;

always@(posedge clk)
begin
	if(rst || h_count==(799+56+120))	//visible part + front porch + impulse width
		hs<=0;
	else if(h_count==799+56)
		hs<=1;
end

always@(posedge clk)
begin
	if(rst || (v_count==(599+37+6)&& hen)) //visible part + front porch + impulse width
		vs<=0;
	else if(v_count==599+37 && hen)
		vs<=1;
end

assign vsync=vs;
assign hsync=hs;

reg hde;
reg vde;
always@(posedge clk)
 if(rst||h_count==799)
  hde<=0;
 else if(h_count==1039)
 hde<=1;
 
always@(posedge clk)
	if(rst||(v_count==599&&hen))
		vde<=0;
	else if(v_count==665&&hen)
		vde<=1;


assign rd_addr=v_count[9:3];	//Display is in 8x8 pixels size, so the last 3 bit is don't care
assign h_out=h_count[10:3];
assign de=(vde&&hde);

endmodule

