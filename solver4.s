# Compiler-generated RV32I from solver4.c; not hand-written assembly.
# Build/link with build_solver4.sh and solver4.ld; load ELF in Ripes.
	.file	"solver4.c"
	.option nopic
	.option norelax
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
 #APP
	.section .text.start,"ax",@progbits
.globl _start
_start:
la sp, __stack_top
la t0, __bss_start
la t1, __bss_end
1:
bgeu t0, t1, 2f
sb zero, 0(t0)
addi t0, t0, 1
j 1b
2:
call solver4_main
li a7, 10
ecall
3: j 3b
.text

 #NO_APP
	.align	2
	.type	permutation_index, @function
permutation_index:
	addi	a7,a0,1
	li	a1,0
	addi	a0,a0,7
	li	a6,1
	li	t3,3
	li	t1,5
	li	t5,2
	li	t4,4
.L12:
	lbu	a2,-1(a7)
	mv	a5,a7
	li	a3,0
.L3:
	lbu	a4,0(a5)
	addi	a5,a5,1
	sltu	a4,a4,a2
	add	a3,a3,a4
	bne	a0,a5,.L3
	beq	a6,t3,.L4
	addi	a5,a6,-3
	bgtu	a5,t1,.L5
	beq	a6,t1,.L6
	beq	a6,t4,.L17
	slli	a1,a1,1
	add	a0,a1,a3
	ret
.L5:
	slli	a5,a1,1
	add	a5,a5,a1
	beq	a6,t5,.L9
	slli	a5,a5,1
	add	a1,a5,a1
.L10:
	add	a1,a1,a3
	addi	a6,a6,1
	addi	a7,a7,1
	j	.L12
.L9:
	slli	a1,a5,1
	j	.L10
.L4:
	slli	a5,a1,2
	add	a1,a5,a1
	addi	a7,a7,1
	add	a1,a3,a1
	li	a6,4
	j	.L12
.L17:
	slli	a1,a1,2
	add	a1,a3,a1
	addi	a7,a7,1
	li	a6,5
	j	.L12
.L6:
	slli	a5,a1,1
	add	a1,a5,a1
	addi	a7,a7,1
	add	a1,a3,a1
	li	a6,6
	j	.L12
	.size	permutation_index, .-permutation_index
	.align	2
	.type	heuristic, @function
heuristic:
	addi	sp,sp,-16
	sw	s1,4(sp)
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s1,a0
	mv	a4,a0
	li	a5,0
	li	a3,0
	li	a1,7
.L21:
	lbu	a2,0(a4)
	beq	a2,a5,.L31
.L19:
	addi	a3,a3,1
.L20:
	addi	a5,a5,1
	addi	a4,a4,1
	bne	a5,a1,.L21
	mv	a0,s1
	addi	s0,a3,3
	call	permutation_index
	lui	a5,%hi(perm_dist)
	addi	a5,a5,%lo(perm_dist)
	add	a5,a5,a0
	lbu	a1,0(a5)
	addi	a4,s1,7
	addi	a0,s1,13
	li	a5,0
.L22:
	lbu	a3,0(a4)
	slli	a2,a5,1
	add	a5,a2,a5
	addi	a4,a4,1
	add	a5,a3,a5
	bne	a0,a4,.L22
	lui	a4,%hi(.LANCHOR0)
	addi	a4,a4,%lo(.LANCHOR0)
	add	a5,a4,a5
	srai	a3,s0,2
	lbu	a0,0(a5)
	bge	a3,a1,.L23
	mv	a3,a1
.L23:
	bge	a0,a3,.L24
	mv	a0,a3
.L24:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
.L31:
	lbu	a2,7(a4)
	beq	a2,zero,.L20
	j	.L19
	.size	heuristic, .-heuristic
	.align	2
	.type	solve.part.0, @function
