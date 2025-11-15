`ifndef PACKET_TX_DRIVER__SV
`define PACKET_TX_DRIVER__SV

class packet_tx_driver extends uvm_driver #(packet);

  virtual xge_mac_interface vif;

  `uvm_component_utils(packet_tx_driver)

  function new(string name="packet_tx_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual xge_mac_interface)::get(this, "", "drv_vi", vif))
      `uvm_fatal(get_name(), "Driver VIF not found!");

    if (vif == null)
      `uvm_fatal(get_name(), "Driver VIF is NULL!");
  endfunction


  virtual task run_phase(uvm_phase phase);
    packet req;
    bit [7:0] frame_bytes[$];  // flattened frame
    int unsigned total_bytes;
    int unsigned flit_count;

    // idle state
    vif.drv_cb.pkt_tx_val <= 1'b0;
    vif.drv_cb.pkt_tx_sop <= 1'b0;
    vif.drv_cb.pkt_tx_eop <= 1'b0;
    vif.drv_cb.pkt_tx_mod <= 3'b0;
    vif.drv_cb.pkt_tx_data <= 64'h0;

    @(posedge vif.clk_156m25);

    forever begin
      seq_item_port.get_next_item(req);

      if (req == null) continue;

      //-------------------------
      // Build full frame bytes
      //-------------------------

      frame_bytes.delete();

      // 6 bytes dest mac
      for (int i=0; i<6; i++)
        frame_bytes.push_back(req.mac_dst_addr >> ((5-i)*8));

      // 6 bytes src mac
      for (int i=0; i<6; i++)
        frame_bytes.push_back(req.mac_src_addr >> ((5-i)*8));

      // EtherType (big endian)
      frame_bytes.push_back(req.ether_type[15:8]);
      frame_bytes.push_back(req.ether_type[7:0]);

      // payload bytes
      foreach(req.payload[i])
        frame_bytes.push_back(req.payload[i]);

      total_bytes = frame_bytes.size();
      flit_count  = (total_bytes + 7) / 8;

      //-------------------------
      // Transmit 64-bit flits
      //-------------------------

      for (int i = 0; i < flit_count; i++) begin
        bit [63:0] flit = '0;

        for (int j=0; j<8; j++) begin
          int idx = i*8 + j;
          if (idx < total_bytes)
            flit[(7-j)*8 +: 8] = frame_bytes[idx];
        end

        // SOP/EOP/MOD
        vif.drv_cb.pkt_tx_sop <= (i==0);
        vif.drv_cb.pkt_tx_eop <= (i == flit_count-1);
        vif.drv_cb.pkt_tx_mod <= (i == flit_count-1) ? (total_bytes % 8) : 3'd0;

        vif.drv_cb.pkt_tx_data <= flit;
        vif.drv_cb.pkt_tx_val  <= 1'b1;

        @(vif.drv_cb);
      end

      // return to idle
      vif.drv_cb.pkt_tx_val <= 1'b0;
      vif.drv_cb.pkt_tx_sop <= 1'b0;
      vif.drv_cb.pkt_tx_eop <= 1'b0;
      @(vif.drv_cb);

      // Insert IPG
      repeat(req.ipg) @(vif.drv_cb);

      seq_item_port.item_done();
    end
  endtask

endclass

`endif
