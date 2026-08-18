import Complex_pack::*;

module BUTTERFLY(
    input  complex_data_t       A    ,
    input  complex_data_t       B    ,
    output complex_data_13_t    ADD  ,
    output complex_data_13_t    SUB
);


// assign ADD.re = A.re + B.re;
// assign ADD.im = A.im + B.im;


// assign SUB.re = A.re - B.re;
// assign SUB.im = A.im - B.im;

    // Explicit sign extension keeps the full 13-bit butterfly result.
    assign ADD.re = {A.re[11], A.re} + {B.re[11], B.re};
    assign ADD.im = {A.im[11], A.im} + {B.im[11], B.im};

    assign SUB.re = {A.re[11], A.re} - {B.re[11], B.re};
    assign SUB.im = {A.im[11], A.im} - {B.im[11], B.im};


endmodule