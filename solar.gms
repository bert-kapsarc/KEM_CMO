*Solar DNI curves.
*Saudi Arabia obtained from NREL/KACST. The cities used for each region
*are: West-Jeddah, South-Abha,Central-Solar Village,East-AlQusaimah. The values
*represent average DNI levels for each segment over the seasonal period for each
*region. The data from the year 2002 are used.
*KWT = 'east' until data can be obtained
Table ELsolcurve(l,seasons,r) regional and seasonal solar DNI profiles in W per sq. m
                 WOA         SOA        COA         EOA
L1.summer        0.00        0.00       0.00        0.00
L2.summer        110.09      259.83     308.17      301.34
L3.summer        295.82      530.41     701.85      682.11
L4.summer        364.87      436.38     759.63      741.60
L5.summer        286.14      249.75     537.49      556.56
L6.summer        107.01      83.94      171.54      195.74
L7.summer        0.00        0.00       0.00        0.00
L8.summer        0.00        0.00       0.00        0.00

L1.winter        0.00        0.00       0.00        0.00
L2.winter        118.65      240.74     208.64      147.02
L3.winter        366.36      580.38     544.80      370.83
L4.winter        501.84      646.97     658.06      426.94
L5.winter        385.92      447.85     421.11      253.03
L6.winter        131.80      140.52     99.21       49.90
L7.winter        0.00        0.00       0.00        0.00
L8.winter        0.00        0.00       0.00        0.00

L1.spring-fall    0.00        0.00       0.00        0.00
L2.spring-fall    133.59      321.61     268.68      185.34
L3.spring-fall    366.00      717.74     631.74      453.89
L4.spring-fall    446.01      725.93     683.32      500.01
L5.spring-fall    326.06      464.02     401.39      292.48
L6.spring-fall    112.45      134.21     81.12       61.02
L7.spring-fall    0.00        0.00       0.00        0.00
L8.spring-fall    0.00        0.00       0.00        0.00
;
*We let the hourly operation of solar without storage to be proportional to the DNI.
*In actuality, the output from solar plants is equal to some efficiency times the
*irradiance (heat input). For thermal plants, it's the first law thermal efficiency.
*While CSP plants only utilize direct irradiation (DI), the DI is linearly
*proportional to the DNI. From this, we set the solar plant electricity output equal to its
*peak nominal output (i.e. the plant's output capacity) multiplied by the solar irradiance
*normalized by the maximum irradiance value throughout the year.
Parameter ELsolcurvenorm(l,seasons,r) normalized DNI profiles from ELsolcurve;
Elsolcurvenorm(l,e,r)=ELsolcurve(l,e,r)/smax((ll,ee),ELsolcurve(ll,ee,r));


parameter solar_cap(r) regional solar capcitity installation in GW
/
COA      3
EOA      2
SOA      5
WOA      1
/

;
scalar random, mean, stddev;
mean = 1;
stddev =0.3;
set sumi /1*100/;
scalar CDF_lo, CDF_hi, CDF_alpha,CDF_beta,Z_cdf,X_cdf;

parameter CDF_x(s) cumulative distribution functions for each scenario s;
CDF_alpha = cdfnorm(0,mean,stddev);
CDF_beta =  cdfnorm(1,mean,stddev);
Z_cdf=CDF_beta-CDF_alpha;
prob(s)=0;
CDF_x(s)=0;
loop(s,

         X_cdf=ord(s)/card(s);
         CDF_x(s)= (cdfnorm(X_cdf,mean,stddev)-CDF_alpha)/Z_cdf;
         prob(s) = CDF_x(s) - CDF_x(s-1);
         EL_Demand(r,e,l,s)= EL_Demand(r,e,l,s)-solar_cap(r)*Elsolcurvenorm(l,e,r)*X_cdf;
);

