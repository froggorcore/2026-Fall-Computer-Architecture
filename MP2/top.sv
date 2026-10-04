`include "fade_rgb.sv"
`include "pwm.sv"

// fade_rgb top level module

module top #(
    parameter PWM_INTERVAL = 2000
)(
    input logic  clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    // Shared counter value
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value;

    //
    logic [$clog2(PWM_INTERVAL) - 1:0] red_level;
    logic [$clog2(PWM_INTERVAL) - 1:0] green_level;
    logic [$clog2(PWM_INTERVAL) - 1:0] blue_level;

    fade_rgb #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk      (clk),
        .red      (red_level),
        .green    (green_level),
        .blue     (blue_level)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk),
        .pwm_count      (pwm_value)
    );

    assign RGB_R = ~(pwm_value < red_level);
    assign RGB_G = ~(pwm_value < green_level);
    assign RGB_B = ~(pwm_value < blue_level);

endmodule
