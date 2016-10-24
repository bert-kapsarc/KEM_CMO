$title Dynamic Programming Investment
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms

$FuncLibIn stolib stodclib
function cdfnorm     /stolib.cdfnormal/;

scalar trading set to 1 to allow regional trade by firms /0/;

$INCLUDE SetsAndVariables.gms

$INCLUDE Demand.gms
$include parameters.gms

$INCLUDE equations.gms
$include demand_calib.gms


Option Savepoint=1;
CMO.optfile = 1 ;

Execute_Loadpoint 'CMO_p.gdx';

*trade.l(i,n,r,rr,e,l,s,ss)$(not r_trans(n,r,rr))=0;
*arbitrage.l(n,r,rr,e,l,s,ss)$(not r_trans(n,r,rr))=0;
*trans.lo(n,e,l,s,ss)=0;
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
         -sum((s,ss),prob(r,e,l,s,ss)*
           (EL_demand(r,e,l,s,ss)-
                 (sum((j),sales.l(j,r,e,l,s,ss))-sum((n,rr)$r_trade(n,r,rr),arbitrage.l(n,r,rr,e,l,s,ss))+sum((n,rr)$r_trade(n,rr,r),arbitrage.l(n,rr,r,e,l,s,ss)) )
           )
         )/sum((s,ss),EL_demand(r,e,l,s,ss));

         reserve_capacity(r) = sum((i,h),Cap_avail.l(i,h,r))/smax((e,l),sum((s,ss),EL_demand(r,e,l,s,ss)*prob(r,e,l,s,ss)))-1;
;



profit(i)=sum((h,r,e,l,s,ss),prob(r,e,l,s,ss)*(price.l(r,e,l,s,ss)-mc(h,r,s,ss))*q.l(i,h,r,e,l,s,ss)*d(e,l))-sum((h,r),ici(h)*Cap_avail.l(i,h,r))-sum((h,r),icr(h)*ret.l(i,h,r))+sum((r,e,m,h),delta.l(r,e,m)*beta(h,r,m)*Cap_avail.l(i,h,r));




*********compute other indicators

***return on investment
roi(i)=profit(i)/(sum((h,r),Cap_avail.l(i,h,r)*ici(h)));

****capacity usage
cus(i)=sum((r,e,l,h,s,ss),prob(r,e,l,s,ss)*d(e,l)*q.l(i,h,r,e,l,s,ss))/sum((l,h,r,e,s,ss),prob(r,e,l,s,ss)*d(e,l)*Cap_avail.l(i,h,r));

****return on production
rop(i)=profit(i)/sum((r,e,l,h,s,ss),prob(r,e,l,s,ss)*d(e,l)*q.l(i,h,r,e,l,s,ss));

****return on capacity
roc(i)=profit(i)/(sum((r,e,l,h),d(e,l)*Cap_avail.l(i,h,r)));


display q.l, price.l, delta.l,inv.l, Cap_avail.l, ret.l,kind0,profit;


display roi,cus,rop,roc;

display lambda_high.l,eta_high.l;



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


*$offtext
