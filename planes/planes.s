! a 128b freedirectional plane raytracer (3rd ever dc 128b).
! well, ok then, I optimized away some directions.. ;)
! quarn/Outbreak - 18th march 2005

!		.set    DEBUG,1
!		.set	CLRSCR,1
		.text

.ifdef	CLRSCR
		.align	2
clrscr:
		mov.l	VIDEO_BASE,r0	! clear screen
		mov	#0,r1
		mov.l	CLRCOUNT,r2
clrscr_loop:
		mov.l	r1,@r0
		dt	r2
		bf/s	clrscr_loop
		add	#4,r0
		bra	main
		nop

		.align	4
CLRCOUNT:	.long	640*480/2
VIDEO_BASE:	.LONG	0xa5000000

.endif

		.align 2
main:
.ifdef  DEBUG
                mov     #64,r13
		shll	r13
.endif
main_loop:
		ftrc    fr12,fpul
		.word	0xf2fd

		mov.l	VIDEO_RAM,r7
		mov	#127,r1		! height

main_yloop:
		mov	#127, r2	! width
main_xloop:
		mov	r1, r4
		add	#-64,r4

		mov	r2, r5
		add	#-64,r5

		lds	r4,fpul		! y
		float	fpul,fr5

		lds	r5,fpul		! x
		float	fpul,fr4

		mov	#32,r3
		lds	r3,fpul
		float	fpul, fr6	! z

		! rotate around the y-axis
		fmov	fr6,fr8
		fmul	fr2,fr6		! c * z
		fmul	fr3,fr8		! s * z

		fmov	fr4,fr9
		fmul	fr2,fr4		! c * x
		fmul	fr3,fr9		! s * x

		fadd	fr8,fr4		!  c * x + s * z
		fsub	fr9,fr6		! -s * x + c * z

		! intersection and texture coordinates
		float	fpul, fr0	! distance between planes
		fabs	fr5
		fdiv	fr5, fr0	! t

		lds	r12, fpul
		float	fpul, fr10

		fmul	fr0,fr4		! t * dir.x
		fmac	fr0,fr6,fr10	! org.z + t * dir.z

		ftrc	fr4,fpul
		sts	fpul,r6

		ftrc	fr10,fpul
		sts	fpul,r0

		xor	r6,r0
		and	#31,r0

		! shade in y. this is cheating, but as we do not rotate in x or z, it will look ok
		cmp/pz	r4
		bt	skip
		not	r4,r4
skip:
		mul.l	r4,r0
		sts	macl,r0
		shlr	r0

		! put pixel
		mov.w	r0,@-r7

		dt	r2
		bf	main_xloop

		mov.w	LINEADD,r6
		sub	r6,r7

		dt	r1
		bf	main_yloop

		! calculate next frames rotation
		mova	FRAME_ADD,r0
		fmov    @r0,fr1
		fadd	fr1,fr12

		add	#2,r12
.ifdef  DEBUG
                cmp/hi  r13,r12
                bf      main_loop

                mov.l   dcload_syscall,r0
                mov.l   @r0,r0
                jmp     @r0
                mov     #15,r4

                .align  4
dcload_syscall: .long   0x8c004008
.else
                bra     main_loop
                nop
.endif

		.align	4
VIDEO_RAM:	.long   0xa5000000  + (640 + 128) + (480 + 100) * 640
FRAME_ADD:	.float	156.455675 ! 0.015 * 32768 / PI
LINEADD:	.short	640*2 -(127)*2 
