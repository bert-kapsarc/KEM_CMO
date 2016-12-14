$title Dynamic Programming Investment
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms
$FuncLibIn stolib stodclib
function cdfnorm     /stolib.cdfnormal/;

scalar trading set to 1 to allow regional trade by firms /1/;
scalar no_fringe set to 1 to exclude fringe from simulation /0/;

$INCLUDE SetsAndVariables.gms

$INCLUDE Demand.gms


$include parameters.gms
* Administered fuel price in mmbtu/mwh
*fuel_price_admin(h,r)$(not nuclear(h)) = 1.25;
* change fuel prices to 2015 adminstered values
*mc(h,r,s,ss) = mc_non_fuel(h,r)+heat_rate(h)*fuel_price_admin(h,r);

$INCLUDE equations.gms
$include demand_calib.gms

* Distribute ownership of exisitng assets by the Genco's
* Near homogenous with one dominant player per region
kind0(Genco,h,r) = sum(GGenco, kind_save(GGenco,h,r))*(2$(not oli(genco,r))/9+1$oli(genco,r)/3) ;


*        conjectural variations of the firms
     v(i) = 0;
     v('fringe') = -1;

*        cap on market share (investments) by firm
*     market_share_inv('fringe') = 0.2;
*        cap on market share (investments) by firm
     market_share_prod('fringe') = 0.2;

*        Capacity market configuration
     m(r,e,l) = no;
$ontext
*        Used to customize capacity markets based on expected prices that are greater than double the baseload prices
*$gdxin energy.gdx

$LOAD price
         loop(l,
          m(r,e,l)$(     sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss))>
                         2*smin(ll,sum((s,ss),prob(r,e,ll,s,ss)*price.l(r,e,ll,s,ss)))
                 )=yes
         );
$offtext


Option Savepoint=2;

Execute_Loadpoint 'test2.gdx';

CMO.optfile = 1 ;

solve CMO using mcp;

$include report.gms
