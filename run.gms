$title Dynamic Programming Investment with Reliability Options
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms
$FuncLibIn stolib stodclib
function cdfnorm /stolib.cdfnormal/;

scalar
    fixed_ppa  /1/

$INCLUDE SetsAndVariables.gms
$INCLUDE Demand.gms
$include parameters.gms
$include marginal_cost.gms
$include demand_calib.gms
$INCLUDE equations.gms
$include scen_config.gms
;

$ontext
* Configure capacity market segments
* Load energy only market data to configure capacity market segments
$gdxin energy_cournot.gdx
$LOAD demand_actual Cap_avail price
$include capacity_market.gms
$offtext
;
$INCLUDE emp.gms

*Option Savepoint=1;
model CMO_opt_downtime /cmo/ ;
CMO.optfile =  1;
*solve CMO using mcp;
*    inv.fx(i,h,r) =0;
*    inv.up(i,'GT',r) = inf;
*    inv.up(i,'CCGT',r) = inf;
*    cap_uptime(h,r,e) = cap_uptime(h,r,e)*(1+0.005$((CCGT(h) or GT(h)) and (winter(e) or spring(e))) )
*
    Execute_Loadpoint 'CMO_p.gdx';
*    SOLVE power using NLP minimizing ELcost;
    SOLVE CMO using emp;
$include report.gms
