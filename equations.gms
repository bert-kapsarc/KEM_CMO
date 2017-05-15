parameter fixed_cost(h);

fixed_cost(h)=sum(hh$(capadd(hh,h)>0),ici(hh)+capadd(hh,h)*om(hh))

set r_trans(r,rr);
set r_trade(r,rr);

r_trans(r,rr)$(ord(r)<ord(rr) and kind_trans0(r,rr)>0)=yes;

r_trade(r,rr)$(r_trans(r,rr) or r_trans(rr,r)) = yes;
*r_trade(r,rr)$r_trans(r,rr) = no;

         trade.fx(i,r,rr,e,l,s,ss)$(r_trade(r,rr) and trading<>1)=0;
*         arbitrage.fx(r,rr,e,l,s,ss)$r_trade(r,rr) = 0;

*         price_trans.fx(r,rr,e,l,s,ss)$r_trade(r,rr)=0;

*         Cap_avail.fx(i,h,r)=0;

Equations
         EqX_1(i,r)
         EqX_2(i,r)
         EqX_3(i,r)
         EqX_4(h,r)     lower bound aggregate gencos production (replicate effect of long term PPA's on the market)
         EqX_5(i,f,r)    fuel demand constraint


         Eq_q(i,h,f,r,e,l,s,ss)
         Eq_inv(i,h,r)
         Eq_kind(i,h,r)
         Eq_ret(i,h,r)
         Eq_trade(i,h,r,rr,e,l,s,ss)
         Eq_arb(r,rr,e,l,s,ss)
         EQ_X(h,r,e,l,s,ss)

         Eq1(r,e,l,s,ss) Equation (1)
         Eq1_2(r,e,l,s,ss)
         Eq1_3(r,e,l,s,ss)
         Eq2(o,r,e,l) Equation (2)
         Eq2_2(h,r)

         EQ3_1(i) Firms objective function

         EQ3_2(i,h,r,e,l,s,ss) Capacity constraint
         EQ3_3(i,h,r) Retirement constraint
         EQ3_4(i,r,e,l,s,ss) Identity for the sales into each options contract
         EQ3_5(i,o,r,e,l,s,ss) Price cap constraint (dual is the aggregate unsold demand under each contract)
         Eq3_6(i,o,r,e,l,s,ss) Constraint defines the total unsold capacity under each reliability option (dual is Z)
         EQ3_6_2(i,o,r,e,l,s,ss)
         EQ3_7(i,r,e,l,s,ss) Constraint for the unserved energy in a firms options contract
         EQ3_8(i,r,e,l,s,ss)
         EQ3_9(i,e,l)
         Eq3_11(i,h,r)
         EQ3_10(o,r,e,l,s,ss)

         EQ4_1

         Eq5_1(r,rr,e,l,s,ss)
         Eq5_2(r,rr,e,l,s,ss)
         Eq5_3(r,rr,e,l,s,ss)
         Eq5_4(r,rr,e,l,s,ss)
;

Eq1(r,e,l,s,ss)..
price(r,e,l,s,ss)=e=a(r,e,l,s,ss)-b(r,e,l,s,ss)*demand(r,e,l,s,ss)
;


Eq1_2(r,e,l,s,ss)..    demand(r,e,l,s,ss)=e=
                          sum((i,o),sales(i,o,r,e,l,s,ss))$(r_options=1)
                         +sum(i,U(i,r,e,l,s,ss))
                         -sum(rr$r_trade(r,rr),arbitrage(r,rr,e,l,s,ss))
                         +sum(rr$r_trade(r,rr),arbitrage(rr,r,e,l,s,ss))
;

Eq1_3(r,e,l,s,ss)$(r_options=1) ..
 total_sales(r,e,l,s,ss)=e= sum((i,o),sales(i,o,r,e,l,s,ss))
;

Eq2(o,r,e,l)$(r_options=1 or (r_options<>1 and ord(o)=1 and m(r,e,l)))..
delta(o,r,e,l)=e=
 sum((s,ss),Z("g1",o,r,e,l,s,ss)*prob(r,e,l,s,ss))$(r_options=1)
+(theta(r,e,l)-xi(r,e,l)*sum(h$(not gttocc(h)),demand_capacity(h,r)))$(r_options<>1)
;

Eq2_2(h,r)$(not gttocc(h))..
demand_capacity(h,r)=e=sum((i),Cap_avail(i,h,r))
;

EQ3_1(i)..
profit(i) =e=
-sum((r,e,l,s,ss),(
     (sum(o,sales(i,o,r,e,l,s,ss))$(r_options=1)+U(i,r,e,l,s,ss))*(
             a(r,e,l,s,ss)
             -b(r,e,l,s,ss)*(
                  sum((ii,oo),sales(ii,oo,r,e,l,s,ss))$(r_options=1)
                 +sum(ii,U(ii,r,e,l,s,ss))
                 -sum(rr$r_trade(r,rr),arbitrage(r,rr,e,l,s,ss))
                 +sum(rr$r_trade(r,rr),arbitrage(rr,r,e,l,s,ss)) )$Cournot(i)
             -b(r,e,l,s,ss)*demand(r,e,l,s,ss)$(not Cournot(i))
      )

    -sum(o,Z("g1",o,r,e,l,s,ss)*sales(i,o,r,e,l,s,ss))$(r_options=1)

    -sum((h,f)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss)*mc(h,f,r))
    -sum(rr$r_trade(r,rr),price_trans(r,rr,e,l,s,ss)*trade(i,r,rr,e,l,s,ss))
)*prob(r,e,l,s,ss)*d(e,l))

