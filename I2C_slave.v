`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: I2C Slave
// Module Name: I2C_slave
// Description: Basic behavioral I2C slave for simulation.
//
//////////////////////////////////////////////////////////////////////////////////

module I2C_slave (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        scl,
    inout  wire        sda,
    input  wire [6:0]  addr,
    output reg  [7:0]  data_rd,
    output reg         ack
);

    // States
    parameter IDLE  = 3'b000;
    parameter ADDR  = 3'b001;
    parameter READ  = 3'b010;
    parameter WRITE = 3'b011;
    parameter ACK_S = 3'b100;

    reg [2:0] state;
    reg [7:0] shift_reg;
    reg [2:0] bit_cnt;
    reg       sda_out;
    reg       sda_oe;

    // Simulated internal memory
    reg [7:0] memory [0:255];

    // Tri-state SDA
    assign sda = sda_oe ? sda_out : 1'bz;

    // State machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            data_rd   <= 8'b0;
            ack       <= 1'b0;
            sda_out   <= 1'b1;
            sda_oe    <= 1'b0;
            bit_cnt   <= 3'd0;
            shift_reg <= 8'b0;
        end else begin
            case (state)

                IDLE: begin
                    sda_out <= 1'b1;
                    sda_oe  <= 1'b0;
                    if (scl && (sda == 1'b0)) begin
                        state   <= ADDR;
                        bit_cnt <= 3'd7;
                    end
                end

                ADDR: begin
                    if (scl) begin
                        shift_reg[bit_cnt] <= sda;
                        if (bit_cnt == 3'd0) begin
                            if (shift_reg[7:1] == addr) begin
                                state <= ACK_S;
                                ack   <= 1'b1;
                            end else begin
                                state <= IDLE;
                            end
                        end else begin
                            bit_cnt <= bit_cnt - 3'd1;
                        end
                    end
                end

                READ: begin
                    if (scl) begin
                        data_rd[bit_cnt] <= sda;
                        if (bit_cnt == 3'd0) begin
                            ack   <= 1'b1;
                            state <= ACK_S;
                        end else begin
                            bit_cnt <= bit_cnt - 3'd1;
                        end
                    end
                end

                WRITE: begin
                    if (scl) begin
                        sda_out <= shift_reg[bit_cnt];
                        sda_oe  <= 1'b1;
                        if (bit_cnt == 3'd0)
                            state <= ACK_S;
                        else
                            bit_cnt <= bit_cnt - 3'd1;
                    end
                end

                ACK_S: begin
                    if (scl) begin
                        sda_out <= 1'b0;
                        sda_oe  <= 1'b1;
                        if (shift_reg[0] == 1'b0)
                            state <= READ;   // Master reading from slave
                        else
                            state <= WRITE;  // Master writing to slave
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
