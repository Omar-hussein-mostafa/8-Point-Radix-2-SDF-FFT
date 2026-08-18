import Complex_pack::*;

module FFT_Top (
    input  logic          clk,
    input  logic          rstn,
    input  logic          valid_in,
    input  complex_data_t DIN,
    output complex_data_t DOUT,
    output logic          Valid_out
);

    // --- Internal Routing Wires ---
    logic [1:0] rom_addr1;
    logic [1:0] rom_addr2;
    
    logic       mux1_sel;
    logic       mux2_sel;
    logic       mux3_sel;
    logic       mux_d4_sel;
    logic       mux_d2_sel;
    logic       mux_d1_sel;

    complex_data_t twiddle1;
    complex_data_t twiddle2;

    // --- 1. Control Unit ---
    Control_unit ctrl_inst (
        .valid_in   (valid_in),
        .rstn       (rstn),
        .clk        (clk),
        .ROM_ADDR1  (rom_addr1),
        .ROM_ADDR2  (rom_addr2),
        .MUX1_SEL   (mux1_sel),
        .MUX2_SEL   (mux2_sel),
        .MUX3_SEL   (mux3_sel),
        .MUX_D4_SEL (mux_d4_sel),
        .MUX_D2_SEL (mux_d2_sel),
        .MUX_D1_SEL (mux_d1_sel),
        .Valid_out  (Valid_out)
    );

    // --- 2. Twiddle Factor ROMs ---
    Twiddle_ROM rom1 (
        .addr        (rom_addr1),
        .twiddle_out (twiddle1)
    );

    Twiddle_ROM rom2 (
        .addr        (rom_addr2),
        .twiddle_out (twiddle2)
    );

    // --- 3. SDF Pipeline Datapath ---
    SDF_STAGE datapath_inst (
        .clk             (clk),
        .rstn            (rstn),
        .DIN             (DIN),
        .TWIDDLE_FACTOR1 (twiddle1),
        .TWIDDLE_FACTOR2 (twiddle2),
        .MUX1_SEL        (mux1_sel),
        .MUX2_SEL        (mux2_sel),
        .MUX3_SEL        (mux3_sel),
        .MUX_D4_SEL      (mux_d4_sel),
        .MUX_D2_SEL      (mux_d2_sel),
        .MUX_D1_SEL      (mux_d1_sel),
        .OUTPUT          (DOUT)
    );


    

endmodule