# -*- coding: utf-8 -*-
"""
Created on Fri Oct  1 12:06:44 2021

@author: Helena Gonzalez


"""
A=[7,3,7,7,0,1,7,7,7,6,5,2,7,7,7]
def ArrayCompare(A, N, x, i):
    cont=0
    rep=0
    #we go throught all the list
    while cont<N-1:
        numSeguidos=0
        if cont<len(A)-1:
            cont+=1
        else:
            cont=N-1
        if A[cont] == x:
            numSeguidos=1
          
            while cont < N-1 and A[cont+1]== x :
                cont+=1
                numSeguidos+=1
        # if I have at least i repetitions of the number
        if numSeguidos>=i:
            rep+=1 
    
    if i<=0 or N<=0:
        return -1
    else:
        info = 0,rep
        return info
    
a=ArrayCompare(A, 15, 7, 2)
print (a)
