# Compiler-generated RV32I from solver3.c; not hand-written assembly.
# Build/link with build_solver3.sh and solver3.ld; load ELF in Ripes.
	.file	"solver3.c"
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
call solver3_main
li a7, 10
ecall
3: j 3b
.text

 #NO_APP
	.align	2
	.type	apply_move, @function
apply_move:
	addi	sp,sp,-80
	sw	s1,68(sp)
	sw	s5,52(sp)
	sw	ra,76(sp)
	sw	s0,72(sp)
	sw	s2,64(sp)
	sw	s3,60(sp)
	sw	s4,56(sp)
	sw	s6,48(sp)
	sw	s7,44(sp)
	li	a5,2
	mv	s5,a0
	mv	s1,a1
	bgtu	a2,a5,.L2
	addi	a2,a2,1
	andi	s4,a2,0xff
	li	a4,0
.L3:
	lui	s2,%hi(.LANCHOR0)
	addi	s2,s2,%lo(.LANCHOR0)
	slli	a5,a4,3
	sub	a5,a5,a4
	addi	s3,s2,24
	add	s3,s3,a5
	add	s2,s2,a5
	li	s0,0
	addi	s7,sp,23
	li	s6,2
.L7:
	li	a2,14
	mv	a1,s1
	mv	a0,sp
	call	memcpy
	addi	a4,sp,16
	mv	a2,s3
	mv	a3,s2
.L6:
	lbu	a5,0(a3)
	lbu	a1,0(a2)
	addi	a3,a3,1
	add	a5,sp,a5
	lbu	a0,0(a5)
	lbu	a5,7(a5)
	addi	a2,a2,1
	sb	a0,0(a4)
	add	a5,a5,a1
	ble	a5,s6,.L5
	addi	a5,a5,-3
.L5:
	sb	a5,7(a4)
	addi	a4,a4,1
	bne	a4,s7,.L6
	addi	s0,s0,1
	li	a2,14
	addi	a1,sp,16
	mv	a0,s1
	andi	s0,s0,0xff
	call	memcpy
	bne	s4,s0,.L7
	mv	a1,s1
	mv	a0,s5
	li	a2,14
	call	memcpy
	lw	ra,76(sp)
	lw	s0,72(sp)
	lw	s1,68(sp)
	lw	s2,64(sp)
	lw	s3,60(sp)
	lw	s4,56(sp)
	lw	s6,48(sp)
	lw	s7,44(sp)
	mv	a0,s5
	lw	s5,52(sp)
	addi	sp,sp,80
	jr	ra
.L2:
	addi	s4,a2,-2
	li	a3,5
	andi	s4,s4,0xff
	li	a4,1
	bleu	a2,a3,.L3
	addi	a2,a2,-5
	andi	s4,a2,0xff
	mv	a4,a5
	j	.L3
	.size	apply_move, .-apply_move
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
.L23:
	lbu	a2,-1(a7)
	mv	a5,a7
	li	a3,0
.L14:
	lbu	a4,0(a5)
	addi	a5,a5,1
	sltu	a4,a4,a2
	add	a3,a3,a4
	bne	a0,a5,.L14
	beq	a6,t3,.L15
	addi	a5,a6,-3
	bgtu	a5,t1,.L16
	beq	a6,t1,.L17
	beq	a6,t4,.L27
	slli	a1,a1,1
	add	a0,a1,a3
	ret
.L16:
	slli	a5,a1,1
	add	a5,a5,a1
	beq	a6,t5,.L20
	slli	a5,a5,1
	add	a1,a5,a1
.L21:
	add	a1,a1,a3
	addi	a6,a6,1
	addi	a7,a7,1
	j	.L23
.L20:
	slli	a1,a5,1
	j	.L21
.L15:
	slli	a5,a1,2
	add	a1,a5,a1
	addi	a7,a7,1
	add	a1,a3,a1
	li	a6,4
	j	.L23
