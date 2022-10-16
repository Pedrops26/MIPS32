.data
archivo_entrada: .asciiz "mips/fraseseningles.txt"

archivo_salida:  .asciiz "mips/frasesordenadaseningles.txt"

buffer: .space 4000	#Buffer guarda lo que hay en el archivo texto

buffer2: .asciiz "Ingrese el separador de frases en su texto de entrada: \n"

buffer3: .space 1	#Guarda el n�mero m�ximo de caracteres

.align	2
vector1: .space 4000	#Guardo las direcciones de cada frase (primer caracter)

.text

la $s3, vector1		#Guardo el vector1 en s3
addi $sp, $sp, -4000	#Reservo espacio en stack
move $t3, $sp		#Guardo la direcci�n principal del stack en t3

#Syscall Open File (entrada)
li $v0, 13				#Seleccionar el syscall (abrir archivo)
la $a0, archivo_entrada			#Guardo el buffer donde tengo el texto
li $a1, 0				#Bandera = 0 Leer  = 1 Escribir
li $a2, 0				#
syscall					#Cierra, guarda todo
move $s0, $v0				#Retorna la direccion que esta en $v0

#EL ARCHIVO EST� ABIERTO

#Guardar buffer en programa
li $v0, 14				#Seleccionar el syscall
move $a0, $s0				#Retorna la direcci�n que est� en $s0 
la $a1, buffer				#todo lo que se lee queda en Buffer y se guarda en $a1 #la direcciones, li datos
li $a2, 4000				#tama�o maximo caracteres en el texto
syscall					#Retorna variable con numero -> cuantas letras hay en el txt
move $s1, $v0				# $s1 guarda cu�ntas letras hay en el texto
move $t1, $a1				#Copio la direcci�n del buffer a t1

sw $a1, 0($sp)				#Guardo la direccion del primer caracter de la primer frase en stack

#PREGUNTAR AL USUARIO
li $v0, 4				#Seleccionar el syscall
la $a0, buffer2				#Direcci�n del texto a mostrar
syscall

#LEER LO DEL USUARIO
li $v0, 8				#Seleccionar el syscall
la $a0, buffer3				#Se guarda lo que el usuario ingres�
li $a1, 3				#Se guarda el m�ximo n�mero de caracteteres
syscall
move $a3, $a0				#Copio a0 en a3

#GUARDAR EL SEPARADOR DE FRASES
lb $s2, 0($a0)				#Guardo el ASCII del caracter separador en los registros
move $a2, $t1				#Muevo la direcci�n del buffer en a2
move $a1, $t1				#Muevo la direcci�n del buffer a t1
add $a1, $a1, $s1			#Le sumo el # de caracteres al buffer para que no se sobreescriba encima

#GUARDAR EN REGISTROS Y LUEGO EN MEMORIA LOS CARACTERES
for:
lb $s0, 0($a2)				#Guardo en registro el caracter le�do
sb $s0, 0($a1)				#Guardo en memoria el caracter leido
j suma					#Salto hacia la funci�n suma

#AVANZAR DE CARACTER EN EL TEXTO DE ENTRADA 
suma:
addi $a1, $a1, 1		#Avanzo en el espacio en memoria para escribir
addi $a2, $a2, 1		#Avanzo en el texto
addi $t0, $t0, 1		#Contador para saber cuando se llega al final del texto
beq $s0, $s2, contador_frases	#Si el caracter leido es punto, salto a la funcion que cuenta el numero de frases
bne $s1, $t0, for		#Compara el contador con el # total de caracteres

#CONTAR # DE FRASES
contador_frases:
addi $t2, $t2, 1		#Contador de frases +1
jal for_stack			#salto al ciclo for para el stack
beq $s1, $t0, comparar		#Compara si ya se leyeron todos los caracteres del texto
j for				#Regreso al ciclo for

#CARGAR LA DIRECCI�N DEL PRIMER CARACTER DE CADA FRASE EN PILA
for_stack:
addi $sp, $sp, 4		#Avanzo 4 posiciones en la pila
sw $a2, 0($sp)			#Guardo en stack la direcci�n del caracter siguiente al punto
jr $ra				#Retorno a la funci�n

#COMPARAR CARACTERES
comparar:		#s5 con direccion s0, s6 con direccion s2
move $a3, $t3		#Pongo en un registro address la direcci�n de la pila
lw $s0, 0($a3)		#Guardo en un argumento la direcci�n guardada en la n posici�n del stack
addi $t3, $t3, 4	#Avanzo en la pila 4 bytes
move $a3, $t3		#Muevo a un argumento la direcci�n del stack
lw $s2, 0($a3)		#Guardo en registro la direcci�n guardada en la n posici�n del stack

#CARGAR CARACTERES EN REGISTRO
guardar_char:				
move $a0, $s0		#Muevo la direcci�n de la frase 1 hacia un argumento
lb $s5, 0($a0)		#Cargo en registro el primer caracter en la direcci�n 1
move $a0, $s2		#Muevo la direcci�n de la frase 2 hacia un argumento
lb $s6, 0($a0)		#Cargo en registro el primer caracter en la direccion 2

