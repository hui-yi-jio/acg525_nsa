//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.9
//Part Number: GW5A-LV25UG324ES
//Device: GW5A-25
//Device Version: A
//Created Time: Sun Oct 26 18:44:18 2025

module Gowin_Oversample (q, fclkp, d, fclkn, fclkqp, fclkqn, pclk, reset);

output [31:0] q;
input fclkp;
input d;
input fclkn;
input fclkqp;
input fclkqn;
input pclk;
input reset;

wire df_wire;
wire gw_gnd;

assign gw_gnd = 1'b0;

OSIDES32 osides32_inst (
    .Q(q),
    .DF(df_wire),
    .FCLKP(fclkp),
    .D(d),
    .FCLKN(fclkn),
    .FCLKQP(fclkqp),
    .FCLKQN(fclkqn),
    .PCLK(pclk),
    .RESET(reset),
    .SDTAP(gw_gnd),
    .VALUE(gw_gnd),
    .DLYSTEP({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam osides32_inst.C_STATIC_DLY = 0;
defparam osides32_inst.DYN_DLY_EN = "FALSE";
defparam osides32_inst.ADAPT_EN = "FALSE";

endmodule //Gowin_Oversample
