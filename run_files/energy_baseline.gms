$title Dynamic Programming Investment
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms
$FuncLibIn stolib stodclib
function cdfnorm     /stolib.cdfnormal/;

scalar trading set to 1 to allow regional trade by firms /0/;
scalar no_fringe set to 1 to exclude fringe from simulation /0/;

$INCLUDE SetsAndVariables.gms

$INCLUDE Demand.gms


$include parameters.gms
* Administered fuel price in mmbtu/mwh
fuel_price_admin(h,r)$(not nuclear(h)) = 1.25;
* change fuel prices to 2015 adminstered values
mc(h,r,s,ss) = mc_non_fuel(h,r)+heat_rate(h)*fuel_price_admin(h,r);

$INCLUDE equations.gms
$include demand_calib.gms


$gdxin capacity_80.gdx
$LOAD price sales arbitrage
$gdxin

elasticity(r,e,l,s,ss) = 1/b(r,e,l,s,ss) * price.l(r,e,l,s,ss)/ (
                   sum((j),sales.l(j,r,e,l,s,ss))
                  -sum(rr$r_trans(r,rr),arbitrage.l(r,rr,e,l,s,ss))
                  +sum(rr$r_trans(r,rr),arbitrage.l(rr,r,e,l,s,ss)) ) ;


*        Adjusted demand curve under baseline PPA assumptinos used to deliver
*        lower prices to the consumer for the project demand in 2020.
*        We cap the expected equilibrium priceat 80 RMB to Limit
*        the profits of the producers and prices paid by consumers

parameter  reduced_price(r,e,l,s,ss)   ;

reduced_price(r,e,l,s,ss) = LRMC(r,e,l,s,ss) ;
reduced_price(r,e,l,s,ss)$(LRMC(r,e,l,s,ss)>80) = 80;

b(r,e,l,s,ss) = reduced_price(r,e,l,s,ss)/EL_demand(r,e,l,s,ss)/elasticity(r,e,l,s,ss);
  a(r,e,l,s,ss) = (reduced_price(r,e,l,s,ss)+ b(r,e,l,s,ss)*EL_demand(r,e,l,s,ss));




* Assets Allocation
kind0(Genco,h,r) = sum(GGenco, kind_save(GGenco,h,r))*(2$(not oli(genco,r))/9+1$oli(genco,r)/3) ;

*increase west to central tranmnission capacity
*kind_trans0(r,rr)  = kind_trans0(r,rr)*10;
*kind_trans0('WOA','COA')  = 5;
*kind_trans0('COA','WOA')  = 5;

*$ontext
*        Genco PPA aggregated by region
loop(h$(not GTtoCC(h) and not nuclear(h)),
         Genco_PPA(h,'EOA')=79;
         Genco_PPA(h,'SOA')=26;
         Genco_PPA(h,'WOA')=93;
         Genco_PPA(h,'COA')=87;
);
Genco_PPA(h,r)$(not ST(h))=Genco_PPA(h,r)*EL_demgro(r);


* Assign PPA per technology assuming CCGT receive baseload and other technolgoies absorb the rest.
Genco_PPA('CCGT',r)=sum(i$Genco(i),kind0(i,'CCGT',r))*sum((e,l),d(e,l))*2;
Genco_PPA('ST',r)=sum(i$Genco(i),kind0(i,'ST',r))*sum((e,l),d(e,l))*0.9;
Genco_PPA('GT',r)=(Genco_PPA('GT',r)-Genco_PPA('ST',r)-Genco_PPA('CCGT',r));
*$offtext
Genco_PPA(h,r)$(Genco_PPA(h,r)<0)=0;
Genco_PPA('CCGT',r) = Genco_PPA('CCGT',r);
Genco_PPA('GT',r) = Genco_PPA('GT',r);

*        conjectural variations of the firms
     v(i) = 0;
     v('fringe') = -1;

*        cap on market share (investments) by firm
*     market_share_inv('fringe') = 0;
*        cap on market share (investments) by firm
     market_share_prod('fringe') = 0.2;


*        Capacity market configuration
     m(r,e,l) = no;
$ontext
*        Used to customize capacity markets based on expected prices that are greater than double the baseload prices
$gdxin energy.gdx

$LOAD price
         loop(l,
          m(r,e,l)$(     sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss))>
                         2*smin(ll,sum((s,ss),prob(r,e,ll,s,ss)*price.l(r,e,ll,s,ss)))
                 )=yes
         );
$gdxin
$offtext


Option Savepoint=2;

Execute_Loadpoint 'baseline_ppa.gdx';

CMO.optfile = 1 ;

solve CMO using mcp;

$include report.gms


$ontext
Parameters  a1(r,e,l,s,ss) intercept of energy demand curve,
            b1(r,e,l,s,ss) slope of energy demand curve
            q1(r,e,l,s,ss)
;


  elasticity(r,e,l,s,ss) = 0.16;
  a1(r,e,l,s,ss) = LRMC(r,e,l,s,ss)*(1+1/elasticity(r,e,l,s,ss));
  b1(r,e,l,s,ss) = LRMC(r,e,l,s,ss)/EL_demand(r,e,l,s,ss)/elasticity(r,e,l,s,ss);

 q1(r,e,l,s,ss)  =-(a1(r,e,l,s,ss)- a(r,e,l,s,ss))/(b(r,e,l,s,ss)- b1(r,e,l,s,ss));


          consumer('surplus',r) = consumer('surplus',r)
+sum((e,l,s,ss),prob(r,e,l,s,ss)*(
 (a1(r,e,l,s,ss)*q1(r,e,l,s,ss) - b1(r,e,l,s,ss)*q1(r,e,l,s,ss)*q1(r,e,l,s,ss)/2)
-(a(r,e,l,s,ss)*q1(r,e,l,s,ss) - b(r,e,l,s,ss)*q1(r,e,l,s,ss)*q1(r,e,l,s,ss)/2)
));

$offtext
