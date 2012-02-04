! a 128b rotozoomer for dreamcast.. (2nd ever dc 128b)
! quarn/Outbreak - 16 mars 2005

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
                mov     #127,r13
		shll	r13
		shll	r13
.endif

		mova    PI_SCALE,r0
		fmov    @r0,fr11
main_loop:
		fmov	fr4,fr7
		fmul    fr11,fr7
		ftrc    fr7,fpul
		.word 0xf0fd
		fmul	fr5,fr0
		fmul	fr5,fr1

		mov.l	VIDEO_RAM,r0
		mov	#100,r1		! height
main_yloop:
		mov	#127, r2	! width
		mov	r1, r4
		add	#-50,r4
main_xloop:

		mov	r2, r5
		add	#-64,r5

		lds	r4,fpul		! y 
		float	fpul,fr6

		lds	r5,fpul		! x
		float	fpul,fr7

		fmov	fr6,fr8
		fmul	fr0,fr6		! c * y
		fmul	fr1,fr8		! s * y

		fmov	fr7,fr9
		fmul	fr0,fr7		! c * x
		fmul	fr1,fr9		! s * x

		fsub	fr8, fr7	! c * x - s * y
		fadd	fr6,fr9		! c * y + s * x

		ftrc	fr7,fpul
		sts	fpul, r6

		ftrc	fr9,fpul
		sts	fpul, r7

		xor	r6,r7
		mov	#31,r6
		and	r6,r7
		mov.w	r7,@r0
		add	#2,r0

		dt	r2
		bf	main_xloop

		mov.w	LINEADD,r6
		add	r6,r0

		dt	r1
		bf	main_yloop
		

		! calculate some new values for rotation
		! and zoom		
		mova    FRAME_ADD,r0
		fmov    @r0,fr6
		fadd	fr6,fr4

		fmov	fr4,fr6
		fmul    fr11,fr6
		ftrc    fr6,fpul
		.word 0xf0fd

		fmov	fr0,fr5

		add	#1,r12
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
VIDEO_RAM:      .long   0xa5000000  + (640 - 128) + (480 - 100) * 640
PI_SCALE:       .float  10430.37835     ! 32768 / PI
FRAME_ADD:	.float	0.03
LINEADD:	.short	640*2 -(127)*2 
