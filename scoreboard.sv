//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : scoreboard.sv                                       //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef SCOREBOARD__SV
`define SCOREBOARD__SV

typedef uvm_in_order_comparator #(packet) packet_comparator;

class scoreboard extends uvm_scoreboard;

  // ------------------ INTERFACE FOR CLOCK ------------------
  virtual xge_mac_interface vif;

  // ------------------ COVERAGE COLLECTOR ------------------
  coverage_collector cov_col;

  // Packet storage for matching
  packet        pkt_tx_agent_q [$];
  packet        pkt_rx_agent_q [$];
  wishbone_item wshbn_read_q   [$];

  // Counters
  int unsigned  m_matches;
  int unsigned  m_mismatches;
  int unsigned  m_dut_errors;
  int unsigned  non_empty_queue;

  // Coverage counters 
  int unsigned  pkt_count;
  int unsigned  wb_count;

  // Events
  uvm_event     check_packet_event;
  uvm_event     check_wshbn_event;

  `uvm_component_utils(scoreboard)

  // Analysis ports
  `uvm_analysis_imp_decl(_from_pkt_tx_agent)
  uvm_analysis_imp_from_pkt_tx_agent #(packet, scoreboard) from_pkt_tx_agent;

  `uvm_analysis_imp_decl(_from_pkt_rx_agent)
  uvm_analysis_imp_from_pkt_rx_agent #(packet, scoreboard) from_pkt_rx_agent;

  `uvm_analysis_imp_decl(_from_wshbn_agent)
  uvm_analysis_imp_from_wshbn_agent #(wishbone_item, scoreboard) from_wshbn_agent;


  // ------------------ GET CLOCK FUNCTION ------------------
  function logic get_clock();
      if (!uvm_config_db#(virtual xge_mac_interface)::get(this, "", "vif", vif))
          `uvm_fatal("SCBD", "Interface (vif) not found in config_db")

      return vif.clk_156m25;
  endfunction


  // ------------------ CTOR ------------------
  function new(string name="scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction


  // ------------------ BUILD PHASE ------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_matches = 0;
    m_mismatches = 0;
    m_dut_errors = 0;
    non_empty_queue = 0;

    pkt_count = 0;
    wb_count  = 0;

    // Get interface for the scoreboard
    if (!uvm_config_db#(virtual xge_mac_interface)::get(this, "", "vif", vif))
        `uvm_fatal("SCBD", "Interface (vif) not found in config_db")

    // Create coverage collector using real DUT clock
    cov_col = new("cov_col", vif.clk_156m25);

    from_pkt_tx_agent = new("from_pkt_tx_agent", this);
    from_pkt_rx_agent = new("from_pkt_rx_agent", this);
    from_wshbn_agent  = new("from_wshbn_agent",  this);

    check_packet_event = new("check_packet_event");
    check_wshbn_event  = new("check_wshbn_event");

  endfunction



  // ------------------ WRITE HANDLERS ------------------

  function void write_from_pkt_tx_agent(packet tx_packet);
    `uvm_info(get_name(), "Received pkt_tx packet", UVM_HIGH);
    pkt_tx_agent_q.push_back(tx_packet);

    pkt_count++;
    void'(cov_col.sample_packet(tx_packet));
  endfunction


  function void write_from_pkt_rx_agent(packet rx_packet);
    `uvm_info(get_name(), "Received pkt_rx packet", UVM_HIGH);
    pkt_rx_agent_q.push_back(rx_packet);

    check_packet_event.trigger();

    pkt_count++;
    void'(cov_col.sample_packet(rx_packet));
  endfunction


  function void write_from_wshbn_agent(wishbone_item wshbn_xtxn);
    `uvm_info(get_name(), "Received wishbone transaction", UVM_HIGH);
    wshbn_read_q.push_back(wshbn_xtxn);

    check_wshbn_event.trigger();

    wb_count++;
    void'(cov_col.sample_wishbone(wshbn_xtxn));
  endfunction



  // ------------------ PARALLEL CHECKERS ------------------

  virtual task check_packet();
    forever begin
      check_packet_event.wait_trigger();
      check_packet_queues();
    end
  endtask


  virtual task check_wishbone_trans();
    forever begin
      check_wshbn_event.wait_trigger();
      check_wshbn_queue();
    end
  endtask



  // ------------------ PACKET COMPARE LOGIC ------------------

  virtual function void check_packet_queues();
    packet tx_pkt;
    packet rx_pkt;
    int unsigned error;
    int unsigned mismatch;

    while (pkt_tx_agent_q.size() && pkt_rx_agent_q.size()) begin
      error = 0;
      tx_pkt = pkt_tx_agent_q.pop_front();
      rx_pkt = pkt_rx_agent_q.pop_front();

      if (tx_pkt.mac_dst_addr != rx_pkt.mac_dst_addr)
        report_field_mismatch("MAC_DST_ADDR", tx_pkt.mac_dst_addr, rx_pkt.mac_dst_addr, error);

      if (tx_pkt.mac_src_addr != rx_pkt.mac_src_addr)
        report_field_mismatch("MAC_SRC_ADDR", tx_pkt.mac_src_addr, rx_pkt.mac_src_addr, error);

      if (tx_pkt.ether_type != rx_pkt.ether_type)
        report_field_mismatch("ETHER_TYPE", tx_pkt.ether_type, rx_pkt.ether_type, error);

      // Payload compare
      if (tx_pkt.payload.size() != rx_pkt.payload.size())
        error++;

      void'(compare_payload_bytes(tx_pkt.payload, rx_pkt.payload,
                                  (tx_pkt.payload.size() < rx_pkt.payload.size())
                                  ? tx_pkt.payload.size() : rx_pkt.payload.size(),
                                  mismatch));

      if (mismatch) error++;

      if (error)
        m_mismatches++;
      else begin
        m_matches++;
        `uvm_info(get_name(), "PACKET MATCH", UVM_HIGH)
      end
    end
  endfunction


  function void report_field_mismatch(string field, bit [63:0] exp, bit [63:0] act, inout int unsigned err);
      `uvm_error(get_name(), 
          $psprintf("%s MISMATCH! Exp=%0x Act=%0x", field, exp, act))
      err++;
  endfunction



  // ------------------ PAYLOAD COMPARE ------------------

  function void compare_payload_bytes(
      bit [7:0] exp_bytes[],
      bit [7:0] act_bytes[],
      int unsigned length,
      ref int unsigned mismatch
  );
    mismatch = 0;
    for (int i = 0; i < length; i++) begin
      if (exp_bytes[i] != act_bytes[i]) begin
        mismatch++;
        `uvm_error(get_name(),
          $psprintf("PYLD[%0d] MISMATCH Exp=%0x Act=%0x",
                    i, exp_bytes[i], act_bytes[i]));
      end
    end
  endfunction



  // ------------------ WISHBONE CHECK ------------------

  virtual function void check_wshbn_queue();
    wishbone_item xtxn;
    int unsigned error;

    while (wshbn_read_q.size()) begin
      error = 0;
      xtxn = wshbn_read_q.pop_front();

      if (xtxn.xtxn_n == wishbone_item::READ) begin
        if ((xtxn.xtxn_addr == 8'h08 || xtxn.xtxn_addr == 8'h0C) &&
            xtxn.xtxn_data != 32'h0) begin

          `uvm_error(get_name(), "WISHBONE RD ERROR")
          error++;
        end
      end

      if (error) m_dut_errors++;
    end
  endfunction



  // ------------------ RUN PHASE ------------------

  task run_phase(uvm_phase phase);
    fork
      check_packet();
      check_wishbone_trans();
    join_none
  endtask



  // ------------------ CHECK PHASE ------------------

  virtual function void check_phase(uvm_phase phase);
    if (pkt_tx_agent_q.size())
      `uvm_error(get_name(), "pkt_tx_agent_q not empty at end")

    if (pkt_rx_agent_q.size())
      `uvm_error(get_name(), "pkt_rx_agent_q not empty at end")

    if (wshbn_read_q.size())
      `uvm_error(get_name(), "wshbn_read_q not empty at end")
  endfunction

  // ------------------ FINAL PHASE --------------------

  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);

    `uvm_info(get_name(),
      $sformatf("FINAL: Packet Matches   = %0d", m_matches), UVM_LOW)
    `uvm_info(get_name(),
      $sformatf("FINAL: Packet Mismatches= %0d", m_mismatches), UVM_LOW)
    `uvm_info(get_name(),
      $sformatf("FINAL: Wishbone Errors  = %0d", m_dut_errors), UVM_LOW)

    // Extra coverage summary
    `uvm_info(get_name(),
      $sformatf("COVERAGE: Packets Sampled=%0d  WB Txns=%0d",
                pkt_count, wb_count), UVM_LOW)

    if (m_mismatches || m_dut_errors || non_empty_queue)
      `uvm_error(get_name(), "********** TEST FAILED **********")
    else
      `uvm_info(get_name(), "********** TEST PASSED **********", UVM_NONE)
  endfunction

endclass

`endif
