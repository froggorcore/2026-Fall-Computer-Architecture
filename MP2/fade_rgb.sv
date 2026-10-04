// Finite State Machine

module fade_rgb #(
    parameter STATE_INTERVAL = 2000000,     // CLK freq is 12MHz, so 2000000 cycles is 1/6th of a second
    parameter PWM_INTERVAL = 2000,
    parameter CYCLES_PER_STATE = STATE_INTERVAL / PWM_INTERVAL,
    parameter INC_DEC_VAL = PWM_INTERVAL / CYCLES_PER_STATE
)(
    input logic clk,
    output logic [$clog2(PWM_INTERVAL+1)-1:0] red,
    output logic [$clog2(PWM_INTERVAL+1)-1:0] green,
    output logic [$clog2(PWM_INTERVAL+1)-1:0] blue

);

    // Define state variable values
    localparam HUE_ANGLE_0 = 3'b000;
    localparam HUE_ANGLE_60 = 3'b001;
    localparam HUE_ANGLE_120 = 3'b010;
    localparam HUE_ANGLE_180 = 3'b011;
    localparam HUE_ANGLE_240 = 3'b100;
    localparam HUE_ANGLE_300 = 3'b101;

    // Declare state variables
    logic [2:0] current_state = HUE_ANGLE_0;
    logic [2:0] next_state;

    // Declare next output variables
    logic [$clog2(PWM_INTERVAL+1)-1:0] red_pwm_value = PWM_INTERVAL;
    logic [$clog2(PWM_INTERVAL+1)-1:0] green_pwm_value = 0;
    logic [$clog2(PWM_INTERVAL+1)-1:0] blue_pwm_value = 0;

    // Declare variables for timing state transitions
    logic [$clog2(STATE_INTERVAL) - 1:0] count = 0;
    logic [$clog2(CYCLES_PER_STATE) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0; // time to go to next PWM duty cycle
    logic time_to_transition = 1'b0;

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition)
        current_state <= next_state;

    // Compute the next state of the FSM
    always_comb begin
        next_state = 3'bxxx;
        case (current_state)
            HUE_ANGLE_0:
                next_state = HUE_ANGLE_60;
            HUE_ANGLE_60:
                next_state = HUE_ANGLE_120;
            HUE_ANGLE_120:
                next_state = HUE_ANGLE_180;
            HUE_ANGLE_180:
                next_state = HUE_ANGLE_240;
            HUE_ANGLE_240:
                next_state = HUE_ANGLE_300;
            HUE_ANGLE_300:
                next_state = HUE_ANGLE_0;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count == PWM_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            HUE_ANGLE_0: begin
                green_pwm_value <= green_pwm_value + INC_DEC_VAL;
            end

            HUE_ANGLE_60: begin
                red_pwm_value <= red_pwm_value - INC_DEC_VAL;
            end

            HUE_ANGLE_120: begin
                blue_pwm_value <= blue_pwm_value + INC_DEC_VAL;
            end

            HUE_ANGLE_180: begin
                green_pwm_value <= green_pwm_value - INC_DEC_VAL;
            end

            HUE_ANGLE_240: begin
                red_pwm_value <= red_pwm_value + INC_DEC_VAL;
            end

            HUE_ANGLE_300: begin
                blue_pwm_value <= blue_pwm_value - INC_DEC_VAL;
            end
        endcase
    end


    // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == CYCLES_PER_STATE - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

    // Register the FSM outputs
    always_ff @(posedge clk) begin
        red <= red_pwm_value;
        green <= green_pwm_value;
        blue <= blue_pwm_value;
    end

endmodule
