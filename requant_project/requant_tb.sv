
module requant_tb;

    logic signed [31:0] acc_in;
    logic signed [31:0] bias;
    logic signed [31:0] multiplier;
    logic signed [7:0] zero_point;
    logic relu_enable;

    logic signed [7:0] data_out;

    integer errors = 0;

    requant dut (
        .acc_in(acc_in),
        .bias(bias),
        .multiplier(multiplier),
        .zero_point(zero_point),
        .relu_enable(relu_enable),
        .data_out(data_out)
    );

    task automatic check_case(
        input string test_name,
        input logic signed [31:0] a,
        input logic signed [31:0] b,
        input logic signed [31:0] m,
        input logic signed [7:0] zp,
        input logic relu,
        input logic signed [7:0] expected
    );
    begin
        acc_in = a;
        bias = b;
        multiplier = m;
        zero_point = zp;
        relu_enable = relu;

        #1;

        if (data_out !== expected) begin
            $display(
                "FAIL: %s | Expected: %0d | Got: %0d",
                test_name, expected, data_out
            );
            errors = errors + 1;
        end
        else begin
            $display(
                "PASS: %s | Output: %0d",
                test_name, data_out
            );
        end
    end
    endtask

    initial begin

        $display("--------------------------------");
        $display("REQUANTIZATION TEST STARTED");
        $display("--------------------------------");

        // Positive scaling
        check_case(
            "Positive scaling",
            32'sd1000, 32'sd0, 32'sd1638,
            8'sd0, 1'b0, 8'sd50
        );

        // Negative scaling
        check_case(
            "Negative scaling",
            -32'sd1000, 32'sd0, 32'sd1638,
            8'sd0, 1'b0, -8'sd50
        );

        // Bias addition
        check_case(
            "Bias addition",
            32'sd800, 32'sd200, 32'sd1638,
            8'sd0, 1'b0, 8'sd50
        );

        // Zero-point adjustment
        check_case(
            "Zero point",
            32'sd1000, 32'sd0, 32'sd1638,
            8'sd5, 1'b0, 8'sd55
        );

        // ReLU
        check_case(
            "ReLU",
            -32'sd1000, 32'sd0, 32'sd1638,
            8'sd0, 1'b1, 8'sd0
        );

        // Positive saturation
        check_case(
            "Positive saturation",
            32'sd5000, 32'sd0, 32'sd16384,
            8'sd0, 1'b0, 8'sd127
        );

        // Negative saturation
        check_case(
            "Negative saturation",
            -32'sd5000, 32'sd0, 32'sd16384,
            8'sd0, 1'b0, -8'sd128
        );

        // Zero input
        check_case(
            "Zero input",
            32'sd0, 32'sd0, 32'sd16384,
            8'sd0, 1'b0, 8'sd0
        );

        $display("--------------------------------");

        if (errors == 0)
            $display("PASS: ALL TESTS PASSED");
        else
            $display("FAIL: %0d TESTS FAILED", errors);

        $display("--------------------------------");

        $finish;
    end

endmodule
