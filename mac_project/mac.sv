
module mac (
    input  logic clk,
    input  logic reset,
    input  logic enable,

    input  logic signed [7:0] a,
    input  logic signed [7:0] b,

    output logic signed [31:0] acc
);

    logic signed [15:0] product;

    // Signed 8-bit multiplication
    assign product = a * b;

    // Accumulate the product
    always_ff @(posedge clk) begin
        if (reset)
            acc <= 32'sd0;
        else if (enable)
            acc <= acc + {{16{product[15]}}, product};
    end

endmodule

