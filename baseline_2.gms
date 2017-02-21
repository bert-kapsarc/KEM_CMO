$title Dynamic Programming Investment
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms
$FuncLibIn stolib stodclib
function cdfnorm     /stolib.cdfnormal/;

scalar trading set to 1 to allow regional trade by firms /0/
       fixed_ppa  /1/;

$INCLUDE SetsAndVariables.gms

$INCLUDE Demand.gms
$include parameters.gms
$include marginal_cost.gms

$INCLUDE equations.gms
$include demand_calib.gms

$include scen_config.gms

* apply perfect competition to all firms. No market power (Cournot).
     v(i) = -1;


$ontext
*        Configure capacity market segments
         scalar price_threshold /1.2/
*  Enter file to load previous data from
$gdxin test.gdx
$include capacity_market.gms
$offtext

*        Genco PPA aggregated by region
loop(h$(not GTtoCC(h) and not nuclear(h)),
         Genco_PPA(h,'EOA')=79;
         Genco_PPA(h,'SOA')=26;
         Genco_PPA(h,'WOA')=93;
         Genco_PPA(h,'COA')=87;
);
Genco_PPA(h,r)$(not ST(h))=Genco_PPA(h,r)*EL_demgro(r);


* Assign PPA per technology assuming CCGT receive baseload and other technolgoies absorb the rest.
Genco_PPA('CCGT',r)=sum(i,kind0(i,'CCGT',r))*sum((e,l),d(e,l))*0.9;
Genco_PPA('ST',r)=sum(i,kind0(i,'ST',r))*sum((e,l),d(e,l))*0.6;
Genco_PPA('ST','WOA')=Genco_PPA('ST','WOA')*0.8;
Genco_PPA('GT',r)=(Genco_PPA('GT',r)-Genco_PPA('ST',r)-Genco_PPA('CCGT',r));
*$offtext
Genco_PPA(h,r)$(Genco_PPA(h,r)<0)=0;
*Genco_PPA(h,r)=0;
Option Savepoint=2;
Execute_Loadpoint 'test.gdx';

q.l(i,'GTtoCC',f,r,e,l,s,ss) = 0 ;
CMO.optfile = 1 ;

solve CMO using mcp;

$include report.gms

