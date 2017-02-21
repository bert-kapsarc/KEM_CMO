
parameter EL_demgro(r)  projected percentage growth in electricity demand from 2015 to 2020 by region
/
WOA      1.183
EOA      1.368
SOA      1.329
COA      1.217
/
;

*        apply growth equally to all demand segments
EL_demand(r,e,l,s,ss)= EL_demand(r,e,l,s,ss)*EL_demgro(r);
$INCLUDE solar.gms

parameter elasticity(r,e,l,s,ss) demand elasticity for eletricity;
elasticity(r,e,l,s,ss) = 0.16;

parameter  LRMC(r,seasons,l,s,ss) long run marginal cost in each load segment USD per MWH
           LRMC_baseline(r,seasons,l,s,ss) baseline LRMC;

parameter util_hrs(r,e,l,s,ss) average number of hours in a given load segment;
         util_hrs(r,e,l,s,ss)=
         sum((ee,ll)$(EL_Demand(r,ee,ll,s,ss)>=EL_Demand(r,e,l,s,ss)),d(ee,ll));

* long run marginal cost. rescale capacity payment to USD/MWh
LRMC(r,e,l,s,ss) =
smin((h,f)$(fuel_set(h,f,r) and oil(f) and not nuclear(h) and not gttocc(h)),
         mc_reform(h,f,r)+((ic(h)+om(h))/util_hrs(r,e,l,s,ss))
);

LRMC_baseline(r,e,l,s,ss) =
smin((h,f)$(fuel_set(h,f,r) and not nuclear(h) and not gttocc(h)),
         mc_baseline(h,f,r)+((ic(h)+om(h))/util_hrs(r,e,l,s,ss))
);

* Adjust baseline LRMC during select market segments (calibration)
*LRMC_baseline(r,e,l,s,ss) = LRMC_baseline(r,e,l,s,ss)*
*         ( 1.2*util_hrs(r,e,l,s,ss)$(util_hrs(r,e,l,s,ss)<0.5*8.760 and util_hrs(r,e,l,s,ss)>=0.2*8.760  )
*          +1.8*util_hrs(r,e,l,s,ss)$(util_hrs(r,e,l,s,ss)<0.2*8.760)
*          +util_hrs(r,e,l,s,ss)$(util_hrs(r,e,l,s,ss)>=0.5*8.760))/8.760;

a(r,e,l,s,ss) = LRMC(r,e,l,s,ss)*(1+1/elasticity(r,e,l,s,ss));
b(r,e,l,s,ss) = LRMC(r,e,l,s,ss)/EL_demand(r,e,l,s,ss)/elasticity(r,e,l,s,ss);

parameter        c(r,e,l,s,ss)
                 EL_demand_resp(r,e,l,s,ss) equlibrium demand response after price reform;


c(r,e,l,s,ss) =  (LRMC(r,e,l,s,ss)-LRMC_baseline(r,e,l,s,ss))/
                 ((LRMC_baseline(r,e,l,s,ss)+LRMC(r,e,l,s,ss))/2);

EL_demand_resp(r,e,l,s,ss) = EL_demand(r,e,l,s,ss)*
         (1-c(r,e,l,s,ss)/2*elasticity(r,e,l,s,ss))/
         (1+c(r,e,l,s,ss)/2*elasticity(r,e,l,s,ss));

b(r,e,l,s,ss) = (LRMC(r,e,l,s,ss)-LRMC_baseline(r,e,l,s,ss))/
                 (EL_demand(r,e,l,s,ss)-EL_demand_resp(r,e,l,s,ss));
a(r,e,l,s,ss) = LRMC(r,e,l,s,ss)+b(r,e,l,s,ss)*EL_demand_resp(r,e,l,s,ss);

* Capacity Price calibration                                                   *
* assume a flat inverse demand curve for capacity
* price is set to the maximum fixed cost of all generators operating in the market
* soread of the total number of demand hours

         theta(r,e,l) =
                 +smax(h$(not nuclear(h)),(ic(h)+om(h)))/
                 sum((ee,ll),d(ee,ll))
*                 sum((s,ss),util_hrs(r,e,l,s,ss)*prob(r,e,l,s,ss))
*                 sum((s),prob(s,ss)*d(e,m))    ;
*                 sum((s,ll)$(EL_Demand(r,e,ll,s,ss)>=EL_Demand(r,e,m,s,ss)),prob(s,ss)*d(e,ll));
;
         xi(r,e,l)$m(r,e,l) =0;