.L27:
	slli	a1,a1,2
	add	a1,a3,a1
	addi	a7,a7,1
	li	a6,5
	j	.L23
.L17:
	slli	a5,a1,1
	add	a1,a5,a1
	addi	a7,a7,1
	add	a1,a3,a1
	li	a6,6
	j	.L23
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
.L31:
	lbu	a2,0(a4)
	beq	a2,a5,.L41
.L29:
	addi	a3,a3,1
.L30:
	addi	a5,a5,1
	addi	a4,a4,1
	bne	a5,a1,.L31
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
.L32:
	lbu	a3,0(a4)
	slli	a2,a5,1
	add	a5,a2,a5
	addi	a4,a4,1
	add	a5,a3,a5
	bne	a0,a4,.L32
	lui	a4,%hi(.LANCHOR1)
	addi	a4,a4,%lo(.LANCHOR1)
	add	a5,a4,a5
	srai	a3,s0,2
	lbu	a0,0(a5)
	bge	a3,a1,.L33
	mv	a3,a1
.L33:
	bge	a0,a3,.L34
	mv	a0,a3
.L34:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
.L41:
	lbu	a2,7(a4)
	beq	a2,zero,.L30
	j	.L29
	.size	heuristic, .-heuristic
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	beq	a2,zero,.L43
	add	a2,a1,a2
	mv	a5,a0
.L44:
	lbu	a4,0(a1)
	addi	a1,a1,1
	addi	a5,a5,1
	sb	a4,-1(a5)
	bne	a1,a2,.L44
.L43:
	ret
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	beq	a2,zero,.L50
	add	a2,a0,a2
	mv	a5,a0
.L51:
	sb	a1,0(a5)
	addi	a5,a5,1
	bne	a5,a2,.L51
.L50:
	ret
	.size	memset, .-memset
	.align	2
	.globl	solve
	.type	solve, @function
solve:
	addi	sp,sp,-352
	sw	ra,348(sp)
	sw	s2,336(sp)
	mv	a5,a0
	li	a4,0
	li	a2,7
.L58:
	lbu	a3,0(a5)
	bne	a3,a4,.L57
	lbu	a3,7(a5)
	addi	a4,a4,1
	addi	a5,a5,1
	bne	a3,zero,.L57
	bne	a4,a2,.L58
	lw	ra,348(sp)
	li	s2,0
	mv	a0,s2
	lw	s2,336(sp)
	addi	sp,sp,352
	jr	ra
.L57:
	sw	s11,300(sp)
	lui	s11,%hi(.LANCHOR1)
	addi	a5,s11,%lo(.LANCHOR1)
	sw	a5,12(sp)
	lw	a5,732(a5)
	sw	s0,344(sp)
	sw	s1,340(sp)
	sw	s3,332(sp)
	sw	s4,328(sp)
	sw	s5,324(sp)
	sw	s6,320(sp)
	sw	s7,316(sp)
	sw	s8,312(sp)
	sw	s9,308(sp)
	sw	s10,304(sp)
	sw	a1,28(sp)
	sw	a0,24(sp)
	bne	a5,zero,.L113
	li	a4,4096
	addi	a4,a4,944
	lui	s5,%hi(perm_dist)
	lui	s10,%hi(.LANCHOR0)
	mv	s9,a4
	addi	s5,s5,%lo(perm_dist)
	addi	s10,s10,%lo(.LANCHOR0)
	li	s3,0
	addi	s0,sp,126
.L87:
	add	a4,a4,s5
	mv	a5,s5
	li	a3,-1
.L60:
	sb	a3,0(a5)
	addi	a5,a5,1
	bne	a5,a4,.L60
	sb	zero,0(s5)
.L86:
	mv	s2,s5
	li	s7,0
	li	s6,0
	li	s8,255
	j	.L85
