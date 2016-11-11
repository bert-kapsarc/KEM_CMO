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

Equations
         Eq1(r,e,l,s,ss)              Equation (1)
         Eq2(r,e,l)                Equation (1)
         Eq9_1(company,h,r,e,l,s,ss)        Equation (8.1)
         Eq9_2(company,h,r)              Equation (8.2)
         Eq9_3(company,h,r)              Equation (8.3)
         Eq9_4(company,n,r,rr,e,l,s,ss)       Equation (8.4)
         Eq9_5(company,h,r,e,l,s,ss)
         Eq9_5a(company,h,r)
         Eq9_6(company,h,r)
         Eq9_7(company,h,r)
         Eq9_8(company,r,e,l,s,ss)

         Eq10_1(n,r,rr,e,l,s,ss)

         Eq11_1(n,e,l,s,ss)
         Eq11_2(n,e,l,s,ss)
         Eq11_3(n,e,l,s,ss)
         Eq11_4(n,e,l,s,ss)
         Eq11_5(n,e,l,s,ss)

         Eq_q(company,h,r,e,l,s,ss)
         Eq_inv(company,h,r)
         Eq_ret(company,h,r)
         Eq_trade(company,n,r,rr,e,l,s,ss)
         Eq_arb(n,r,rr,e,l,s,ss)

;
Eq1(r,e,l,s,ss)..    price(r,e,l,s,ss)=e=
                     a(r,e,l,s,ss)-b(r,e,l,s,ss)*sum(j,sales(j,r,e,l,s,ss))
                     +b(r,e,l,s,ss)*(
                          sum((n,rr)$r_trade(n,r,rr),arbitrage(n,r,rr,e,l,s,ss))
                          -sum((n,rr)$r_trade(n,rr,r),arbitrage(n,rr,r,e,l,s,ss))
                     );

Eq2(r,e,l)$m(r,e,l) ..        delta(r,e,l)=e=theta(r,e,l)-xi(r,e,l)*sum((j,hh)$(not gttocc(hh)),beta(hh,r,l)*Cap_avail(j,hh,r));

Eq9_1(i,h,r,e,l,s,ss)$(not gttocc(h)) ..  price(r,e,l,s,ss)-mc(h,r,s,ss)-b(r,e,l,s,ss)*(1+v(i))*sales(i,r,e,l,s,ss)-lambda_high(i,h,r,e,l,s,ss)+lambda_low(i,h,r,e,l,s,ss)=e= 0 ;
*
Eq9_2(i,h,r)..       sum((e,l)$m(r,e,l),d(e,l)*delta(r,e,l)*beta(h,r,l))
                    -sum((e,l)$m(r,e,l),d(e,l)*xi(r,e,l)*(beta(h,r,l)+z(i))*sum(hh,beta(hh,r,l)*Cap_avail(i,hh,r)))
                     +sum((hh,e,l,s,ss)$(not gttocc(hh)),prob(r,e,l,s,ss)*d(e,l)*lambda_high(i,hh,r,e,l,s,ss)*capadd(h,hh))
                     -shadows_gttocc(i,h,r)$gttocc(h)
                     +alpha(i,h,r) =e=ici(h)+om(h);
*

