//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9
//Part Number: GW5A-LV25UG324ES
//Device: GW5A-25
//Device Version: A
//Created Time: Sun Oct 26 18:44:18 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_Oversample your_instance_name(
        .q(q_o), //output [31:0] q
        .fclkp(fclkp_i), //input fclkp
        .d(d_i), //input d
        .fclkn(fclkn_i), //input fclkn
        .fclkqp(fclkqp_i), //input fclkqp
        .fclkqn(fclkqn_i), //input fclkqn
        .pclk(pclk_i), //input pclk
        .reset(reset_i) //input reset
    );

//--------Copy end-------------------
