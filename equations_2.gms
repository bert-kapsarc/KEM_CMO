

set r_trans(r,rr);

r_trans(r,rr)$(kind_trans0(r,rr)>0)=yes;


         trade.fx(i,r,rr,e,l,s)=0;
*         arbitrage.fx(r,rr,l,s)=0;

*        Fix capacity price
*         delta.l(r,m) = 0;

Equations
         Eq1(r,e,l,s)              Equation (1)
         Eq2(r,e,l)                Equation (1)
         Eq8_1(i,h,r,e,l,s)        Equation (8.1)
         Eq8_2(i,h,r)              Equation (8.2)
         Eq8_3(i,h,r)              Equation (8.3)
         Eq8_4(i,r,rr,e,l,s)       Equation (8.4)
         Eq8_5(i,h,r,e,l,s)
         Eq8_6(i,h,r)
         Eq8_7(i,h,r)
         Eq8_8(i,r,e,l,s)

         Eq9_1(r,rr,e,l,s)
         Eq9_2(r,rr,e,l,s)
         Eq9_3(r,rr,e,l,s)
         Eq9_4(r,rr,e,l,s)

         Eq_q(i,h,r,e,l,s)
         Eq_inv(i,h,r)
         Eq_ret(i,h,r)
         Eq_trade(i,r,rr,e,l,s)
         Eq_arb(r,rr,e,l,s)
         Eq_trans(r,rr,e,l,s)

;
Eq1(r,e,l,s)..    price(r,e,l,s)=e=
                     a(r,e,l,s)-b(r,e,l,s)*sum((h,j),q(j,h,r,e,l,s))
                     +b(r,e,l,s)*(sum(rr$r_trans(r,rr),arbitrage(r,rr,e,l,s))-sum(rr$r_trans(rr,r),arbitrage(rr,r,e,l,s))) ;

Eq2(r,e,m) ..        delta(r,e,m)=e=theta(r,e,m)-xi(r,e,m)*sum((j,hh),beta(hh,r,m)*Cap_avail(j,hh,r));

Eq8_1(i,h,r,e,l,s) ..  price(r,e,l,s)-mc(h,r,s)-b(r,e,l,s)*(1+v(i))*q(i,h,r,e,l,s)-lambda_high(i,h,r,e,l,s)+lambda_low(i,h,r,e,l,s)=e= 0 ;
*
Eq8_2(i,h,r)..       sum((e,m),d(e,m)*delta(r,e,m)*beta(h,r,m))
                    -sum((e,m),d(e,m)*xi(r,e,m)*(beta(h,r,m)+z(i))*sum(hh,beta(hh,r,m)*Cap_avail(i,hh,r)))
                     +sum((e,l,s),prob(s)*d(e,l)*lambda_high(i,h,r,e,l,s)) +alpha(i,h,r) =e=ici(h)+om(h);
*

Eq8_3(i,h,r)..      -sum((e,m),d(e,m)*delta(r,e,m)*beta(h,r,m))
                    +sum((e,m),d(e,m)*xi(r,e,m)*(beta(h,r,m)+z(i))*sum(hh,beta(hh,r,m)*Cap_avail(i,hh,r)))
                    -sum((e,l,s),prob(s)*d(e,l)*lambda_high(i,h,r,e,l,s))-eta_high(i,h,r)
                     +eta_low(i,h,r) =e= icr(h)-om(h);
*

Eq8_4(i,r,rr,e,l,s)$r_trans(r,rr).. price(rr,e,l,s)-price(r,e,l,s)-price_trans(r,rr,e,l,s)
                     +b(r,e,l,s)*sales(i,r,e,l,s)*(1+x(i,r,rr))
                     -b(rr,e,l,s)*sales(i,rr,e,l,s)*(1+x(i,rr,r))+zeta(i,r,rr,e,l,s)   =e=0;
*

Eq8_5(i,h,r,e,l,s) ..  Cap_avail(i,h,r)-Q(i,h,r,e,l,s)=g=0;
Eq8_6(i,h,r)..         kind0(i,h,r) - ret(i,h,r)=g=0 ;
Eq8_7(i,h,r)..         Cap_avail(i,h,r) =e= kind0(i,h,r)+inv(i,h,r)-ret(i,h,r);

Eq8_8(i,r,e,l,s)..     sales(i,r,e,l,s)=e=
                         sum(h,Q(i,h,r,e,l,s))-sum(rr$r_trans(r,rr),trade(i,r,rr,e,l,s))+sum(rr$r_trans(rr,r),trade(i,rr,r,e,l,s));

Eq9_1(r,rr,e,l,s)$r_trans(r,rr)..    price(rr,e,l,s)-price(r,e,l,s)
                         -price_trans(r,rr,e,l,s)
*                         -shadows_trans_balance(r,rr,e,l,s)
                         +shadows_arb(r,rr,e,l,s)
                         =e= 0;
*

Eq9_2(r,rr,e,l,s)$r_trans(r,rr)..   price_trans(r,rr,e,l,s)-phi(r,rr)-tau(r,rr,e,l,s)/d(e,l)
*                         +shadows_trans_balance(r,rr,e,l,s)
*                         +shadows_trans_low(r,rr,e,l,s)
                                 =e=0
;

Eq9_3(r,rr,e,l,s)$r_trans(r,rr)..   kind_trans0(r,rr)-arbitrage(r,rr,e,l,s)=g=0;

*Eq9_4(r,rr,e,l,s)$r_trans(r,rr)..   (-sum(i,trade(i,r,rr,e,l,s))-arbitrage(r,rr,e,l,s)+trans(r,rr,e,l,s))=e=0;


Eq_q(i,h,r,e,l,s)        .. Q(i,h,r,e,l,s) =g= 0;
Eq_inv(i,h,r)            .. inv(i,h,r) =g= 0;
Eq_ret(i,h,r)            .. ret(i,h,r)=g=0;
Eq_trade(i,r,rr,e,l,s)$r_trans(r,rr)   .. trade(i,r,rr,e,l,s)=g=0;
Eq_arb(r,rr,e,l,s)$r_trans(r,rr)       .. arbitrage(r,rr,e,l,s)=g=0;


Eq_trans(r,rr,e,l,s)$r_trans(r,rr)     .. trans(r,rr,e,l,s)*trans(rr,r,e,l,s)=e=0;


model CMO   /
            Eq1,
            Eq2,
            Eq8_1,
            Eq8_2,
            Eq8_3,
*            Eq8_4,
            Eq8_5.lambda_high,
            Eq8_6.eta_high,
            Eq8_7,
*            Eq8_8,
            Eq9_1,
            Eq9_2,

            Eq9_3.tau ,
*            Eq9_4,
*            Eq9_4.shadows_trans_balance,

            Eq_q.lambda_low,
*            Eq_trade.zeta,
            Eq_inv.alpha,
            Eq_ret.eta_low,
            Eq_arb.shadows_arb,
*            Eq_trans
/;
         option MCP=path;
        CMO.scaleopt =1;
        tau.scale(r,rr,e,l,s)=1e4;
