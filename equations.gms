parameter fixed_cost(h);

fixed_cost(h)=sum(hh$(capadd(hh,h)>0),ici(hh)+capadd(hh,h)*om(hh))

set r_trans(r,rr);
set r_trade(r,rr);

r_trans(r,rr)$(ord(r)<ord(rr) and kind_trans0(r,rr)>0)=yes;

r_trade(r,rr)$(r_trans(r,rr) or r_trans(rr,r)) = yes;
*r_trade(r,rr)$r_trans(r,rr) = no;

         trade.fx(i,r,rr,e,l,s,ss)$(r_trade(r,rr) and trading<>1)=0;
         arbitrage.fx(r,rr,e,l,s,ss)$r_trade(r,rr) = 0;

         price_trans.fx(r,rr,e,l,s,ss)$r_trade(r,rr)=0;
Equations
$ontext
         Eq9_1(firm,h,f,r,e,l,s,ss)
         Eq9_2(firm,h,r)
         Eq9_3(firm,h,r)
         Eq9_4(firm,h,r,rr,e,l,s,ss)
         EQ9_4x(firm,r,e,l)
         Eq9_5(firm,h,r,e,l,s,ss)
         Eq9_6(firm,h,r)

         Eq9_7(r,rr,e,l,s,ss)
         Eq9_8(r,rr,e,l,s,ss)
         Eq9_9(r,rr,e,l,s,ss)

         Eq9_10(firm,h,r)
         Eq9_11(firm,h,r,e,l,s,ss)
         EQ9_12(r,rr,e,l,s,ss)
         EQ9_13(r,rr,e,l,s,ss)

         EQ9_14(o,r,e,l,s,ss)
         Eq9_15(r,e,l,s,ss)
         Eq9_16(o,r,e,l,s,ss)
         EQ9_17(i,r,e,l,s,ss)
         EQ9_18(i,r,e,l,s,ss)
         EQ9_19(i,e,l)
$offtext


         EqX_1(i,r)
         EqX_2(i,r)
         EqX_3(i,r)
         EqX_4(h,r)     lower bound aggregate gencos production (replicate effect of long term PPA's on the market)
         EqX_5(f,r)    fuel demand constraint


         Eq_q(i,h,f,r,e,l,s,ss)
         Eq_inv(i,h,r)
         Eq_kind(i,h,r)
         Eq_ret(i,h,r)
         Eq_trade(i,h,r,rr,e,l,s,ss)
         Eq_arb(r,rr,e,l,s,ss)
         EQ_X(h,r,e,l,s,ss)

         Eq1(r,e,l,s,ss) Equation (1)
         Eq2(o,r,e,l) Equation (2)

         EQ3_1(i) Firms objective function

         EQ3_2(i,h,r,e,l,s,ss) Capacity constraint
         EQ3_3(i,h,r) Retirement constraint
         EQ3_4(i,r,e,l,s,ss) Identity for the sales into each options contract
         EQ3_5(o,r,e,l,s,ss) Price cap constraint (dual is the aggregate unsold demand under each contract)
         Eq3_6(o,r,e,l,s,ss) Constraint defines the total unsold capacity under each reliability option (dual is Z)
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

Eq1(r,e,l,s,ss)..    price(r,e,l,s,ss)=e=
                     a(r,e,l,s,ss)-b(r,e,l,s,ss)*(
                          sum((ii,o),sales(ii,o,r,e,l,s,ss))$(r_options=1)
                         +sum(ii,U(ii,r,e,l,s,ss))
                         -sum(rr$r_trade(r,rr),arbitrage(r,rr,e,l,s,ss))
                         +sum(rr$r_trade(r,rr),arbitrage(rr,r,e,l,s,ss))
                     )
;

Eq2(o,r,e,l)$(r_options=1 or (r_options<>1 and ord(o)=1 and m(r,e,l)))..
delta(o,r,e,l)=e=
 sum((s,ss),Z(o,r,e,l,s,ss)*prob(r,e,l,s,ss))$(r_options=1)
+(theta(r,e,l)-xi(r,e,l)*sum((ii,hh)$(not gttocc(hh)),Cap_avail(ii,hh,r)))$(r_options<>1 and m(r,e,l));


EQ3_1(i)..
profit(i) =e=
-sum((r,e,l,s,ss),
    (
         sum(o,M_p(o,r,e,l,s,ss)*sales(i,o,r,e,l,s,ss))$(r_options=1)
         +U(i,r,e,l,s,ss)*(
                 a(r,e,l,s,ss)-b(r,e,l,s,ss)*(
                          sum((ii,oo),sales(ii,oo,r,e,l,s,ss))$(r_options=1)
                         +sum(ii,U(ii,r,e,l,s,ss))
                         -sum(rr$r_trade(r,rr),arbitrage(r,rr,e,l,s,ss))
                         +sum(rr$r_trade(r,rr),arbitrage(rr,r,e,l,s,ss)) )
    )$Cournot(i)
    +U(i,r,e,l,s,ss)*price(r,e,l,s,ss)$(not Cournot(i))

    -sum((h,f)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss)*mc(h,f,r))
    -sum(rr$r_trade(r,rr),price_trans(r,rr,e,l,s,ss)*trade(i,r,rr,e,l,s,ss))
)*prob(r,e,l,s,ss)*d(e,l))

