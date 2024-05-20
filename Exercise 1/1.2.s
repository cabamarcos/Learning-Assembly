.data  

A: .word 7,3,6,6,0,1,6,6,4,5,6,6,6,6,7,5,3,4,5,6,7,8,9,7,6,5,4,6,6
num_string: .word 29
x: .word 6 #number to be found
rep: .word 2

mat: .word 2, 3, 0, 4, 5, 8, 3 
	 .word 3, 0, 3, 3, 3, 0, 9
     .word 3, 3, 8, 9, 6, 7, 4
     .word 3, 0, 3, 3, 0, 9, 8
     
rows: .word 4
cols: .word 7
number: .word 3
repet: .word 2


.text

main:
#arraycompare
la $a0 A
lw $a1 num_string
lw $a2 x #number to be found
lw $a3 rep
jal arraycompare
#print 0
move $a0 $v0 
li $v0 1
syscall 
move $a0 $v1 #print result of the first function
syscall 

#matrixcompare
#we add the parameters
la $a0 mat
lw $a1 rows
lw $a2 cols
lw $a3 number
lw $t0 repet


#as the data in the temporal register can get lost, we have to store it in the stack
sub $sp $sp 4
sw $t0 ($sp)
#call de function
jal matrixcompare
lw $t0 ($sp) #restore the parameter
addi $sp $sp 4 #meterlo en el stack



move $a0 $v0
li $v0 1
syscall #print 0
move $a0 $v1
syscall #print second function result

li $v0 10 #exit
syscall 

arraycompare:
  # $a0 initial address of the stack
  # $a1 length of the string 
  # $a2 number to be found
  # $a3 number of repetititions needed
  
  #stack frame
  sub $sp $sp 24
  sw $ra ($sp)
  sw $s0 4($sp)
  sw $s1 8($sp)
  sw $s2 12($sp)
  sw $s3 16($sp)
  sw $s4 20($sp)
  
  #li $s5 0 #counter for number of elements
  li $s3 0 #temporal result of function,0 by default
  #errors#
  ble $a1 0 enderror #we see if nº of elem in array <=0 --> return -1
  ble $a3 0 enderror #i<=0 --> return -1
  
  li $s0 0 #loop counter
  move $s1 $a0 #adress of current elem in array (ponter only)
  li $s2 0 #nº of consecutive appereances of integer in $a2
  li $s4 0 #temporal error of function, 0 by default
  
  loop1:
  	bgeu $s0 $a1 end1 #counter>=nº elem in array
    
    #save $a0 & $a1
    sub $sp $sp 16
    sw $a0 ($sp)
    sw $a1 4($sp)
    sw $a2 8($sp)
    sw $a3 12($sp)
    ##compare
    #lw $s3 ($s0)
    #lw $s5 ($s2) #bigcounter
    #bne $s3 $a2 end2 # comparar el elemento que buscamos con el elemento actual
    
    #using cmp library
    lw $a0 ($s1) #current elem in array
    move $a1 $a2 #integer we search
    #we pass them as parameters
    jal cmp
    
    lw $a0 ($sp)
	lw $a1 4($sp)
    lw $a2 8($sp)
    lw $a3 12($sp)
    add $sp $sp 16
    #finish the library
    
    beqz $v0 end3 #if it is equal to 0, means that $a0 and $a1 are diffferent
    #we add 1 in nº of consecutive aparitions 
    add $s2 $s2 1
    b nextelement

    end3:
    	#so as there is not any repeated value, we reset it
        li $s2 0
        b continue
                
    nextelement:
  		#go to the next element, but first we have to compare if nº of consecutive apeareances and 
        #nº of min occurences is the same
        #we save the registers to work with them 
        sub $sp $sp 16
        sw $a0 ($sp)
        sw $a1 4($sp)
        sw $a2 8($sp)
        sw $a3 12($sp)
        
        move $a0 $a3	# pass min number of occurrrences as parameter
        move $a1 $s2	# pass number of consecutive appearances as parameter
        #move $a0 $v0 #current elem
        #lw $a1 4($a0) #next element
        jal cmp #if eq then $v0==1
        
        #load reg
        lw $a0 ($sp)
        lw $a1 4($sp)
        lw $a2 8($sp)
        lw $a3 12($sp)
        add $sp $sp 16
        
        beqz $v0 continue
        addi $s3 $s3 1 #add 1 to temp result
        
        continue:
        add $s0 $s0 1 #loop repetition counter +1
        add $s1 $s1 4 #next elem of array
        b loop1
        
    	#add $a0 $a0 4  
    	#add $s2 $s2 4    
        #add $s5 $s5 4 #add 1 position to the counter 
        #b loop1
