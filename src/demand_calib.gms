
parameter EL_demgro(r)  projected percentage growth in electricity demand from 2015 to 2020 by region
/
WOA      1.183
EOA      1.368
SOA      1.329
COA      1.217
/
;

*        apply growth equally to all demand segments
EL_Demand(r,seasons,l,s)= EL_Demand(r,seasons,l,s)*EL_demgro(r)*0.85;
$INCLUDE solar.gms

parameter elasticity(r,seasons,l,s) demand elasticity for eletricity;
elasticity(r,seasons,l,s) = 0.16;

parameter  LRMC(r,seasons,l,s) long run marginal cost in each load segment USD per MWH
           LRMC_baseline(r,seasons,l,s) baseline LRMC;

parameter util_hrs(r,seasons,l,s) average number of hours in a given load segment;
alias (season,sseasons);
         util_hrs(r,seasons,l,s)=
         sum((sseasons,ll)$(EL_Demand(r,sseasons,ll,s)>=EL_Demand(r,seasons,l,s)),d(sseasons,ll));

* long run marginal cost. rescale capacity payment to USD/MWh
LRMC(r,e,l,s) =
smin((h,f)$(fuel_set(h,f,r) and oil(f) and not nuclear(h) and not gttocc(h)),
         mc_reform(h,f,r)+((ic(h)+om(h))/util_hrs(r,e,l,s))
);

LRMC_baseline(r,e,l,s) =
smin((h,f)$(fuel_set(h,f,r) and not nuclear(h) and not gttocc(h)),
         mc_baseline(h,f,r)+((ic(h)+om(h))/util_hrs(r,e,l,s))
);

a(r,e,l,s) = LRMC(r,e,l,s)*(1+1/elasticity(r,e,l,s));
b(r,e,l,s) = LRMC(r,e,l,s)/EL_demand(r,e,l,s)/elasticity(r,e,l,s);

parameter        c(r,e,l,s)
                 EL_demand_resp(r,e,l,s) equlibrium demand response after price reform;


c(r,e,l,s) =  (LRMC(r,e,l,s)-LRMC_baseline(r,e,l,s))/
                 ((LRMC_baseline(r,e,l,s)+LRMC(r,e,l,s))/2);

EL_demand_resp(r,e,l,s) = EL_demand(r,e,l,s)*
         (1-c(r,e,l,s)/2*elasticity(r,e,l,s))/
         (1+c(r,e,l,s)/2*elasticity(r,e,l,s));

b(r,e,l,s) = (LRMC(r,e,l,s)-LRMC_baseline(r,e,l,s))/
                 (EL_demand(r,e,l,s)-EL_demand_resp(r,e,l,s));
a(r,e,l,s) = LRMC(r,e,l,s)+b(r,e,l,s)*EL_demand_resp(r,e,l,s);

* Capacity Price calibration                                                   *
* assume a flat inverse demand curve for capacity
* price is set to the maximum fixed cost of all generators operating in the market
* soread of the total number of demand hours

         theta(r,e,l) =
                 +smax(h$(not nuclear(h)),(ic(h)+om(h)))/
                 sum((ee,ll),d(ee,ll))
*                 sum((s),util_hrs(r,e,l,s)*prob(r,e,l,s,ss))
*                 sum((s),prob(s,ss)*d(e,m))    ;
*                 sum((s,ll)$(EL_Demand(r,e,ll,s)>=EL_Demand(r,e,m,s)),prob(s,ss)*d(e,ll));
;
         xi(r,e,l)$m(r,e,l) =0;


