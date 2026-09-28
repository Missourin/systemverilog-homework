//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens_with_flow_control
(
    input  clk,
    input  rst,

    input  up_valid,
    output up_ready,
    input  up_token,

    output down_valid,
    input  down_ready,
    output down_data
);

    logic expect_second;

    // up_ready = 1, когда можем принять (готовы, кроме случая, когда ждём второй токен и down_ready=0)
    assign up_ready   = ~(expect_second & ~down_ready);

    // down_valid = up_valid (как требует тестбенч)
    assign down_valid = up_valid;

    // down_data = 1, если это второй токен пары
    assign down_data  = expect_second & up_valid & up_ready & up_token;

    wire up_fire = up_valid & up_ready & up_token;

    always_ff @(posedge clk or posedge rst)
        if (rst)
            expect_second <= 1'b0;
        else if (up_fire)
            expect_second <= ~expect_second;

endmodule