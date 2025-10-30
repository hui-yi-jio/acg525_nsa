function automatic [31:0]crc32([31:0]crc,[7:0]data);
	for (int i = 0; i < 8; ++i) begin
		bit b = crc[0] ^ data[i];
		crc >>= 1;
		crc ^= b ? 'hedb88320 : 0;
	end
	return crc;
endfunction;
function [31:0]crcupd([10:0]cnt, [31:0]crc, [7:0]frm);
	case(cnt) inside
		[8:1047]:	return crc32(crc, frm);
		//1048	:	return crc ^ -1;
		default	:	return -1;
	endcase
endfunction
function [7:0]txbyte([10:0]cnt, [7:0]frm, [7:0]crc);
	case(cnt) inside
		7	:	return 'hd5;
		[8:1047]:	return frm;
		[1048:1051]:	return crc;
		default	:	return 'h55;
	endcase
endfunction
localparam [5:0][7:0]mac = 48'h88_dab8_bf08;
function [7:0]frame([10:0]cnt, [7:0]data, [1:0][7:0]seq);
	case(cnt) inside
		[8:13]	:	return mac[cnt - 8];
		[14:19]	:	return 'h66;
		20, 21	:	return 'h19;
		22, 23	:	return seq[cnt - 22];
		[24:1047]:	return data;
		default	:	return 0;
	endcase
endfunction

module tx(
	input clk125, idx,
	input [7:0]data1,
	output reg txctl,
	output reg [10:0]txad,
	output [3:0]txd
);
	reg [1:0][7:0] seq;

	reg idx0, idx1, ie;
	reg [10:0] cnt0, cnt1, cnt2, cnt3;
	reg [3:0][7:0] crc;
	reg [7:0]data2, frm2, frm3, crc3;
	wire [9:0]ad = 10'(cnt0 - 24);
	always_ff @(negedge clk125) begin
		ie <= idx1 ^ idx0;
		idx0 <= idx;
		idx1 <= idx0;
		cnt0 <= ie ? 0 : txctl ? cnt0 + 1 : cnt0;
		seq <= seq + ie * 1;
		txad <= {idx0, ad};

		cnt1 <= cnt0;
		cnt2 <= cnt1;
		frm2 <= frame(cnt1, data1,seq);
		crc <= crcupd(cnt2, crc, frm2);

		crc3 <= crc[cnt2[1:0]] ^ -1;
		cnt3 <= cnt2;
		data2 <= data1;
		frm3 <= frame(cnt2, data2, seq);
	end
	reg [7:0] databuf;
	always_ff @(posedge clk125) begin 
		databuf <= txbyte(cnt3, frm3, crc3);
		txctl <= cnt3 < 1052;
	end
	assign txd = clk125 ? databuf[3:0] : databuf[7:4];
endmodule
