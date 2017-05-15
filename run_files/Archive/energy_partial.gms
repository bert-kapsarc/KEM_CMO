$title Dynamic Programming Investment
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms
$FuncLibIn stolib stodclib
function cdfnorm /stolib.cdfnormal/;

scalar trading set to 1 to allow regional trade by firms /0/
       fixed_ppa  /0/;

$INCLUDE SetsAndVariables.gms

$INCLUDE Demand.gms
$include parameters.gms
$include marginal_cost.gms

$INCLUDE equations.gms
$include demand_calib.gms

$include scen_config.gms

$ontext
*        Configure capacity market segments
         scalar price_threshold /1.25/
*  Enter file to load previous data from
$gdxin test.gdx
$include capacity_market.gms
$offtext

Option Savepoint=1;

Execute_Loadpoint 'energy_partial.gdx';

CMO.optfile = 1 ;

solve CMO using mcp;

$include report.gms
