
module requant (
    input  logic signed [31:0] acc_in,
    input  logic signed [31:0] bias,
    input  logic signed [31:0] multiplier,
    input  logic signed [7:0]  zero_point,
    input  logic               relu_enable,

    output logic signed [7:0] data_out
);

    // Intermediate signals
    logic signed [32:0]  acc_bias;
    logic signed [64:0]  acc_bias_ext;
    logic signed [64:0]  multiplier_ext;
    logic signed [129:0] product_full;
    logic signed [64:0]  product;

    logic        [64:0] magnitude;
    logic        [64:0] rounded_magnitude;

    logic signed [65:0] scaled_value;
    logic signed [65:0] adjusted_value;

    always_comb begin

        // Stage 1: Add bias
        acc_bias =
            {acc_in[31], acc_in} +
            {bias[31], bias};

        // Extend operands to preserve multiplication width
        acc_bias_ext = {{32{acc_bias[32]}}, acc_bias};

        multiplier_ext =
            {{33{multiplier[31]}}, multiplier};

        // Stage 2: Fixed-point multiplication
        product_full = acc_bias_ext * multiplier_ext;

        // Original product fits in 65 signed bits
        product = product_full[64:0];

        // Stage 3: Rounding and Q15 right shift
        // Round to nearest, ties away from zero
        if (product[64])
            magnitude = -$unsigned(product);
        else
            magnitude = $unsigned(product);

        rounded_magnitude =
            (magnitude + 65'd16384) >> 15;

        if (product[64])
            scaled_value = -$signed({1'b0, rounded_magnitude});
        else
            scaled_value = $signed({1'b0, rounded_magnitude});

        // Stage 4: ReLU and zero-point adjustment
        if (relu_enable && scaled_value < 0)
            adjusted_value = {{58{zero_point[7]}}, zero_point};
        else
            adjusted_value = scaled_value +
                {{58{zero_point[7]}}, zero_point};

        // Stage 5: INT8 saturation
        if (adjusted_value > 66'sd127)
            data_out = 8'sd127;

        else if (adjusted_value < -66'sd128)
            data_out = -8'sd128;

        else
            data_out = adjusted_value[7:0];

    end

endmodule

