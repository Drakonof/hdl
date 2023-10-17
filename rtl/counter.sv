/**
 * \file counter.sv
 * \author A. Shimko
 * \brief Just an uart tx.
 *
 * \code{.unparsed}
 * 
 * counter # 
 * (
 *     .MAX_VALUE ()
 * )
 * counter_inst                         
 * (
 *     .clk_i     (),
 *     .s_rst_n_i (),
 * 
 *     .en_i      (),
 * 
 *     .value_o   ()
 * );
 *
 * \endcode
 * 
 * 08.02.22 : add (counter.sv): created
 * 12.03.22 : fix (counter.sv): changed "(i_en == '1)" to "(i_en == 1'h1)"
 * 31.03.22 : rev (counter.sv): changed i/o_ prefects to _i/o prefixes
 * 31.03.22 : fix (counter.sv): removed the compare of the counter with MAX_VALUE
 * 31.03.22 : fix (counter.sv): changed comparing with the constans
 *          1. '0 to 1'b0
 *          2. 1'h1 to 1'b1
 * 18.04.22 : fix (counter.sv): add enable
 * 19.05.22 : fix (counter.sv): change the comments to doxygen style ones
 * 
 */

`timescale 1ns / 1ps

module counter #
(
    /** \name Parameters. @{ */
    parameter integer MAX_VALUE = 8,
    /** @} \name Local parameters. @{ */
    localparam integer WIDTH = $clog2(MAX_VALUE)
    /** @} */
)
(
    /** \name Signals. @{ */
    input  logic                 clk_i,
    input  logic                 s_rst_n_i,

    input  logic                 en_i,

    output logic [WIDTH - 1 : 0] value_o
    /** @} */
);
    /** \name Internal signals and regs. @{ */
    logic [WIDTH - 1 : 0] counter;
    /** @} \name Behavioral block @{ */
    always_comb begin
        value_o = counter;
    end

    always_ff @ (posedge clk_i) begin
        if (s_rst_n_i == 1'b0) begin
            counter <= '0;
        end
        else begin
            if (en_i == 1'b1) begin
                counter <= counter + 1'b1; 
            end
        end
    end
    /** @} */
endmodule
