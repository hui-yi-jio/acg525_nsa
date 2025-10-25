function automatic [31:0]crc32([31:0]crc,[7:0]data);
	for (int i = 0; i < 8; ++i) begin
		bit b = crc[0] ^ data[i];
		crc >>= 1;
		crc ^= b ? 'hedb88320 : 0;
	end
	return crc;
endfunction;
function [31:0]crcnext([31:0]crc, [7:0]cnt, [7:0]data);
	case (cnt) inside
		[0:7]: return -1;
		[8:221]: return crc32(crc, data);
		default return crc;
	endcase
endfunction

localparam [13:0][7:0]head = 'h1919_08bf_b8da_8800_0088_dab8_bf08;
module tx(
	input clk125,
	output reg txctl,

	output wire[3:0]txd
);
	reg [7:0] txcnt0, txcnt1;
	reg [3:0][7:0] crc;
	function [7:0]sel([7:0]cnt);
		case(cnt) inside
			[0:6]	:	return 'h55;
			7	:	return 'hd5;
			[8:21]	:	return head[cnt - 8];
			[22:221]:	return 'h39;
			[222:225]:	return crc[cnt - 222] ^ -1;
			default	:	return 0;
		endcase 
	endfunction
	reg [7:0]txreg0, txreg1;

	always_ff @(posedge clk125) begin 
		txcnt1 <= txcnt1 + 1;	//0
		txcnt0 <= txcnt1;	//1
		txctl <= txcnt0 < 226;	//2
		txreg1 <= sel(txcnt1);	//1
		txreg0 <= sel(txcnt0);	//2
		crc <= crcnext(crc, txcnt0, txreg1);	//2
	end
	assign txd = clk125 ? txreg0[3:0] : txreg0[7:4]; //2
endmodule
