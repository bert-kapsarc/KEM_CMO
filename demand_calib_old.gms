
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

parameter elasticity(r,e,l,s,ss) demand elasticity for eletricity ???;
elasticity(r,e,l,s,ss) = 0.16;

parameter  LRMC(r,seasons,l,s,ss) long run marginal cost in each load segment USD per MWH
           LRMC_baseline(r,seasons,l,s,ss);

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

LRMC_baseline(r,e,l,s,ss) = LRMC_baseline(r,e,l,s,ss)*
         ( 1.2*util_hrs(r,e,l,s,ss)$(util_hrs(r,e,l,s,ss)<0.5*8.760 and util_hrs(r,e,l,s,ss)>=0.2*8.760  )
          +1.8*util_hrs(r,e,l,s,ss)$(util_hrs(r,e,l,s,ss)<0.2*8.760)
          +util_hrs(r,e,l,s,ss)$(util_hrs(r,e,l,s,ss)>=0.5*8.760))/8.760;
*

*LRMC_baseline('WOA',winter,l,s,ss) = 0.1;
*LRMC_baseline('EOA',e,l,s,ss)$(util_hrs('EOA',e,l,s,ss)>=0.2*8.760) = LRMC_baseline('EOA',e,l,s,ss)*1.1;
*LRMC_baseline('COA',e,l,s,ss)$(util_hrs('COA',e,l,s,ss)<0.2*8.760) = LRMC_baseline('COA',e,l,s,ss)*1.1;

a1(r,e,l,s,ss) = LRMC_baseline(r,e,l,s,ss)*(1+1/elasticity(r,e,l,s,ss));
b1(r,e,l,s,ss) = LRMC_baseline(r,e,l,s,ss)/EL_demand(r,e,l,s,ss)/elasticity(r,e,l,s,ss);


parameter c(r,e,l,s,ss)
         EL_demand_resp(r,e,l,s,ss) approximated equlibrium demand after price increase;


parameter q_x,p_x;

c(r,e,l,s,ss) =  (LRMC(r,e,l,s,ss)-LRMC_baseline(r,e,l,s,ss))/
                 ((LRMC_baseline(r,e,l,s,ss)+LRMC(r,e,l,s,ss))/2);

EL_demand_resp(r,e,l,s,ss) = EL_demand(r,e,l,s,ss)*
         (1-c(r,e,l,s,ss)/2*elasticity(r,e,l,s,ss))/
         (1+c(r,e,l,s,ss)/2*elasticity(r,e,l,s,ss));

q_x(r,e,l,s,ss)=(EL_demand_resp(r,e,l,s,ss)+EL_demand(r,e,l,s,ss))/2;
p_x(r,e,l,s,ss)=a1(r,e,l,s,ss)-b1(r,e,l,s,ss)*q_x(r,e,l,s,ss);

b2(r,e,l,s,ss) = (LRMC(r,e,l,s,ss)-LRMC_baseline(r,e,l,s,ss))/
                 (EL_demand(r,e,l,s,ss)-EL_demand_resp(r,e,l,s,ss));
a2(r,e,l,s,ss) = LRMC(r,e,l,s,ss)+b2(r,e,l,s,ss)*EL_demand_resp(r,e,l,s,ss);
a1(r,e,l,s,ss) = a2(r,e,l,s,ss);
b1(r,e,l,s,ss) = b2(r,e,l,s,ss);

$ontext

b2(r,e,l,s,ss) = (LRMC(r,e,l,s,ss)-p_x(r,e,l,s,ss))/
                 (q_x(r,e,l,s,ss)-EL_demand_resp(r,e,l,s,ss));
a2(r,e,l,s,ss) = p_x(r,e,l,s,ss)+b2(r,e,l,s,ss)*q_x(r,e,l,s,ss);
$offtext
$ontext
LRMC(r,e,l,s,ss)$(util_hrs(r,e,l,s,ss)<0.2*8.760) =
         LRMC(r,e,l,s,ss)*util_hrs(r,e,l,s,ss)/8.76*5;
b2(r,e,l,s,ss) = b1(r,e,l,s,ss);
a2(r,e,l,s,ss) = LRMC(r,e,l,s,ss)+b2(r,e,l,s,ss)*EL_demand(r,e,l,s,ss);
$offtext

* Energy Price calibration                                                     *
IF(fixed_ppa =1,
a(r,e,l,s,ss) = a1(r,e,l,s,ss);
b(r,e,l,s,ss) = b1(r,e,l,s,ss);
else
*a2(r,e,l,s,ss) = LRMC(r,e,l,s,ss)*(1+1/elasticity(r,e,l,s,ss));
*b2(r,e,l,s,ss) = LRMC(r,e,l,s,ss)/EL_demand(r,e,l,s,ss)/elasticity(r,e,l,s,ss);
a(r,e,l,s,ss) = a2(r,e,l,s,ss);
b(r,e,l,s,ss) = b2(r,e,l,s,ss);
);



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


