module tb_simple_ram;

    logic clk;
    logic [7:0] addr;
    logic [7:0] dout;

    // Instantiate RAM
    simple_ram uut (
        .clk(clk),
        .addr(addr),
        .dout(dout)
    );

    // Generate 50 MHz clock
    initial clk = 0;
    always #10 clk = ~clk;

    // Waveform recording
    initial begin
        $dumpfile("ram_wave.vcd");
        $dumpvars(0, tb_simple_ram);
    end

    // Test memory reads
    initial begin

        addr = 0;

        // Read address 0
        @(negedge clk);
        addr = 0;

        @(posedge clk);
        #1;
        $display("Address 0: %0d", $signed(dout));

        if ($signed(dout) != 5)
            $fatal(1,"Address 0 test failed");

        // Read address 1
        @(negedge clk);
        addr = 1;

        @(posedge clk);
        #1;
        $display("Address 1: %0d", $signed(dout));

        if ($signed(dout) != 8)
            $fatal(1,"Address 1 test failed");

        // Read address 2
        @(negedge clk);
        addr = 2;

        @(posedge clk);
        #1;
        $display("Address 2: %0d", $signed(dout));

        if ($signed(dout) != -3)
            $fatal(1,"Address 2 test failed");

        // Read address 3
        @(negedge clk);
        addr = 3;

        @(posedge clk);
        #1;
        $display("Address 3: %0d", $signed(dout));

        if ($signed(dout) != 12)
            $fatal(1,"Address 3 test failed");
// Read address 4
@(negedge clk);
addr = 4;
@(posedge clk);
#1;
$display("Address 4: %0d", $signed(dout));
if ($signed(dout) != 127)
    $fatal(1, "Address 4 test failed");

// Read address 5
@(negedge clk);
addr = 5;
@(posedge clk);
#1;
$display("Address 5: %0d", $signed(dout));
if ($signed(dout) != -128)
    $fatal(1, "Address 5 test failed");

// Read address 6
@(negedge clk);
addr = 6;
@(posedge clk);
#1;
$display("Address 6: %0d", $signed(dout));
if ($signed(dout) != 25)
    $fatal(1, "Address 6 test failed");

// Read address 7
@(negedge clk);
addr = 7;
@(posedge clk);
#1;
$display("Address 7: %0d", $signed(dout));
if ($signed(dout) != -10)
    $fatal(1, "Address 7 test failed");

        $display("All RAM tests passed!");

        $finish;
    end

endmodule
