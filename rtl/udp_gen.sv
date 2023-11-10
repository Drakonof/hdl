//`include "platform.vh"

//`resetall
//`default_nettype none

`timescale 1ps/1ps

//todo: interface, struct

//(* dont_touch = "yes" *)
module udp_gen #
(
  localparam unsigned DATA_WIDTH = 64,
  
  localparam unsigned MAC_ADDR_WIDTH = 48,
  parameter [MAC_ADDR_WIDTH - 1 : 0] MAC_ADDR = 48'h1A1B1C1D1E1F,
  
  localparam unsigned LT_WIDTH = 16,
  parameter [LT_WIDTH - 1 : 0] LT = 16'h1800, //?? without size
  
  localparam unsigned IPV4_ADDR_WIDTH = 32,
  localparam unsigned UDP_PORT_WIDTH = 16
)
(
  input  logic                           clk_i,
  input  logic                           s_rst_n_i,
  
  input  logic                           en_i,
  

  input  logic [MAC_ADDR_WIDTH - 1 : 0]  dst_mac_addr_i,
  
  input  logic [IPV4_ADDR_WIDTH - 1 : 0] src_ipv4_addr_i, //format???
  input  logic [IPV4_ADDR_WIDTH - 1 : 0] dst_ipv4_addr_i,

  input  logic [UDP_PORT_WIDTH - 1 : 0] src_udp_port_i, // format???
  input  logic [UDP_PORT_WIDTH - 1 : 0] dst_udp_port_i,
  
  output logic [DATA_WIDTH - 1 : 0]     data_o,
  output logic                          data_valid_o,       
  output logic                          frame_end_o
);
 
  localparam unsigned                MIN_DATA_SIZE   = 64;   // 46 bytes payload
  localparam unsigned                MAX_DATA_SIZE   = 1518; // 1500 bytes payload
  
  localparam unsigned                FMS_STATE_NR    = 8;
  localparam unsigned                FMS_STATE_WIDTH = $clog2(FMS_STATE_NR);
  
  localparam unsigned                COUNTER_WIDTH    = 16;
  localparam [COUNTER_WIDTH - 1 : 0] COUNTER_MAX_VAL = 16'h50; // 'h50
  
  //todo:
  localparam unsigned                GAP_COUNTER_VAL = 12;
  localparam unsigned                GAP_COUNTER_WIDTH = $clog2(GAP_COUNTER_MAX_VAL);
  localparam unsigned                GAP_COUNTER_MAX_VAL = 'd12;
  
  
  typedef enum logic [FMS_STATE_WIDTH - 1 : 0] {
    IDLE_STATE,
    MAC_1_STATE,
    MAC_2_STATE,
    IP_1_STATE,
    IP_2_STATE,
    UDP_1_STATE,
    DATA_1_STATE,
    DATA_2_STATE
  } fsm_state_t;

  
  fsm_state_t fsm_state;
  fsm_state_t next_fsm_state;
  
  logic [MAC_ADDR_WIDTH - 1 : 0]  dst_mac_addr;
  
  logic [IPV4_ADDR_WIDTH - 1 : 0] src_ipv4_addr;
  logic [IPV4_ADDR_WIDTH - 1 : 0] dst_ipv4_addr;
  
  logic [UDP_PORT_WIDTH - 1 : 0]  src_udp_port;
  logic [UDP_PORT_WIDTH - 1 : 0]  dst_udp_port;
  
  logic [COUNTER_WIDTH - 1 : 0]   counter;

  
  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'h0)
        begin
          dst_mac_addr  <= '0;
          
          src_ipv4_addr <= '0;
          dst_ipv4_addr <= '0;
          
          src_udp_port  <= '0;
          dst_udp_port  <= '0;
        end
      else if (en_i == 'h1)
        begin
          dst_mac_addr <= dst_mac_addr_i;
          
          src_ipv4_addr <= src_ipv4_addr_i;
          dst_ipv4_addr <= dst_ipv4_addr_i;
          
          src_udp_port  <= src_udp_port_i;
          dst_udp_port  <= dst_udp_port_i;
        end
    end
    
  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'h0)
        begin
          counter <= '0;
        end
      else if (fsm_state == DATA_1_STATE)
        begin
          counter <= counter + 1'h1;
        end
    end
  
  // 1
  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'h0)
        begin
          fsm_state <= IDLE_STATE;
        end
      else if (en_i == 'h1)
        begin
          fsm_state <= next_fsm_state;
        end
    end
    
  // 2
  always_comb
    begin
      next_fsm_state = fsm_state;
      
      case (fsm_state)
      
      IDLE_STATE:
        begin
          if (en_i == 'h1)
            begin
              next_fsm_state = MAC_1_STATE;
            end
        end
        
      MAC_1_STATE:
        begin
          next_fsm_state = MAC_2_STATE;
        end
        
      MAC_2_STATE:
        begin
          next_fsm_state = IP_1_STATE;
        end
        
      IP_1_STATE:
        begin
          next_fsm_state = IP_2_STATE;
        end
        
      IP_2_STATE:
        begin
          next_fsm_state = UDP_1_STATE;
        end
      
      UDP_1_STATE:
        begin
          next_fsm_state = DATA_1_STATE;
        end
        
      DATA_1_STATE:
        begin
          if (counter == (COUNTER_MAX_VAL - 1))
            begin
              next_fsm_state = DATA_2_STATE;
            end
        end
        
      DATA_2_STATE:
        begin
          if (counter == COUNTER_MAX_VAL)
            begin
              next_fsm_state = IDLE_STATE;
            end
        end
        
      default:
        begin
          next_fsm_state = fsm_state;
        end
      
      endcase
    end
    
  // 3
  always_comb
    begin
      case (fsm_state)
      
      IDLE_STATE:
        begin
          data_valid_o = '0;
          frame_end_o  = '0;

          data_o       = '0;
        end
        
      MAC_1_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = '0;
          
          data_o       = {dst_mac_addr, MAC_ADDR[15 : 0]}; // signal racing?
        end
        
      MAC_2_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = '0;
          
          data_o       = {MAC_ADDR[47 : 16], LT, 16'haaaa}; //todo: ip Vertion, IHL, DSCP, ECN
        end
        
      IP_1_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = '0;
          
          data_o  = {16'hbbbb, 16'hcccc, 16'hdddd, 8'hee, 8'hff}; //todo: ip total lenght, identification, flag + fragment offset, time to live, protocol
        end
        
      IP_2_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = '0;
          
          data_o  = {16'h1111, src_ipv4_addr, dst_ipv4_addr[15 : 0]}; //todo: header checksum, src ip, dst ip [15:0]
        end
        
      UDP_1_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = '0;
          
          data_o       = {dst_ipv4_addr[31 : 16], src_udp_port, dst_udp_port, COUNTER_MAX_VAL}; //todo: dst ip [31:16], src port, dst port lengh !! 16'h8 + COUNTER_MAX_VAL
        end
        
      DATA_1_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = '0;
          
          data_o  = {48'h0, counter}; //  !'0
        end
        
      DATA_2_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = 'h1;
          
          data_o       = {48'h0, counter}; //  !'0
        end
        
      default:
        begin
          data_valid_o = '0;
          frame_end_o  = '0;
        end
        
      endcase
    end

endmodule