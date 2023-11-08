`timescale 1ns / 1ps

module rom_tb_wrapper #
(
  parameter unsigned DATA_WIDTH = 8,
  parameter unsigned ADDR_WIDTH = 8,
  parameter          INIT_FILE  = "rom_init.mem"
)
(
  input  logic                      clk_i,
  input  logic [ADDR_WIDTH - 1 : 0] addr_i,

  output logic [DATA_WIDTH - 1 : 0] data_o
);

  rom #
  (
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH ),
    .INIT_FILE  (INIT_FILE)
  )
  rom_dut (
    .clk_i  (clk_i ),
    .addr_i (addr_i),

    .data_o (data_o)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, rom_tb_wrapper);
  end

endmodule
