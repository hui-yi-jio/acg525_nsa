module main(
	input clk50,

	input digsig, key0, key1,
	output ds, stclk, shclk,

	input [3:0]rxd,
	output [3:0]txd,

	input rxclk, rxctl,
	output txclk, txctl
);
	wire clk125;
	wire clk125_90;
        wire clk1000;
        wire clkmin;

	assign txclk = clk125_90;
	assign shclk = clkmin;

    Gowin_PLL pll(
        .clkout0(clk125), //output clkout0
        .clkout1(clk125_90), //output clkout1
        .clkout2(clk1000), //output clkout3
        .clkout3(clkmin), //output clkout4
        .clkin(clk50) //input clkin
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

	net net(
	.clk125(clk125),
	.txctl(txctl),
	.txd(txd)
	);
endmodule
