`ifndef COVERAGE__SV
`define COVERAGE__SV

// Coverage collector class (pure SV, no UVM macros)
class coverage_collector;

  // Clock signal for sampling
  logic clk;

  // Local copies to store latest packet and wishbone info
  bit [47:0]  mac_dst_addr_cg;
  bit [47:0]  mac_src_addr_cg;
  bit [15:0]  ether_type_cg;
  integer     payload_size_cg;

  // use same element type as pkt.payload (bit[7:0] array)
  bit [7:0]   payload_bytes_cg [] ;

  // Wishbone data
  wishbone_item wb_cg;

  // ---------------- PACKET COVERGROUP ------------------
  covergroup cg_packet @(posedge clk);

    // mac_dst is 48-bit, use 48-bit ranges / constants
    mac_dst: coverpoint mac_dst_addr_cg {
      bins low_range   = {[48'h0000_0000_0000 : 48'h00FF_FFFF_FFFF]};
      bins mid_range   = {[48'h0100_0000_0000 : 48'hFEFF_FFFF_FFFF]};
      bins high_range  = {[48'hFF00_0000_0000 : 48'hFFFF_FFFF_FFFF]};
    }

    ether_type: coverpoint ether_type_cg {
      bins ipv4       = {16'h0800};
      bins arp        = {16'h0806};
      bins vlan       = {16'h8100};
      bins ipv6       = {16'h86DD};
      bins other_vals = default;
    }

    payload_size: coverpoint payload_size_cg {
      bins small_sz  = {[0:45]};
      bins normal_sz = {[46:1500]};
      bins jumbo_sz  = {[1501:9000]};
    }

  endgroup


  // ---------------- WISHBONE COVERGROUP -----------------
  covergroup cg_wishbone @(posedge clk);

    wb_addr: coverpoint wb_cg.xtxn_addr {
      bins mac_conf1 = {8'h08};
      bins mac_conf2 = {8'h0C};
      bins others    = default;
    }

    wb_type: coverpoint wb_cg.xtxn_n {
      bins read  = {wishbone_item::READ};
      bins write = {wishbone_item::WRITE};
    }

  endgroup


  // Constructor
  function new(string name="", input logic clk_in);
    this.clk = clk_in;
    cg_packet = new();
    cg_wishbone = new();
  endfunction


  // ---------------- SAMPLING TASKS -----------------
  function void sample_packet(packet pkt);
    mac_dst_addr_cg  = pkt.mac_dst_addr;
    mac_src_addr_cg  = pkt.mac_src_addr;
    ether_type_cg    = pkt.ether_type;
    payload_size_cg  = pkt.payload.size();
    // copy payload bytes (types now match)
    payload_bytes_cg = pkt.payload;

    cg_packet.sample();
  endfunction


  function void sample_wishbone(wishbone_item wb);
    wb_cg = wb;
    cg_wishbone.sample();
  endfunction

endclass

`endif
