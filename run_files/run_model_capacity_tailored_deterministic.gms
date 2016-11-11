$title Dynamic Programming Investment
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms

$FuncLibIn stolib stodclib
function cdfnorm     /stolib.cdfnormal/;

scalar trading set to 1 to allow regional trade by firms /0/;
scalar no_fringe set to 1 to allow regional trade by firms /0/;

$INCLUDE SetsAndVariables.gms

$INCLUDE Demand.gms
$include parameters.gms

$INCLUDE equations.gms
$include demand_calib.gms

     m(r,e,l) = no;

*     v('fringe')=-0.99;


*$ontext
$gdxin energy_deterministic.gdx

$LOAD price
         loop(l,
          m(r,e,l)$(     sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss))>
                         2*smin(ll,sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,ll,s,ss)))
                 )=yes
         );
*$offtext

*Option Savepoint=1;

CMO.optfile = 1 ;

*Execute_Loadpoint 'energy.gdx';

*trade.l(i,n,r,rr,e,l,s,ss)$(not r_trans(n,r,rr))=0;
*arbitrage.l(n,r,rr,e,l,s,ss)$(not r_trans(n,r,rr))=0;
*trans.lo(n,e,l,s,ss)=0;
solve CMO using mcp;

$include report.gms
