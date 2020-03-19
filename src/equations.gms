
Equations
    EQ1(r,e,l,s,ss) Inverse enery demand equation (energy market price) (1)
    EQ1_demand(r,e,l,s,ss) energy demand identity (for optimality condition of competitive firms)
    EQ2(r,e,l) Capacity market equation (2)
    EQ2_firm_capacity(i,h,r) Equation for capacity by firm and tech
    EQ2_capacity(r) Quation for total capacity sold to capacity market (for optimality condition of competitive firms)
    EQ3(r,e,l,s,ss) Zonal load balance

    EQ4_1(i) Firms objective function
    EQ4_2(i,h,r,e,l,s,ss) Capacity constraint
    EQ4_3(i,h,r) Retirement constraint
    EQ4_4(i,e,l,s,ss) Constraint on total sales to the neergy market

    EQ5_1(e,l,s,ss) ISO\TSO objective funciton
    EQ5_2(n,e,l,s,ss,dir) transmission capacity constraints

    EQ6_1(e,l,s,ss) Abritrager objective funciton
    EQ6_2(e,l,s,ss) No arbitrage contstraint

    EQcapuptime(i,h,r,s,ss) constraint on maximum hours of operation.

    EqX_1(i,r) constraint on GTtoCC investment decisions
    EqX_2(i,r) Market barriers for competitive fringe (investments)
    EqX_3(i,r) Market barriers for copmetitive fringe (production)
    EqX_4(i,h,r) Fower bound aggregate gencos production (replicate effect of long term PPAs on the market)
    EqX_5(i,f,r) Regional Fuel supply constraint

    EQ_cost
    EQ_dembal
;

$macro price_m(r,e,l,s,ss) (a(r,e,l,s) \
    -b(r,e,l,s)*( \
       +sum(ii,sales(ii,r,e,l,s,ss)) \
       +arbitrage(r,e,l,s,ss) )$Cournot(i) \
    -b(r,e,l,s)*demand(r,e,l,s,ss)$(not Cournot(i)) \
    )
$macro delta_m(i,r,e,l) (theta(r,e,l) \
    -xi(r,e,l)*( \
        sum((ii,hh),Cap_avail_m(ii,hh,r))$Cournot(i) \
        +total_capacity(r)$(not Cournot(i)) \
    ))

$macro Cap_avail_m(ii,hh,r) (kind(ii,hh,r)-ret(ii,hh,r) \
    +sum(hhh$(abs(capadd(hhh,hh))>0),inv(ii,hhh,r)*capadd(hhh,hh)))$(not gttocc(hh))


Eq1(r,e,l,s,ss)..
price(r,e,l,s,ss) =e= sum(i$(ord(i)=1),price_m(r,e,l,s,ss))
;

EQ1_demand(r,e,l,s,ss).. demand(r,e,l,s,ss) =e=
    sum(ii,sales(ii,r,e,l,s,ss))
    +arbitrage(r,e,l,s,ss)
;

EQ2(r,e,l)$m(r,e,l)..
delta(r,e,l)=e=sum(i$(ord(i)=1),delta_m(i,r,e,l))
;

EQ2_firm_capacity(i,h,r).. Cap_avail(i,h,r) =e= Cap_avail_m(i,h,r)
;

EQ2_capacity(r).. total_capacity(r) =e= sum((i,h),Cap_avail_m(i,h,r))
;

EQ3(r,e,l,s,ss).. Load(r,e,l,s,ss)=e=
    +sum(i,sales(i,r,e,l,s,ss))
    -sum((i,f,h)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss))
    +arbitrage(r,e,l,s,ss)
;


EQ4_1(i)..
profit(i) =e=
    sum((r,e,l,s,ss),(
        sales(i,r,e,l,s,ss)*price_m(r,e,l,s,ss)
        -sum((h,f)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss)*mc(h,f,r))
        -price_trans(r,e,l,s,ss)*(
                 +sales(i,r,e,l,s,ss)
                 -sum((f,h)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss))
         )
    )*d(e,l)*prob(r,e,l,s,ss))

    +sum((h,r,e,l)$(m(r,e,l) and not gttocc(h)),
        delta_m(i,r,e,l)*Cap_avail(i,h,r)*d(e,l))

    -sum((h,r),ici(h)*inv(i,h,r)+ret(i,h,r)*icr(h)$(not gttocc(h)))
    -sum((h,r)$(not gttocc(h)),Cap_avail(i,h,r)*om(h))
