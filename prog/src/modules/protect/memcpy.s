;************************************************************************
;	メモリのコピー
;========================================================================
;■書式		: void memcpy(dst, src, size);
;
;■引数
;	dst		: コピー先
;	src		: コピー元
;	size	: バイト数
;
;■戻り値	: 無し
;************************************************************************
memcpy:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; EBP+16| バイト数
												; EBP+12| コピー元
												; EBP+ 8| コピー先
												; ------|--------
		push	ebp								; EBP+ 0| EBP（元の値）
		mov		ebp, esp						; EBP+ 4| EIP（戻り番地）
												; ------|--------
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	ecx
		push	esi
		push	edi

		;---------------------------------------
		; バイト単位でのコピー
		;---------------------------------------
		cld										; DF   = 0; // +方向
		mov		edi, [ebp + 8]					; EDI  = コピー先;
		mov		esi, [ebp +12]					; EDI  = コピー元;
		mov		ecx, [ebp +16]					; EDI  = バイト数;
		rep movsb								; while (*EDI++ = *ESI++) ;

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		edi
		pop		esi
		pop		ecx

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret
