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

$INCLUDE equations.gms
$include demand_calib.gms

* Distribute ownership of exisitng assets by the Genco's
* Near homogenous with one dominant player per region
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
* Below we define in what demand segments the capacity market is operated
* It is defined when the demand exceeds some ratio of the avabilabe capacity in a gien region
$gdxin energy.gdx

$LOAD demand_actual Cap_avail
         loop(l,
          m(r,e,l)$(
                 smax((s,ss),demand_actual(r,e,l,s,ss))>
                 sum((i,h),Cap_avail.l(i,h,r))*0.9
                 )=yes
         );
*$offtext

 theta(r,e,l) =  max(h$(not nuclear(h)),(ic(h)+om(h)))/sum((ee,ll),d(ee,ll))*2 ;
 xi(r,e,l)$m(r,e,l) =0;


Option Savepoint=2;

Execute_Loadpoint 'capacity.gdx';

CMO.optfile = 1 ;

solve CMO using mcp;

$include report.gms
