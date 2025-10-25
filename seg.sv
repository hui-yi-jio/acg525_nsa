localparam [15:0][7:0]segt = {
	8'hc0,8'hf9,8'ha4,8'b0,
	8'h99,8'h92,8'h82,8'hf8,
	8'h80,8'h90,8'h88,8'h83,
	8'hc6,8'ha1,8'h86,8'h8e};

module seg(
	input clk,
	output reg segdata, shclk, stclk
);
	reg [6:0]segstat0;
	wire [6:0]segstat1 = segstat0 + 1;
	wire [7:0]segbit = 1 << segstat1[2:0];
	wire [7:0]segbuf = segstat1[3] ? segbit : segt[1];
	always @(negedge clk) begin
		segstat0 <= segstat1;
		segdata <= segbuf[segstat1[6:4]];
	end
	always @(posedge clk) stclk <= segstat0[3];
	assign shclk = clk;
endmodule
