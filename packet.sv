`ifndef PACKET__SV
`define PACKET__SV

class packet extends uvm_sequence_item;

  // Header fields
  rand bit [47:0] mac_dst_addr;
  rand bit [47:0] mac_src_addr;
  rand bit [15:0] ether_type;

  // Payload bytes
  rand bit [7:0] payload[];

  // Inter-packet gap
  rand int unsigned ipg;

  // SOP/EOP marks (not random)
  bit sop_mark;
  bit eop_mark;

  `uvm_object_utils_begin(packet)
    `uvm_field_int(mac_dst_addr , UVM_DEFAULT)
    `uvm_field_int(mac_src_addr , UVM_DEFAULT)
    `uvm_field_int(ether_type   , UVM_DEFAULT)
    `uvm_field_array_int(payload, UVM_DEFAULT)
    `uvm_field_int(ipg,          UVM_DEFAULT)
  `uvm_object_utils_end

  // Payload 46 to 1500 bytes
  constraint C_payload_size { payload.size() inside {[46:1500]}; }

  // IPG spacing
  constraint C_ipg { ipg inside {[4:40]}; }

  function new(string name="packet");
    super.new(name);
  endfunction

endclass : packet

class packet_bringup extends packet;

  `uvm_object_utils(packet_bringup)

  constraint C_bringup {
    mac_dst_addr == 48'hAABB_CCDD_EEFF;
    mac_src_addr == 48'h1122_3344_5566;
    ether_type   inside {16'h0800, 16'h0806, 16'h86DD}; // IPv4, ARP, IPv6
    payload.size() inside {[45:54]};
    foreach (payload[i]) payload[i] == i;
    ipg == 10;
  }

  function new(string name="packet_bringup");
    super.new(name);
  endfunction

endclass


class packet_oversized extends packet;

  `uvm_object_utils(packet_oversized)

  constraint C_oversize {
    payload.size() inside {[1501:9000]};   // jumbo frame
  }

  function new(string name="packet_oversized");
    super.new(name);
  endfunction

endclass


class packet_undersized extends packet;

  `uvm_object_utils(packet_undersized)

  constraint C_undersize {
    payload.size() inside {[1:45]};   // Ethernet minimum < 46 bytes
  }

  function new(string name="packet_undersized");
    super.new(name);
  endfunction

endclass


class packet_small_large extends packet;

  `uvm_object_utils(packet_small_large)

  constraint C_small_large {
    payload.size() dist {
      [46:60]      := 50,    // small frames
      [1450:1500]  := 50     // large frames close to MTU
    };
  }

  function new(string name="packet_small_large");
    super.new(name);
  endfunction

endclass


class packet_small_ipg extends packet;

  `uvm_object_utils(packet_small_ipg)

  constraint C_small_ipg {
    ipg inside {[1:10]};   // very small interpacket gap
  }

  function new(string name="packet_small_ipg");
    super.new(name);
  endfunction

endclass


class packet_zero_ipg extends packet;

  `uvm_object_utils(packet_zero_ipg)

  constraint C_zero_ipg {
    ipg == 0;      // continuous packets, stress test
  }

  function new(string name="packet_zero_ipg");
    super.new(name);
  endfunction

endclass


`endif
