import  Complex_pack::*;

module DELAY
#(
    parameter DELAY_DEPTH = 4
)
(
    input                    clk    ,
    input                    rstn   ,
    input   complex_data_t   Input  ,
    output  complex_data_t   Output 
);

complex_data_t [DELAY_DEPTH-1:0] DELAY;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        DELAY <= '0;
    end
    else begin
        if(DELAY_DEPTH > 1) begin
            DELAY <= {DELAY[DELAY_DEPTH-2:0] , Input };
        end
        else begin
            DELAY <= Input;
        end
    end
end
    
assign Output = DELAY[DELAY_DEPTH-1];
endmodule