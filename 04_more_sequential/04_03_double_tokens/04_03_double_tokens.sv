//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output       b,
    output logic overflow
);
    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note :
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110

    logic [7:0] in_ones_cnt;
    logic [8:0] out_gen_cnt;

    assign b = !overflow & (out_gen_cnt > '0 | a);

    always_ff @ (posedge clk)
        if (rst)    in_ones_cnt <= '0;
        else if (a) in_ones_cnt <= in_ones_cnt + 1'b1;
        else        in_ones_cnt <= '0;

    always_ff @(posedge clk)
        if (rst)                        overflow <= '0;
        else if (in_ones_cnt >= 8'd200) overflow <= 1'b1;

    always_ff @(posedge clk)
        if (rst)        out_gen_cnt <= '0;
        else if (a & b) out_gen_cnt <= out_gen_cnt + 1'b1;
        else if (a)     out_gen_cnt <= out_gen_cnt + 2'd2;
        else if (b)     out_gen_cnt <= out_gen_cnt - 1'b1;

endmodule
