set r_trans(r,rr);
set r_trade(r,rr);

r_trans(r,rr)$(ord(r)<ord(rr) and kind_trans0(r,rr)>0)=yes;

r_trade(r,rr)$(r_trans(r,rr) or r_trans(rr,r)) = yes;

         trade.fx(i,r,rr,e,l,s,ss)$(trading<>1)=0;

Equations
         Eq1(r,e,l,s,ss)              Equation (1)
         Eq2(r,e,l)                Equation (1)
         Eq9_1(company,h,r,e,l,s,ss)        Equation (8.1)
         Eq9_2(company,h,r)              Equation (8.2)
         Eq9_3(company,h,r)              Equation (8.3)
         Eq9_4(company,r,rr,e,l,s,ss)       Equation (8.4)
         Eq9_5(company,h,r,e,l,s,ss)

         Eq9_6(company,h,r)
         Eq9_7(company,h,r)
         Eq9_8(company,r,e,l,s,ss)
         Eq9_9(company,h,r)
         Eq9_10(company,r)
         Eq9_11(company,r)

         Eq10_1(r,rr,e,l,s,ss)
         Eq10_1a(r,rr,e,l,s,ss)

         Eq11_1(r,rr,e,l,s,ss)
         Eq11_2(r,rr,e,l,s,ss)
         Eq11_3(r,rr,e,l,s,ss)
         Eq11_4(r,rr,e,l,s,ss)

         Eq_q(company,h,r,e,l,s,ss)
         Eq_inv(company,h,r)
         Eq_ret(company,h,r)
         Eq_trade(company,r,rr,e,l,s,ss)
         Eq_arb(r,rr,e,l,s,ss)
;
Eq1(r,e,l,s,ss)..    price(r,e,l,s,ss)=e=
                     a(r,e,l,s,ss)-b(r,e,l,s,ss)*sum(j,sales(j,r,e,l,s,ss))
                     +b(r,e,l,s,ss)*(
                          sum((rr)$r_trade(r,rr),arbitrage(r,rr,e,l,s,ss))
                          -sum((rr)$r_trade(r,rr),arbitrage(rr,r,e,l,s,ss))
                     );

Eq2(r,e,l)$m(r,e,l) ..        delta(r,e,l)=e=theta(r,e,l)-xi(r,e,l)*sum((j,hh)$(not gttocc(hh)),Cap_avail(j,hh,r));

Eq9_1(i,h,r,e,l,s,ss)$(not gttocc(h)) ..
price(r,e,l,s,ss)-mc(h,r,s,ss)-b(r,e,l,s,ss)*(1+v(i))*sales(i,r,e,l,s,ss)-lambda_high(i,h,r,e,l,s,ss)+lambda_low(i,h,r,e,l,s,ss)=e= 0 ;
*

Eq9_2(i,h,r)..       sum((e,l)$m(r,e,l),d(e,l)*delta(r,e,l))
                    -sum((e,l)$m(r,e,l),d(e,l)*xi(r,e,l)*(1+z(i))*sum(hh,Cap_avail(i,hh,r)))
                     +sum((hh,e,l,s,ss)$(not gttocc(hh)),prob(r,e,l,s,ss)*d(e,l)*lambda_high(i,hh,r,e,l,s,ss)*capadd(h,hh))
                     -shadows_gttocc(i,r)$gttocc(h)
                     +alpha(i,h,r)
                     +(market_share_cap(i)-1)*shadows_inv_cap(i,r)

                         =e=beta(i)*(ici(h)+om(h));
*

Eq9_11(i,r)$(market_share_cap(i)<1)  ..           market_share_cap(i)*sum((j,h),inv(j,h,r))
                         -sum(h,inv(i,h,r))=g=0;