Eq9_3(i,h,r)$(not gttocc(h))..      -sum((e,l)$m(r,e,l),d(e,l)*delta(r,e,l)*beta(h,r,l))
                    +sum((e,l)$m(r,e,l),d(e,l)*xi(r,e,l)*(beta(h,r,l)+z(i))*sum(hh,beta(hh,r,l)*Cap_avail(i,hh,r)))
                    -sum((e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*lambda_high(i,h,r,e,l,s,ss))-eta_high(i,h,r)
                     +eta_low(i,h,r) =e= icr(h)-om(h);
*

Eq9_4(i,n,r,rr,e,l,s,ss)$(trading=1 and r_trade(n,r,rr))..
         price(rr,e,l,s,ss)-price(r,e,l,s,ss)+zeta(i,n,r,rr,e,l,s,ss)
         -price_trans(n,e,l,s,ss)
        +b(r,e,l,s,ss)*sales(i,r,e,l,s,ss)*(1+x(i,r,rr))
        -b(rr,e,l,s,ss)*sales(i,rr,e,l,s,ss)*(1+x(i,rr,r))
                 =e=0;

Eq9_5(i,h,r,e,l,s,ss)$(not gttocc(h)) ..  Cap_avail(i,h,r)-Q(i,h,r,e,l,s,ss)=g=0;

Eq9_5a(i,h,r)$(gttocc(h)) ..  (kind0(i,'GT',r)-ret(i,'GT',r))=g=inv(i,h,r);

Eq9_6(i,h,r)$(not gttocc(h))..  kind0(i,h,r) - ret(i,h,r)=g=0 ;
Eq9_7(i,h,r)$(not gttocc(h))..  Cap_avail(i,h,r) =e= kind0(i,h,r)+sum(hh,inv(i,hh,r)*capadd(hh,h))-ret(i,h,r);

Eq9_8(i,r,e,l,s,ss)..     sales(i,r,e,l,s,ss)=e=
                         sum(h$(not gttocc(h)),Q(i,h,r,e,l,s,ss))
                       -sum((n,rr)$(r_trade(n,r,rr)),trade(i,n,r,rr,e,l,s,ss))$(trading=1)
                       +sum((n,rr)$(r_trade(n,rr,r)),trade(i,n,rr,r,e,l,s,ss))$(trading=1) ;

*Eq9_9(i,h,r).. kind0(i,h,r)-kind(i,h,r)=g=0  ;

Eq10_1(n,r,rr,e,l,s,ss)$r_trade(n,r,rr)..
         price(rr,e,l,s,ss)-price(r,e,l,s,ss)
         -price_trans(n,e,l,s,ss)
         +shadows_arbitrage(n,r,rr,e,l,s,ss)
                                 =e=0        ;

Eq11_1(n,e,l,s,ss).. price_trans_pos(n,e,l,s,ss)+price_trans_neg(n,e,l,s,ss)$(trading=1)
                         -phi(n)-tau(n,e,l,s,ss)/d(e,l)
                         =e= 0;

Eq11_2(n,e,l,s,ss)..

         trans(n,e,l,s,ss)=g=
         (
                 sum((i,r,rr)$(trans_node(n,r) and r_trade(n,r,rr)),trade(i,n,r,rr,e,l,s,ss))
                 -sum((i,r,rr)$(trans_node(n,r) and r_trade(n,rr,r)),trade(i,n,rr,r,e,l,s,ss))
                 +sum((r,rr)$(trans_node(n,r) and r_trade(n,r,rr)),arbitrage(n,r,rr,e,l,s,ss))
                 -sum((r,rr)$(trans_node(n,r) and r_trade(n,rr,r)),arbitrage(n,rr,r,e,l,s,ss))
           )$(trading=1)
           +sum((r,rr)$(r_trade(n,r,rr)),arbitrage(n,r,rr,e,l,s,ss))$(trading<>1)
         ;


Eq11_3(n,e,l,s,ss)$(trading=1)..

         trans(n,e,l,s,ss)=g=
         -(
                 sum((i,r,rr)$(trans_node(n,r) and r_trade(n,r,rr)),trade(i,n,r,rr,e,l,s,ss))
                 -sum((i,r,rr)$(trans_node(n,r) and r_trade(n,rr,r)),trade(i,n,rr,r,e,l,s,ss))
                 +sum((r,rr)$(trans_node(n,r) and r_trade(n,r,rr)),arbitrage(n,r,rr,e,l,s,ss))
                 -sum((r,rr)$(trans_node(n,r) and r_trade(n,rr,r)),arbitrage(n,rr,r,e,l,s,ss))
           )
         ;

Eq11_4(n,e,l,s,ss)..   kind_trans0(n)-trans(n,e,l,s,ss)=g=0;


Eq11_5(n,e,l,s,ss)..   price_trans(n,e,l,s,ss)=e=
                         price_trans_pos(n,e,l,s,ss)+price_trans_neg(n,e,l,s,ss)$(trading=1);



Eq_q(i,h,r,e,l,s,ss)$(not gttocc(h))     .. Q(i,h,r,e,l,s,ss) =g= 0;
Eq_inv(i,h,r)                            .. inv(i,h,r) =g= 0;
Eq_ret(i,h,r)$(not gttocc(h))            .. ret(i,h,r)=g=0;


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

            Eq9_5a.shadows_gttocc,

            Eq9_6.eta_high,
            Eq9_7,
            Eq9_8,

            Eq10_1,
            Eq11_1,
            Eq11_2.price_trans_pos
            Eq11_3.price_trans_neg,
            Eq11_4.tau,
            EQ11_5,

            Eq_q.lambda_low,
            Eq_trade.zeta,
            Eq_inv.alpha,
            Eq_ret.eta_low,
            Eq_arb.shadows_arbitrage,
/;
         option MCP=path;
        CMO.scaleopt =1;
*        tau.scale(n,e,l,s,ss)=1e4;
