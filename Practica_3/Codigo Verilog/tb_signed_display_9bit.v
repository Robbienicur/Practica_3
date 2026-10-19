`timescale 1ns/1ps
module tb_signed_display_9bit;
    reg signed [8:0] v;
    wire [6:0] h0, h1, h2, h3;
    integer errors = 0, i;
    signed_display_9bit dut (.value(v), .HEX0(h0), .HEX1(h1), .HEX2(h2), .HEX3(h3));

    function [6:0] seg(input integer d);
        case (d)
            0: seg=7'b1000000; 1: seg=7'b1111001; 2: seg=7'b0100100; 3: seg=7'b0110000;
            4: seg=7'b0011001; 5: seg=7'b0010010; 6: seg=7'b0000010; 7: seg=7'b1111000;
            8: seg=7'b0000000; default: seg=7'b0010000;
        endcase
    endfunction

    integer m;
    initial begin
        // Barrido completo -256..255
        for (i = -256; i <= 255; i = i + 1) begin
            v = i; #1;
            m = (i < 0) ? -i : i;
            if (h0 !== seg(m % 10) || h1 !== seg((m/10) % 10) || h2 !== seg(m/100) ||
                h3 !== ((i < 0) ? 7'b0111111 : 7'b1111111)) begin
                errors = errors + 1; $display("FAIL v=%0d", i);
            end
        end
        if (errors == 0) $display("DISPLAY: 512 valores correctos"); else $display("DISPLAY: %0d errores", errors);
        $finish;
    end
endmodule
