//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9
//Part Number: GW5A-LV25UG324ES
//Device: GW5A-25
//Device Version: A
//Created Time: Tue Oct 28 01:43:53 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    ad2tx your_instance_name(
        .dout(dout_o), //output [7:0] dout
        .clka(clka_i), //input clka
        .cea(cea_i), //input cea
        .clkb(clkb_i), //input clkb
        .ceb(ceb_i), //input ceb
        .oce(oce_i), //input oce
        .reset(reset_i), //input reset
        .ada(ada_i), //input [10:0] ada
        .din(din_i), //input [7:0] din
        .adb(adb_i) //input [10:0] adb
    );

//--------Copy end-------------------
