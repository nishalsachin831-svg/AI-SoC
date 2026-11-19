module simple_ram (
    input  logic       clk,
    input  logic [7:0] addr,
    output logic [7:0] dout
);

    // 256 memory locations, 8 bits each
    logic [7:0] mem [0:255];

    // Initialize memory from file
    initial begin
        $readmemh("weights.mem", mem,0, 7);
    end

    // Synchronous read
    always_ff @(posedge clk) begin
        dout <= mem[addr];
    end

endmodule
