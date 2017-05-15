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

file empinfo / '%emp.info%' /;

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
*  Enter file to load previous data from
$gdxin test_1.gdx
$LOAD demand_actual Cap_avail price
$include capacity_market.gms
$offtext
;

$INCLUDE emp.gms

Option Savepoint=1;
option reslim = 1e5;

if(r_options<>1,
         Execute_Loadpoint 'test.gdx';
         CMO.optfile = 1 ;
         SOLVE CMO using emp;
else
*         Execute_Loadpoint 'CMO_options_p.gdx';
         CMO_options.optfile = 1 ;
         SOLVE CMO_options using emp;
);
$include report.gms
