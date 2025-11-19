// src/apb_master.sv
// Несинтезируемый APB master.
// Здесь реализованы задачи apb_write и apb_read, которые формируют транзакции по шине.

`timescale 1ns/1ps

module apb_master (
    input  logic        pclk,
    input  logic        presetn,

    output logic [31:0] paddr,
    output logic        psel,
    output logic        penable,
    output logic        pwrite,
    output logic [31:0] pwdata,

    input  logic [31:0] prdata,
    input  logic        pready
);

    // Инициализация сигналов
    initial begin
        paddr   = '0;
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        pwdata  = '0;
    end

    // APB write: двухтактная транзакция (setup + access)
    task automatic apb_write (input logic [31:0] inp_addr,
                              input logic [31:0] inp_data);
        begin
            // Setup phase
            @(posedge pclk);
            paddr   <= inp_addr;
            pwdata  <= inp_data;
            pwrite  <= 1'b1;
            psel    <= 1'b1;
            penable <= 1'b0;

            // Access phase
            @(posedge pclk);
            penable <= 1'b1;

            // Ожидание pready от слейва
            while (!pready) begin
                @(posedge pclk);
            end

            // Завершение транзакции
            @(posedge pclk);
            psel    <= 1'b0;
            penable <= 1'b0;
            pwrite  <= 1'b0;
            pwdata  <= '0;
        end
    endtask

    // APB read: для простоты реализуем как task с выходным параметром
    task automatic apb_read (input  logic [31:0] inp_addr,
                             output logic [31:0] out_data);
        begin
            // Setup phase
            @(posedge pclk);
            paddr   <= inp_addr;
            pwrite  <= 1'b0;
            psel    <= 1'b1;
            penable <= 1'b0;

            // Access phase
            @(posedge pclk);
            penable <= 1'b1;

            // Ожидание pready и захват prdata
            while (!pready) begin
                @(posedge pclk);
            end
            out_data = prdata;

            // Завершение транзакции
            @(posedge pclk);
            psel    <= 1'b0;
            penable <= 1'b0;
        end
    endtask

    // Пример сценария, соответствующий пунктам 8–9 задания.
    initial begin : master_scenario
        logic [31:0] read_back;

        // Ждём снятия reset
        @(negedge presetn);
        @(posedge presetn);
        repeat (2) @(posedge pclk);

        // 0x0 — запись номера в списке группы (10-й)
        $display("[%0t] MASTER: write group index (10) to 0x0", $time);
        apb_write(32'h0000_0000, 32'd10);

        // 0x4 — запись даты 18.11.2025 -> 18112025 
        $display("[%0t] MASTER: write date 18.11.2025 (18112025) to 0x4", $time);
        apb_write(32'h0000_0004, 32'd18112025);

        // 0x8 — первые 4 буквы фамилии "PRIY" в ASCII
        // P=0x50, R=0x52, I=0x49, Y=0x59
        $display("[%0t] MASTER: write surname 'PRIY' to 0x8", $time);
        apb_write(32'h0000_0008, 32'h50_52_49_59);

        // 0xC — первые 4 буквы имени "KONS" в ASCII
        // K=0x4B, O=0x4F, N=0x4E, S=0x53
        $display("[%0t] MASTER: write name 'KONS' to 0xC", $time);
        apb_write(32'h0000_000C, 32'h4B_4F_4E_53);

        
        $display("[%0t] MASTER: read back from 0x0", $time);
        apb_read(32'h0000_0000, read_back);
        $display("[%0t] MASTER: read_back[0x0] = 0x%08h (%0d)", $time, read_back, read_back);

        $display("[%0t] MASTER: read back from 0x4", $time);
        apb_read(32'h0000_0004, read_back);
        $display("[%0t] MASTER: read_back[0x4] = 0x%08h (%0d)", $time, read_back, read_back);

        $display("[%0t] MASTER: read back from 0x8", $time);
        apb_read(32'h0000_0008, read_back);
        $display("[%0t] MASTER: read_back[0x8] = 0x%08h", $time, read_back);

        $display("[%0t] MASTER: read back from 0xC", $time);
        apb_read(32'h0000_000C, read_back);
        $display("[%0t] MASTER: read_back[0xC] = 0x%08h", $time, read_back);

        $display("[%0t] MASTER: scenario finished", $time);

    end

endmodule
