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

    logic [31:0] a_reg [N];
    logic [31:0] b_reg [N];
    logic [31:0] c_reg [N];

    logic  arg_vld_reg [N];

    logic [IDX_WIDTH-1:0] idx;

    logic [31:0] out_res [N];
    logic        out_vld [N];

    always_ff @(posedge clk) begin
        if (rst) begin
            idx <= '0;
            for (int i = 0; i < N; i++) begin
                a_reg       [i] <= '0;
                b_reg       [i] <= '0;
                c_reg       [i] <= '0;
                arg_vld_reg [i] <= 1'b0;
            end
        end
        else begin
            for (int i = 0; i < N; i++) begin
                arg_vld_reg [i] <= 1'b0;
            end

            if (arg_vld) begin
                a_reg       [idx] <= a;
                b_reg       [idx] <= b;
                c_reg       [idx] <= c;
                arg_vld_reg [idx] <= 1'b1;

                if (idx == N - 1) idx <= '0;
                else              idx <= idx + 1'b1;
            end
        end
    end

    generate
      if (formula == 1 && impl == 1) begin : g_f1_i1
          for (genvar i = 0; i < N; i++) begin : gen_modules
              formula_1_impl_1_top i_top (
                  .clk     ( clk             ),
                  .rst     ( rst             ),
                  .arg_vld ( arg_vld_reg [i] ),
                  .a       ( a_reg       [i] ),
                  .b       ( b_reg       [i] ),
                  .c       ( c_reg       [i] ),
                  .res_vld ( out_vld     [i] ),
                  .res     ( out_res     [i] )
                  );
          end
      end
      else if (formula == 1 && impl == 2) begin : g_f1_i2
          for (genvar i = 0; i < N; i++) begin : gen_modules
              formula_1_impl_2_top i_top (
                  .clk     ( clk             ),
                  .rst     ( rst             ),
                  .arg_vld ( arg_vld_reg [i] ),
                  .a       ( a_reg       [i] ),
                  .b       ( b_reg       [i] ),
                  .c       ( c_reg       [i] ),
                  .res_vld ( out_vld     [i] ),
                  .res     ( out_res     [i] )
                  );
          end
      end
      else begin : g_f2
          for (genvar i = 0; i < N; i++) begin : gen_modules
              formula_2_top i_top (
                  .clk     ( clk             ),
                  .rst     ( rst             ),
                  .arg_vld ( arg_vld_reg [i] ),
                  .a       ( a_reg       [i] ),
                  .b       ( b_reg       [i] ),
                  .c       ( c_reg       [i] ),
                  .res_vld ( out_vld     [i] ),
                  .res     ( out_res     [i] )
                  );
          end
      end
    endgenerate

    logic        res_vld_next;
    logic [31:0] res_next;

    always_comb begin
        res_vld_next = 1'b0;
        res_next     = '0;

        for (int i = 0; i < N; i++) begin
            if (out_vld [i] && !res_vld_next) begin
                res_vld_next = 1'b1;
                res_next     = out_res [i];
            end
        end
    end

    always_ff @(posedge clk)
        if (rst) res_vld <= 1'b0;
        else     res_vld <= res_vld_next;

    always_ff @(posedge clk)
      if (rst) res <= '0;
      else     res <= res_next;

endmodule
