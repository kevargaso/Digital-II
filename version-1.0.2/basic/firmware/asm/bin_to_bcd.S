.equ BCD_BASE,    0x440000
.equ BCD_INPUT,   0x04      
.equ BCD_INIT,    0x08      
.equ BCD_RESULT,  0x0C      
.equ BCD_DONE,    0x10

.section .text
.globl bin_to_bcd
.globl bin_to_bcd_hw
# a0 binary number
bin_to_bcd:

# Double Dabble algorithm enter 16 bits out 5 decimal digits
# Binary Number on a1, results on a1
  addi sp,sp,-28        # save ra, a2, a3, a4, a5 on stack. 5(sp) = var tmp
  sw   t0,0(sp) 
  sw   t1,4(sp)
  sw   t2,8(sp) 
  sw   t3,12(sp)
  sw   t5,16(sp) 
  sw   t6,20(sp)  
  sw   ra,24(sp)
  mv   a1, zero
  li   t6, 1
  slli t6, t6, 15    # Bit counter 16 bits
    
.L0:               
# shift left {a1, a0}
  slli a1,a1,1       #
  li   t1,0x03       # Number to add on each iteration
  li   t2,0x05       # Number to add on each iteration   
  li   t3,0x0F       # BCD mask 

  li   t0,1
  slli t0,t0,15      # 
  and  t0,t0,a0
  beqz t0, .L1       # (MSB)A0  = 1
  add  a1,a1,1
.L1:
  slli a0,a0,1       #
  srli t6, t6, 1     # Update bit counter
  beqz t6, .L6       # print result
.L11:
# check if each BCD digit <= 5 and add 3 if apply
  and  t0, a1, t3    #
  bge  t0, t2, .L2   #
  j    .L3 
.L2:
  add  t0, t0, t1    # 
  and  t0, t0, t3    # remove extra bits if overflow
# update a1
  mv   t5, zero
  addi t5, t5, -1    # t5 = 0xFFFFFFFF
  xor  t5, t3, t5    # t5 = 0xfffffff0 (only in first iteration, then ff0f, f0ff, 0fff, etc)
  or   t0, t0, t5    # t0 = 0xfffffffN (only in first iteration, then ffnf, fnff, nfff, etc)
  or   a1, a1, t3    # a1 = 0xkkkkkkkF
  and  a1, a1, t0    # a1 = 0xKKKKKKKN (only in first iteration, then kkFk, kFkk, Fkkk, etc)
.L3:
  slli t1, t1, 4     # Next BCD Number
  slli t2, t2, 4     #
  slli t3, t3, 4     #
  beqz t3,.L0  #
  j    .L11 


# Print result
.L6:
  li   t3, 0x8       # 2 ^ bits to send  
.L5:
  mv   t0, a1
  srli t0, t0, 12
  andi t0, t0, 0x0F
  addi t0, t0, 0x30
  mv   a0, t0
  call putchar
  slli a1, a1, 4
  srli t3, t3, 1
  beqz t3, .PC0
  j    .L5
.PC0: 
  li   a0,0xA
  call putchar
  li   a0,0x0D
  call putchar   
 
  lw   t0,0(sp) 
  lw   t1,4(sp)
  lw   t2,8(sp) 
  lw   t3,12(sp)
  lw   t5,16(sp) 
  lw   t6,20(sp)   
  lw   ra,24(sp)
  addi sp,sp,28        # save a3, a4, a5 on the stack
  
  ret




bin_to_bcd_hw:
  li  gp, BCD_BASE          # Cargar la dirección base del periférico BIN2BCD
  sw  a0, BCD_INPUT(gp)     # Guardar el número binario de entrada
  li  a0, 1                 # Cargar el valor 1 en a0 para iniciar la conversión
  sw  a0, BCD_INIT(gp)      # Iniciar la conversión
  sw  zero, BCD_INIT(gp)    # Desactivar la señal de inicio
  
.L0_bcd:
  li  t0, 1                 # Constante para verificar el bit DONE
  lw  t1, BCD_DONE(gp)      # Cargar el registro de estado
  and t1, t1, t0            # Verificar si DONE está activo
  beqz t1, .L0_bcd          # Si DONE=0, seguir esperando
  
  lw  a0, BCD_RESULT(gp)    # Cargar el resultado BCD en a0
  
  # Guardar registros en el stack antes de imprimir
  addi sp, sp, -28          # Reservar espacio en el stack
  sw   t0, 0(sp) 
  sw   t1, 4(sp)
  sw   t2, 8(sp) 
  sw   t3, 12(sp)
  sw   t5, 16(sp) 
  sw   t6, 20(sp)   
  sw   ra, 24(sp)
  
  # Print result
  mv   a1, a0               # Mover el resultado BCD a a1 para impresión
.L6_bcd:
  li   t3, 0x8              # 2 ^ bits to send  
.L5_bcd:
  mv   t0, a1
  srli t0, t0, 12
  andi t0, t0, 0x0F
  addi t0, t0, 0x30
  mv   a0, t0
  call putchar
  slli a1, a1, 4
  srli t3, t3, 1
  beqz t3, .PC0_bcd
  j    .L5_bcd
.PC0_bcd: 
  li   a0, 0xA
  call putchar
  li   a0, 0x0D
  call putchar   
 
  # Restaurar registros del stack
  lw   t0, 0(sp) 
  lw   t1, 4(sp)
  lw   t2, 8(sp) 
  lw   t3, 12(sp)
  lw   t5, 16(sp) 
  lw   t6, 20(sp)   
  lw   ra, 24(sp)
  addi sp, sp, 28           # Restaurar el stack pointer
  
  lw   a0, BCD_RESULT(gp)   # Restaurar el resultado BCD en a0 para el retorno
  ret                       # Retornar