solve.part.0:
	lui	a5,%hi(.LANCHOR0)
	addi	sp,sp,-336
	addi	a5,a5,%lo(.LANCHOR0)
	sw	a5,12(sp)
	lw	a5,732(a5)
	sw	s0,328(sp)
	sw	ra,332(sp)
	sw	s1,324(sp)
	sw	s2,320(sp)
	sw	s3,316(sp)
	sw	s4,312(sp)
	sw	s5,308(sp)
	sw	s6,304(sp)
	sw	s7,300(sp)
	sw	s8,296(sp)
	sw	s9,292(sp)
	sw	s10,288(sp)
	sw	s11,284(sp)
	sw	a0,24(sp)
	mv	s0,a1
	bne	a5,zero,.L33
	li	a5,4096
	addi	a5,a5,944
	lui	t5,%hi(perm_dist)
	lui	s2,%hi(.LANCHOR1+52)
	lui	s1,%hi(.LANCHOR1+116)
	mv	a1,a5
	addi	s2,s2,%lo(.LANCHOR1+52)
	addi	s1,s1,%lo(.LANCHOR1+116)
	li	s8,2
	addi	s5,t5,%lo(perm_dist)
	li	s9,0
.L65:
	add	a4,s5,a5
	li	a3,-1
	mv	a5,s5
.L34:
	sb	a3,0(a5)
	addi	a5,a5,1
	bne	a4,a5,.L34
	sb	zero,0(s5)
	sw	s0,16(sp)
.L64:
	li	s4,0
	li	a5,0
	mv	a3,a1
	mv	s0,s5
	j	.L63
.L35:
	addi	a5,a5,1
	addi	s0,s0,1
	beq	a3,a5,.L147
.L63:
	lbu	s10,0(s0)
	li	a4,255
	beq	s10,a4,.L35
	li	a4,50462720
	li	a2,393216
	addi	a4,a4,256
	addi	a2,a2,1284
	sw	zero,112(sp)
	sh	zero,116(sp)
	sw	a4,104(sp)
	sw	a2,108(sp)
	beq	s9,zero,.L36
	addi	s11,sp,104
	lui	a4,%hi(.LANCHOR1)
	mv	t1,s11
	addi	t3,a4,%lo(.LANCHOR1)
	addi	t4,sp,110
	mv	a2,a5
	li	a7,0
	li	a0,0
.L37:
	lw	a1,0(t3)
	addi	a4,a0,1
	andi	a4,a4,0xff
	bgt	a1,a2,.L41
.L38:
	mv	a0,a4
	sub	a2,a2,a1
	addi	a4,a4,1
	andi	a4,a4,0xff
	bge	a2,a1,.L38
	sb	a0,7(t1)
.L41:
	addi	t1,t1,1
	add	a7,a7,a0
	beq	t4,t1,.L142
	lbu	a0,7(t1)
	addi	t3,t3,4
	j	.L37
.L142:
	ble	a7,s8,.L148
.L43:
	addi	a7,a7,-3
	bgt	a7,s8,.L43
.L148:
	li	a4,0
	beq	a7,zero,.L44
	li	a4,3
	sub	a4,a4,a7
.L44:
	sb	a4,117(sp)
.L45:
	lw	a4,112(sp)
	lw	a0,104(sp)
	lw	a2,108(sp)
	sw	a4,64(sp)
	lhu	a4,116(sp)
	sw	a5,8(sp)
	addi	a5,s11,6
	sw	a0,56(sp)
	sh	a4,68(sp)
	mv	s6,s5
	sw	a2,60(sp)
	mv	s5,s11
	li	s7,0
	mv	s11,s10
	li	a0,0
	mv	s10,s9
	li	a4,0
	li	s3,9
	sw	a3,4(sp)
	mv	s9,a5
.L54:
	addi	s7,s7,1
	sub	a5,s7,a0
	andi	a5,a5,0xff
	addi	a5,a5,-1
	slli	a1,a5,3
	sub	a1,a1,a5
	add	a1,a1,a4
	add	a3,s2,a1
	addi	t1,a3,7
	add	a1,s1,a1
	mv	a4,s5
	mv	a2,s5
