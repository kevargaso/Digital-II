.equ DIV_BASE,   0x430000  
.equ DIV_OP_A,   0x04
.equ DIV_OP_B,   0x08
.equ DIV_INIT,   0x0C
.equ DIV_RESULT, 0x10
.equ DIV_DONE,   0x14


.section .text
.globl div
.globl div_hw
# a0 / a1
div:
  addi sp,sp,-8        # save a3, a4, a5 on the stack
  sw   a3,0(sp) 
  sw   a2,1(sp) 
  
  mv    a2, a1
  mv    a1, a0         # a1/a2
  li    a0, -1
  beqz  a2, .L5        # division by 0 exit return -1
  li    a3, 1          # store current bit
  bgeu  a2, a1, .L2    # divisor > dividend ?
.L1:
  blez  a2, .L2        # divisor < 0 ? return 0
  slli  a2, a2, 1      # shift divisor until divisor > dividend
  slli  a3, a3, 1      # Store number of shifts
  bgtu  a1, a2, .L1    # dividend > divisor ?
.L2:
  li    a0, 0          # quotient = 0
.L3:
  bltu  a1, a2, .L4    # dividend < divisor?
  sub   a1, a1, a2     # dividend = dividend - divisor
  or    a0, a0, a3     
.L4:
  srli  a3, a3, 1      # 
  srli  a2, a2, 1
  bnez  a3, .L3        # a3 = 0? corrimiento de todos lis bits
.L5:
  lw   a3,0(sp) 
  lw   a2,1(sp) 
  addi sp,sp,8      
  ret
# a0 / a1
div_hw:
  li  gp, DIV_BASE # cargar base del divisor hardware
  sw  a0, DIV_OP_A(gp) # guardar dividendo
  sw  a1, DIV_OP_B(gp) # guardar divisor
  li  a0, 1 #cargar el valor 1 en a0 para iniciar la division
  sw  a0, DIV_INIT(gp)
  sw  zero, DIV_INIT(gp)
  .L0:
     li  t0, 1
     lw  t1, DIV_DONE(gp)
     and t1, t1, t0
     beqz  t1, .L0
     lw  a0, DIV_RESULT(gp)
    ret








  
#a1      a2      a3   a0
#1010   0010     1     0
#1010   0100    10     0
#1010   1000   100     0
#1010  10000  1000     0

#1010   1000   100     0
#0010   1000   100   100
#0010   0100   010   100

#0010   0010   001   100
#0000   0010   001   101

#0000   0001   000   101


