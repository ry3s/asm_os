;;; メモリの比較
;;; @fn memcpy(src0, src1, size);
;;; @param src0 address 0
;;; @param src1 address 1
;;; @param size バイト数
;;; @return 一致(0), 不一致(0以外)

memcpy:
    ;;
    ;; スタックフレームの構築
    ;;
    push bp                     ; BP+ 8| byte size
    mov bp, sp                  ; BP+ 6| address 1
                                ; BP+ 4| address 0
                                ; -----|-----------
                                ; BP+ 2| IP(戻り番地)
                                ; BP+ 0| BP(元の値)
                                ; -----+-----------
    ;;
    ;; レジスタの保存
    ;;
    push bx
    push cx
    push dx
    push si
    push di
    ;;
    ;; 引数の取得
    ;;
    cld                         ; DFクリア(+方向)
    mov si, [bp + 4]
    mov di, [bp + 6]
    mov cx, [bp + 8]
    ;;
    ;; バイト単位での比較
    ;;
    repe cmpsb                  ; if (ZF = 異なる文字なし)
    jnz .10F                    ;   ret = 0; 一致
    mov ax, 0                   ; else
    jmp .10E                    ;  ret = -1; 不一致
    .10F:
    mov ax, -1
    .10E:
    ;;
    ;; レジスタの復帰
    ;;
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ;;
    ;; スタックフレームの破棄
    ;;
    mv sp, bp
    pop bp

    ret
