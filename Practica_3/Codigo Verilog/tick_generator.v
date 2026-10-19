// Generador de pulso de habilitacion (tick) de 1 ciclo de clk (50 MHz)
// 4 bits de seleccion (16 combinaciones): rango de 0.125 s (125 ms) a 2.000 s en pasos de 0.125 s
module tick_generator (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    input  wire [3:0] speed_sel,  // 4'd0: 0.125 s ... 4'd7: 1.000 s ... 4'd15: 2.000 s
    output reg        tick
);

    reg [26:0] counter;
    reg [26:0] terminal_count;

    // 50 MHz -> 0.125 s = 6,250,000 ciclos. Tabla LUT de 16 velocidades (sin multiplicadores)
    always @(*) begin
        case (speed_sel)
            4'd0:    terminal_count = 27'd6_249_999;   // 0.125 s (125 ms)
            4'd1:    terminal_count = 27'd12_499_999;  // 0.250 s (250 ms)
            4'd2:    terminal_count = 27'd18_749_999;  // 0.375 s (375 ms)
            4'd3:    terminal_count = 27'd24_999_999;  // 0.500 s (500 ms)
            4'd4:    terminal_count = 27'd31_249_999;  // 0.625 s (625 ms)
            4'd5:    terminal_count = 27'd37_499_999;  // 0.750 s (750 ms)
            4'd6:    terminal_count = 27'd43_749_999;  // 0.875 s (875 ms)
            4'd7:    terminal_count = 27'd49_999_999;  // 1.000 s (1000 ms)
            4'd8:    terminal_count = 27'd56_249_999;  // 1.125 s (1125 ms)
            4'd9:    terminal_count = 27'd62_499_999;  // 1.250 s (1250 ms)
            4'd10:   terminal_count = 27'd68_749_999;  // 1.375 s (1375 ms)
            4'd11:   terminal_count = 27'd74_999_999;  // 1.500 s (1500 ms)
            4'd12:   terminal_count = 27'd81_249_999;  // 1.625 s (1625 ms)
            4'd13:   terminal_count = 27'd87_499_999;  // 1.750 s (1750 ms)
            4'd14:   terminal_count = 27'd93_749_999;  // 1.875 s (1875 ms)
            4'd15:   terminal_count = 27'd99_999_999;  // 2.000 s (2000 ms)
            default: terminal_count = 27'd49_999_999;  // 1.000 s
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 27'd0;
            tick    <= 1'b0;
        end else if (!enable) begin
            counter <= 27'd0;
            tick    <= 1'b0;
        end else if (counter >= terminal_count) begin
            counter <= 27'd0;
            tick    <= 1'b1;
        end else begin
            counter <= counter + 27'd1;
            tick    <= 1'b0;
        end
    end

endmodule
