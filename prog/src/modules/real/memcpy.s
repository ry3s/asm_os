;;; メモリのコピー
;;; @fn void memcpy(dst, src, size);
;;; @param dst コピー先
;;; @param src コピー元
;;; @param size バイト数
;;; @return なし

memcpy:
    ;;
    ;; スタックフレームの構築
    ;;
    push bp                     ; BP+ 8| byte size
    mov bp, sp                  ; BP+ 6| source
                                ; BP+ 4| destination
                                ; -----|-----------
                                ; BP+ 2| IP(戻り番地)
                                ; BP+ 0| BP(元の値)
                                ; -----+-----------
    ;;
    ;; レジスタの保存
    ;;
    push cx
    push si
    push di
    ;;
    ;; バイト単位でのコピー
    ;;
    cld                         ; DF = 0; // +方向
    mov di, [bp + 4]            ; DI = dst
    mov si, [bp + 6]            ; SI = src
    mov cx, [bp + 8]            ; CX = byte size

    rep movsb                   ; while (*DI++ = *SI++);
    ;;
    ;; レジスタの復帰
    ;;
    pop di
    pop si
    pop cx
    ;;
    ;; スタックフレームの破棄
    ;;
    mv sp, bp
    pop bp

    ret
