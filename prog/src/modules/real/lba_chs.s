;;; LBAをCHSに変換
;;; void lba_chs(drive, drv_chs, lba);
;;; drive: address of struct drive(drive param)
;;; drv_chs: address of struct drive(cyln, head, sect)
;;; lba: LBA
;;; return: failure(0), success(others)
lba_chs:
    ;; START
    push    bp  			    ;    + 8| LBA（2バイト）
    mov     bp, sp				;    + 6| drv_chsドライブ情報
								;    + 4| driveドライブ情報
								; ------+--------
								;    + 2| IP（戻り番地）
								;  BP+ 0| BP（元の値）
								; ------+--------
    push    ax
    push    bx
    push    dx
    push    si
    push    di

    ;; BODY
    mov     si,     [bp + 4]        ; SI = drive buff;
    mov     di,     [bp + 6]        ; DI = drv_chs buff;


    ;; sect num / cyln (head * sect)
    mov     al, [si + drive.head]   ; AL = max head num;
    mul     byte [si + drive.sect]  ; AX = max head num * max sect num;
    mov     bx,     ax              ; BX = sect num / cyln

    ;; シリンダ番号を取得するために
    ;; LBAをシリンダあたりのセクタ数で除算
    mov     dx,     0               ; DX = LBA (上位2 byte)
    mov     ax,     [bp + 8]        ; AX = LBA (下位2 byte)
    div     bx                      ; AX = DX:AX / BX; // シリンダ番号
                                    ; DX = DX:AX % BX; // rem

    mov     [di + drive.cyln],  ax

    mov     ax,     dx              ; AX = rem
    div byte [si + drive.sect]      ;


    movzx   dx,     ah
    inc     dx

    mov     ah,     0x00

    mov     [di + drive.head],  ax
    mov     [di + drive.sect],  dx

    ;; FINISH
    pop		di
	pop		si
	pop		dx
	pop		bx
	pop		ax

	mov		sp, bp
	pop		bp

	ret
