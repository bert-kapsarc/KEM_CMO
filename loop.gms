          set scenario /1*11/
              prices /'energy price, USD/MWH'/;

          parameter results_profits(scenario,*,*,*),results,results_reserves,results_prices(scenario,prices,r,e,l) ;
loop(scenario,
*        cap on market share (investments) by firm
     market_share_cap('fringe') = 0.2*(ord(scenario)-1)/card(scenario);

*        Capacity market configuration
     m(r,e,l) = no;
*$ontext
*        Used to customize capacity markets based on expected prices that are greater than double the baseload prices


Execute_Load 'energy_high.gdx', results_prices ;
         loop(l,
          m(r,e,l)$(    results_prices(scenario,'energy price, USD/MWH',r,e,l)>
                         2*smin(ll,results_prices(scenario,'energy price, USD/MWH',r,e,ll))
                 )=yes
         );
*$offtext

         solve CMO using mcp;
$include report.gms
         results_profits(scenario,'profits, million USD','consumer surplus',r) = consumer_surplus(r);
         results_profits(scenario,'profits, million USD',i,r) = sum(h,profit(i,h));
         results(scenario,'production, TWH',i,h,r) = sum((e,l,s,ss),prob(r,e,l,s,ss)*q.l(i,h,r,e,l,s,ss)*d(e,l));
         results(scenario,'investments, GW',i,h,r) = inv.l(i,h,r);
         results_reserves(scenario,'reserves',r) =  reserve_capacity(r);
         results_prices(scenario,'energy price, USD/MWH',r,e,l) = price_avg(r,e,l);
);