localparam [7:0]segt[0:15] = {
	8'h03,8'h9f,8'h25,8'h0d,
	8'h99,8'h49,8'h41,8'h1f,
	8'h01,8'h09,8'h11,8'hc1,
	8'h63,8'h85,8'h61,8'h71};

module seg(
	input clk, key0, key1,
	output reg ds, stclk
);
	reg [7:0]k0cnt, k1cnt;
	always @(negedge key0) k0cnt <= k0cnt + 1;
	always @(negedge key1) k1cnt <= k1cnt + 1;

	reg [6:0]segstat0;
	wire [6:0]segstat1 = segstat0 + 1;
	wire [7:0]segbit = 1 << segstat1[6:4];
	wire [7:0]segdata = segt[segstat1[6:4] + k0cnt[3:0]];
	wire [15:0]segbuf = {segbit, segdata};
	always @(negedge clk) begin 
		segstat0 <= segstat1;
		ds <= segbuf[segstat1[3:0]];
	end
	always @(posedge clk) stclk <= !segstat0[3];

endmodule
