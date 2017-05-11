Parameters
           v(firm)   CONJECTURAL VARIANTION for production by player /g1 0, g2 0, g3 0, g4 0, fringe -1/
           X(firm)   CONJECTURAL VARIANTION for capacity by player /g1 0, g2 0, g3 0, g4 0, fringe -1/

           capital_cost(tech) Capital cost in USD per GW /CCGT 1102, GT 1016, ST 1680, Nuclear 6500, GTtoCC 600, PV 2584, WT 1569/
*           capital_cost(h) Capital cost in USD per GW /CCGT 1740, GT 1485, ST 2120, Nuclear 4896, GTtoCC 600/

           ic(tech)  investment cost USD per GW

           om(tech) Fixed O&M cost USD per GW  /GT 10.68, GTtoCC 19.94, CCGT 19.94, ST 38.67, Nuclear 130, PV 26.75, WT 39.625 /
*           om(h) Fixed O&M cost USD per GW  /GT 11.2, GTtoCC 12.4, CCGT 12.4, ST 11.2, Nuclear 68.8/
           K0(h,r) existent capacity of technology h in region r before liberalization

*Design operating life for ST, GT, and CCGT from KFUPM generation report.
           lifetime(tech) plant lifetime /CCGT 35, GT 30, ST 40, Nuclear 55, GTtoCC 20, PV 20, WT 20/
           discrate discount rate used for power plant investments /0.06/

           market_share_inv(firm) cap on a companies market share by investment
           market_share_prod(firm) cap on a companies market share by investment
;
         market_share_inv(i) = 1;
         market_share_prod(i) = 1;

           Table capadd(hh,h) a factor for adding capacity (only applicable to dispatchable tech)
                  GT      CCGT
         GTtoCC   -1      1.5
         ;

             capadd(h,h)$(not gttocc(h)) = 1 ;


;
sets     time /2015*2040/
         t dummy time set /2020/
         tt(t) /2020/
         index /1*1000/
parameter discoef         ;

*        Discounting plant capital costs over lifetime
         discoef(h,t) = discounting(lifetime(h),discrate,index,t,tt);

         ic(h)=capital_cost(h)*discoef(h,'2020');


Parameters ici(h)  investment cost
           icr(h)  retirement capacity cost;

ici(h) = ic(h)
;
icr(h) = ic(h)*0.15;
*icr(h) = 0;

parameter mc(tech,f,r) marginal cost in USD per MWh
         mc_non_fuel(tech,r) variable cost non fuel;

mc_non_fuel(ccgt,r)  = 1.2449 ;
mc_non_fuel(ccgt,'EOA')  = 1.1833 ;
mc_non_fuel('GT',r) =  1.6840;
mc_non_fuel('ST',r) =  1.2261;
mc_non_fuel('Nuclear',r) = 6.9;
mc_non_fuel('GTtoCC',r)  = mc_non_fuel('CCGT',r)  ;

* Uranium-235 use is in g/GWh
parameter heat_rate(tech,f) fueal burn rate in mmbtu and g per MWH  ;
heat_rate(ccgt,'methane')=7.655;
heat_rate(ccgt,'oil')=9.676;
*heat_rate('GTtoCC','methane')=7.655;
*heat_rate('GTtoCC','oil')=9.676;
heat_rate('GT','methane')=11.302;
heat_rate('GT','oil')=13.550;
heat_rate('ST','methane')=10.372;
heat_rate('ST','oil')=10.197;
heat_rate('Nuclear','U-235')=0.120;
;

set fuel_set(tech,f,r);
fuel_set(h,f,r)$(heat_rate(h,f)>0) = yes;
         fuel_set('PV','ren',r) = yes;
         fuel_set('WT','ren',r) = yes;

table fuel_quota(f,r)

                 COA     EOA     SOA     WOA
 methane         400     600     0.1      200
;

fuel_quota(f,r) = fuel_quota(f,r)*1.409;

Parameters  a(r,e,l,s,ss) intercept of energy demand curve,
            b(r,e,l,s,ss) slope of energy demand curve
            a1(r,e,l,s,ss),a2(r,e,l,s,ss),b1(r,e,l,s,ss),b2(r,e,l,s,ss),
            theta(r,e,l) intercept of capacity demand curve,
            xi(r,e,l) slope of capacity demand curve
;


parameter P_cap(o,r,e,l), Sales_bar(o,r,e,l,s,ss);

table kind0(firm,tech,r) firms existing generation capacity in GW

                 COA             EOA             SOA             WOA

g1.CCGT          5.419           0               0               0
g1.GT            13.0693         0               0               0
g1.ST            0               0               0               0

g2.CCGT          0               3.333           0               0
g2.GT            0               7.4663          0               0
g2.ST            0               10.192          0               0

g3.CCGT          0               0               0               0
g3.GT            0               0               4.11314         0
g3.ST            0               0               0               0

