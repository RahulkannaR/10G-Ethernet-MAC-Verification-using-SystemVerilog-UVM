`ifndef BIND_ASSERTIONS_SV
`define BIND_ASSERTIONS_SV

`include "assertions_module.sv"

// Bind a pure-RV module instance to the DUT. This file must be compiled
// after xge_mac.v so the simulator knows the xge_mac scope & internal names.
bind xge_mac assertions_for_xge_mac inst_xge_mac_assertions (
    // map portname_in_assertions  (signal_in_xge_mac_scope)
    .clk_156    (clk_156m25),
    .rst_n      (reset_156m25_n),

    // FIFO (using interface/inst signals inside xge_mac)
    .fifo_write (pkt_tx_val),
    .fifo_read  (pkt_rx_ren),
    .fifo_full  (pkt_tx_full),
    .fifo_empty (~pkt_rx_avail),

    // Wishbone
    .wb_valid   (wb_stb_i),
    .wb_ack     (wb_ack_o),
    .wb_addr    (wb_adr_i),

    // XGMII - pick a single byte lane or adapt as needed
    .xgmii_ctrl (xgmii_txc[7:0]),   // if xgmii_txc is 8-bit control per lane
    .xgmii_data (xgmii_txd),

    // Packet fields — adapt if these nets exist in DUT, else leave tied/unused
    .pkt_len    (pkt_rx_mod),       // <- adjust if you have better net
    .etherType  (xgmii_txd[63:48])  // <- example if ethertype sits here; change if not
);

`endif
