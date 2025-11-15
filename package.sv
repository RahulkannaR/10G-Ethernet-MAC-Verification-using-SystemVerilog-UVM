`ifndef PACKAGE_SV
`define PACKAGE_SV


import uvm_pkg::*;
`include "uvm_macros.svh"

//coverage, assertion
`include "assertions_module.sv"

// Base packet / items
`include "packet.sv"
`include "xgmii_packet.sv"
`include "wishbone_item.sv"
`include "reset_item.sv"

// Sequences
`include "wishbone_sequence.sv"
`include "packet_sequence.sv"
`include "reset_sequence.sv"

// Virtual sequencer (must be BEFORE virtual_sequence)
`include "reset_sequencer.sv"
`include "wishbone_sequencer.sv"
`include "packet_tx_sequencer.sv"
`include "virtual_sequencer.sv"

// Virtual sequence
`include "virtual_sequence.sv"

// Drivers
`include "packet_tx_driver.sv"
`include "packet_rx_agent.sv"        // has internal driver? If separate driver exists add it
`include "reset_driver.sv"
`include "wishbone_driver.sv"

// Monitors
`include "packet_tx_monitor.sv"
`include "packet_rx_monitor.sv"
`include "wishbone_monitor.sv"
`include "xgmii_tx_monitor.sv"
`include "xgmii_rx_monitor.sv"

// Agents
`include "packet_tx_agent.sv"
`include "packet_rx_agent.sv"
`include "wishbone_agent.sv"
`include "xgmii_tx_agent.sv"
`include "xgmii_rx_agent.sv"
`include "reset_agent.sv"

// Scoreboard & env
`include "coverage.sv"
`include "scoreboard.sv"
`include "env.sv"

// Tests
`include "testclass.sv"
`include "testcase.sv"
`include "test_lib.svh"
`endif