;;; BIOS のフォントデータを取得する
;;; @fn get_font_adr(adr);
;;; @param (adr) フォントアドレス格納位置
;;; @return void


get_font_adr:
    ;; スタックフレームの構築
    push bp
    mov bp, sp

    ;; レジスタの保存
    push ax
    push bx
    push si
    push es
    push bp

    ;; 引数を取得
    mov si, [bp + 4]

    ;; フォントアドレスの取得
    mov ax, 0x1130
    mov bh, 0x06                ; 8x16 font (vga/mcga)
    int 10h                     ; ES:BP = font address

    ;; フォントアドレスを保存
    mov [si + 0], es            ; dst[0] = segment;
    mov [si + 2], bp            ; dst[1] = offset;

    ;; レジスタの復帰
    pop bp
    pop es
    pop si
    pop bx
    pop ax

    ;; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret
