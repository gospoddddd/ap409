// src/apb_top_tb.sv
// Верхний уровень / тестбенч для проверки работы APB master и slave.

`timescale 1ns/1ps

module apb_top_tb;

    // APB сигналы
    logic        pclk;
    logic        presetn;

    logic [31:0] paddr;
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        pready;

    // Генерация тактового сигнала
    initial begin
        pclk = 0;
        forever #5 pclk = ~pclk; // период 10 нс
    end

    // Генерация reset
    initial begin
        presetn = 1'b0;
        #20;
        presetn = 1'b1;
    end

    // Подключаем master и slave
    apb_master u_master (
        .pclk   (pclk),
        .presetn(presetn),
        .paddr  (paddr),
        .psel   (psel),
        .penable(penable),
        .pwrite (pwrite),
        .pwdata (pwdata),
        .prdata (prdata),
        .pready (pready)
    );

    apb_slave u_slave (
        .pclk   (pclk),
        .presetn(presetn),
        .paddr  (paddr),
        .psel   (psel),
        .penable(penable),
        .pwrite (pwrite),
        .pwdata (pwdata),
        .prdata (prdata),
        .pready (pready)
    );

    // Ограничим время симуляции
    initial begin
        #500;
        $display("[%0t] TB: finish simulation", $time);
        $finish;
    end

endmodule
