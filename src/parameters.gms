Parameters
    v(firm)   CONJECTURAL VARIANTION for production by player /g1 0, g2 0, g3 0, g4 0, fringe -1/
    X(firm)   CONJECTURAL VARIANTION for capacity by player /g1 0, g2 0, g3 0, g4 0, fringe -1/

    capital_cost(tech) Capital cost in USD per KW /
     CCGT 1032, GT 882, ST 1026, Nuclear 5288, GTtoCC 240, PV 1153, WT 1400/;
Parameters
           ic(tech)  investment cost USD per KW
           om(tech) Fixed O&M cost USD per KW  /GT 11.2, GTtoCC 12.4, CCGT 12.4, ST 11.2, Nuclear 68.8, PV 9, WT 35 /
*           om(h) Fixed O&M cost USD per KW  /GT 11.2, GTtoCC 12.4, CCGT 12.4, ST 11.2, Nuclear 68.8/

*Design operating life for ST, GT, and CCGT from KFUPM generation report.
    lifetime(tech) plant lifetime /CCGT 35, GT 30, ST 40, Nuclear 55, GTtoCC 20, PV 25, WT 25/
    discrate discount rate used for power plant investments /0.06/

    market_share_inv(firm) cap on a companies market share by investment
    market_share_prod(firm) cap on a companies market share by investment
;
market_share_inv(i) = 1;
market_share_prod(i) = 1;

Table capadd(hh,h) a factor for adding capacity (only applicable to dispatchable tech)
            GT      CCGT
    GTtoCC  -1      1.5
 ;
capadd(h,h)$(not gttocc(h)) = 1
;
lifetime(CCGT)= 30;
lifetime(gttocc)= 20;
lifetime(GT)= 25;
lifetime(ST)= 35;

sets    time /2015*2040/
        t dummy time set /2020/
        tt(t) /2020/
        index /1*1000/
;

parameter discoef ;

*        Discounting plant capital costs over lifetime
discoef(h,t)$(lifetime(h)>0) = discounting(lifetime(h),discrate,index,t,tt);

ic(h)=capital_cost(h)*discoef(h,'2020');


Parameters ici(h)  investment cost
           icr(h)  retirement capacity cost;

ici(h) = ic(h)
;
icr(h) = ic(h)*0.15;
*icr(h) = 0;

parameter fuel_price_intl(f,r) price of fuels in USD per mmbtu and KG U235
        fuel_price_admin(f,r) price of fuels in USD per mmbtu and KG U235
        fuel_price(f,r) price of fuels in USD per mmbtu and KG U235
        mc(tech,f,r) marginal cost in USD per MWh
        mc_non_fuel(tech,r) variable cost non fuel
        mc_baseline(h,f,r) marginal cost of baseline scenario in usd per mwh
        mc_reform(h,f,r) marginal cost after price reform in usd per mwh
        mc_intl(h,f,r)
;

mc_non_fuel(ccgt,r)  = 3.76 ;
mc_non_fuel(GT,r) = 4.6;
mc_non_fuel(ST,r) =  1.87;
mc_non_fuel('Nuclear',r) = 2.56;

* Uranium-235 use is in g/GWh
parameter   heat_rate(tech,f,r) fuel burn rate in mmbtu and g per MWH
            fuel_efficiency(tech,f,r) net thermal efficiency by tech and region
            Cap_uptime(tech,r,seasons) max uptime for tech h in region r season e
;

fuel_efficiency(CCGT,'methane',r) = 0.5;
fuel_efficiency(CCGT,'oil',r) = 0.47;

fuel_efficiency('CCGT1','methane',r) = 0.53;
fuel_efficiency('CCGT2','methane',r) = 0.41;
fuel_efficiency('CCGT3','methane',r) = 0.39;

fuel_efficiency('CCGT1',oil_gas,'WOA') = 0.55;
fuel_efficiency('CCGT2','methane','WOA') = 0;
fuel_efficiency('CCGT2','oil','WOA') = 0.33;