bne $s5, $s6, comparar_mayor #Si los dos caracteres son diferentes, salto a la funcion que compara cu�l es mayor y cu�l es menor
beq $s5, $s6, avanzar_char	#Si los dos caracteres son iguales, salto a la funcion que avanza al segundo caracter de ambas frases

#AVANZAR DE CARACTER EN LAS FRASES
avanzar_char:
addi $s0, $s0, 1	#Avanzo un byte en la direcci�n de la frase 1
addi $s2, $s2, 1	#Avanzo un byte en la direcci�n de la frase 2
addi $t8, $t8, 1	#Contador para el # de bytes en los que se avanz� en ambas frases
j guardar_char		#Salto a la funci�n que guarda los caracteres

#COMPARAR CARACTERES
comparar_mayor:
bgt $s5, $s6, switch	#Si el ASCII del caracter de la frase 1 es mayor al de la frase 2, salto a la funci�n switch
blt $s5, $s6, Exit	#Si no, salgo de las funciones para escribir en el texto de salida

#INTERCAMBIA CARACTERES
switch:
move $t5, $s0		#Muevo la direcci�n de la frase 1 a un temporal t5
move $t6, $s2		#Muevo la direcci�n de la frase 2 a un temporal t6
move $s0, $t6		#Muevo la direcci�n de la frase 2 al registro donde estaba la direcci�n de la frase 1
move $s2, $t5		#Muevo la direcci�n de la frase 1 al registro donde estaba la direcci�n de la frase 2

#GUARDAR EN PILA EL NUEVO ORDEN DE LAS DIRECCIONES DE LAS FRASES
move $sp, $a3		#Retomo la direcci�n principal de la pila
sw $s0, 0($sp)		#Cargo en la primer direcci�n de pila la nueva frase 1
sw $s2, 4($sp)		#Cargo en la segunda direcci�n de pila la nueva frase 2

#VERIFICAR SI EL APUNTADOR EST� EN LA PRIMER POSICI�N DE LA DIRECCI�N QUE SE VA A USAR
ret_y_escribir:
la $a1, buffer		#Retomo la direcci�n donde est� guardado el buffer
move $s0, $a0		#Copio la direcci�n del buffer en un registro
bne $t8, $zero, retroceder_char	#Si el contador de # de bytes es diferente de cero, salto a la funci�n que regresa el apuntador a la primer posici�n de cada frase
beq $t8, $zero, escribir	#Si el contador de # de bytes es igual a cero, salto a la funci�n que escribe las frases ordenadas en el archivo de salida

#RETROCEDER EL APUNTADOR
retroceder_char:
sub $a0, $a0, 1		#Regreso un byte en la direcci�n de la frase 1
sub $a1, $a1, 1		#Regreso un byte en la direcci�n de la frase 2
sub $t8, $t8, 1		#Resto 1 al contador del # de bytes que se avanzaron en cada frase
bne $t8, $zero, retroceder_char	#Si el contador es diferente de cero repito esta funci�n, si no paso a escribir

#ESCRIBIR LAS FRASES EN EL NUEVO ORDEN EN MEMORIA 
escribir:
lb $s5, 0($a0)		#Cargo en registro el primer byte le�do en la direcci�n a0
sb $s5, 0($a1)		#Cargo en memoria en la direcci�n de a1 el primer byte le�do en la direcci�n a0
addi $a0, $a0, 1	#Avanzo un byte en la direcci�n a0 para leer el siguiente byte
addi $a1, $a1, 1	#Avanzo un byte en la direcci�n a1 para guardar el byte en la siguiente posici�n
addi $t4, $t4, 1	#Contador de caracteres escritos en el archivo de salida
beq $t4, $s1, Exit	#Si el contador es igual al numero de caracteres del archivo de entrada, salto a escribir en el archivo de salida
j escribir		#Regreso a esta funci�n misma

Exit:
#Syscall Open File (salida)
li $v0, 13				#Seleccionar el syscall
la $a0, archivo_salida			#Guardo el buffer donde tengo el texto
li $a1, 1				#Bandera = 0 Leer  = 1 Escribir
li $a2, 0				#
syscall					#Cierra, guarda todo
move $s2, $v0				#$s2 se guarda la direccion del archivo donde se va a escribir

#pasar del buffer al txt
li $v0, 15				#Seleccionar el syscall
move $a0, $s2				#Retorna la direccion del archivo de escritura #Move para otra variable
la $a1, buffer				#Buffer -> ah� est� lo que voy a escribir en archivo_salida
move $a2, $s1				#N�mero de caracteres que se van a escribir
syscall


#LO DE TXT SE GUARDO EN EL BUFFER Y SE GUARDO EN EL TXT NUEVO


#Cierra los archivos (se guarda lo que se hizo)
li $v0, 16
move $a0, $s0				#Cierre el archivo de lectura
syscall

li $v0, 16				#Cierre el archivo de escritura
move $a0, $s2
syscall

li $v0, 17				#Cierra el sistema (17 -> cierra y guarda)
syscall
