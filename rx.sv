module rx(
	input rxclk, rxctl,
	input [3:0]rxd,
	output reg[7:0]dout,
	output reg[12:0]addr, cycle,
	output reg[7:0]div
);
	
	reg [13:0]cnt;
	reg [3:0]data0, data1;
	wire [7:0]data = {data0, data1};
	wire [12:0]ad = 13'(cnt - 24);
	always_ff @(negedge rxclk) data0 <= rxd;
	always_ff @(posedge rxclk) begin
		data1 <= rxd;
		cnt <= rxctl ? cnt + 1 : 0;
		addr <= ad;
		if (cnt == 24) div <= data;
		if (cnt > 24) dout <= data;
	end
	always_ff @(negedge rxctl) cycle <= ad - 1;
	
endmodule
