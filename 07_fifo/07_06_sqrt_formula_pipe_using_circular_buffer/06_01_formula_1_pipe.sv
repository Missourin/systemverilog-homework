//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // NOTHING TO DO HERE

    logic        isqrt_1_y_vld, isqrt_2_y_vld, isqrt_3_y_vld;
    logic [15:0] isqrt_1_y, isqrt_2_y, isqrt_3_y;

    logic        en;

    assign en = isqrt_1_y_vld & isqrt_2_y_vld & isqrt_3_y_vld;

    always_ff @(posedge clk)
        if      (rst) res_vld <= '0;
        else          res_vld <= en;

    always_ff @(posedge clk)
        if      (rst) res <= '0;
        else if (en)  res <= { 16'b0, isqrt_1_y } +
                             { 16'b0, isqrt_2_y } +
                             { 16'b0, isqrt_3_y };

    isqrt isqrt_1 (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( arg_vld       ),
        .x     ( a             ),
        .y_vld ( isqrt_1_y_vld ),
        .y     ( isqrt_1_y     )
    );

    isqrt isqrt_2 (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( arg_vld       ),
        .x     ( b             ),
        .y_vld ( isqrt_2_y_vld ),
        .y     ( isqrt_2_y     )
    );

    isqrt isqrt_3 (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( arg_vld       ),
        .x     ( c             ),
        .y_vld ( isqrt_3_y_vld ),
        .y     ( isqrt_3_y     )
    );

endmodule
