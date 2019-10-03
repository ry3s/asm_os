;;; 数値を文字列に変換する
;;; @fn  void itoa(num,  buff, size, radix, flag)
;;; @param num 変換する値
;;; @param buff 保存先バッファアドレス
;;; @param size 保存先バッファサイズ
;;; @param radix 2, 8, 10 or 16
;;; @param flag
;;;        B2: 空白をゼロで埋める
;;;        B1: '+/-' 記号を付加する
;;;        B0: 値を符号付き変数として扱う

itoa:
    ;; スタックフレームの構築
    push bp                     ;   +12| flag
    mov bp, sp                  ;   +10| radix
                                ;   + 8| buff size
                                ;   + 6| buff address
                                ;   + 4| num
                                ;   + 2| IP
                                ; BP+ 0| BP
                                ; -----+-------------

    ;; レジスタの保存
    push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di

    ;; 引数の取得
    mov		ax, [bp + 4]					; val  = 数値;
	mov		si, [bp + 6]					; dst  = バッファアドレス;
	mov		cx, [bp + 8]					; size = 残りバッファサイズ;

	mov		di, si							; // バッファの最後尾
	add		di, cx							; dst  = &dst[size - 1];
	dec		di								;

	mov		bx, [bp +12]					; flags = オプション;

    ;; 符号付き判定
    test bx, 0b0001             ; if (flags & 0b01) {
                                ;   if (val > 0) {
    .10Q:                       ;     flag |= 2;
    je .10E                     ;   }
    cmp ax, 0                   ; }

    .12Q:
    jge .12E
    or bx, 0b0010

    .12E:
    .10E:

    ;; 符号出力判定
    test bx, 0b0010             ; if (flag & 0x02) {
                                ;   if (val > 0) {
    .20Q:                       ;      val *= -1;
    je .20E                     ;      *dst = '-';
    cmp ax, 0                   ;   } else {
                                ;      *dst = '+';
    .22Q:                       ;   }
    jge .22F                    ;
    neg ax                      ;   size--;
    mov [si], byte '-'          ; }
    jmp .22E

    .22F:
    mov [si], byte '+'

    .22E:
    dec cx

    .20E:

    ;; ASCII 変換
    mov bx, [bp + 10]           ; BX = radix
                                ;
    .30L:                       ; do {
    mov dx, 0                   ;  DX = DX:AX % radix;
    div bx                      ;  AX = DX:AX / radix;
                                ;
    mov si, dx                  ;
    mov dl, byte [.ascii + si]  ;  DL = ASCII[DX];
    mov [di], dl                ;  *dst = DL;
    dec di                      ;   dst--;
                                ;
    cmp ax, 0                   ;
    loopnz .30L                 ; } while (AX);

    .30E:

    ;; 空白を埋める
    cmp cx, 0                   ; if (size) {
                                ;
    .40Q:                       ;
    je .40E                     ;
    mov al, ' '                 ;    AL = ' '
    cmp [bp + 12], word 0b0100  ;    if (flag & 0x04) {
                                ;
    .42Q:                       ;
    jne .42E                    ;
    mov al, '0'                 ;       AL = '0';
                                ;    }
    .42E:                       ;
    std                         ;    DF = 1
    rep stosb                   ;    while (--cx) *DI-- = ' ';
                                ;
    .40E:                       ; }

    ;; レジスタの復帰
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax

    ;; スタックフレームの破棄
	mov		sp, bp
	pop		bp

	ret


    .ascii db "0123456789ABCDEF" ; 変換テーブル
