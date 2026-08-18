% Helper function to format the +/- sign cleanly for complex numbers
function s = sign_char(val)
    if val >= 0
        s = '+';
    else
        s = '-';
    end
end