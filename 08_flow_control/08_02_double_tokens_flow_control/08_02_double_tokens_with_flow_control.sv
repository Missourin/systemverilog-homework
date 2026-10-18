module double_tokens_with_flow_control
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

  // Task:
  // Implement module double input signals (tokens). The module must use signals valid-ready for
  // transfer tokens. If the module receives more than 100 sequential tokens then it must set up_ready = 0;

    logic [7:0] out_gen_cnt;
    logic [6:0] cnt;

    wire up_hs   = up_valid & up_ready;
    wire down_hs = down_valid & down_ready;

    assign down_valid = 1'b1;
    assign up_ready   = (cnt < 7'd100);
    assign down_data  = (out_gen_cnt > 0) ? 1'b1 : (up_valid & up_token);

    always_ff @(posedge clk or posedge rst)
        if (rst)
            cnt <= '0;
        else if (cnt >= 7'd100 & down_ready)
            cnt <= '0;
        else if (up_hs) begin
            if (up_token)
                cnt <= cnt + 1'b1;
            else
                cnt <= '0;
        end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            out_gen_cnt <= '0;
        else begin
            case ({up_hs & up_token, down_hs})
                2'b11:                      out_gen_cnt <= out_gen_cnt + 1'b1;
                2'b10:                      out_gen_cnt <= out_gen_cnt + 2'd2;
                2'b01: if (out_gen_cnt > 0) out_gen_cnt <= out_gen_cnt - 1'b1;

                default: out_gen_cnt <= out_gen_cnt;
            endcase
        end
    end

endmodule