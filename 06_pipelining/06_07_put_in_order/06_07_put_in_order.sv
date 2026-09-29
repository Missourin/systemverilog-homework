module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    localparam PTR_W = $clog2(n_inputs);

    logic [PTR_W - 1:0   ]              ptr;
    logic [n_inputs - 1:0]              saved_vld;
    logic [n_inputs - 1:0][width - 1:0] saved_data;

    assign down_vld  = saved_vld  [ptr];
    assign down_data = saved_data [ptr];

    always_ff @(posedge clk)
        if (rst)
            ptr <= '0;
        else if (down_vld) begin
            if (ptr == PTR_W'(n_inputs - 1))
                ptr <= '0;
            else
                ptr <= ptr + 1'b1;
        end

    always_ff @(posedge clk)
        if (rst)
        begin
            saved_vld  <= '0;
            saved_data <= '0;
        end
        else
        begin
            for (int i = 0; i < n_inputs; i++)
                if (up_vlds [i]) begin
                    saved_vld  [i] <= 1'b1;
                    saved_data [i] <= up_data [i];
                end
                else if (down_vld && (ptr == i))
                    saved_vld [i] <= 1'b0;
        end

endmodule
