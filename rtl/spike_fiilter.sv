`timescale 1ns / 1ps

module spike_filter #
(
  parameter unsigned DELAY_NUM = 50
)
(
  input  logic clk_i,
  input  logic s_rst_n_i,

  input  logic in_i,

  output logic out_o
);
  logic                     ok_flag;

  logic [DELAY_NUM - 1 : 0] delay;

  always_ff @( posedge clk_i )
    begin
       if (s_rst_n_i == 1'b0)
         begin
           delay <= 'h0;
         end
       else 
         begin
           delay <= {delay[DELAY_NUM - 2 : 0], in_i};
         end
    end

  always_ff @ (posedge clk_i)
    begin
       if (s_rst_n_i == 1'b0)
         begin
           ok_flag <= 1'b0;
         end
       else if (&delay == 'b1)
         begin
           ok_flag <= 1'b1;
         end
       else if (|delay == 'b0)
         begin
           ok_flag <= 1'b0;
         end
    end

  assign out_o = ok_flag;

endmodule