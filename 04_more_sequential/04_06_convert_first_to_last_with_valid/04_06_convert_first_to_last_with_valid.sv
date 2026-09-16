//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module conv_first_to_last_no_ready
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    input                up_first,
    input  [width - 1:0] up_data,

    output               down_valid,
    output               down_last,
    output [width - 1:0] down_data
);

    // Task:
    // Implement a module that converts 'first' input status signal
    // to the 'last' output status signal.
    //
    // The module delays the input stream by one clock cycle
    // and converts the 'first' flag of the *next* transfer
    // into the 'last' flag of the *current* transfer.

    wire up_first_safe = up_valid ? up_first : 1'b0;

    logic               down_valid_r;
    logic               down_last_r;
    logic [width - 1:0] down_data_r;

    always_ff @(posedge clock)
        if (reset) begin
            down_valid_r <= 1'b0;
            down_last_r  <= 1'b0;
            down_data_r  <= '0;
        end
        else begin
            down_valid_r <= up_valid;
            down_last_r  <= up_first_safe;
            down_data_r  <= up_data;
        end

    assign down_valid = down_valid_r;
    assign down_last  = down_last_r;
    assign down_data  = down_data_r;

endmodule