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

$INCLUDE equations.gms
$include demand_calib.gms

* Assets Allocation
kind0(Genco,h,r) = sum(GGenco, kind_save(GGenco,h,r))*(2$(not oli(genco,r))/9+1$oli(genco,r)/3) ;


*        conjectural variations of the firms
     v(i) = 0;
     v('fringe') = -1;



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

Execute_Loadpoint 'energy.gdx';


CMO.optfile = 1 ;

$INCLUDE loop.gms


