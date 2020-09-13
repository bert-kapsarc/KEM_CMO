
parameter EL_demgro(r)  projected percentage growth in electricity demand from 2015 to 2020 by region

/
WOA      1.09
EOA      1.12
SOA      1.14
COA      1.11
$ontext
WOA      1.183
EOA      1.368
SOA      1.329
COA      1.217
$offtext
/
EL_Demand_calib(r,seasons,l,s)
;

if(not e('summer-wknd'),
    EL_Demand(r,'summer',l,s)=sum(summer,EL_Demand(r,summer,l,s)*d(summer,l))/sum(summer,d(summer,l));
*    util_hrs(r,'summer',l,s)=sum(summer,util_hrs(r,summer,l,s));
    d('summer',l)=sum(summer,d(summer,l));
);
if(not e('spf-wknd'),
    EL_Demand(r,'spfa',l,s)=sum(spring,EL_Demand(r,spring,l,s)*d(spring,l))/sum(spring,d(spring,l));
*    util_hrs(r,'spfa',l,s)=sum(spring,util_hrs(r,spring,l,s));
    d('spfa',l)=sum(spring,d(spring,l));
);
if(not e('winter-wknd'),
    EL_Demand(r,'winter',l,s)=sum(winter,EL_Demand(r,winter,l,s)*d(winter,l))/sum(winter,d(winter,l));
*    util_hrs(r,'winter',l,s)=sum(winter,util_hrs(r,winter,l,s));
    d('winter',l)=sum(winter,d(winter,l));
);

*  apply level growth to all demand segments
EL_Demand_calib(r,seasons,l,s)= EL_Demand(r,seasons,l,s);
EL_Demand(r,seasons,l,s)= EL_Demand(r,seasons,l,s)*EL_demgro(r);

;
$INCLUDE solar.gms

parameter elasticity(r,seasons,l,s) demand elasticity for eletricity;

elasticity(r,seasons,l,s) = 0.16;

parameter  LRMC(r,seasons,l,s) long run marginal cost in each load segment USD per MWH
           LRMC_baseline(r,seasons,l,s) baseline LRMC;

parameter util_hrs(r,seasons,l,s) average number of hours in a given load segment;
alias (season,sseasons);
    util_hrs(r,seasons,l,s)=
    sum((sseasons,ll)$(EL_Demand(r,sseasons,ll,s)>=EL_Demand(r,seasons,l,s)),d(sseasons,ll))
;

* long run marginal cost. rescale capacity payment to USD/MWh
LRMC(r,e,l,s) =
*smax((h,f)$(fuel_set(h,f,r)),mc(h,f,r)+(ici(h)+om(h))/util_hrs(r,e,l,s))
*$ontext
smax((h,f)$(fuel_set(h,f,r)  and CCGT(h)),mc(h,f,r)+(ici(h)+om(h))/util_hrs(r,e,l,s)
    )$(EL_Demand(r,e,l,s)<=sum((i,h)$CCGT(h),kind0(i,h,r)))
+smax((h,f)$(fuel_set(h,f,r) and not GT(h) and not ren(h)),mc(h,f,r)+(ici(h)+om(h))/util_hrs(r,e,l,s)
    )$(EL_Demand(r,e,l,s)>sum((i,h)$CCGT(h),kind0(i,h,r)) and EL_Demand(r,e,l,s)<=sum((i,h)$(not GT (h)),kind0(i,h,r)))
+smax((h,f)$(fuel_set(h,f,r) and GT(h)),mc(h,f,r)+(ici(h)+om(h))/util_hrs(r,e,l,s)
    )$(EL_Demand(r,e,l,s)>sum((i,h)$(not GT(h)),kind0(i,h,r)))
*$offtext
;

LRMC_baseline(r,e,l,s) =
*smax((h,f)$(fuel_set(h,f,r)),mc_baseline(h,f,r)+(ici(h)+om(h))/util_hrs(r,e,l,s))
*$ontext
smax((h,f)$(fuel_set(h,f,r) and CCGT(h)),mc_baseline(h,f,r)+(ici(h)+om(h))/util_hrs(r,e,l,s)
    )$(EL_Demand(r,e,l,s)<sum((i,h)$CCGT(h),kind0(i,h,r)))
*+smax((h,f)$(fuel_set(h,f,r) and GT(h)),mc_baseline(h,f,r)+(ici(h)+om(h))/util_hrs(r,e,l,s)
*    )$(EL_Demand(r,e,l,s)>=sum((i,h)$CCGT(h),kind0(i,h,r)))
*$ontext
+smax((h,f)$(fuel_set(h,f,r) and not GT(h) and not ren(h)),mc_baseline(h,f,r)+(ici(h)+om(h))/util_hrs(r,e,l,s)
    )$(EL_Demand(r,e,l,s)>sum((i,h)$CCGT(h),kind0(i,h,r)) and EL_Demand(r,e,l,s)<=sum((i,h)$(not GT (h)),kind0(i,h,r)))
+smax((h,f)$(fuel_set(h,f,r) and GT(h)),mc_baseline(h,f,r)+(ici(h)+om(h))/util_hrs(r,e,l,s)
    )$(EL_Demand(r,e,l,s)>sum((i,h)$(not GT(h)),kind0(i,h,r)))
*$offtext
;

a(r,e,l,s) = LRMC_baseline(r,e,l,s)*(1+1/elasticity(r,e,l,s));
b(r,e,l,s) = LRMC_baseline(r,e,l,s)*1/(EL_demand(r,e,l,s)*d(e,l))/elasticity(r,e,l,s)*1.092
;
$ontext
parameter        c(r,e,l,s)
                 EL_demand_resp(r,e,l,s) equlibrium demand response after price reform;


c(r,e,l,s) =  (LRMC(r,e,l,s)-LRMC_baseline(r,e,l,s))/
                 ((LRMC_baseline(r,e,l,s)+LRMC(r,e,l,s))/2);

EL_demand_resp(r,e,l,s) = EL_demand(r,e,l,s)*
         (1-c(r,e,l,s)/2*elasticity(r,e,l,s))/
         (1+c(r,e,l,s)/2*elasticity(r,e,l,s));

b(r,e,l,s) = (LRMC(r,e,l,s)-LRMC_baseline(r,e,l,s))/
                 ((EL_demand(r,e,l,s)-EL_demand_resp(r,e,l,s))*d(e,l));
a(r,e,l,s) = LRMC(r,e,l,s)+b(r,e,l,s)*EL_demand_resp(r,e,l,s);
$offtext



