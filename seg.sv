localparam [7:0]segt[0:15] = {
	8'h03,8'h9f,8'h25,8'h0d,
	8'h99,8'h49,8'h41,8'h1f,
	8'h01,8'h09,8'h11,8'hc1,
	8'h63,8'h85,8'h61,8'h71
};
function automatic [5:0]cntedge(b, [31:0]x);
	bit [5:0]j = b ^ x[0];
	for (int i = 0; i < 31; ++i)
		j += ^x[i+:2];
	return j;
endfunction

module seg(
	input clk, pclk, key0, key1, [31:0]dsq,
	output reg ds, stclk
);	
	reg preb;
	wire b = dsq[31];
	wire [5:0]ce = cntedge(preb, dsq);
	wire [5:0]c1 = $countones(dsq);
	localparam [31:0]t = 31250000; 
	reg [31:0]prec, t1s, t1c, freq, fcnt, cnt;
	wire[31:0]t1 = t1s / freq, t0 = (t - t1s) / freq, duty = t1s * 100 / t;
	always @(negedge pclk) begin
		preb <= b;
		if (cnt == t) begin
			cnt <= 1;
			freq <= fcnt >> 1;
			fcnt <= ce;
			t1s <= t1c;
			t1c <= c1;
		end else begin
			cnt <= cnt + 1;
			fcnt <= fcnt + ce;
			t1c <= t1c + c1;
		end
	end

	reg [1:0]k0cnt, k1cnt;
	always @(negedge key0) k0cnt <= k0cnt + 1;
	always @(negedge key1) k1cnt <= k1cnt + 1;

	function [7:0][3:0]cntbuf();
		case(k0cnt)
			0: return t0;
			1: return t1;
			2: return freq;
			3: return duty;
		endcase
	endfunction
	wire [7:0][3:0]disbuf = cntbuf();

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
