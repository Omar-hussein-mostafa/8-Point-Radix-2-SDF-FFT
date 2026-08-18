import Complex_pack::*;

module Complex_MULT
#(
    parameter int STAGE = 1
)
(
    input  complex_data_t A,
    input  complex_data_t B,
    output complex_data_t C
);

logic signed [23:0] mult_rr; 
logic signed [23:0] mult_ii; 
logic signed [23:0] mult_ri; 
logic signed [23:0] mult_ir; 

logic signed [24:0] temp_mult_re;
logic signed [24:0] temp_mult_im;


assign mult_rr = A.re * B.re;
assign mult_ii = A.im * B.im;
assign mult_ri = A.re * B.im;
assign mult_ir = A.im * B.re;

assign temp_mult_re = mult_rr - mult_ii; 
assign temp_mult_im = mult_ri + mult_ir; 

   
    generate
        if (STAGE == 1) begin : gen_mult_stg1
            assign C.re = temp_mult_re[22:11];
            assign C.im = temp_mult_im[22:11];
            
        end else if (STAGE == 2) begin : gen_mult_stg2
            assign C.re = temp_mult_re[21:10];
            assign C.im = temp_mult_im[21:10];
        end
    endgenerate
    
endmodule