Eq9_3(i,h,r)$(not gttocc(h))..      -sum((e,l)$m(r,e,l),d(e,l)*delta(r,e,l))
                    +sum((e,l)$m(r,e,l),d(e,l)*xi(r,e,l)*(1+z(i))*sum(hh,Cap_avail(i,hh,r)))
                    -sum((e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*lambda_high(i,h,r,e,l,s,ss))-eta_high(i,h,r)
                     -shadows_gttocc(i,r)$gt(h)
                     +eta_low(i,h,r) =e= icr(h)-beta(i)*om(h);
*

Eq9_4(i,r,rr,e,l,s,ss)$(trading=1 and r_trade(r,rr))..
         price(rr,e,l,s,ss)-price(r,e,l,s,ss)+zeta(i,r,rr,e,l,s,ss)
         -price_trans(r,rr,e,l,s,ss)
        +b(r,e,l,s,ss)*sales(i,r,e,l,s,ss)*(1+v(i))
        -b(rr,e,l,s,ss)*sales(i,rr,e,l,s,ss)*(1+v(i))
                 =e=0;

Eq9_5(i,h,r,e,l,s,ss)$(not gttocc(h)) ..  Cap_avail(i,h,r)-Q(i,h,r,e,l,s,ss)=g=0;

Eq9_6(i,h,r)$(not gttocc(h))..  kind(i,h,r) - ret(i,h,r)=g=0 ;
Eq9_7(i,h,r)$(not gttocc(h))..  Cap_avail(i,h,r) =e= kind(i,h,r)+sum(hh,inv(i,hh,r)*capadd(hh,h))-ret(i,h,r);

Eq9_8(i,r,e,l,s,ss)..     sales(i,r,e,l,s,ss)=e=
                         sum(h$(not gttocc(h)),Q(i,h,r,e,l,s,ss))
                       -sum((rr)$r_trade(r,rr),trade(i,r,rr,e,l,s,ss))$(trading=1)
                       +sum((rr)$r_trade(r,rr),trade(i,rr,r,e,l,s,ss))$(trading=1) ;

Eq9_9(i,h,r).. kind0(i,h,r)-kind(i,h,r)=e=0  ;

Eq9_10(i,r) ..  (kind(i,'GT',r)-ret(i,'GT',r))=g=inv(i,'GTtoCC',r);

Eq10_1(r,rr,e,l,s,ss)$r_trade(r,rr)..
         price(rr,e,l,s,ss)-price(r,e,l,s,ss)
         -price_trans(r,rr,e,l,s,ss)
         +shadows_arbitrage(r,rr,e,l,s,ss)
                                 =e=0        ;


Eq11_1(r,rr,e,l,s,ss)$r_trans(r,rr)..

         kind_trans0(r,rr)=g=
                 sum(i,trade(i,r,rr,e,l,s,ss))$(trading=1)
                 -sum(i,trade(i,rr,r,e,l,s,ss))$(trading=1)
                 +arbitrage(r,rr,e,l,s,ss)
;

Eq11_2(r,rr,e,l,s,ss)$r_trans(r,rr)..

         kind_trans0(r,rr)=g=
                 sum(i,trade(i,rr,r,e,l,s,ss))$(trading=1)
                 -sum(i,trade(i,r,rr,e,l,s,ss))$(trading=1)
                 +arbitrage(rr,r,e,l,s,ss)
;


Eq11_3(r,rr,e,l,s,ss)$r_trans(r,rr) ..
         price_trans(r,rr,e,l,s,ss)
                         =e=  phi(r,rr)+tau_pos(r,rr,e,l,s,ss)/d(e,l)


;
Eq11_4(r,rr,e,l,s,ss)$r_trans(r,rr)..
         price_trans(rr,r,e,l,s,ss)
                         =e= phi(r,rr)+tau_neg(r,rr,e,l,s,ss)/d(e,l)

;


Eq_q(i,h,r,e,l,s,ss)$(not gttocc(h))     .. Q(i,h,r,e,l,s,ss) =g= 0;
Eq_inv(i,h,r)                            .. inv(i,h,r) =g= 0;
Eq_ret(i,h,r)$(not gttocc(h))            .. ret(i,h,r)=g=0;


Eq_trade(i,r,rr,e,l,s,ss)$(trading=1 and r_trade(r,rr))..
         trade(i,r,rr,e,l,s,ss)=g=0;

Eq_arb(r,rr,e,l,s,ss)$r_trade(r,rr) .. arbitrage(r,rr,e,l,s,ss)=g=0;

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
            Eq9_8,
            Eq9_9,
            Eq9_10.shadows_gttocc,
            EQ9_11.shadows_inv_cap

            Eq10_1,
            Eq11_1.tau_pos,
            Eq11_2.tau_neg,
            EQ11_3,
            EQ11_4,

            Eq_q.lambda_low,
            Eq_trade.zeta,
            Eq_inv.alpha,
            Eq_ret.eta_low,
            Eq_arb.shadows_arbitrage
/;
         option MCP=path;
        CMO.scaleopt =1;
*        tau.scale(r,rr,e,l,s,ss)=1e4;