.L57:
	lbu	a0,0(a3)
	lbu	a5,0(a1)
	addi	a3,a3,1
	add	a0,sp,a0
	lbu	a6,56(a0)
	lbu	a0,63(a0)
	addi	a1,a1,1
	sb	a6,0(a2)
	add	a5,a5,a0
	ble	a5,s8,.L56
	addi	a5,a5,-3
.L56:
	sb	a5,7(a2)
	addi	a2,a2,1
	bne	a3,t1,.L57
	bne	s10,zero,.L149
	mv	a0,s5
	call	permutation_index
.L60:
	add	a0,s6,a0
	lbu	a5,0(a0)
	addi	s11,s11,1
	bge	s11,a5,.L61
	sb	s11,0(a0)
	li	s4,1
.L61:
	beq	s7,s3,.L150
	li	a0,0
	li	a4,0
	ble	s7,s8,.L55
	li	a5,5
	bgt	s7,a5,.L96
	li	a0,3
	li	a4,21
.L55:
	lbu	s11,0(s0)
	j	.L54
.L36:
	sw	a4,56(sp)
	li	a4,1284
	sh	a4,60(sp)
	li	a4,6
	sb	a4,62(sp)
	lui	a4,%hi(.LANCHOR1)
	addi	a4,a4,%lo(.LANCHOR1)
	lw	a1,24(a4)
	addi	s11,sp,104
	mv	a2,a5
	addi	t3,a4,24
	mv	t4,s11
	li	t1,0
	li	a7,6
	addi	t5,sp,56
	li	a4,0
	bgt	a1,a2,.L151
.L47:
	sub	a2,a2,a1
	addi	a4,a4,1
	bge	a2,a1,.L47
	add	a1,sp,a4
	lbu	a1,56(a1)
	sb	a1,0(t4)
	bge	a4,a7,.L51
.L50:
	add	a1,t5,a4
.L52:
	lbu	a0,1(a1)
	addi	a4,a4,1
	addi	a1,a1,1
	sb	a0,-1(a1)
	blt	a4,a7,.L52
.L51:
	addi	t1,t1,1
	li	a4,7
	addi	a7,a7,-1
	addi	t3,t3,4
	addi	t4,t4,1
	beq	t1,a4,.L45
	lw	a1,0(t3)
	li	a4,0
	ble	a1,a2,.L47
.L151:
	lbu	a1,56(sp)
	sb	a1,0(t4)
	li	a1,6
	bne	t1,a1,.L50
	j	.L45
.L149:
	li	a0,0
.L59:
	slli	a5,a0,1
	add	a0,a5,a0
	lbu	a5,7(a4)
	addi	a4,a4,1
	add	a0,a5,a0
	bne	a4,s9,.L59
	j	.L60
.L96:
	lbu	s11,0(s0)
	li	a0,6
	li	a4,42
	j	.L54
.L150:
	lw	a5,8(sp)
	lw	a3,4(sp)
	mv	s5,s6
	addi	a5,a5,1
	mv	s9,s10
	addi	s0,s0,1
	bne	a3,a5,.L63
.L147:
	mv	a1,a3
	bne	s4,zero,.L64
	lw	a3,12(sp)
	li	a1,729
	li	a4,1
	lw	s0,16(sp)
	mv	a5,a1
	mv	s5,a3
	bne	s9,a4,.L97
	sw	s9,732(a3)
.L33:
	lw	a0,24(sp)
	call	heuristic
	li	a5,11
	addi	a3,sp,104
	bgt	a0,a5,.L129
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	addi	a5,a5,116
	sw	a5,12(sp)
	li	s5,7
	li	s7,2
	addi	s4,sp,47
	mv	s2,a0
	mv	s9,s0
.L66:
	lw	a4,24(sp)
	mv	a5,a3
.L68:
	lbu	a2,7(a4)
	lbu	a1,0(a4)
	addi	a5,a5,1
	sb	a2,6(a5)
	sb	a1,-1(a5)
	addi	a2,sp,111
	addi	a4,a4,1
	bne	a2,a5,.L68
	sw	zero,56(sp)
	li	s8,0
	mv	a6,s2
	mv	a2,s9
