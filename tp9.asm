global main
extern puts
extern sscanf
extern fread
extern fopen
extern fclose
extern printf

section .data
    nameTramos                             db "tramos.dat",0
    regEstaciones                          dw 0
    nameEst                                db "estaciones.dat",0
    regTramos           times 0            db ""
        fil     dw 0
        col     dw 0
    idEstaciones                           dq 0
    idTramos                               dq 0
    modo                                   db "rb",0
    errorEst                               db "No se pudo abrir el archivo de estaciones.",0
    errorTramos                            db "El archivo de tramos no pudo ser abierto.",0
    tramos              times 400          dw 0 ;acá guardo la info leida del registro
    lineas              times 400          dw 0 ;acá voy guardando las líneas
    filActual                              dw 1
    colActual                              dw 1
    posAnteriores       times 100          dw 0
    maxEstaciones                          dw 0
    msjResult                              db "Linea %c: ",0
    format                                 dw "%hi ",0
    tope                                   dw 0
    filasVisitadas      times 100          dw 1,0
    maxEstResult                           db "La maxima estacion especificada es %hi",10,0
    aux                                    dw 0
    iguales                                db ' ';S o N
    valido                                 db ' ';S o N
    idEst                                  dw 65
section .bss

section .text
main:

    call openFileEst
    cmp rax,0
    jle errOpenEst

leerEstaciones:
    mov qword[idEstaciones],rax
    jmp readEstaciones

leerTramos:
    call openFileTramos
    cmp rax,0
    jle errOpenTramos
    mov qword[idTramos],rax

    call printMaxEst

    jmp readTramos

procesarDatos:
    call listarLineas

    call printResult

endProgram:
    ret

errOpenEst:
    mov rcx,0
    mov rcx,errorEst
    sub rsp,32
    call puts
    add rsp,32
    
    jmp endProgram ;si no pude leer un máximo de estaciones no puedo hacer nada
    
errOpenTramos:
    mov rcx,0
    mov rcx,[idEstaciones]
    sub rsp,32
    call fclose
    sub rsp,32

    mov rcx,0
    mov rcx,errorTramos
    sub rsp,32
    call puts
    add rsp,32

    jmp endProgram ;si no pude abrir el archivo de tramos no puedo hacer nada

openFileEst:
    mov rax,0
    mov rcx,0
    mov rdx,0

    mov rcx,nameEst
    mov rdx,modo
    sub rsp,32
    call fopen
    add rsp,32

    ret

openFileTramos:
    mov rax,0
    mov rcx,0
    mov rdx,0

    mov rcx,nameTramos
    mov rdx,modo
    sub rsp,32
    call fopen
    add rsp,32

    ret


readEstaciones:
    mov rax,0
    mov rcx,0
    mov rdx,0
    mov r8,0
    mov r9,0

    mov rcx,regEstaciones
    mov rdx,2
    mov r8,1
    mov r9,[idEstaciones]
    sub rsp,32
    call fread
    add rsp,32

    cmp rax,0
    jle closeFileEst

    call valEst
    cmp byte[valido],'N'
    je readEstaciones

    call definirMaxEst
    
    jmp readEstaciones

closeFileEst:
    mov rcx,0
    mov rcx,[idEstaciones]
    sub rsp,32
    call fclose
    add rsp,32

    jmp leerTramos

readTramos:
    mov rax,0
    mov rcx,0
    mov rdx,0
    mov r8,0
    mov r9,0

    mov rcx,regTramos
    mov rdx,4
    mov r8,1
    mov r9,[idTramos]
    sub rsp,32
    call fread
    add rsp,32

    cmp rax,0
    jle closeFileTramos

    cmp byte[valido],'N'
    je readTramos

    call actualizarMatriz
    ;Intercambio la fila y la columna para poder llenar la matriz y que sea
    ;simétrica, sino mi algoritmo no funcionaría
    call intercambiarFilCol

    call actualizarMatriz

    jmp readTramos

