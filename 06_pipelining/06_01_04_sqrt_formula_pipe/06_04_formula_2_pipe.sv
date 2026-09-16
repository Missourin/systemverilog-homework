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

    // Task:
    //
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    localparam N = 16;

    logic        isqrt_x_1_vld;
    logic [31:0] isqrt_x_1;
    logic        isqrt_y_1_vld;
    logic [15:0] isqrt_y_1;

    logic        b_delayed_vld;
    logic [31:0] b_delayed;

    logic        sum_bc_vld;
    logic [31:0] sum_bc;

    logic        isqrt_2_x_vld;
    logic [31:0] isqrt_2_x;
    logic        isqrt_2_y_vld;
    logic [15:0] isqrt_2_y;

    logic        a_delayed_vld;
    logic [31:0] a_delayed;

    logic        sum_abc_vld;
    logic [31:0] sum_abc;

    logic        isqrt_3_x_vld;
    logic [31:0] isqrt_3_x;
    logic        isqrt_3_y_vld;
    logic [15:0] isqrt_3_y;

    isqrt isqrt_1 (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( isqrt_x_1_vld ),
        .x     ( isqrt_x_1     ),
        .y_vld ( isqrt_y_1_vld ),
        .y     ( isqrt_y_1     )
    );

    isqrt isqrt_2 (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( isqrt_2_x_vld ),
        .x     ( isqrt_2_x     ),
        .y_vld ( isqrt_2_y_vld ),
        .y     ( isqrt_2_y     )
    );

    isqrt isqrt_3 (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( isqrt_3_x_vld ),
        .x     ( isqrt_3_x     ),
        .y_vld ( isqrt_3_y_vld ),
        .y     ( isqrt_3_y     )
    );

    assign isqrt_x_1_vld = arg_vld;
    assign isqrt_x_1     = c;

    shift_register_with_valid #(
        .width ( 32 ),
        .depth ( N )
    ) delay_b (
        .clk      ( clk           ),
        .rst      ( rst           ),
        .in_vld   ( arg_vld       ),
        .in_data  ( b             ),
        .out_vld  ( b_delayed_vld ),
        .out_data ( b_delayed     )
    );

    assign sum_bc_vld = isqrt_y_1_vld & b_delayed_vld;
    assign sum_bc     = b_delayed + { 16'b0, isqrt_y_1 };

    assign isqrt_2_x_vld = sum_bc_vld;
    assign isqrt_2_x     = sum_bc;

    shift_register_with_valid #(
        .width ( 32 ),
        .depth ( 2 * N )
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

    assign isqrt_3_x_vld = sum_abc_vld;
    assign isqrt_3_x     = sum_abc;


    assign res_vld = isqrt_3_y_vld;
    assign res     = { 16'b0, isqrt_3_y };

endmodule
