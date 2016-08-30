********************************************************************************
*        MACROS for KEM
********************************************************************************

*        Time dependant discount factor
$MACRO   discfact(i,t)                   1/(1+i)**(ord(t)-1)

*        sum of discount factors over lifetime T of capital
$MACRO   sumdiscfact(T,i,n)              sum(n$(ord(n)<=T),discfact(i,n))

*        Numerator of discounting coefficients
*        Accounts for recursive dynmic solves when size of t greater than tt
*        Consider final time period of tt to be a long term static solution
$MACRO   intdiscfact(i,t,tt) sum(tt$(ord(tt)>=ord(t)),1/(1+i)**(ord(tt)-ord(t)))

$MACRO   discounting(Time,i,n,t,tt)    intdiscfact(i,t,tt)/sumdiscfact(Time,i,n)

$MACRO   addmethane(x,y,z)               x+y*(1-1e-3)+z