closeFileTramos:
    mov rcx,0
    mov rcx,[idTramos]
    sub rsp,32
    call fclose
    add rsp,32

    jmp procesarDatos

actualizarMatriz:
    call calcDesplaz

    mov rcx,0
    mov cx,1
    mov word[tramos+rax],cx

    ret

calcDesplaz:
    mov rbx,0
    mov rax,0
    mov ax,word[fil]
    cwde
    cdqe
    mov rbx,rax
    mov rax,0
    mov ax,word[col]
    cwde
    cdqe
    dec rbx      ;fila - 1
    dec rax      ;columna - 1
    imul rbx,40    ;(fila - 1) * 40 -> cada elemento es de 2 bytes y son 20 elementos    
    imul rax,2    ;(columna - 1) * 2 -> cada elemento es de 2 bytes
    add rax,rbx   ;tengo el desplazamiento en ax

    ret

valTramos:
    cmp word[fil],1
    jl invalido
    cmp word[fil],20
    jg invalido
    cmp word[col],1
    jl invalido
    cmp word[col],20
    jg invalido
    mov rcx,0
    mov cx,word[col]
    cmp cx,word[fil] 
    je invalido    ;las estaciones no deben unirse consigo mismas

    mov byte[valido],'S'
    ret

valEst:
    cmp word[regEstaciones],1
    jl invalido
    cmp word[regEstaciones],20
    jg invalido

    mov byte[valido],'S'
    ret

invalido:
    mov byte[invalido],'N'
    ret

definirMaxEst:
    mov rcx,0
    mov cx,[regEstaciones]
    cmp cx,[maxEstaciones]
    jg changeMaxEst

    ret

changeMaxEst:
    mov [maxEstaciones],cx

    ret


printMaxEst:
    mov rcx,0
    mov rdx,0
    mov rcx,maxEstResult
    mov dx,[maxEstaciones]
    sub rsp,32
    call printf
    add rsp,32

    ret

intercambiarFilCol:    
    mov rcx,0
    mov cx,[col]
    mov [aux],cx ;aux = col
    mov rcx,0
    mov cx,[fil]
    mov [col],cx ;col = fil
    mov rcx,0
    mov cx,[aux]
    mov [fil],cx ;fil = aux = col

    ret
    
listarLineas:
    mov r10,0 ;para las posiciones anteriores
    mov r11,0
    mov r11,2 ;para las filas visitadas

recorrerMatriz:
    ;Recorro la matriz de tramos, empiezo en (1,1)
    mov rcx,0
    mov cx,[filActual]
    mov [fil],cx

    mov rcx,0
    mov cx,[colActual]
    mov [col],cx
    call calcDesplaz

    mov [aux],cx
    call verFilVisitadas
    cmp byte[iguales],'S'
    je actIteradores

    cmp word[tramos+rax],1
    je  actLineas

;    Estoy en (1,3)
;    Filas visitadas = 1
;    3 es la próxima fila a visitar
;    3 esta en filas visitadas?
;    no, entonces actualizo lineas
;    Estoy en (3,1)
;    Filas visitadas = {1,3}
;    1 está en filas visitadas?
;    Si, entonces no actualizo las líneas

actIteradores:
    inc word[colActual]
    mov rcx,0
    mov cx,word[maxEstaciones]
    cmp [colActual],cx
    jg  retornar

    jmp recorrerMatriz

retornar:
    cmp r10,0 ;ver si hay posAnteriores -> r10 = 0 implica que no hay posAnteriores
    je  avanzarEnFila ;no hay posAnteriores, avanzo en la fila, para esto debo ver qué fila debo visitar
    sub r10,2
    mov rcx,0
    mov cx,[posAnteriores+r10]
    mov [colActual],cx
    mov word[posAnteriores+r10],0
    sub r10,2
    mov r10,0
    mov cx,[posAnteriores+r10]
    mov [filActual],cx
    mov word[posAnteriores+r10],0
    
    jmp actIteradores

actLineas:
    cmp word[posAnteriores],0
    jne actFila

    mov rcx,0
    mov cx,[filActual]
    mov [fil],cx
    mov word[col],1

    jmp incCol

