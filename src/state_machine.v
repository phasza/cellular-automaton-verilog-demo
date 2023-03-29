`timescale 1ns / 1ps

module state_machine(
    input clk,  							// input clock
    input rst,								// a new setting happens after reset
		input sclk,								// clock for next state
		input [7:0] SW,						// switch to select mode (Wolfram code)
		input init_rdy,						// initialization ready
		input rdy,								// reading ready, enables writing
		output reg [0:99] data,
		output reg [6:0] addr
    );

// save Wolfram code configuration during reset
reg [7:0] sw_reg;
always@(posedge clk)
begin
	if(rst)
		sw_reg <= SW;
end

// sclk rise generation
reg [2:0] sclk_shr;
always@(posedge clk)
begin
	if(rst)
		sclk_shr<=0;
	else
		sclk_shr<={sclk,sclk_shr[2:1]};
end

assign sclk_rise=(sclk_shr[1:0]==2'b10)?1'b1:1'b0;


reg [0:101] row;

// Theoretical cellular automaton is infinite, but we have register boundaries.
// To ease the violation the last value of the register is shifted to the first value
always@(posedge clk)
begin
	if(rst)
		row[0]<=0;
	else if(init_rdy && rdy && sclk_rise)
		row[0]<=row[100];
end

always@(posedge clk)
begin
	if(rst)
		row[101]<=0;
	else if(init_rdy && rdy && sclk_rise)
		row[101]<=row[1];
end

// state block for each "bit"
// duuring reset the 50th bit is 1 (middle of the screen), the rest is zero
// each bit has a new value based on the value of the previous, current and next block according to Wolfram code

genvar i;
generate
    for (i = 1; i < 101; i = i + 1) begin: rule
		always@(posedge clk)
		begin
		if(rst && i != 50)
			row[i] <= 0;
		else if(rst && i == 50)
			row[i] <= 1;
      else if(init_rdy && rdy && sclk_rise)
			begin
				case({row[i-1],row[i],row[i+1]})
					3'b000: row[i] <= sw_reg[0];
					3'b001: row[i] <= sw_reg[1];
					3'b010: row[i] <= sw_reg[2];
					3'b011: row[i] <= sw_reg[3];
					3'b100: row[i] <= sw_reg[4];
					3'b101: row[i] <= sw_reg[5];
					3'b110: row[i] <= sw_reg[6];
					3'b111: row[i] <= sw_reg[7];
				endcase
			end
		end
    end
endgenerate


// address counter
reg [6:0] cnt_addr;
always@(posedge clk)
begin
	if(rst || cnt_addr==7'd74)
		cnt_addr<=0;
	else if(init_rdy && rdy && sclk_rise)
		cnt_addr <=cnt_addr+1;
end

always@(posedge clk)
begin
	if(rst || init_rdy && rdy && sclk_rise)
	begin
		data <= row [1:100];
		addr <= cnt_addr;
	end
end

endmodule
