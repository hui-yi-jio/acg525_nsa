module main(
	input clk50,

	input digsig, key0, key1,
	output ds, stclk, shclk,

	input [3:0]rxd,
	output [3:0]txd,

	input adcovr,
	output adcclk,dacclk,adcoe,
	input [9:0]adpin,
	output [9:0]dapin,

	input rxclk, rxctl,
	output txclk, txctl
);
	wire clk125;
	wire clk125_90;
        wire clk1000;
        wire clkmin;

	assign adcclk = clk50;
	assign dacclk = clk50;
	assign txclk = clk125_90;
	assign shclk = clkmin;

    Gowin_PLL pll(
        .clkout0(clk125), //output clkout0
        .clkout1(clk125_90), //output clkout1
        .clkout2(clk1000), //output clkout3
        .clkout3(clkmin), //output clkout4
        .clkin(clk50) //input clkin
    );
	wire [39:0]addata;
	wire adwren;
	wire txrden;
	wire txafull;
	wire [39:0]txdata;
	tx tx(
	.clk125(clk125),
	.full(txafull),
	.idata(txdata),
	.txctl(txctl),
	.rden(txrden),
	.txd(txd)
	);
	adc adc(
		.clk50(clk50),
		.idata(adpin),
		.odata(addata),
		.wren(adwren)
		);
	fifo_top fifo(
		.Data(addata), //input [39:0] Data
		.WrClk(clk50), //input WrClk
		.RdClk(clk125), //input RdClk
		.WrEn(adwren), //input WrEn
		.RdEn(txrden), //input RdEn
		.Almost_Full(txafull), //output Almost_Full
		.Q(txdata) //output [39:0] Q
//		.Empty(Empty_o), //output Empty
//		.Full(Full_o) //output Full
	);
	
	seg seg(
	        .clk(clkmin),
	        .clk1000(clk1000),
	        .key0(key0),
	        .key1(key1),
	        .digsig(digsig),
	        .ds(ds),
	        .stclk(stclk)
	);

	rx rx(
		.rxclk(rxclk),
		.rxctl(rxctl),
		.rxd(rxd)
		);
endmodule
