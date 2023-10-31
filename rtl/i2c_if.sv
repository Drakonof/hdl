interface i2c_if;
  logic scl_o;
  logic scl_i;
  logic scl_t;
  
  logic sda_o;
  logic sda_i;
  logic sda_t;

  modport io
  (
    output  scl_o,
    input   scl_i,
    output  scl_t,
  
    output  sda_o,
    input   sda_i,
    output  sda_t
  );   
endinterface