.L61:
	addi	s6,s6,1
	addi	s2,s2,1
	beq	s9,s6,.L146
.L85:
	lbu	a5,0(s2)
	beq	a5,s8,.L61
	li	a5,50462720
	li	a4,393216
	addi	a5,a5,256
	addi	a4,a4,1284
	sw	zero,128(sp)
	sh	zero,132(sp)
	sw	a5,120(sp)
	sw	a4,124(sp)
	beq	s3,zero,.L62
	addi	s1,sp,120
	mv	a1,s1
	addi	a0,s10,48
	mv	a4,s6
	li	a2,0
	li	a5,0
.L63:
	lw	a3,0(a0)
	bgt	a3,a4,.L66
.L64:
	addi	a5,a5,1
	sub	a4,a4,a3
	andi	a5,a5,0xff
	bge	a4,a3,.L64
	sb	a5,7(a1)
.L66:
	addi	a1,a1,1
	add	a2,a2,a5
	beq	s0,a1,.L65
	lbu	a5,7(a1)
	addi	a0,a0,4
	j	.L63
.L62:
	sw	a5,72(sp)
	li	a1,6
	li	a5,1284
	addi	s1,sp,120
	sh	a5,76(sp)
	sb	a1,78(sp)
	mv	a6,s1
	addi	a0,s10,72
	mv	a4,s6
	addi	a7,sp,72
.L71:
	lw	a3,0(a0)
	li	a5,0
	bgt	a3,a4,.L147
.L72:
	sub	a4,a4,a3
	addi	a5,a5,1
	bge	a4,a3,.L72
	add	a3,sp,a5
	lbu	a3,72(a3)
	sb	a3,0(a6)
	bge	a5,a1,.L76
.L75:
	add	a3,a5,a7
.L77:
	lbu	a2,1(a3)
	addi	a5,a5,1
	addi	a3,a3,1
	sb	a2,-1(a3)
	blt	a5,a1,.L77
	lw	a3,4(a0)
	addi	a0,a0,4
	addi	a1,a1,-1
	addi	a6,a6,1
	li	a5,0
	ble	a3,a4,.L72
.L147:
	lbu	a2,72(sp)
	li	a3,6
	sub	a3,a3,a1
	sb	a2,0(a6)
	li	a2,5
	ble	a3,a2,.L75
	j	.L70
.L76:
	addi	a1,a1,-1
	li	a5,-1
	bne	a1,a5,.L148
.L70:
	lw	a2,120(sp)
	lw	a3,124(sp)
	lw	a4,128(sp)
	lhu	a5,132(sp)
	sw	a2,72(sp)
	sw	a3,76(sp)
	sw	a4,80(sp)
	sh	a5,84(sp)
	li	s11,0
	li	s4,9
	j	.L84
.L80:
	mv	a0,s1
	call	permutation_index
.L82:
	lbu	a5,0(s2)
	add	a0,s5,a0
	lbu	a4,0(a0)
	addi	a5,a5,1
	bge	a5,a4,.L83
	sb	a5,0(a0)
	li	s7,1
.L83:
	addi	s11,s11,1
	beq	s11,s4,.L61
.L84:
	lw	a7,72(sp)
	lw	a3,76(sp)
	lw	a4,80(sp)
	lhu	a5,84(sp)
	andi	a2,s11,0xff
	addi	a1,sp,32
	mv	a0,s1
	sw	a7,32(sp)
	sw	a3,36(sp)
	sw	a4,40(sp)
	sh	a5,44(sp)
	call	apply_move
	beq	s3,zero,.L80
	mv	a5,s1
	li	a0,0
.L81:
	lbu	a4,7(a5)
	slli	a3,a0,1
	add	a0,a3,a0
	addi	a5,a5,1
	add	a0,a4,a0
	bne	a5,s0,.L81
	j	.L82
.L65:
	li	a5,2
	ble	a2,a5,.L67