-sum((o,r,e,l),delta(o,r,e,l)*K(i,o,r,e,l)*d(e,l))$(r_options=1)
-sum((h,r,e,l)$(m(r,e,l) and not gttocc(h)),
    (theta(r,e,l)-xi(r,e,l)*sum((ii,hh)$(not gttocc(hh)),Cap_avail(ii,hh,r)))*
    Cap_avail(i,h,r)*d(e,l))$(r_options<>1 and Cournot(i))
-sum((o,h,r,e,l)$(ord(o)=1 and m(r,e,l) and not gttocc(h)),delta(o,r,e,l)*
    Cap_avail(i,h,r)*d(e,l))$(r_options<>1 and not Cournot(i))

+sum((h,r),ici(h)*inv(i,h,r)+ret(i,h,r)*icr(h)$(not gttocc(h)))
+sum((h,r)$(not gttocc(h)),Cap_avail(i,h,r)*om(h))
;

Eq3_2(i,h,r,e,l,s,ss)$(not gttocc(h)) ..
         Cap_avail(i,h,r)*(
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
=g=
         sum(o,sales(i,o,r,e,l,s,ss))$(r_options=1)
         +U(i,r,e,l,s,ss)
;

EQ3_5(o,r,e,l,s,ss)$(r_options=1)..
         Z(o,r,e,l,s,ss)=g=Price(r,e,l,s,ss)-P_cap(o,r,e,l)
;

EQ3_6(o,r,e,l,s,ss)$(r_options=1)..
         Omega(o,r,e,l,s,ss)+sum((ii,oo),sales(ii,oo,r,e,l,s,ss))
         +sum(ii,U(ii,r,e,l,s,ss))
         =g=Sales_bar(o,r,e,l,s,ss)
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
         M_p(o,r,e,l,s,ss)=e=Price(r,e,l,s,ss)-Z(o,r,e,l,s,ss);

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


EqX_5(f,r)$(fuel_quota(f,r)>0)..
-sum((i,h,e,l,s,ss)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l)*heat_rate(h,f)) =g=
          -fuel_quota(f,r);

EQ4_1.. arb_profit =e=
         -sum((r,rr,e,l,s,ss)$r_trade(r,rr),(
                 arbitrage(r,rr,e,l,s,ss)*(Price(rr,e,l,s,ss)-Price(r,e,l,s,ss))
                 -arbitrage(r,rr,e,l,s,ss)*price_trans(r,rr,e,l,s,ss)
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




model CMO   /EQ1,EQ2,EQ3_1,EQ3_2,EQ3_3,EQ3_4,EQ3_5,EQ3_6,EQ3_7,EQ3_8,EQ3_9,
             EQ3_10,EQ3_11,
             EQX_1,EQX_2,EQX_3,
*            EQX_4,EQX_5,
*            EQ4_1, EQ5_1, EQ5_2, EQ5_3, EQ5_4
/;
$ontext
            Eq9_1,
            Eq9_2,
            Eq9_3,
            Eq9_4,
            EQ9_4x,
            Eq9_5.lambda_high,
            Eq9_6.eta_high,
            Eq9_7,
            Eq9_8.tau_pos,
            Eq9_9.tau_neg,


            Eq9_10,
            Eq9_11,
            EQ9_12,
            EQ9_13,
            EQ9_14.Omega,
            EQ9_15.Z,
            EQ9_16,
            EQ9_17.xi,
            EQ9_18.mu_high,
            EQ9_19.psi,



            EqX_1.shadows_gttocc,
            EQX_2.shadows_inv_cap,
            EqX_3.shadows_prod_cap,
            EqX_4.shadows_genco_ppa,
            EqX_5.shadows_fuel_alloc,



            Eq_q.lambda_low,
            Eq_trade.zeta,
            Eq_inv.alpha,
            Eq_ret.eta_low,
            Eq_arb.shadows_arbitrage,
            EQ_K.shadows_K
$offtext

         option MCP=path;
*         CMO.scaleopt =1;
*        tau.scale(r,rr,e,l,s,ss)=1e4;
