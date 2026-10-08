module float_discriminant_distributor
(
    input                     clk,
    input                     rst,
    input                     arg_vld,

    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,
    output logic              busy
);

    localparam N         = 22;
    localparam SEL_WIDTH = $clog2(N);

    logic [SEL_WIDTH-1:0] sel_in;
    logic [SEL_WIDTH-1:0] sel_out;

    logic [N-1:0]           blk_arg_vld;
    logic [N-1:0][FLEN-1:0] blk_a, blk_b, blk_c;

    logic [N-1:0]           blk_res_vld;
    logic [N-1:0][FLEN-1:0] blk_res;
    logic [N-1:0]           blk_res_neg;
    logic [N-1:0]           blk_err;
    logic [N-1:0]           blk_busy_out;

    assign res_vld      = blk_res_vld [sel_out];
    assign res          = blk_res     [sel_out];
    assign res_negative = blk_res_neg [sel_out];
    assign err          = blk_err     [sel_out];

    assign busy         = |blk_busy_out;

    always_ff @(posedge clk) begin
        if (rst) begin
            sel_in <= '0;
        end else if (arg_vld) begin
            if (sel_in == N - 1)
                sel_in <= '0;
            else
                sel_in <= sel_in + 1'b1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            sel_out <= '0;
        end else if (res_vld) begin
            if (sel_out == N - 1)
                sel_out <= '0;
            else
                sel_out <= sel_out + 1'b1;
        end
    end

    generate
        for (genvar i = 0; i < N; i++) begin : g_dmx
            always_comb begin
                blk_arg_vld [i] = arg_vld && (sel_in == i [SEL_WIDTH-1:0]);
                blk_a       [i] = a;
                blk_b       [i] = b;
                blk_c       [i] = c;
            end
        end
    endgenerate

    generate
        for (genvar i = 0; i < N; i++) begin : g_calc
            float_discriminant u_blk (
                .clk          ( clk             ),
                .rst          ( rst             ),
                .arg_vld      ( blk_arg_vld  [i] ),
                .a            ( blk_a        [i] ),
                .b            ( blk_b        [i] ),
                .c            ( blk_c        [i] ),
                .res_vld      ( blk_res_vld  [i] ),
                .res          ( blk_res      [i] ),
                .res_negative ( blk_res_neg  [i] ),
                .err          ( blk_err      [i] ),
                .busy         ( blk_busy_out [i] )
            );
        end
    endgenerate

endmodule