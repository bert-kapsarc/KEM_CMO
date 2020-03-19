parameter fixed_cost(h);

fixed_cost(h)=sum(hh$(capadd(hh,h)>0),ici(hh)+capadd(hh,h)*om(hh))

set r_trans(r,rr);
set r_trade(r,rr);

*Fix nuclear and renewable builds to zero 
inv.fx(i,'Nuclear',r)=0;
inv.fx(i,ren,r)=0;
ret.fx(i,ren,r)=0;

Equations
    EqX_1(i,r)
    EqX_2(i,r)
    EqX_3(i,r)
    EqX_4(i,h,r)     lower bound aggregate gencos production (replicate effect of long term PPAs on the market)
    EqX_5(i,f,r)    fuel demand constraint


    Eq_q(i,h,f,r,e,l,s,ss)
    Eq_inv(i,h,r)
    Eq_kind(i,h,r)
    Eq_ret(i,h,r)
    Eq_trade(i,h,r,rr,e,l,s,ss)
    Eq_arb(r,rr,e,l,s,ss)
    EQ_X(h,r,e,l,s,ss)

    Eq1(r,e,l,s,ss) Inverse enery demand equation (energy market price) (1)
    EQ1_demand(r,e,l,s,ss)
    Eq2(o,r,e,l) Capacity market equation (2)
    EQ3(r,e,l,s,ss) Zonal load balance

    EQ4_1(i) Firms objective function

    EQ4_2(i,h,r,e,l,s,ss) Capacity constraint
    EQ4_3(i,h,r) Retirement constraint
    EQ4_4(i,e,l,s,ss) Identity for the sales into each options contract
    EQ4_5(i,o,r,e,l,s,ss) Price cap constraint (dual is the aggregate unsold demand under each contract)
    EQ4_6(i,o,r,e,l,s,ss) Constraint defines the total unsold capacity under each reliability option (dual is Z)
    EQ4_6_2(i,o,r,e,l,s,ss)
    EQ4_7(i,r,e,l,s,ss) Constraint for the unserved energy in a firms options contract
    EQ4_8(i,r,e,l,s,ss)
    EQ4_9(i,e,l)
    EQ4_10(o,r,e,l,s,ss)

    EQ5_1(e,l,s,ss)
    EQ5_2(n,e,l,s,ss,dir)

    EQ6_1
    EQ6_2

    EQcapuptime(i,h,r,s,ss)

    EQ_cost
    EQ_dembal
;

$macro price_m(i,r,e,l,s,ss)  (a(r,e,l,s) \
     -b(r,e,l,s)*( \
        sum((ii,oo),sales(ii,oo,r,e,l,s,ss))$(r_options=1) \
        +sum(ii,sales(ii,r,e,l,s,ss)) \
        +arbitrage(r,e,l,s,ss) )$Cournot(i) \
     -b(r,e,l,s)*demand_m(r,e,l,s,ss)$(not Cournot(i)) \
    )
$macro demand_m(r,e,l,s,ss) \   
    (sum((ii,oo),sales(ii,oo,r,e,l,s,ss))$(r_options=1) \
    +sum(ii,sales(ii,r,e,l,s,ss)) \
    +arbitrage(r,e,l,s,ss))

$macro total_sales(r,e,l,s,ss) sum((ii,oo),sales(ii,oo,r,e,l,s,ss))
$macro delta(o,r,e,l) \         
    (sum((s,ss),Z("g1",o,r,e,l,s,ss)*prob(r,e,l,s,ss))$(r_options=1) \
    +(theta(r,e,l)-xi(r,e,l)*sum(h$(not gttocc(h)),Cap_avail(i,h,r)))$(r_options<>1) )
$macro Cap_avail(i,h,r)     sum((ii),Cap_avail(ii,h,r))
$macro price_trans(r,e,l,s,ss)  sum((n,dir),PTDF(n,r,dir)*DEQ5_4(n,e,l,s,ss,dir)/D(e,l))
$macro Cap_avail(i,h,r) \
    kind(i,h,r)-ret(i,h,r) \
    +sum(hh$(abs(capadd(hh,h))>0),inv(i,hh,r)*capadd(hh,h))

Eq1(r,e,l,s,ss)..
price(r,e,l,s,ss)=e=(a(r,e,l,s)-b(r,e,l,s)*demand_m(r,e,l,s,ss))
;

