`timescale 1ns / 1ps

// uncommet that if debug logs are needed
//`define DEBUG

module random_state_generator # 
(
  parameter unsigned STATE_0_MIN_VAL = 10,
  parameter unsigned STATE_0_MAX_VAL = 20,
  parameter unsigned STATE_1_MIN_VAL = 30,
  parameter unsigned STATE_1_MAX_VAL = 40
)
(
  input  logic clk_i,
  input  logic s_rst_n_i,
    
  output logic state_o
);

  bit value_switch;
    
  int  counter = 0;
  int  limit   = 0;
    
  always_ff @ (posedge clk_i)
    begin
      if (s_rst_n_i == 1'h0) 
        begin
          counter = 0;
          limit   = $urandom_range(STATE_0_MIN_VAL , STATE_0_MAX_VAL );
`ifdef DEBUG
          $display("limit by reset: %d", limit);
`endif
          value_switch <= 'h0;
          state_o      <= 'h0;
        end
      else 
        begin
          if (value_switch == 1'h0)
            begin
              if (counter == (limit - 1))
                begin
                  counter = 0;
                  limit   = $urandom_range(STATE_1_MIN_VAL , STATE_1_MAX_VAL );
`ifdef DEBUG
                  $display("limit in value_switch == 0: %d", limit);
`endif
                  value_switch <= 'h1;
                  state_o      <= 'h1;
                end
              else 
                begin
                  ++counter;
                  state_o <= 'h0;
                end
            end
          else
            begin 
              if (counter == (limit - 1)) 
                begin
                  counter = 0;
                  limit   = $urandom_range(STATE_0_MIN_VAL , STATE_0_MAX_VAL );
`ifdef DEBUG
                  $display("limit in value_switch == 1: %d", limit);
`endif
                  value_switch <= 'h0;
                  state_o      <= 'h0;
                end
              else 
                begin
                  ++counter;
                  state_o <= 'h1;
                end
            end
          end
        end
      
  always @ (*)
    begin
      assert ((STATE_0_MIN_VAL > STATE_0_MAX_VAL) ||
             (STATE_1_MIN_VAL > STATE_1_MAX_VAL))
        begin  
          $error("The module parameters error.");
        end
    end

endmodule