actFila:
    mov rcx,0
    mov cx,[posAnteriores]
    mov [fil],cx
    mov word[col],1

incCol:
    call calcDesplaz
    cmp word[lineas+rax],0
    je  addLinea
    inc word[col]
    mov rcx,0
    mov cx,word[col]
    cmp cx,word[maxEstaciones] ;col - maxEstaciones <= 0 -> col <= maxEstaciones
    jle incCol

addLinea:
    mov rcx,0
    mov cx,[colActual]
    mov [lineas+rax],cx

actualizarPos:
    mov rcx,0
    mov cx,[colActual]
    mov [filasVisitadas+r11],cx
    add r11,2
    mov rcx,0
    mov cx,[filActual]
    mov [posAnteriores+r10],cx
    add r10,2
    mov rcx,0
    mov cx,[colActual]
    mov [posAnteriores+r10],cx
    add r10,2
    mov [filActual],cx
    mov word[colActual],0

    jmp actIteradores

avanzarEnFila:
    mov rcx,0
    mov cx,[filActual]
    mov [aux],cx
    call verFilVisitadas
    cmp byte[iguales],'S' ;esto significaría que ya visité la fila
    je sigFila            ;como ya visité la fila,avanzo

    mov rcx,0                   ;si llegué acá es porque no son iguales
    mov cx,[filActual]
    mov [filasVisitadas+r11],cx
    add r11,2
    mov word[colActual],1
    mov rax,0
    mov ax,2
    imul word[maxEstaciones]
    cmp r11,rax
    jl recorrerMatriz   ;r11 es el tope de las filas visitadas, si tope filas visitadas < maxEstaciones * 2 aun no visité todas las filas

sigFila:
    inc word[filActual]
    mov rcx,0
    mov cx,[filActual]
    cmp cx,[maxEstaciones] ;filActual - maxEstaciones <= 0 -> filActual <= maxEstaciones
    jle avanzarEnFila

finListado:
    ret

verFilVisitadas:
    mov rbx,0

procesarFilas:
    mov rcx,0
    cmp word[filasVisitadas+rbx],0
    je  finRecorrido
    mov cx,word[filasVisitadas+rbx]
    cmp cx,[aux]
    jne avanzar

    mov byte[iguales],'S'
    ret

incIterador:
    add rbx,2
    jmp verFilVisitadas

avanzar:
    add bx,2
    jmp procesarFilas

finRecorrido:
    mov byte[iguales],'N'
    ret

printResult:

    mov word[fil],1
    mov word[col],0

recorrerLineas:

avanzarCol:
    inc word[col]
    mov rcx,0
    mov cx,[col]
    cmp cx,[maxEstaciones]
    jle cmpContenido

avanzarFil:
    mov word[col],1
    inc word[fil]
    mov rcx,0
    mov cx,[fil]
    cmp cx,[maxEstaciones]
    jg  endPrinting

cmpContenido:   
    call calcDesplaz
    cmp word[lineas+rax],0
    jne  avanzarCol

    dec word[col]
    mov rcx,0
    mov cx,[col]
    mov [tope],cx
    mov word[col],1

    cmp word[tope],0
    je avanzarFil

print:
    mov rcx,0
    mov rdx,0
    mov rcx,msjResult
    mov dx,[idEst]
    sub rsp,32
    call printf
    add rsp,32

    mov rcx,0
    mov rdx,0
    mov rcx,format
    mov dx,[fil]
    sub rsp,32
    call printf
    add rsp,32
    
    inc word[idEst]
printLinea:
    call calcDesplaz
    
    mov rcx,0
    mov rdx,0
    mov rcx,format
    mov dx,[lineas+rax]
    sub rsp,32
    call printf
    add rsp,32

    inc word[col]
    mov rcx,0
    mov cx,[col]
    cmp cx,[tope] ;col - tope <= 0 -> col <= tope
    jg  avanzarFil
    
    jmp printLinea

endPrinting:
    ret