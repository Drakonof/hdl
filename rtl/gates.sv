`timescale 1ns / 1ps


module gates
(
  input  logic a_i,
  input  logic b_i,
  
  input  logic ctrl_i,
  
  output logic and_o,
  output logic or_o,
  output logic xor_o,
  
  output logic nand_o,
  output logic nor_o,
  output logic xnor_o,
  
  output logic not_a_o,
  output logic buf_a_o,
  
  output logic bufif0_a_o,
  output logic notif0_a_o,
  
  output logic bufif1_a_o,
  output logic notif1_a_o
);

//  always_comb
//    begin
//      and_o   = a_i & b_i;
//      or_o    = a_i | b_i; 
//      xor_o   = a_i ^ b_i;
      
//      nand_o  = ~(a_i & b_i);
//      nor_o   = ~(a_i | b_i);
//      xor_o   = ~(a_i ^ b_i);

//      not_a_o = ~a_i;
//      not_b_o = ~b_i;
//    end

    and  _and(and_o, a_i, b_i);
    or   _or(or_o, a_i, b_i); 
    xor  _xor(xor_o, a_i, b_i);
    
    nand _nand(nand_o, a_i, b_i);
    nor  _nor(nor_o , a_i, b_i);
    xnor _xnor(xor_o, a_i, b_i);

    not _not(not_a_o, ~a_i);
    
    buf _buf(buf_a_o, a_i);
    
    bufif0 _bufif0(bufif0_a_o, a_i, ctrl_i);
    bufif1 _bufif1(bufif1_a_o, a_i, ctrl_i);
    
    notif0 _notif0(notif0_a_o, a_i, ctrl_i);
    notif1 _notif1(notif1_a_o, a_i, ctrl_i);
endmodule
