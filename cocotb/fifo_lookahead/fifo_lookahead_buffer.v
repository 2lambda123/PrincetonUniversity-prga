// Automatically generated by PRGA's RTL generator
//
// Convert a non-lookahead FIFO to a lookahead FIFO if REVERSED is 0
// or, convert a lookahead FIFO to a non-lookahead FIFO if REVERSED is 1
`timescale 1ns/1ps
module fifo_lookahead_buffer #(
    parameter DATA_WIDTH = 32,
    parameter REVERSED = 0
) (
    input wire [0:0] clk,
    input wire [0:0] rst,

    input wire [0:0] empty_i,
    output reg [0:0] rd_i,
    input wire [DATA_WIDTH - 1:0] dout_i,

    output reg [0:0] empty,
    input wire [0:0] rd,
    output reg [DATA_WIDTH - 1:0] dout
    );

    generate if (REVERSED) begin
        always @(posedge clk) begin
            dout <= dout_i;
        end

        always @* begin
            empty = empty_i;
            rd_i = rd;
        end
    end else begin
        reg [DATA_WIDTH - 1:0] dout_i_f;
        reg dout_i_valid;

        always @(posedge clk) begin
            if (rst) begin
                empty <= 'b1;
                dout_i_valid <= 'b0;
            end else begin
                if (~empty_i && rd_i) begin
                    empty <= 'b0;
                end else if (rd) begin
                    empty <= 'b1;
                end

                dout_i_valid <= ~empty_i && rd_i;
            end
        end

        always @(posedge clk) begin
            if (dout_i_valid) begin
                dout_i_f <= dout_i;
            end
        end

        always @* begin
            rd_i = empty || rd;
            dout = dout_i_valid ? dout_i : dout_i_f;
        end
    end endgenerate

endmodule
