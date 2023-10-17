/**
 * \file gpio.sv
 * \author A. Shimko
 * \brief Bidir output implementation.
 * \version 1.0
 *
 * \code{.unparsed}
 *  
 * gpio # 
 * (
 *     WIDTH (),
 * )
 * gpio_inst                         
 * (
 *     .clk_i    (),
 * 
 *     .dir_i    (),
 * 
 *     .data_i   (),
 *     .data_o   (),
 *     .inout_io ()
 * );
 *
 *  \endcode
 *
 * 11.06.22 : add (gpio.sv): created
 * 12.06.22 : add (gpio.sv): replaced inout_i signal name to inout_io
 *
 */

`timescale 1ns / 1ps

module gpio
(
    /** \name Signals. @{ */
    input  logic                 clk_i,
   
    input  logic                 dir_i,         /**< 0 - inout_io is an input, 1 - inout_io is an output. */
   
    input  logic data_i,       /**< Data to output through inout_io. */
    output logic data_o,       /**< Data to input through inout_io. */
    inout  logic inout_io
    /** @} */
);
    /** \name Internal signals and regs. @{ */
    logic dir;
    logic out_buf, in_buf;   
    /** @} */

    /** \name Combinatorial block. @{ */
    assign inout_io = (dir == 1'b1) ? out_buf : 'bz;

    always_comb begin
        data_o = in_buf;
    end
    /** @} */
    
    /** \name Sequential block. @{ */ 
    always_ff @ (posedge clk_i)
    begin
        dir     <= dir_i;
        in_buf  <= inout_io;
        out_buf <= data_i;
    end
    /** @} */

endmodule
