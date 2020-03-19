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

$ontext
*        Configure capacity market segments
*  Enter file to load previous data from
$gdxin energy_only.gdx
$LOAD demand_actual Cap_avail price
$include capacity_market.gms
$offtext
;

$INCLUDE emp.gms
cournot(i)$genco(i) = no;
Option Savepoint=1;
    CMO.optfile = 1 ;
    power.optfile =  1;
*solve CMO using mcp;
if(r_options<>1,
*    inv.fx(i,h,r) =0;
*    inv.up(i,'GT',r) = inf;
*    cap_uptime('GT',r,summer) =    cap_uptime('GT',r,summer)*0.6;
*    cap_uptime('CCGT',r,summer) =    cap_uptime('CCGT',r,summer)*0.95;
*    inv.up(i,'CCGT',r) = inf;
    Execute_Loadpoint 'power_p.gdx';

*    SOLVE CMO using emp;
    SOLVE power using NLP minimizing ELcost;
else
*    Execute_Loadpoint 'test.gdx';
    CMO_options.optfile = 1 ;
    SOLVE CMO_options using emp;
);
$include report.gms
