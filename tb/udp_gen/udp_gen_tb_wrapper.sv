`timescale 1ns / 1ps

module udp_gen_tb_wrapper #
(
  localparam unsigned DATA_WIDTH = 64,
  
  localparam unsigned MAC_ADDR_WIDTH = 48,
  parameter [MAC_ADDR_WIDTH - 1 : 0] MAC_ADDR = 48'h1A1B1C1D1E1F,
  
  localparam unsigned LT_WIDTH = 16,
  parameter [LT_WIDTH - 1 : 0] LT = 16'h0800,
  
  localparam unsigned IPV4_ADDR_WIDTH = 32,
  localparam unsigned UDP_PORT_WIDTH = 16
);
  logic                           clk;
  logic                           s_rst_n;
  
  logic                           en;

  logic [MAC_ADDR_WIDTH - 1 : 0]  dst_mac_addr;
  
  logic [IPV4_ADDR_WIDTH - 1 : 0] src_ipv4_addr;
  logic [IPV4_ADDR_WIDTH - 1 : 0] dst_ipv4_addr;

  logic [UDP_PORT_WIDTH - 1 : 0]  src_udp_port;
  logic [UDP_PORT_WIDTH - 1 : 0]  dst_udp_port;

  udp_gen_inf data_inf();

  udp_gen #
  (
    .MAC_ADDR (MAC_ADDR),
  
    .LT       (LT      )
  )
  udp_gen_dut
  (
    .clk_i           (clk          ),
    .s_rst_n_i       (s_rst_n      ),
  
    .en_i            (en           ),
  

    .dst_mac_addr_i  (dst_mac_addr ),
 
    .src_ipv4_addr_i (src_ipv4_addr),
    .dst_ipv4_addr_i (dst_ipv4_addr),

    .src_udp_port_i  (src_udp_port ),
    .dst_udp_port_i  (dst_udp_port ),
  
    .data_inf        (data_inf       )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, udp_gen_tb_wrapper);
  end

endmodule
