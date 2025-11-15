// --------------------------------------------------------------
// reset_sequencer.sv
// --------------------------------------------------------------
`ifndef RESET_SEQUENCER_SV
`define RESET_SEQUENCER_SV

class reset_sequencer extends uvm_sequencer #(reset_item);
  `uvm_component_utils(reset_sequencer)

  function new(string name = "reset_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass

`endif
