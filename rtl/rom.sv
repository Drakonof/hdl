module rom #
(
  parameter unsigned DATA_WIDTH = 8,
  parameter unsigned ADDR_WIDTH = 8,
  
  parameter          INIT_FILE  = ""
)
(
  input  logic                      clk_i,
  input  logic [ADDR_WIDTH - 1 : 0] addr_i,

  output logic [DATA_WIDTH - 1 : 0] data_o
);

  localparam unsigned MEM_DEPTH = 2 ** ADDR_WIDTH;

  logic [DATA_WIDTH - 1 : 0] data;
  logic [DATA_WIDTH - 1 : 0] rom_mem [0 : MEM_DEPTH - 1];

  initial 
    begin
      if (INIT_FILE != "")
        begin
          $display("loading rom");
          $readmemh(INIT_FILE, rom_mem);
        end
      else
        begin
          $error("init file is needed");
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

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, rom);
  end

endmodule
