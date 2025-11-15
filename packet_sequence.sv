`ifndef PACKET_SEQUENCE__SV
`define PACKET_SEQUENCE__SV

class packet_sequence extends uvm_sequence #(packet);

  int unsigned num_packets = 100;

  `uvm_object_utils(packet_sequence)

  function new(string name = "packet_sequence");
    super.new(name);
  endfunction


  virtual task body();
    `uvm_info("PKT_SEQ", "packet_sequence::body() STARTED", UVM_MEDIUM)

    // Get updated packet count if supplied via config_db
    void'(uvm_config_db#(int unsigned)::get(null, get_full_name(), "num_packets", num_packets));

    for (int i = 0; i < num_packets; i++) begin

      // ------- CREATE REQUEST -------
      req = packet::type_id::create("req");
      start_item(req);

      // ------- RANDOMIZE PACKET -------
      if (!req.randomize()) begin
        `uvm_error("PKT_SEQ", "Packet randomization FAILED!")
      end

      // ------- OPTIONAL: SHOW PACKET CONTENT -------
      `uvm_info("PKT_SEQ", $sformatf("Generated Packet %0d:\n%s", 
                    i, req.sprint()), UVM_HIGH)

      finish_item(req);
    end

  endtask : body


  virtual task pre_start();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    void'(uvm_config_db#(int unsigned)::get(null, get_full_name(),
                                            "num_packets", num_packets));
  endtask : pre_start


  virtual task post_start();
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask : post_start

endclass : packet_sequence

`endif
