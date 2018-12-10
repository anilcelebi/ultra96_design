// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2018.2.2
// Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

module olast (
        ap_clk,
        ap_rst,
        ap_start,
        start_full_n,
        ap_done,
        ap_continue,
        ap_idle,
        ap_ready,
        start_out,
        start_write,
        p_ilast_V_bv_V_dout,
        p_ilast_V_bv_V_empty_n,
        p_ilast_V_bv_V_read,
        p_olast_V_bv_V_din,
        p_olast_V_bv_V_full_n,
        p_olast_V_bv_V_write
);

parameter    ap_ST_fsm_state1 = 3'd1;
parameter    ap_ST_fsm_pp0_stage0 = 3'd2;
parameter    ap_ST_fsm_state4 = 3'd4;

input   ap_clk;
input   ap_rst;
input   ap_start;
input   start_full_n;
output   ap_done;
input   ap_continue;
output   ap_idle;
output   ap_ready;
output   start_out;
output   start_write;
input  [0:0] p_ilast_V_bv_V_dout;
input   p_ilast_V_bv_V_empty_n;
output   p_ilast_V_bv_V_read;
output  [0:0] p_olast_V_bv_V_din;
input   p_olast_V_bv_V_full_n;
output   p_olast_V_bv_V_write;

reg ap_done;
reg ap_idle;
reg start_write;
reg p_ilast_V_bv_V_read;
reg p_olast_V_bv_V_write;

