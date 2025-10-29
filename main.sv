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
	assign pllout = rxclk;
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
        .q(dsq), 
        .fclkp(fclkp), 
        .d(rxclk), 
        .fclkn(fclkqp), 
        .fclkqp(fclkn), 
        .fclkqn(fclkqn), 
        .pclk(pclk), 
        .reset(0) 
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
        .clkout0(clk125),
        .clkout1(clk125_90),
        .clkout2(clk1000),
        .clkout3(clkmin),
        .clkin(clk50)
    );
	wire [7:0]adout, txin;
	wire [10:0]adad, txad;
	wire idx;
	tx tx(
	.clk125(clk125),
	.idx(idx),
	.data1(txin),
	.txctl(txctl),
	.txad(txad),
	.txd(txd)
	);
	adc adc(
		.clk50(clk50),
		.din(adpin),
		.idx(idx),
		.dout(adout),
		.addr(adad)
		);
	
    ad2tx ad2tx(
        .dout(txin),
        .clka(clk50),
        .cea(1), 
        .clkb(clk125),
        .ceb(1),
        .oce(1),
        .reset(0),
        .ada(adad),
        .din(adout),
        .adb(txad)
    );
    wire [7:0]dain, rxout;
    wire [13:0]cycle, daad, rxad;
	rx rx(
		.rxclk(rxclk),
		.rxctl(rxctl),
		.rxd(rxd),
		.dout(rxout),
		.addr(rxad),
		.cycle(cycle)
		);
	dac dac(
		.clk125(clk125),
		.din(dain),
		.cycle(cycle),
		.dout(dapin),
		.addr(daad));
    rx2da rx2da(
        .dout(dain),
        .clka(rxclk), 
        .cea(1),
        .clkb(clk125),
        .ceb(1), 
        .oce(1),
        .reset(0),
        .ada(rxad),
        .din(rxout),
        .adb(daad) 
    );
	seg seg(
	        .clk(clkmin),
	        .pclk(pclk),
	        .key0(key0),
	        .key1(key1),
	        .dsq0(dsq),
	        .ds(ds),
	        .stclk(stclk),
		.led(led)
	);

endmodule
