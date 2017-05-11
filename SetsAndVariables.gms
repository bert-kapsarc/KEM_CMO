Sets
     firm /fringe, g1*g15/
     Genco(firm) /g1*g2/
     i(firm) generators  /g1*g2/

     Cournot(i) cournot firms /g1*g2/

     fringe(firm)     /fringe/
     tech       /CCGT, CCconv, GT, ST, Nuclear, PV, WT,GTtoCC, all/
     h(tech) technology       / CCGT, GT, ST, GTtoCC, Nuclear, PV, WT /
     o reliability option /o1,o2/
     ccgt(tech) /CCGT/
     gttocc(tech) /GTtoCC/
     gt(tech) /GT/
     st(tech) /ST/
     nuclear(tech) /nuclear/
     PV(tech) /PV/
     WT(tech) /WT/
     ren(tech) /WT,PV/


     l market segment   /l1*l8/
     seasons  /winter,winter-wknd,summer,summer-wknd,spring-fall,spf-wknd/
*     e(seasons) seasons for running the model /winter,summer,spring-fall/
     e(seasons) seasons for running the model /summer/
     e_wkdy(seasons) /winter,summer,spring-fall/
     e_wknd(seasons) /winter-wknd,summer-wknd,spf-wknd/
     winter(seasons) /winter,winter-wknd/
     spring(seasons) /spring-fall,spf-wknd/
     summer(seasons) /summer,summer-wknd/
     fall(seasons) /spring-fall,spf-wknd/

     f fuels /u-235, methane, oil, ren/
     oil_gas(f) /methane, oil/
     oil(f) /oil/

     r regions /COA,EOA,SOA,WOA/
     coa(r) /COA/

     m(r,e,l) capacity markets
     scen /s1*s10/

     s(scen) scenarios for energy demand        /s1*s1/
     ss(scen) scenarios for renewables       /s1*s1/

     majority(genco,r)

;
         loop(genco,
                 majority(genco,r)$(ord(r) = ord(genco)) = yes;
         );


Alias (h,hh), (r,rr), (e,ee), (o,oo);


alias (l,ll), (i,ii), (h,hh), (r,rr,rrr), (e,ee), (Genco,GGenco), (seasons,sseasons);;

      m(r,e,l) = no;

variables



         Cap_avail(i,h,r) available capacity of player i of technolgy h in region r in MW
         M_p(o,r,e,l,s,ss) call option impact on the generators revenues
                 price(r,e,l,s,ss) energy price in USD per MWh
         delta(o,r,e,l) prices for the capacity or reliability options market in USD per  MW per hour
         price_trans(r,rr,e,l,s,ss) tranmission price in USD per MWh
         profit(i)
         arb_profit

         kind(firm,h,r) existing capacity by player
         trans(r,rr,e,l,s,ss) electricity transmission

         demand(r,e,l,s,ss)
;
Positive Variables
         Q(i,h,f,r,e,l,s,ss)  generation quantity from a player i at market l in scenario in MW
         inv(i,h,r)  investment by player i in technology h
         ret(i,h,r)  retirement of technology h in region r by player i
         sales(i,o,r,e,l,s,ss) sales of firm in region r market l scenario s in MW

         U(i,r,e,l,s,ss) residual sales not bound to an option contract
         K(i,o,r,e,l) Capacity sold into the reliabilty options contract


         Z(o,r,e,l,s,ss) Non-negative difference between market and exercise price (P_cap)

         arbitrage(r,rr,e,l,s,ss) TSO outgoing electricity arbitrage from node r on line n
         trade(i,r,rr,e,l,s,ss) outgoing electricity trade by firm i from node r on line n
         trans(r,rr,e,l,s,ss) electricity trans by on line n

         tau_pos(r,rr,e,l,s,ss) shadow prices for the high capacity constraint in USD per MW
         tau_neg(r,rr,e,l,s,ss) shadow prices for the high capacity constraint in USD per MW


         Omega(o,r,e,l,s,ss)
         Gamma(i,r,e,l,s,ss)
;
Variables

         lambda_high(firm,h,r,seasons,l,s,ss) shadow prices for the high capacity constraint in USD per  MWh
         lambda_low(firm,h,f,r,seasons,l,s,ss)  shadows prices for low constraint in USD per  MW
         alpha(firm,h,r) shadow prices for the non-negative investment constraints in USD per  MW
         eta_high(firm,h,r) shadow prices for the capacity retirment constraint in USD per  MW
         eta_low(firm,h,r) dual vairable for the non-negativity of retirements

         shadows_existing_capacity(h,r)
         shadows_fuel_alloc(f,r)

         mu_high(firm,r,seasons,l,s,ss) upper bound on U
         mu_low(firm,r,seasons,l,s,ss) non-negativity of U

         psi_high(firm,e,l)  dual variable for the constraint on how much capacity a firm can bid into the option
         psi_low(firm,r,e,l) non-negativity of K

         shadows_K(firm,r,seasons,l)
         shadows_arbitrage(r,rr,seasons,l,s,ss) shadow prices for no-negative incoming arbitrage constriant in USD per MW
         shadows_gttocc(firm,r) shadows on upper bound of GT conversion USD per MW
         shadows_inv_cap(firm,r)
         shadows_prod_cap(firm,r)
         shadows_genco_ppa(h,r) shadows on the lower bound for the gencos aggregate production


         zeta(firm,h,r,rr,seasons,l,s,ss) shadow prices for the outgoing no-negative trade constraint in USD per MW

         shadows_trans_pos(r,rr,seasons,l,s,ss)
         shadows_trans_neg(r,rr,seasons,l,s,ss)

         price_trans_pos(r,rr,seasons,l,s,ss)
         price_trans_neg(r,rr,seasons,l,s,ss)
          ;

positive variables lambda_high, lambda_low,  alpha
                   eta_high,eta_low
                   tau,zeta,shadows_arbitrage,shadows_trans,shadows_K,
                   shadows_gttocc,
                   shadows_inv_cap,shadows_prod_cap,shadows_genco_ppa,
                   shadows_trans_pos,shadows_trans_neg,shadows_existing_capacity,
                   shadows_fuel_alloc,mu_high,mu_low
;
