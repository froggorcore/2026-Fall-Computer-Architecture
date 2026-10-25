
module controller (
    input logic clk,
    input logic enable,
    output logic start_calc,
    output logic load_sreg,
    output logic transmit_pixel,
    output logic [5:0] pixel
);

    localparam TRANSMIT_FRAME = 1'b0;
    localparam IDLE           = 1'b1;

    localparam [2:0] READ_CH_VALS   = 3'b001;
    localparam [2:0] LOAD_SREG      = 3'b010;
    localparam [2:0] TRANSMIT_PIXEL = 3'b100;

    localparam [8:0] TRANSMIT_CYCLES = 9'd360;

    parameter [23:0] IDLE_CYCLES = 24'd11976832;

    logic state = TRANSMIT_FRAME;
    logic next_state;

    logic [2:0] transmit_phase = READ_CH_VALS;
    logic [2:0] next_transmit_phase;

    logic [5:0] pixel_counter = 6'd0;
    logic [8:0] transmit_counter = 9'd0;
    logic [23:0] idle_counter = 24'd0;

    logic transmit_pixel_done;
    logic idle_done;

    assign transmit_pixel_done =
        (transmit_counter == TRANSMIT_CYCLES - 1'b1);

    assign idle_done =
        (idle_counter == IDLE_CYCLES - 1'b1);

    // state and phase registers
    always_ff @(posedge clk) begin
        if (!enable) begin
            state <= TRANSMIT_FRAME;
            transmit_phase <= READ_CH_VALS;
        end
        else begin
            state <= next_state;
            transmit_phase <= next_transmit_phase;
        end
    end

    // main controller state machine
    always_comb begin
        next_state = state;
        start_calc = 1'b0;

        if (enable) begin
            unique case (state)
                TRANSMIT_FRAME: begin
                    if ((pixel_counter == 6'd63) &&
                        transmit_pixel_done) begin
                        next_state = IDLE;
                        start_calc = 1'b1;
                    end
                end

                IDLE: begin
                    if (idle_done)
                        next_state = TRANSMIT_FRAME;
                end

                default: next_state = TRANSMIT_FRAME;
            endcase
        end
    end

    // transmission phase state machine
    always_comb begin
        next_transmit_phase = READ_CH_VALS;

        if (enable && (state == TRANSMIT_FRAME)) begin
            unique case (transmit_phase)
                READ_CH_VALS:
                    next_transmit_phase = LOAD_SREG;

                LOAD_SREG:
                    next_transmit_phase = TRANSMIT_PIXEL;

                TRANSMIT_PIXEL:
                    next_transmit_phase =
                        transmit_pixel_done
                        ? READ_CH_VALS
                        : TRANSMIT_PIXEL;

                default:
                    next_transmit_phase = READ_CH_VALS;
            endcase
        end
    end

    // pixel counter
    always_ff @(posedge clk) begin
        if (!enable)
            pixel_counter <= 6'd0;
        else if ((state == TRANSMIT_FRAME) &&
                 transmit_pixel_done)
            pixel_counter <= pixel_counter + 1'b1;
    end

    // transmission bit-cycle counter
    always_ff @(posedge clk) begin
        if (!enable || (transmit_phase != TRANSMIT_PIXEL))
            transmit_counter <= 9'd0;
        else
            transmit_counter <= transmit_counter + 1'b1;
    end

    // idle interval counter
    always_ff @(posedge clk) begin
        if (!enable || (state != IDLE))
            idle_counter <= 24'd0;
        else
            idle_counter <= idle_counter + 1'b1;
    end

    // outputs
    assign pixel = pixel_counter;

    assign load_sreg =
        enable && (transmit_phase == LOAD_SREG);

    assign transmit_pixel =
        enable && (transmit_phase == TRANSMIT_PIXEL);

endmodule
