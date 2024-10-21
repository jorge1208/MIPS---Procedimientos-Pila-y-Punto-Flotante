.data
array:      .word 5, 9, 1, 7, 3  # Nuestro array de ejemplo
array_len:  .word 5              # Longitud del array

.text
.globl main
main:
    # Inicializamos registros y cargamos la longitud del array
    la $t0, array             # Cargar la dirección base del array en $t0
    lw $t1, array_len         # Cargar la longitud del array en $t1 (n)

    move $t2, $zero           # $t2 será el índice inicial (0)

    # Bucle externo para la ordenación por selección
sort_loop:
    sub $t3, $t1, $t2         # Número de elementos restantes a ordenar (n - i)
    blez $t3, end_sort        # Si ya no quedan elementos, salir

    # Llamar a la subrutina max para encontrar el valor máximo
    move $a0, $t0             # Base del array en $a0
    move $a1, $t2             # Índice inicial (i) en $a1
    move $a2, $t1             # Índice final (n) en $a2
    jal max                   # Llamada a la subrutina max

    # Intercambiar el valor máximo con el valor en la posición final
    sll $v1, $v1, 2           # Multiplicar la posición por 4 (tamaño de palabra)
    add $v1, $t0, $v1         # Obtener la dirección del valor máximo
    lw $t4, 0($v1)            # Cargar el valor máximo en $t4
    lw $t5, 0($t0)            # Cargar el valor actual en la posición inicial
    sw $t4, 0($t0)            # Colocar el valor máximo en la posición inicial
    sw $t5, 0($v1)            # Colocar el valor original en la posición del máximo

    addi $t0, $t0, 4          # Avanzar el índice del array
    addi $t2, $t2, 1          # Incrementar el índice

    j sort_loop               # Repetir el bucle

end_sort:
    # Terminar el programa
    li $v0, 10
    syscall

# Subrutina para encontrar el máximo en el array
# Entrada: $a0 = base del array, $a1 = índice inicial, $a2 = índice final
# Salida:  $v0 = valor máximo, $v1 = posición del valor máximo
max:
    add $t6, $a0, $a1         # Dirección inicial del array
    lw $t7, 0($t6)            # Cargar el primer valor como el máximo
    move $t8, $a1             # Inicializar la posición del máximo
    move $v0, $t7             # Inicializar el valor máximo
    move $v1, $a1             # Inicializar la posición del máximo

max_loop:
    addi $a1, $a1, 1          # Incrementar el índice
    bge $a1, $a2, end_max     # Si hemos alcanzado el final, salir

    sll $t9, $a1, 2           # Multiplicar el índice por 4
    add $t6, $a0, $t9         # Obtener la dirección del siguiente elemento
    lw $t7, 0($t6)            # Cargar el siguiente valor

    ble $t7, $v0, max_loop    # Si el valor no es mayor, continuar
    move $v0, $t7             # Actualizar el valor máximo
    move $v1, $a1             # Actualizar la posición del máximo

    j max_loop                # Repetir el bucle

end_max:
    jr $ra                    # Regresar al llamador