reg    real_start;
reg    start_once_reg;
reg    ap_done_reg;
(* fsm_encoding = "none" *) reg   [2:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    internal_ap_ready;
reg    p_ilast_V_bv_V_blk_n;
wire    ap_CS_fsm_pp0_stage0;
reg    ap_enable_reg_pp0_iter1;
wire    ap_block_pp0_stage0;
reg   [0:0] p_436_reg_178;
reg    p_olast_V_bv_V_blk_n;
reg   [0:0] p_453_reg_182;
reg   [18:0] p_s0_v_reg_85;
reg   [18:0] p_425_reg_96;
wire   [0:0] exitcond_fu_107_p2;
wire    ap_block_state2_pp0_stage0_iter0;
reg    ap_block_state3_pp0_stage0_iter1;
reg    ap_block_pp0_stage0_11001;
wire   [18:0] p_s0_v84_fu_113_p2;
reg    ap_enable_reg_pp0_iter0;
wire   [0:0] p_436_fu_131_p2;
wire   [0:0] p_453_fu_137_p2;
wire   [0:0] p_465_fu_143_p2;
reg   [0:0] p_465_reg_186;
wire   [18:0] idx_urem_fu_161_p3;
reg    ap_block_state1;
reg    ap_block_pp0_stage0_subdone;
reg    ap_condition_pp0_exit_iter0_state2;
reg    ap_block_pp0_stage0_01001;
wire   [1:0] p_435_fu_119_p1;
wire   [9:0] tmp_10_fu_127_p1;
wire   [10:0] tmp_9_fu_123_p1;
wire   [18:0] next_urem_fu_149_p2;
wire   [0:0] tmp_11_fu_155_p2;
wire    ap_CS_fsm_state4;
reg   [2:0] ap_NS_fsm;
reg    ap_idle_pp0;
wire    ap_enable_pp0;

// power-on initialization
initial begin
#0 start_once_reg = 1'b0;
#0 ap_done_reg = 1'b0;
#0 ap_CS_fsm = 3'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter0 = 1'b0;
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if ((1'b1 == ap_CS_fsm_state4)) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter0 <= 1'b0;
    end else begin
        if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b1 == ap_condition_pp0_exit_iter0_state2) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
            ap_enable_reg_pp0_iter0 <= 1'b0;
        end else if ((~((real_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
            ap_enable_reg_pp0_iter0 <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if (((1'b1 == ap_condition_pp0_exit_iter0_state2) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
            ap_enable_reg_pp0_iter1 <= (1'b1 ^ ap_condition_pp0_exit_iter0_state2);
        end else if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
        end else if ((~((real_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
            ap_enable_reg_pp0_iter1 <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        start_once_reg <= 1'b0;
    end else begin
        if (((internal_ap_ready == 1'b0) & (real_start == 1'b1))) begin
            start_once_reg <= 1'b1;
        end else if ((internal_ap_ready == 1'b1)) begin
            start_once_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (exitcond_fu_107_p2 == 1'd0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        p_425_reg_96 <= idx_urem_fu_161_p3;
    end else if ((~((real_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        p_425_reg_96 <= 19'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (exitcond_fu_107_p2 == 1'd0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        p_s0_v_reg_85 <= p_s0_v84_fu_113_p2;
    end else if ((~((real_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        p_s0_v_reg_85 <= 19'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (exitcond_fu_107_p2 == 1'd0) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        p_436_reg_178 <= p_436_fu_131_p2;
        p_453_reg_182 <= p_453_fu_137_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (exitcond_fu_107_p2 == 1'd0) & (p_453_fu_137_p2 == 1'd1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        p_465_reg_186 <= p_465_fu_143_p2;
    end
end

always @ (*) begin
    if ((exitcond_fu_107_p2 == 1'd1)) begin
        ap_condition_pp0_exit_iter0_state2 = 1'b1;
    end else begin
        ap_condition_pp0_exit_iter0_state2 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state4)) begin
        ap_done = 1'b1;
    end else begin
        ap_done = ap_done_reg;
    end
end

always @ (*) begin
    if (((real_start == 1'b0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter0 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state4)) begin
        internal_ap_ready = 1'b1;
    end else begin
        internal_ap_ready = 1'b0;
    end
end

always @ (*) begin
    if (((p_436_reg_178 == 1'd1) & (1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        p_ilast_V_bv_V_blk_n = p_ilast_V_bv_V_empty_n;
    end else begin
        p_ilast_V_bv_V_blk_n = 1'b1;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (p_436_reg_178 == 1'd1) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        p_ilast_V_bv_V_read = 1'b1;
    end else begin
        p_ilast_V_bv_V_read = 1'b0;
    end
end

always @ (*) begin
    if (((p_453_reg_182 == 1'd1) & (1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        p_olast_V_bv_V_blk_n = p_olast_V_bv_V_full_n;
    end else begin
        p_olast_V_bv_V_blk_n = 1'b1;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (p_453_reg_182 == 1'd1) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        p_olast_V_bv_V_write = 1'b1;
    end else begin
        p_olast_V_bv_V_write = 1'b0;
    end
end

always @ (*) begin
    if (((start_once_reg == 1'b0) & (start_full_n == 1'b0))) begin
        real_start = 1'b0;
    end else begin
        real_start = ap_start;
    end
end

always @ (*) begin
    if (((start_once_reg == 1'b0) & (real_start == 1'b1))) begin
        start_write = 1'b1;
    end else begin
        start_write = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if ((~((real_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_pp0_stage0 : begin
            if (~((exitcond_fu_107_p2 == 1'd1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else if (((exitcond_fu_107_p2 == 1'd1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_state4;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_state4 : begin
            ap_NS_fsm = ap_ST_fsm_state1;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state4 = ap_CS_fsm[32'd2];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_pp0_stage0_01001 = ((ap_enable_reg_pp0_iter1 == 1'b1) & (((p_453_reg_182 == 1'd1) & (p_olast_V_bv_V_full_n == 1'b0)) | ((p_436_reg_178 == 1'd1) & (p_ilast_V_bv_V_empty_n == 1'b0))));
end

always @ (*) begin
    ap_block_pp0_stage0_11001 = ((ap_enable_reg_pp0_iter1 == 1'b1) & (((p_453_reg_182 == 1'd1) & (p_olast_V_bv_V_full_n == 1'b0)) | ((p_436_reg_178 == 1'd1) & (p_ilast_V_bv_V_empty_n == 1'b0))));
end

always @ (*) begin
    ap_block_pp0_stage0_subdone = ((ap_enable_reg_pp0_iter1 == 1'b1) & (((p_453_reg_182 == 1'd1) & (p_olast_V_bv_V_full_n == 1'b0)) | ((p_436_reg_178 == 1'd1) & (p_ilast_V_bv_V_empty_n == 1'b0))));
end

always @ (*) begin
    ap_block_state1 = ((real_start == 1'b0) | (ap_done_reg == 1'b1));
end

assign ap_block_state2_pp0_stage0_iter0 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_state3_pp0_stage0_iter1 = (((p_453_reg_182 == 1'd1) & (p_olast_V_bv_V_full_n == 1'b0)) | ((p_436_reg_178 == 1'd1) & (p_ilast_V_bv_V_empty_n == 1'b0)));
end

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign ap_ready = internal_ap_ready;

assign exitcond_fu_107_p2 = ((p_s0_v_reg_85 == 19'd307200) ? 1'b1 : 1'b0);

assign idx_urem_fu_161_p3 = ((tmp_11_fu_155_p2[0:0] === 1'b1) ? next_urem_fu_149_p2 : 19'd0);

assign next_urem_fu_149_p2 = (p_425_reg_96 + 19'd1);

assign p_435_fu_119_p1 = p_425_reg_96[1:0];

assign p_436_fu_131_p2 = ((p_435_fu_119_p1 == 2'd0) ? 1'b1 : 1'b0);

assign p_453_fu_137_p2 = ((tmp_10_fu_127_p1 < 10'd320) ? 1'b1 : 1'b0);

assign p_465_fu_143_p2 = ((tmp_9_fu_123_p1 == 11'd319) ? 1'b1 : 1'b0);

assign p_olast_V_bv_V_din = p_465_reg_186;

assign p_s0_v84_fu_113_p2 = (p_s0_v_reg_85 + 19'd1);

assign start_out = real_start;

assign tmp_10_fu_127_p1 = p_425_reg_96[9:0];

assign tmp_11_fu_155_p2 = ((next_urem_fu_149_p2 < 19'd640) ? 1'b1 : 1'b0);

assign tmp_9_fu_123_p1 = p_425_reg_96[10:0];

endmodule //olast
