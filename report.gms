*$ontext
Parameters
         profit(company,tech)         profit per player by tech
         roi(company,tech)              return on investment
         cus(company,tech)              capacity usage
         rop(company,tech)              return on production
         roc(company,tech)              return on capacity
         investments(company,tech)      investments

         price_avg(r,e,l)        expected price by region and season




         production(company,tech)       production by player


         error_demand(r,e,l)
         reserve_capacity(r)
         ;

         scalar         consumer_surplus                consumer surplus ;

*$ontext
         error_demand(r,e,l) =
         -sum((s,ss),prob(r,e,l,s,ss)*
           (EL_demand(r,e,l,s,ss)-
                 (sum((j),sales.l(j,r,e,l,s,ss))-sum((n,rr)$r_trade(n,r,rr),arbitrage.l(n,r,rr,e,l,s,ss))+sum((n,rr)$r_trade(n,rr,r),arbitrage.l(n,rr,r,e,l,s,ss)) )
           )
         )/sum((s,ss),EL_demand(r,e,l,s,ss));

         reserve_capacity(r) = sum((i,h),Cap_avail.l(i,h,r))/smax((e,l),sum((s,ss),EL_demand(r,e,l,s,ss)*prob(r,e,l,s,ss)))-1;
;

         consumer_surplus = sum((i,h,r,e,l,s,ss),prob(r,e,l,s,ss)*
                         (a(r,e,l,s,ss) - price.l(r,e,l,s,ss))*q.l(i,h,r,e,l,s,ss)/2*d(e,l));

         investments(i,h) =  sum(r,inv.l(i,h,r));

         price_avg(r,e,l) = sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss));

profit(i,h)=sum((r,e,l,s,ss),prob(r,e,l,s,ss)*(price.l(r,e,l,s,ss)-mc(h,r,s,ss))*q.l(i,h,r,e,l,s,ss)*d(e,l))-sum((hh,r),(ici(hh)+om(h))*inv.l(i,hh,r)*capadd(hh,h))-sum((r),(icr(h)-om(h))*ret.l(i,h,r))+sum((r,e,l)$m(r,e,l),delta.l(r,e,l)*beta(h,r,l)*Cap_avail.l(i,h,r));
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
rop(i,h)=profit(i,h)/sum((r,e,l,s,ss),prob(r,e,l,s,ss)*d(e,l)*q.l(i,h,r,e,l,s,ss));
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
