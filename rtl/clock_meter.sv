`timescale 1ns / 1ps


module clock_meter #
(
  parameter integer CLK_MHZ = 100,
  
  localparam integer MSR_CLK_VAL_WIDTH = 32
)
(
  input  logic                             clk_i,
  input  logic                             a_rst_n_i,
  
  input  logic                             msr_clk_i,
  
  output logic [MSR_CLK_VAL_WIDTH - 1 : 0] msr_clk_val_o
);
  
  
  localparam integer REF_CNT_NUM   = 10000000;
  localparam integer REF_CNT_WIDTH = $clog2(REF_CNT_NUM);
  
  localparam integer DECIM_CLK_MHZ  = CLK_MHZ / 10;
  
  
  logic [REF_CNT_WIDTH - 1 : 0]     ref_cnt;
  
  logic [MSR_CLK_VAL_WIDTH - 1 : 0] msr_cnt;
  logic [MSR_CLK_VAL_WIDTH - 1 : 0] msr_clk_val;
  logic                             msr_cnt_rst;
  logic [MSR_CLK_VAL_WIDTH - 1 : 0] gray_msr_cnt;
  
  logic [MSR_CLK_VAL_WIDTH - 1 : 0] res_msr_cnt;
  
  
  integer i;
  

  always_ff @(posedge clk_i)
    begin
      if (a_rst_n_i == 1'b0)
        begin
          ref_cnt <= 'h0;
        end
      else
        begin
          if (ref_cnt == (REF_CNT_NUM - 1))
            begin
              ref_cnt <= 'h0;
            end
          else
            begin
              ref_cnt <= ref_cnt + 1'b1;
            end
        end
    end
    
  
  always_ff @(posedge clk_i)
    begin
      if (a_rst_n_i == 1'b0)
        begin
          msr_cnt_rst <= 'h0;
        end
      else
        begin
          if (ref_cnt == (REF_CNT_NUM - 1))
            begin
              msr_cnt_rst <= 'h1;
            end
          else
            begin
              msr_cnt_rst <= 1'b0;
            end
        end
    end
  
  always_ff @(posedge msr_clk_i)
    begin
      if (a_rst_n_i == 1'b0)
        begin
          gray_msr_cnt <= 'h0;
          msr_cnt      <= 'h0;
        end
      else
        begin
          if (msr_cnt_rst == 1'b1)
            begin
              msr_cnt      <= 'h0;
              gray_msr_cnt <= 'h0;
            end
          else
            begin
              msr_cnt <= msr_cnt + 1'b1;
              
              for(i = 0; i < MSR_CLK_VAL_WIDTH - 1; i = i + 1)
                begin
                  gray_msr_cnt[i] <=  msr_cnt[i+1] ^ msr_cnt[i];
                end
                
              gray_msr_cnt[MSR_CLK_VAL_WIDTH - 1] <=  msr_cnt[MSR_CLK_VAL_WIDTH - 1];
            end
        end
    end
    
  always_ff @(posedge clk_i)
    begin
      if (a_rst_n_i == 1'b0)
        begin
          res_msr_cnt <= 'h0;
        end
      else if (ref_cnt == (REF_CNT_NUM - 1))
         begin
           for(i = 0;  i < MSR_CLK_VAL_WIDTH; i = i + 1)
               res_msr_cnt[i] <= ^(gray_msr_cnt >> i);
         end
      end
    
  always_ff @(posedge clk_i)
    begin
      if (a_rst_n_i == 1'b0)
        begin
          msr_clk_val <= 'h0;
        end
      else
        begin
          msr_clk_val <= DECIM_CLK_MHZ * res_msr_cnt;
        end
    end
    
  always_comb
    begin
       msr_clk_val_o = msr_clk_val;
    end

endmodule
