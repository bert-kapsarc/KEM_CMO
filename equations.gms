parameter fixed_cost(h);

fixed_cost(h)=sum(hh$(capadd(hh,h)>0),ici(hh)+capadd(hh,h)*om(hh))

set r_trans(r,rr);
set r_trade(r,rr);

r_trans(r,rr)$(ord(r)<ord(rr) and kind_trans0(r,rr)>0)=yes;

r_trade(r,rr)$(r_trans(r,rr) or r_trans(rr,r)) = yes;
*r_trade(r,rr)$r_trans(r,rr) = no;

         trade.fx(i,h,r,rr,e,l,s,ss)$(trading<>1)=0;
*         arbitrage.fx(r,rr,e,l,s,ss)$r_trans(r,rr) = 0;
*         tau_pos.fx(r,rr,e,l,s,ss) = 0;
     shadows_gttocc.fx(i,r) =0;
Equations
         Eq1(r,e,l,s,ss)              Equation (1)
         Eq2(r,e,l)                Equation (1)
         Eq9_1(company,h,f,r,e,l,s,ss)        Equation (8.1)
         Eq9_2(company,h,r)              Equation (8.2)
         Eq9_3(company,h,r)              Equation (8.3)
         Eq9_4(company,h,r,rr,e,l,s,ss)       Equation (8.4)
         Eq9_5(company,h,r,e,l,s,ss)
         Eq9_6(company,h,r)

         Eq9_7(r,rr,e,l,s,ss)
         Eq9_8(r,rr,e,l,s,ss)
         Eq9_9(r,rr,e,l,s,ss)

         Eq9_10(company,h,r)
         Eq9_11(company,h,r,e,l,s,ss)
         EQ9_12(r,rr,e,l,s,ss)
         EQ9_13(r,rr,e,l,s,ss)

         EQ9_14(h,r,e,l,s,ss)
         Eq9_15(h,r,e,l,s,ss)
         Eq9_16(h,r,e,l,s,ss)


         EqX_1(company,r)
         EqX_2(company,r)
         EqX_3(company,r)
         EqX_4(h,r)     lower bound aggregate gencos production (replicate effect of long term PPA's on the market)
         EqX_5(f,r)    fuel demand constraint


         Eq_q(company,h,f,r,e,l,s,ss)
         Eq_inv(company,h,r)
         Eq_kind(company,h,r)
         Eq_ret(company,h,r)
         Eq_trade(company,h,r,rr,e,l,s,ss)
         Eq_arb(r,rr,e,l,s,ss)
         EQ_X(h,r,e,l,s,ss)
;

Eq1(r,e,l,s,ss)..    price(r,e,l,s,ss)=e=
                     a(r,e,l,s,ss)-b(r,e,l,s,ss)*
                     (sum((j,h)$(not gttocc(h)),sales(j,h,r,e,l,s,ss))
                         -sum(rr$r_trade(r,rr),arbitrage(r,rr,e,l,s,ss))
                         +sum(rr$r_trade(r,rr),arbitrage(rr,r,e,l,s,ss))
                     );

Eq2(r,e,l)$m(r,e,l)..
delta(r,e,l)=e=
 sum((h,s,ss)$(not gttocc(h)),X(h,r,e,l,s,ss)*prob(r,e,l,s,ss))$(r_options=1)
+(theta(r,e,l)-xi(r,e,l)*sum((j,hh)$(not gttocc(hh)),Cap_avail(j,hh,r)))$(r_options<>1);

Eq9_1(i,h,f,r,e,l,s,ss)$(fuel_set(h,f,r) and not gttocc(h)) ..
         price(r,e,l,s,ss)-X(h,r,e,l,s,ss)
         +b(r,e,l,s,ss)*(1+v(i))*(Omega(h,r,e,l,s,ss)$(r_options=1)-sales(i,h,r,e,l,s,ss))
         -lambda_high(i,h,r,e,l,s,ss)
         +shadows_genco_ppa(h,r)$(Genco_PPA(h,r)>0)
         +(market_share_prod(i)*(1+v(i))-1)*shadows_prod_cap(i,r)$(market_share_prod(i)<1)
         -shadows_fuel_alloc(f,r)*heat_rate(h,f)$(fuel_quota(f,r)>0)
         +lambda_low(i,h,f,r,e,l,s,ss)=e= mc(h,f,r) ;
*

Eq9_2(i,h,r)$(not legacy(i))..
          sum((e,l)$m(r,e,l),d(e,l)*delta(r,e,l))*sum(hh$(not gttocc(hh)),capadd(h,hh))
         -sum((e,l)$m(r,e,l),d(e,l)*xi(r,e,l)*(1+z(i))*
                 sum(hh$(not gttocc(hh)),Cap_avail(i,hh,r)))*sum(hh$(not gttocc(hh)),capadd(h,hh))$(r_options<>1)
         +sum((hh,e,l,s,ss)$(not gttocc(hh)),
                 prob(r,e,l,s,ss)*d(e,l)*lambda_high(i,hh,r,e,l,s,ss)*capadd(h,hh)*
                 (
                         1$(not ren(hh))
                         +ELwindpowernorm(l,e,r)$WT(hh)
                         +Elsolcurvenorm(l,e,r)$PV(hh)
                 )
         )
         -shadows_gttocc(i,r)$gttocc(h)
         +alpha(i,h,r)
         +(market_share_inv(i)*(1+z(i))-1)*shadows_inv_cap(i,r)$(market_share_inv(i)<1)

                         =e=
        ici(h)+ sum(hh$(not gttocc(hh)),capadd(h,hh)*om(hh))
;

*

Eq9_3(i,h,r)$(not gttocc(h))..
         -sum((e,l)$m(r,e,l),d(e,l)*delta(r,e,l))
         +sum((e,l)$m(r,e,l),d(e,l)*xi(r,e,l)*(1+z(i))*
                 sum(hh$(not gttocc(hh)),Cap_avail(i,hh,r)))$(r_options<>1)
         -sum((e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*lambda_high(i,h,r,e,l,s,ss)*
                 (
                         1$(not ren(h))
                         +ELwindpowernorm(l,e,r)$WT(h)
                         +Elsolcurvenorm(l,e,r)$PV(h)
                 )
         )
         -shadows_gttocc(i,r)$gt(h)
         -eta_high(i,h,r)
         +eta_low(i,h,r) =e= (icr(h)-om(h));

Eq9_4(i,h,r,rr,e,l,s,ss)$(trading=1 and r_trade(r,rr) and not legacy(i) and not gttocc(h))..
         m_p(h,rr,e,l,s,ss)-m_p(h,r,e,l,s,ss)+zeta(i,h,r,rr,e,l,s,ss)
         -price_trans(r,rr,e,l,s,ss)
        +b(r,e,l,s,ss)*sales(i,h,r,e,l,s,ss)*(1+v(i))
        -b(rr,e,l,s,ss)*sales(i,h,rr,e,l,s,ss)*(1+v(i))
                 =e=0;

Eq9_5(i,h,r,e,l,s,ss)$(not gttocc(h)) ..
         Cap_avail(i,h,r)*(
                 1$(not ren(h))
                 +ELwindpowernorm(l,e,r)$WT(h)
                 +Elsolcurvenorm(l,e,r)$PV(h)
         )
         -sum(f$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss))=g=0;

Eq9_6(i,h,r)$(not gttocc(h))..  kind(i,h,r) - ret(i,h,r)=g=0 ;


Eq9_7(r,rr,e,l,s,ss)$r_trade(r,rr)..
         price(rr,e,l,s,ss)-price(r,e,l,s,ss)
         -price_trans(r,rr,e,l,s,ss)
         +shadows_arbitrage(r,rr,e,l,s,ss) =e=0        ;

Eq9_8(r,rr,e,l,s,ss)$r_trans(r,rr)..

         kind_trans0(r,rr)=g=
                  sum((i,h)$(not legacy(i) and not gttocc(h)),trade(i,h,r,rr,e,l,s,ss))$(trading=1)
                 -sum((i,h)$(not legacy(i) and not gttocc(h)),trade(i,h,rr,r,e,l,s,ss))$(trading=1)
                 +arbitrage(r,rr,e,l,s,ss)
;

Eq9_9(r,rr,e,l,s,ss)$r_trans(r,rr)..
         kind_trans0(r,rr)=g=
                  sum((i,h)$(not legacy(i) and not gttocc(h)),trade(i,h,rr,r,e,l,s,ss))$(trading=1)
                 -sum((i,h)$(not legacy(i) and not gttocc(h)),trade(i,h,r,rr,e,l,s,ss))$(trading=1)
                 +arbitrage(rr,r,e,l,s,ss)
;

Eq9_10(i,h,r)$(not gttocc(h))..
         Cap_avail(i,h,r) =e= kind(i,h,r)+sum(hh,inv(i,hh,r)*capadd(hh,h))-ret(i,h,r);

Eq9_11(i,h,r,e,l,s,ss)$(not gttocc(h))..
         sales(i,h,r,e,l,s,ss)=e=
         sum(f$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss))
         -sum(rr$r_trade(r,rr),trade(i,h,r,rr,e,l,s,ss))$(trading=1 and not legacy(i))
         +sum(rr$r_trade(r,rr),trade(i,h,rr,r,e,l,s,ss))$(trading=1 and not legacy(i)) ;


