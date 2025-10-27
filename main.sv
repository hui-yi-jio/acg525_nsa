module main(
	input clk50,

	input digsig, key0, key1,
	output ds, stclk, shclk, [3:0]led,

	input [3:0]rxd,
	output [3:0]txd,

	input adcovr,
	output adcclk,dacclk,adcoe,
	input [9:0]adpin,
	output [9:0]dapin,

	input rxclk, rxctl,
	output txclk, txctl,
	output pllout
);
	wire pclk, fclkp, fclkn, fclkqp, fclkqn, po;
	reg [15:0]div;
	always @(posedge po) div <= div + 1;
	assign pllout = div > 800;
    gpio_pll gpiopll(
        .clkout0(fclkp), 
        .clkout1(fclkn), 
        .clkout2(fclkqp),
        .clkout3(fclkqn),
        .clkout4(pclk),  
        .clkout5(po),
        .clkin(clk50)   
    );
	wire [31:0]dsq;
    Gowin_Oversample oversam(
        .q(dsq), //output [31:0] q
        .fclkp(fclkp), //input fclkp
        .d(clk50), //input d
        .fclkn(fclkqp), //input fclkn
        .fclkqp(fclkn), //input fclkqp
        .fclkqn(fclkqn), //input fclkqn
        .pclk(pclk), //input pclk
        .reset(0) //input reset
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
	        .pclk(pclk),
	        .key0(key0),
	        .key1(key1),
	        .dsq(dsq),
	        .ds(ds),
	        .stclk(stclk),
		.led(led)
	);

	rx rx(
		.rxclk(rxclk),
		.rxctl(rxctl),
		.rxd(rxd)
		);
endmodule
