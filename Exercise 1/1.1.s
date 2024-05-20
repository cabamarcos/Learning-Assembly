.main: 
jal ArrayCompare
move ... $v0
...
syscall
ArrayCompare: li $t0 0 #cont
			  li $t1 0 #rep
			  li $t3 8 #N
              li $t4 1 #usamos para numSeguidos=1
              li $t5 2 #i necesita parametro
while1:bge 
	   li $t2 0 #numSeguidos
       addi $s0 $t3 -1 #len(a)-1
       bge $t3, $s0 then
else:  move $t0 $t3
	   b end
then:  addi $t3 $t3 1

end:   #if A[cont] == x: 
	   move $t2 $t4
while2:bge #A[cont+1]== x: end2
	   addi $t0 $t0 1
       addi $t2 $t2 1
end2:  blt $t2 $t5 end3
       addi $t1 $t1 1  
       
end3: # if i<=0 or N<=0:  
      #  return -1
    #else:
     #   info = "(0,",rep,')'
      #  return info
jr $ra
