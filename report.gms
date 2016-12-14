

*$ontext
         demand_expected(r,e,l) =sum((s,ss),prob(r,e,l,s,ss)*EL_demand(r,e,l,s,ss));
         demand_actual(r,e,l,s,ss)=

                 (sum((j),sales.l(j,r,e,l,s,ss))
                  -sum(rr$r_trans(r,rr),arbitrage.l(r,rr,e,l,s,ss))
                  +sum(rr$r_trans(r,rr),arbitrage.l(rr,r,e,l,s,ss)) ) ;

         error_demand(r,e,l) =
         -sum((s,ss),prob(r,e,l,s,ss)*
                 (EL_demand(r,e,l,s,ss)-demand_actual(r,e,l,s,ss))
         )/demand_expected(r,e,l);

         reserve_capacity(r) = sum((i,h),Cap_avail.l(i,h,r))/smax((e,l,s,ss),demand_actual(r,e,l,s,ss))-1;
;
k1(r,e,l,s,ss) = demand_actual(r,e,l,s,ss)*d(e,l)*price.l(r,e,l,s,ss)**(elasticity(r,e,l,s,ss));

         consumer('surplus',r) = sum((e,l,s,ss),prob(r,e,l,s,ss)*
         k1(r,e,l,s,ss)*price.l(r,e,l,s,ss)**(1-elasticity(r,e,l,s,ss))/(1-elasticity(r,e,l,s,ss))
         );



*         sum((i,h,e,l,s,ss),prob(r,e,l,s,ss)*
*         (a(r,e,l,s,ss) - price.l(r,e,l,s,ss))*q.l(i,h,r,e,l,s,ss)*d(e,l)/2);
*        Subtract out fuel subsidies
         consumer('fuel subsidy',r) = sum((i,h,e,l,s,ss),prob(r,e,l,s,ss)*
         (fuel_price(h,r)-fuel_price_admin(h,r))*q.l(i,h,r,e,l,s,ss)*heat_rate(h)*d(e,l));

         consumer('fixed cost',r) = sum((i,h,e,l)$m(r,e,l),delta.l(r,e,l)*Cap_avail.l(i,h,r)*d(e,l));


         balancing_account('purchases energy',r)=
                 sum((i,h,e,l,s,ss),price.l(r,e,l,s,ss)*
                         prob(r,e,l,s,ss)*q.l(i,h,r,e,l,s,ss)*d(e,l));
         balancing_account('purchases capacity',r)=
                 sum((i,h,e,l)$m(r,e,l),delta.l(r,e,l)*Cap_avail.l(i,h,r));

         balancing_account('consumer sales',r)=sum((i,h,e,l,s,ss,consumer_type),
         consumer_share(consumer_type,r)*consumer_tariff(consumer_type)*
                         prob(r,e,l,s,ss)*q.l(i,h,r,e,l,s,ss)*d(e,l));



         investments(i,h) =  sum(r,inv.l(i,h,r));

         price_avg(r,e,l) = sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss));

         price_avg_cost(r,e,l) = (
                  sum((i,h,s,ss),prob(r,e,l,s,ss)*mc(h,r,s,ss)*q.l(i,h,r,e,l,s,ss)*d(e,l))
                 +sum((i,h,hh),(ici(hh)+om(h))*beta(i)*inv.l(i,hh,r)*capadd(hh,h))
                 +sum((i,h),(icr(h)-om(h))*ret.l(i,h,r))
                 )/sum((s,ss),prob(r,e,l,s,ss)*demand_actual(r,e,l,s,ss));

         price_trans_avg(r,rr,e,l) = sum((s,ss),prob(r,e,l,s,ss)*price_trans.l(r,rr,e,l,s,ss));

         trans.l(r,rr,e,l,s,ss)$r_trade(r,rr) =
                 sum(i,trade.l(i,r,rr,e,l,s,ss))$(trading=1)
                 -sum(i,trade.l(i,rr,r,e,l,s,ss))$(trading=1)
                 +arbitrage.l(r,rr,e,l,s,ss)
                 -arbitrage.l(rr,r,e,l,s,ss);

         trade_avg(i,r,rr,e,l) =sum((s,ss),prob(r,e,l,s,ss)*trade.l(i,r,rr,e,l,s,ss)*d(e,l));
         transmission(r,rr,e,l) =sum((s,ss),prob(r,e,l,s,ss)*trans.l(r,rr,e,l,s,ss)*d(e,l));
         arbitrage_avg(r,rr,e,l) =sum((s,ss),prob(r,e,l,s,ss)*arbitrage.l(r,rr,e,l,s,ss)*d(e,l));


