`timescale 1ns / 1ps

module i2c_slave #
(
  parameter unsigned DATA_WIDTH = 8,
  
  localparam unsigned ADDR_WIDTH = DATA_WIDTH - 1,
  localparam unsigned DATA_BIT_NUM = $clog2(DATA_WIDTH)
)
(
  input logic clk_i,
  input logic s_rst_n_i,
    
 // input logic ack_en_i,
  input logic en_i,
    
  output logic [DATA_WIDTH - 1 : 0] data_o,
  input logic [DATA_WIDTH - 1 : 0] data_i,
  input logic [ADDR_WIDTH - 1 : 0] self_addr_i,
  
  
  input logic scl_i,
  input logic scl_o,
  input logic scl_t,
  
  input logic sda_i,
  output logic sda_o,
  output logic sda_t,
  
  input logic general_call_i
  
  //output logic status_o //x9 todo:
);

  localparam unsigned FSM_STATE_NUM = 9;
  localparam unsigned FSM_STATE_WIDTH = $clog2(FSM_STATE_NUM);
  
  typedef enum logic [FSM_STATE_WIDTH - 1  : 0] {
    IDLE_STATE,
    START_STATE,
    //REP_START_STATE,
    ADDR_STATE,
    WRITE_STATE,
    READ_STATE,
    RECV_ACK_STATE,
    SEND_ACK_STATE,
    STOP_STATE
  } fsm_state_t;
  
  fsm_state_t fsm_state;
  
  logic sda_prev;
  logic [ADDR_WIDTH - 1 : 0] self_addr;
  logic [DATA_BIT_NUM - 1 : 0] bit_counter;
  logic [DATA_WIDTH - 1  : 0] sent_data; 
  logic [DATA_WIDTH - 1  : 0] recv_data;  
  logic sda;
  
  
  always_ff @ (posedge clk_i)
    begin
      if (s_rst_n_i == 1'b0)
        begin
          fsm_state <= IDLE_STATE;
          sda_prev <= 1'h1;
         
         
         self_addr  <= self_addr_i;
         


          sent_data  <= 'h0;

        
        end
      else
        begin
          case (fsm_state)
          
            IDLE_STATE:
              begin
                fsm_state <= IDLE_STATE;
                sda_prev <= sda_i;
              
                if (en_i == 1'b1)
                  begin
                        fsm_state <= START_STATE;
                        self_addr  <= self_addr_i;
                        sent_data <= data_i;
                  end
              end
              
            START_STATE:
              begin
                if ((sda_prev == 1'h1) && (sda_i == 'h0) && (scl_i == 1'h1))
                  begin
                    fsm_state <= ADDR_STATE;
                  end
              end
              
            ADDR_STATE:
              begin
                if (scl_i == 1'h1)
                  begin
                    self_addr <= {self_addr[ADDR_WIDTH - 2 : 0], sda_i};
                    
                    bit_counter <= bit_counter + 'h1;
                    
                    if (bit_counter == 'h7)
                      begin
                        bit_counter <= 'h0;
                        
                        if (sda_i == 'h1)
                          begin
                            fsm_state <= WRITE_STATE;
                          end
                        else
                          begin
                            fsm_state <= READ_STATE;
                          end
                      end
                  end
              end
                  
              WRITE_STATE:
                begin
                  if (scl_i == 1'h1)
                    begin
                      sent_data <= {sent_data[DATA_WIDTH - 2 : 0], 1'h0};
                      sda <= sent_data[7];
                      
                      bit_counter <= bit_counter + 'h1;
                      sda_prev <= sda_i;
                      
                      if (bit_counter == 'h7)
                        begin
                          bit_counter <= 'h0;
                          
                          if ((sda_i == 1'h0) && (sda_prev == 1'h1))
                          fsm_state <= STOP_STATE;
                        end
                    end
                end
                
              READ_STATE:
                begin
                  if (scl_i == 1'h1)
                    begin
                      recv_data <= {recv_data[ADDR_WIDTH - 2 : 0], sda_i};
                      
                      bit_counter <= bit_counter + 'h1;
                      
                      if (bit_counter == 'h7)
                        begin
                          bit_counter <= 'h0;
                          
                          if ((sda_i == 1'h0) && (sda_prev == 1'h1))
                          fsm_state <= STOP_STATE;
                        end
                    end
                end
                
              STOP_STATE:
                begin
                  if (scl_i == 1'h1)
                    begin
                          sda <= 'h1;
                          fsm_state <= IDLE_STATE;
                          bit_counter <= 'h0;
                     end
                end
          endcase
        end
    end 
  
 assign sda_o = sda;

endmodule