-sum((o,r,e,l),delta(o,r,e,l)*K(i,o,r,e,l)*d(e,l))$(r_options=1)
-sum((h,r,e,l)$(m(r,e,l) and not gttocc(h)),
  (theta(r,e,l)
    -xi(r,e,l)*sum((ii,hh)$(not gttocc(hh)),Cap_avail(ii,hh,r))$Cournot(i)
    -xi(r,e,l)*sum(hh$(not gttocc(hh)),demand_capacity(hh,r))$(not Cournot(i))
  )*Cap_avail(i,h,r)*d(e,l))$(r_options<>1)

+sum((h,r),ici(h)*inv(i,h,r)+ret(i,h,r)*icr(h)$(not gttocc(h)))
+sum((h,r)$(not gttocc(h)),Cap_avail(i,h,r)*om(h))
;

Eq3_2(i,h,r,e,l,s,ss)$(not gttocc(h)) ..
         (kind(i,h,r)+sum(hh,inv(i,hh,r)*capadd(hh,h))-ret(i,h,r))*(
                 1$(not ren(h))
                 +ELwindpowernorm(l,e,r)$WT(h)
                 +Elsolcurvenorm(l,e,r)$PV(h)
         )
         -sum((f)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss))=g=0;

Eq3_3(i,h,r)$(not gttocc(h))..  kind(i,h,r) - ret(i,h,r)=g=0
;

Eq3_4(i,r,e,l,s,ss)..

         sum((f,h)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss))
         -sum(rr$r_trade(r,rr),trade(i,r,rr,e,l,s,ss))$(trading=1)
         +sum(rr$r_trade(r,rr),trade(i,rr,r,e,l,s,ss))$(trading=1)
=e=
         sum(o,sales(i,o,r,e,l,s,ss))$(r_options=1)
         +U(i,r,e,l,s,ss)
;

EQ3_5(i,o,r,e,l,s,ss)$(r_options=1)..
         Z(i,o,r,e,l,s,ss)=g=Price(r,e,l,s,ss)-P_cap(o,r,e,l)
;

EQ3_6(i,o,r,e,l,s,ss)$(r_options=1)..
*         Omega(o,r,e,l,s,ss)
*         +sum((ii,oo),sales(ii,oo,r,e,l,s,ss))
*         +sum(ii,U(ii,r,e,l,s,ss))
          sum((ii),sales(ii,o,r,e,l,s,ss))
*$Cournot(i)
*          +total_sales(r,e,l,s,ss)$(not Cournot(i))
         =g=
         Omega(i,o,r,e,l,s,ss)
*sales(i,o,r,e,l,s,ss)=g=Omega(i,o,r,e,l,s,ss)

;


EQ3_6_2(i,o,r,e,l,s,ss)$(r_options=1)..
Zm(i,o,r,e,l,s,ss)-P_cap(o,r,e,l)+Price(r,e,l,s,ss)=g=0
;

