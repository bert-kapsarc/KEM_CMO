
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

if(no_fringe=1,
         i('fringe')=no ;
         Q.l('fringe',h,r,e,l,s,ss)    =0;
         Q.l('fringe','GT',r,seasons,'l5',s,ss)=kind0('fringe','GT',r)*0.5$(summer(seasons));
         Q.l('fringe','GT',r,seasons,'l6',s,ss)=kind0('fringe','GT',r)*0.5$(summer(seasons));
         Q.l('fringe','GT',r,seasons,'l7',s,ss)=kind0('fringe','GT',r)*0.5$(summer(seasons));

         Q.l('fringe','ST',r,e,l,s,ss)=kind0('fringe','ST',r)*0.8;
         Q.l('fringe','CCGT',r,e,l,s,ss)=kind0('fringe','CCGT',r)*0.8;

         EL_Demand(r,e,l,s,ss) = (EL_Demand(r,e,l,s,ss) -sum(h,Q.l('fringe',h,r,e,l,s,ss)))$(EL_Demand(r,e,l,s,ss)-sum(h,Q.l('fringe',h,r,e,l,s,ss))>smin(ll,EL_Demand(r,e,ll,s,ss)))
                                 +smin(ll,EL_Demand(r,e,ll,s,ss))$(EL_Demand(r,e,l,s,ss)-sum(h,Q.l('fringe',h,r,e,l,s,ss))<=smin(ll,EL_Demand(r,e,ll,s,ss)))
                                 ;

);

parameter elasticity(r) demand elasticity for eletricity ???;

parameter  LRMC(r,e,l,s,ss) long run marginal cost in each load segment USD per MWH;

* long run marginal cost. rescale capacity payment to USD/MW
LRMC(r,e,l,s,ss) =
smin(h,mc(h,r,s,ss)+(ic(h)+om(h))/sum((ll)$(EL_Demand(r,e,ll,s,ss)>=EL_Demand(r,e,l,s,ss)),d(e,ll)) )
;

elasticity(r) = 0.16;

* Energy Price calibration                                                     *
            a(r,e,l,s,ss) = LRMC(r,e,l,s,ss)*(1+1/elasticity(r));
            b(r,e,l,s,ss) = LRMC(r,e,l,s,ss)/EL_demand(r,e,l,s,ss)/elasticity(r) ;


* Capacity Price calibration                                                   *


* assume a flat inverse demand curve for capacity
* price is set to the maximum fixed cost of all generators operating in the market
* soread of the total number of demand hours

         theta(r,e,l) =  0
                 +smax(h$(not nuclear(h)),(ic(h)+om(h)))/sum((ee,ll),d(ee,ll))
*                 sum((s),prob(s,ss)*d(e,m))    ;
*                 sum((s,ll)$(EL_Demand(r,e,ll,s,ss)>=EL_Demand(r,e,m,s,ss)),prob(s,ss)*d(e,ll));
;
         xi(r,e,l)$m(r,e,l) =0;



$ontext
         a(r,'l1',s,ss) = 1200 +uniform(0,100);
         a(r,'l2',s,ss) = 600 +uniform(0,50);
         a(r,'l3',s,ss) = 300 +uniform(0,10);

         b(r,'l1',s,ss) = 0.005 +uniform(0,0.0005);
         b(r,'l2',s,ss) = 0.01 +uniform(0,0.0005);
         b(r,'l3',s,ss) = 0.01 +uniform(0,0.0005);


theta(r,e,'l1') = 5000 +uniform(0,200);
theta(r,e,'l2') = 3000 +uniform(0,100);
theta(r,e,'l3') = 2000 +uniform(0,50);

xi(r,e,'l1') = 0.00001 ;
xi(r,e,'l2') = 0.00002 ;
xi(r,e,'l3') = 0.00003 ;
$offtext

