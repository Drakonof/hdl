`timescale 1ns / 1ps


module axis_delay_tb_wrapper #
(
  parameter unsigned AXIS_DATA_WIDTH = 64
);


  logic                                 clk;

  logic                                 m_axis_tvalid;
  logic [AXIS_DATA_WIDTH - 1 : 0]       m_axis_tdata;
  logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] m_axis_tstrb;
  logic                                 m_axis_tlast;
  logic                                 m_axis_tready;
  
  logic                                 s_axis_tvalid;
  logic [AXIS_DATA_WIDTH - 1 : 0]       s_axis_tdata;
  logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] s_axis_tstrb;
  logic                                 s_axis_tlast;
  logic                                 s_axis_tready;


  axis_delay #
  (
    .AXIS_DATA_WIDTH (AXIS_DATA_WIDTH)
  )
  axis_delay_dut
  (
    .clk_i         (clk          ),

    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tdata  (m_axis_tdata ),
    .m_axis_tstrb  (m_axis_tstrb ),
    .m_axis_tlast  (m_axis_tlast ),
    .m_axis_tready (m_axis_tready),

    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tdata  (s_axis_tdata ),
    .s_axis_tstrb  (s_axis_tstrb ),
    .s_axis_tlast  (s_axis_tlast ),
    .s_axis_tready (s_axis_tready)
  );


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, axis_delay_tb_wrapper);
  end


endmodule
