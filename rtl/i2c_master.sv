//todo: arbitration lost

`timescale 1ns / 1ps


module i2c_master #
(
  parameter unsigned PRESC_WIDTH = 16,
  parameter unsigned DATA_WIDTH = 8,
  
  localparam unsigned ADDR_WIDTH = DATA_WIDTH - 1,
  localparam unsigned DATA_BIT_NUM = $clog2(DATA_WIDTH)
)
(
  input logic clk_i,
  input logic s_rst_n_i,
  
  input logic en_i,
  //todo: output logic ready_o, 
  
  input logic [PRESC_WIDTH - 1 : 0] prescale_i,
  input logic [DATA_WIDTH - 1 : 0] data_i,
  //todo: input logic [ADDR_WIDTH - 1 : 0] self_addr_i, 
  input logic [ADDR_WIDTH - 1 : 0] slave_addr_i,
  input logic dir_i,

  output logic scl_o, 
  //todo: input logic scl_i,
  //todo: output logic scl_t,
  
  output logic sda_o
  //todo: input logic sda_i,
  //todo: output logic sda_t
);


  localparam unsigned FSM_STATE_NUM = 9;
  localparam unsigned FSM_STATE_WIDTH = $clog2(FSM_STATE_NUM);


  typedef enum logic [FSM_STATE_WIDTH - 1  : 0] {
    IDLE_STATE,
    START_STATE,
    //todo: REP_START_STATE,
    ADDR_STATE,
    DIR_STATE,
    WRITE_STATE,
    READ_STATE,
    RECV_ACK_STATE,
    SEND_ACK_STATE,
    STOP_STATE
  } fsm_state_t;

  
  logic [PRESC_WIDTH - 1 : 0]  prescale;
  logic [PRESC_WIDTH - 1 : 0]  prescale_half;
  logic [DATA_WIDTH - 1 : 0]   sent_data; 
  logic [ADDR_WIDTH - 1 : 0]   slave_addr;
  logic                        dir;
  
  logic                        sda;
  logic                        scl_tick;
  logic [PRESC_WIDTH - 1 : 0]  scl_cntr;
  
  logic [DATA_BIT_NUM - 1 : 0] bit_counter;

  logic                        strob_tick;

  logic                        scl_strob;
  logic                        scl_strob_d;

  
  fsm_state_t fsm_state;
  

  always_ff @ (posedge clk_i)
    begin 
      if (s_rst_n_i == 1'b0)
        begin
          scl_tick   <= 'h1;
          scl_cntr   <= 'h0;
          strob_tick <= 1'h0;
        end
      else if (en_i == 1'h1)
        begin
          scl_cntr <= scl_cntr + 'h1;
          
          if ((fsm_state == IDLE_STATE) || 
              (fsm_state == STOP_STATE))
            begin
              scl_tick <= 'h1;
            end
          else if (scl_cntr == (prescale - 'h1))
            begin
              scl_tick <= !scl_tick;
              scl_cntr <= 'h0;
            end
          else if (scl_cntr == (prescale - 'h2))
            begin
              strob_tick <= !strob_tick;
            end
        end
    end

    always_ff @ (posedge clk_i)
      begin
        if (s_rst_n_i == 1'b0)
          begin
            scl_strob_d <= '0;
          end
        else
          begin
            scl_strob_d <= strob_tick;
          end
      end

  always_ff @ (posedge clk_i)
    begin
      if (s_rst_n_i == 1'b0)
        begin
          fsm_state     <= IDLE_STATE;

          prescale      <= 'h0;
          sent_data     <= 'h0;

          dir           <= 'h0;
          slave_addr    <= 'h0;
          sda           <= 'h1;
          
          bit_counter   <= 'h0;

          prescale_half <= 'h0;
        end
      else
        begin
          case (fsm_state)
          
            IDLE_STATE:
              begin
                fsm_state <= IDLE_STATE;
              
                if (en_i == 1'b1)
                  begin
                    fsm_state     <= START_STATE;

                    sent_data     <= data_i;
                    dir           <= dir_i;
                    slave_addr    <= slave_addr_i;
                    
                    prescale      <= prescale_i;
                    prescale_half <= {1'h0, prescale_i[PRESC_WIDTH - 1 : 1]};
                    
                    sda           <= 'h1;
                  end
              end
              
            START_STATE:
              begin
                if (scl_cntr == (prescale_half - 1))
                  begin
                    sda <= 'h0;
                  end
                
                if (scl_strob == 1'h1)
                  begin
                    fsm_state   <= ADDR_STATE;

                    bit_counter <= 'h0;
                    sda         <= slave_addr[6];
                    slave_addr  <= {slave_addr[ADDR_WIDTH - 2 : 0], 1'h0};
                  end
              end
              
            ADDR_STATE:
              begin
                if (scl_strob == 1'h1)
                  begin
                    slave_addr  <= {slave_addr[ADDR_WIDTH - 2 : 0], 1'h0};
                    sda         <= slave_addr[6];
                    bit_counter <= bit_counter + 'h1;

                    if (bit_counter == 'h6)
                      begin
                        bit_counter <= 'h0;
                        sda         <= dir;
                        
                        fsm_state   <= DIR_STATE;
                      end
                  end
              end

            DIR_STATE:
              begin
                if (scl_strob == 1'h1)  
                  begin
                    if (dir == 'h1)
                      begin
                        fsm_state <= WRITE_STATE;

                        sent_data <= {sent_data[DATA_WIDTH - 2 : 0], 1'h0};
                        sda <= sent_data[7];
                      end
                    else
                      begin
                        fsm_state <= READ_STATE;
                      end
                  end
              end
                  
              WRITE_STATE:
                begin
                  if (scl_strob == 1'h1) 
                    begin
                      sent_data   <= {sent_data[DATA_WIDTH - 2 : 0], 1'h0};
                      sda         <= sent_data[7];
                      
                      bit_counter <= bit_counter + 'h1;
                      
                      if (bit_counter == 'h7)
                        begin
                          bit_counter <= 'h0;
                          fsm_state   <= STOP_STATE;
                          sda         <= 'h0;
                        end
                    end
                end
                
              STOP_STATE:
                begin
                  if (scl_cntr == (prescale_half - 1))
                    begin
                      sda <= 'h1;
                    end
                end
          endcase
        end
    end 

    always_comb 
      begin
        scl_strob = ~strob_tick && scl_strob_d;
      end
    
    always_comb
      begin
        scl_o = scl_tick;
        sda_o = sda;
      end

    initial 
      begin
        $dumpfile("dump.vcd");
        $dumpvars(1, i2c_master);
      end
endmodule
