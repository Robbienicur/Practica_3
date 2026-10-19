`timescale 1ns/1ps
// Testbench de la FSM + contador con "ticks" abreviados (Procedimiento, paso 6)
module tb_signed_counter_fsm;
    reg clk = 0, reset = 0, tick = 0, pause_pulse = 0, inc_pulse = 0, dec_pulse = 0;
    wire signed [8:0] count;
    wire [1:0] state;
    integer errors = 0;

    signed_counter_fsm dut (.clk(clk), .reset(reset), .tick(tick),
        .pause_pulse(pause_pulse), .inc_pulse(inc_pulse), .dec_pulse(dec_pulse),
        .count(count), .state(state));

    always #10 clk = ~clk;

    task pulse_tick;  begin @(negedge clk); tick = 1; @(negedge clk); tick = 0; end endtask
    task press_inc;   begin @(negedge clk); inc_pulse = 1;   @(negedge clk); inc_pulse = 0;   end endtask
    task press_dec;   begin @(negedge clk); dec_pulse = 1;   @(negedge clk); dec_pulse = 0;   end endtask
    task press_pause; begin @(negedge clk); pause_pulse = 1; @(negedge clk); pause_pulse = 0; end endtask
    task press_reset; begin @(negedge clk); reset = 1;       @(negedge clk); reset = 0;       end endtask

    task check(input signed [8:0] exp_val, input [1:0] exp_state, input [255:0] name);
        begin
            if (count !== exp_val || state !== exp_state) begin
                errors = errors + 1;
                $display("FAIL %0s: count=%0d (esperado %0d) state=%0d (esperado %0d)",
                         name, count, exp_val, state, exp_state);
            end else
                $display("ok   %0s: count=%0d state=%0d", name, count, state);
        end
    endtask

    // Forzar el valor para probar limites sin esperar 255 ticks
    task load(input signed [8:0] v); begin force dut.count = v; @(negedge clk); release dut.count; end endtask

    initial begin
        $dumpfile("tb.vcd"); $dumpvars(0, tb_signed_counter_fsm);
        press_reset;                 check(0, 0, "RESET");
        press_inc; pulse_tick;       check(1, 1, "INC y tick");
        load(58);  pulse_tick;       check(59, 1, "58 + tick");
        load(255); pulse_tick;       check(-256, 1, "255 + tick -> -256");
        press_reset; press_dec; pulse_tick; check(-1, 2, "DEC y tick");
        load(-58); pulse_tick;       check(-59, 2, "-58 - tick");
        load(-256); pulse_tick;      check(255, 2, "-256 - tick -> 255");
        load(45); press_pause; pulse_tick; pulse_tick; pulse_tick; check(45, 0, "PAUSA + ticks");
        load(-123); press_reset;     check(0, 0, "RESET desde -123");
        // Prioridad: pausa > inc > dec en el mismo ciclo
        press_inc;
        @(negedge clk); pause_pulse = 1; inc_pulse = 1; dec_pulse = 1; @(negedge clk);
        pause_pulse = 0; inc_pulse = 0; dec_pulse = 0; @(negedge clk);
        check(count, 0, "prioridad PAUSA");
        @(negedge clk); inc_pulse = 1; dec_pulse = 1; @(negedge clk);
        inc_pulse = 0; dec_pulse = 0; @(negedge clk);
        check(count, 1, "prioridad INC sobre DEC");
        if (errors == 0) $display("TODAS LAS PRUEBAS PASARON"); else $display("%0d ERRORES", errors);
        $finish;
    end
endmodule