.L68:
	addi	a2,a2,-3
	bgt	a2,a5,.L68
.L67:
	li	a5,0
	beq	a2,zero,.L69
	li	a5,3
	sub	a5,a5,a2
.L69:
	sb	a5,133(sp)
	j	.L70
.L146:
	bne	s7,zero,.L86
	lw	a5,12(sp)
	li	s9,729
	li	a3,1
	mv	a4,s9
	mv	s5,a5
	bne	s3,a3,.L116
	sw	s3,732(a5)
.L113:
	lw	a0,24(sp)
	call	heuristic
	li	a5,11
	mv	s8,a0
	bgt	a0,a5,.L117
	addi	s1,sp,120
	li	s4,7
.L109:
	lw	a1,24(sp)
	li	a2,14
	mv	a0,s1
	call	memcpy
	li	s2,0
	sw	zero,72(sp)
.L88:
	slli	s10,s2,3
	sub	a5,s10,s2
	slli	a5,a5,1
	add	a5,s1,a5
	li	a4,0
.L90:
	lbu	a3,0(a5)
	bne	a3,a4,.L89
	lbu	a3,7(a5)
	addi	a4,a4,1
	addi	a5,a5,1
	bne	a3,zero,.L89
	bne	a4,s4,.L90
	addi	a5,sp,72
	slli	a3,s2,2
	lw	a4,28(sp)
	add	a3,a3,a5
	beq	s2,zero,.L144
.L92:
	lw	a2,0(a5)
	addi	a5,a5,4
	addi	a4,a4,4
	sw	a2,-4(a4)
	bne	a3,a5,.L92
.L144:
	lw	s0,344(sp)
	lw	ra,348(sp)
	lw	s1,340(sp)
	lw	s3,332(sp)
	lw	s4,328(sp)
	lw	s5,324(sp)
	lw	s6,320(sp)
	lw	s7,316(sp)
	lw	s8,312(sp)
	lw	s9,308(sp)
	lw	s10,304(sp)
	lw	s11,300(sp)
	mv	a0,s2
	lw	s2,336(sp)
	addi	sp,sp,352
	jr	ra
.L89:
	beq	s8,s2,.L149
	slli	a5,s2,2
	addi	s5,sp,72
	add	s0,s5,a5
	sw	a5,12(sp)
	lw	a5,0(s0)
	li	a4,8
	bgt	a5,a4,.L145
	sub	s3,s10,s2
	slli	s3,s3,1
	addi	a4,sp,288
	add	s3,a4,s3
	addi	s7,s2,1
.L107:
	addi	s6,a5,1
	sw	s6,0(s0)
	andi	a2,a5,0xff
	bne	s2,zero,.L150
.L98:
	lhu	t1,-168(s3)
	lhu	a7,-166(s3)
	lhu	a6,-164(s3)
	lhu	a0,-162(s3)
	lhu	a1,-160(s3)
	lhu	a5,-158(s3)
	sh	t1,32(sp)
	sh	a7,34(sp)
	sh	a6,36(sp)
	sh	a0,38(sp)
	sh	a1,40(sp)
	sh	a5,42(sp)
	lhu	a5,-156(s3)
	addi	a1,sp,32
	addi	a0,sp,56
	sh	a5,44(sp)
	call	apply_move
	addi	a0,sp,56
	call	heuristic
	add	a5,a0,s7
	mv	s9,s7
	bgt	a5,s8,.L104
.L111:
	slli	a5,s9,3
	lhu	a7,56(sp)
	lhu	a6,58(sp)
	lhu	a0,60(sp)
	lhu	a1,62(sp)
	lhu	a2,64(sp)
	lhu	a3,66(sp)
	lhu	a4,68(sp)
	sub	a5,a5,s9
	slli	a5,a5,1
	slli	t1,s9,2
	add	a5,sp,a5
	add	s5,s5,t1
	sh	a7,120(a5)
	sh	a6,122(a5)
	sh	a0,124(a5)
	sh	a1,126(a5)
	sh	a2,128(a5)
	sh	a3,130(a5)
	sh	a4,132(a5)
	sw	zero,0(s5)
	mv	s2,s9
	j	.L88
