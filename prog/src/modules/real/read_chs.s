;;; セクタ読み出し関数
;;; @fn read_chs(drive, sect, dst);
;;; @param drive the address of drive struct
;;; @param sect the number of read sectors
;;; @param dst the address of destination
;;; @return the number of sectors that read

read_chs:
    ;; スタックフレームの構築
    push bp                     ;    + 8| dst
    mov bp, sp                  ;    + 6| num sectors
    push 3                      ;    + 4| param buff
    push 0                      ; ------+------------
                                ;    + 2| IP
                                ; BP + 0| BP
                                ;-------+-------------
                                ;    - 2| retry = 3;
                                ;    - 4| sect = 0;

    ;; レジスタの保存
    push bx
    push cx
    push dx
    push es
    push si

    ;; 処理の開始
    mov si, [bp + 4]            ; SI = SRC buff

    ;; CX レジスタの設定
    mov ch, [si + drive.cyln + 0] ; CH = clynder number
    mov cl, [si + drive.cyln + 1] ; CL = clynder number
    shl cl, 6                     ; CL <<= 6
    or cl, [si + drive.sect]      ; CL |= sector number

    ;; セクタ読み込み
    mov dh, [si + drive.head]   ; DH = head number
    mov dl, [si + 0]            ; DL = drive number
    mov ax, 0x0000              ; AX = 0x0000
    mov es, ax                  ; ES = segment
    mov bx, [bp + 8]            ; BX = dst

    .10L:
    mov ah, 0x02
    mov al, [bp + 6]

    int 0x13
    jnc .11E

    mov al, 0
    jmp .10E

    .11E:
    cmp al, 0
    jne .10E

    mov ax, 0
    dec word [bp - 2]
    jnz .10L

    .10E:
    mov ah, 0

    ;; レジスタの復帰
    pop si
    pop es
    pop dx
    pop cx
    pop bx


    ;; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret
