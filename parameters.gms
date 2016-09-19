Parameters
           v(i)   CONJECTURAL VARIANTION for production by player /g1 0, g2 0, g3 0, g4 0, fringe 0/
           z(i)   CONJECTURAL VARIANTION for capacity by player /g1 0, g2 0, g3 0, g4 0, fringe 0/


           capital_cost(h) Capital cost in USD per MW /CCGT 1740000, GT 1485000, ST 2120000, Nuclear 4896000/
           ic(h)  investment cost USD per MW
           om(h) Fixed O&M cost USD per MW  /GT 11200, CCGT 12400, ST 11200, Nuclear 68800/
           K0(h,r) existent capacity of technology h in region r before liberalization
           kind0(i,h,r) initial capacity by technology and firm in each region in GW
           K(r,l) minimum installed capacity available to sell in region r and market segment l
           EL_demand(r,seasons,l,s) Electricity Demand (GW)
           prob(s) probability /s1 0.5/

*Design operating life for steam, GT, and CC from KFUPM generation report.
           lifetime(h) plant lifetime /CCGT 30, GT 25, ST 35, Nuclear 60/
           discrate discount rate used for power plant investments /0.06/



;

         prob(s) = 1/card(s);
         parameter discoef;
         set t dummy time set /2020/
         set index /1*1000/
             tt(t) /2020/
         ;

*        Discounting plant capital costs over lifetime
         discoef(h,t) = discounting(lifetime(h),discrate,index,t,tt);

         ic(h)=capital_cost(h)*discoef(h,'2020');


Parameters ici(h)  investment cost
           icr(h)  retirement capacity cost;

ici(h) = ic(h)
;
icr(h) = ic(h)*0.1;
*icr(h) = 0;




parameter    d(seasons,l) duration of segemt l in region r (deterministic);
d(e,l) = duration(e,l)



parameter mc(h,r,s) marginal cost in USD per MWh  ;

mc('CCGT',r,s)  = 1.2449 ;
mc('CCGT','EOA',s)  = 1.1833 ;
mc('GT',r,s) =  1.6840;
mc('ST',r,s) =  1.2261;
mc('Nuclear',r,s) = 6.9;
*mc('ULtrsc',r,s)  = 1.2449


* Uranium-235 use is in g/GWh
parameter heat_rate(h) fueal burn rate in mmbtu and KG per MWH
/
CCGT               6.09286
GT                 12.818
ST                 8.949
Nuclear            0.120
*Ultrsc              1.217
/
;


parameter fuel_price(h) price of fuels in USD per mmbtu and KG U235
/
CCGT               1.25
GT                 1.25
ST                 1.25
Nuclear            113
*Ultrsc             50
/
;

loop(s,
mc(h,r,s) = mc(h,r,s)+heat_rate(h)*fuel_price(h)*1;
*uniform(1,1)
);
;


parameter  beta(h,r,l) available capacity in market l
;
beta(h,r,l)=1;

Parameters  a(r,e,l,s) intercept of energy demand curve,
            b(r,e,l,s) slope of energy demand curve
            theta(r,e,l) intercept of capacity demand curve,
            xi(r,e,l) slope of capacity demand curve;

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

g1.CCGT          1360.6          0               0               0
g1.GT            13069.3         0               0               0
g1.ST            0               0               0               0

g2.CCGT          0               3929            0               0
g2.GT            0               5831.5          0               0
g2.ST            0               6756            0               0

g3.CCGT          0               0               0               0
g3.GT            0               0               4113.14         0
g3.ST            0               0               0               0

g4.CCGT          0               0               0               1288
g4.GT            0               0               0               8549.7
g4.ST            0               0               0               9888.4

fringe.CCGT      0               2567.37         0               0
fringe.GT        1116            3708.5          0               600.56
fringe.ST        706             6496.8          1020            7129.36
;

table kind_trans0(r,rr) transmission capacity in MW
               WOA   SOA   COA   EOA
         WOA   0     1.5   1.2   0.0
         SOA   1.5   0     0.0   0.0
         COA   1.2   0.0   0     5.22
         EOA   0.0   0.0   5.22  0
      ;
*WOA   0     1.16
kind_trans0(r,rr)=kind_trans0(r,rr)*1000;

*Data for 2014 inter-regional transmission capacities were obtained from ECRA correspondence.
         table phi(r,rr)  oper. and maint. cost of transmission in USD per MWH
                WOA   SOA     COA     EOA
         WOA   3.49   3.73    3.71    4.33
         SOA   3.73   3.49    4.10    4.50
         COA   3.71   4.1     3.49    3.78
         EOA   4.33   4.5     3.78    3.49
;

Parameter capfactor(h) capacity factors for dispatchable plants
/ST      0.885
 GT      0.923
 CCGT    0.885
 Nuclear 0.860
/



parameter  x(i,r,rr)   CONJECTURAL VARIANTION for electricity by player between region r and rr
;
x(i,r,rr)=v(i);
