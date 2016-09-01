
parameter EL_demgro(r)  projected percentage growth in electricity demand from 2015 to 2020 by region
/
WOA      1.183
EOA      1.368
SOA      1.329
COA      1.217
/
;
*        apply growth equally to all demand segments
         EL_Demand(r,e,l,s) = ELlcgw(r,e,l)*EL_demgro(r);

parameter elasticity(r) demand elasticity for eletricity ???;
elasticity(r) = 0.3;

* Energy Price calibration                                                     *
            a(r,e,l,s) = smax(h,mc(h,r,s))*(1+elasticity(r));
            b(r,e,l,s) = smax(h,mc(h,r,s)/(EL_demand(r,e,l,s)))*elasticity(r);

*            b(r,e,l,s) = smax(h,mc(h,r,s))*d(e,l)/
*            sum(ll$(EL_Demand(r,e,ll,s)<=EL_Demand(r,e,l,s)),EL_demand(r,e,ll,s)*d(e,ll))*elasticity(r)
         ;



* Capacity Price calibration                                                   *

*capacity market for GT only in 3 highest demand segments
beta('GT',r,'l5')=1;
beta('GT',r,'l6')=1;
beta('GT',r,'l7')=1;

*beta('CCGT',r,'l1')=1;
*beta('CCGT',r,'l2')=1;
*beta('CCGT',r,'l3')=1;
*beta('CCGT',r,'l4')=1;
*beta('CCGT',r,'l8')=1;
;
* no capacity markets
*beta(h,r,l)=0;


* assume a flat inverse demand curve for capacity
* price is set to the maximum fixed cost of all generators operating in the market
* divided by the expected number of hours in each load segment

theta(r,e,m) = smax(h$(beta(h,r,m)=1),(ici(h)+om(h)))/
*                 d(e,m)    ;
                 sum((s,ll)$(EL_Demand(r,e,ll,s)>=EL_Demand(r,e,m,s)),prob(s)*d(e,ll));

                 xi(r,e,m) =0;

theta(r,e,m)$(smax((h),beta(h,r,m))=0)=0;

$ontext
         a(r,'l1',s) = 1200 +uniform(0,100);
         a(r,'l2',s) = 600 +uniform(0,50);
         a(r,'l3',s) = 300 +uniform(0,10);

         b(r,'l1',s) = 0.005 +uniform(0,0.0005);
         b(r,'l2',s) = 0.01 +uniform(0,0.0005);
         b(r,'l3',s) = 0.01 +uniform(0,0.0005);


theta(r,e,'l1') = 5000 +uniform(0,200);
theta(r,e,'l2') = 3000 +uniform(0,100);
theta(r,e,'l3') = 2000 +uniform(0,50);

xi(r,e,'l1') = 0.00001 ;
xi(r,e,'l2') = 0.00002 ;
xi(r,e,'l3') = 0.00003 ;
$offtext


$ontext
parameter  LRMC(r,e,l,s) long run marginal cost in each load segment USD per MWH;

* long run maringal cost. rescale capacity payment to USD/MW
LRMC(r,e,l,s) = smax(h,mc(h,r,s)+(ic(h)+om(h))/sum(ll$(EL_Demand(r,e,ll,s)<=EL_Demand(r,e,l,s)),d(e,ll,s)));

$offtext
