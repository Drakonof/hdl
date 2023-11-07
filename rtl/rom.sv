//`include "./platform.vh"

module rom #
(
  parameter unsigned DATA_WIDTH = 8,
  parameter unsigned ADDR_WIDTH = 8,
  
`ifdef XILINX
  parameter          RAM_TYPE    = "block", // "distributed", "block"
`endif

  parameter          INIT_FILE  = "/home/artem/H/hdl/tb/rom_tb/rom_init.mem"
)
(
  input  logic                      clk_i,
  input  logic [ADDR_WIDTH - 1 : 0] addr_i,

  output logic [DATA_WIDTH - 1 : 0] data_o
);

  localparam unsigned MEM_DEPTH = 2 ** ADDR_WIDTH;

  logic [DATA_WIDTH - 1 : 0] data;
  
`ifdef XILINX
  (*ram_style = RAM_TYPE*)
`endif
  logic [DATA_WIDTH - 1 : 0] rom_mem [0 : MEM_DEPTH - 1];

  initial 
    begin

`ifdef XILINX
      assert ((RAM_TYPE == "distributed") && (RAM_TYPE == "block"))
      else
        begin
          $fatal(1, "wrong ram_style");
        end
`endif

      assert (INIT_FILE != "")
        begin
          $display("loading rom");
          $readmemh(INIT_FILE, rom_mem);
        end
      else
        begin
          $fatal(1, "init file is needed");
        end
    end

  always_ff @ (posedge clk_i)
    begin
      data <= rom_mem[addr_i];
    end

  always_comb
    begin
      data_o = data;
    end

`ifndef XILINX
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, rom);
  end
`endif

endmodule
