`ifndef ASSERTIONS_MODULE_SV
`define ASSERTIONS_MODULE_SV

// Pure SV module that instantiates assertions as properties.
// NOTE: Do NOT use UVM macros (uvm_error/UVM_NONE) inside here.
module assertions_for_xge_mac(
    input  logic        clk_156,
    input  logic        rst_n,

    input  logic        fifo_write,
    input  logic        fifo_read,
    input  logic        fifo_full,
    input  logic        fifo_empty,

    input  logic        wb_valid,
    input  logic        wb_ack,
    input  logic [7:0]  wb_addr,

    input  logic [7:0]  xgmii_ctrl,
    input  logic [63:0] xgmii_data,

  input  logic [2:0]        pkt_len,
    input  logic [15:0] etherType
);

    // ---------------- FIFO ----------------
    property p_fifo_no_overflow;
      @(posedge clk_156) disable iff (!rst_n)
        !(fifo_write && fifo_full);
    endproperty
    assert property (p_fifo_no_overflow);

    property p_fifo_no_underflow;
      @(posedge clk_156) disable iff (!rst_n)
        !(fifo_read && fifo_empty);
    endproperty
    assert property (p_fifo_no_underflow);

    // ---------------- Wishbone ----------------
    property p_wb_handshake_valid_ack;
      @(posedge clk_156) disable iff (!rst_n)
        wb_valid |-> ##[1:8] wb_ack;
    endproperty
    assert property (p_wb_handshake_valid_ack);

    property p_wb_addr_stable;
      @(posedge clk_156) disable iff (!rst_n)
        wb_valid |-> $stable(wb_addr);
    endproperty
    assert property (p_wb_addr_stable);

    // ---------------- XGMII ----------------
    property p_xgmii_ctrl_valid;
      @(posedge clk_156) disable iff (!rst_n)
        (xgmii_ctrl == 8'h01) |-> (xgmii_data inside {64'h07,64'hFB,64'hFD,64'h5C});
    endproperty
    assert property (p_xgmii_ctrl_valid);

    // ---------------- PACKET ----------------
    property p_pkt_min_length;
      @(posedge clk_156) disable iff (!rst_n)
        (pkt_len > 0) |-> (pkt_len >= 64);
    endproperty
    assert property (p_pkt_min_length);

    property p_pkt_max_length;
      @(posedge clk_156) disable iff (!rst_n)
        (pkt_len > 0) |-> (pkt_len <= 1518);
    endproperty
    assert property (p_pkt_max_length);

endmodule

`endif
