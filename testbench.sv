// Code your testbench here
// or browse Examples
//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : xge_test_top.sv                                     //
//  Author    : G. Andres Mancera                                   //
//  License   : GNU Lesser General Public License                   //
//  Course    : System and Functional Verification Using UVM        //
//              UCSC Silicon Valley Extension                       //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef XGE_TEST_TOP__SV
`define XGE_TEST_TOP__SV

`include "uvm_macros.svh"
import uvm_pkg::*;

// RTL design Includes
`include "timescale.v"
`include "defines.v"

`include "generic_fifo.v"
`include "generic_fifo_ctrl.v"
`include "generic_mem_medium.v"
`include "generic_mem_small.v"
`include "meta_sync.v"
`include "meta_sync_single.v"
`include "rx_data_fifo.v"
`include "rx_dequeue.v"
`include "rx_enqueue.v"
`include "rx_hold_fifo.v"
`include "sync_clk_core.v"
`include "sync_clk_wb.v"
`include "sync_clk_xgmii_tx.v"
`include "tx_data_fifo.v"
`include "tx_dequeue.v"
`include "tx_enqueue.v"
`include "tx_hold_fifo.v"
`include "wishbone_if.v"
`include "CRC32_D8.v"
`include "CRC32_D64.v"
`include "fault_sm.v"
`include "xge_mac.v"

// the package (testbench classes)

// Interface
`include "xge_mac_interface.sv"
`include "package.sv"


module xge_test_top();
	

  logic         clk_156m25, clk_xgmii_rx, clk_xgmii_tx;
  logic         reset_156m25_n, reset_xgmii_rx_n, reset_xgmii_tx_n;
  logic         pkt_rx_ren, pkt_tx_eop, pkt_tx_sop, pkt_tx_val;
  logic         wb_clk_i, wb_cyc_i, wb_rst_i, wb_stb_i, wb_we_i;
  logic [63:0]  pkt_tx_data, xgmii_rxd;
  logic [2:0]   pkt_tx_mod;
  logic [7:0]   wb_adr_i, xgmii_rxc;
  logic [31:0]  wb_dat_i;
  logic         pkt_rx_avail, pkt_rx_eop, pkt_rx_err, pkt_rx_sop, pkt_rx_val, pkt_tx_full;
  logic         wb_ack_o, wb_int_o;
  logic [63:0]  pkt_rx_data, xgmii_txd;
  logic [3:0]   pkt_rx_mod;
  logic [31:0]  wb_dat_o;
  logic [7:0]   xgmii_txc;

  //-----------------------------------------------------------------
  // In order to enable waveform dumping, either uncomment the system
  // call below or use the +vcs+vcdpluson vcs command line option.
  //initial begin
  //  $vcdpluson();
  //end
  // Generate free running clocks
  initial begin
    clk_156m25      <= '0;
    clk_xgmii_rx    <= '0;
    clk_xgmii_tx    <= '0;
    wb_clk_i        <= '0;
    forever begin
      #3200;
      clk_156m25    = ~clk_156m25;
      clk_xgmii_rx  = ~clk_xgmii_rx;
      clk_xgmii_tx  = ~clk_xgmii_tx;
      wb_clk_i      = ~wb_clk_i;
    end
  end

// Instantiate xge_mac_interface
  xge_mac_interface     xge_mac_if  (
                                        .clk_156m25         (clk_156m25),
                                        .clk_xgmii_rx       (clk_xgmii_rx),
                                        .clk_xgmii_tx       (clk_xgmii_tx),
                                        .wb_clk_i           (wb_clk_i),
                                        .reset_156m25_n     (reset_156m25_n),
                                        .reset_xgmii_rx_n   (reset_xgmii_rx_n),
                                        .reset_xgmii_tx_n   (reset_xgmii_tx_n),
                                        .wb_rst_i           (wb_rst_i)
                                    );
	  initial begin
  uvm_config_db#(virtual xge_mac_interface)::set(null, "*", "vif", xge_mac_if);
end

  // Instantiate the xge_mac core DUT
  xge_mac   xge_mac_dut   ( // Outputs
                            .pkt_rx_avail       (xge_mac_if.pkt_rx_avail),
                            .pkt_rx_data        (xge_mac_if.pkt_rx_data),
                            .pkt_rx_eop         (xge_mac_if.pkt_rx_eop),
                            .pkt_rx_err         (xge_mac_if.pkt_rx_err),
                            .pkt_rx_mod         (xge_mac_if.pkt_rx_mod),
                            .pkt_rx_sop         (xge_mac_if.pkt_rx_sop),
                            .pkt_rx_val         (xge_mac_if.pkt_rx_val),
                            .pkt_tx_full        (xge_mac_if.pkt_tx_full),
                            .wb_ack_o           (xge_mac_if.wb_ack_o),
                            .wb_dat_o           (xge_mac_if.wb_dat_o),
                            .wb_int_o           (xge_mac_if.wb_int_o),
                            .xgmii_txc          (xge_mac_if.xgmii_txc),
                            .xgmii_txd          (xge_mac_if.xgmii_txd),
                            // Inputs
                            .clk_156m25         (clk_156m25),
                            .clk_xgmii_rx       (clk_xgmii_rx),
                            .clk_xgmii_tx       (clk_xgmii_tx),
                            .pkt_rx_ren         (xge_mac_if.pkt_rx_ren),
                            .pkt_tx_data        (xge_mac_if.pkt_tx_data),
                            .pkt_tx_eop         (xge_mac_if.pkt_tx_eop),
                            .pkt_tx_mod         (xge_mac_if.pkt_tx_mod),
                            .pkt_tx_sop         (xge_mac_if.pkt_tx_sop),
                            .pkt_tx_val         (xge_mac_if.pkt_tx_val),
                            .reset_156m25_n     (reset_156m25_n),
                            .reset_xgmii_rx_n   (reset_xgmii_rx_n),
                            .reset_xgmii_tx_n   (reset_xgmii_tx_n),
                            .wb_adr_i           (xge_mac_if.wb_adr_i),
                            .wb_clk_i           (wb_clk_i),
                            .wb_cyc_i           (xge_mac_if.wb_cyc_i),
                            .wb_dat_i           (xge_mac_if.wb_dat_i),
                            .wb_rst_i           (wb_rst_i),
                            .wb_stb_i           (xge_mac_if.wb_stb_i),
                            .wb_we_i            (xge_mac_if.wb_we_i),
                            .xgmii_rxc          (xge_mac_if.xgmii_rxc),
                            .xgmii_rxd          (xge_mac_if.xgmii_rxd)
                          );

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


endmodule : xge_test_top


`endif  // XGE_TEST_TOP__SV
