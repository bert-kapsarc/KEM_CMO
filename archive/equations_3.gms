set trans_node(n,r),trans_node_end(n,r);

trans_node('WEST','WOA')=yes;
trans_node_end('WEST','COA')=yes;

trans_node('South','SOA')=yes;
trans_node_end('South','WOA')=yes;

trans_node('East','EOA')=yes;
trans_node_end('East','COA')=yes;


set r_trans(n,r,rr), r_trade(n,r,rr);

r_trans(n,r,rr)$(trans_node(n,r) and trans_node_end(n,rr) and ord(r)<>ord(rr))=yes;
r_trade(n,r,rr)$(r_trans(n,r,rr))=yes;
r_trade(n,rr,r)$(r_trans(n,r,rr))=yes;


*         psi.l(n,e,l,s)=1e-3;
*         trade.fx(i,n,r,rr,e,l,s)=0;
*         arbitrage.fx(r,rr,l,s)=0;

*        Fix capacity price
*         delta.l(r,m) = 0;

Equations
         Eq1(r,e,l,s)              Equation (1)
         Eq2(r,e,l)                Equation (1)
         Eq9_1(i,h,r,e,l,s)        Equation (8.1)
         Eq9_2(i,h,r)              Equation (8.2)
         Eq9_3(i,h,r)              Equation (8.3)
         Eq9_4(i,n,r,rr,e,l,s)       Equation (8.4)
         Eq9_5(i,h,r,e,l,s)
         Eq9_6(i,h,r)
         Eq9_7(i,h,r)
         Eq9_8(i,r,e,l,s)

         Eq10_1(n,r,rr,e,l,s)

         Eq11_1(n,e,l,s)
         Eq11_2(n,e,l,s)
         Eq11_3(n,e,l,s)

         Eq_q(i,h,r,e,l,s)
         Eq_inv(i,h,r)
         Eq_ret(i,h,r)
         Eq_trade(i,n,r,rr,e,l,s)
         Eq_arb(n,r,rr,e,l,s)

;
Eq1(r,e,l,s)..    price(r,e,l,s)=e=
                     a(r,e,l,s)-b(r,e,l,s)*sum(j,sales(j,r,e,l,s))
                     +b(r,e,l,s)*(
                          sum((n,rr)$r_trade(n,r,rr),arbitrage(n,r,rr,e,l,s))
                          -sum((n,rr)$r_trade(n,rr,r),arbitrage(n,rr,r,e,l,s))
                     );

Eq2(r,e,m) ..        delta(r,e,m)=e=theta(r,e,m)-xi(r,e,m)*sum((j,hh),beta(hh,r,m)*Cap_avail(j,hh,r));

Eq9_1(i,h,r,e,l,s) ..  price(r,e,l,s)-mc(h,r,s)-b(r,e,l,s)*(1+v(i))*sales(i,r,e,l,s)-lambda_high(i,h,r,e,l,s)+lambda_low(i,h,r,e,l,s)=e= 0 ;
*
Eq9_2(i,h,r)..       sum((e,m),d(e,m)*delta(r,e,m)*beta(h,r,m))
                    -sum((e,m),d(e,m)*xi(r,e,m)*(beta(h,r,m)+z(i))*sum(hh,beta(hh,r,m)*Cap_avail(i,hh,r)))
                     +sum((e,l,s),prob(s)*d(e,l)*lambda_high(i,h,r,e,l,s)) +alpha(i,h,r) =e=ici(h)+om(h);
*

Eq9_3(i,h,r)..      -sum((e,m),d(e,m)*delta(r,e,m)*beta(h,r,m))
                    +sum((e,m),d(e,m)*xi(r,e,m)*(beta(h,r,m)+z(i))*sum(hh,beta(hh,r,m)*Cap_avail(i,hh,r)))
                    -sum((e,l,s),prob(s)*d(e,l)*lambda_high(i,h,r,e,l,s))-eta_high(i,h,r)
                     +eta_low(i,h,r) =e= icr(h)-om(h);
*

Eq9_4(i,n,r,rr,e,l,s)$r_trade(n,r,rr)..
         price(rr,e,l,s)-price(r,e,l,s)+zeta(i,n,r,rr,e,l,s)
         -price_trans(n,e,l,s)
        +b(r,e,l,s)*sales(i,r,e,l,s)*(1+x(i,r,rr))
        -b(rr,e,l,s)*sales(i,rr,e,l,s)*(1+x(i,rr,r))
                 =e=0;


Eq9_5(i,h,r,e,l,s) ..  Cap_avail(i,h,r)-Q(i,h,r,e,l,s)=g=0;
Eq9_6(i,h,r)..         kind0(i,h,r) - ret(i,h,r)=g=0 ;
Eq9_7(i,h,r)..         Cap_avail(i,h,r) =e= kind0(i,h,r)+inv(i,h,r)-ret(i,h,r);

Eq9_8(i,r,e,l,s)..     sales(i,r,e,l,s)=e=
                         sum(h,Q(i,h,r,e,l,s))
                                 -sum((n,rr)$(r_trade(n,r,rr)),trade(i,n,r,rr,e,l,s))
                                 +sum((n,rr)$(r_trade(n,rr,r)),trade(i,n,rr,r,e,l,s));

Eq10_1(n,r,rr,e,l,s)$r_trade(n,r,rr)..
         price(rr,e,l,s)-price(r,e,l,s)
         -price_trans(n,e,l,s)
         +shadows_arbitrage(n,r,rr,e,l,s)
                                 =e=0        ;

Eq11_1(n,e,l,s).. price_trans(n,e,l,s)
                         -phi(n)-tau(n,e,l,s)/d(e,l)
                         =e= 0;

Eq11_2(n,e,l,s)..   kind_trans0(n)-trans(n,e,l,s)=g=0;

Eq11_3(n,e,l,s)..

         trans(n,e,l,s)=g=
                    abs(
                 sum((i,r,rr)$(trans_node(n,r) and r_trade(n,r,rr)),trade(i,n,r,rr,e,l,s))
                 -sum((i,r,rr)$(trans_node(n,rr) and r_trade(n,rr,r)),trade(i,n,rr,r,e,l,s))
                 +sum((r,rr)$(trans_node(n,r) and r_trade(n,r,rr)),arbitrage(n,r,rr,e,l,s))
                 -sum((r,rr)$(trans_node(n,rr) and r_trade(n,rr,r)),arbitrage(n,rr,r,e,l,s))
           )
         ;

Eq_q(i,h,r,e,l,s)        .. Q(i,h,r,e,l,s) =g= 0;
Eq_inv(i,h,r)            .. inv(i,h,r) =g= 0;
Eq_ret(i,h,r)            .. ret(i,h,r)=g=0;


Eq_trade(i,n,r,rr,e,l,s)$r_trade(n,r,rr)   .. trade(i,n,r,rr,e,l,s)=g=0;

Eq_arb(n,r,rr,e,l,s)$r_trade(n,r,rr)   .. arbitrage(n,r,rr,e,l,s)=g=0;

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

            Eq10_1,
            Eq11_1,
            Eq11_2.tau,
            Eq11_3.price_trans

            Eq_q.lambda_low,
            Eq_trade.zeta,
            Eq_inv.alpha,
            Eq_ret.eta_low,
            Eq_arb.shadows_arbitrage,
/;
         option MCP=path;
        CMO.scaleopt =1;
        tau.scale(n,e,l,s)=1e4;
