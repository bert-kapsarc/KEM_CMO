$title Dynamic Programming Investment with Reliability Options
$ontext

$offtext
$ifThen "%system.platform%" == "WEX"
$set SLASH \
$else
$set SLASH /
$endIf
$stars *##*
$inlinecom /* */

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms
$FuncLibIn stolib stodclib
function cdfnorm /stolib.cdfnormal/;

$INCLUDE SetsAndVariables.gms
$INCLUDE Demand.gms
$include parameters.gms
$include marginal_cost.gms
$include demand_calib.gms
$INCLUDE equations.gms
$include scen_config.gms
;
$ifThen set calibration
$setglobal scenario calib
inv.fx(i,h,r)=0;
ret.fx(i,h,r)=0;
$else
$ifThen.capacity set capacity
$setglobal scenario capacity_%capacity%
$ifThen.pv set PVratio
$setglobal scenario %scenario%_PV%PVratio%
$endIf.pv
$else.capacity
$setglobal scenario energy
$endIf.capacity
$endIf
;
$ifThen set cournot
$setglobal energy_market energy_cournot
$setglobal scenario %scenario%_cournot
$else
$setglobal energy_market energy
$endIf


$ifThen set capacity
* Configure capacity market segments
* Load energy only market data to configure capacity market segments
$include capacity_market.gms
$endIf

$ifThen set noFuelSubsidy
$setglobal scenario %scenario%_fuelReform
$endIF



$ifThen.loadpoint exist build%SLASH%%scenario%.gdx
    execute_load 'build%SLASH%%scenario%'
$else.loadpoint
    execute_load 'build%SLASH%energy'
$endif.loadpoint
;
inv.fx(i,h,r)$GTtoCC(h)=0
Option Savepoint=1;
model CMO_opt_downtime /cmo/ ;
CMO.optfile =  1;
$ifThen set LP
    demand.fx(r,e,l,s,ss) = EL_demand(r,e,l,s)
    SOLVE power using NLP minimizing ELcost;
$else
$INCLUDE emp.gms
    Repeat(SOLVE CMO using emp; until(CMO.solveStat ne 13));
    if(CMO.modelstat gt 2, abort "The model didn't converge....");
$endIF
*execute_load  'build%SLASH%%scenario%', price,demand,Cap_avail,profitR,q,delta,inv,ret,price_trans,sales,Load,arbitrage;
;
$include report.gms