.L69:
	slli	a0,s8,3
	sub	s0,a0,s8
	slli	s0,s0,1
	add	a4,a3,s0
	li	a5,0
.L71:
	lbu	a1,0(a4)
	bne	a1,a5,.L70
	lbu	a1,7(a4)
	addi	a5,a5,1
	addi	a4,a4,1
	bne	a1,zero,.L70
	bne	a5,s5,.L71
	beq	s8,zero,.L32
	addi	a5,sp,56
	slli	a4,s8,2
	mv	s5,a2
	add	a4,a4,a5
.L73:
	lw	a3,0(a5)
	addi	a5,a5,4
	addi	s5,s5,4
	sw	a3,-4(s5)
	bne	a4,a5,.L73
.L32:
	lw	ra,332(sp)
	lw	s0,328(sp)
	lw	s1,324(sp)
	lw	s2,320(sp)
	lw	s3,316(sp)
	lw	s4,312(sp)
	lw	s5,308(sp)
	lw	s6,304(sp)
	lw	s7,300(sp)
	lw	s9,292(sp)
	lw	s10,288(sp)
	lw	s11,284(sp)
	mv	a0,s8
	lw	s8,296(sp)
	addi	sp,sp,336
	jr	ra
.L70:
	beq	s8,a6,.L152
	addi	a5,sp,56
	slli	a7,s8,2
	add	a4,a5,a7
	lw	s2,0(a4)
	li	a5,9
	addi	s6,s2,1
	bgt	s6,a5,.L144
	sw	a4,16(sp)
	andi	a5,s6,0xff
	lw	a4,16(sp)
	addi	s11,a5,-3
	addi	s10,a5,-6
	sub	s3,a0,s8
	sw	s0,20(sp)
	andi	s0,s10,0xff
	andi	s10,s11,0xff
	mv	s11,s6
	slli	s3,s3,1
	addi	a1,sp,272
	sw	a7,28(sp)
	sw	a3,4(sp)
	sw	a2,8(sp)
	sw	s11,0(a4)
	add	s3,a1,s3
	addi	s9,s8,1
	mv	s1,a6
	mv	s6,s2
	bne	s8,zero,.L153
.L131:
	andi	a2,s6,0xff
	li	a3,0
	bgtu	a2,s7,.L154
.L80:
	addi	a5,a5,-1
	slli	a1,a5,3
	sub	a1,a1,a5
	lui	a5,%hi(.LANCHOR1+52)
	add	a1,a1,a3
	addi	a5,a5,%lo(.LANCHOR1+52)
	add	a3,a5,a1
	lw	a5,12(sp)
	addi	t5,a3,7
	addi	a2,sp,40
	add	a1,a5,a1
.L86:
	lbu	a4,0(a3)
	lbu	a5,0(a1)
	addi	a3,a3,1
	add	a4,s3,a4
	lbu	a0,-168(a4)
	lbu	a4,-161(a4)
	addi	a1,a1,1
	sb	a0,0(a2)
	add	a5,a5,a4
	ble	a5,s7,.L85
	addi	a5,a5,-3
.L85:
	sb	a5,7(a2)
	addi	a2,a2,1
	bne	t5,a3,.L86
	addi	a0,sp,40
	call	heuristic
	add	a5,s9,a0
	ble	a5,s1,.L155
	addi	t1,s10,1
	addi	a7,s0,1
	addi	s11,s11,1
	li	a5,10
	andi	s10,t1,0xff
	andi	s0,a7,0xff
	addi	s6,s6,1
	beq	s11,a5,.L156
	lw	a4,16(sp)
	andi	a5,s11,0xff
	sw	s11,0(a4)
	beq	s8,zero,.L131
.L153:
	addi	a1,s8,-1
	slli	a2,a1,2
	addi	a4,sp,56
	add	a2,a4,a2
