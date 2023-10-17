/**
 * \file true_dual_port_ram.sv
 * \author A. Shimko
 * \brief True dual block RAM.
 * \version 1.0
 *
 * \code{.unparsed}
 *  
 * true_dual_port_ram #
 * (
 *     .DATA_WIDTH     (), 
 *     .ADDR_WIDTH     (), 
 *    
 *     .IS_OUT_LATENCY (), 
 *                    
 *     .RAM_TYPE       (),
 *     .INIT_FILE_NAME ()
 * )
 * true_dual_port_ram_inst
 * (
 *     .i_clk_a            (),
 *                         
 *     .i_addr_a           (),
 *                        
 *     .i_wr_en_a          (),
 *     .i_wr_data_a        (),
 *     .i_wr_byte_valid_a  (),
 *    
 *     .i_rd_en_a          (),                   
 *     .o_rd_data_a        (),
 *     .o_rd_data_valid_a  (),
 *                       
 *     .i_clk_b            (),
 *                       
 *     .i_addr_b           (),
 *                       
 *     .i_wr_en_b          (),
 *     .i_wr_data_b        (),
 *     .i_wr_byte_valid_b  (),     
 *
 *     .i_rd_en_b          (), 
 *     .o_rd_data_b        (), 
 *     .o_rd_data_valid_a  ()
 * );
 *
 *  \endcode
 *
 * 23.03.22 : add (true_dual_port_ram.sv): created
 * 18.06.22 : add (true_dual_port_ram.sv): added doxygen comments
 * 20.07.22 : fix (true_dual_port_ram.sv): replaced _i/_o postfixes to i_/o_ prefixes for the input/output signals
 *
 */

`timescale 1ns / 1ps

module true_dual_port_ram #
(
    /** \name Parameters. @{ */
    parameter unsigned DATA_WIDTH     = 8,
    parameter unsigned ADDR_WIDTH     = 8,
    
    parameter string        IS_OUT_LATENCY = "true",  //"true", "false"
    
    parameter string        RAM_TYPE       = "block", // "distributed", "block"
    parameter string        INIT_FILE_NAME = "",
    /** @} \name Local parameters. @{ */
    localparam unsigned BYTE_VALID_WIDTH = DATA_WIDTH / 8,
    localparam unsigned MEM_DEPTH        = 2 ** ADDR_WIDTH
    /** @} */
)
(
    /** \name Signals. @{ */
    input  logic                            clk_a_i,

    input  logic [ADDR_WIDTH - 1 : 0]       addr_a_i,

    input  logic                            wr_en_a_i,
    input  logic [DATA_WIDTH - 1 : 0]       wr_data_a_i,
    input  logic [BYTE_VALID_WIDTH - 1 : 0] wr_byte_valid_a_i,

    input logic                             rd_en_a_i,
    output logic [DATA_WIDTH - 1 : 0]       rd_data_a_o,
    output logic                            rd_data_valid_a_o,

    input  logic                            clk_b_i,

    input  logic [ADDR_WIDTH - 1 : 0]       addr_b_i,

    input  logic                            wr_en_b_i,
    input  logic [DATA_WIDTH - 1 : 0]       wr_data_b_i,
    input  logic [BYTE_VALID_WIDTH - 1 : 0] wr_byte_valid_b_i,        

    input logic                             rd_en_b_i,
    output logic [DATA_WIDTH - 1 : 0]       rd_data_b_o,
    output logic                            rd_data_valid_b_o
    /** @} */ 
);
    /** \name Internal signals and regs. @{ */
    (*ram_style = RAM_TYPE*) 
    logic [DATA_WIDTH - 1 : 0] mem [MEM_DEPTH - 1 : 0];
    /** @} */

    /** \name Sequential block. @{ */
    /** \brief Initializing of the memory from a file or to zero. */
    generate
        if (INIT_FILE_NAME != "") begin : init_file
            initial begin
                $readmemh(INIT_FILE_NAME, mem, 0, MEM_DEPTH - 1);
            end
        end 
        else begin: init_zero
            initial begin
                for (int i = 0; i < MEM_DEPTH; i++) begin
                    mem[i] = '0;
                end
            end
        end
    endgenerate

    /** \brief Byte valid logic of port a. */
    always @(posedge clk_a_i) begin
        if (wr_en_a_i == 1'h1) begin
            for (int i = 0; i < BYTE_VALID_WIDTH; i++) begin
                if (wr_byte_valid_a_i[i] == 1'h1) begin
                    mem[addr_a_i][(i * 8) +: 8] <= wr_data_a_i[(i * 8) +: 8];
                end
            end
        end
    end

    /** \brief Byte valid logic of port b. */
    always @(posedge clk_b_i) begin
        if (wr_en_b_i == 1'h1) begin
            for (int i = 0; i < BYTE_VALID_WIDTH; i++) begin
                if (wr_byte_valid_b_i[i] == 1'h1) begin
                    mem[addr_b_i][(i * 8) +: 8] <= wr_data_b_i[(i * 8) +: 8];
                end
            end
        end
    end

    /** \brief Out latency or non latency logic for reading from the memory. */
    generate 
        if (IS_OUT_LATENCY == "true") begin : out_latency
            always_ff @(posedge clk_a_i) begin
                if (rd_en_a_i == 1'h1) begin   
                    rd_data_a_o <= mem[addr_a_i];
                end

                rd_data_valid_a_o <= rd_en_a_i;
            end

            always_ff @(posedge clk_b_i) begin  
                if (rd_en_b_i == 1'h1) begin  
                    rd_data_b_o <= mem[addr_b_i];
                end

                rd_data_valid_b_o <= rd_en_b_i;
            end
        end
        else begin
            always_comb begin  
                rd_data_a_o = mem[addr_a_i];
                rd_data_b_o = mem[addr_b_i];

                rd_data_valid_a_o = rd_en_a_i;
                rd_data_valid_b_o = rd_en_b_i;
            end
        end
    endgenerate
    /** @} */

endmodule
