module dac(
	input clk125,
	input [7:0]din,
	input [13:0]cycle,
	input [7:0]div,
	output reg [9:0]dout,
	output reg [13:0]addr);

	reg [13:0]c;
	reg [15:0]d, cnt;
	always @(negedge clk125) begin
		c <= cycle;
		d <= div;
		cnt <= cnt <= d ? cnt + 1 : 0;
		dout <= din << 2;
	end
	always @(negedge cnt == 0) addr <= addr < c ? addr + 1 : 0;

endmodule
