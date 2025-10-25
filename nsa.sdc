//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.9 
//Created Time: 2025-10-26 02:00:11
create_clock -name k0 -period 1000 -waveform {0 500} [get_ports {key0}]
create_clock -name k1 -period 1000 -waveform {0 500} [get_ports {key1}]
create_clock -name ds -period 128 -waveform {0 64} [get_ports {ds}]