fuel_efficiency(GT,'methane',r) = 0.30;
fuel_efficiency(GT,'oil',r) = 0.27;
fuel_efficiency('GT1','methane',r) = 0.33;
fuel_efficiency('GT2','methane',r) = 0.28;
fuel_efficiency('GT3','methane',r) = 0.25;

fuel_efficiency('GT2','oil','WOA') = 0.26;
fuel_efficiency('GT2','methane','WOA') = 0;
fuel_efficiency('GT3','oil','WOA') = 0.20;
fuel_efficiency('GT3','methane','WOA') = 0;

fuel_efficiency(ST,'methane',r) = 0.37;
fuel_efficiency(ST,'oil',r) = 0.35;
fuel_efficiency('ST1','oil',r) = 0.36;
fuel_efficiency('ST1','oil','SOA') = 0.37;

heat_rate(tech,f,r)$(fuel_efficiency(tech,f,r)>0) = 3.412/fuel_efficiency(tech,f,r);
$ontext
heat_rate(ccgt,'methane',r)=7.655;
heat_rate(ccgt,'oil',r)=9.676;
heat_rate('GT','methane',r)=11.302;
heat_rate('GT','oil',r)=13.550;
heat_rate('ST','methane',r)=10.372;
heat_rate('ST','oil',r)=10.197;
$offtext
heat_rate('Nuclear','U-235',r)=0.120;



table fuel_quota(f,r)
                 COA     EOA     SOA     WOA
 methane         450     1750    0.01    150
;

*fuel_quota(f,r) = fuel_quota(f,r)*1.409;

Parameters  a(r,e,l,s) intercept of energy demand curve,
            b(r,e,l,s) slope of energy demand curve
            a1(r,e,l,s),a2(r,e,l,s),b1(r,e,l,s),b2(r,e,l,s),
            theta(h,r,e,l) intercept of capacity demand curve,
            xi(h,r,e,l) slope of capacity demand curve
;
theta(h,r,e,l)=0;
xi(h,r,e,l)=0;

parameter P_cap(o,r,e,l), Sales_bar(o,r,e,l,s);

table kind0(firm,tech,r) firms existing generation capacity in GW

                COA             EOA            SOA              WOA
*g1.CCGT         2.389
g1.CCGT1        1.748
g1.CCGT2        1.328
*g1.CCGT3        4.630
g1.GT           9
*g1.GT1          0.492
*g1.GT2          0.31787
g1.GT3          0.5616
g1.ST           0.01

g2.CCGT                         2.739
*g2.GT                           7.4663
g2.GT                           4.090
g2.GT1                          0.501
g2.GT2                          0.6475
*g2.GT3                          0.3279
*g2.ST                           10.192
g2.ST                           5.220
g2.ST1                          4.272

*g3.GT                                          4.11314
g3.GT                                          1.49
*g3.GT2                                         1.61413
*g3.GT3                                         0.109
g3.ST1                                         2.640

*g4.CCGT                                                         1.288
g4.CCGT                                                         1.980
g4.CCGT1                                                        1.25
g4.CCGT3                                                        0.948
*g4.GT                                                           7.358
g4.GT                                                           4.2602
*g4.GT1                                                          3.6
g4.GT2                                                          1.9448
g4.GT3                                                          0.218
*g4.ST                                                           13.518
g4.ST                                                           9.5354
g4.ST1                                                          1.03

fringe.CCGT     0               2.56737         0               4.6
fringe.GT       1.416           4.844           0               1.30056
fringe.ST       2.4             6.2             2.428           4.51877
*fringe.PV       0.9             0               0               1
*fringe.WT       0.2             0               0.2             0.8
;

kind0(firm,'CCGT',r) = sum(ccgt, kind0(firm,ccgt,r));
kind0(firm,'GT',r) = sum(gt, kind0(firm,gt,r));
kind0(firm,'ST',r) = sum(st, kind0(firm,st,r));

