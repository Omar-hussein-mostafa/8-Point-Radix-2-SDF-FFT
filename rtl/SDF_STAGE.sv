import Complex_pack::*;

module SDF_STAGE
(
    input                  clk             ,
    input                  rstn            ,
    input   complex_data_t DIN             ,
    input   complex_data_t TWIDDLE_FACTOR1 ,
    input   complex_data_t TWIDDLE_FACTOR2 ,
    input                  MUX1_SEL        ,
    input                  MUX2_SEL        ,
    input                  MUX3_SEL        ,
    input                  MUX_D4_SEL      ,
    input                  MUX_D2_SEL      ,
    input                  MUX_D1_SEL      ,
    output  complex_data_t OUTPUT         
);


// INTERNAL SIGNALS
complex_data_t     ADD2      ;
complex_data_t     ADD3      ;
complex_data_t     SUB1      ;
complex_data_t     ADD1      ;
complex_data_t     SUB2      ;
complex_data_t     SUB3      ;
complex_data_t     MULT1     ;
complex_data_t     MULT2     ;
complex_data_t     MUX1      ;
complex_data_t     MUX2      ;
complex_data_t     MUX3      ;
complex_data_t     MUX_D4    ;
complex_data_t     MUX_D2    ;
complex_data_t     MUX_D1    ;
complex_data_t     D4        ;
complex_data_t     D2        ;
complex_data_t     D1        ;

complex_data_13_t  temp_ADD1 ;
complex_data_13_t  temp_ADD2 ;
complex_data_13_t  temp_ADD3 ;
complex_data_13_t  temp_SUB1 ;
complex_data_13_t  temp_SUB2 ;
complex_data_13_t  temp_SUB3 ;

// --------------- Stage 1 --------------- //
BUTTERFLY butterfly_1 (D4,DIN ,temp_ADD1,temp_SUB1);

assign ADD1.re = {temp_ADD1.re[12], temp_ADD1.re[12:2]}; // Q6.6
assign ADD1.im = {temp_ADD1.im[12], temp_ADD1.im[12:2]};    
assign SUB1.re = temp_SUB1.re[12:1];                     // Q5.7
assign SUB1.im = temp_SUB1.im[12:1];

assign MUX_D4    = (MUX_D4_SEL)? DIN : SUB1;
DELAY #(4) DELAY_4 (clk,rstn,MUX_D4,D4);
Complex_MULT #(1) CMULT1 (D4,TWIDDLE_FACTOR1,MULT1);    // Q6.6
assign MUX1      = (MUX1_SEL)? ADD1 : MULT1;            // Q6.6

// --------------- Stage 2 --------------- //
BUTTERFLY butterfly_2 (D2,MUX1 ,temp_ADD2,temp_SUB2);

assign ADD2.re = temp_ADD2.re[11:0]; 
assign ADD2.im = temp_ADD2.im[11:0];
assign SUB2.re = temp_SUB2.re[11:0]; 
assign SUB2.im = temp_SUB2.im[11:0];

assign MUX_D2    = (MUX_D2_SEL)? MUX1 : SUB2;
DELAY #(2) DELAY_2 (clk,rstn,MUX_D2,D2);
Complex_MULT #(2) CMULT2 (D2,TWIDDLE_FACTOR2,MULT2);    // Q6.6
assign MUX2      = (MUX2_SEL)? ADD2 : MULT2;            // Q6.6

// --------------- Stage 3 --------------- //
BUTTERFLY butterfly_3 (D1,MUX2 ,temp_ADD3,temp_SUB3);

assign ADD3.re = temp_ADD3.re[12:1]; // Q7.5
assign ADD3.im = temp_ADD3.im[12:1];
assign SUB3.re = temp_SUB3.re[12:1]; // Q7.5
assign SUB3.im = temp_SUB3.im[12:1];

assign MUX_D1    = (MUX_D1_SEL)? MUX2 : SUB3;
DELAY #(1) DELAY_1 (clk,rstn,MUX_D1,D1);
assign MUX3      = (MUX3_SEL)? ADD3 : D1;            // Q7.5


assign OUTPUT = MUX3;
endmodule