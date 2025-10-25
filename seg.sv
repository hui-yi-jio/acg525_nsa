localparam [15:0][7:0]segt = {
	8'hc0,8'hf9,8'ha4,8'b0,
	8'h99,8'h92,8'h82,8'hf8,
	8'h80,8'h90,8'h88,8'h83,
	8'hc6,8'ha1,8'h86,8'h8e};

module seg(
	input clk, key0, key1,
	output reg segdata, shclk, stclk
);
	reg [7:0]k0cnt, k1cnt;
	always @(negedge key0) k0cnt <= k0cnt + 1;
	always @(negedge key1) k1cnt <= k1cnt + 1;

	reg [6:0]segstat0;
	wire [6:0]segstat1 = segstat0 + 1;
	wire [7:0]segbit = 1 << segstat1[2:0];
	wire [7:0]segbuf = segstat1[3] ? k0cnt : k1cnt;
	reg [9:0]div;
	always @(negedge clk) div <= div + 1;
	always @(negedge div[9]) begin
		segstat0 <= segstat1;
		segdata <= segbuf[segstat1[6:4]];
	end
	always @(posedge div[9]) stclk <= segstat0[3];
	assign shclk = div[9];
endmodule