*kind0(firm,CCGT,r)=0;

heat_rate(h,f,r)$(sum(genco,kind0(genco,h,r))=0 and not h_default(h)) = 0;

set fuel_set(tech,f,r);
fuel_set(h,f,r)$(heat_rate(h,f,r)>0) = yes;
         fuel_set('PV','ren',r) = yes;
         fuel_set('WT','ren',r) = yes;


parameter
         kind_trans0(n) transmission capacity in GW
         /
         COA_WOA         1.2
         SOA_WOA         1.5
         COA_EOA         5.22
         /

*Data for 2014 inter-regional transmission capacities were obtained from ECRA correspondence.
         phi(n)  oper. and maint. cost of transmission in USD per MWH
         /
         COA_WOA         3.71
         SOA_WOA         3.73
         COA_EOA         3.78
         /

         capfactor(tech) capacity factors for dispatchable plants
         /ST             0.885
          GT             0.923
          CCGT           0.885
          Nuclear        0.860
         /


;

* Define cap_uptime regional values by tech.
    Cap_uptime(h,r,e) =  1;
    Cap_uptime(CCGT,r,winter) =  0.97;
    Cap_uptime(CCGT,r,spring) =  0.99;

    Cap_uptime('CCGT','COA',winter) =  0.953;
    Cap_uptime('CCGT1','COA',winter) =  0.976;
    Cap_uptime('CCGT2','COA',winter) =  0.949;
    Cap_uptime('CCGT3','COA',winter) =  0.955;
    Cap_uptime('GT','COA',winter) =  0.969;
    Cap_uptime('GT1','COA',winter) =  0.960;
    Cap_uptime('GT2','COA',winter) =  0.943;
    Cap_uptime('GT3','COA',winter) =  0.999;
    Cap_uptime('ST','COA',winter) =  0.986;
    Cap_uptime('ST1','COA',winter) =  1;

    Cap_uptime('CCGT','COA',spring) =  0.988;
    Cap_uptime('CCGT1','COA',spring) =  0.985;
    Cap_uptime('CCGT2','COA',spring) =  0.980;
    Cap_uptime('CCGT3','COA',spring) =  0.987;
    Cap_uptime('GT','COA',spring) =  0.985;
    Cap_uptime('GT1','COA',spring) =  0.971;
    Cap_uptime('GT2','COA',spring) =  0.985;
    Cap_uptime('GT3','COA',spring) =  0.985;
    Cap_uptime('ST','COA',spring) =  0.986;
    Cap_uptime('ST1','COA',spring) =  1;

    Cap_uptime('CCGT1','EOA',winter) =  0.974;
    Cap_uptime('GT','EOA',winter) = 0.982;
    Cap_uptime('GT1','EOA',winter) =  0.981;
    Cap_uptime('GT2','EOA',winter) =  0.985;
    Cap_uptime('GT3','EOA',winter) =  0.972;
    Cap_uptime('ST','EOA',spring) =  0.983;
    Cap_uptime('ST1','EOA',spring) =  0.986;

    Cap_uptime('CCGT1','EOA',spring) =  0.98;
    Cap_uptime('GT','EOA',spring) = 0.989;
    Cap_uptime('GT1','EOA',spring) =  0.981;
    Cap_uptime('GT2','EOA',spring) =  0.983;
    Cap_uptime('GT3','EOA',spring) =  0.987;
    Cap_uptime('ST','EOA',spring) =  0.983;
    Cap_uptime('ST1','EOA',spring) =  0.996;

    Cap_uptime('CCGT','WOA',winter) =  0.952;
    Cap_uptime('CCGT1','WOA',winter) =  0.952;
    Cap_uptime('CCGT2','WOA',winter) =  0.952;
    Cap_uptime('CCGT3','WOA',winter) =  0.965;
    Cap_uptime('GT','WOA',winter) =  0.987;
    Cap_uptime('GT1','WOA',winter) =  0.973;
    Cap_uptime('GT2','WOA',winter) =  0.975;
    Cap_uptime('GT3','WOA',winter) =  0.988;
    Cap_uptime('ST','WOA',winter) =  0.989;
    Cap_uptime('ST1','WOA',winter) =  1;

    Cap_uptime('CCGT','WOA',spring) =  0.977;
    Cap_uptime('CCGT1','WOA',spring) =  0.952;
    Cap_uptime('CCGT2','WOA',spring) =  0.952;
    Cap_uptime('CCGT3','WOA',spring) =  0.977;
    Cap_uptime('GT','WOA',spring) =  0.990;
    Cap_uptime('GT1','WOA',spring) =  0.983;
    Cap_uptime('GT2','WOA',spring) =  0.990;
    Cap_uptime('GT3','WOA',spring) =  0.986;
    Cap_uptime('ST','WOA',spring) =  0.986;
    Cap_uptime('ST1','WOA',spring) =  0.989;


    Cap_uptime('CCGT','SOA',winter) =  0.952;
    Cap_uptime('GT','SOA',winter) =  0.933;
    Cap_uptime('GT2','SOA',winter) =  0.967;
    Cap_uptime('GT3','SOA',winter) =  0.967;
    Cap_uptime('ST','SOA',winter) =  0.986;
    Cap_uptime('ST1','SOA',winter) =  1;

    Cap_uptime('CCGT','SOA',spring) =  0.977;
    Cap_uptime('GT','SOA',spring) =  0.996;
    Cap_uptime('GT2','SOA',spring) =  0.985;
    Cap_uptime('GT3','SOA',spring) =  0.985;
    Cap_uptime('ST','SOA',spring) =  0.986;
    Cap_uptime('ST1','SOA',spring) =  1;


