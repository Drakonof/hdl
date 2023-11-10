//`include "platform.vh"

//`resetall
//`default_nettype none



//(* dont_touch = "yes" *)
interface udp_gen_inf #
(
  parameter unsigned DATA_WIDTH = 64
);

  logic [DATA_WIDTH - 1 : 0] data;
  logic                      data_valid;      
  logic                      frame_end;

endinterface