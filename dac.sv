module dac(
	input clk125,
	input [7:0]din,
	input [13:0]cycle,
	output [9:0]dout,
	output [13:0]addr);

	always @(negedge clk125) begin
		dout <= din << 2;
		addr <= addr <= cycle ? addr + 1 : 0;
	end

endmodule
