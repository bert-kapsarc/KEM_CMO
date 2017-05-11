
$ontext
Eq9_1(i,h,f,r,e,l,s,ss)$(fuel_set(h,f,r) and not gttocc(h)) ..
         price(r,e,l,s,ss)+Z(r,e,l,s,ss)*v(i)
         +b(r,e,l,s,ss)*(1+v(i))*(Omega(i,h,r,e,l,s,ss)$(r_options=1)-sales(i,r,e,l,s,ss))
         -lambda_high(i,h,r,e,l,s,ss)
         +shadows_genco_ppa(h,r)$(Genco_PPA(h,r)>0)
         +(market_share_prod(i)*(1+v(i))-1)*shadows_prod_cap(i,r)$(market_share_prod(i)<1)
         -shadows_fuel_alloc(f,r)*heat_rate(h,f)$(fuel_quota(f,r)>0)
         +mu_high(i,r,seasons,l,s,ss)
         +lambda_low(i,h,f,r,e,l,s,ss)=e= mc(h,f,r) ;
*

Eq9_2(i,h,r)..
          sum((e,l)$m(r,e,l),d(e,l)*delta(r,e,l))*sum(hh$(not gttocc(hh)),capadd(h,hh))
         -sum((e,l)$m(r,e,l),d(e,l)*xi(r,e,l)*(1+X(i))*
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
         +psi_high(i,e,l)
         +alpha(i,h,r)
         +(market_share_inv(i)*(1+X(i))-1)*shadows_inv_cap(i,r)$(market_share_inv(i)<1)

                         =e=
        ici(h)+ sum(hh$(not gttocc(hh)),capadd(h,hh)*om(hh))
;

*

Eq9_3(i,h,r)$(not gttocc(h))..
         -sum((e,l)$m(r,e,l),d(e,l)*delta(r,e,l))
         +sum((e,l)$m(r,e,l),d(e,l)*xi(r,e,l)*(1+X(i))*
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
         +eta_low(i,h,r)
         -psi_high(i,e,l)
          =e= (icr(h)-om(h));

Eq9_4(i,r,rr,e,l,s,ss)$(trading=1 and r_trade(r,rr) and not gttocc(h))..
         P(rr,e,l,s,ss)-P(r,e,l,s,ss)+zeta(r,rr,e,l,s,ss)
         -price_trans(r,rr,e,l,s,ss)
        +b(r,e,l,s,ss)*sales(i,r,e,l,s,ss)*(1+v(i))
        -b(rr,e,l,s,ss)*sales(i,rr,e,l,s,ss)*(1+v(i))
                 =e=0;

Eq9_5(i,h,r,e,l,s,ss)$(not gttocc(h)) ..
         Cap_avail(i,h,r)*(
                 1$(not ren(h))
                 +ELwindpowernorm(l,e,r)$WT(h)
                 +Elsolcurvenorm(l,e,r)$PV(h)
         )
         -sum(f$fuel_set(h,f,r),Q(i,h,f,r,ELs,Ell,s,ss))=g=0;

Eq9_6(i,h,r)$(not gttocc(h))..  kind(i,h,r) - ret(i,h,r)=g=0 ;


Eq9_7(r,rr,e,l,s,ss)$r_trade(r,rr)..
         price(rr,e,l,s,ss)-price(r,e,l,s,ss)
         -price_trans(r,rr,e,l,s,ss)
         +shadows_arbitrage(r,rr,e,l,s,ss) =e=0        ;

Eq9_8(r,rr,e,l,s,ss)$r_trans(r,rr)..

         kind_trans0(r,rr)=g=
                  sum((i,h)$(not gttocc(h)),trade(i,h,r,rr,e,l,s,ss))$(trading=1)
                 -sum((i,h)$(not gttocc(h)),trade(i,h,rr,r,e,l,s,ss))$(trading=1)
                 +arbitrage(r,rr,e,l,s,ss)
;

Eq9_9(r,rr,e,l,s,ss)$r_trans(r,rr)..
         kind_trans0(r,rr)=g=
                  sum((i,h)$(not gttocc(h)),trade(i,h,rr,r,e,l,s,ss))$(trading=1)
                 -sum((i,h)$(not gttocc(h)),trade(i,h,r,rr,e,l,s,ss))$(trading=1)
                 +arbitrage(rr,r,e,l,s,ss)
;

Eq9_10(i,h,r)$(not gttocc(h))..
         Cap_avail(i,h,r) =e= kind(i,h,r)+sum(hh,inv(i,hh,r)*capadd(hh,h))-ret(i,h,r);

Eq9_11(i,h,r,e,l,s,ss)$(not gttocc(h))..
         sales(i,r,e,l,s,ss)=e=
         sum((f,h)$fuel_set(h,f,r),Q(i,h,f,r,e,l,s,ss))
         -sum(rr$r_trade(r,rr),trade(i,r,rr,e,l,s,ss))$(trading=1)
         +sum(rr$r_trade(r,rr),trade(i,rr,r,e,l,s,ss))$(trading=1) ;


Eq9_12(r,rr,e,l,s,ss)$r_trans(r,rr) ..
         price_trans(r,rr,e,l,s,ss)
           =e= phi(r,rr)+(tau_pos(r,rr,e,l,s,ss)+tau_neg(r,rr,e,l,s,ss))/d(e,l)
;

Eq9_13(r,rr,e,l,s,ss)$r_trans(r,rr)..
         price_trans(rr,r,e,l,s,ss)
           =e= phi(r,rr)+(tau_pos(r,rr,e,l,s,ss)+tau_neg(r,rr,e,l,s,ss))/d(e,l);


EQ9_14(g,r,e,l,s,ss)$(r_options=1)..
         Z(g,r,e,l,s,ss)-Price(r,e,l,s,ss)+P_cap(g,r,e,l)=g=0;

EQ9_15(r,e,l,s,ss)$(r_options=1)..
         Omega(r,e,l,s,ss)+sum(i,sales(i,r,e,l,s,ss))=g=Sales_bar(r,e,l,s,ss);

EQ9_16(g,r,e,l,s,ss)..
         M_p(g,r,e,l,s,ss)=e=Price(r,e,l,s,ss)-Z(g,r,e,l,s,ss)$(r_options=1);

EQ9_17(i,r,e,l,s,ss).. U(i,r,e,l,s,ss) =g= sales(i,r,e,l,s,ss) - K(i,r,e,l);

EQ9_18(i,r,e,l,s,ss)..  sales(i,r,e,l,s,ss) =g= U(i,r,e,l,s,ss) ;

EQ9_19(i,e,l).. sum((h,r), Cap_avail(i,h,r)) =g= sum(r,K(i,r,e,l)) ;



EqX_1(i,r)..  kind(i,'GT',r)-ret(i,'GT',r)-inv(i,'GTtoCC',r)=g=0;

EqX_2(i,r)$(market_share_inv(i)<1)  ..
                 market_share_inv(i)*sum((ii,h),inv(ii,h,r))
                         -sum(h,inv(i,h,r))=g=0;


EqX_3(i,r)$(market_share_prod(i)<1)  ..
market_share_prod(i)*sum((h,f,ii,e,l,s,ss)$(fuel_set(h,f,r) and not gttocc(h)), Q(ii,h,f,r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l))
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

Eq_inv(i,h,r).. inv(i,h,r) =g= 0;

Eq_ret(i,h,r)$(not gttocc(h)) .. ret(i,h,r)=g=0;


Eq_trade(i,h,r,rr,e,l,s,ss)$(trading=1 and r_trade(r,rr)and not gttocc(h))..
         trade(i,h,r,rr,e,l,s,ss)=g=0;

Eq_arb(r,rr,e,l,s,ss)$r_trade(r,rr) .. arbitrage(r,rr,e,l,s,ss)=g=0;

$offtext