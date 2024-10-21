.text
.globl __start
__start:
    # Pedir el grado del polinomio (n)
    li $v0, 5              # Syscall para leer un entero
    syscall
    move $t0, $v0          # Guardar el grado n en $t0

    # Reservar memoria para los coeficientes (n + 1 coeficientes)
    addi $a0, $t0, 1       # Número de coeficientes = n + 1
    li $v0, 9              # Syscall para asignar memoria
    syscall
    move $s0, $v0          # Guardar la dirección base en $s0

    # Leer los coeficientes del polinomio (enteros)
    li $t1, 0              # Inicializar índice a 0
read_coeffs:
    bge $t1, $a0, read_x   # Si hemos leído todos los coeficientes, ir a leer x
    li $v0, 4              # Syscall para imprimir mensaje
    la $a0, msg_coeff      # Mensaje "Ingrese coeficiente"
    syscall

    li $v0, 5              # Syscall para leer un entero (coeficiente)
    syscall
    sw $v0, 0($s0)         # Guardar el coeficiente en la memoria
    addi $s0, $s0, 4       # Mover el puntero a la siguiente dirección
    addi $t1, $t1, 1       # Incrementar el índice
    j read_coeffs          # Repetir

read_x:
    # Leer el valor de x (en formato float)
    li $v0, 6              # Syscall para leer un valor flotante
    syscall
    mov.s $f2, $f0         # Guardar x en $f2

    # Evaluar el polinomio con coeficientes enteros
    li.s $f0, 0.0          # Inicializar acumulador a 0
    move $s0, $v0          # Resetear la dirección base de los coeficientes
    move $t1, $t0          # Inicializar contador para grado

eval_poly:
    bltz $t1, print_result # Si el grado es negativo, ir a imprimir el resultado
    lw $t2, 0($s0)         # Cargar el coeficiente en $t2 (entero)
    mtc1 $t2, $f4          # Mover el coeficiente a un registro flotante
    cvt.s.w $f4, $f4       # Convertir el coeficiente a punto flotante

    # Calcular el término: coef * x^t1
    mov.s $f6, $f2         # Guardar x en $f6
    li $t3, 1              # Inicializar el contador de potencia
power_loop:
    beqz $t1, no_power     # Si la potencia es 0, saltar
    mul.s $f6, $f6, $f2    # Multiplicar x por sí mismo
    subi $t1, $t1, 1       # Reducir la potencia
    j power_loop
no_power:
    mul.s $f6, $f6, $f4    # Multiplicar el coeficiente por x^t1
    add.s $f0, $f0, $f6    # Acumular el valor en el resultado

    addi $s0, $s0, 4       # Mover al siguiente coeficiente
    subi $t1, $t1, 1       # Decrementar el grado
    j eval_poly

print_result:
    # Imprimir el resultado final
    li $v0, 4              # Syscall para imprimir mensaje
    la $a0, msg_result     # Mensaje "El resultado es: "
    syscall

    li $v0, 2              # Syscall para imprimir valor flotante
    mov.s $f12, $f0        # Mover el resultado final a $f12
    syscall

    # Terminar el programa
    li $v0, 10
    syscall

.data
    msg_coeff:  .asciiz "Ingrese coeficiente: "
    msg_x:      .asciiz "Ingrese el valor de x: "
    msg_result: .asciiz "El resultado es: "