.L77:
	andi	a3,s6,0xff
	lw	a4,0(a2)
	bgtu	a3,s7,.L79
	addi	a4,a4,-1
	andi	a4,a4,0xff
	bleu	a4,s7,.L132
	li	a3,0
	j	.L80
.L155:
	lw	s0,20(sp)
	lw	a3,4(sp)
	lw	a2,8(sp)
	addi	a5,s0,14
	addi	a4,sp,111
	mv	a6,s1
	add	a5,a4,a5
	addi	s1,sp,40
.L88:
	lbu	a1,0(s1)
	lbu	a4,7(s1)
	addi	s1,s1,1
	sb	a1,-7(a5)
	sb	a4,0(a5)
	addi	a5,a5,1
	bne	s1,s4,.L88
	slli	a5,s9,2
	add	a5,sp,a5
	sw	zero,56(a5)
	mv	s8,s9
	j	.L69
.L152:
	addi	s8,s8,-1
.L75:
	li	a5,-1
	bne	s8,a5,.L69
	addi	s2,a6,1
	li	a5,12
	mv	s9,a2
	bne	s2,a5,.L66
	j	.L32
.L154:
	li	a4,5
	mv	a5,s10
	li	a3,21
	bleu	a2,a4,.L80
.L99:
	mv	a5,s0
	li	a3,42
	j	.L80
.L79:
	li	a5,5
	bgtu	a3,a5,.L157
	addi	a5,a4,-4
	andi	a5,a5,0xff
	bleu	a5,s7,.L132
	mv	a5,s10
	li	a3,21
	j	.L80
.L157:
	addi	a5,a4,-1
	andi	a5,a5,0xff
	li	a4,5
	bleu	a5,a4,.L99
.L132:
	addi	s11,s11,1
	li	a5,10
	beq	s11,a5,.L139
	lw	a3,28(sp)
	addi	s10,s10,1
	addi	s0,s0,1
	add	a4,sp,a3
	andi	s10,s10,0xff
	andi	s0,s0,0xff
	addi	s6,s6,1
	andi	a5,s11,0xff
	sw	s11,56(a4)
	j	.L77
.L156:
	lw	a3,4(sp)
	lw	a2,8(sp)
	mv	a6,s1
.L144:
	addi	a1,s8,-1
	mv	s8,a1
	j	.L75
.L97:
	mv	s9,a4
	j	.L65
.L139:
	lw	a3,4(sp)
	lw	a2,8(sp)
	mv	a6,s1
	mv	s8,a1
	j	.L75
.L129:
	li	s8,-1
	j	.L32
	.size	solve.part.0, .-solve.part.0
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	beq	a2,zero,.L159
	add	a2,a0,a2
	mv	a5,a0
.L160:
	sb	a1,0(a5)
	addi	a5,a5,1
	bne	a5,a2,.L160
.L159:
	ret
	.size	memset, .-memset
	.align	2
	.globl	solve
	.type	solve, @function
solve:
	mv	a5,a0
	li	a4,0
	li	a2,7
.L167:
	lbu	a3,0(a5)
	bne	a4,a3,.L166
	lbu	a3,7(a5)
	addi	a4,a4,1
	addi	a5,a5,1
	bne	a3,zero,.L166
	bne	a4,a2,.L167
	li	a0,0
	ret
.L166:
	tail	solve.part.0
	.size	solve, .-solve
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC1:
	.string	"invalid cube state\n"
	.align	2
.LC2:
	.string	"no solution within 11 moves\n"
	.align	2
.LC3:
	.string	"invalid solution move\n"
	.align	2
.LC4:
	.string	"solution verification failed\n"
	.text
	.align	2
	.globl	solver4_run
	.type	solver4_run, @function
solver4_run:
	li	a5,0
	li	a3,15
.L171:
	add	a4,a0,a5
	lbu	a4,0(a4)
	beq	a4,zero,.L236
	addi	a5,a5,1
	bne	a5,a3,.L171