table     PTDF(n,r,dir)
                  COA.p    EOA.p     WOA.p     SOA.p
         COA_EOA   0       -1         0         0
         COA_WOA   1        1         0         0
         SOA_WOA  -1       -1         0        -1

;
PTDF(n,r,'m')=  -PTDF(n,r,'p')

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

*         kind0(firm,h,r) =kind0(firm,h,r)+ sum(time$(ord(time)<=6),ELaddition(firm,h,time,r))
*                         - sum(time$(ord(time)<=6),ELretirement(firm,h,time,r));

parameter Genco_PPA(h,r);
Genco_PPA(h,r) = 0;

*        REPORT WRITER PARAMS

*$ontext


set indicators /'profit', 'surplus','fuel subsidy','fixed cost','total surplus'/
    balancing_account_sets /'purchases energy','purchases capacity','consumer sales'/
    consumer_type /'Residential', 'Commercial', 'Government', 'Industrial', 'Other'/
;

Parameters
    roi(firm,tech)              return on investment
    cus(firm,tech)              capacity usage
    rop(firm,tech)              return on production
    roc(firm,tech)              return on capacity
    investments(firm,tech)      investments
    retirements(firm,tech)

    price_avg                 expected price by region and season
    price_avg_flat
    price_trans_avg       expected price by region and season
    price_avg_cost

    production               production by player in TWH
    transmission             transmission by ISO in TWH
    trade_avg(firm,r,rr,e,l) expected interregional trade by each firm in TWH
    arbitrage_avg(r,rr,e,l) expected interregional arbitrage by ISO in TWH

    demand_err
    demand_actual
    demand_total
    demand_projected
    demand_projected_total
    reserve_capacity(r)
    report(indicators,r)                consumer surplus fuel subsisdies and fixed cost
    social_surplus

    balancing_account(balancing_account_sets,r)
    cs_threshold(r,e,l,s,ss)
;

parameter fixed_cost(h);
fixed_cost(h)=sum(hh$(capadd(hh,h)>0),ici(hh)+capadd(hh,h)*om(hh))

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
consumer_share('Other',r) =1-sum(consumer_type,consumer_share(consumer_type,r));