g4.CCGT          0               0               0               1.288
g4.GT            0               0               0               7.358
g4.ST            0               0               0               13.518

fringe.CCGT      0               2.56737         0               0
fringe.GT        1.116           2.144           0               0.60056
fringe.ST        0.706           3.4968          1.128           2.51877
fringe.PV        0.9             0               0               1
fringe.WT        0.2             0               0.2             0.8
;


K0(h,r) = sum(genco,kind0(genco,h,r));

table kind_trans0(r,rr) transmission capacity in GW

                WOA   SOA     COA     EOA
         WOA          1.5     1.2
         SOA    0
         COA    0                     0
         EOA                  5.22

      ;
kind_trans0(r,rr)$(kind_trans0(rr,r)>0) = kind_trans0(rr,r);
*WOA   0     1.16

*Data for 2014 inter-regional transmission capacities were obtained from ECRA correspondence.
         table phi(r,rr)  oper. and maint. cost of transmission in USD per MWH

                WOA   SOA     COA     EOA
         WOA   3.49   3.73    3.71    4.33
         SOA   3.73   3.49    4.10    4.50
         COA   3.71   4.1     3.49    3.78
         EOA   4.33   4.5     3.78    3.49

;

Parameter capfactor(tech) capacity factors for dispatchable plants
/ST      0.885
 GT      0.923
 CCGT    0.885
 Nuclear 0.860
/






parameter  ELretirement(firm,h,time,r), ELaddition(firm,h,time,r);

*updated capacity additions/retirements as of June 13 2016

*Known capacity additions:
*Capacity of units already under construction (sources: compiled news sources, see printouts):
*Rabigh 2 IPP (2017)
         ELaddition('fringe','CCGT','2017','WOA')=2.06;
*Jeddah South (2017)
         ELaddition('g4','ST','2017','WOA')=2.65;
*Shuqaiq (2017)
*Stscrb
         ELaddition('fringe','ST','2017','SOA')=2.64;
*Qurayyah IPPs (2017)
         ELaddition('fringe','CCGT','2017','EOA')=3.927;


*Source: KFUPM Generation Report (2010)
         ELretirement('g4','GT','2016','WOA')=0.207;
         ELretirement('g4','GT','2017','WOA')=0.217;
         ELretirement('g4','GT','2018','WOA')=0.214;
         ELretirement('g4','GT','2019','WOA')=0.271;
         ELretirement('g4','GT','2020','WOA')=0.240;
         ELretirement('g4','GT','2021','WOA')=0.229;
         ELretirement('g4','GT','2022','WOA')=0.321;
         ELretirement('g4','GT','2023','WOA')=0.244;
         ELretirement('g4','GT','2024','WOA')=0.236;
         ELretirement('g4','GT','2025','WOA')=0.246;
         ELretirement('g4','GT','2026','WOA')=0.212;
         ELretirement('g4','GT','2027','WOA')=0.208;
         ELretirement('g4','ST','2027','WOA')=0.260;
         ELretirement('g4','ST','2028','WOA')=0.260;
         ELretirement('g4','ST','2029','WOA')=0.260;
         ELretirement('g4','GT','2030','WOA')=0.240;
         ELretirement('g4','GT','2031','WOA')=0.240;
         ELretirement('g4','ST','2032','WOA')=0.260;

         ELretirement('g3','GT','2015','SOA')=0.015;
         ELretirement('g3','GT','2016','SOA')=0.089;
         ELretirement('g3','GT','2017','SOA')=0.085;
         ELretirement('g3','GT','2018','SOA')=0.091;
         ELretirement('g3','GT','2019','SOA')=0.089;
         ELretirement('g3','GT','2020','SOA')=0.094;
         ELretirement('g3','GT','2021','SOA')=0.106;
         ELretirement('g3','GT','2022','SOA')=0.094;
         ELretirement('g3','GT','2023','SOA')=0.100;
         ELretirement('g3','GT','2024','SOA')=0.109;
         ELretirement('g3','GT','2025','SOA')=0.070;
         ELretirement('g3','GT','2026','SOA')=0.106;
         ELretirement('g3','GT','2027','SOA')=0.132;
         ELretirement('g3','GT','2028','SOA')=0.112;
         ELretirement('g3','GT','2029','SOA')=0.132;
         ELretirement('g3','GT','2030','SOA')=0.132;
         ELretirement('g3','GT','2031','SOA')=0.121;
         ELretirement('g3','GT','2032','SOA')=0.120;

         ELretirement('g1','GT','2015','COA')=0.126;
         ELretirement('g1','GT','2016','COA')=0.210;
         ELretirement('g1','GT','2017','COA')=0.228;
         ELretirement('g1','GT','2018','COA')=0.240;
         ELretirement('g1','GT','2019','COA')=0.254;
         ELretirement('g1','GT','2020','COA')=0.266;
         ELretirement('g1','GT','2021','COA')=0.250;
         ELretirement('g1','GT','2022','COA')=0.264;
         ELretirement('g1','GT','2023','COA')=0.270;
         ELretirement('g1','GT','2024','COA')=0.251;
         ELretirement('g1','GT','2025','COA')=0.270;
         ELretirement('g1','GT','2026','COA')=0.269;
         ELretirement('g1','GT','2027','COA')=0.291;
         ELretirement('g1','GT','2028','COA')=0.285;
         ELretirement('g1','GT','2029','COA')=0.341;
         ELretirement('g1','GT','2030','COA')=0.355;
         ELretirement('g1','GT','2031','COA')=0.343;
         ELretirement('g1','GT','2032','COA')=0.361;

         ELretirement('g2','GT','2015','EOA')=0.100;
         ELretirement('g2','GT','2016','EOA')=0.287;
         ELretirement('g2','GT','2017','EOA')=0.232;
         ELretirement('g2','GT','2018','EOA')=0.232;
         ELretirement('g2','GT','2019','EOA')=0.232;
         ELretirement('g2','GT','2020','EOA')=0.255;
         ELretirement('g2','GT','2021','EOA')=0.236;
         ELretirement('g2','GT','2022','EOA')=0.239;
         ELretirement('g2','GT','2023','EOA')=0.240;
         ELretirement('g2','GT','2024','EOA')=0.098;
         ELretirement('g2','ST','2026','EOA')=0.430;
         ELretirement('g2','ST','2027','EOA')=0.430;
         ELretirement('g2','ST','2028','EOA')=0.430;
         ELretirement('g2','ST','2029','EOA')=0.430;
         ELretirement('g2','ST','2030','EOA')=0.625;
         ELretirement('g2','ST','2031','EOA')=0.625;
         ELretirement('g2','ST','2032','EOA')=0.625;

