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

* Assets Allocation
kind0(Genco,h,r) = sum(GGenco, kind_save(GGenco,h,r))*(2$(not oli(genco,r))/9+1$oli(genco,r)/3) ;

*        10% increase in capacity payments
theta(r,e,l) = theta(r,e,l);



*        conjectural variations of the firms
     v(i) = 0;
     v('fringe') = -1;

*        cap on market share (investments) by firm
*     market_share_inv('fringe') = 0.2;
*        cap on market share (investments) by firm
     market_share_prod('fringe') = 0.2;

*        Capacity market configuration
     m(r,e,l) = no;
*$ontext
*        Used to customize capacity markets based on expected prices that are greater than double the baseload prices
$gdxin energy_afp.gdx

$LOAD demand_actual Cap_avail
         loop(l,
          m(r,e,l)$(
                 smax((s,ss),demand_actual(r,e,l,s,ss))>
                 sum((i,h),Cap_avail.l(i,h,r))*0.8

*                 sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss))>
*                 2*smin(ll,sum((s,ss),prob(r,e,ll,s,ss)*price.l(r,e,ll,s,ss)))
                 )=yes
         );
*$offtext


Option Savepoint=2;

Execute_Loadpoint 'energy_afp.gdx';

CMO.optfile = 1 ;

solve CMO using mcp;

$include report.gms
