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
     m(r,e,l) = no;
     beta(i)=1;
     kind_trans0(r,rr) = kind_trans0(r,rr);

         v(i) = -1;
         v('g1') = 0;
         v('g2') = 0;
         v('g3') = 0;
         v('g4') = 0;
         x(i,r,rr)  = v(i) ;

$ontext
*        Used to customize capacity markets based on expected prices that are greater than double the baseload prices
*$gdxin energy.gdx

*$LOAD price
         loop(l,
          m(r,e,l)$(     sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss))>
                         2*smin(ll,sum((s,ss),prob(r,e,ll,s,ss)*price.l(r,e,ll,s,ss)))
                 )=yes
         );
$offtext


*Option Savepoint=1;

*Execute_Loadpoint 'test_trade.gdx';

CMO.optfile = 1 ;

solve CMO using mcp;

$include report.gms