*        Fringe retires capacity by 2020

         ELretirement('fringe','ST','2020','EOA')=2.306;
         ELretirement('fringe','ST','2020','WOA')=1.203;

         kind0(firm,h,r) =kind0(firm,h,r)+ sum(time$(ord(time)<=6),ELaddition(firm,h,time,r))
                         - sum(time$(ord(time)<=6),ELretirement(firm,h,time,r));

parameter Genco_PPA(h,r);
Genco_PPA(h,r) = 0;

parameter kind_save
;

         kind_save(firm,h,r) = kind0(firm,h,r);



*        REPORT WRITER PARAMS

*$ontext

set consumer_sets /'surplus','fuel subsidy','fixed cost'/
    balancing_account_sets /'purchases energy','purchases capacity','consumer sales'/

    consumer_type /'Residential', 'Commercial', 'Government', 'Industrial', 'Other'/



Parameters
         roi(firm,tech)              return on investment
         cus(firm,tech)              capacity usage
         rop(firm,tech)              return on production
         roc(firm,tech)              return on capacity
         investments(firm,tech)      investments
         retirements(firm,tech)

         price_avg(r,e,l)                 expected price by region and season
         price_avg_flat(r)
         price_trans_avg(r,rr,e,l)        expected price by region and season
         price_avg_cost(r,e,l)

         production(firm,tech)      production by player in TWH
         transmission(r,rr,e,l)        transmission by ISO in TWH
         trade_avg(firm,r,rr,e,l)         expected interregional trade by each firm in TWH
         arbitrage_avg(r,rr,e,l)       expected interregional arbitrage by ISO in TWH

         error_demand(r,e,l)
         demand_actual(r,e,l,s,ss)
         demand_expected(r,e,l)
         reserve_capacity(r)
         consumer(consumer_sets,r)                consumer surplus fuel subsisdies and fixed cost
         social_surplus

         balancing_account(balancing_account_sets,r)

          cs_threshold(r,e,l,s,ss)

;


parameter consumer_share(consumer_type,r)
         /       Residential.COA 0.538
                 Commercial.COA  0.184
                 Government.COA  0.165
                 Industrial.COA  0.068

                 Residential.EOA 0.346
                 Commercial.EOA  0.109
                 Government.EOA  0.108
                 Industrial.EOA  0.398

                 Residential.WOA 0.534
                 Commercial.WOA  0.182
                 Government.WOA  0.121
                 Industrial.WOA  0.131

                 Residential.SOA 0.613
                 Commercial.SOA  0.156
                 Government.SOA  0.164
                 Industrial.SOA  0.029/

         consumer_tariff(consumer_type)
         /       Residential 0.0447
                 Commercial  0.0679
                 Other       0.04
                 Government  0.085
                 Industrial  0.048 /
         ;


         consumer_share('Other',r) =
          1-sum(consumer_type,consumer_share(consumer_type,r));




