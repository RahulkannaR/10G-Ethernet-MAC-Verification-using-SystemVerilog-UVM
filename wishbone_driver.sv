//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : wishbone_driver.sv                                  //
//  Author    : G. Andres Mancera (edited)                          //
//  License   : GNU Lesser General Public License                   //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef WISHBONE_DRIVER__SV
`define WISHBONE_DRIVER__SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class wishbone_driver extends uvm_driver #(wishbone_item);

  // Use 'vif' so env.sv direct-assignments work (and also accept "drv_vi" from config_db)
  virtual xge_mac_interface vif;

  `uvm_component_utils( wishbone_driver )

  // ---------------- Constructor ----------------
  function new(input string name = "wishbone_driver", input uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // ---------------- Build Phase ----------------
  virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);

    // Be forgiving: try both "vif" and legacy "drv_vi" keys
    if (!uvm_config_db#(virtual xge_mac_interface)::get(this, "", "vif", vif)) begin
      void'(uvm_config_db#(virtual xge_mac_interface)::get(this, "", "drv_vi", vif));
    end

    if ( vif == null ) begin
      `uvm_fatal(get_name(), "Virtual Interface for wishbone_driver not set (tried keys: \"vif\",\"drv_vi\")");
    end
  endfunction : build_phase


  // ---------------- Run Phase ----------------
  virtual task run_phase(input uvm_phase phase);
    wishbone_item req;
    `uvm_info(get_name(), $sformatf("Starting wishbone_driver::run_phase - %m"), UVM_LOW);

    forever begin
      // Get next item from sequencer
      seq_item_port.get_next_item(req);

      // Drive the transaction using the interface clocking block
      @(vif.drv_cb);

      // Put address/data/controls on bus
      vif.drv_cb.wb_adr_i <= req.xtxn_addr;
      vif.drv_cb.wb_dat_i <= req.xtxn_data;
      vif.drv_cb.wb_we_i  <= (req.xtxn_n == wishbone_item::WRITE) ? 1'b1 : 1'b0;
      vif.drv_cb.wb_cyc_i <= 1'b1;
      vif.drv_cb.wb_stb_i <= 1'b1;

      // Wait for ack (polling with clocking)
      // timeout/robustness can be added if desired
      do @(vif.drv_cb); while (vif.drv_cb.wb_ack_o !== 1);

      // De-assert handshake signals
      @(vif.drv_cb);
      vif.drv_cb.wb_cyc_i <= 1'b0;
      vif.drv_cb.wb_stb_i <= 1'b0;

      // Give sequencer item-done
      seq_item_port.item_done();

      // Small idle between transactions (optional, keeps bus sane)
      repeat (2) @(vif.drv_cb);
    end
  endtask : run_phase

endclass : wishbone_driver

`endif  // WISHBONE_DRIVER__SV
