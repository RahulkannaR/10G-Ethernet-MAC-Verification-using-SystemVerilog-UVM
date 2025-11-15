// --------------------------------------------------------------
// packet_tx_sequencer.sv
// --------------------------------------------------------------
`ifndef PACKET_TX_SEQUENCER_SV
`define PACKET_TX_SEQUENCER_SV

class packet_tx_sequencer extends uvm_sequencer #(packet);
  `uvm_component_utils(packet_tx_sequencer)

  function new(string name = "packet_tx_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass

`endif
