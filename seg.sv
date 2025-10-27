typedef int unsigned u32;
localparam [7:0]segt[0:15] = {
	8'h03,8'h9f,8'h25,8'h0d,
	8'h99,8'h49,8'h41,8'h1f,
	8'h01,8'h09,8'h11,8'hc1,
	8'h63,8'h85,8'h61,8'h71
};
function automatic u32 cntedge(b, u32 x);
	u32 y = {x[30:0], b}, j = 0;
	foreach(y[i]) j += {31'b0, y[i] ^ x[i]};
	return j;
endfunction

module seg(
	input clk, pclk, key0, key1, [31:0]dsq,
	output reg ds, stclk, [1:0]led
);	
	reg preb;
	wire b = dsq[31];
	wire [31:0]ce = cntedge(preb, dsq);
	wire [31:0]c1 = $countones(dsq), c0 = 32 - c1;
	localparam u32 t = 31_250_000; 
	reg [31:0] duty, t1c, freq, fcnt, cnt,t0,t1, prec, qbuf;
	always @(negedge pclk) begin
		preb <= b;
		case(ce)
			0: prec <= prec + 32;
			1: if (preb) begin
				prec <= c0 * 1;
				t1 <= prec + c1 * 1;
			end else begin
				prec <= c1 * 1;
				t0 <= prec + c0 * 1;
			end
		endcase
		if (cnt == t) begin
			qbuf <= dsq;
			cnt <= 1;
			freq <= fcnt;
			fcnt <= ce * 1;
			duty <= t1c;
			t1c <= c1 * 1;
		end else begin
			cnt <= cnt + 1;
			fcnt <= fcnt + ce * 1;
			t1c <= t1c + c1 * 1;
		end
	end

	reg [1:0]k0cnt, k1cnt;
	assign led[1:0] = k0cnt;
	always @(negedge key0) k0cnt <= k0cnt + 1;
	always @(negedge key1) k1cnt <= k1cnt + 1;

	wire [3:0][7:0][3:0]cntbuf = {t0,qbuf,duty,freq};
	wire [7:0][3:0]disbuf = cntbuf[k0cnt];

	reg [6:0]segstat0;
	wire [6:0]segstat1 = segstat0 + 1;
	wire [2:0]segidx = segstat1[6:4];
	wire [7:0]segbit = 128 >> segidx;
	wire [7:0]segdata = segt[disbuf[segidx]];
	wire [15:0]segbuf = {segbit, segdata};
	always @(negedge clk) begin 
		segstat0 <= segstat1;
		ds <= segbuf[segstat1[3:0]];
	end
	always @(posedge clk) stclk <= !segstat0[3];

endmodule
