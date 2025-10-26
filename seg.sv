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
function [4:0]ffe(b, [31:0]x);
	if (b ^ x[0])
		return 0;
	for (int i = 0; i < 31; ++i)
		if (^x[i+:2])
			return i + 1;
endfunction
function automatic [4:0]cm([31:0]x);
	bit [4:0] i, j;
	for (i = 0; i < 31; ++i)
		if (^x[i+:2])
			break;
	for (j = i + 1; j < 31; ++j)
		if (^x[j+:2])
			break;
	return j - i;
endfunction
function automatic [4:0]ct([31:0]x);
	bit [4:0] i;
	for (i = 0; i < 31; ++i)
		if (^x[30 - i+:2])
			break;
	return i + 1;
endfunction

module seg(
	input clk, pclk, key0, key1, [31:0]dsq,
	output reg ds, stclk
);	
	reg preb;
	wire b = dsq[31];
	wire [5:0]ce = cntedge(preb, dsq);
	reg [31:0]prec, t0, t1, freq, fcnt, cnt, duty;
	wire [5:0]c1 = $countones(dsq);
	wire [5:0]c0 = 32 - c1;
	wire [31:0]be = prec + ffe(preb, dsq);
	wire [4:0] ae = cm(dsq);
	always @(negedge pclk) begin
		preb <= b;
		if (cnt == 31250000) begin
			cnt <= 1;
			freq <= fcnt >> 1;
			fcnt <= ce;
		end else begin
			cnt <= cnt + 1;
			fcnt <= fcnt + ce;
		end
		case(ce)
			0: prec <= prec + 32;
			1:
				if (b) begin
					prec <= c1;
					t0 <= prec + c0;
				end else begin
					prec <= c0;
					t1 <= prec + c1;
				end
			default: begin
				prec <= ct(dsq);
				if (preb) begin
					t1 <= be;
					t0 <= ae;
				end else begin
					t0 <= be;
					t1 <= ae;
				end
			end

		endcase
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
