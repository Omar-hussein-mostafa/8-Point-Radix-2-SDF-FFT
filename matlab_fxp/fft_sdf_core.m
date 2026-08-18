function [ADD1, SUB1, MULT1, ADD2, SUB2, MULT2, ADD3, SUB3, MULT3] = fft_sdf_core(DIN_STREAM, ROM_OUT_1, ROM_OUT_2,T)
    %#codegen
    
    ADD1   = cast(DIN_STREAM(1:4) + DIN_STREAM(5:8) , 'like' ,T.ADD1 );     % 4 element vector 
    SUB1   = cast(DIN_STREAM(1:4) - DIN_STREAM(5:8) , 'like' ,T.SUB1 );     % 4 element vector
    MULT1  = cast(SUB1 .* ROM_OUT_1                 , 'like' ,T.MULT1);     % 4 element vector 
    
    S2_top    = [ADD1(1:2); MULT1(1:2)];
    S2_bottom = [ADD1(3:4); MULT1(3:4)];

    ADD2  = cast(S2_top + S2_bottom     , 'like' , T.ADD2 );                % 4 element vector 
    SUB2  = cast(S2_top - S2_bottom     , 'like' , T.SUB2 );                % 4 element vector
    MULT2 = cast(SUB2 .* ROM_OUT_2      , 'like' , T.MULT2);                % 4 element vector 

    S3_top    = [ADD2(1);ADD2(3); MULT2(1);MULT2(3)];
    S3_bottom = [ADD2(2);ADD2(4); MULT2(2);MULT2(4)];
    
    ADD3  = cast(S3_top + S3_bottom , 'like' , T.ADD3 );                    % 4 element vector 
    SUB3  = cast(S3_top - S3_bottom , 'like' , T.SUB3 );                    % 4 element vector
    MULT3 = cast(SUB3               , 'like' , T.MULT3);                    % 4 element vector 
end