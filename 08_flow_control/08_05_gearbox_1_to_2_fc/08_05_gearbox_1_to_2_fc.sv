//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2_fc
# (
    parameter width = 8
)
(
    input                   clk,
    input                   rst,
    input                   up_valid,
    output                  up_ready,
    input  [   width - 1:0] up_data,
    output                  down_valid,
    output [ 2*width - 1:0] down_data,
    input                   down_ready
);

    logic [width - 1:0]   hi_buf;
    logic [2*width - 1:0] out_buf;
    logic                 out_valid;
    logic                 state;

    wire up_handshake   = up_valid && up_ready;
    wire down_handshake = down_valid && down_ready;

    assign up_ready   = ~out_valid || down_handshake;
    assign down_valid = out_valid;
    assign down_data  = out_buf;

    always_ff @(posedge clk)
        if      (rst)          state <= 1'b0;
        else if (up_handshake) state <= ~state;

    always_ff @(posedge clk)
        if      (rst)                   out_valid <= 1'b0;
        else if (down_handshake)        out_valid <= 1'b0;
        else if (up_handshake && state) out_valid <= 1'b1;

    always_ff @(posedge clk)
        if (rst) begin
            hi_buf    <= '0;
            out_buf   <= '0;
        end
        else if (up_handshake && ~state)
            hi_buf  <= up_data;
        else if (up_handshake &&  state)
            out_buf <= { hi_buf, up_data };

    // always @(posedge clk) begin
    //     if (rst) begin
    //         state     <= 1'b0;
    //         out_valid <= 1'b0;
    //         hi_buf    <= '0;
    //         out_buf   <= '0;
    //     end
    //     else begin
    //         if (down_handshake)
    //             out_valid <= 1'b0;

    //         if (up_handshake) begin
    //             if (state == 1'b0) begin
    //                 hi_buf <= up_data;
    //                 state  <= 1'b1;
    //             end else begin
    //                 out_buf   <= {hi_buf, up_data};
    //                 out_valid <= 1'b1;
    //                 state     <= 1'b0;
    //             end
    //         end
    //     end
    // end

endmodule