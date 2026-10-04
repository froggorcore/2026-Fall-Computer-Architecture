// PWM generator to fade LED

module pwm #(
    parameter PWM_INTERVAL = 2000       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic clk,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_count = 0
);
    // Implement counter for timing transition in PWM output signal
    always_ff @(posedge clk) begin
        if (pwm_count == PWM_INTERVAL - 1) begin
            pwm_count <= 0;
        end
        else begin
            pwm_count <= pwm_count + 1;
        end
    end

endmodule
