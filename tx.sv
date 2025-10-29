function automatic [31:0]crc32([31:0]crc,[7:0]data);
	for (int i = 0; i < 8; ++i) begin
		bit b = crc[0] ^ data[i];
		crc >>= 1;
		crc ^= b ? 'hedb88320 : 0;
	end
	return crc;
endfunction;
function [31:0]crcupd([11:0]cnt, [31:0]crc, [7:0]frm);
	case(cnt) inside
		[0:7]	:	return -1;
		[8:1047]:	return crc32(crc, frm);
	endcase
endfunction
function [7:0]txbyte([11:0]cnt, [7:0]frm, [3:0][7:0]crc);
	case(cnt) inside
		[0:6]	:	return 'h55;
		7	:	return 'hd5;
		[8:1047]:	return frm;
		[1048:1051]:	return crc[cnt - 1024] ^ -1;
	endcase
endfunction

localparam [5:0][7:0]mac = 48'h88_dab8_bf08;
module tx(
	input clk125, idx,
	input [7:0]data1,
	output reg txctl,
	output [10:0]txad,
	output [3:0]txd
);
	reg [1:0][7:0] seq;
	function [7:0]frame([11:0]cnt, [7:0]data);
		case(cnt) inside
			[8:13]	:	return mac[cnt - 8];
			[14:19]	:	return 'h66;
			20, 21	:	return 'h19;
			22, 23	:	return seq[cnt - 22];
			[24:1047]:	return data;
		endcase
	endfunction

	reg idx0;
	reg [11:0] cnt0, cnt1, cnt2;
	reg [3:0][7:0] crc2;
	reg [7:0]frm2;
	wire [9:0]ad = 10'(cnt0 - 24);
	wire ie = idx ^ idx0;
	always_ff @(negedge clk125) begin
		idx0 <= idx;
		cnt0 <= ie ? 0 : cnt0 + 1;
		seq <= seq + ie * 1;
		txad <= {idx, ad};
		cnt1 <= cnt0;
		cnt2 <= cnt1;
		frm2 <= frame(cnt1, data1);
		crc2 <= crcupd(cnt2, crc2, frm2);
	end
	reg [7:0] databuf;
	always_ff @(posedge clk125) begin 
		databuf <= txbyte(cnt2, frm2, crc2);
		txctl <= cnt2 < 1052;
	end
	assign txd = clk125 ? databuf[3:0] : databuf[7:4];
endmodule
