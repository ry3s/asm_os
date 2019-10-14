;;; セクタ読み込み(LBA指定)
;;; 事前にドライブパラメータを取得しておく
;;; @fn word read_lba(drive, lba, sect, dst);
;;; @param (lba) LBA
;;; @param (sect) 読み出しセクタ数
;;; @param (dst) 読み出し先アドレス
;;; @return 読み込んだセクタ数
read_lba:
    ;; START
    push    bp                  ;   +10| dst
    mov     bp, sp              ;   + 8| sect num
                                ;   + 6| LBA(2 byte)
                                ;   + 4| drive info
                                ;------+------------
                                ;   + 2| IP
                                ; BP+ 0| BP
                                ;------+------------
    push    si


    ;; BODY
    mov     si,     [bp + 4]        ; SI = drive info;
    ;; LBA -> CHS
    mov     ax,     [bp + 6]        ; AX = LBA;
    cdecl lba_chs, si, .chs, ax     ; lba_chs(drive, .chs, AX);

    ;; copy drive number
    mov     al,     [si + drive.no] ;
    mov     [.chs + drive.no],  al  ; drive number

    ;; read sector
    cdecl read_chs, .chs, word [bp + 8], word [bp + 10]
                                ; AX = read_chs(.chs, sect number, ofs);

    ;; FINISH
    pop     si

    mov     sp,     bp
    pop     bp


    ret

    ALIGN 2
    .chs: times drive_size   db  0       ; 読み込みセクタに関する情報
