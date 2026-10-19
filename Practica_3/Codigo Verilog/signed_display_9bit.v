// Convierte un valor con signo de 9 bits (-256..255) a 4 displays de 7 segmentos.
// HEX3: signo ('-' o apagado), HEX2..HEX0: centenas, decenas, unidades. Activos en bajo.
module signed_display_9bit (
    input  wire signed [8:0] value,
    output wire [6:0]        HEX0,
    output wire [6:0]        HEX1,
    output wire [6:0]        HEX2,
    output wire [6:0]        HEX3
);

    wire        negative = value[8];
    // Magnitud en 9 bits sin signo: para -256 resulta 256 (9'b1_0000_0000)
    wire [8:0]  magnitude = negative ? (~value + 9'd1) : value;

    wire [3:0] units    = magnitude % 10;
    wire [3:0] tens     = (magnitude / 10) % 10;
    wire [3:0] hundreds = magnitude / 100;

    function [6:0] seg7;   // {g,f,e,d,c,b,a}, activo en bajo
        input [3:0] d;
        case (d)
            4'd0: seg7 = 7'b1000000;
            4'd1: seg7 = 7'b1111001;
            4'd2: seg7 = 7'b0100100;
            4'd3: seg7 = 7'b0110000;
            4'd4: seg7 = 7'b0011001;
            4'd5: seg7 = 7'b0010010;
            4'd6: seg7 = 7'b0000010;
            4'd7: seg7 = 7'b1111000;
            4'd8: seg7 = 7'b0000000;
            4'd9: seg7 = 7'b0010000;
            default: seg7 = 7'b1111111;
        endcase
    endfunction

    assign HEX0 = seg7(units);
    assign HEX1 = seg7(tens);
    assign HEX2 = seg7(hundreds);
    assign HEX3 = negative ? 7'b0111111 : 7'b1111111;  // solo segmento g, o apagado

endmodule
