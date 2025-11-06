`include "def.sv"
localparam [7:0]segt[0:15] = {
	8'h03,8'h9f,8'h25,8'h0d,
	8'h99,8'h49,8'h41,8'h1f,
	8'h01,8'h09,8'h11,8'hc1,
	8'h63,8'h85,8'h61,8'h71
};
function automatic u6 cntedge(b, u32 x);
	u32 y = {x[30:0], b};
	u32 z = x ^ y;
	return $countones(z);
endfunction
function automatic u6 ctz(u32 x);
	u6 j = 0;
	foreach(x[i]) j += 1 * (x << i == 0);
	return j;
endfunction
function automatic u6 cto(u32 x);
	return ctz(~x);
endfunction
function automatic u6 clz(u32 x);
	u6 j = 0;
	foreach(x[i]) j += 1 * (x >> i == 0);
	return j;
endfunction
function automatic u6 clo(u32 x);
	return clz(~x);
endfunction
function [27:0]avg(u28 x0, u28 x1);
	return x0 * 255 + 256 + x1 >> 8;
endfunction
function [59:0]bin2dec([14:0][3:0]x);
	for (int i = 0; i < 8; ++i)
		if (x[i + 7] > 4)
			x[i + 7] += 3;
	return x << 1;
endfunction

module seg(
	input clk, pclk, key0, key1, [31:0]dsq0,
	output reg ds, stclk, [1:0]led
);	
	reg preb;
	reg [31:0]dsq, d10, f10;
	reg [27:0]duty, t1c, freq, fcnt;
	reg [27:0]t0,t1, prec;
	reg [21:0]cnt;
	wire b = dsq[31];
	wire u6 ce = cntedge(preb, dsq);
	wire u6 c1 = $countones(dsq);
	wire u6 ct1 = cto(dsq);
	wire u6 ct0 = ctz(dsq);
	wire u6 cmz = ctz(dsq >> ct1);
	wire u6 cmo = cto(dsq >> ct0);
	always @(negedge pclk) begin
		dsq <= dsq0;
		preb <= b;
		if (ce == 0) prec <= prec + 32;
		else begin
			prec <= 28'(b ? clo(dsq) : clz(dsq));
			if (preb) t1 <= prec + 1 * ct1;
			else t0 <= prec + 1 * ct0;
			if (ce > 1) 
				if (preb) t0 <= 1 * cmz;
				else t1 <= 1 * cmo;
		end
		if (cnt == 1) begin
			d10 <= 0;
			f10 <= 0;
		end else if (cnt < 30) begin
			{d10, duty} <= bin2dec({d10, duty});
			{f10, freq} <= bin2dec({f10, freq});
		end
		if (cnt == 3125000) begin
			freq <= fcnt >> 1;
			duty <= t1c;

			cnt <= 1;
			fcnt <= ce * 1;
			t1c <= c1 * 1;
		end else begin
			cnt <= cnt + 1;
			fcnt <= fcnt + ce * 1;
			t1c <= t1c + c1 * 1;
		end

	end

	reg k0, k1;
	reg [1:0]k0cnt, k1cnt;
	assign led[1:0] = k0cnt;

	wire [3:0][7:0][3:0]cntbuf = {32'(t0),32'(t1),32'(d10),32'(f10)};
	wire [7:0][3:0]disbuf = cntbuf[k0cnt];

	reg [6:0]segstat0;
	wire [6:0]segstat1 = segstat0 + 1;
	wire [2:0]segidx = segstat1[6:4];
	wire [7:0]segbit = 128 >> segidx;
	wire [7:0]segdata = segt[disbuf[segidx]];
	wire [15:0]segbuf = {segbit, segdata};
	always @(negedge clk) begin 
		k0 <= key0;
		k1 <= key1;
		k0cnt <= k0cnt + 2'(!k0 & key0);
		k1cnt <= k1cnt + 2'(!k1 & key1);
		segstat0 <= segstat1;
		ds <= segbuf[segstat1[3:0]];
	end
	always @(posedge clk) stclk <= !segstat0[3];

endmodule