EQ1_demand(r,e,l,s,ss).. demand(r,e,l,s,ss) =e= 
    sum(ii,sales(ii,r,e,l,s,ss)) 
    +arbitrage(r,e,l,s,ss)$Cournot(i)
;

Eq2(o,r,e,l)$(r_options=1 or (r_options<>1 and ord(o)=1 and m(r,e,l)))..
delta(o,r,e,l)=e=
 sum((s,ss),Z("g1",o,r,e,l,s,ss)*prob(r,e,l,s,ss))$(r_options=1)
+(theta(r,e,l)-xi(r,e,l)*sum(h$(not gttocc(h)),Cap_avail(i,h,r)))$(r_options<>1)
;

EQ3(r,e,l,s,ss).. Load(r,e,l,s,ss)=e=
    +sum((i,o),sales(i,o,r,e,l,s,ss))$(r_options=1)
    +sum(i,sales(i,r,e,l,s,ss))
    -sum((i,f,h)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss))
    +arbitrage(r,e,l,s,ss)
;


EQ4_1(i)..
profit(i) =e=
    sum((r,e,l,s,ss),(
         (sum(o,sales(i,o,r,e,l,s,ss))$(r_options=1)+sales(i,r,e,l,s,ss))*price_m(i,r,e,l,s,ss)

        -sum(o,Z("g1",o,r,e,l,s,ss)*sales(i,o,r,e,l,s,ss))$(r_options=1)

        -sum((h,f)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss)*mc(h,f,r))
        -price_trans(r,e,l,s,ss)*(
                 sum(o,sales(i,o,r,e,l,s,ss))$(r_options=1)
                 +sales(i,r,e,l,s,ss)
                 -sum((f,h)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss))
         )
    )*d(e,l)*prob(r,e,l,s,ss))

    +sum((o,r,e,l),delta(o,r,e,l)*K(i,o,r,e,l)*d(e,l))$(r_options=1)
    +sum((h,r,e,l)$(m(r,e,l) and not gttocc(h)),
      (theta(r,e,l)
        -xi(r,e,l)*sum((ii,hh)$(not gttocc(hh)),Cap_avail(ii,hh,r))$Cournot(i)
        -xi(r,e,l)*sum(hh$(not gttocc(hh)),Cap_avail(i,hh,r))$(not Cournot(i))
      )*Cap_avail(i,h,r)*d(e,l))$(r_options<>1)

    -sum((h,r),ici(h)*inv(i,h,r)+ret(i,h,r)*icr(h)$(not gttocc(h)))
    -sum((h,r)$(not gttocc(h)),Cap_avail(i,h,r)*om(h))
;

EQ_cost.. ELcost =e= sum((h,i,r),sum((f,e,l,s,ss)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss)*mc(h,f,r)*d(e,l)*prob(r,e,l,s,ss))
+ici(h)*inv(i,h,r)+ret(i,h,r)*icr(h)$(not gttocc(h))
+Cap_avail(i,h,r)*om(h)$(not gttocc(h)))
+sum((n,e,l,s,ss,dir), phi(n)*d(e,l)*transn(n,e,l,s,ss,dir))
;

EQcapuptime(i,h,r,s,ss)$(not ren(h) and not gttocc(h))..
    sum((e,l),cap_uptime(h,r,e)*d(e,l)*Cap_avail(i,h,r)) - sum((e,l,f)$fuel_set(h,f,r), Q(i,h,f,r,e,l,s,ss)*d(e,l)) =g= 0
;

