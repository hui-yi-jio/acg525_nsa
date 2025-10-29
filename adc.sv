module adc(
	input clk50,
	input [9:0]din,
	output reg idx,
	output reg [7:0]dout,
	output reg [10:0]addr);

	always @(negedge clk50) begin
		addr <= addr + 1;
		dout <= din[9:2];
		idx <= !addr[10];
	end

endmodule
