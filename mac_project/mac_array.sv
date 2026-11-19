
module mac_array (
    input  logic clk,
    input  logic reset,
    input  logic start,

    input  logic [511:0] matrix_a,
    input  logic [511:0] matrix_b,

    output wire [2047:0] matrix_c,

    output wire busy,
    output wire done
);

    // Controller states
    typedef enum logic [1:0] {
        IDLE,
        COMPUTE,
        DONE
    } state_t;

    state_t state;

    // Shared multiplication index
    logic [2:0] k_index;

    // Clear all MAC accumulators when a new operation starts
    wire clear_acc;
    assign clear_acc = (state == IDLE) && start;

    // Status signals
    assign busy = (state == COMPUTE);
    assign done = (state == DONE);

    // Controller
    always_ff @(posedge clk) begin
        if (reset) begin
            state   <= IDLE;
            k_index <= 3'd0;
        end
        else begin
            case (state)

                IDLE: begin
                    k_index <= 3'd0;

                    if (start)
                        state <= COMPUTE;
                end

                COMPUTE: begin
                    if (k_index == 3'd7) begin
                        state <= DONE;
                    end
                    else begin
                        k_index <= k_index + 1'b1;
                    end
                end

                DONE: begin
                    state <= IDLE;
                end

                default: begin
                    state   <= IDLE;
                    k_index <= 3'd0;
                end

            endcase
        end
    end

    // Generate 64 MAC units
    genvar i, j;

    generate
        for (i = 0; i < 8; i = i + 1) begin : ROW

            for (j = 0; j < 8; j = j + 1) begin : COL

                wire signed [7:0] a_operand;
                wire signed [7:0] b_operand;
                wire signed [31:0] acc_value;

                // Select A[i][k_index]
                assign a_operand =
                    $signed(matrix_a[((i*8 + k_index)*8) +: 8]);

                // Select B[k_index][j]
                assign b_operand =
                    $signed(matrix_b[((k_index*8 + j)*8) +: 8]);

                // Individual MAC instance
                mac mac_inst (
                    .clk    (clk),
                    .reset  (reset | clear_acc),
                    .enable (state == COMPUTE),
                    .a      (a_operand),
                    .b      (b_operand),
                    .acc    (acc_value)
                );

                // Connect accumulator to output matrix
                assign matrix_c[((i*8 + j)*32) +: 32] =
                    acc_value;

            end
        end
    endgenerate

endmodule
