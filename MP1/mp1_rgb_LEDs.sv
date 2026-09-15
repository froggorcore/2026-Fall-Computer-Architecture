// Change LED colors

module top(
    input logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);
    // CLK frequency is 12MHz, so 6,000,000 cycles is 0.5s
    parameter COLOR_INTERVAL = 2000000;
    parameter CYCLE_INTERVAL = 12000000;
    logic [$clog2(CYCLE_INTERVAL) - 1:0] count = 0;

    // start RGB LED values to be at 1
    // since LEDs is active low, all LEDs are off.
    initial begin
        RGB_R = 1'b1;
        RGB_G = 1'b1;
        RGB_B = 1'b1;
    end

    always_ff @(posedge clk) begin
        if (count >= CYCLE_INTERVAL - 1) begin
            count <= 0;
        end else begin
            count <= count + 1;
        end

        // RED
        if (count < 1*COLOR_INTERVAL) begin
            RGB_R <= 1'b0;
            RGB_G <= 1'b1;
            RGB_B <= 1'b1;
        end
        // YELLOW
        else if (count < 2*COLOR_INTERVAL) begin
            RGB_R <= 1'b0;
            RGB_G <= 1'b0;
            RGB_B <= 1'b1;
        end
        // GREEN
        else if (count < 3*COLOR_INTERVAL) begin
            RGB_R <= 1'b1;
            RGB_G <= 1'b0;
            RGB_B <= 1'b1;
        end
        // CYAN
        else if (count < 4*COLOR_INTERVAL - 1) begin
            RGB_R <= 1'b1;
            RGB_G <= 1'b0;
            RGB_B <= 1'b0;
        end
        // BLUE
        else if (count < 5*COLOR_INTERVAL - 1) begin
            RGB_R <= 1'b1;
            RGB_G <= 1'b1;
            RGB_B <= 1'b0;
        end
        // MAGENTA
        else begin
            RGB_R <= 1'b0;
            RGB_G <= 1'b1;
            RGB_B <= 1'b0;
        end
    end

endmodule
