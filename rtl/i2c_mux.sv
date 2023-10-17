`timescale 1ns / 1ps

module i2c_mux
(
  input logic clk_i,
  
  input logic sl_i,

  input  logic scl_i,
  output logic scl_o,
  output logic scl_t, 
  input  logic sda_i,
  output logic sda_o,
  output logic sda_t,

  output logic scl_mi_o,
  input  logic scl_mo_i,
  input  logic scl_mt_i,
  output logic sda_mi_o,
  input  logic sda_mo_i,
  input  logic sda_mt_i,

  output logic scl_si_o,
  output logic sda_si_o,
  input  logic sda_so_i,
  input  logic sda_st_i
);

  always_ff @ (posedge clk_i)
    begin
      if (sl_i == 1'b0)
        begin
          scl_mi_o <= scl_i;
          scl_o    <= scl_mo_i;
          scl_t    <= scl_mt_i;
          sda_mi_o <= sda_i;
          sda_o    <= sda_mo_i;
          sda_t    <= sda_mt_i;
        end
      else
        begin
          scl_si_o <= scl_i;   
          sda_si_o <= sda_i;   
          sda_o    <= sda_so_i;
          sda_t    <= sda_st_i;
        end
    end

endmodule