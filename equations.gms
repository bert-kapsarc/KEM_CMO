

*         trade.fx(i,r,rr,l,s)=0;
*         arb.fx(r,rr,l,s)=0;

*        Fix capacity price
*         capacity_price.l(r,m) = 0;

Equations
         Eq1(r,e,l,s)              Equation (1)
         Eq2(r,e,m)                Equation (1)
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
                     a(r,e,l,s)-b(r,e,l,s)*sum(j,sales(j,r,e,l,s))
                     +b(r,e,l,s)*(sum(rr,arb(r,rr,e,l,s))-sum(rr,arb(rr,r,e,l,s))) ;

Eq2(r,e,m) ..        capacity_price(r,e,m)=e=theta(r,e,m)-xi(r,e,m)*sum((j,hh),beta(hh,r,m)*Cap_avail(j,hh,r));

Eq8_1(i,h,r,e,l,s) ..  price(r,e,l,s)-mc(h,r,s)-b(r,e,l,s)*(1+v(i))*sales(i,r,e,l,s)-shadows_high(i,h,r,e,l,s)+shadows_low(i,h,r,e,l,s)=e= 0 ;
*
Eq8_2(i,h,r)..       sum((e,m),d(e,m)*capacity_price(r,e,m)*beta(h,r,m))
                    -sum((e,m),d(e,m)*xi(r,e,m)*(beta(h,r,m)+z(i))*sum(hh,beta(hh,r,m)*Cap_avail(i,hh,r)))
                     +sum((e,l,s),prob(s)*d(e,l)*shadows_high(i,h,r,e,l,s)) +shadows_inv(i,h,r) =e=ici(h)+om(h);
*

Eq8_3(i,h,r)..      -sum((e,m),d(e,m)*capacity_price(r,e,m)*beta(h,r,m))
                    +sum((e,m),d(e,m)*xi(r,e,m)*(beta(h,r,m)+z(i))*sum(hh,beta(hh,r,m)*Cap_avail(i,hh,r)))
                    -sum((e,l,s),prob(s)*d(e,l)*shadows_high(i,h,r,e,l,s))-shadows_retirment_high(i,h,r)
                     +shadows_retirment_low(i,h,r) =e= icr(h)-om(h);
*

Eq8_4(i,r,rr,e,l,s).. price(rr,e,l,s)-price(r,e,l,s)-price_trans(r,rr,e,l,s)
                     +b(r,e,l,s)*sales(i,r,e,l,s)*(1+x(i,r,rr))
                     -b(rr,e,l,s)*sales(i,rr,e,l,s)*(1+x(i,rr,r)) +shadows_trade(i,r,rr,e,l,s)   =e=0;
*

Eq8_5(i,h,r,e,l,s) ..  Cap_avail(i,h,r)-q(i,h,r,e,l,s)=g=0;
Eq8_6(i,h,r)..         kind0(i,h,r) - ret(i,h,r)=g=0 ;
Eq8_7(i,h,r)..         Cap_avail(i,h,r) =e= kind0(i,h,r)+inv(i,h,r)-ret(i,h,r);

Eq8_8(i,r,e,l,s)..     sales(i,r,e,l,s)=e=
                         sum(h,q(i,h,r,e,l,s))-sum(rr,trade(i,r,rr,e,l,s))+sum(rr,trade(i,rr,r,e,l,s));

Eq9_1(r,rr,e,l,s)..    price(rr,e,l,s)-price(r,e,l,s)
                         -price_trans(r,rr,e,l,s)
*                         +shadows_trans_balance(r,rr,e,l,s)
                         +shadows_arb(r,rr,e,l,s)
                         =e= 0;
*

Eq9_2(r,rr,e,l,s)..   price_trans(r,rr,e,l,s)-phi(r,rr)-shadows_trans_high(r,rr,e,l,s)/d(e,l)
*                         -shadows_trans_balance(r,rr,e,l,s)
                                 =e=0
;

Eq9_3(r,rr,e,l,s)..   kind_trans0(r,rr)-trans(r,rr,e,l,s)=g=0;
Eq9_4(r,rr,e,l,s)..   sum(i,trade(i,r,rr,e,l,s))+arb(r,rr,e,l,s)-trans(r,rr,e,l,s)=e=0;

Eq_q(i,h,r,e,l,s)        .. q(i,h,r,e,l,s) =g= 0;
Eq_inv(i,h,r)            .. inv(i,h,r) =g= 0;
Eq_ret(i,h,r)            .. ret(i,h,r)=g=0;
Eq_trade(i,r,rr,e,l,s)   .. trade(i,r,rr,e,l,s)=g=0;
Eq_arb(r,rr,e,l,s)       .. arb(r,rr,e,l,s)=g=0;
Eq_trans(r,rr,e,l,s)     .. trans(r,rr,e,l,s)=g=0;




model e1   /
            Eq1,
            Eq2,
            Eq8_1,
            Eq8_2,
            Eq8_3,
            Eq8_4,
            Eq8_5.shadows_high,
            Eq8_6.shadows_retirment_high,
            Eq8_7,
            Eq8_8,
            Eq9_1,
            Eq9_2,

            Eq9_3.shadows_trans_high ,
            Eq9_4,
*            Eq9_4.shadows_trans_balance,

            Eq_q.shadows_low,
            Eq_trade.shadows_trade,
            Eq_inv.shadows_inv,
            Eq_ret.shadows_retirment_low,
            Eq_arb.shadows_arb,
/;

