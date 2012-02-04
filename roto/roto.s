! a 256b rotozoomer for dreamcast.. (2nd 256b for dreamcast ever)
! quarn/Outbreak - quarn@home.se - 20 july 2002 22:14:13
!
! To compile:
!	sh-elf-as -little -o 256b.o 256b.s
!	sh-elf-ld -EL --oformat srec -Ttext 0x8c010000 256b.o -o 256b.srec
!	sh-elf-objcopy -O binary 256b.srec 256b.bin

		.text

!.set	CLRSCR,1
.set	DEBUG,1

		.align	2
.ifdef	CLRSCR
clrscr:
		mov.l	VIDEO_BASE,r0	! clear screen
		mov	#0,r1
		mov.l	CLRCOUNT,r2
clrscr_loop:
		mov.l	r1,@r0
		dt	r2
		bf/s	clrscr_loop
		add	#4,r0
.endif

!xorgen:
!		mov.l	TEXTURE,r1	! generate xor-texture
!		mov.l	TWIDTH,r2
!xor_yloop:
!		mov	r2,r5
!		shlr2	r5
!		mov.l	TWIDTH,r3
!xor_xloop:
!		mov	r3,r4
!		shlr2	r4
!		xor	r5,r4
!		mov.b	r4,@r1
!		add	#1,r1

!		dt	r3
!		bf	xor_xloop

!		dt	r2
!		bf	xor_yloop

!		bra	main
!		nop

main:
		mov	#1,r12
.ifdef	DEBUG
		mov	#127,r13
.endif
main_loop:
		lds	r12,fpul
		float	fpul,fr4
		mov	#20,r14
		lds	r14,fpul
		float	fpul,fr5
		fdiv	fr5,fr4

		mova	PI_SCALE,r0
		fmov	@r0,fr6
		fmul	fr6,fr4
		ftrc	fr4,fpul
		.word	0xf0fd
!		fsca	fpul,dr0

		fmov	fr0,fr7
		fmov	fr1,fr8

		lds	r12,fpul
		float	fpul,fr4
		mov	#10,r14
		lds	r14,fpul
		float	fpul,fr5
		fdiv	fr5,fr4

		fmul	fr6,fr4
		ftrc	fr4,fpul
		.word	0xf0fd
!		fsca	fpul,dr0

		mova	FP_SCALE,r0
		fmov	@r0,fr2
		fmul	fr0,fr3
		mova	FP_SCALE2,r0
		fmov	@r0,fr2
		fadd	fr2,fr3
		fmul	fr3,fr7
		fmul	fr3,fr8

		ftrc	fr7,fpul
		sts	fpul,r1

		ftrc	fr8,fpul
		sts	fpul,r2

		mov.l	WIDTH,r5
		shlr	r5

		mul.l	r1,r5
		sts	macl,r3
		neg	r3,r3

		mul.l	r2,r5
		sts	macl,r4
		neg	r4,r4

		mov	r4,r5
		sub	r3,r4
		add	r5,r3

		mov.l	VIDEO_RAM,r0
		mov.l	HEIGHT,r5
main_yloop:
		mov.l	WIDTH,r6

		mov	r3,r7	! sin
		mov	r4,r8	! cos
main_xloop:
		mov	r7,r10
		shlr8	r10

		mov	r8,r11
		shlr8	r11

		xor	r11,r10

		mov.w	r10,@r0
		add	#2,r0

		add	r1,r7
		add	r2,r8

		dt	r6
		bf	main_xloop

		add	r2,r3
		sub	r1,r4

		mov.l	LINEADD,r10
		add	r10,r0

		dt	r5
		bf	main_yloop

		add	#1,r12

.ifdef	DEBUG
		cmp/hi	r13,r12
		bf	main_loop

		mov.l	dcload_syscall,r0
		mov.l	@r0,r0
		jmp	@r0
		mov	#15,r4

		.align	4
dcload_syscall:	.long	0x8c004008


.else

		bra	main_loop
		nop
.endif


		.align	4
CLRCOUNT:	.long	640*480/2
VIDEO_BASE:	.LONG	0xa5000000
LINEADD:	.long	320 !(640-320)*2
WIDTH:		.long	320
HEIGHT:		.long	240

VIDEO_RAM:	.LONG	0xa5000000 ! + (640 - 320) + 240 * 640

PI_SCALE:	.float	10430.37835     ! 32768 / PI
FP_SCALE:	.float	65536.0
FP_SCALE2:	.float	16384.0