*         price.l(r,e,l,s,ss) = price_avg_cost(r,e,l) ;

profit(i,h)=sum((r,e,l,s,ss),prob(r,e,l,s,ss)*(price.l(r,e,l,s,ss)-mc(h,r,s,ss))*q.l(i,h,r,e,l,s,ss)*d(e,l))-sum((hh,r),(ici(hh)+om(h))*beta(i)*inv.l(i,hh,r)*capadd(hh,h))-sum((r),(icr(h)-om(h)*beta(i))*ret.l(i,h,r))+sum((r,e,l)$m(r,e,l),delta.l(r,e,l)*Cap_avail.l(i,h,r));
*profit(i,'all')=sum(h,profit(i,h));

production(i,h)=sum((r,e,l,s,ss),prob(r,e,l,s,ss)*q.l(i,h,r,e,l,s,ss)*d(e,l));
*production(i,'all')=sum(h,production(i,h)) ;

*********compute other indicators

***return on investment
roi(i,h)$(sum(r,Cap_avail.l(i,h,r))>1e-6)=profit(i,h)/(sum((r),Cap_avail.l(i,h,r)*ici(h)));
*roi(i,'all')=sum(h,roi(i,h));

****capacity usage
cus(i,h)$(sum(r,Cap_avail.l(i,h,r))>1e-6)=sum((r,e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*q.l(i,h,r,e,l,s,ss))/sum((l,r,e,s,ss),prob(r,e,l,s,ss)*d(e,l)*Cap_avail.l(i,h,r));
*cus(i,'all')=sum(h,cus(i,h));

****return on production
rop(i,h)$(sum((r,e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*q.l(i,h,r,e,l,s,ss))>0)=
         profit(i,h)/sum((r,e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*q.l(i,h,r,e,l,s,ss));
*rop(i,'all')=sum(h,rop(i,h));

****return on capacity
roc(i,h)$(sum(r,Cap_avail.l(i,h,r))>1e-6)=profit(i,h)/(sum((r,e,l),d(e,l)*Cap_avail.l(i,h,r)));
*roc(i,'all')=sum(h,roc(i,h));

display q.l, price.l, delta.l,inv.l, Cap_avail.l, ret.l,kind0,profit;


display roi,cus,rop,roc;

display lambda_high.l,eta_high.l;



$ontext
file results /C:Users\c-olivef\AXEL Investment Gams\RESULTS.txt/;

put results;
put 'Investment model: the value of perfect rationality'//
    'Marginal Costs per generator'//;

loop((h,r,s,ss),put h.tl,@12,s.tl,@24,mc(h,r,s,ss):6:1//);

put 'Investment Costs per generator'//;

loop(h,put h.tl,@12,ic(h):6:1//);


put 'Investment per generator'//;

loop((i,h,r),put i.tl,@12,h.tl,@24,inv.l(i,h,r):6:1//);


put 'Generation per generator'//;

loop((i,h,r,e,l,s,ss),put i.tl,@12,h.tl,@24,l.tl,@32,s.tl,@44,q.l(i,h,r,e,l,s,ss):6:1//);


put 'Equilibrium Prices '//;

loop((r,e,l,s,ss),put s.tl,@12,l.tl,@24,price(r,e,l,s,ss)//);

put 'Total Profit per generator'//;

loop(i,put i.tl,@12,profit(i):8:2//);

put 'Generator, Return on Investment, Capacity usage, Return on production, Return on Capacity'//;

loop(i,put i.tl,@12,roi(i),@30,cus(i),@50,rop(i),@70,roc(i):10:2//);


$offtext
