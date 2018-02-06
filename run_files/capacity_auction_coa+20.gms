$title Dynamic Programming Investment with Reliability Options
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms
$FuncLibIn stolib stodclib
function cdfnorm /stolib.cdfnormal/;

scalar trading set to 1 to allow regional trade by firms /0/
       fixed_ppa  /0/
       r_options reliability options switch /0/

$INCLUDE SetsAndVariables.gms

$INCLUDE Demand.gms
$include parameters.gms
$include marginal_cost.gms

$include demand_calib.gms
$INCLUDE equations.gms

$include scen_config.gms
;

*v(i)=0;
*z(i) = -1;

m(r,e,l)=no;

*$ontext
*        Configure capacity market segments
*  Enter file to load previous data from
$gdxin results/energy_only.gdx
$LOAD demand Cap_avail price
$include capacity_market.gms
*$offtext
;

Parameter Cap_target(r)/COA 18.99
                         EOA 29.48
                         SOA 7.42
                         WOA 27.46/ ;
         Cap_target('COA') = 28.5*1.2;

* theta(r,e,l)$m(r,e,l) =  2*smax(h$(not nuclear(h)),(ic(h)+om(h)))/sum((ee,ll),d(ee,ll))
 theta(r,e,l)$m(r,e,l) =  2*smax(h$(not nuclear(h)),(ic(h)+om(h)))/sum((ee,ll),d(ee,ll))*(1+0.2$coa(r))
;
xi(r,e,l)$m(r,e,l) = smax(h$(not nuclear(h)),(ic(h)+om(h)))/sum((ee,ll),d(ee,ll))/Cap_target(r)
;


$INCLUDE emp.gms

Option Savepoint=1;

*solve CMO using mcp;
if(r_options<>1,
    Execute_Loadpoint 'results/capacity_auction_coa.gdx';
    CMO.optfile = 1 ;
    SOLVE CMO using emp;
else
    CMO_options.optfile = 1 ;
    SOLVE CMO_options using emp;
);
$include report.gms
