
$INCLUDE Macros.gms

$FuncLibIn stolib stodclib
function cdfnorm     /stolib.cdfnormal/;

$INCLUDE SetsAndVariables.gms
Parameters
         profit(company,tech)         profit per player by tech
         roi(company,tech)              return on investment
         cus(company,tech)              capacity usage
         rop(company,tech)              return on production
         roc(company,tech)              return on capacity




         production(company,tech)       production by player


         error_demand(r,e,l)
         reserve_capacity(r)
         ;

         scalar         consumer_surplus                consumer surplus ;


Execute_Loadpoint 'capacity_tailored_deterministic.gdx', profit, inv, roi, cus, rop, roc, consumer_surplus, production, error_demand, reserve_capacity, price, delta;

execute_unload 'report_capacity_tailored_deterministic.gdx', profit, inv, roi, cus, rop, roc, consumer_surplus, production, error_demand, reserve_capacity, price, delta ;
execute '=gdx2access report_capacity_tailored_deterministic.gdx';