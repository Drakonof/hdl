`timescale 1ns / 1ps

module random_state_generator_tb_wrapper #
(
  parameter unsigned STATE_0_MIN_VAL = 10,
  parameter unsigned STATE_0_MAX_VAL = 20,
  parameter unsigned STATE_1_MIN_VAL = 30,
  parameter unsigned STATE_1_MAX_VAL = 40
)
(
  input  logic clk_i,
  input  logic s_rst_n_i,
    
  output logic state_o
);

  random_state_generator #
  (
    .STATE_0_MIN_VAL (STATE_0_MIN_VAL),
    .STATE_0_MAX_VAL (STATE_0_MAX_VAL),
    .STATE_1_MIN_VAL (STATE_1_MIN_VAL),
    .STATE_1_MAX_VAL (STATE_1_MAX_VAL)
  )
  random_state_generator_dut (
    .clk_i     (clk_i    ),
    .s_rst_n_i (s_rst_n_i),
    .state_o   (state_o  )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, random_state_generator_tb_wrapper);
  end

endmodule
