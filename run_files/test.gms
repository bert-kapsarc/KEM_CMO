$title Dynamic Programming Investment
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms
$FuncLibIn stolib stodclib
function cdfnorm /stolib.cdfnormal/;

scalar trading set to 1 to allow regional trade by firms /0/
       fixed_ppa  /0/
       r_options reliability options switch /1/

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

$ontext
*        Configure capacity market segments
         scalar price_threshold /1.6/
                 capacity_threshold /0.9/
*  Enter file to load previous data from
$gdxin test_1.gdx
$include capacity_market.gms
$offtext
;
m(r,e,l) =yes;
*$(summer(e))
Option Savepoint=1;

*Execute_Loadpoint 'test_2.gdx';

CMO.optfile = 1 ;

solve CMO using mcp;

$include report.gms