.L149:
	addi	s2,s8,-1
.L95:
	li	a5,-1
	bne	s2,a5,.L88
	addi	s8,s8,1
	li	a5,12
	bne	s8,a5,.L109
	j	.L144
.L150:
	addi	t1,s2,-1
	sub	s11,s10,s2
	slli	a6,t1,2
	slli	s11,s11,1
	add	a6,s5,a6
	addi	a4,sp,288
	andi	a2,a5,0xff
	li	a7,2
	lw	a5,0(a6)
	add	s11,a4,s11
	bgtu	a2,a7,.L99
.L151:
	addi	a5,a5,-1
	andi	a5,a5,0xff
	bleu	a5,a7,.L110
.L100:
	lhu	t5,-168(s11)
	lhu	t4,-166(s11)
	lhu	t3,-164(s11)
	lhu	a0,-162(s11)
	lhu	a1,-160(s11)
	lhu	a5,-158(s11)
	sh	t5,32(sp)
	sh	t4,34(sp)
	sh	t3,36(sp)
	sh	a0,38(sp)
	sh	a1,40(sp)
	sh	a5,42(sp)
	lhu	a5,-156(s11)
	addi	a1,sp,32
	addi	a0,sp,56
	sw	t1,20(sp)
	sw	a6,16(sp)
	sh	a5,44(sp)
	call	apply_move
	addi	a0,sp,56
	call	heuristic
	addi	s9,s2,1
	add	a5,s9,a0
	lw	a6,16(sp)
	lw	t1,20(sp)
	li	a7,2
	ble	a5,s8,.L111
.L110:
	lw	a5,12(sp)
	addi	a1,s6,1
	add	a4,s5,a5
	mv	a5,s6
	sw	a1,0(a4)
	andi	a2,a5,0xff
	mv	s6,a1
	lw	a5,0(a6)
	bleu	a2,a7,.L151
.L99:
	li	a1,5
	bgtu	a2,a1,.L152
	addi	a5,a5,-4
	andi	a5,a5,0xff
	bgtu	a5,a7,.L100
	j	.L110
.L104:
	li	a5,9
	beq	s6,a5,.L145
	mv	a5,s6
	j	.L107
.L152:
	addi	a5,a5,-1
	andi	a5,a5,0xff
	bleu	a5,a1,.L98
	li	a5,9
	bne	s6,a5,.L110
	mv	s2,t1
	j	.L95
.L145:
	addi	t1,s2,-1
	mv	s2,t1
	j	.L95
.L116:
	li	s3,1
	j	.L87
.L117:
	li	s2,-1
	j	.L144
.L148:
	addi	a0,a0,4
	addi	a6,a6,1
	j	.L71
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
	.globl	solver3_run
	.type	solver3_run, @function
solver3_run:
	addi	sp,sp,-144
	sw	ra,140(sp)
	sw	s1,132(sp)
	li	a5,0
	li	a3,15
.L154:
	add	a4,a0,a5
	lbu	a4,0(a4)
	beq	a4,zero,.L200
	addi	a5,a5,1
	bne	a5,a3,.L154
.L155:
	lui	a5,%hi(.LC1)
	lui	a4,%hi(.LC1+19)
	addi	a5,a5,%lo(.LC1)
	addi	a4,a4,%lo(.LC1+19)
	li	a0,105
.L161:
	addi	a5,a5,1
	li	a7,11
 #APP
# 332 "solver3.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lbu	a0,0(a5)
	bne	a5,a4,.L161
	lw	ra,140(sp)
	li	s1,2
	mv	a0,s1
	lw	s1,132(sp)
	addi	sp,sp,144
	jr	ra
