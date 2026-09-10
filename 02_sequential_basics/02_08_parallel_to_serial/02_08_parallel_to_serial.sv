module parallel_to_serial
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,
    input                      parallel_valid,
    input        [width - 1:0] parallel_data,
    output logic               busy,
    output logic               serial_valid,
    output logic               serial_data
);

    logic [width - 1:0]       shift_reg;
    logic [width - 1:0]       shift_reg_next;
    logic [$clog2(width)-1:0] cnt;

    assign shift_reg_next = parallel_valid ? parallel_data
                                           : { 1'b0, shift_reg[width - 1:1] };

    assign serial_data  = shift_reg_next[0];
    assign serial_valid = parallel_valid | busy;

    always_ff @(posedge clk)
        if (rst)                           busy <= 1'b0;
        else if (parallel_valid)           busy <= 1'b1;
        else if (busy && cnt == width - 2) busy <= 1'b0;

    always_ff @(posedge clk)
        if (rst)                           cnt <= '0;
        else if (parallel_valid)           cnt <= '0;
        else if (busy && cnt != width - 2) cnt <= cnt + 1'b1;

    always_ff @(posedge clk)
        if (rst)                 shift_reg <= '0;
        else if (parallel_valid) shift_reg <= parallel_data;
        else if (busy)           shift_reg <= { 1'b0, shift_reg[width - 1:1] };

endmodule