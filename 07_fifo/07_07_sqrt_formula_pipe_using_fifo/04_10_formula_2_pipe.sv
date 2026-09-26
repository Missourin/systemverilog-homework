//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
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

    localparam N = 16;

    logic        isqrt_1_x_vld;
    logic [31:0] isqrt_1_x;
    logic        isqrt_1_y_vld;
    logic [15:0] isqrt_1_y;

    logic        b_delayed_vld;
    logic [31:0] b_delayed;

    logic        sum_bc_vld;
    logic [31:0] sum_bc;

    logic        isqrt_2_x_vld;
    logic [31:0] isqrt_2_x;
    logic        en_isqrt_2;

    logic        isqrt_2_y_vld;
    logic [15:0] isqrt_2_y;

    logic        a_delayed_vld;
    logic [31:0] a_delayed;

    logic        sum_abc_vld;
    logic [31:0] sum_abc;

    logic        isqrt_3_x_vld;
    logic [31:0] isqrt_3_x;
    logic        en_isqrt_3;

    logic        isqrt_3_y_vld;
    logic [15:0] isqrt_3_y;

    assign isqrt_1_x_vld = arg_vld;
    assign isqrt_1_x     = c;

    isqrt isqrt_1 (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( isqrt_1_x_vld ),
        .x     ( isqrt_1_x     ),
        .y_vld ( isqrt_1_y_vld ),
        .y     ( isqrt_1_y     )
    );

    shift_register_with_valid #(
        .width ( 32 ),
        .depth ( N  )
    ) delay_b (
        .clk      ( clk           ),
        .rst      ( rst           ),
        .in_vld   ( arg_vld       ),
        .in_data  ( b             ),
        .out_vld  ( b_delayed_vld ),
        .out_data ( b_delayed     )
    );

    assign sum_bc_vld = isqrt_1_y_vld & b_delayed_vld;
    assign sum_bc     = b_delayed + { 16'b0, isqrt_1_y };

    assign en_isqrt_2 = sum_bc_vld;

    always_ff @(posedge clk or posedge rst)
        if (rst) begin
            isqrt_2_x_vld <= 1'b0;
            isqrt_2_x     <= '0;
        end
        else if (en_isqrt_2) begin
            isqrt_2_x_vld <= 1'b1;
            isqrt_2_x     <= sum_bc;
        end
        else begin
            isqrt_2_x_vld <= 1'b0;
        end

    isqrt isqrt_2 (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( isqrt_2_x_vld ),
        .x     ( isqrt_2_x     ),
        .y_vld ( isqrt_2_y_vld ),
        .y     ( isqrt_2_y     )
    );

    shift_register_with_valid #(
        .width ( 32    ),
        .depth ( 2*N+1 )
    ) delay_a (
        .clk      ( clk           ),
        .rst      ( rst           ),
        .in_vld   ( arg_vld       ),
        .in_data  ( a             ),
        .out_vld  ( a_delayed_vld ),
        .out_data ( a_delayed     )
    );

    assign sum_abc_vld = isqrt_2_y_vld & a_delayed_vld;
    assign sum_abc     = a_delayed + { 16'b0, isqrt_2_y };

    assign en_isqrt_3 = sum_abc_vld;

    always_ff @(posedge clk or posedge rst)
        if (rst) begin
            isqrt_3_x_vld <= 1'b0;
            isqrt_3_x     <= '0;
        end
        else if (en_isqrt_3) begin
            isqrt_3_x_vld <= 1'b1;
            isqrt_3_x     <= sum_abc;
        end
        else begin
            isqrt_3_x_vld <= 1'b0;
        end

    isqrt isqrt_3 (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( isqrt_3_x_vld ),
        .x     ( isqrt_3_x     ),
        .y_vld ( isqrt_3_y_vld ),
        .y     ( isqrt_3_y     )
    );

    assign res_vld = isqrt_3_y_vld;
    assign res     = { 16'b0, isqrt_3_y };

endmodule