Eq9_12(r,rr,e,l,s,ss)$r_trans(r,rr) ..
         price_trans(r,rr,e,l,s,ss)
           =e= phi(r,rr)+(tau_pos(r,rr,e,l,s,ss)+tau_neg(r,rr,e,l,s,ss))/d(e,l)
;

Eq9_13(r,rr,e,l,s,ss)$r_trans(r,rr)..
         price_trans(rr,r,e,l,s,ss)
           =e= phi(r,rr)+(tau_pos(r,rr,e,l,s,ss)+tau_neg(r,rr,e,l,s,ss))/d(e,l);


EQ9_14(h,r,e,l,s,ss)$(r_options=1 and not gttocc(h))..
         X(h,r,e,l,s,ss)-Price(r,e,l,s,ss)+P_cap(h,r,e,l)=g=0;

EQ9_15(h,r,e,l,s,ss)$(r_options=1 and not gttocc(h))..
         Omega(h,r,e,l,s,ss)+mu(h,r,e,l,s,ss)-sum(i,sales(i,h,r,e,l,s,ss))=e=0;

EQ9_16(h,r,e,l,s,ss)$(not gttocc(h))..
         M_p(h,r,e,l,s,ss)=e=Price(r,e,l,s,ss)-X(h,r,e,l,s,ss)$(r_options=1);

