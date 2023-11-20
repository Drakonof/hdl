`timescale 1ns / 1ps

module bit_rate_meter_tb_wrapper #
(
  parameter unsigned CLK_MHZ_VAL = 100,
  parameter unsigned DATA_WIDTH  = 32,

  localparam unsigned RES_WIDTH = 32
);
  logic                      clk;
  logic                      s_rst_n;

  logic                      data_valid;

  logic [RES_WIDTH - 1 : 0]  bit_rate;

  bit_rate_meter #
  (
    .CLK_MHZ_VAL (CLK_MHZ_VAL),
  
    .DATA_WIDTH  (DATA_WIDTH )
  )
  bit_rate_meter_dut
  (
    .clk_i        (clk       ),
    .s_rst_n_i    (s_rst_n   ),
  
    .data_valid_i (data_valid),

    .bit_rate_o   (bit_rate  )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, bit_rate_meter_tb_wrapper);
  end

endmodule
