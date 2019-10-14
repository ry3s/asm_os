    %include "../include/define.s"
    %include "../include/macros.s"

    ORG KERNEL_LOAD

    [BITS 32]
;;;
;;; エントリポイント
;;;
kernel:
    ;; 処理の終了
    jmp     $                   ; while (1);
;;;
;;; padding
;;;
    times   KERNEL_SIZE - ($ - $$)  db  0 ; padding