EqX_1(i,r)..  kind(i,'GT',r)-ret(i,'GT',r)-inv(i,'GTtoCC',r)=g=0;

EqX_2(i,r)$(market_share_inv(i)<1)  ..
                 market_share_inv(i)*sum((j,h),inv(j,h,r))
                         -sum(h,inv(i,h,r))=g=0;


EqX_3(i,r)$(market_share_prod(i)<1)  ..
market_share_prod(i)*sum((h,f,j,e,l,s,ss)$(fuel_set(h,f,r) and not gttocc(h)), Q(j,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))
-sum((h,f,e,l,s,ss)$(fuel_set(h,f,r) and not gttocc(h)),Q(i,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))=g=0;

EqX_4(h,r)$(Genco_PPA(h,r)>0)..
sum((i,f,e,l,s,ss)$(fuel_set(h,f,r) and not gttocc(h)),
         Q(i,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l)) =g=
          Genco_PPA(h,r);


EqX_5(f,r)$(fuel_quota(f,r)>0)..
-sum((i,h,e,l,s,ss)$(fuel_set(h,f,r) and not gttocc(h)),
         Q(i,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l)*heat_rate(h,f)) =g=
          -fuel_quota(f,r);


Eq_q(i,h,f,r,e,l,s,ss)$(fuel_set(h,f,r) and not gttocc(h))..
         Q(i,h,f,r,e,l,s,ss) =g= 0;

Eq_inv(i,h,r)$(not legacy(i)).. inv(i,h,r) =g= 0;

Eq_ret(i,h,r)$(not gttocc(h)) .. ret(i,h,r)=g=0;


Eq_trade(i,h,r,rr,e,l,s,ss)$(trading=1 and r_trade(r,rr) and not legacy(i) and not gttocc(h))..
         trade(i,h,r,rr,e,l,s,ss)=g=0;

Eq_arb(r,rr,e,l,s,ss)$r_trade(r,rr) .. arbitrage(r,rr,e,l,s,ss)=g=0;

EQ_X(h,r,e,l,s,ss)$(r_options=1 and not gttocc(h))..
         X(h,r,e,l,s,ss)=g=0;

model CMO   /
            Eq1,
            Eq2,
            Eq9_1,
            Eq9_2,
            Eq9_3,
            Eq9_4,
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
            EQ9_15,
            EQ9_16,

*            EqX_1.shadows_existing_capacity,
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
            Eq_X.mu
/;
         option MCP=path;
         CMO.scaleopt =1;
*        tau.scale(r,rr,e,l,s,ss)=1e4;