.L231:
	lui	a5,%hi(.LC1)
	lui	a4,%hi(.LC1+19)
	addi	a5,a5,%lo(.LC1)
	addi	a4,a4,%lo(.LC1+19)
	li	a0,105
.L232:
	addi	a5,a5,1
	li	a7,11
 #APP
# 329 "solver4.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lbu	a0,0(a5)
	bne	a5,a4,.L232
	li	t4,2
	mv	a0,t4
	ret
.L236:
	li	a4,14
	bne	a5,a4,.L231
	addi	sp,sp,-128
	sw	s0,120(sp)
	addi	s0,sp,20
	sw	s1,116(sp)
	sw	ra,124(sp)
	mv	a3,s0
	addi	s1,sp,27
	li	t4,0
	li	a2,0
	li	t3,6
	li	a7,2
	li	t1,1
.L174:
	lbu	a5,0(a0)
	addi	a5,a5,-49
	andi	a5,a5,0xff
	sll	a1,t1,a5
	and	a6,a1,a2
	bgtu	a5,t3,.L172
	lbu	a4,7(a0)
	or	a2,a2,a1
	addi	a0,a0,1
	addi	a4,a4,-49
	andi	a4,a4,0xff
	bgtu	a4,a7,.L172
	sb	a5,0(a3)
	sb	a4,7(a3)
	addi	a3,a3,1
	bne	a6,zero,.L172
	add	t4,t4,a4
	bne	a3,s1,.L174
	sw	s2,112(sp)
	ble	t4,a7,.L175
	li	a5,2
.L176:
	addi	t4,t4,-3
	bgt	t4,a5,.L176
.L175:
	addi	a4,sp,20
	li	a5,0
	li	a2,7
	bne	t4,zero,.L237
.L177:
	lbu	a3,0(a4)
	bne	a3,a5,.L180
	lbu	a3,7(a4)
	addi	a5,a5,1
	addi	a4,a4,1
	bne	a3,zero,.L180
	bne	a5,a2,.L177
	li	t0,0
.L203:
	addi	t5,sp,36
	mv	a5,t5
.L181:
	lbu	a3,0(s0)
	lbu	a4,7(s0)
	addi	s0,s0,1
	sb	a3,0(a5)
	sb	a4,7(a5)
	addi	a5,a5,1
	bne	s0,s1,.L181
	beq	t0,zero,.L184
	lui	t6,%hi(.LANCHOR1)
	addi	t6,t6,%lo(.LANCHOR1)
	addi	t3,sp,68
	slli	a0,t0,2
	addi	s0,t6,52
	add	a0,a0,t3
	addi	t6,t6,116
	li	t2,8
	li	t1,2
	li	s1,5
.L192:
	lw	a5,0(t3)
	addi	a4,a5,-1
	bgtu	a4,t2,.L238
	andi	a5,a5,0xff
	addi	a4,a5,-1
	andi	a3,a4,0xff
	li	a2,0
	bleu	a3,t1,.L187
	bgtu	a3,s1,.L188
	addi	a5,a5,-3
	andi	a5,a5,0xff
	addi	a4,a5,-1
	li	a2,21
.L187:
	slli	a6,a4,3
	sub	a6,a6,a4
	add	a6,a6,a2
	add	a2,s0,a6
	addi	a4,sp,52
	add	a6,t6,a6
	addi	s2,a2,7
	mv	a1,a4
.L190:
	lbu	a3,0(a2)
	lbu	a5,0(a6)
	addi	a2,a2,1
	add	a3,sp,a3
	lbu	a7,36(a3)
	lbu	a3,43(a3)
	addi	a6,a6,1
	sb	a7,0(a1)
	add	a5,a5,a3
	ble	a5,t1,.L189
	addi	a5,a5,-3
.L189:
	sb	a5,7(a1)
	addi	a1,a1,1
	bne	s2,a2,.L190
	addi	a1,a4,7
	mv	a5,t5
