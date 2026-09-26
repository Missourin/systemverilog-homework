//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_fifos
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

    localparam N = 16;

    logic        isqrt_1_x_vld;
    logic [31:0] isqrt_1_x;
    logic        isqrt_1_y_vld;
    logic [15:0] isqrt_1_y;

    logic        b_delayed_vld;
    logic [31:0] b_delayed;
    logic [32:0] fifo_1_read;
    logic        fifo_1_empty, fifo_1_full;

    logic        sum_bc_vld;
    logic [31:0] sum_bc;

    logic        isqrt_2_x_vld;
    logic [31:0] isqrt_2_x;

    logic        isqrt_2_y_vld;
    logic [15:0] isqrt_2_y;

    logic        a_delayed_vld;
    logic [31:0] a_delayed;
    logic [32:0] fifo_2_read;
    logic        fifo_2_empty, fifo_2_full;

    logic        sum_abc_vld;
    logic [31:0] sum_abc;

    logic        isqrt_3_x_vld;
    logic [31:0] isqrt_3_x;

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

    flip_flop_fifo_with_counter #(
        .width ( 33 ),
        .depth ( N  )
    ) fifo_1 (
        .clk        ( clk            ),
        .rst        ( rst            ),
        .push       ( 1'b1           ),
        .pop        ( 1'b1           ),
        .write_data ( { arg_vld, b } ),
        .read_data  ( fifo_1_read    ),
        .empty      ( fifo_1_empty   ),
        .full       ( fifo_1_full    )
    );

    assign b_delayed_vld = fifo_1_read[32];
    assign b_delayed     = fifo_1_read[31:0];

    assign sum_bc_vld = isqrt_1_y_vld & b_delayed_vld;
    assign sum_bc     = b_delayed + { 16'b0, isqrt_1_y };

    always_ff @(posedge clk or posedge rst)
        if (rst) begin
            isqrt_2_x_vld <= 1'b0;
            isqrt_2_x     <= '0;
        end
        else if (sum_bc_vld) begin
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

    flip_flop_fifo_with_counter #(
        .width ( 33    ),
        .depth ( 2*N+1 )
    ) fifo_2 (
        .clk        ( clk            ),
        .rst        ( rst            ),
        .push       ( 1'b1           ),
        .pop        ( 1'b1           ),
        .write_data ( { arg_vld, a } ),
        .read_data  ( fifo_2_read    ),
        .empty      ( fifo_2_empty   ),
        .full       ( fifo_2_full    )
    );

    assign a_delayed_vld = fifo_2_read[32];
    assign a_delayed     = fifo_2_read[31:0];

    assign sum_abc_vld = isqrt_2_y_vld & a_delayed_vld;
    assign sum_abc     = a_delayed + { 16'b0, isqrt_2_y };

    always_ff @(posedge clk or posedge rst)
        if (rst) begin
            isqrt_3_x_vld <= 1'b0;
            isqrt_3_x     <= '0;
        end
        else if (sum_abc_vld) begin
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