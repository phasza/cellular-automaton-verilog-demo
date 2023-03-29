`timescale 1ns / 1ps

// 4 bit width, 75 bit deep block ram

module frame_buffer2(
   input clk,
   input wr_en,
   input [6:0] wr_addr,
   input [0:3] wr_data,
   input [6:0] rd_addr,
   output [0:3] rd_data
);

reg [0:3] dp_ram [74:0];

reg [0:3] rd_reg;
always @ (posedge clk)
begin
   if (wr_en)
      dp_ram[wr_addr] <= wr_data;
      
   rd_reg <= dp_ram[rd_addr];
end

assign rd_data = rd_reg;

endmodule
