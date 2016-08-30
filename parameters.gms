Parameters
           v(i)   CONJECTURAL VARIANTION for production by player /g1 0, g2 0, g3 0, g4 0, fringe 0/
           z(i)   CONJECTURAL VARIANTION for capacity by player /g1 0, g2 0, g3 0, g4 0, fringe 0/


           capital_cost(h) Capital cost in USD per MW /CCGT 1740000, GT 1485000, ST 2120000, Nuclear 4896000/
           ic(h)  investment cost USD per MW
           om(h) Fixed O&M cost USD per MW  /GT 11200, CCGT 12400, ST 11200, Nuclear 68800/
           K0(h,r) existent capacity of technology h in region r before liberalization
           kind0(i,h,r) initial capacity by technology and firm in each region in GW
           K(r,l) minimum installed capacity available to sell in region r and market segment l
           EL_demand(r,e,l,s) Electricity Demand (GW)
           prob(s) probability /s1 0.5, s2 0.5/

           lifetime(h) plant lifetime /CCGT 30, GT 25, ST 35, Nuclear 60/
           discrate discount rate used for power plant investments /0.06/



;
         parameter discoef;
         set t dummy time set /2020/
         set index /1*1000/
             tt(t) /2020/
         ;

*        Discounting plant capital costs over lifetime
         discoef(h,t) = discounting(lifetime(h),discrate,index,t,tt);

         ic(h)=capital_cost(h)*discoef(h,'2020');


Parameters ici(h)  investment cost
           ic0(h)  investment initial capacity cost
           icr(h)  retirement capacity cost;

ici(h) = ic(h)
;
icr(h) = ic(h)/2;
*icr(h) = 0;




parameter    d(e,l) duration of segemt l in region r (deterministic);
d(e,l) = duration(e,l)

$ontext
d(e,l,s)=0;
loop(s,
 loop(l,
  d(e,l,s) = duration(e,l)*uniform(1,1)+(duration(e,l-1)-d(e,l-1,s))$(ord(l)>1);
  d(e,l,s)$(ord(l)=card(l)) = d(e,l,s) + sum(ll,duration(e,ll)-d(e,ll,s))
 );
);
$offtext



parameter mc(h,r,s) marginal cost in USD per MWh  ;

mc('CCGT',r,s)  = 1.2449 ;
mc('CCGT','EOA',s)  = 1.1833 ;
mc('GT',r,s) =  1.6840;
mc('ST',r,s) =  1.2261;
mc('Nuclear',r,s) = 6.9;


parameter heat_rate(h) fueal burn rate in BBL and KG per MWH
/
CCGT               1.217
GT                 2.046
ST                 1.648
Nuclear            0.120
/
;


parameter fuel_price(h) price of fuels in USD per BBL and KG U235
/
CCGT               10
GT                 10
ST                 10
Nuclear            100
/
;

loop(s,
mc(h,r,s) = mc(h,r,s)+heat_rate(h)*fuel_price(h)*1;
*uniform(1,1)
);
;


parameter  beta(h,r,l) available capacity in market l
;

scalars reserve capacity reserve /0.1/;


Parameters  a(r,e,l,s) intercept of energy demand curve,
            b(r,e,l,s) slope of energy demand curvec
            theta(r,e,l) intercept of capacity demand curve,
            xi(r,e,l) slope of capacity demand curve;

parameter    EL_Demand(r,e,l,s)  Electricity Demand in MW (stochastic);


$ontext
Table K0(h,r)
      COA        EOA          SOA          WOA
CCGT  1360.6     6496.37      0            9144.97
GT    14185.3    9540.3       4113.14      9150.26
ST    706        13252.8      1020         16399.2
;

Table K0(h,r)
      COA   EOA   SOA   WOA
CCGT  0     0     0     0
GT    0     0     0     0
ST    0     0     0     0
;
$offtext


table kind0(i,h,r) firms existing generation capacity in MW

                 COA             EOA             SOA             WOA

g1.CCGT          1.3606          0               0               0
g1.GT            13.0693         0               0               0
g1.ST            0               0               0               0

g2.CCGT          0               3.929            0               0
g2.GT            0               5.8315          0               0
g2.ST            0               6.756            0               0

g3.CCGT          0               0               0               0
g3.GT            0               0               4.11314         0
g3.ST            0               0               0               0

g4.CCGT          0               0               0               1.288
g4.GT            0               0               0               8.5497
g4.ST            0               0               0               9.8884

fringe.CCGT      0               2.56737         0               0
fringe.GT        1.116           3.7085          0               0.60056
fringe.ST        0.706           6.4968         1.020            7.12936
;
kind0(i,h,r)=kind0(i,h,r)*1e3;

table kind_trans0(r,rr) transmission capacity in MW
               WOA   SOA   COA   EOA
         WOA   0     1.5   1.2   0.0
         SOA   1.5   0     0.0   0.0
         COA   1.2   0.0   0     5.22
         EOA   0.0   0.0   5.22  0
      ;
*WOA   0     1.16
kind_trans0(r,rr)=kind_trans0(r,rr)*1000;

         table phi(r,rr)  oper. and maint. cost of transmission in USD per MWH
                WOA   SOA     COA     EOA
         WOA   3.49   3.73    3.71    4.33
         SOA   3.73   3.49    4.10    4.50
         COA   3.71   4.1     3.49    3.78
         EOA   4.33   4.5     3.78    3.49
;



table  x(i,r,rr)   CONJECTURAL VARIANTION for electricity by player between region r and rr

                     WOA   SOA   COA   EOA
         g1*g4.WOA   0     0     0     0
         g1*g4.SOA   0     0     0     0
         g1*g4.COA   0     0     0     0
         g1*g4.EOA   0     0     0     0
;