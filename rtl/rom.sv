//`include "./platform.vh"

module rom #
(
  parameter unsigned DATA_WIDTH = 8,
  parameter unsigned ADDR_WIDTH = 8,
  
`ifdef XILINX
  parameter          RAM_TYPE    = "block", // "distributed", "block"
`endif

  parameter          INIT_FILE  = ""
)
(
  input  logic                      clk_i,
  input  logic [ADDR_WIDTH - 1 : 0] addr_i,

  output logic [DATA_WIDTH - 1 : 0] data_o
);

  localparam unsigned MEM_DEPTH = 2 ** ADDR_WIDTH;

  logic [DATA_WIDTH - 1 : 0] data;

  int fd;

  initial 
    begin
    
`ifdef XILINX
      if ((RAM_TYPE != "distributed") || (RAM_TYPE != "block"))
        begin
          $fatal(1, "wrong ram_style");
        end
`endif

      if (INIT_FILE != "")
        begin
          fd = $fopen(INIT_FILE, "r");
          if (fd == '0) $fatal(1, "file doesn't exist");
          $fclose(fd);

          $display("loading rom by %s", INIT_FILE);
          $readmemh(INIT_FILE, rom_mem);
        end
      else
        begin
          $fatal(1, "init file is needed");
        end

    end
  
`ifdef XILINX
  (*ram_style = RAM_TYPE*)
`endif
  logic [DATA_WIDTH - 1 : 0] rom_mem [0 : MEM_DEPTH - 1];


  always_ff @ (posedge clk_i)
    begin
      data <= rom_mem[addr_i];
    end

  always_comb
    begin
      data_o = data;
    end

endmodule
