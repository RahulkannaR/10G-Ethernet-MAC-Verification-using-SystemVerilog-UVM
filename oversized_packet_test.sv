`ifndef OVERSIZED_PACKET_TEST__SV
`define OVERSIZED_PACKET_TEST__SV

class oversized_packet_test extends virtual_sequence_test_base;

  `uvm_component_utils(oversized_packet_test)

  // ----------------------------------------------------
  // Constructor
  // ----------------------------------------------------
  function new(string name = "oversized_packet_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // ----------------------------------------------------
  // BUILD PHASE (ONLY declarations & statements allowed)
  // ----------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_name(), $sformatf("Hierarchy: %m"), UVM_NONE)

    // Type override must be inside build_phase
    uvm_factory::get().set_type_override_by_type(
      packet::get_type(),
      packet_oversized::get_type()
    );
  endfunction : build_phase

  // ----------------------------------------------------
  // NOTE:
  // No statements allowed here before task run_phase!!
  // ----------------------------------------------------

  // ----------------------------------------------------
  // RUN PHASE (must appear AFTER all declarations)
  // ----------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    virtual_sequence vseq;
    super.run_phase(phase);

    vseq = virtual_sequence::type_id::create("vseq");

    `uvm_info(get_name(),
              "Starting OVERSIZED virtual sequence...",
              UVM_MEDIUM)

    vseq.start(v_seqr);
  endtask : run_phase

endclass : oversized_packet_test

`endif
