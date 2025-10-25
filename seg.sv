localparam [7:0]segt[0:15] = {
	8'h03,8'h9f,8'h25,8'h0d,
	8'h99,8'h49,8'h41,8'h1f,
	8'h01,8'h09,8'h11,8'hc1,
	8'h63,8'h85,8'h61,8'h71};

module seg(
	input clk, clk1000, key0, key1, digsig,
	output reg ds, stclk
);	
	reg [5:0][3:0]cnt, cnt0, cnt1;
	reg digsig0;
	always @(negedge clk1000) begin
		digsig0 <= digsig;
		if (digsig0 ^ digsig) begin
			cnt <= 1;
			if (digsig0)
				cnt1 <= cnt;
			else
				cnt0 <= cnt;
		end else
			cnt <= cnt + 1;
	end

	reg [1:0]k0cnt, k1cnt;
	always @(negedge key0) k0cnt <= k0cnt + 1;
	always @(negedge key1) k1cnt <= k1cnt + 1;

	wire [5:0][3:0]cntbuf = k0cnt[0] ? cnt0 : cnt1;
	wire [7:0][3:0]disbuf = {6'b0,k0cnt, cntbuf};

	reg [6:0]segstat0;
	wire [6:0]segstat1 = segstat0 + 1;
	wire [2:0]segidx = segstat1[6:4];
	wire [7:0]segbit = 1 << segidx;
	wire [7:0]segdata = segt[disbuf[segidx]];
	wire [15:0]segbuf = {segbit, segdata};
	always @(negedge clk) begin 
		segstat0 <= segstat1;
		ds <= segbuf[segstat1[3:0]];
	end
	always @(posedge clk) stclk <= !segstat0[3];

endmodule
