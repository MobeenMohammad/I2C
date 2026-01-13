`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2025
// Design Name: I2C Master
// Module Name: I2C_master
// Description: Simple I2C master module for basic read/write transaction
//
//////////////////////////////////////////////////////////////////////////////////

module I2C_master (
    input  wire        clk,
    input  wire        rst_n,
    output reg         scl,
    inout  wire        sda,
    input  wire        start,
    input  wire [6:0]  addr,
    input  wire        rw,
    input  wire [7:0]  data_wr,
    output reg  [7:0]  data_rd,
    output reg         busy,
    output reg         ack
);

    // State definitions
    parameter IDLE       = 3'b000;
    parameter START      = 3'b001;
    parameter ADDR       = 3'b010;
    parameter WRITE      = 3'b011;
    parameter READ       = 3'b100;
    parameter ACK_CHECK  = 3'b101;
    parameter STOP       = 3'b110;

    reg [2:0] state;

    // Internal signals
    reg [7:0] shift_reg;
    reg [2:0] bit_cnt;
    reg       sda_out;
    reg       sda_oe;

    // Tri-state SDA
    assign sda = sda_oe ? sda_out : 1'bz;

    // Clock divider for SCL generation
    reg [7:0] clk_div;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 8'd0;
            scl     <= 1'b1;
        end else begin
            if (clk_div == 8'd199) begin
                clk_div <= 8'd0;
                scl     <= ~scl;
            end else begin
                clk_div <= clk_div + 8'd1;
            end
        end
    end

    // State machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            busy      <= 1'b0;
            ack       <= 1'b0;
            sda_out   <= 1'b1;
            sda_oe    <= 1'b0;
            bit_cnt   <= 3'd0;
            shift_reg <= 8'd0;
            data_rd   <= 8'd0;
        end else begin
            case (state)

                IDLE: begin
                    busy    <= 1'b0;
                    sda_out <= 1'b1;
                    sda_oe  <= 1'b0;
                    if (start) begin
                        state <= START;
                        busy  <= 1'b1;
                    end
                end

                START: begin
                    sda_out <= 1'b0;
                    sda_oe  <= 1'b1;
                    if (scl == 1'b1) begin
                        state     <= ADDR;
                        shift_reg <= {addr, rw};
                        bit_cnt   <= 3'd7;
                    end
                end

                ADDR: begin
                    sda_out <= shift_reg[bit_cnt];
                    sda_oe  <= 1'b1;
                    if (scl == 1'b0) begin
                        if (bit_cnt == 3'd0)
                            state <= ACK_CHECK;
                        else
                            bit_cnt <= bit_cnt - 3'd1;
                    end
                end

                ACK_CHECK: begin
                    sda_oe <= 1'b0;
                    if (scl == 1'b1) begin
                        ack <= ~sda;
                        if (rw) begin
                            state   <= READ;
                            bit_cnt <= 3'd7;
                        end else begin
                            state     <= WRITE;
                            shift_reg <= data_wr;
                            bit_cnt   <= 3'd7;
                        end
                    end
                end

                WRITE: begin
                    sda_out <= shift_reg[bit_cnt];
                    sda_oe  <= 1'b1;
                    if (scl == 1'b0) begin
                        if (bit_cnt == 3'd0)
                            state <= ACK_CHECK;
                        else
                            bit_cnt <= bit_cnt - 3'd1;
                    end
                end

                READ: begin
                    sda_oe <= 1'b0;
                    if (scl == 1'b1) begin
                        data_rd[bit_cnt] <= sda;
                        if (bit_cnt == 3'd0)
                            state <= STOP;
                        else
                            bit_cnt <= bit_cnt - 3'd1;
                    end
                end

                STOP: begin
                    sda_out <= 1'b0;
                    sda_oe  <= 1'b1;
                    if (scl == 1'b1) begin
                        sda_out <= 1'b1;
                        state   <= IDLE;
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