;

EQ_cost.. ELcost =e=
    sum((h,i,r),sum((f,e,l,s,ss)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss)*mc(h,f,r)*d(e,l)*prob(r,e,l,s,ss))
    +ici(h)*inv(i,h,r)+ret(i,h,r)*icr(h)$(not gttocc(h))
    +Cap_avail(i,h,r)*om(h)$(not gttocc(h)))
    +sum((n,r,e,l,s,ss,dir),Load(r,e,l,s,ss)*PTDF(n,r,dir)*phi(n)*d(e,l)*prob(r,e,l,s,ss))
;

EQ4_2(i,h,r,e,l,s,ss)$(not gttocc(h)) ..
    Cap_avail(i,h,r)*(
    1$(not ren(h))
        +ELwindpowernorm(l,e,r)$WT(h)
        +Elsolcurvenorm(l,e,r)$PV(h) )
    -sum((f)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss))=g=0
;

EQ4_3(i,h,r)$(not gttocc(h))..  kind(i,h,r) - ret(i,h,r)=g=0
;

EQ4_4(i,e,l,s,ss)..
    sum((f,h,r)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss))
    =g=
    +sum(r,sales(i,r,e,l,s,ss))
;

EQ5_1(e,l,s,ss).. iso_profit(e,l,s,ss) =e=
    sum(r,Load(r,e,l,s,ss)*d(e,l)*price_trans(r,e,l,s,ss))
   -sum((n,r,dir),Load(r,e,l,s,ss)*PTDF(n,r,dir)*phi(n)*d(e,l))
;

EQ5_2(n,e,l,s,ss,dir)..
    kind_trans0(n)=g=sum(r,PTDF(n,r,dir)*Load(r,e,l,s,ss))
;


EQ6_1(e,l,s,ss).. arb_profit(e,l,s,ss) =e= sum(r,
            arbitrage(r,e,l,s,ss)*d(e,l)*
            (price(r,e,l,s,ss) -price_trans(r,e,l,s,ss)) )
;

EQ6_2(e,l,s,ss)..
         sum(r,arbitrage(r,e,l,s,ss))=e=0
;

EqX_1(i,r)..  kind(i,'GT',r)-ret(i,'GT',r)-inv(i,'GTtoCC',r)=g=0
;
EqX_2(i,r)$(market_share_inv(i)<1)..
    market_share_inv(i)*sum((ii,h),inv(ii,h,r))-sum(h,inv(i,h,r))=g=0
;
EqX_3(i,r)$(market_share_prod(i)<1)..
    market_share_prod(i)*sum((h,f,ii,e,l,s,ss)$fuel_set(h,f,r), Q(ii,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))
    -sum((h,f,e,l,s,ss)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))=g=0
;
EqX_4(i,h,r)$(Genco_PPA(h,r)>0 and not gttocc(h))..
    sum((ii,f,e,l,s,ss)$fuel_set(h,f,r),Q(ii,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))
    =g=Genco_PPA(h,r)
;
EqX_5(i,f,r)$(fuel_quota(f,r)>0)..
    -sum((ii,h,e,l,s,ss)$fuel_set(h,f,r),Q(ii,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l)*heat_rate(h,f,r)) =g=
    -fuel_quota(f,r)
;
EQcapuptime(i,h,r,s,ss)$(not ren(h) and not gttocc(h))..
    sum((e,l),cap_uptime(h,r,e)*d(e,l)*Cap_avail(i,h,r)) - sum((e,l,f)$fuel_set(h,f,r), Q(i,h,f,r,e,l,s,ss)*d(e,l)) =g= 0
;
EQ_dembal(r,e,l,s,ss) ..
    sum(ii,sales(ii,r,e,l,s,ss))
   =g= EL_Demand(r,e,l,s)
;

model CMO   /
    EQ1,EQ1_demand,EQ2,EQ2_firm_capacity,EQ2_capacity,EQ3,
    EQ4_1,EQ4_2,EQ4_3,EQ4_4,
    EQ5_1,
    EQ5_2,
    EQ6_1,
    EQ6_2,
    EQX_1,
    EQX_2,
    EQX_3,
    EQX_4,
    EQX_5,
*    EQcapuptime
/
power /
    EQ_cost,EQ_dembal,EQ4_2,EQ4_3,EQ4_4,EqX_5,EQ5_2,
*    EQcapuptime
    /
;

option MCP=path;
option NLP=pathnlp;
