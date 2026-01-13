`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: I2C Top Integration
// Module Name: I2C_top
// Description: Integrates I2C master and slave modules.
//
//////////////////////////////////////////////////////////////////////////////////

module I2C_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [6:0]  addr,
    input  wire        rw,
    input  wire [7:0]  data_wr,
    output wire [7:0]  data_rd_master,
    output wire [7:0]  data_rd_slave,
    output wire        ack_master,
    output wire        ack_slave
);

    wire scl;
    wire sda;

    I2C_master master_inst (
        .clk(clk),
        .rst_n(rst_n),
        .scl(scl),
        .sda(sda),
        .start(start),
        .addr(addr),
        .rw(rw),
        .data_wr(data_wr),
        .data_rd(data_rd_master),
        .busy(),
        .ack(ack_master)
    );

    I2C_slave slave_inst (
        .clk(clk),
        .rst_n(rst_n),
        .scl(scl),
        .sda(sda),
        .addr(addr),
        .data_rd(data_rd_slave),
        .ack(ack_slave)
    );

endmodule
