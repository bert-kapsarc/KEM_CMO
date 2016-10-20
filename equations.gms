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


         trade.fx(i,n,r,rr,e,l,s,ss)$(trading<>1)=0;
*         arbitrage.fx(r,rr,l,s,ss)=0;

*        Fix capacity price
*         delta.l(r,m) = 0;

Equations
         Eq1(r,e,l,s,ss)              Equation (1)
         Eq2(r,e,l)                Equation (1)
         Eq9_1(i,h,r,e,l,s,ss)        Equation (8.1)
         Eq9_2(i,h,r)              Equation (8.2)
         Eq9_3(i,h,r)              Equation (8.3)
         Eq9_4(i,n,r,rr,e,l,s,ss)       Equation (8.4)
         Eq9_5(i,h,r,e,l,s,ss)
         Eq9_6(i,h,r)
         Eq9_7(i,h,r)
         Eq9_8(i,r,e,l,s,ss)

         Eq10_1(n,r,rr,e,l,s,ss)

         Eq11_1(n,e,l,s,ss)
         Eq11_2(n,e,l,s,ss)
         Eq11_3(n,e,l,s,ss)

         Eq_q(i,h,r,e,l,s,ss)
         Eq_inv(i,h,r)
         Eq_ret(i,h,r)
         Eq_trade(i,n,r,rr,e,l,s,ss)
         Eq_arb(n,r,rr,e,l,s,ss)

;
Eq1(r,e,l,s,ss)..    price(r,e,l,s,ss)=e=
                     a(r,e,l,s,ss)-b(r,e,l,s,ss)*sum(j,sales(j,r,e,l,s,ss))
                     +b(r,e,l,s,ss)*(
                          sum((n,rr)$r_trade(n,r,rr),arbitrage(n,r,rr,e,l,s,ss))
                          -sum((n,rr)$r_trade(n,rr,r),arbitrage(n,rr,r,e,l,s,ss))
                     );

Eq2(r,e,m) ..        delta(r,e,m)=e=theta(r,e,m)-xi(r,e,m)*sum((j,hh),beta(hh,r,m)*Cap_avail(j,hh,r));

Eq9_1(i,h,r,e,l,s,ss) ..  price(r,e,l,s,ss)-mc(h,r,s,ss)-b(r,e,l,s,ss)*(1+v(i))*sales(i,r,e,l,s,ss)-lambda_high(i,h,r,e,l,s,ss)+lambda_low(i,h,r,e,l,s,ss)=e= 0 ;
*
Eq9_2(i,h,r)..       sum((e,m),d(e,m)*delta(r,e,m)*beta(h,r,m))
                    -sum((e,m),d(e,m)*xi(r,e,m)*(beta(h,r,m)+z(i))*sum(hh,beta(hh,r,m)*Cap_avail(i,hh,r)))
                     +sum((e,l,s,ss),prob(s,ss)*d(e,l)*lambda_high(i,h,r,e,l,s,ss)) +alpha(i,h,r) =e=ici(h)+om(h);
*

Eq9_3(i,h,r)..      -sum((e,m),d(e,m)*delta(r,e,m)*beta(h,r,m))
                    +sum((e,m),d(e,m)*xi(r,e,m)*(beta(h,r,m)+z(i))*sum(hh,beta(hh,r,m)*Cap_avail(i,hh,r)))
                    -sum((e,l,s,ss),prob(s,ss)*d(e,l)*lambda_high(i,h,r,e,l,s,ss))-eta_high(i,h,r)
                     +eta_low(i,h,r) =e= icr(h)-om(h);
*

Eq9_4(i,n,r,rr,e,l,s,ss)$(trading=1 and r_trade(n,r,rr))..
         price(rr,e,l,s,ss)-price(r,e,l,s,ss)+zeta(i,n,r,rr,e,l,s,ss)
         -price_trans(n,e,l,s,ss)
        +b(r,e,l,s,ss)*sales(i,r,e,l,s,ss)*(1+x(i,r,rr))
        -b(rr,e,l,s,ss)*sales(i,rr,e,l,s,ss)*(1+x(i,rr,r))
                 =e=0;


Eq9_5(i,h,r,e,l,s,ss) ..  Cap_avail(i,h,r)-Q(i,h,r,e,l,s,ss)=g=0;
Eq9_6(i,h,r)..         kind0(i,h,r) - ret(i,h,r)=g=0 ;
Eq9_7(i,h,r)..         Cap_avail(i,h,r) =e= kind0(i,h,r)+inv(i,h,r)-ret(i,h,r);

Eq9_8(i,r,e,l,s,ss)..     sales(i,r,e,l,s,ss)=e=
                         sum(h,Q(i,h,r,e,l,s,ss))
                       -sum((n,rr)$(r_trade(n,r,rr)),trade(i,n,r,rr,e,l,s,ss))$(trading=1)
                       +sum((n,rr)$(r_trade(n,rr,r)),trade(i,n,rr,r,e,l,s,ss))$(trading=1) ;

Eq10_1(n,r,rr,e,l,s,ss)$r_trade(n,r,rr)..
         price(rr,e,l,s,ss)-price(r,e,l,s,ss)
         -price_trans(n,e,l,s,ss)
         +shadows_arbitrage(n,r,rr,e,l,s,ss)
                                 =e=0        ;

Eq11_1(n,e,l,s,ss).. price_trans(n,e,l,s,ss)
                         -phi(n)-tau(n,e,l,s,ss)/d(e,l)
                         =e= 0;

Eq11_2(n,e,l,s,ss)..   kind_trans0(n)-trans(n,e,l,s,ss)=g=0;

Eq11_3(n,e,l,s,ss)..

         trans(n,e,l,s,ss)=g=
                    abs(
                 sum((i,r,rr)$(trans_node(n,r) and r_trade(n,r,rr)),trade(i,n,r,rr,e,l,s,ss))
                 -sum((i,r,rr)$(trans_node(n,r) and r_trade(n,rr,r)),trade(i,n,rr,r,e,l,s,ss))
                 +sum((r,rr)$(trans_node(n,r) and r_trade(n,r,rr)),arbitrage(n,r,rr,e,l,s,ss))
                 -sum((r,rr)$(trans_node(n,r) and r_trade(n,rr,r)),arbitrage(n,rr,r,e,l,s,ss))
           )$(trading=1)
           +sum((r,rr)$(r_trade(n,r,rr)),arbitrage(n,r,rr,e,l,s,ss))$(trading<>1)
         ;

Eq_q(i,h,r,e,l,s,ss)        .. Q(i,h,r,e,l,s,ss) =g= 0;
Eq_inv(i,h,r)            .. inv(i,h,r) =g= 0;
Eq_ret(i,h,r)            .. ret(i,h,r)=g=0;


Eq_trade(i,n,r,rr,e,l,s,ss)$(trading=1 and r_trade(n,r,rr))..
         trade(i,n,r,rr,e,l,s,ss)=g=0;

Eq_arb(n,r,rr,e,l,s,ss)$r_trade(n,r,rr)   .. arbitrage(n,r,rr,e,l,s,ss)=g=0;

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
*        tau.scale(n,e,l,s,ss)=1e4;
