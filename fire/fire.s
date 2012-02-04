! a 128b fire effect for dreamcast.. (1st ever dc 128b)
! quarn/Outbreak - 16 mars 2005

!		.set    DEBUG,1
!		.set	CLRSCR,1
		.text

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
.endif

main_loop:
		mov.l	VIDEO_RAM,r0
		mov	#100,r1		! height
		mov	#0,r3		! pos
		mov	#127,r9
main_yloop:
		mov	#127, r2	! width
main_xloop:
		mov	#2,r6

		mov	r3,r4
		add	#-2,r4
		mov.w	@(r0, r4),r8	! pos - 1
		and	r9,r8
		mov	r8,r5
		add	#2*2,r4
		mov.w	@(r0, r4),r8	! pos + 1
		and	r9,r8
		add	r8,r5

		add	#-2*2,r4
loop1:
		mov.w	SWIDTH, r10
		mov	#3,r7
		add	r10,r4
loop2:
		mov.w   @(r0, r4),r8
		and	r9,r8
		add     r8,r5
		add	#2,r4

		dt	r7
		bf	loop2

		add	#-3*2,r4
		dt	r6
		bf	loop1

		! put pixel
		shlr2	r5
		shlr	r5

		cmp/gt	r9,r5
		bf	skip
		mov	r9,r5
skip:
		mov.w	r5, @(r0,r3)
		add	#2,r3

		dt	r2
		bf	main_xloop

		mov.l	LINEADD,r11
		add	r11,r3

		dt	r1
		bf	main_yloop

		! keep fire alive
		mov	#50,r7
loop3:
		! ignite new pixel
		mov.l	LASTLINE,r0
		mov	r14,r10
		and	r9,r10
		shll	r10
		add	r10,r0
		mov.w	r9,@r0

		! calculate next pixel to ignite
		not	r14,r14
		rotr	r14
		add	r12,r14

		dt	r7
		bf	loop3
		
		add     #1,r12
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
SWIDTH:		.long	640*2
LINEADD:	.long	640*2 -(127)*2 
LASTLINE:	.long	0xa5000000 + (640-128) +  (480 - 100) * 640 + (640*2)*(99)
