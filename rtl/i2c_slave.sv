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
  //input logic [DATA_WIDTH - 1 : 0] data_i,
  
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
  
  
  always_ff @ (posedge clk_i)
    begin
      if (s_rst_n_i == 1'b0)
        begin
          fsm_state <= IDLE_STATE;
         
         
         // self_addr  <= 'h0;
        
        end
      else
        begin
          case (fsm_state)
          
            IDLE_STATE:
              begin
                fsm_state <= IDLE_STATE;
              
                if (en_i == 1'b1)
                  begin
                    

                        fsm_state <= START_STATE;
                
             
                   
                  end
              end
              
            START_STATE:
              begin
                if ((sda_i == 'h0) && (scl_i == 1'h1))
                      begin
                        fsm_state <= START_STATE;
                      end
              end
              
            ADDR_STATE:
              begin
                if (scl_cntr == (prescale_quart - 1))
                  begin
                    slave_addr <= {slave_addr[ADDR_WIDTH - 2 : 0], 1'h0};
                    sda <= slave_addr[6];
                    bit_counter <= bit_counter + 'h1;
                    
                    if (bit_counter == 'h6)
                      begin
                        bit_counter <= 'h0;
                        
                        if (dir == 'h1)
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
                  if (scl_cntr == (prescale_quart - 1))
                    begin
                      sent_data <= {sent_data[DATA_WIDTH - 2 : 0], 1'h0};
                      sda <= sent_data[7];
                      
                      bit_counter <= bit_counter + 'h1;
                      
                      if (bit_counter == 'h7)
                        begin
                          bit_counter <= 'h0;
                          fsm_state <= STOP_STATE;
                        end
                    end
                end
                
              STOP_STATE:
                begin
                  sda <= 'h0;
                
                  if (scl_cntr == (prescale_half - 1))
                    begin
                      sda <= 'h1;
                      fsm_state <= IDLE_STATE;
                      bit_counter <= 'h0;
                    end
                end 
          
          endcase
        end
    end 
  
 

endmodule
