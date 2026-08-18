package Complex_pack;

typedef struct packed {
    logic signed [11:0] re;
    logic signed [11:0] im;
} complex_data_t;
typedef struct packed {
        logic signed [12:0] re;
        logic signed [12:0] im;
} complex_data_13_t;
endpackage