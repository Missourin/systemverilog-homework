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

    wire limit_reached = (cnt >= 7'd100);

    assign up_ready = ~limit_reached;
    assign down_valid = (out_gen_cnt > 0) | up_valid;
    assign down_data  = (out_gen_cnt > 0) ? 1'b1 : up_token;

    always_ff @(posedge clk) begin
        if (rst) begin
            out_gen_cnt <= '0;
            cnt         <= '0;
        end
        else begin
            if (down_ready) begin
                cnt <= '0;
            end else if (up_hs) begin
                if (up_token)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= '0;
            end

            case ({up_hs & up_token, down_hs})
                2'b11: begin
                    if (out_gen_cnt == 0)
                        out_gen_cnt <= out_gen_cnt + 1'b1;
                end

                2'b10: begin
                    out_gen_cnt <= out_gen_cnt + 2'd2;
                end

                2'b01: begin
                    if (out_gen_cnt > 0)
                        out_gen_cnt <= out_gen_cnt - 1'b1;
                end
            endcase
        end
    end

endmodule