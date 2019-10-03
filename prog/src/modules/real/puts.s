;;; 文字列の表示
;;; @fn puts(str);
;;; @param str the address of string
;;; @return nothing

puts:
    ;; スタックフレームの構築
    push bp
    mov bp, sp
    ;; レジスタの保存
    push ax
    push bx
    push si

    mov si, [bp + 4]            ; SI = the address of string

    ;; 関数本体
    mov ah, 0x0E
    mov bx, 0x0000

    cld                         ; DF = 0;
                                ; do {
    .10L:                       ;    AL = *SI++;
    lodsb                       ;    if (0 == AL) break;
                                ;    Int10(0x0E, AL);
    cmp al, 0                   ; } while(1);
    je .10E

    int 0x10
    jmp .10L

    .10E:
    ;; レジスタの復帰
    pop si
    pop bx
    pop ax
    ;; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret
