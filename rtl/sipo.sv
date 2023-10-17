/*--------------------------------------------------
| engineer : A. Shimko
|
| module   : sipo.sv (serial in parallel out)
|
| testbench: sipo_tb.sv
| 
| brief    :
|
| todo     :
|
| 18.03.21 : add: created
| 01.04.22 : style: changed i/o_ prefects to _i/o prefixes
| 01.04.22 : fix: changed parameters
|
|            1. renamed DO_MSB_FIRST to DIRECTION
|            2. renamed DIRECTION cases ("true" and "false") to "msb_first", "lsb_first"
| 01.04.22 : fix: changed "'0" to "1'b0" for rst
|
*/

/*
sipo # 
(
    .DATA_WIDTH (), // default: 8
    .DIRECTION  ()  // default: "msb_first", cases: "msb_first", "lsb_first"
)
sipo_inst                         
(
    .clk_i        (),
    .s_rst_n_i    (),
    .en_i         (),

    .data_o       (), // width: DATA_WIDTH

    .data_i       ()
);
*/

`timescale 1ns / 1ps

module sipo # 
(
    parameter unsigned DATA_WIDTH = 8,
    parameter string        DIRECTION  = "msb_first"
)
(
    input  logic                       clk_i,
    input  logic                       s_rst_n_i,
    input  logic                       en_i,
    
    output logic  [DATA_WIDTH - 1 : 0] data_o,

    input  logic                       data_i
);
    localparam unsigned MSB = DATA_WIDTH - 1;
    localparam unsigned LSB = 0;

    logic [DATA_WIDTH - 1 : 0] buff;
    
    generate
        if (DIRECTION == "msb_first") begin : msb_mode
            always_ff @ (posedge clk_i) begin
                if (s_rst_n_i == 1'b0) begin
                    buff <= '0;
                end
                else begin
                    buff = {buff[MSB - 1 : LSB], data_i};
                end
            end
        end
        else begin  : lsb_mode 
            always_ff @ (posedge clk_i) begin
                if (s_rst_n_i == 1'b0) begin
                    buff <= '0;
                end
                else if (en_i == 1'b1) begin
                    buff = {data_i, buff[MSB : LSB + 1]};
                end
            end
        end
    endgenerate

   assign data_o = buff;
    
endmodule
