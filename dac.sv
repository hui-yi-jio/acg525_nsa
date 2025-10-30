module dac(
	input clk125,
	input [7:0]din,
	input [13:0]cycle,
	output reg [9:0]dout,
	output reg [13:0]addr);

	reg [13:0]c;
	always @(negedge clk125) begin
		c <= cycle;
		dout <= din << 2;
		addr <= addr <= c ? addr + 1 : 0;
	end

endmodule
