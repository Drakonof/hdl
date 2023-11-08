`timescale 1ns / 1ps

module single_port_ram_tb_wrapper #
(
  parameter unsigned DATA_WIDTH = 8,
  parameter unsigned ADDR_WIDTH = 8,
  
  parameter          IS_OUT_LATENCY = "false",  //"true", "false"

  parameter          INIT_FILE  = "ram_init.mem",

  localparam integer BYTE_VALID_WIDTH = DATA_WIDTH / 8
)
(
  input  logic                            clk_i,

  input  logic                            wr_en_i,

  input  logic [DATA_WIDTH - 1 : 0]       data_i,
  input  logic [BYTE_VALID_WIDTH - 1 : 0] byte_valid_i,
  input  logic [ADDR_WIDTH - 1 : 0]       addr_i,

  output logic [DATA_WIDTH - 1 : 0]       data_o
);

  single_port_ram #
  (
    .DATA_WIDTH      (DATA_WIDTH   ),
    .ADDR_WIDTH     (ADDR_WIDTH    ),

    .IS_OUT_LATENCY (IS_OUT_LATENCY),

    .INIT_FILE      (INIT_FILE     )
  )
  single_port_ram_dut (
    .clk_i        (clk_i       ),
    
    .wr_en_i      (wr_en_i     ),

    .data_i       (data_i      ),
    .addr_i       (addr_i      ),
    .byte_valid_i (byte_valid_i),

    .data_o       (data_o      )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, single_port_ram_tb_wrapper);
  end

endmodule