enderror:
  	  li $s4 -1 #if there is an error, the function will return -1
      li $v0 -1
      
      lw $ra ($sp)
      lw $s0 4($sp)
      lw $s1 8($sp)
      lw $s2 12($sp)
      lw $s3 16($sp)
      lw $s4 20($sp)
      add $sp $sp 24
      
      jr $ra #return
  #errors#
end1: move $v0 $s4 #if errors this is -1, if not 0
	  move $v1 $s3 #temporal result(nº of repetitions of x i times)
      
      lw $ra ($sp)
      lw $s0 4($sp)
      lw $s1 8($sp)
      lw $s2 12($sp)
      lw $s3 16($sp)
      lw $s4 20($sp)
      add $sp $sp 24
      
      jr $ra #return
      
matrixcompare:
  #$a0 matrix address
  #$a1 number of rows
  #$a2 number of columns
  #$a3 number to be found
  #$a4 repetitions
  
  #stack frame
  sub $sp $sp 28
  sw $ra ($sp)
  sw $s0 4($sp)
  sw $s1 8($sp)
  sw $s2 12($sp)
  sw $s3 16($sp)
  sw $s4 20($sp)
  sw $s5 24($sp)
  
  li $s2 0 #result
    
  #errors
  blez $a1 enderror2 #rows <=0 --> -1
  blez $a2 enderror2 #cols <=0 --> -1
  blez $a3 enderror2 #num searched <=0 --> -1

  li $s0 0 #row counter
  li $s4 0 #error
  lw $s5 28($sp) #min num of occurrences
  mul $s3 $a2 4 #nº bytes per row
  move $s1 $a0 #address of row
  
loop2:	bge $s0 $a1 end #if row counter >= nº rows, you have gone trough all the matrix
		#STACK FUNCTION 
        sub $sp $sp 16
        sw $a0 ($sp)
        sw $a1 4($sp)
        sw $a2 8($sp)
        sw $a3 12($sp)
		
        move $a0 $s1 #current row address
        #as we can put the rest of parameters as actual parameters, we don't have to use the stack anymore to store them
        move $a1 $a2 #number col   
        move $a2 $a3 #int searched
        move $a3 $s5 #number of consecutive ocurrences
        #We have to put it this way because in array compare we defined the reg $a like this
        
        jal arraycompare #invoke function
        add $s2 $s2 $v1 #add nº of rep in that row
        
        #Load registers
        lw $a0 ($sp)
        lw $a1 4($sp)
        lw $a2 8($sp)
        lw $a3 12($sp)
        add $sp $sp 16
        
        # finish function
        # UPDATE VALUES
        add $s0 $s0 1 #increase loop counter
        add $s1 $s1 $s3 #$s1 es el adress de mi matrix y le añado el numero de elementos que tenga cada row para poder pasar a la siguiente 
        b loop2 #I continue until the numbre of row counter is bigger or equal than the actual number of rows
enderror2:
  li $s4 -1 #error
end:  #This values have to be returned
      move $v0 $s4 #if error return -1, if not, 0
      move $v1 $s2 #temporal result 
      #stack frame      
      lw $ra ($sp)
      lw $s0 4($sp)
      lw $s1 8($sp)
      lw $s2 12($sp)
      lw $s3 16($sp)
      lw $s4 20($sp)
      lw $s5 24($sp)  
      addi $sp $sp 28

      jr $ra #return
