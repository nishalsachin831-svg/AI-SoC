
module mac_array_tb;

    logic clk = 0;
    logic reset;
    logic start;

    logic [511:0] matrix_a;
    logic [511:0] matrix_b;

    wire [2047:0] matrix_c;
    wire busy;
    wire done;

    integer i, j;
    integer errors;

    mac_array dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .matrix_a(matrix_a),
        .matrix_b(matrix_b),
        .matrix_c(matrix_c),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin

        reset = 1;
        start = 0;
        matrix_a = 0;
        matrix_b = 0;
        errors = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Load identity matrix A and matrix B
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin

                matrix_a[((i*8+j)*8) +: 8] =
                    (i == j) ? 8'd1 : 8'd0;

                matrix_b[((i*8+j)*8) +: 8] =
                    (i*8+j) + 1;

            end
        end

        // Start computation
        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;

        // Wait for completion
        wait(done == 1);

// Allow outputs to settle before checking
@(negedge clk);

// Verify all 64 outputs
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin

                if ($signed(matrix_c[((i*8+j)*32) +: 32])
                    !== ((i*8+j)+1)) begin

                    $display("FAIL: C[%0d][%0d]", i, j);
                    errors = errors + 1;

                end

            end
        end

        if (errors == 0)
            $display("PASS: All 64 outputs are correct.");
        else
            $display("FAIL: %0d errors detected.", errors);

        $finish;

    end

endmodule
