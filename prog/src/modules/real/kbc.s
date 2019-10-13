;;; KBC バッファ書き込み関数
;;; @fn bool KBC_Data_Write(data);
;;; @param (data) 書き込みデータ
;;; @return 0(failure) others(success)

KBC_Data_Write:
    ;; START
    push bp                     ;   + 4| data
    mov bp, sp                  ;   + 2| IP
                                ; BP+ 0| BP
                                ; -----+------

    push cx

    ;; BODY
    mov cx, 0                   ; CX = 0; //max_cnt_num

    .10L:                       ; do {
    in al, 0x64                 ;   AL = inp(0x64); //KBC status
    test al, 0x02               ;   ZF = AL & 0x02; //writable?
    loopnz .10L                 ; } while (--CX && !ZF);

    cmp cx, 0                   ; if (CX) {
    jz .20E                     ;   // 未タイムアウト

    mov al, [bp + 4]            ;   AL = data;
    out 0x60, al                ;   outp(0x60, AL);

    .20E:                       ; }
    mov ax, cx                  ; return CX;


    ;; FINISH
    pop cx

    mov sp, bp
    pop bp

    ret

;;; KBCバッファ読み込み関数
;;; @fn bool KBC_Data_Read(data);
;;; @param (data) 読み込みデータ格納アドレス
;;; @return 0(failure), others(success)

KBC_Data_Read:
    ;; START
    push bp                     ;   + 4| data
    mov bp, sp                  ;   + 2| IP
                                ; BP+ 0| BP
                                ; -----+------

    push cx
    push di

    ;; BODY
    mov cx, 0                   ; CX = 0; //max_cnt_num

    .10L:                       ; do {
    in al, 0x64                 ;   AL = inp(0x64); //KBC status
    test al, 0x01               ;   ZF = AL & 0x01; //readable?
    loopz .10L                 ; } while (--CX && !ZF);

    cmp cx, 0                   ; if (CX) {
    jz .20E                     ;   // 未タイムアウト

    mov ah, 0x00                ;   AH = 0x00;
    in al, 0x60                 ;   AL = inp(0x60);

    mov di, [bp + 4]            ;   DI = ptr;
    mov [di + 0], ax            ;   DI[0] = AX;

    .20E:                       ; }
    mov ax, cx                  ; return CX;

    ;; FINISH
    pop di
    pop cx

    mov sp, bp
    pop bp

    ret

;;; KBCコマンド書き込み関数
;;; @fn bool KBC_Cmd_write(cmd);
;;; @param (cmd) command
;;; @return 0(failure), others(success)

KBC_Cmd_Write:
    ;; START
    push bp                     ;   + 4| data
    mov bp, sp                  ;   + 2| IP
                                ; BP+ 0| BP
                                ; -----+------

    push cx

    ;; BODY
    mov cx, 0                   ; CX = 0; //max_cnt_num

    .10L:                       ; do {
    in al, 0x64                 ;   AL = inp(0x64); //KBC status
    test al, 0x02               ;   ZF = AL & 0x02; //writable?
    loopnz .10L                 ; } while (--CX && !ZF);

    cmp cx, 0                   ; if (CX) {
    jz .20E                     ;   // 未タイムアウト

    mov al, [bp + 4]            ;   AL = command;
    out 0x64, al                ;   outp(0x60, AL);

    .20E:                       ; }
    mov ax, cx                  ; return CX;


    ;; FINISH
    pop cx

    mov sp, bp
    pop bp

    ret