.L191:
	lbu	a2,0(a4)
	lbu	a3,7(a4)
	addi	a4,a4,1
	sb	a2,0(a5)
	sb	a3,7(a5)
	addi	a5,a5,1
	bne	a4,a1,.L191
	addi	t3,t3,4
	bne	t3,a0,.L192
.L184:
	li	a5,0
	li	a3,7
.L194:
	lbu	a4,0(t5)
	bne	a4,a5,.L207
	lbu	a4,7(t5)
	addi	a5,a5,1
	addi	t5,t5,1
	bne	a4,zero,.L207
	bne	a5,a3,.L194
	beq	t0,zero,.L202
	lui	a2,%hi(.LANCHOR1)
	addi	a2,a2,%lo(.LANCHOR1)
	addi	a3,sp,68
	li	a4,0
.L197:
	lw	a5,0(a3)
	addi	a5,a5,-1
	slli	a5,a5,2
	add	a5,a2,a5
	lw	a5,180(a5)
	lbu	a0,0(a5)
	beq	a0,zero,.L198
.L199:
	addi	a5,a5,1
	li	a7,11
 #APP
# 329 "solver4.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lbu	a0,0(a5)
	bne	a0,zero,.L199
.L198:
	addi	a4,a4,1
	beq	a4,t0,.L202
	addi	a3,a3,4
	li	a0,32
	li	a7,11
 #APP
# 329 "solver4.c" 1
	ecall
# 0 "" 2
 #NO_APP
	j	.L197
.L188:
	addi	a5,a5,-6
	andi	a5,a5,0xff
	addi	a4,a5,-1
	li	a2,42
	j	.L187
.L237:
	lw	s2,112(sp)
.L172:
	lui	a5,%hi(.LC1)
	lui	a4,%hi(.LC1+19)
	addi	a5,a5,%lo(.LC1)
	addi	a4,a4,%lo(.LC1+19)
	li	a0,105
.L178:
	addi	a5,a5,1
	li	a7,11
 #APP
# 329 "solver4.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lbu	a0,0(a5)
	bne	a5,a4,.L178
	lw	ra,124(sp)
	lw	s0,120(sp)
	li	t4,2
	lw	s1,116(sp)
	mv	a0,t4
	addi	sp,sp,128
	jr	ra
.L180:
	addi	a0,sp,20
	addi	a1,sp,68
	sw	t4,12(sp)
	call	solve.part.0
	li	a5,-1
	lw	t4,12(sp)
	mv	t0,a0
	bne	a0,a5,.L203
	lui	a5,%hi(.LC2)
	lui	a4,%hi(.LC2+28)
	addi	a5,a5,%lo(.LC2)
	addi	a4,a4,%lo(.LC2+28)
	li	a0,110
.L182:
	addi	a5,a5,1
	li	a7,11
 #APP
# 329 "solver4.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lbu	a0,0(a5)
	bne	a5,a4,.L182
.L183:
	lw	s2,112(sp)
	li	t4,1
.L239:
	lw	ra,124(sp)
	lw	s0,120(sp)
	lw	s1,116(sp)
	mv	a0,t4
	addi	sp,sp,128
	jr	ra
.L238:
	lui	a5,%hi(.LC3)
	lui	a4,%hi(.LC3+22)
	addi	a5,a5,%lo(.LC3)
	addi	a4,a4,%lo(.LC3+22)
	li	a0,105
.L186:
	addi	a5,a5,1
	li	a7,11
 #APP
# 329 "solver4.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lbu	a0,0(a5)
	bne	a5,a4,.L186
	lw	s2,112(sp)
	li	t4,1
	j	.L239
.L202:
	li	a0,10
	li	a7,11
 #APP
# 329 "solver4.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lw	ra,124(sp)
	lw	s0,120(sp)
	lw	s2,112(sp)
	lw	s1,116(sp)
	mv	a0,t4
	addi	sp,sp,128
	jr	ra
.L207:
	lui	a5,%hi(.LC4)
	lui	a4,%hi(.LC4+29)
	addi	a5,a5,%lo(.LC4)
	li	a0,115
	addi	a4,a4,%lo(.LC4+29)
.L196:
	addi	a5,a5,1
	li	a7,11
 #APP
# 329 "solver4.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lbu	a0,0(a5)
	bne	a5,a4,.L196
	j	.L183
	.size	solver4_run, .-solver4_run
	.align	2
	.globl	solver4_main
	.type	solver4_main, @function
solver4_main:
	lui	a0,%hi(.LANCHOR2)
	addi	sp,sp,-16
	addi	a0,a0,%lo(.LANCHOR2)
	sw	ra,12(sp)
	call	solver4_run
	lw	ra,12(sp)
	lui	a5,%hi(.LANCHOR0+736)
	sw	a0,%lo(.LANCHOR0+736)(a5)
	addi	sp,sp,16
	jr	ra
	.size	solver4_main, .-solver4_main
	.globl	solver4_status
	.globl	cube_input
	.section	.rodata.str1.4
	.align	2
.LC5:
	.string	"R"
	.align	2
.LC6:
	.string	"R2"
	.align	2
.LC7:
	.string	"R'"
	.align	2
.LC8:
	.string	"B"
	.align	2
.LC9:
	.string	"B2"
	.align	2
.LC10:
	.string	"B'"
	.align	2
.LC11:
	.string	"D"
	.align	2
.LC12:
	.string	"D2"
	.align	2
.LC13:
	.string	"D'"
	.section	.rodata
	.align	2
	.set	.LANCHOR1,. + 0
	.type	weight.1, @object
	.size	weight.1, 24
weight.1:
	.word	243
	.word	81
	.word	27
	.word	9
	.word	3
	.word	1
	.type	factorial.0, @object
	.size	factorial.0, 28
factorial.0:
	.word	720
	.word	120
	.word	24
	.word	6
	.word	2
	.word	1
	.word	1
	.type	move_source, @object
	.size	move_source, 63
move_source:
	.base64	"AQQCAAMFBg=="
	.base64	"BAMCAQAFBg=="
	.base64	"AwACBAEFBg=="
	.base64	"AAECBAUGAw=="
	.base64	"AAECBQYDBA=="
	.base64	"AAECBgMEBQ=="
	.base64	"AAIFAwEEBg=="
	.base64	"AAUEAwIBBg=="
	.base64	"AAQBAwUCBg=="
	.zero	1
	.type	move_twist, @object
	.size	move_twist, 63
move_twist:
	.base64	"AQIAAgEAAA=="
	.base64	"AAAAAAAAAA=="
	.base64	"AQIAAgEAAA=="
	.base64	"AAAAAQIBAg=="
	.base64	"AAAAAAAAAA=="
	.base64	"AAAAAQIBAg=="
	.base64	"AAAAAAAAAA=="
	.base64	"AAAAAAAAAA=="
	.base64	"AAAAAAAAAA=="
	.zero	1
	.type	move_names, @object
	.size	move_names, 36
move_names:
	.word	.LC5
	.word	.LC6
	.word	.LC7
	.word	.LC8
	.word	.LC9
	.word	.LC10
	.word	.LC11
	.word	.LC12
	.word	.LC13
	.data
	.align	2
	.set	.LANCHOR2,. + 0
	.type	cube_input, @object
	.size	cube_input, 15
cube_input:
	.string	"21345671111111"
	.bss
	.align	2
	.set	.LANCHOR0,. + 0
	.type	orient_dist, @object
	.size	orient_dist, 729
orient_dist:
	.zero	729
	.zero	3
	.type	heuristic_ready, @object
	.size	heuristic_ready, 4
heuristic_ready:
	.zero	4
	.type	solver4_status, @object
	.size	solver4_status, 4
solver4_status:
	.zero	4
	.type	perm_dist, @object
	.size	perm_dist, 5040
perm_dist:
	.zero	5040
	.ident	"GCC: (GNU) 16.2.0"
	.section	.note.GNU-stack,"",@progbits
