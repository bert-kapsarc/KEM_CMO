Sets
     company /fringe, g1*g4/
     i(company) generators       /fringe,g1*g4/
     Genco(company) /g1*g4/

     fringe(company)     /fringe/
     tech       /CCGT, GT, GTtoCC, ST, Nuclear, all/
     h(tech) technology       /CCGT, GT, GTtoCC, ST, Nuclear/
     gttocc(h) /GTtoCC/
     gt(h) /GT/
     ccgt(h) /CCGT/
     st(h) /ST/
     nuclear(h) /nuclear/
     l market segment   /l1*l8/
     seasons  /winter,summer,spring-fall/
*     e(seasons) seasons for running the model /summer/
     e(seasons) seasons for running the model /winter,summer,spring-fall/
     winter(seasons) /winter/
     spring(seasons) /spring-fall/
     summer(seasons) /summer/
     fall(seasons) /spring-fall/
     r regions          /COA,EOA,SOA,WOA/

     m(r,e,l) capacity markets
     scen /s1*s10/

     s(scen) scenarios for energy demand        /s1*s5/
     ss(scen) scenarios for renewables       /s1*s2/

     oli(genco,r)

;
         oli("g1","COA") = yes;
         oli("g2","SOA") = yes;
         oli("g3","EOA") = yes;
         oli("g4","WOA") = yes;


Alias (h,hh), (i,j), (r,rr);


alias (l,ll), (i,ii), (h,hh), (r,rr,rrr), (e,ee), (Genco,GGenco);;

*   intialze capacity market in select segements
    m(r,e,'l5') =  yes;
    m(r,e,'l6') =  yes;
    m(r,e,'l7') =  yes;


variables
         inv(company,h,r)  investment by player i in technology h
         ret(company,h,r)  retirement of technology h in region r by player i
         kind(company,h,r) existing capacity by player

         Cap_avail(company,h,r) available capacity of player i of technolgy h in region r in MW
         Q(company,h,r,seasons,l,s,ss)  generation quantity from a player i at market l in scenario in MW
         sales(company,r,seasons,l,s,ss) sales of firm in region r market l scenario s in MW
         lambda_high(company,h,r,seasons,l,s,ss) shadow prices for the high capacity constraint in USD per  MWh
         lambda_low(company,h,r,seasons,l,s,ss)  shadows prices for low constraint in USD per  MWh
         delta(r,seasons,l)   shadow prices for the capacity market in USD per  MW per hour
         price(r,seasons,l,s,ss) energy price in USD per MWh
         price_trans(r,rr,seasons,l,s,ss) tranmission price in USD per MWh
         alpha(company,h,r) shadow prices for the non-negative investment constraints in USD per  MW
         eta_high(company,h,r) shadow prices for the capacity retirment constraint in USD per  MW
         eta_low(company,h,r)

         arbitrage(r,rr,seasons,l,s,ss) TSO outgoing electricity arbitrage from node r on line n
         trade(company,r,rr,seasons,l,s,ss) outgoing electricity trade by firm i from node r on line n
         trans(r,rr,seasons,l,s,ss) electricity trans by on line n
         tau_pos(r,rr,seasons,l,s,ss) shadow prices for the high capacity constraint in USD per MW
         tau_neg(r,rr,seasons,l,s,ss) shadow prices for the high capacity constraint in USD per MW
         zeta(company,r,rr,seasons,l,s,ss) shadow prices for the outgoing no-negative trade constraint in USD per MW
         shadows_arbitrage(r,rr,seasons,l,s,ss) shadow prices for no-negative incoming arbitrage constriant in USD per MW
         shadows_gttocc(company,r) shadows on upper bound of GT conversion USD per MW
         shadows_inv_cap(company,r)
         shadows_prod_cap(company,r)
         shadows_genco_ppa(h,r) shadows on the lower bound for the gencos aggregate prodction

          price_trans_pos(r,rr,seasons,l,s,ss)
           price_trans_neg(r,rr,seasons,l,s,ss)

          shadows_trans_pos(r,rr,seasons,l,s,ss)
          shadows_trans_neg(r,rr,seasons,l,s,ss)
          ;

positive variables lambda_high, lambda_low,  alpha,
                   eta_high,eta_low, psi
                   tau,zeta,shadows_arbitrage,shadows_trans,shadows_gttocc
                   tau_pos,tau_neg,shadows_inv_cap,shadows_prod_cap,shadows_genco_ppa,
                   shadows_trans_pos,shadows_trans_neg
                   ;
