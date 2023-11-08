`timescale 1ns / 1ps

module simple_dual_port_ram_tb_wrapper #
(
  parameter unsigned DATA_WIDTH = 8,
  parameter unsigned ADDR_WIDTH = 8,
  
  parameter          IS_OUT_LATENCY = "false",  //"true", "false"

  parameter          INIT_FILE  = "ram_init.mem",

  localparam integer BYTE_VALID_WIDTH = DATA_WIDTH / 8
)
(
  input  logic                            wr_clk_i,

  input  logic                            wr_en_i,
  input  logic [DATA_WIDTH - 1 : 0]       wr_data_i,
  input  logic [BYTE_VALID_WIDTH - 1 : 0] wr_byte_valid_i,
  input  logic [ADDR_WIDTH - 1 : 0]       wr_addr_i,

  input  logic                            rd_clk_i,

  input  logic                            rd_en_i,
  output logic [DATA_WIDTH - 1 : 0]       rd_data_o,
  input  logic [ADDR_WIDTH - 1 : 0]       rd_addr_i
);

  simple_dual_port_ram #
  (
    .DATA_WIDTH      (DATA_WIDTH   ),
    .ADDR_WIDTH     (ADDR_WIDTH    ),

    .IS_OUT_LATENCY (IS_OUT_LATENCY),

    .INIT_FILE      (INIT_FILE     )
  )
  simple_dual_port_ram_dut (
    .wr_clk_i        (wr_clk_i       ),
    
    .wr_en_i         (wr_en_i        ),
    .wr_data_i       (wr_data_i      ),
    .wr_byte_valid_i (wr_byte_valid_i),
    .wr_addr_i       (wr_addr_i      ),

    .rd_clk_i        (rd_clk_i       ),

    .rd_en_i         (rd_en_i        ),
    .rd_data_o       (rd_data_o      ),
    .rd_addr_i       (rd_addr_i      )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, simple_dual_port_ram_tb_wrapper);
  end

endmodule
