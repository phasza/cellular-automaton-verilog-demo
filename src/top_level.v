`timescale 1ns / 1ps


module top_level(
	input xclk,				// 16 Mhz base clockk
	input rst,
	input [3:0] BTN,
	input [7:0] SW,
	output [5:0] xrgb,	
	output xhs,
	output xvs
    );

// 50 Mhz clock
wire clk;
clk_gen clk0(.xclk(xclk),.clk(clk));

// Data enable
wire sclk;
sclk_gen sclk0(.clk(clk),.rst(rst),.BTN(BTN),.sclk(sclk));

// Initialize
wire init_rdy;
wire [6:0] wr_addr_init;
wire [0:99] wr_data_init;
init init0(.clk(clk),.rst(rst),.wr_addr(wr_addr_init),.wr_data(wr_data_init),.init_rdy(init_rdy));

// VGA controller
wire de;
wire [6:0] h_cnt;
wire [6:0] rd_addr_vga;
vga_control vga0(.clk(clk),.rst(rst),.init_rdy(init_rdy),.hsync(xhs),.vsync(xvs),.de(de),.h_out(h_cnt),.rd_addr(rd_addr_vga));

// Cellular automat state machine
wire [0:99] wr_data_state;
wire [6:0] wr_addr_state;
state_machine state0(.clk(clk),.rst(rst),.sclk(sclk),.SW(SW),.init_rdy(init_rdy),.rdy(~de),.data(wr_data_state),.addr(wr_addr_state));

// Memory reset. Active at init and data enable
wire wen;
assign wen=(~init_rdy || ~de);

// Write address selector
wire [6:0] wr_addr;
assign wr_addr=(~init_rdy)?wr_addr_init:wr_addr_state;

// Write data selector
wire [0:99] wr_data;
assign wr_data=(~init_rdy)?wr_data_init:wr_data_state;

wire [0:99] rd_data;
// Block memory. 3 / 32 bit width and 1 / 4 bit width memory concatenated.
frame_buffer frame0(.clk(clk),.wr_en(wen),.wr_addr(wr_addr),.wr_data(wr_data[0:31]),.rd_addr(rd_addr_vga),.rd_data(rd_data[0:31]));
frame_buffer frame1(.clk(clk),.wr_en(wen),.wr_addr(wr_addr),.wr_data(wr_data[32:63]),.rd_addr(rd_addr_vga),.rd_data(rd_data[32:63]));
frame_buffer frame2(.clk(clk),.wr_en(wen),.wr_addr(wr_addr),.wr_data(wr_data[64:95]),.rd_addr(rd_addr_vga),.rd_data(rd_data[64:95]));
frame_buffer2 frame3(.clk(clk),.wr_en(wen),.wr_addr(wr_addr),.wr_data(wr_data[95:99]),.rd_addr(rd_addr_vga),.rd_data(rd_data[96:99]));

// Data selector
// If data enable === 0 -> black screen

reg [5:0] rgb;
always@(posedge clk)
begin
	if(rst)
		rgb <= 0;
	else if(de)
		rgb <= {rd_data[h_cnt],rd_data[h_cnt],rd_data[h_cnt],rd_data[h_cnt],rd_data[h_cnt],rd_data[h_cnt]};
	else
		rgb <= 0;
end

assign xrgb = rgb;

endmodule
