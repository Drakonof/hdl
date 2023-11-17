`timescale 1 ns / 1 ps

module bit_rate_meter #
(
  parameter unsigned CLK_MHZ_VAL = 100,

  localparam unsigned RES_WIDTH = 32
)
(
  input  logic                      clk_i,
  input  logic                      s_rst_n_i,

  input  logic                      data_valid_i,

  output logic [RES_WIDTH - 1 : 0]  bit_rate_i
);

  
  localparam unsigned                     TICKS_PER_SEC      = CLK_MHZ_VAL * 1000000;
  localparam unsigned                     TICK_COUNTER_WIDTH = $clog2(TICKS_PER_SEC);
  localparam [TICK_COUNTER_WIDTH - 1 : 0] TICKS_NR           = TICKS_PER_SEC;


  logic [TICK_COUNTER_WIDTH - 1 : 0] tick_counter;

  logic [RES_WIDTH - 1 : 0] bit_counter;
  logic [RES_WIDTH - 1 : 0] bit_rate;
  

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 'h1)
      	begin
      	  tick_counter <= '0;
      	  get_val_flag <= '0;
      	end
      else
        begin
          if (tick_counter == (TICKS_NR - 'h1))
            begin
              tick_counter <= '0;
              get_val_flag <= 'h1;
            end
          else
            begin
              tick_counter <= tick_counter + 'h1;
              get_val_flag <= '0;
            end
        end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 'h1)
      	begin
      	  bit_counter <= '0;
      	  bit_rate    <= '0;
      	end
      else
        begin
          if (get_val_flag == 'h1)
            begin
              bit_counter <= '0;
              bit_rate    <= bit_counter;
            end
          else if (data_valid_i == 'h1)
            begin
              bit_counter <= bit_counter + 'h1;
            end
        end
    end

  always_comb
    begin
      bit_rate_i = bit_rate;
    end


endmodule