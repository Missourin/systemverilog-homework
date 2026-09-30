module float_discriminant_distributor
(
    input                     clk,
    input                     rst,
    input                     arg_vld,

    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,
    output logic              busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.

    localparam N         = 22;
    localparam SEL_WIDTH = $clog2(N);

    logic [SEL_WIDTH-1:0] sel_in;

    logic [N-1:0]           blk_arg_vld;
    logic [N-1:0][FLEN-1:0] blk_a, blk_b, blk_c;

    logic [N-1:0]           blk_res_vld;
    logic [N-1:0][FLEN-1:0] blk_res;
    logic [N-1:0]           blk_res_neg;
    logic [N-1:0]           blk_err;
    logic [N-1:0]           blk_busy_out;

    logic [N-1:0]           blk_ready;
    logic [N-1:0][FLEN-1:0] blk_res_saved;
    logic [N-1:0]           blk_neg_saved;
    logic [N-1:0]           blk_err_saved;

    assign res_vld      = blk_ready     [sel_in];
    assign res          = blk_res_saved [sel_in];
    assign res_negative = blk_neg_saved [sel_in];
    assign err          = blk_err_saved [sel_in];

    assign busy = |blk_busy_out || arg_vld;

    always_ff @(posedge clk)
        if (rst) sel_in <= '0;
        else     sel_in <= sel_in + 1'b1;

    generate
        for (genvar i = 0; i < N; i++) begin : g_dmx
            always_comb begin
                blk_arg_vld [i] = arg_vld && (sel_in == i [SEL_WIDTH-1:0]);
                blk_a [i] = a;
                blk_b [i] = b;
                blk_c [i] = c;
            end
        end
    endgenerate

    generate
        for (genvar i = 0; i < N; i++) begin : g_calc
            float_discriminant u_blk (
                .clk          ( clk              ),
                .rst          ( rst              ),
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

    always_ff @(posedge clk)
        if (rst) begin
            blk_ready <= '0;
        end
        else begin
            for (int p = 0; p < N; p = p + 1) begin
                if (blk_res_vld [p]) begin
                    blk_res_saved [p] <= blk_res [p];
                    blk_neg_saved [p] <= blk_res_neg [p];
                    blk_err_saved [p] <= blk_err [p];
                    blk_ready     [p] <= 1'b1;
                end
                else if ((sel_in == p) && blk_ready [p]) begin
                    blk_ready [p] <= 1'b0;
                end
            end
        end

endmodule