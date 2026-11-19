module tb_mac;

    logic clk = 0;
    logic reset, enable;
    logic signed [7:0] a, b;
    logic signed [31:0] acc;

    mac dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .a(a),
        .b(b),
        .acc(acc)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("mac.vcd");
        $dumpvars(0, tb_mac);

        reset = 1;
        enable = 0;
        a = 0;
        b = 0;

        @(negedge clk);
        reset = 0;

        a = 5;
        b = 3;
        enable = 1;

        @(negedge clk);
        $display("SystemVerilog MAC Output: %0d", acc);

        if (acc == 15)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule
