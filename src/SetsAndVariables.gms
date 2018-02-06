Sets
     firm /fringe, g1*g15/
     Genco(firm)      /g1*g4/
     i(firm) generators  /fringe,g1*g4/

     Cournot(i) cournot firms

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
     e(seasons) seasons for running the model /winter,winter-wknd,summer,summer-wknd,spring-fall,spf-wknd/
*     e(seasons) seasons for running the model /summer/
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
     n power lines /COA_EOA,COA_WOA,SOA_WOA/

     m(r,e,l) capacity markets
     scen /s1*s10/

     s(scen) scenarios for energy demand        /s1*s7/
     ss(scen) scenarios for renewables       /s1/
     dir /p,m/
     majority(genco,r)

;
         loop(genco,
                 majority(genco,r)$(ord(r) = ord(genco)) = yes;
         );


Alias (h,hh), (r,rr), (e,ee), (o,oo);


alias (l,ll), (i,ii), (h,hh), (r,rr,rrr), (e,ee), (Genco,GGenco), (seasons,sseasons);;

      m(r,e,l) = no;

variables



         Cap_avail(i,tech,r) available capacity of player i of technolgy h in region r in MW
         M_p(o,r,e,l,s,ss) call option impact on the generators revenues
         price(r,e,l,s,ss) energy price in USD per MWh
         delta(o,r,e,l) prices for the capacity or reliability options market in USD per  MW per hour
         price_trans(r,e,l,s,ss) tranmission price in USD per MWh
         profit(i)
         arb_profit(e,l,s,ss)
         iso_profit(e,l,s,ss)

         kind(firm,tech,r) existing capacity by player
         trans(r,e,l,s,ss) electricity transmission

         arbitrage(r,e,l,s,ss) incoming (pos) and outgoing (neg) electricity arbitrage from node r on line n
         demand(r,e,l,s,ss)
         demand_capacity(tech,r)

         DEq5_2(r,e,l,s,ss)

;
Positive Variables
         Q(i,tech,f,r,e,l,s,ss)  generation quantity from a player i at market l in scenario in GW
         inv(i,tech,r)  investment by player i in technology tech in GW
         ret(i,tech,r)  retirement of technology h in region r by player i in GW
         sales(i,o,r,e,l,s,ss) sales of each firm in region r market l scenario s in GW
         DEQ5_3(n,e,l,s,ss,dir)
         DEQ5_4(n,e,l,s,ss,dir)

         total_sales(r,e,l,s,ss)

         K(i,o,r,e,l) Capacity sold into the reliabilty options contract

         U(i,r,e,l,s,ss) residual sales not bound to an option contract
         Z(i,o,r,e,l,s,ss) Non-negative difference between market and exercise price (P_cap)
         Zm(i,o,r,e,l,s,ss)

         Omega(i,o,r,e,l,s,ss)
         Gamma(i,r,e,l,s,ss)

         transn(n,e,l,s,ss,dir)
;