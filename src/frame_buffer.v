`timescale 1ns / 1ps

// 32 bit width, 75 bit deep block ram

module frame_buffer(
   input clk,
   input wr_en,
   input [6:0] wr_addr,
   input [0:31] wr_data,
   input [6:0] rd_addr,
   output [0:31] rd_data
);

reg [0:31] memory [74:0];

reg [0:31] rd_reg;
always @ (posedge clk)
begin
   if (wr_en)
      memory[wr_addr] <= wr_data;
   rd_reg <= memory[rd_addr];
end

assign rd_data = rd_reg;

endmodule
