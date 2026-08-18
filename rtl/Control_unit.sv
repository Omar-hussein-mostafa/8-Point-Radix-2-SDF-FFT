module Control_unit(
    input   logic         valid_in   ,
    input   logic         rstn       ,
    input   logic         clk        ,
    output  logic   [1:0] ROM_ADDR1  ,
    output  logic   [1:0] ROM_ADDR2  ,
    output  logic         MUX1_SEL   ,
    output  logic         MUX2_SEL   ,
    output  logic         MUX3_SEL   ,
    output  logic         MUX_D4_SEL ,
    output  logic         MUX_D2_SEL ,
    output  logic         MUX_D1_SEL ,
    output  logic         Valid_out  
); 
    
logic [2:0] counter_out      ;
logic       counter_enable   ;
logic [6:0] valid_pipe       ;

// Counter Instantiation
Counter cnt ( clk, rstn, counter_enable, counter_out);

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        valid_pipe <= 0;
    end
    else begin
        valid_pipe <= {valid_pipe[5:0], valid_in};
    end
end

assign Valid_out = valid_pipe[6];
assign counter_enable = valid_in || (valid_pipe != 7'b0000000);

// MUX Selection Control
// Stage 1 switches every 4 cycles
assign MUX1_SEL   =  counter_out[2];
assign MUX_D4_SEL = ~counter_out[2];

assign MUX_D2_SEL = ~counter_out[1];
assign MUX2_SEL   =  counter_out[1];
// Stage 3 switches every 1 cycle
assign MUX3_SEL   =  counter_out[0];
assign MUX_D1_SEL = ~counter_out[0];

// Addresses 0, 1, 2, 3
assign ROM_ADDR1 = counter_out[1:0];
    
// Addresses 0, 2, 0, 2
assign ROM_ADDR2 = {counter_out[0], 1'b0};

endmodule