$title Dynamic Programming Investment
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms
$FuncLibIn stolib stodclib
function cdfnorm /stolib.cdfnormal/;

scalar trading set to 1 to allow regional trade by firms /0/
       fixed_ppa  /0/
       legacy_auction /0/

$INCLUDE SetsAndVariables.gms

$INCLUDE Demand.gms
$include parameters.gms
$include marginal_cost.gms

$INCLUDE equations.gms
$include demand_calib.gms

$include scen_config.gms

*v(i) = -1;
*z(i) = -1;

$ontext
*        Configure capacity market segments
         scalar price_threshold /1.6/
                 capacity_threshold /0.9/
*  Enter file to load previous data from
$gdxin test_1.gdx
$include capacity_market.gms
$offtext
;
*m(r,e,l)$(summer(e) and ord(l)<=8 and ord(l)>3)=yes;
Option Savepoint=1;

Execute_Loadpoint 'capacity_summ.gdx';

CMO.optfile = 1 ;

solve CMO using mcp;

$include report.gms
