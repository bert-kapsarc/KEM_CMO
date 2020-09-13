elasticity(r,e,l,s) = 1/b(r,e,l,s) * price.l(r,e,l,s,'s1')/demand.l(r,e,l,s,'s1');
demand_projected(r,e,l) =sum((s,ss),prob(r,e,l,s,ss)*EL_demand(r,e,l,s)*d(e,l));
demand_projected_total(r) = sum((e,l),demand_projected(r,e,l));
demand_projected_total("national") = sum(r, demand_projected_total(r));
demand_actual(r,e,l)=sum((s,ss),prob(r,e,l,s,ss)*demand.l(r,e,l,s,ss)*d(e,l));
demand_total(r) =  sum((e,l),demand_actual(r,e,l));
*demand_total("national") = sum(r, demand_total(r));

demand_err(r,e,l,s,ss) =-(EL_demand(r,e,l,s)-demand.l(r,e,l,s,ss))/EL_demand(r,e,l,s);

scalar demand_err_tot ;
demand_err_tot =  sum((r,e,l,s,ss),prob(r,e,l,s,ss)*demand.l(r,e,l,s,ss)*d(e,l))/sum((r,e,l),demand_projected(r,e,l))-1;

reserve_capacity(r) = sum((i,h)$(not ren(h)),Cap_avail.l(i,h,r))/
    smax((e,l,s,ss),demand.l(r,e,l,s,ss))-1;

report('profit',r) =sum((i),profitR.l(i,r))
;
report('surplus',r) =
sum((e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*(
(a(r,e,l,s) - price.l(r,e,l,s,ss))*demand.l(r,e,l,s,ss)/2
))
;
report('fuel subsidy',r) = sum((i,f,h,e,l,s,ss),prob(r,e,l,s,ss)*
(fuel_price_intl(f,r)-fuel_price(f,r))*
q.l(i,h,f,r,e,l,s,ss)*heat_rate(h,f,r)*d(e,l))
;
report('fixed cost',r) =
sum((i,h,e,l)$m(h,r,e,l),
    d(e,l)*delta.l(h,r,e,l)*Cap_avail.l(i,h,r)
);
report('total surplus',r) =
     report('surplus',r)
    +report('profit',r)
    -report('fuel subsidy',r)
    -report('fixed cost',r)

;

cs_threshold(r,e,l,s,ss) = demand.l(r,e,l,s,ss)-2*a(r,e,l,s)/b(r,e,l,s);
;
parameter production
;

production(i,h)=sum((f,r,e,l,s,ss)$fuel_set(h,f,r),
         prob(r,e,l,s,ss)*q.l(i,h,f,r,e,l,s,ss)*d(e,l));
*production(i,'all')=sum(h,production(i,h)) ;
*production('all','all')=sum((i,h),production(i,h)) ;


balancing_account('purchases energy',r)=
         sum((i,h,f,e,l,s,ss),price.l(r,e,l,s,ss)*
                prob(r,e,l,s,ss)*q.l(i,h,f,r,e,l,s,ss)*d(e,l));

balancing_account('purchases capacity',r)=
         sum((i,h,e,l)$m(h,r,e,l),delta.l(h,r,e,l)*Cap_avail.l(i,h,r)*d(e,l));

balancing_account('consumer sales',r)=
         sum((i,h,f,e,l,s,ss,consumer_type),consumer_share(consumer_type,r)*
         consumer_tariff(consumer_type)*
                prob(r,e,l,s,ss)*q.l(i,h,f,r,e,l,s,ss)*d(e,l));

investments(i,h) =  1e-6+sum(r,inv.l(i,h,r));
retirements(i,h)$(not gttocc(h)) = 1e-6+sum(r,ret.l(i,h,r));
price_avg(r,e,l) = sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss));


price_avg_flat(r)  =
         sum((e,l),price_avg(r,e,l)*demand_actual(r,e,l))/demand_total(r);

price_avg_flat("national") =
         sum(r, price_avg_flat(r)*demand_total(r))/sum(r,demand_total(r));

price_avg_cost(r) = (
         sum((i,h,f,e,l,s,ss)$fuel_set(h,f,r),prob(r,e,l,s,ss)*
                mc(h,f,r)*q.l(i,h,f,r,e,l,s,ss)*d(e,l))
        +sum((i,h,hh),(ici(hh)+om(h))*inv.l(i,hh,r)*capadd(hh,h))
        +sum((i,h),(icr(h)-om(h))*ret.l(i,h,r))
        )/demand_total(r);

price_avg_cost("national") =
         sum((r),price_avg_cost(r)*demand_total(r))/sum(r,demand_total(r));


price_trans_avg(r,e,l) =
         sum((s,ss),prob(r,e,l,s,ss)*price_trans.l(r,e,l,s,ss));

parameter trade;
trade(i,r,e,l) = sum((s,ss),prob(r,e,l,s,ss)*d(e,l)*(
    sales.l(i,r,e,l,s,ss)
    -sum((f,h)$fuel_set(h,f,r),Q.l(i,h,f,r,e,l,s,ss)) )
);
transmission(n,e,l,dir) =sum((s,ss,r),PTDF(n,r,dir)*Load.l(r,e,l,s,ss)*prob(r,e,l,s,ss)*d(e,l));
*       arbitrage_avg(r,rr,e,l) =sum((s,ss),prob(r,e,l,s,ss)*arbitrage.l(r,rr,e,l,s,ss)*d(e,l));
;

execute_unload  'build%SLASH%merge%SLASH%%scenario%',
    profitR,
    report,
    price,
    price_avg,
    price_avg_flat,
    price_avg_cost,
    price_trans_avg,
    transmission,
    production,
    retirements,
    investments,
    Cap_avail,
    reserve_capacity,
    balancing_account,
    trade,
    demand_actual,
    demand_total,
    elasticity,
    demand_err,
    demand_err_tot;
execute 'gdxmerge build%SLASH%merge%SLASH%*.gdx output=build%SLASH%report';
execute_unload  'build%SLASH%%scenario%';

*********compute other indicators
$ontext
TO-DO add report for technology specific profits
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
$offtext



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
