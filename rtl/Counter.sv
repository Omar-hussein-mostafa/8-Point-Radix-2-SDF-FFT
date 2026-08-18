module Counter(
    input             clk           ,
    input             rstn          ,
    input             cnt_counter   ,
    output reg [2:0]  counter_out   
);
    

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        counter_out  <= 0;
    end
    else begin
        if(cnt_counter) begin 
            counter_out  <= counter_out  + 3'd1;    
        end
        else begin
            counter_out <= 0;
        end
    end
end
endmodule