EQ3_7(i,r,e,l,s,ss)$(r_options=1)..
        sum(o,sales(i,o,r,e,l,s,ss)-K(i,o,r,e,l))+Gamma(i,r,e,l,s,ss)=g=0
;

EQ3_8(i,r,e,l,s,ss)$(r_options=1)..
         b(r,e,l,s,ss)*U(i,r,e,l,s,ss)=g=0
;

EQ3_9(i,e,l)$(r_options=1)..
         sum((r,h)$(not gttocc(h)),Cap_avail(i,h,r))-sum((o,r),K(i,o,r,e,l))=g=0
;

EQ3_10(o,r,e,l,s,ss)$(r_options=1)..
         M_p(o,r,e,l,s,ss)=e=Price(r,e,l,s,ss)-Z("g1",o,r,e,l,s,ss);

Eq3_11(i,h,r)$(not gttocc(h))..
         Cap_avail(i,h,r) =e= kind(i,h,r)+sum(hh,inv(i,hh,r)*capadd(hh,h))-ret(i,h,r);


EqX_1(i,r)..  kind(i,'GT',r)-ret(i,'GT',r)-inv(i,'GTtoCC',r)=g=0;

EqX_2(i,r)$(market_share_inv(i)<1)  ..
                 market_share_inv(i)*sum((ii,h),inv(ii,h,r))
                         -sum(h,inv(i,h,r))=g=0;


EqX_3(i,r)$(market_share_prod(i)<1)  ..
market_share_prod(i)*sum((h,f,ii,e,l,s,ss)$fuel_set(h,f,r), Q(ii,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))
-sum((h,f,e,l,s,ss)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))=g=0;

EqX_4(h,r)$(Genco_PPA(h,r)>0 and not gttocc(h))..
sum((i,f,e,l,s,ss)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))
         =g=Genco_PPA(h,r);


EqX_5(i,f,r)$(fuel_quota(f,r)>0)..
-sum((ii,h,e,l,s,ss)$fuel_set(h,f,r),Q(ii,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l)*heat_rate(h,f)) =g=
          -fuel_quota(f,r);

EQ4_1.. arb_profit =e=
         -sum((r,rr,e,l,s,ss)$r_trade(r,rr),(
                 arbitrage(r,rr,e,l,s,ss)*(Price(rr,e,l,s,ss)-Price(r,e,l,s,ss)-price_trans(r,rr,e,l,s,ss))
         )*prob(r,e,l,s,ss)*d(e,l))
;


Eq5_1(r,rr,e,l,s,ss)$r_trans(r,rr)..
         kind_trans0(r,rr)=g=
                  sum(i,trade(i,r,rr,e,l,s,ss))$(trading=1)
                 -sum(i,trade(i,rr,r,e,l,s,ss))$(trading=1)
                 +arbitrage(r,rr,e,l,s,ss)
;

Eq5_2(r,rr,e,l,s,ss)$r_trans(r,rr)..
         kind_trans0(r,rr)=g=
                  sum(i,trade(i,rr,r,e,l,s,ss))$(trading=1)
                 -sum(i,trade(i,r,rr,e,l,s,ss))$(trading=1)
                 +arbitrage(rr,r,e,l,s,ss)
;


Eq5_3(r,rr,e,l,s,ss)$r_trans(r,rr) ..
         price_trans(r,rr,e,l,s,ss)
           =e=
           (phi(r,rr)$r_trans(r,rr)+(tau_pos(r,rr,e,l,s,ss)+tau_neg(r,rr,e,l,s,ss))/d(e,l))
;

Eq5_4(r,rr,e,l,s,ss)$r_trans(r,rr)..
         price_trans(rr,r,e,l,s,ss)
           =e= price_trans(r,rr,e,l,s,ss)
;




model CMO   /
             EQ1,EQ1_2,EQ1_3,
             EQ2,EQ2_2,
             EQ3_1,EQ3_2,EQ3_3,EQ3_4,
             EQ3_10,EQ3_11,
             EQX_1,EQX_2,EQX_3,
*            EQX_4,
             EQX_5,
            EQ4_1, EQ5_1, EQ5_2, EQ5_3,EQ5_4
/;

model CMO_options /CMO,EQ3_5,EQ3_6,EQ3_7,EQ3_8,EQ3_9/
;

         option MCP=path;
*         CMO.scaleopt =1;
*        tau.scale(r,rr,e,l,s,ss)=1e4;
