/*
random_state_generator # 
(
    .STATE_0_MIN_VAL (), // default: 10
    .STATE_0_MAX_VAL (), // default: 20
    .STATE_1_MIN_VAL (), // default: 30
    .STATE_1_MAX_VAL ()  // default: 40
)
random_state_generator_inst                         
(
    .clk_i     (),
    .s_rst_n_i (),

    .state_o   ()
);
*/

`timescale 1ns / 1ps

module random_state_generator # 
(
    parameter unsigned STATE_0_MIN_VAL = 10,
    parameter unsigned STATE_0_MAX_VAL = 20,
    parameter unsigned STATE_1_MIN_VAL = 30,
    parameter unsigned STATE_1_MAX_VAL = 40
)
(
    input  logic clk_i,
    input  logic s_rst_n_i,
    
    output logic state_o
);

    bit value_switch = 1'b0;
    
    int  counter = 0;
    int  limit   = 0;
    
    always_ff @ (posedge clk_i) begin
        if (s_rst_n_i == 1'b0) begin
    	    counter = 0;
    	    limit   = $urandom_range(STATE_0_MIN_VAL , STATE_0_MAX_VAL );
    	    
    	    state_o <= 1'b0;
        end
        else begin
            if (value_switch == 1'b0) begin
                if (counter == (limit - 1)) begin
                    counter = 0;
                    limit   = $urandom_range(STATE_1_MIN_VAL , STATE_1_MAX_VAL );
                    
                    value_switch <= 1'b1;
                    state_o      <= 1'b1;
                end
                else begin
                    ++counter;
                    state_o <= 1'b0;
                end
            end
    		else
                if (counter == (limit - 1)) begin
                    counter = 0;
                    limit   = $urandom_range(STATE_0_MIN_VAL , STATE_0_MAX_VAL );
                    
                    value_switch <= 1'b0;
                    state_o      <= 1'b0;
                end
                else begin
                    ++counter;
                    state_o <= 1'b1;
                end
            end
        end
    
    // assert    
    always @ (*) begin
        if ((STATE_0_MIN_VAL > STATE_0_MAX_VAL) ||
            (STATE_1_MIN_VAL > STATE_1_MAX_VAL)) begin
            
            $error("The module parameters error.");
        end
    end
endmodule
