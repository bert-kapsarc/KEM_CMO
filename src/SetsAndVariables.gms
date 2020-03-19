Sets
    firm /fringe, g1*g4/
    Genco(firm)      /g1*g4/
    i(firm) generators  /fringe,g1*g4/

    Cournot(i) cournot firms

    fringe(firm)     /fringe/
    tech       /CCGT, CCGT1, CCGT2, CCGT3, GT, GT1, GT2, GT3, ST, ST1, Nuclear, PV, WT,GTtoCC, all/
*    h(tech) technology       /CCGT, CCGT1, CCGT2, CCGT3, GT, GT1, GT2, GT3, ST, ST1, PV, WT,GTtoCC/
    h(tech) technology       /CCGT, GT, ST, PV, WT,GTtoCC/
    h_default(h) /CCGT GT, ST/
    o reliability option /o1,o2/
    CCGT(tech) /CCGT, CCGT1, CCGT2, CCGT3/
    gttocc(tech) /GTtoCC/
    GT(tech) /GT, GT1, GT2,GT3/
    ST(tech) /ST,ST1/
    nuclear(tech) /nuclear/
    PV(tech) /PV/
    WT(tech) /WT/
    ren(tech) /WT,PV/


    l market segment   /l1*l8/
    seasons  /winter,winter-wknd,summer,summer-wknd,spring-fall,spf-wknd/
    e(seasons) seasons for running the model /winter,winter-wknd,summer,summer-wknd,spring-fall,spf-wknd/
*    e(seasons) seasons for running the model /summer/
    e_wkdy(seasons) /winter,summer,spring-fall/
    e_wknd(seasons) /winter-wknd,summer-wknd,spf-wknd/
    winter(seasons) /winter,winter-wknd/
    spring(seasons) /spring-fall,spf-wknd/
    summer(seasons) /summer,summer-wknd/
    fall(seasons) /spring-fall,spf-wknd/
    sumfalspr(seasons) /spring-fall,spf-wknd,winter,winter-wknd/

    f fuels /u-235, methane, oil, ren/
    oil_gas(f) /methane, oil/
    oil(f) /oil/

    r regions /COA,EOA,SOA,WOA/
    coa(r) /COA/
    n power lines /COA_EOA,COA_WOA,SOA_WOA/

    m(r,e,l) capacity markets
    scen /s1*s10/

    s(scen) scenarios for energy demand        /s1*s1/
    ss(scen) scenarios for renewables       /s1/
    dir /p,m/
    majority(genco,r)

;
loop(genco,
    majority(genco,r)$(ord(r) = ord(genco)) = yes;
);


Alias (h,hh), (r,rr), (e,ee), (o,oo), (i,ii);
alias (l,ll), (i,ii), (h,hh,hhh), (r,rr,rrr), (e,ee), (Genco,GGenco), (seasons,sseasons);;

m(r,e,l) = no;

variables
    price(r,e,l,s,ss) energy price in USD per MWh
    demand(r,e,l,s,ss)
    delta(r,e,l) prices for the capacity or reliability options market in USD per  MW per hour
    Cap_avail(i,h,r)
    total_capacity(r)


    price_trans(r,e,l,s,ss) tranmission price in USD per MWh

    profit(i)
    arb_profit(e,l,s,ss)
    iso_profit(e,l,s,ss)

    kind(firm,tech,r) existing capacity by player
    arbitrage(r,e,l,s,ss) incoming (pos) and outgoing (neg) electricity arbitrage from zone r
    Load(r,e,l,s,ss) zonal load balance

    ELcost

;
Positive Variables

    Q(i,tech,f,r,e,l,s,ss)  generation quantity from a player i at market l in scenario in GW
    inv(i,tech,r)  investment by player i in technology tech in GW
    ret(i,tech,r)  retirement of technology h in region r by player i in GW
    sales(i,r,e,l,s,ss) sales of each firm in region r market l scenario s in GW

$ontext
    DEQ5_3(n,e,l,s,ss,dir)
    DEQ5_4(n,e,l,s,ss,dir)
    K(i,o,r,e,l) Capacity sold into the reliabilty options contract
    Z(i,o,r,e,l,s,ss) Non-negative difference between market and exercise price (P_cap)
    Zm(i,o,r,e,l,s,ss)
    Omega(i,o,r,e,l,s,ss)
    Gamma(i,r,e,l,s,ss)
$offtext
;
