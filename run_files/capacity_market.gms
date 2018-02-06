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

m(r,e,l)=no;

*$ontext
*        Configure capacity market segments
*  Enter file to load previous data from
$gdxin results/energy_only.gdx
$LOAD demand Cap_avail price
$include capacity_market.gms
*$offtext
;

$INCLUDE emp.gms

Option Savepoint=1;

*solve CMO using mcp;
if(r_options<>1,
    Execute_Loadpoint 'results/capacity_payment.gdx';
    CMO.optfile = 1 ;
    SOLVE CMO using emp;
else
    CMO_options.optfile = 1 ;
    SOLVE CMO_options using emp;
);
$include report.gms
