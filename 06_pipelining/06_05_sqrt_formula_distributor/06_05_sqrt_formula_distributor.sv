module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res
);

    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.

    localparam N = 50;
    localparam IDX_WIDTH = $clog2(N);

    logic [IDX_WIDTH-1:0] in_idx;
    logic [IDX_WIDTH-1:0] out_idx;

    logic [31:0] selected_res;
    logic        selected_vld;

    wire [N-1:0]        inst_arg_vld;
    wire [N-1:0]        inst_res_vld_raw;
    wire [31 :0]        inst_res_raw [N-1:0];

    assign selected_res = inst_res_raw     [out_idx];
    assign selected_vld = inst_res_vld_raw [out_idx];

    always_ff @(posedge clk or posedge rst)
        if (rst) res <= '0;
        else     res <= selected_res;

    always_ff @(posedge clk or posedge rst)
        if (rst) res_vld <= 1'b0;
        else     res_vld <= selected_vld;

    always_ff @(posedge clk or posedge rst)
        if (rst)
            in_idx <= '0;
        else if (arg_vld) begin
            if (in_idx == N - 1)
                in_idx <= '0;
            else
                in_idx <= in_idx + 1'b1;
        end

    always_ff @(posedge clk or posedge rst)
        if (rst)
            out_idx <= '0;
        else if (selected_vld) begin
            if (out_idx == N - 1)
                out_idx <= '0;
            else
                out_idx <= out_idx + 1'b1;
        end

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen_calc_units

            assign inst_arg_vld [i] = arg_vld && (in_idx == i);

            if (formula == 1 && impl == 1) begin : g_f1_i1
                formula_1_impl_1_top i_top (
                    .clk     ( clk                  ),
                    .rst     ( rst                  ),
                    .arg_vld ( inst_arg_vld     [i] ),
                    .a       ( a                    ),
                    .b       ( b                    ),
                    .c       ( c                    ),
                    .res_vld ( inst_res_vld_raw [i] ),
                    .res     ( inst_res_raw     [i] )
                );
            end
            else if (formula == 1 && impl == 2) begin : g_f1_i2
                formula_1_impl_2_top i_top (
                    .clk     ( clk                  ),
                    .rst     ( rst                  ),
                    .arg_vld ( inst_arg_vld     [i] ),
                    .a       ( a                    ),
                    .b       ( b                    ),
                    .c       ( c                    ),
                    .res_vld ( inst_res_vld_raw [i] ),
                    .res     ( inst_res_raw     [i] )
                );
            end
            else begin : g_f2
                formula_2_top i_top (
                    .clk     ( clk                  ),
                    .rst     ( rst                  ),
                    .arg_vld ( inst_arg_vld     [i] ),
                    .a       ( a                    ),
                    .b       ( b                    ),
                    .c       ( c                    ),
                    .res_vld ( inst_res_vld_raw [i] ),
                    .res     ( inst_res_raw     [i] )
                );
            end
        end
    endgenerate

endmodule
