;;; ドライブパラメータを取得する
;;; @fn get_drive_param(drive);
;;; @param (drive) pointer: drive struct
;;; @return 0: fail

get_drive_param:
    ;; スタックフレームの構築
    push bp                     ;   + 4| param buff
    mov bp, sp                 ;   + 2| IP
                                ; BP+ 0| BP

    ;; レジスタの保存
    push bx
    push cx
    push es
    push si
    push di

    ;; 処理の開始
    mov si, [bp + 4]            ; SI = buff;

    mov ax, 0                   ; init Disk Base Table Pointer
    mov es, ax                  ; ES = 0;
    mov di, ax                  ; DI = 0;

    mov ah, 8                   ;
    mov dl, [si + drive.no]     ; DL = drive number;
    int 0x13                    ; CF = BIOS(0x13, 8);
                                ;
    .10Q:                       ;
    jc .10F                     ; if (0 == CF)
                                ; {
    .10T:                       ;
    mov al, cl                  ;
    and ax, 0x3F                ;   AX = num_sector
                                ;
    shr cl, 6                   ;
    ror cx, 8                   ;
    inc cx                      ;   CX = num_clyn
                                ;
    movzx bx, dh                ;
    inc bx                      ;   BX = num_head(1-based)
                                ;
    mov [si + drive.cyln], cx   ;   drive.clyn = CX;
    mov [si + drive.head], bx   ;   drive.head = BX;
    mov [si + drive.sect], ax   ;   drive.sect = AX;
                                ;
    jmp .10E                    ; }
                                ; else
    .10F:                       ; {
    mov ax, 0                   ;   AX = 0; failure
                                ;
    .10E:                       ; }

    ;; レジスタの復帰
    pop di
    pop si
    pop es
    pop cx
    pop bx

    ;; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret
