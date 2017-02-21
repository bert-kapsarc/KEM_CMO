

elasticity(r,e,l,s,ss) = 1/b(r,e,l,s,ss) * price.l(r,e,l,s,ss)/ (
                   sum((j),sales.l(j,r,e,l,s,ss))
                  -sum(rr$r_trans(r,rr),arbitrage.l(r,rr,e,l,s,ss))
                  +sum(rr$r_trans(r,rr),arbitrage.l(rr,r,e,l,s,ss)) ) ;

*        EL_demand(r,e,l,s,ss) = EL_demand_resp(r,e,l,s,ss);
*$ontext
         demand_expected(r,e,l) =sum((s,ss),prob(r,e,l,s,ss)*EL_demand(r,e,l,s,ss)*d(e,l));
         demand_actual(r,e,l,s,ss)=(
                 sum(j,sales.l(j,r,e,l,s,ss))
                  -sum(rr$r_trade(r,rr),arbitrage.l(r,rr,e,l,s,ss))
                  +sum(rr$r_trade(r,rr),arbitrage.l(rr,r,e,l,s,ss)) )*d(e,l);

         error_demand(r,e,l) =
         -sum((s,ss),prob(r,e,l,s,ss)*
                 (EL_demand(r,e,l,s,ss)*d(e,l)-demand_actual(r,e,l,s,ss))
         )/demand_expected(r,e,l);

         scalar error_total ;
         error_total =  sum((r,e,l,s,ss),prob(r,e,l,s,ss)*demand_actual(r,e,l,s,ss))/sum((r,e,l),demand_expected(r,e,l))-1;

         reserve_capacity(r) = sum((i,h),Cap_avail.l(i,h,r))/
                 smax((e,l,s,ss),demand_actual(r,e,l,s,ss)/d(e,l))-1;

        consumer('surplus',r) =
         sum((e,l,s,ss),prob(r,e,l,s,ss)*
         (a(r,e,l,s,ss) - price.l(r,e,l,s,ss))*demand_actual(r,e,l,s,ss))/2;

*        fuel subsidies
         consumer('fuel subsidy',r) = sum((i,f,h,e,l,s,ss),prob(r,e,l,s,ss)*
         (intl_fuel_price(f,r)-fuel_price(f,r))*
         q.l(i,h,f,r,e,l,s,ss)*heat_rate(h,f)*d(e,l));

         consumer('fixed cost',r) =
         sum((i,h,e,l)$m(r,e,l),delta.l(r,e,l)*Cap_avail.l(i,h,r)*d(e,l));

         cs_threshold(r,e,l,s,ss) = demand_actual(r,e,l,s,ss)/d(e,l)-2*a(r,e,l,s,ss)/b(r,e,l,s,ss);

*         price.l(r,e,l,s,ss) = price_avg_cost(r,e,l) ;

profit(i,h)=
sum((f,r,e,l,s,ss)$fuel_set(h,f,r),prob(r,e,l,s,ss)*d(e,l)*
         (price.l(r,e,l,s,ss)-mc(h,f,r))*q.l(i,h,f,r,e,l,s,ss))$(not legacy(i))

-sum((hh,r)$(capadd(hh,h)>0),ici(hh)*inv.l(i,hh,r))

*-sum(r,sum(hh$(capadd(hh,h)>0),inv.l(i,hh,r)*capadd(hh,h)))*om(h)$(legacy_auction<>1)
-sum(r, Cap_avail.l(i,h,r)*om(h))

-sum(r,icr(h)*ret.l(i,h,r))
*+sum((r,e,l)$m(r,e,l),sum(hh$(capadd(hh,h)>0),inv.l(i,hh,r)*capadd(hh,h))*delta.l(r,e,l)*d(e,l))$(legacy_auction<>1)
+sum((r,e,l)$m(r,e,l),delta.l(r,e,l)*Cap_avail.l(i,h,r)*d(e,l))
*$(legacy_auction=1)
;

social_surplus  = sum((i,h),profit(i,h))   +
         sum(r, consumer('surplus',r)
                -consumer('fuel subsidy',r)
                -consumer('fixed cost',r))
;

production(i,h)=sum((f,r,e,l,s,ss)$fuel_set(h,f,r),
         prob(r,e,l,s,ss)*q.l(i,h,f,r,e,l,s,ss)*d(e,l));
*production(i,'all')=sum(h,production(i,h)) ;



balancing_account('purchases energy',r)=
        sum((i,h,f,e,l,s,ss),price.l(r,e,l,s,ss)*
                prob(r,e,l,s,ss)*q.l(i,h,f,r,e,l,s,ss)*d(e,l));
balancing_account('purchases capacity',r)=
        sum((i,h,e,l)$m(r,e,l),delta.l(r,e,l)*Cap_avail.l(i,h,r)*d(e,l));

balancing_account('consumer sales',r)=
sum((i,h,f,e,l,s,ss,consumer_type),consumer_share(consumer_type,r)*
        consumer_tariff(consumer_type)*
                prob(r,e,l,s,ss)*q.l(i,h,f,r,e,l,s,ss)*d(e,l));

investments(i,h) =  1e-6+sum(r,inv.l(i,h,r));
retirements(i,h)$(not gttocc(h)) =  1e-6+sum(r,ret.l(i,h,r));
price_avg(r,e,l) = sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss));

price_avg_flat(r)  =
         sum((e,l,s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss)*EL_demand(r,e,l,s,ss)*d(e,l))/
         sum((e,l,s,ss),prob(r,e,l,s,ss)*EL_demand(r,e,l,s,ss)*d(e,l));

price_avg_cost(r,e,l) = (
         sum((i,h,f,s,ss)$fuel_set(h,f,r),prob(r,e,l,s,ss)*
                mc(h,f,r)*q.l(i,h,f,r,e,l,s,ss)*d(e,l))
        +sum((i,h,hh),(ici(hh)+om(h))*inv.l(i,hh,r)*capadd(hh,h))
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


*********compute other indicators

***return on investment
roi(i,h)$(sum(r,Cap_avail.l(i,h,r))>1e-6)=profit(i,h)/(sum((r),Cap_avail.l(i,h,r)*ici(h)));
*roi(i,'all')=sum(h,roi(i,h));

****capacity usage
cus(i,h)$(sum(r,Cap_avail.l(i,h,r))>1e-6)=
         sum((f,r,e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*q.l(i,h,f,r,e,l,s,ss))/
                 sum((l,r,e,s,ss),prob(r,e,l,s,ss)*d(e,l)*Cap_avail.l(i,h,r));
*cus(i,'all')=sum(h,cus(i,h));

****return on production
rop(i,h)$(sum((f,r,e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*q.l(i,h,f,r,e,l,s,ss))>0)=
         profit(i,h)/sum((f,r,e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*q.l(i,h,f,r,e,l,s,ss));
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
