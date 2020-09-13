Table ELsolcurvenorm(l,seasons,r) normalized DNI profiles from ELsolcurve
                WOA         SOA         COA         EOA
L2.summer       0.04841     0.08728     0.09679     0.12283
L3.summer       0.49514     0.56292     0.54821     0.59095
L4.summer       0.60461     0.54671     0.59234     0.62183
L5.summer       0.34433     0.28393     0.32733     0.32962
L6.summer       0.02012     0.03151     0.03123     0.02458
L7.summer       2E-5        0.00044     6E-5        0.00018
L2.winter       0.07068     0.08324     0.0866      0.09404
L3.winter       0.53918     0.59524     0.60393     0.56221
L4.winter       0.62018     0.6755      0.66027     0.58282
L5.winter       0.36821     0.34473     0.29547     0.23054
L6.winter       0.03793     0.01478     0.0072      0.00194
L7.winter       8E-5        0.00299     0.00153
L2.spfa         0.07771     0.09091     0.10306     0.12411
L3.spfa         0.55373     0.57502     0.58795     0.60333
L4.spfa         0.64501     0.60435     0.61795     0.58141
L5.spfa         0.41315     0.32262     0.30257     0.25652
L6.spfa         0.06385     0.02345     0.01289     0.00806
L7.spfa         0.00047     0.0007                  0.00085
;
ELsolcurvenorm(l,'summer-wknd',r)=ELsolcurvenorm(l,'summer',r);
ELsolcurvenorm(l,'winter-wknd',r)=ELsolcurvenorm(l,'winter',r);
ELsolcurvenorm(l,'spf-wknd',r)=ELsolcurvenorm(l,'spfa',r);
parameter solar_cap(r) regional solar PV capacity installation in GW
/
COA      0.9
EOA      0
SOA      0
WOA      1
/

;
parameter wind_cap(r) regional wind capacity installation in GW
/
COA      0.2
EOA      0.0
SOA      0.2
WOA      0.8
/

;


$INCLUDE wind.gms

parameter prob2(scen) /s1 0.98, s2 0.02/
          solar_outage(scen) /s1 1, s2 0/;

loop(ss$(card(ss)>1),
    prob(r,seasons,l,s,ss) = prob(r,seasons,l,s,ss)*prob2(ss)
);
