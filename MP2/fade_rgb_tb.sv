`timescale 10ns/100ps
`include "top.sv"

module fade_rgb_tb;

    parameter PWM_INTERVAL = 2000;

    logic clk = 0;
    logic RGB_R;
    logic RGB_B;
    logic RGB_G;

    top # (
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u0 (
        .clk              (clk),
        .RGB_R            (RGB_R),
        .RGB_G            (RGB_G),
        .RGB_B            (RGB_B)
    );

    initial begin
        $dumpfile("fade_rgb.vcd");
        $dumpvars(0, fade_rgb_tb);
        #200000000 // run simulation for 2 seconds
        $finish;
    end

    always begin
        #4.1667 // trying to simulate at 12MHz
        clk = ~clk;
    end

endmodule

