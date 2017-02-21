$title Dynamic Programming Investment
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms
$FuncLibIn stolib stodclib
function cdfnorm /stolib.cdfnormal/;

scalar trading set to 1 to allow regional trade by firms /0/
       fixed_ppa  /0/
       legacy_auction /0/ ;

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
         scalar capacity_threshold /1/
*  Enter file to load previous data from
$gdxin testc_2.gdx
$include capacity_market.gms
$offtext
m(r,e,l)$(summer(e) and ord(l)<=8 and ord(l)>3)=yes;

 Parameter Cap_target(r)/COA 18.99
                         EOA 29.48
                         SOA 7.42
                         WOA 27.46/ ;

         Cap_target('COA') = 25;
         Cap_target('WOA') = 25;

 xi(r,e,l)$m(r,e,l) = smax(h$(not nuclear(h)),(ic(h)+om(h)))/sum((ee,ll),d(ee,ll))/sum(rr,Cap_target(rr)) ;
 theta(r,e,l)$m(r,e,l) =  smax(h$(not nuclear(h)),(ic(h)+om(h)))/sum((ee,ll),d(ee,ll))*2- (xi(r,e,l)*(sum(rr,Cap_target(rr))-cap_target(r))) ;


Option Savepoint=1;

Execute_Loadpoint 'capacity_auction_new_intercept.gdx';

CMO.optfile = 1 ;

solve CMO using mcp;

$include report.gms
