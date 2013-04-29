section .text

global _fdct
global _idct

_fdct:
	push ebx
	push esi
	push edi
	push ebp
	mov ebp, esp
	mov ebx, [ebp + 28]		;how much
	mov ecx, [ebp + 24]   	;where write
	mov edi, [ebp + 20]  	;where matrix
	pop ebp
	mov esi, T_1
	
FDCT_loop:  		;A' = C * A * CT
	cmp ebx, 0
	je ret_dct
	dec ebx
	
	push ecx
	push edi
	push esi
	push temp_buf
	call matrix_mul
	
	add esp, 4
	pop esi
	pop edi
	pop ecx

	push edi
	push temp_buf	
	push esi
	push ecx
	call matrix_mul
	
	pop ecx
	pop esi
	add esp, 4
	pop edi
	
	add edi, 256
	add ecx, 256
	jmp FDCT_loop
	
_idct:						;A = CT * A' * C
	push ebx
	push esi
	push edi
	push ebp
	mov ebp, esp
	mov ebx, [ebp + 28]		;how much
	mov ecx, [ebp + 24]   	;where write
	mov edi, [ebp + 20]  	;where matrix
	pop ebp
	mov esi, TT_1

IDCT_loop:
	cmp ebx, 0
	je ret_dct
	dec ebx
	
	push ecx
	push edi
	push esi
	push temp_buf
	call matrix_mul
	
	add esp, 4
	pop esi
	pop edi
	pop ecx

	push edi
	push temp_buf	
	push esi
	push ecx
	call matrix_mul
	
	pop ecx
	pop esi
	add esp, 4
	pop edi
	
	add edi, 256
	add ecx, 256
	jmp IDCT_loop
	
matrix_mul:  				
	push ebp
	mov ebp, esp
	mov ecx, [ebp + 8]		;where write
	mov esi, [ebp + 12]		;where C matrix
	mov edi, [ebp + 16]		;where A matrix
	pop ebp
	xor eax, eax
	mov al, 8
	
matrix_mul_loop:
	cmp al, 0
	je ret_
	dec al
	
	mov ah, 8
	movaps xmm2, [esi]
	add esi, 16
	movaps xmm3, [esi]
	add esi, 16
	
entry_loop:
	cmp ah, 0
	je normalize_addres
	dec ah
	
	movaps xmm0, [edi]
	add edi, 16
	movaps xmm1, [edi]
	add edi, 16
	
	mulps xmm0, xmm2
	mulps xmm1, xmm3
	
	haddps xmm0, xmm1
	haddps xmm0, xmm0
	haddps xmm0, xmm0
	movss [ecx], xmm0
	
	add ecx, 4
	jmp entry_loop
	
normalize_addres:
	sub edi, 256
	jmp matrix_mul_loop
	
ret_:
	ret
	
ret_dct:
	pop edi
	pop esi
	pop ebx
	ret
	
section .rdata
	align 16
	T_1 dd	0.1250000000, 0.1250000000, 0.1250000000, 0.1250000000, 0.1250000000, 0.1250000000, 0.1250000000, 0.1250000000
	T_2 dd	0.1733799807, 0.1469844504, 0.0982118700, 0.0344874227, -0.0344874221, -0.0982118694, -0.1469844500, -0.1733799805
	T_3 dd	0.1633203706, 0.0676495127, -0.0676495122, -0.1633203704, -0.1633203709, -0.0676495133, 0.0676495116, 0.1633203702
	T_4 dd	0.1469844504, -0.0344874221, -0.1733799805, -0.0982118705, 0.0982118689, 0.1733799809, 0.0344874239, -0.1469844493
	T_5 dd	0.1250000001, -0.1249999997, -0.1250000006, 0.1249999992, 0.1250000010, -0.1249999988, -0.1250000015, 0.1249999983
	T_6 dd	0.0982118700, -0.1733799805, 0.0344874214, 0.1469844511, -0.1469844493, -0.0344874245, 0.1733799812, -0.0982118673
	T_7 dd	0.0676495127, -0.1633203709, 0.1633203702, -0.0676495110, -0.0676495145, 0.1633203716, -0.1633203694, 0.0676495092
	T_8 dd	0.0344874227, -0.0982118705, 0.1469844511, -0.1733799810, 0.1733799802, -0.1469844486, 0.0982118668, -0.0344874183
	
	TT_1 dd	1.0000000000, 1.3870398454, 1.3065629651, 1.1758756029, 1.0000000009, 0.7856949597, 0.5411961019, 0.2758993815
	TT_2 dd	1.0000000000, 1.1758756029, 0.5411961019, -0.2758993765, -0.9999999973, -1.3870398444, -1.3065629671, -0.7856949639
	TT_3 dd	1.0000000000, 0.7856949597, -0.5411960972, -1.3870398444, -1.0000000045, 0.2758993715, 1.3065629612, 1.1758756086
	TT_4 dd	1.0000000000, 0.2758993815, -1.3065629632, -0.7856949639, 0.9999999937, 1.1758756086, -0.5411960878, -1.3870398484
	TT_5 dd	1.0000000000, -0.2758993765, -1.3065629671, 0.7856949513, 1.0000000081, -1.1758755945, -0.5411961160, 1.3870398414
	TT_6 dd	1.0000000000, -0.7856949555, -0.5411961066, 1.3870398474, -0.9999999901, -0.2758993964, 1.3065629729, -1.1758755888
	TT_7 dd	1.0000000000, -1.1758756001, 0.5411960925, 0.2758993914, -1.0000000117, 1.3870398493, -1.3065629554, 0.7856949344
	TT_8 dd	1.0000000000, -1.3870398444, 1.3065629612, -1.1758755945, 0.9999999865, -0.7856949386, 0.5411960738, -0.2758993466

section .bss
	align 16
	temp_buf resd  256