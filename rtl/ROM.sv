import Complex_pack::*;

module Twiddle_ROM (
    input  logic [1:0]    addr,
    output complex_data_t twiddle_out
);

    always_comb begin
        case (addr)
            // W^0 = 1 + 0j
            2'd0: begin 
                twiddle_out.re = 12'h400; 
                twiddle_out.im = 12'h000; 
            end 
            // W^1 = 0.707 - 0.707j
            2'd1: begin 
                twiddle_out.re = 12'h2D4; 
                twiddle_out.im = 12'hD2C; 
            end 
            // W^2 = 0 - 1j
            2'd2: begin 
                twiddle_out.re = 12'h000; 
                twiddle_out.im = 12'hC00; 
            end 
            // W^3 = -0.707 - 0.707j
            2'd3: begin 
                twiddle_out.re = 12'hD2C; 
                twiddle_out.im = 12'hD2C; 
            end 
            default: begin 
                twiddle_out.re = 12'h000; 
                twiddle_out.im = 12'h000; 
            end
        endcase
    end

endmodule