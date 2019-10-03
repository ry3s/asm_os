%macro cdecl 1-*.nolist
    %rep %0 - 1
    push %{-1:-1}
    %rotate - 1
    %endrep
    %rotate -1
    call %1

    %if 1 < %0
    add sp, (__BITS__ >> 3) * (%0 - 1)
    %endif
%endmacro

    struc drive
    .no reww 1                  ; dirve number
    .cyln reww 1                ; cylinder
    .head reww 1                ; head
    .sect reww 1                ; sector
    endstruc
