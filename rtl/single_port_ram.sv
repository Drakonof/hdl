/*
single_port_ram #
(
  .DATA_WIDTH     (), // default: 8
  .ADDR_WIDTH     (), // default: 8

  .IS_OUT_LATENCY (), // default: "false", cases: "true", "false"
                    
  .RAM_TYPE       (), // default: "block", cases: "distributed", "block"
  .INIT_FILE_NAME ()  // default: ""
)
single_port_ram_inst
(
  .wr_clk_i        (),
    
  .wr_en_i         (),
  .wr_data_i       (), // width: DATA_WIDTH
  .wr_byte_valid_i (), // width: BYTE_VALID_WIDTH width
  .wr_addr_i       (), // width: ADDR_WIDTH

  .rd_clk_i        (),

  .rd_en_i         (),
  .rd_data_o       (), // width: DATA_WIDTH
  .rd_data_valid_o (),
  .rd_addr_i       ()  // width: DATA_WIDTH
);
*/

//todo: assert, reset?

`timescale 1ns / 1ps

module single_port_ram #
(
  parameter integer DATA_WIDTH     = 8,
  parameter integer ADDR_WIDTH     = 8,

  parameter   IS_OUT_LATENCY = "true",  //"true", "false"

  parameter   RAM_TYPE       = "block", // "distributed", "block"
  parameter   INIT_FILE_NAME = "", 

  localparam integer BYTE_VALID_WIDTH = DATA_WIDTH / 8,
  localparam integer MEM_DEPTH        = 2 ** ADDR_WIDTH
)
(
  input  logic                            clk_i,

  input  logic                            wr_en_i,
  input  logic [DATA_WIDTH - 1 : 0]       data_i,
  input  logic [BYTE_VALID_WIDTH - 1 : 0] byte_valid_i,
  input  logic [ADDR_WIDTH - 1 : 0]       addr_i,

  output logic [DATA_WIDTH - 1 : 0]       data_o
);

  (*ram_style = RAM_TYPE*) 
  logic [DATA_WIDTH - 1 : 0] mem [0 : MEM_DEPTH - 1];
  logic [DATA_WIDTH - 1 : 0] rd_data;

  generate
    if (INIT_FILE_NAME != "") 
      begin: init_file
        initial 
          begin
            $readmemh(INIT_FILE_NAME, mem, 0, MEM_DEPTH - 1);
          end
      end 
  endgenerate

  always_ff @(posedge clk_i) 
    begin  
      if (wr_en_i == 1'h1) 
        begin 
          for (int i = 0; i < BYTE_VALID_WIDTH; i++) 
            begin
              if (byte_valid_i[i] == 1'h1) 
                begin
                  mem[addr_i][(i * 8) +: 8] <= data_i[(i * 8) +: 8];
                end
            end
        end
      
        rd_data <= mem[addr_i];
    end

  generate 
    if (IS_OUT_LATENCY == "true") 
      begin
        always_ff @(posedge clk_i) 
          begin  
            data_o <= rd_data;
          end
      end
    else 
      begin
        always_comb
          begin
            data_o = rd_data;
          end
      end
  endgenerate

endmodule