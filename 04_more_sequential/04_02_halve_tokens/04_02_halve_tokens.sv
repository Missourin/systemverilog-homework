//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
    input  clk,
    input  rst,
    input  a,
    output b
);
    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 110_011_101_000_1111
    // b -> 010_001_001_000_0101

    logic expect_second;

    assign b = expect_second & a;

    always_ff @ (posedge clk)
        if (rst)
            expect_second <= '0;
        else begin
            if (expect_second & a)
                expect_second <= '0;
            else if (a)
                expect_second <= '1;
        end


endmodule
