; AdFlt2 *unpacker*  (c) DarkGrey
;
                model   tiny
                .code
                .startup
                .486
                jumps
start:
;-------- Show (c)
                mov     ah, 09h
                mov     dx, offset msg
                int     21h
;------
                mov     si, 81h
                lodsb
                cmp     al, 0dh
                je      usage_
;------
                xor     ax, ax
                mov     si, 80h
                lodsb
                add     si, ax
                mov     [sh], al
                xchg    si, di
                mov     al, 00h
                stosb
;---------
                mov     si, 82h
                mov     dx, si
;---------
                mov     ah, 09h
                mov     dx, offset pf
                int     021h
;---------
                mov     ah, 40h
                xor     ch, ch
                mov     cl, [sh]
                mov     bx, 1
                mov     dx, 82h
                int     021h
;--------- Open file
                mov     ah, 3dh
                mov     dx, 82h
                xor     al, al
                int     21h
                mov     [hr], ax
                jc      errs
;----- Find file size
                mov     ax, 4202h
                xor     cx, cx
                xor     dx, dx
                mov     bx, [hr]
                int     21h
                jc      errs
;----
                mov     [f_s], ax
;---- Set pointer to begin
                mov     ax, 4200h
                xor     cx, cx
                xor     dx, dx
                mov     bx, [hr]
                int     21h
                jc      errs
;------ Read from file
                mov     ah, 3fh
                mov     dx, offset buffer
                mov     cx, [f_s]
                mov     bx, [hr]
                int     21h
                jc      errs
;----- Close file
                mov     ah, 3eh
                mov     bx, [hr]
                int     21h
                jc      errs
;-----
                mov     di, offset buffer
                mov     si, di
                lodsw
                cmp     ax, 0068h
                jne     not_adl
;-----
                std
                mov     di, offset buffer
                mov     si, di
                add     si, [f_s]
                sub     si, 2
                lodsw
                mov     bp, ax
;-
                std
                mov     si, offset buffer
                add     si, [f_s]
                sub     si, 4
                mov     di, si
                mov     cx, [f_s]
                sub     cx, 49h
@@0:
                lodsw
                xor     ax, bp
                xor     word ptr [si], ax
                dec     cx
                jz      nd
                loop    @@0
nd:
;-
                mov     si, offset buffer-9
                add     si, [f_s]
                lodsw
                mov     cx, ax
                cld
                mov     di, offset buffer
                mov     si, offset buffer+014Bh-100h
                repe    movsb
@@4:
                mov     si, offset buffer
                sub     cl, cl
;-
@@2DE:
                lodsb
                add     cl, al
                cmp     si, offset buffer+0489h-100h
                jb      @@2DE
;-hash
                mov     ax, word ptr ds:[buffer+04A9h-100h]
                imul    ax, ax, 0421h
                add     al, cl
                ror     ax, cl
                imul    ax, ax, 0429h
                add     al, cl
                ror     ax, cl
                imul    ax, ax, 0451h
                add     al, cl
                ror     ax, cl
                imul    ax, ax, 045Dh
                add     al, cl
                ror     ax, cl
                sub     cl, cl
                xor     al, ah
                mov     dl, al
;-
                mov     cx, [f_s]
                sub     cx, 4eah
                mov     [n_f_s], cx
;-
                cld
                mov     di, offset buffer+3d5h
                mov     si, di
@@1:
                lodsb
                add     al, dl
                stosb
                loop    @@1
;-
w_t:
                cld
                mov     di, 82h
                xor     ax, ax
                mov     cx, 0ffffh
                repne   scasb
                mov     byte ptr [di-4], 'u'
                mov     byte ptr [di-3], 'n'
                mov     byte ptr [di-2], 'p'
;------------ Create file
                mov     ah, 3ch
                mov     dx, 82h
                xor     cx, cx
                int     21h
                jc      errs
;----- Write file , unpacked code
                mov     [hw], ax
                mov     ah, 40h
                mov     dx, offset buffer +3d5h
                mov     cx, [n_f_s]
                mov     bx, [hw]
                int     21h
                jc      errs
;--- Close file
                mov     ah, 3eh
                mov     bx, [hw]
                int     21h
                jc      errs
;---
                mov     dx, offset cm
                call    write
                mov     ah, 40h
                mov     bx, 1
                mov     dx, 82h
                mov     cl, [sh]
                xor     ch, ch
                int     21h
                int     20h
;-----
write:
                mov     ah, 09h
                int     21h
                ret
;-
errs:
                mov     dx, offset errs_
                call    write
                jmp     ext
;-
not_adl:
                mov     dx, offset nc_
                call    write
                jmp     ext
;-
usage_:
                mov     dx, offset usage
                call    write
;-
ext:
                mov     ah, 4ch
                int     21h
;-
msg             db      , 13, 10, 'AdFlt 2 by EliCZ@post.cz *unpacker* (c) DarkGrey //[DTG]', 13, 10, 13, 10, '$'
usage           db      'Usage: unadflt.com packed.com', 13, 10, '$'
nc_             db      , 13, 10, 'This file is not crypted with AdFlt 2', 13, 10, '$'
pf              db      'Unpacking file: $'
cm              db      , 13, 10, 'Completed !', 13, 10
                db      'Result in: $'
errs_           db      'I/O Error !', 13, 10, '$'
f_s             dw      0
n_f_s           dw      0
hr              dw      0
hw              dw      0
sh              db      0
buffer          db      ?
                end