module rx(
	input rxclk, rxctl,
	input [3:0]rxd,
	output reg[7:0]dout,
	output [13:0]addr, cycle
);
	
	reg [13:0]cnt;
	reg [1:0][7:0]admin, admax;
	reg [3:0]data0, data1;
	wire [7:0]data = {data0, data1};
	always @(negedge rxclk) data0 <= rxd;
	always @(posedge rxclk) begin
		data1 <= rxd;
		cnt <= rxctl ? cnt + 1 : 0;
		addr <= {admin[1:0]}[13:0] + cnt - 26;
		cycle <= {admax[1:0]}[13:0];
		case(cnt) inside
			22,23	:	admin[cnt - 22] <= data;
			24,25	:	admax[cnt - 24] <= data;
			[26:1525]:	dout <= data;
		endcase
	end
	
endmodule
