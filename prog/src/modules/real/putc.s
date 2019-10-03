;;; @fn putc(ch);
;;; @param ch charactor code
;;; @return nothing

putc:
    ;; スタックフレームの構築
    push bp                     ;   + 4| 出力文字
    mov bp, sp                  ;   + 2| IP(戻り番地)
                                ; BP+ 0| BP(元の値)

    ;; レジスタの保存
    push ax
    push bx

    ;; 処理の開始
    mov al, [bp + 4]            ; 出力文字を取得
    mov ah, 0x0E                ; テレタイプ式1文字出力
    mov bx, 0x0000              ; ページ番号と文字色を0に設定
    int 0x10                    ; ビデオBIOSコール

    ;; レジスタの復帰
    pop bx
    pop ax

    ;; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret
