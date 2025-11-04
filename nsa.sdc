//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.9 
//Created Time: 2025-11-05 02:39:13
create_clock -name k1 -period 1000 -waveform {0 500} [get_ports {key1}]
create_clock -name rxctl -period 8 -waveform {0 4} [get_ports {rxctl}]
create_clock -name k0 -period 1000 -waveform {0 500} [get_ports {key0}]
create_clock -name clk125 -period 8 -waveform {0 4} [get_nets {clk125}]
create_clock -name rxclk -period 8 -waveform {0 4} [get_ports {rxclk}]
create_clock -name ds -period 128 -waveform {0 64} [get_ports {ds}]
