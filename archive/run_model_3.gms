$title Dynamic Programming Investment
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms


$INCLUDE SetsAndVariables.gms
$INCLUDE Demand.gms
$include parameters.gms
$INCLUDE equations_2.gms
$include demand_calib.gms


Option Savepoint=2;
CMO.optfile = 1 ;

Execute_Loadpoint 'CMO_p1.gdx';

trade.l(i,r,rr,e,l,s)$(not r_trans(r,rr))=0;
arbitrage.l(r,rr,e,l,s)$(not r_trans(r,rr))=0;
solve CMO using mcp;






*$ontext
Parameters
         profit(i)           profit per player
         roi(i)              return on investment
         cus(i)              capacity usage
         rop(i)              return on production
         roc(i)              return on capacity


         error_demand(r,e,l)
         reserve_capacity(r)
         ;

*$ontext
         error_demand(r,e,l) =
         -sum(s,prob(s)*
           (EL_demand(r,e,l,s)-
                 (sum((j,h),q.l(j,h,r,e,l,s))-sum(rr,arbitrage.l(r,rr,e,l,s))+sum(rr,arbitrage.l(rr,r,e,l,s)) )
           )
         )/sum(s,EL_demand(r,e,l,s));

         reserve_capacity(r) = sum((i,h),Cap_avail.l(i,h,r))/smax((e,l),sum(s,EL_demand(r,e,l,s)*prob(s)))-1;
;






$ontext
profit(i)=sum((h,r,l,s),prob(s)*(price.l(r,l,s)-mc(h,r,s))*q.l(i,h,r,l,s)*d(l,s))-sum((h,r),ici(h)*Cap_avail.l(i,h,r))-sum((h,r),icr(h)*ret.l(i,h,r))+sum((r,m,h,s),capacity_price.l(r,m)*beta(h,r,m)*Cap_avail.l(i,h,r)*prob(s)*d(m,s));




*********compute other indicators

***return on investment
roi(i)=profit(i)/(sum((h,r),Cap_avail.l(i,h,r)*ici(h)));

****capacity usage
cus(i)=sum((r,l,h,s),prob(s)*d(l,s)*q.l(i,h,r,l,s))/sum((l,h,r,s),prob(s)*d(l,s)*Cap_avail.l(i,h,r));

****return on production
rop(i)=profit(i)/sum((r,l,h,s),prob(s)*d(l,s)*q.l(i,h,r,l,s));

****return on capacity
roc(i)=profit(i)/(sum((r,l,h,s),prob(s)*d(l,s)*Cap_avail.l(i,h,r)));


display q.l, price.l, capacity_price.l,inv.l, Cap_avail.l, ret.l,kind0,profit;


display roi,cus,rop,roc;

display shadows_high.l,shadows_retirment_high.l;
*shadows_low.l,shadows_retirment_low.l,shadows_inv.l

$offtext

$ontext

file results /C:Users\c-olivef\AXEL Investment Gams\RESULTS.txt/;

put results;
put 'Investment model: the value of perfect rationality'//
    'Marginal Costs per generator'//;

loop((k,r,s),put k.tl,@12,s.tl,@24,mc(k,r,s):6:1//);

put 'Investment Costs per generator'//;

loop(k,put k.tl,@12,ic(k):6:1//);


put 'Investment per generator'//;

loop((i,k,r),put i.tl,@12,k.tl,@24,inv.l(i,k,r):6:1//);


put 'Generation per generator'//;

loop((i,k,r,l,s),put i.tl,@12,k.tl,@24,l.tl,@32,s.tl,@44,q.l(i,k,r,l,s):6:1//);


put 'Equilibrium Prices '//;

loop((r,s,l),put s.tl,@12,l.tl,@24,price(r,l,s)//);

put 'Total Profit per generator'//;

loop(i,put i.tl,@12,profit(i):8:2//);

put 'Generator, Return on Investment, Capacity usage, Return on production, Return on Capacity'//;

loop(i,put i.tl,@12,roi(i),@30,cus(i),@50,rop(i),@70,roc(i):10:2//);


$offtext