EQ4_2(i,h,r,e,l,s,ss)$(not gttocc(h)) ..
    Cap_avail(i,h,r)*(
*    cap_uptime(h,r,e)*
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
    sum((o,r),sales(i,o,r,e,l,s,ss))$(r_options=1)
    +sum(r,sales(i,r,e,l,s,ss))
;

EQ4_5(i,o,r,e,l,s,ss)$(r_options=1)..
         Z(i,o,r,e,l,s,ss) =g= price_m(i,r,e,l,s,ss) - P_cap(o,r,e,l)
;

EQ4_6(i,o,r,e,l,s,ss)$(r_options=1)..
*         Omega(o,r,e,l,s,ss)
*         +sum((ii,oo),sales(ii,oo,r,e,l,s,ss))
*         +sum(ii,sales(ii,r,e,l,s,ss))
          sum((ii),sales(ii,o,r,e,l,s,ss))
*$Cournot(i)
*          +total_sales(r,e,l,s,ss)$(not Cournot(i))
         =g=
         Omega(i,o,r,e,l,s,ss)
*sales(i,o,r,e,l,s,ss)=g=Omega(i,o,r,e,l,s,ss)

;

EQ4_7(i,r,e,l,s,ss)$(r_options=1)..
        sum(o,sales(i,o,r,e,l,s,ss)-K(i,o,r,e,l))+Gamma(i,r,e,l,s,ss)=g=0
;

EQ4_8(i,r,e,l,s,ss)$(r_options=1)..
         b(r,e,l,s)*sales(i,r,e,l,s,ss)=g=0
;

EQ4_9(i,e,l)$(r_options=1)..
         sum((r,h)$(not gttocc(h)),Cap_avail(i,h,r))-sum((o,r),K(i,o,r,e,l))=g=0
;

EQ4_10(o,r,e,l,s,ss)$(r_options=1)..
         M_p(o,r,e,l,s,ss)=e= price(r,e,l,s,ss)-Z("g1",o,r,e,l,s,ss);


EqX_1(i,r)..  kind(i,'GT',r)-ret(i,'GT',r)-inv(i,'GTtoCC',r)=g=0;

EqX_2(i,r)$(market_share_inv(i)<1)..
                 market_share_inv(i)*sum((ii,h),inv(ii,h,r))
                         -sum(h,inv(i,h,r))=g=0;

EqX_3(i,r)$(market_share_prod(i)<1)..
market_share_prod(i)*sum((h,f,ii,e,l,s,ss)$fuel_set(h,f,r), Q(ii,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))
-sum((h,f,e,l,s,ss)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))=g=0;

EqX_4(i,h,r)$(Genco_PPA(h,r)>0 and not gttocc(h))..
sum((ii,f,e,l,s,ss)$fuel_set(h,f,r),Q(ii,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))
         =g=Genco_PPA(h,r);


EqX_5(i,f,r)$(fuel_quota(f,r)>0)..
-sum((ii,h,e,l,s,ss)$fuel_set(h,f,r),Q(ii,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l)*heat_rate(h,f,r)) =g=
          -fuel_quota(f,r);

EQ5_1(e,l,s,ss).. iso_profit(e,l,s,ss) =e=
    sum(r,Load(r,e,l,s,ss)*d(e,l)*price_trans(r,e,l,s,ss))
   -sum((n,r,dir),Load(r,e,l,s,ss)*PTDF(n,r,dir)*phi(n)*d(e,l))
;

EQ5_2(n,e,l,s,ss,dir)..
    kind_trans0(n)=g=sum(r,PTDF(n,r,dir)*Load(r,e,l,s,ss))
;


EQ6_1(e,l,s,ss).. arb_profit(e,l,s,ss) =e= sum(r,
            arbitrage(r,e,l,s,ss)*d(e,l)*
            (Price(r,e,l,s,ss) -price_trans(r,e,l,s,ss)) )
;

EQ6_2(e,l,s,ss)..
         sum(r,arbitrage(r,e,l,s,ss))=e=0
;


EQ_dembal(r,e,l,s,ss) ..
    sum(ii,sales(ii,r,e,l,s,ss))
   =g= EL_Demand(r,e,l,s)
;

model CMO   /
             EQ1,EQ2,
             EQ4_1,EQ4_2,EQ4_3,EQ4_4,
             EQX_1,
             EQX_2,
             EQX_3,
             EQX_4,
             EQX_5,
             EQ6_1,EQ6_2,
*             EQ5_1,
*             EQ5_2,
             EQ5_3,
             EQ5_4
*             EQ5_5,
             EQ5_6,
             EQcapuptime
/;

model   CMO_options /CMO,EQ4_5,EQ4_6,EQ4_7,EQ4_8,EQ4_9,EQ4_10/

        power /EQ_cost,EQ_dembal,EQ4_2,EQ4_3,EQ4_4,EQ4_11,EqX_5,EQ5_3,EQ5_4,EQcapuptime/
;

         option MCP=path;
         option NLP=pathnlp;
*         CMO.scaleopt =1;