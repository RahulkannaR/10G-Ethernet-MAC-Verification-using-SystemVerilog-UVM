//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : env.sv                                              //
//  Author    : G. Andres Mancera                                   //
//  License   : GNU Lesser General Public License                   //
//  Course    : System and Functional Verification Using UVM        //
//              UCSC Silicon Valley Extension                       //
//                                                                  //
//////////////////////////////////////////////////////////////////////
`ifndef ENV__SV
`define ENV__SV

`include "reset_agent.sv"
`include "wishbone_agent.sv"
`include "packet_tx_agent.sv"
`include "packet_rx_agent.sv"
`include "xgmii_tx_agent.sv"
`include "xgmii_rx_agent.sv"
`include "scoreboard.sv"


class env extends uvm_env;
  virtual xge_mac_interface vif;   // <-- ADD THIS

  reset_agent       rst_agent;
  wishbone_agent    wshbn_agent;
  packet_tx_agent   pkt_tx_agent;
  packet_rx_agent   pkt_rx_agent;
  xgmii_tx_agent    xgmii_tx_agt;
  xgmii_rx_agent    xgmii_rx_agt;
  scoreboard        scbd;

  `uvm_component_utils(env)

  function new(input string name, input uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase( input uvm_phase phase );
    super.build_phase( phase );
    rst_agent      = reset_agent::type_id::create( "rst_agent", this );
    wshbn_agent    = wishbone_agent::type_id::create( "wshbn_agent", this );
    pkt_tx_agent   = packet_tx_agent::type_id::create( "pkt_tx_agent", this );
    pkt_rx_agent   = packet_rx_agent::type_id::create( "pkt_rx_agent", this );
    xgmii_tx_agt   = xgmii_tx_agent::type_id::create( "xgmii_tx_agt", this );
    xgmii_rx_agt   = xgmii_rx_agent::type_id::create( "xgmii_rx_agt", this );
    scbd           = scoreboard::type_id::create( "scbd", this );
    uvm_config_db#(virtual xge_mac_interface)::set(
    this, "scbd", "vif", xge_test_top.xge_mac_if );

  endfunction : build_phase


  virtual function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  // get interface from config db
  if (!uvm_config_db#(virtual xge_mac_interface)::get(this, "", "vif", vif))
    `uvm_fatal(get_name(), "Could not get virtual interface from config_db");

  // connect driver and monitor interfaces
  pkt_tx_agent.pkt_tx_drv.vif = vif;
  pkt_rx_agent.pkt_rx_mon.vif = vif;
  wshbn_agent.wshbn_drv.vif   = vif;
  wshbn_agent.wshbn_mon.vif   = vif;
  xgmii_tx_agt.xgmii_tx_mon.vif = vif;
  xgmii_rx_agt.xgmii_rx_mon.vif = vif;

endfunction


endclass : env

`endif  //ENV__SV
