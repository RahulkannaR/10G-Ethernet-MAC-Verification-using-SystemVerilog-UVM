// --------------------------------------------------------------
// wishbone_sequencer.sv
// --------------------------------------------------------------
`ifndef WISHBONE_SEQUENCER_SV
`define WISHBONE_SEQUENCER_SV

class wishbone_sequencer extends uvm_sequencer #(wishbone_item);
  `uvm_component_utils(wishbone_sequencer)

  function new(string name = "wishbone_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass

`endif
