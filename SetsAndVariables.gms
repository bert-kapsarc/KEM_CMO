Sets i generators       /fringe, g1*g4/
     h technology       /CCGT, GT, ST, Nuclear/
     l market segment   /l1*l8/
     seasons  /winter,summer,spring-fall/
     e(seasons) season /summer/
     winter(seasons) /winter/
     spring(seasons) /spring-fall/
     summer(seasons) /summer/
     fall(seasons) /spring-fall/

     m(l) capacity market /l5*l7/
     s scenarios        /s1*s2/
     r regions          /COA,EOA,SOA,WOA/



Alias (h,hh), (i,j), (m,mm), (r,rr);

alias (l,ll), (i,ii), (s,ss), (h,hh), (r,rr);

variables
         inv(i,h,r)  investment by player i in technology h
         ret(i,h,r)  retirement of technology h in region r by player i

         Cap_avail(i,h,r) available capacity of player i of technolgy h in region r in MW
         Q(i,h,r,e,l,s)  generation quantity from a player i at market l in scenario in MW
         sales(i,r,e,l,s) sales of firm in region r market l scenario s in MW
         lambda_high(i,h,r,e,l,s) shadow prices for the high capacity constraint in USD per  MWh
         lambda_low(i,h,r,e,l,s)  shadows prices for low constraint in USD per  MWh
         delta(r,e,m)   shadow prices for the capacity market in USD per  MW per hour
         price(r,e,l,s) energy price in USD per MWh
         price_trans(r,rr,e,l,s) tranmission price in USD per MWh
         alpha(i,h,r) shadow prices for the non-negative investment constraints in USD per  MW
         eta_high(i,h,r) shadow prices for the capacity retirment constraint in USD per  MW
         eta_low(i,h,r)

         arbitrage(r,rr,e,l,s) TSO arbitrage between regions r and rr  in MW
         trade(i,r,rr,e,l,s) electricity trade by firm i between regions r and rr in market segment l  in MW
         trans(r,rr,e,l,s) electricity trade by firm i between regions r and rr in market segment l  in MW

         tau(r,rr,e,l,s) shadow prices for the high capacity constraint in USD per MW
         shadows_trans_low(r,rr,e,l,s) shadow prices for the no-negative transmission constriant in USD per MW
         zeta(i,r,rr,e,l,s) shadow prices for the high capacity constraint in USD per MW
         shadows_arb(r,rr,e,l,s) shadow prices for no-negative arbitrage constriant in USD per MW

         shadows_trans_balance(r,rr,e,l,s) shadow prices for transmission demand balance constraint
         ;

positive variables lambda_high, lambda_low,  alpha,
                   eta_high,eta_low,
                   tau,shadows_trans_low,
                   zeta,shadows_arb,shadows_trans_balance
*                   Q,inv,ret,trade,arbitrage,trans
                   ;
