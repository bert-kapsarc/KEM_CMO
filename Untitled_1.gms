Eq1(r,e,l,s,ss)..    price(r,e,l,s,ss)=e=
                     a(r,e,l,s,ss)-b(r,e,l,s,ss)*sum(j,sales(j,r,e,l,s,ss))
                     +b(r,e,l,s,ss)*(
                          sum((n,rr)$r_trade(n,r,rr),arbitrage(n,r,rr,e,l,s,ss))
                          -sum((n,rr)$r_trade(n,rr,r),arbitrage(n,rr,r,e,l,s,ss))
                     );

Eq2(r,e,l)$m(r,e,l) ..  delta(r,e,l)=e=theta(r,e,l)-xi(r,e,l)*sum((j,hh)$(not gttocc(hh)),beta(hh,r,l)*Cap_avail(j,hh,r));

Eq9_1(i,h,r,e,l,s,ss)$(not gttocc(h)) ..
price(r,e,l,s,ss)-mc(h,r,s,ss)-b(r,e,l,s,ss)*(1+v(i))*sales(i,r,e,l,s,ss)-lambda_high(i,h,r,e,l,s,ss)+lambda_low(i,h,r,e,l,s,ss)=e= 0 ;
*

Eq9_2(i,h,r)..       sum((e,l)$m(r,e,l),d(e,l)*delta(r,e,l)*beta(h,r,l))
                    -sum((e,l)$m(r,e,l),d(e,l)*xi(r,e,l)*(beta(h,r,l)+z(i))*sum(hh,beta(hh,r,l)*Cap_avail(i,hh,r)))
                     +sum((hh,e,l,s,ss)$(not gttocc(hh)),prob(r,e,l,s,ss)*d(e,l)*lambda_high(i,hh,r,e,l,s,ss)*capadd(h,hh))
                     -shadows_gttocc(i,r)$gttocc(h)
                     +alpha(i,h,r) =e=ici(h)+om(h);
*

Eq9_3(i,h,r)$(not gttocc(h))..      -sum((e,l)$m(r,e,l),d(e,l)*delta(r,e,l)*beta(h,r,l))
                    +sum((e,l)$m(r,e,l),d(e,l)*xi(r,e,l)*(beta(h,r,l)+z(i))*sum(hh,beta(hh,r,l)*Cap_avail(i,hh,r)))
                    -sum((e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*lambda_high(i,h,r,e,l,s,ss))-eta_high(i,h,r)
                     -shadows_gttocc(i,r)$gt(h)
                     +eta_low(i,h,r) =e= icr(h)-om(h);
*

Eq9_4(i,n,r,rr,e,l,s,ss)$(trading=1 and r_trade(n,r,rr))..
         price(rr,e,l,s,ss)-price(r,e,l,s,ss)+zeta(i,n,r,rr,e,l,s,ss)
         -price_trans(n,e,l,s,ss)
        +b(r,e,l,s,ss)*sales(i,r,e,l,s,ss)*(1+x(i,r,rr))
        -b(rr,e,l,s,ss)*sales(i,rr,e,l,s,ss)*(1+x(i,rr,r))
                 =e=0;

Eq9_5(i,h,r,e,l,s,ss)$(not gttocc(h)) ..  Cap_avail(i,h,r)-Q(i,h,r,e,l,s,ss)=g=0;

Eq9_5a(i,r) ..  (kind(i,'GT',r)-ret(i,'GT',r))=g=inv(i,'GTtoCC',r);

Eq9_6(i,h,r)$(not gttocc(h))..  kind(i,h,r) - ret(i,h,r)=g=0 ;
Eq9_7(i,h,r)$(not gttocc(h))..  Cap_avail(i,h,r) =e= kind(i,h,r)+sum(hh,inv(i,hh,r)*capadd(hh,h))-ret(i,h,r);

Eq9_8(i,r,e,l,s,ss)..     sales(i,r,e,l,s,ss)=e=
                         sum(h$(not gttocc(h)),Q(i,h,r,e,l,s,ss))
                       -sum((n,rr)$(r_trade(n,r,rr)),trade(i,n,r,rr,e,l,s,ss))$(trading=1)
                       +sum((n,rr)$(r_trade(n,rr,r)),trade(i,n,rr,r,e,l,s,ss))$(trading=1) ;

Eq9_9(i,h,r).. kind0(i,h,r)-kind(i,h,r)=e=0  ;