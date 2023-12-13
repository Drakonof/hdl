//`include "platform.vh"

`timescale 1 ns / 1 ps


`ifdef XILINX
  `resetall
  `default_nettype none
`endif


module axis_delay #
(
  parameter unsigned AXIS_DATA_WIDTH = 64

 // parameter unsigned DELAY_NR        = 1 //can't be null
)
(
  input logic                                  clk_i,
  
  output logic                                 m_axis_tvalid,
  output logic [AXIS_DATA_WIDTH - 1 : 0]       m_axis_tdata,
  output logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] m_axis_tstrb,
  output logic                                 m_axis_tlast,
  input  logic                                 m_axis_tready,
  
  input  logic                                 s_axis_tvalid,
  input  logic [AXIS_DATA_WIDTH - 1 : 0]       s_axis_tdata,
  input  logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] s_axis_tstrb,
  input  logic                                 s_axis_tlast,
  output logic                                 s_axis_tready
);


  logic                                 axis_tvalid_d;
  logic [AXIS_DATA_WIDTH - 1 : 0]       axis_tdata_d;
  logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] axis_tstrb_d;
  logic                                 axis_tlast_d;
  logic                                 axis_tready_d;


  always_ff @(posedge clk_i)
    begin
      axis_tvalid_d <= s_axis_tvalid;
      axis_tdata_d  <= s_axis_tdata;
      axis_tstrb_d  <= s_axis_tstrb;
      axis_tlast_d  <= s_axis_tlast;

      axis_tready_d <= m_axis_tready;
    end

  always_comb
    begin
      m_axis_tvalid = axis_tvalid_d & axis_tready_d;
      m_axis_tdata  = axis_tdata_d;
      m_axis_tstrb  = axis_tstrb_d;
      m_axis_tlast  = axis_tlast_d;

      s_axis_tready = m_axis_tready;
    end


endmodule