.L200:
	li	a4,14
	bne	a5,a4,.L155
	addi	a3,sp,36
	addi	t4,sp,43
	li	s1,0
	li	a2,0
	li	t3,6
	li	a7,2
	li	t1,1
.L157:
	lbu	a5,0(a0)
	addi	a5,a5,-49
	andi	a5,a5,0xff
	sll	a1,t1,a5
	and	a6,a1,a2
	bgtu	a5,t3,.L155
	lbu	a4,7(a0)
	or	a2,a2,a1
	addi	a0,a0,1
	addi	a4,a4,-49
	andi	a4,a4,0xff
	bgtu	a4,a7,.L155
	sb	a5,0(a3)
	sb	a4,7(a3)
	addi	a3,a3,1
	bne	a6,zero,.L155
	add	s1,s1,a4
	bne	t4,a3,.L157
	sw	s0,136(sp)
	sw	s2,128(sp)
	sw	s3,124(sp)
	sw	s4,120(sp)
	sw	s5,116(sp)
	ble	s1,a7,.L158
	li	a5,2
.L159:
	addi	s1,s1,-3
	bgt	s1,a5,.L159
.L158:
	bne	s1,zero,.L201
	lw	a5,44(sp)
	lw	a3,36(sp)
	lw	a4,40(sp)
	sw	a5,24(sp)
	lhu	a5,48(sp)
	addi	a1,sp,68
	addi	a0,sp,16
	sh	a5,28(sp)
	sw	a3,16(sp)
	sw	a4,20(sp)
	call	solve
	li	a5,-1
	mv	s2,a0
	beq	a0,a5,.L202
	lw	a2,36(sp)
	lw	a3,40(sp)
	lw	a4,44(sp)
	lhu	a5,48(sp)
	sw	a2,52(sp)
	sw	a3,56(sp)
	sw	a4,60(sp)
	sh	a5,64(sp)
	addi	s3,sp,52
	beq	a0,zero,.L166
	addi	a5,sp,68
	slli	s4,a0,2
	add	s4,a5,s4
	mv	s0,a5
	li	s5,8
	j	.L169
.L167:
	lw	a6,52(sp)
	lw	a3,56(sp)
	lw	a4,60(sp)
	lhu	a5,64(sp)
	sw	a6,0(sp)
	sw	a3,4(sp)
	sw	a4,8(sp)
	sh	a5,12(sp)
	call	apply_move
	addi	a0,sp,52
	addi	a1,sp,16
	li	a2,14
	addi	s0,s0,4
	mv	s3,a0
	call	memcpy
	beq	s4,s0,.L166
.L169:
	lw	a5,0(s0)
	mv	a1,sp
	addi	a0,sp,16
	addi	a5,a5,-1
	andi	a2,a5,0xff
	bleu	a5,s5,.L167
	lui	a5,%hi(.LC3)
	lui	a4,%hi(.LC3+22)
	addi	a5,a5,%lo(.LC3)
	addi	a4,a4,%lo(.LC3+22)
	li	a0,105
.L168:
	addi	a5,a5,1
	li	a7,11
 #APP
# 332 "solver3.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lbu	a0,0(a5)
	bne	a5,a4,.L168
.L165:
	li	s1,1
.L199:
	lw	s0,136(sp)
	lw	ra,140(sp)
	lw	s2,128(sp)
	lw	s3,124(sp)
	lw	s4,120(sp)
	lw	s5,116(sp)
	mv	a0,s1
	lw	s1,132(sp)
	addi	sp,sp,144
	jr	ra
.L166:
	mv	a5,s3
	li	a4,0
	li	a2,7
.L171:
	lbu	a3,0(a5)
	bne	a3,a4,.L181
	lbu	a3,7(a5)
	addi	a4,a4,1
	addi	a5,a5,1
	bne	a3,zero,.L181
	bne	a4,a2,.L171
	beq	s2,zero,.L179
	lui	a2,%hi(.LANCHOR0)
	addi	a3,sp,68
	addi	a2,a2,%lo(.LANCHOR0)
	li	a4,0
