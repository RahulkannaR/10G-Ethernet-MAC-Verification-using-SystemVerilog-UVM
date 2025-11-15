`ifndef VIRTUAL_SEQUENCE__SV
`define VIRTUAL_SEQUENCE__SV

class virtual_sequence extends uvm_sequence;

  `uvm_object_utils(virtual_sequence)
  `uvm_declare_p_sequencer(virtual_sequencer)

  reset_sequence             seq_rst;
  wishbone_init_sequence     seq_init_wshbn;
  packet_sequence            seq_pkt;
  wishbone_eot_sequence      seq_eot;

  function new(string name="virtual_sequence");
    super.new(name);
  endfunction

  // --------------------------------------------------------
  // MAIN SEQUENCE BODY
  // --------------------------------------------------------
  virtual task body();
    `uvm_info("VSEQ", "virtual_sequence::body() STARTED", UVM_NONE)

  `uvm_info("VSEQ", $sformatf("p_sequencer = %0p", p_sequencer), UVM_NONE)
  `uvm_info("VSEQ", $sformatf("p_sequencer.seqr_tx_pkt = %0p", p_sequencer.seqr_tx_pkt), UVM_NONE)

  `uvm_info("VSEQ", "About to start PACKET SEQUENCE", UVM_NONE)

  `uvm_do_on( seq_pkt, p_sequencer.seqr_tx_pkt );

  `uvm_info("VSEQ", "After PACKET SEQUENCE start", UVM_NONE)

    // --------------------------
    // 1. RESET DUT
    // --------------------------
    seq_rst = reset_sequence::type_id::create("seq_rst");
    `uvm_info(get_name(), "RUN: reset_sequence", UVM_MEDIUM)
    

    // small wait after reset
    #(2000);

    // --------------------------
    // 2. BASIC WISHBONE INIT
    // --------------------------
    seq_init_wshbn = wishbone_init_sequence::type_id::create("seq_init_wshbn");
    `uvm_info(get_name(), "RUN: wishbone_init_sequence", UVM_MEDIUM)
    `uvm_do_on(seq_init_wshbn, p_sequencer.seqr_wshbn)

    // --------------------------
    // 3. SEND PACKETS
    // --------------------------
    seq_pkt = packet_sequence::type_id::create("seq_pkt");
    `uvm_info(get_name(), "RUN: packet_sequence", UVM_MEDIUM)
    `uvm_do_on(seq_pkt, p_sequencer.seqr_tx_pkt)

    // let packets propagate
    #10000;

    // --------------------------
    // 4. END OF TEST RETURN SEQUENCE
    // --------------------------
    seq_eot = wishbone_eot_sequence::type_id::create("seq_eot");
    `uvm_info(get_name(), "RUN: wishbone_eot_sequence", UVM_MEDIUM)
    `uvm_do_on(seq_eot, p_sequencer.seqr_wshbn)

  endtask : body

  // --------------------------------------------------------
  // UVM OBJECTIONS
  // --------------------------------------------------------
  virtual task pre_start();
    super.pre_start();
    if (starting_phase != null && get_parent_sequence() == null)
      starting_phase.raise_objection(this);
  endtask

  virtual task post_start();
    super.post_start();
    if (starting_phase != null && get_parent_sequence() == null)
      starting_phase.drop_objection(this);
  endtask

endclass : virtual_sequence

`endif
