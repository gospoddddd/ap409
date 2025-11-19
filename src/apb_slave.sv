// src/apb_slave.sv
// Простой APB slave.
// Хранит четыре 32-битных регистра по адресам 0x0, 0x4, 0x8, 0xC
// и печатает через $display информацию о транзакциях.

`timescale 1ns/1ps

module apb_slave (
    input  logic        pclk,
    input  logic        presetn,

    input  logic [31:0] paddr,
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [31:0] pwdata,

    output logic [31:0] prdata,
    output logic        pready
);

    // Четыре регистра
    logic [31:0] reg0;  // addr 0x0
    logic [31:0] reg1;  // addr 0x4
    logic [31:0] reg2;  // addr 0x8
    logic [31:0] reg3;  // addr 0xC

    // Простейший always-блок: реакции на такт и reset
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            reg0  <= '0;
            reg1  <= '0;
            reg2  <= '0;
            reg3  <= '0;
            prdata <= '0;
            pready <= 1'b0;
        end else begin
            pready <= 1'b0; // по умолчанию, активируем только при транзакции

            if (psel && penable) begin
                // Считаем, что транзакция всегда завершается за 1 такт
                pready <= 1'b1;

                if (pwrite) begin
                    // WRITE
                    unique case (paddr[5:0]) // берём младшие биты, т.к. адресы кратны 4
                        6'h00: begin
                            reg0 <= pwdata;
                            $display("[%0t] SLAVE: WRITE @0x0  data=0x%08h (%0d)", $time, pwdata, pwdata);
                        end
                        6'h04: begin
                            reg1 <= pwdata;
                            $display("[%0t] SLAVE: WRITE @0x4  data=0x%08h (%0d)", $time, pwdata, pwdata);
                        end
                        6'h08: begin
                            reg2 <= pwdata;
                            $display("[%0t] SLAVE: WRITE @0x8  data=0x%08h", $time, pwdata);
                        end
                        6'h0C: begin
                            reg3 <= pwdata;
                            $display("[%0t] SLAVE: WRITE @0xC  data=0x%08h", $time, pwdata);
                        end
                        default: begin
                            $display("[%0t] SLAVE: WRITE @0x%08h (ignored)", $time, paddr);
                        end
                    endcase

                end else begin
                    // READ
                    unique case (paddr[5:0])
                        6'h00: begin
                            prdata <= reg0;
                            $display("[%0t] SLAVE: READ  @0x0  -> 0x%08h (%0d)", $time, reg0, reg0);
                        end
                        6'h04: begin
                            prdata <= reg1;
                            $display("[%0t] SLAVE: READ  @0x4  -> 0x%08h (%0d)", $time, reg1, reg1);
                        end
                        6'h08: begin
                            prdata <= reg2;
                            $display("[%0t] SLAVE: READ  @0x8  -> 0x%08h", $time, reg2);
                        end
                        6'h0C: begin
                            prdata <= reg3;
                            $display("[%0t] SLAVE: READ  @0xC  -> 0x%08h", $time, reg3);
                        end
                        default: begin
                            prdata <= '0;
                            $display("[%0t] SLAVE: READ  @0x%08h (ignored)", $time, paddr);
                        end
                    endcase
                end
            end
        end
    end

endmodule
