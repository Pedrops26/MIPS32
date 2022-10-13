.data
archivo_entrada: .asciiz "fraseseningles.txt"

archivo_salida:  .asciiz "frasesordenadaseningles.txt"

buffer: .space 4000	#Buffer guarda lo que hay en el archivo texto

buffer2: .asciiz "Ingrese el separador de frases en su texto de entrada: \n"

buffer3: .space 1	#Guarda el número máximo de caracteres

.align	2
vector1: .space 4000	#Guardo las direcciones de cada frase (primer caracter)

.text

la $s3, vector1

#Syscall Open File (entrada)
li $v0, 13				#Seleccionar el syscall (abrir archivo)
la $a0, archivo_entrada			#Guardo el buffer donde tengo el texto
li $a1, 0				#Bandera = 0 Leer  = 1 Escribir
li $a2, 0				
syscall					#Cierra, guarda todo
move $s0, $v0				#Retorna la direccion que esta en $v0

#EL ARCHIVO ESTÁ ABIERTO

#Guardar buffer en programa
li $v0, 14				#Seleccionar el syscall
move $a0, $s0				#Retorna la dirección que está en $s0 
la $a1, buffer				#todo lo que se lee queda en Buffer y se guarda en $a1 #la direcciones, li datos
li $a2, 4000				#tamaño maximo caracteres en el texto
syscall					#Retorna variable con numero -> cuantas letras hay en el txt
move $s1, $v0				# $s1 guarda cuántas letras hay en el texto
move $t1, $a1
#PREGUNTAR AL USUARIO

li $v0, 4				#Seleccionar el syscall
la $a0, buffer2				#Dirección del texto a mostrar
syscall

#LEER LO DEL USUARIO

li $v0, 8				#Seleccionar el syscall
la $a0, buffer3				#Se guarda lo que el usuario ingresó
li $a1, 3				#Se guarda el máximo número de caracteteres
syscall
move $a3, $a0

lb $s2, 0($a0)				#Guardo el ASCII del caracter separador en los registros
move $a2, $t1				#Muevo la dirección del buffer en a2
move $a1, $t1				#Muevo la dirección del buffer en a2
add $a1, $a1, $s1			#Le sumo el # de caracteres al buffer para que no se sobreescriba encima

for:
lb $s0, 0($a2)
jal guardar_direccion
sb $s0, 0($a1)
j suma

suma:
addi $a1, $a1, 1
addi $a2, $a2, 1
addi $t0, $t0, 1
beq $s0, $s2, contador_frases
bne $s1, $t0, for

contador_frases:
addi $t2, $t2, 1
j for

guardar_direccion:
la $a2, 0($s3)
addi $s3, $s3, 1
jr $ra

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
la $a1, buffer				#Buffer -> ahí está lo que voy a escribir en archivo_salida
move $a2, $s1				#Número de caracteres que se van a escribir
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
