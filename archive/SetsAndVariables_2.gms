Sets i generators       /fringe, g1*g4/
     h technology       /CCGT, GT, ST, Nuclear/
     l market segment   /l1*l8/
     seasons  /winter,summer,spring-fall/
*     e(seasons) seasons for running the model /summer/
     e(seasons) seasons for running the model /winter,summer,spring-fall/
     winter(seasons) /winter/
     spring(seasons) /spring-fall/
     summer(seasons) /summer/
     fall(seasons) /spring-fall/

     m(l) capacity market /l5,l6/
     s scenarios        /s1/
     r regions          /COA,EOA,SOA,WOA/
     n power_lines      /East,South,west/
                                         ;

*     m(l) = no;

*     e(seasons)=yes;

Alias (h,hh), (i,j), (m,mm), (r,rr);

alias (l,ll), (i,ii), (s,ss), (h,hh), (r,rr,rrr), (e,ee);

variables
         inv(i,h,r)  investment by player i in technology h
         ret(i,h,r)  retirement of technology h in region r by player i

         Cap_avail(i,h,r) available capacity of player i of technolgy h in region r in MW
         Q(i,h,r,seasons,l,s)  generation quantity from a player i at market l in scenario in MW
         sales(i,r,seasons,l,s) sales of firm in region r market l scenario s in MW
         lambda_high(i,h,r,seasons,l,s) shadow prices for the high capacity constraint in USD per  MWh
         lambda_low(i,h,r,seasons,l,s)  shadows prices for low constraint in USD per  MWh
         delta(r,seasons,l)   shadow prices for the capacity market in USD per  MW per hour
         price(r,seasons,l,s) energy price in USD per MWh
         price_trans(n,seasons,l,s) tranmission price in USD per MWh
         price_trans_pos(n,r,seasons,l,s) tranmission price in USD per MWh
         price_trans_neg(n,r,seasons,l,s) tranmission price in USD per MWh
         alpha(i,h,r) shadow prices for the non-negative investment constraints in USD per  MW
         eta_high(i,h,r) shadow prices for the capacity retirment constraint in USD per  MW
         eta_low(i,h,r)

         arbitrage(n,r,rr,seasons,l,s) TSO outgoing electricity arbitrage from node r on line n
         trade(i,n,r,rr,seasons,l,s) outgoing electricity trade by firm i from node r on line n
         trans(n,seasons,l,s) electricity trans by on line n

         tau(n,seasons,l,s) shadow prices for the high capacity constraint in USD per MW
         psi(n,seasons,l,s),
         shadows_trans_low(n,seasons,l,s) shadow prices for the no-negative transmission constriant in USD per MW
         zeta(i,n,r,rr,seasons,l,s) shadow prices for the outgoing no-negative trade constraint in USD per MW
         shadows_arbitrage(n,r,rr,seasons,l,s) shadow prices for no-negative incoming arbitrage constriant in USD per MW
         shadows_trans(n,seasons,l,s) shadow prices for the positive transmission constriant in USD per MW
          ;

positive variables lambda_high, lambda_low,  alpha,
                   eta_high,eta_low, psi
                   tau,zeta,shadows_arbitrage,shadows_trans
*                   ,trans,arbitrage
*                   Q,inv,ret,trade,arbitrage,trans
*                 trans_pos,trans_neg
                   ;