.L174:
	lw	a5,0(a3)
	addi	a5,a5,-1
	slli	a5,a5,2
	add	a5,a2,a5
	lw	a5,100(a5)
	lbu	a0,0(a5)
	beq	a0,zero,.L175
.L176:
	addi	a5,a5,1
	li	a7,11
 #APP
# 332 "solver3.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lbu	a0,0(a5)
	bne	a0,zero,.L176
.L175:
	addi	a4,a4,1
	beq	s2,a4,.L179
	addi	a3,a3,4
	li	a0,32
	li	a7,11
 #APP
# 332 "solver3.c" 1
	ecall
# 0 "" 2
 #NO_APP
	j	.L174
.L179:
	li	a0,10
	li	a7,11
 #APP
# 332 "solver3.c" 1
	ecall
# 0 "" 2
 #NO_APP
	j	.L199
.L202:
	lui	a5,%hi(.LC2)
	lui	a4,%hi(.LC2+28)
	addi	a5,a5,%lo(.LC2)
	addi	a4,a4,%lo(.LC2+28)
	li	a0,110
.L164:
	addi	a5,a5,1
	li	a7,11
 #APP
# 332 "solver3.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lbu	a0,0(a5)
	bne	a5,a4,.L164
	j	.L165
.L181:
	lui	a5,%hi(.LC4)
	lui	a4,%hi(.LC4+29)
	addi	a5,a5,%lo(.LC4)
	li	a0,115
	addi	a4,a4,%lo(.LC4+29)
.L173:
	addi	a5,a5,1
	li	a7,11
 #APP
# 332 "solver3.c" 1
	ecall
# 0 "" 2
 #NO_APP
	lbu	a0,0(a5)
	bne	a5,a4,.L173
	j	.L165
.L201:
	lw	s0,136(sp)
	lw	s2,128(sp)
	lw	s3,124(sp)
	lw	s4,120(sp)
	lw	s5,116(sp)
	j	.L155
	.size	solver3_run, .-solver3_run
	.align	2
	.globl	solver3_main
	.type	solver3_main, @function
solver3_main:
	lui	a0,%hi(.LANCHOR2)
	addi	sp,sp,-16
	addi	a0,a0,%lo(.LANCHOR2)
	sw	ra,12(sp)
	call	solver3_run
	lw	ra,12(sp)
	lui	a5,%hi(.LANCHOR1+736)
	sw	a0,%lo(.LANCHOR1+736)(a5)
	addi	sp,sp,16
	jr	ra
	.size	solver3_main, .-solver3_main
	.globl	solver3_status
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
	.set	.LANCHOR0,. + 0
	.type	source, @object
	.size	source, 21
source:
	.base64	"AQQCAAMFBg=="
	.base64	"AAECBAUGAw=="
	.base64	"AAIFAwEEBg=="
	.zero	3
	.type	twist, @object
	.size	twist, 21
twist:
	.base64	"AQIAAgEAAA=="
	.base64	"AAAAAQIBAg=="
	.base64	"AAAAAAAAAA=="
	.zero	3
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
	.set	.LANCHOR1,. + 0
	.type	orient_dist, @object
	.size	orient_dist, 729
orient_dist:
	.zero	729
	.zero	3
	.type	heuristic_ready, @object
	.size	heuristic_ready, 4
heuristic_ready:
	.zero	4
	.type	solver3_status, @object
	.size	solver3_status, 4
solver3_status:
	.zero	4
	.type	perm_dist, @object
	.size	perm_dist, 5040
perm_dist:
	.zero	5040
	.ident	"GCC: (GNU) 16.2.0"
	.section	.note.GNU-stack,"",@progbits
