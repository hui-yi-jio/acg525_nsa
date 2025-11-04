module rx(
	input rxclk, rxctl,
	input [3:0]rxd,
	output reg[7:0]dout,
	output reg[13:0]addr, cycle
);
	
	reg [13:0]cnt;
	reg [3:0]data0, data1;
	wire [7:0]data = {data0, data1};
	wire [13:0]ad = cnt - 26;
	always @(negedge rxclk) data0 <= rxd;
	always @(posedge rxclk) begin
		data1 <= rxd;
		cnt <= rxctl ? cnt + 1 : 0;
		addr <= ad;
		dout <= data;
	end
	always @(negedge rxctl) cycle <= ad;
	
endmodule
