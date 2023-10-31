//todo: ack, status, repstart, read, myltibytes pack for read and write, arbitration lost, tri state buffer control, self_addr, ready, platform and preprocessor, timeout
//todo: resorses and power and timing optimization

`timescale 1ns / 1ps


module i2c_master #
(
  parameter unsigned PRESC_WIDTH = 16,
  parameter unsigned DATA_WIDTH  = 8,
  
  localparam unsigned ADDR_WIDTH   = DATA_WIDTH - 1,
  localparam unsigned DATA_BIT_NUM = $clog2(DATA_WIDTH)
)
(
  input  logic                       clk_i,
  input  logic                       s_rst_n_i,
  
  input  logic                       en_i,
  
  input  logic [PRESC_WIDTH - 1 : 0] prescale_i,
  input  logic [DATA_WIDTH - 1 : 0]  data_i,

  input  logic [ADDR_WIDTH - 1 : 0]  slave_addr_i,
  input  logic dir_i,

  input  logic                       stop_i, // maybe make it to ctrl bus width of eight?
  input  logic                       write_i,// 

  output logic [DATA_WIDTH - 1 : 0]  status_o, // |r|r|r|r|r|addr sent|end of read|end of write|

  output logic                       scl_o, 
  //todo: input  logic                      scl_i,
  //todo: output logic                      scl_t,
  
  output logic                       sda_o,
  input  logic                       sda_i
  //todo: output logic                      sda_t
);


  localparam unsigned FSM_STATE_NUM = 9;
  localparam unsigned FSM_STATE_WIDTH = $clog2(FSM_STATE_NUM);


  typedef enum logic [FSM_STATE_WIDTH - 1  : 0] {
    IDLE_STATE,
    START_1_STATE,
    START_2_STATE,
    REP_START_STATE,
    ADDR_STATE,
    DIR_STATE,
    SEND_DATA_STATE,
    RECV_DATA_STATE,
    RECV_ACK_STATE,
    SEND_ACK_STATE,
    STOP_1_STATE,
    STOP_2_STATE,
    ACK_STATE
  } fsm_state_t;

  
  logic [PRESC_WIDTH - 1 : 0]  prescale;
  logic [PRESC_WIDTH - 1 : 0]  prescale_half;
  logic [DATA_WIDTH - 1 : 0]   sent_data;
  logic [DATA_WIDTH - 1 : 0]   recv_data; 
  logic [ADDR_WIDTH - 1 : 0]   slave_addr;
  logic                        dir;
  
  logic                        sda;
  logic                        scl;
  logic [PRESC_WIDTH - 1 : 0]  scl_cntr;
  
  logic [DATA_BIT_NUM - 1 : 0] bit_counter;

  logic                        strob_tick;

  logic                        scl_strob;
  logic                        scl_strob_d;

  logic [DATA_WIDTH - 1 : 0]   status;

  
  fsm_state_t fsm_state;
  fsm_state_t next_state;
  

  always_ff @(posedge clk_i)
    begin 
      if (s_rst_n_i == 1'b0)
        begin
          scl <= 'h1;
        end
      else if (en_i == 1'h1)
        begin
          if ((fsm_state == IDLE_STATE)    || 
              (fsm_state == START_1_STATE) ||
              (fsm_state == STOP_2_STATE))
            begin
              scl <= 'h1;
            end
          else if (scl_cntr == (prescale - 'h1))
            begin
              scl <= !scl;
            end
        end
      //else ?
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'b0)
        begin
          strob_tick <= '0;
        end
      else
        begin
          if (scl_cntr == (prescale - prescale_half - 'h2))
            begin
              strob_tick <= !strob_tick;
            end
        end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'b0)
        begin
          scl_cntr   <= 'h0;
        end
      else if (scl_cntr == (prescale - 'h1))
        begin
          scl_cntr <= 'h0;
        end
      else if (fsm_state != IDLE_STATE)
        begin
          scl_cntr <= scl_cntr + 'h1; // + en_i?
        end
      end

  always_ff @(posedge clk_i)
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

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'b0)
        begin
          dir           <= '0;

          prescale      <= '0;
          prescale_half <= '0;
        end
      else if (fsm_state == START_1_STATE)
        begin
          dir           <= dir_i;

          prescale      <= prescale_i;
          prescale_half <= {1'h0, prescale_i[PRESC_WIDTH - 1 : 1]};
      end
  end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'b0)
        begin
          bit_counter <= 'h0;
        end
      else if ((fsm_state == ADDR_STATE) || (fsm_state == SEND_DATA_STATE))
        begin
          if (scl_strob == 1'h1)
            begin
              bit_counter <= bit_counter + 'h1;
            end
        end
      else if ((fsm_state == START_2_STATE) || (fsm_state == DIR_STATE))
        begin
          bit_counter <= '0;
        end
    end


  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'b0)
        begin
          slave_addr <= '0;
        end
      else if (fsm_state == START_1_STATE)
        begin
          slave_addr <= slave_addr_i;
        end
      else if ((fsm_state == ADDR_STATE) && (scl_strob == 1'h1))
        begin
          slave_addr  <= {slave_addr[ADDR_WIDTH - 2 : 0], 1'h0};
        end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'b0)
        begin
          sent_data <= 'h0;
        end
      else if (fsm_state == START_1_STATE)
        begin
          sent_data <= data_i;
        end
      else if ((fsm_state == SEND_DATA_STATE) && (scl_strob == 1'h1))
        begin
          sent_data <= {sent_data[DATA_WIDTH - 2 : 0], 1'h0};
        end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'b0)
        begin
          recv_data <= 'h0;
        end
      else if (fsm_state == START_1_STATE)
        begin
          recv_data     <= '0;
        end
      else if ((fsm_state == RECV_DATA_STATE) && (scl_strob == 1'h1))
        begin
          recv_data <= {recv_data[DATA_WIDTH - 2 : 0], sda_i};
        end
    end

  //1
  always_ff @ (posedge clk_i)
    begin
      if (s_rst_n_i == 1'b0)
        begin
          fsm_state <= IDLE_STATE;
        end
      else
        begin
          fsm_state <= next_state;
        end
    end

  //2
  always_comb
    begin
      next_state = fsm_state;

      case (fsm_state)

      IDLE_STATE:
        begin
          if (en_i == 1'b1)
            begin
              next_state = START_1_STATE;
            end
        end

      START_1_STATE:
        begin
        if (scl_cntr == (prescale_half - 1))
          begin
            next_state = START_2_STATE;
          end
        end

      START_2_STATE:
        begin
          if (scl_strob == 1'h1)
            begin
              next_state = ADDR_STATE;
            end
        end
      
      ADDR_STATE:
        begin
          if ((scl_strob == 1'h1) && (bit_counter == 'h6))
            begin
              next_state = DIR_STATE;
            end
        end

      DIR_STATE:
        begin
          if (scl_strob == 1'h1)
            begin
              next_state = RECV_ACK_STATE;
            end
        end
      
      SEND_DATA_STATE:
        begin
          if (scl_strob == 1'h1)
            begin
              if (bit_counter == 'h7)
                begin
                  next_state = RECV_ACK_STATE;
                end
            end
        end

      RECV_DATA_STATE:
        begin
          if (scl_strob == 1'h1)
            begin
              if (bit_counter == 'h7)
                begin
                  next_state = STOP_1_STATE;
                end
            end
        end

      RECV_ACK_STATE:
        begin
          if ((scl_strob == 1'h1) && (sda_i == 1'h0))
            begin
              if (stop_i == 1'h1)
                begin
                  next_state = STOP_1_STATE;
                end
              else if (write_i == 1'h1)
                begin
                  if (dir == 'h0)
                    begin
                      next_state = SEND_DATA_STATE;
                    end
                  else
                    begin
                      next_state = RECV_DATA_STATE;
                    end
                end
            end
        end

      STOP_1_STATE:
        begin
          if (scl_cntr == (prescale_half - 1))
            begin
              next_state = STOP_2_STATE;
            end
        end

      STOP_2_STATE:
        begin
          if (scl_strob == 1'h1)
            begin
              next_state = STOP_2_STATE;
            end
        end

      default:
        begin
          next_state = fsm_state;
        end

    endcase
  end
  
  //3
  always_comb
    begin
      case (fsm_state)
          
      IDLE_STATE:
        begin
          sda = 'h1;
        end
              
      START_1_STATE:
        begin
          if (scl_cntr > (prescale_half - 1))
            begin
              sda = 'h0;
            end
          else
            begin
              sda = 'h1;
            end
        end

      START_2_STATE:
        begin
          sda = 'h0;
        end

      ADDR_STATE:
        begin
          sda = slave_addr[6];
        end

      DIR_STATE:
        begin
          sda = dir;
        end
                  
      SEND_DATA_STATE:
        begin
          sda = sent_data[7];         
         end

      RECV_DATA_STATE:
        begin
        end

      STOP_1_STATE:
        begin
          sda = 'h0;
        end
                
      STOP_2_STATE:
        begin
          if (scl_cntr > (prescale_half - 1))
            begin
              sda = 'h1;
            end
          else
            begin
              sda = 'h0;
            end
        end

      default:
        begin
          sda = 1'h1;
        end

      endcase
    end 

  always_comb 
    begin
      scl_strob = ~strob_tick && scl_strob_d;
    end
    
  always_comb
    begin
      scl_o = scl;
      sda_o = sda;

      status_o = status;
    end

  initial 
    begin
      $dumpfile("dump.vcd");
      $dumpvars(1, i2c_master);
    end

endmodule
