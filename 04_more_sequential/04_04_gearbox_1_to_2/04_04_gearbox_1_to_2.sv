//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2
# (
    parameter width = 0
)
(
    input                    clk,
    input                    rst,

    input                    up_vld,    // upstream
    input  [    width - 1:0] up_data,

    output                   down_vld,  // downstream
    output [2 * width - 1:0] down_data
);
    // Task:
    // Implement a module that transforms a stream of data
    // from 'width' to the 2*'width' data width.
    //
    // The module should be capable to accept new data at each
    // clock cycle and produce concatenated 'down_data'
    // at each second clock cycle.
    //
    // The module should work properly with reset 'rst'
    // and valid 'vld' signals

    logic               last_up_vld;
    logic [width - 1:0] last_up_data;

    assign down_vld = last_up_vld & up_vld;
    assign down_data = { last_up_data, up_data };

    always_ff @ (posedge clk)
        if (rst) begin
            last_up_vld  <= '0;
            last_up_data <= '0;
        end
        else if (last_up_vld & up_vld) begin
            last_up_vld  <= '0;
            last_up_data <= '0;
        end
        else if (up_vld) begin
            last_up_vld  <= 1'b1;
            last_up_data <= up_data;
        end

endmodule
