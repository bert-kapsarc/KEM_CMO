* ELECTRICITY MODEL FOR SAUDI ARABIA (A SUB-MODEL OF THE KAPSARC ENERGY MODEL, OR KEM)
$ontext
********************************************************************************
*This version of the electricity generation model considers hourly load curves
*and contains CSPw/storage, PV, wind, and nuclear activities. It also includes
*spinning reserves to mitigate the effects of PV/wind output unreliability.
********************************************************************************
$offtext
*HFO consumption constraint is not considered for steam plants with scrubbers (see constraints).
parameter ELfconsumpmax(ELf,time,r) fuel supply constraint;

         ELfconsumpmax('Arablight',time,r)=9e9;
         ELfconsumpmax('u-235',time,r)=9e9;
         ELfconsumpmax('Coal',time,r)=9e9;

         ELfconsumpmax('methane',time,'west')=30.00442156;
         ELfconsumpmax('methane',time,'cent')=375.13244;
         ELfconsumpmax('methane',time,'east')=495.0079;

         ELfconsumpmax('methane','t1',r)=ELfconsumpmax('methane','t1',r)*2951.755/2689.685;

         ELfconsumpmax("HFO",time,'west')=3.043062;

         ELfconsumpmax("diesel",time,'east')=1.517017;
         ELfconsumpmax("diesel",time,'west')=3.883935;
         ELfconsumpmax("diesel",time,'sout')=3.597893;
         ELfconsumpmax("diesel",time,'cent')=1.702147;
* 2011 diesel and HFO consumption were calibrated based on SEC operation in 2011 (SEC document).

parameter ELfconsumpmaxcr(ELf,time,r) supply constraint for allocated fuel ;

Parameters ELAPf(f,time,r) administered price of fuels in USD per of units;
*$ontext
         ELAPf('Arablight',time,r)=4.24;
         ELAPf('HFO',time,r)=14.05;
         ELAPf('Diesel',time,r)=26.66;
         ELAPf('Methane',time,r)=0.75;
         ELAPf('u-235',time,r)=113;
         ELAPf('Coal','t1',r)=92.55;
         ELAPf('Coal','t2',r)=84.22;
         ELAPf('Coal','t3',r)=78.39;
         ELAPf('Coal',time,r)$(ord(time)>3)=ELAPf('Coal','t3',r);
* Uranium cost in USD/kg
*$offtext
$ontext
         ELAPf('Arablight',time,r)=107.8;
*http://www.bloomberg.com/news/2011-12-27/saudi-arabian-light-Arablight-prices-to-fall-12-next-year-ncb-says.html
         ELAPf('HFO',time,r)=300;
         ELAPf('Diesel',time,r)=866.21;
*weighted average based on Saudi exports of diesel (CDSI Export Statistics)
         ELAPf('Methane',time,r)=4;
*http://www.bloomberg.com/news/2011-09-19/lng-price-boom-seen-as-japan-vies-with-china-while-exxon-s-shipments-grow.html
         ELAPf('u-235',time,r)=113;
$offtext
Scalars
PVdegrade annual degradation factor for installed PV capacity in % per year /0.01/
*Source for PV degradation factor in hot climates/desert: NREL (2012, p. 14)

*Coefficients related to planning and operating reserves:
ELreserve scale factor for reserve margin GW /1.1/
ELsolspin fraction of solar gen. defining spin. reserve /0.2/
ELwindspin fraction of wind gen. defining spin. reserve /0.2/
ELusrfuelfrac ELfuelburn fraction for operating up spinning reserves /0.1/

*CSP-related coefficients:
ELCSPthermaleff thermal efficiency of CSP steam cycle /0.38/
ELCSPtransloss fraction loss in heat transfer from solar field to CSP cycle /0.35/
ELstorehrloss fraction of stored CSP heat dissipated per hour /0.00031/
ELstorecycloss fraction of heat lost by passing through storage cycle /0.015/
ELminDNI minimum DNI required for instantaneous CSP operation in W per sq. m /300/
ELaperturearea CSP collector area use in km^2 per GWe capacity /10.25/
CSPstoragehours hours equivalent to the amount of energy stored /8/
CSPreservecontr percent contribution of CSP capacity to reserve margin /0/

*Source for CSP Rankine thermal efficiency: US parabolic trough data on NREL
*Source for CSP transfer losses from solar field to steam cycle: Rovira et al. (2013, p. 269)
*Source for hourly heat dissipation from CSP storage: Sioshansi and Denholm (2010, p. 4)
*Source for cycle loss in CSP storage: Madaeni et al. (2012, p. 338)
*Source for minimum DNI requirement: Zhang et al. (2010, p. 7885-7887)
*Source for direct land use ratio: Kearney (2010, p. 18, NREL)
*Source for reserve contribution: Sioshansi and Denholm (2010, p. 16)

*Wind-related coefficients:
ELcutinspeed cut-in speed for wind turbine operation in m per sec /3/
ELcutoffspeed cut-off speed for wind turbine operation in m per sec /25/
ELratedspeed rated speed for wind turbine in m per sec /13/

*Source for cut-in speed: Adaramola et al. (2014), Al-Abbadi (2005), Ucar and Balo (2009), and Ahmed (2012)
*Source for cut-off speed: Adaramola et al. (2014), Al-Abbadi (2005), and Ucar and Balo (2009)
*Source for rated speed: Adaramola et al. (2014), Al-Abbadi (2005), and Ucar and Balo (2009)

Hoursinayear /8760/
;
*For discounting
Parameters ELdiscfact(time) discount factors for electricity sector;

Parameter ELleadtime(ELp) Lead time for plant construction units of time
         /
         Steam   2
         Stscrub 2
         CoalSteam 4
         GT      0
         CC      3
         GTtoCC  1
         PV      2
         CSP     3
         Wind    3
         Nuclear 7
         /
;

*Number of days in each season split up into work days and weekends/holidays.
Table ELdaysinseason(ELs,ELday) Days of each type in a season
      wday wendhol
summ  61   32
wint  64   26
spfa  123  59
;


*To rescale to TWh rather than GWh in the ELcaplim equations
ELdaysinseason(ELs,ELday)=1e-3*ELdaysinseason(ELs,ELday);
;
Parameter ELnormdays(ELs,ELday) ELdaysinseason normalized by total days in a year;
ELnormdays(ELs,ELday)=ELdaysinseason(ELs,ELday)/sum((ELss,ELdayy),ELdaysinseason(ELss,ELdayy));
;
*The ELsolcap and ELwindcap parameters are the regional non-dispatchable solar and
*wind capacity limits. We can vary them below. The limits are now set at 50 GW.
Scalar ELsolcap in GW /50/
       ELwindcap in GW /50/
;

Parameter ELlchours(ELl) time in hours in each load segment;
          ELlchours('L1')=4;
          ELlchours('L2')=4;
          ELlchours('L3')=4;
          ELlchours('L4')=2;
          ELlchours('L5')=3;
          ELlchours('L6')=2;
          ELlchours('L7')=2;
          ELlchours('L8')=3;

* Discretized 2013 hourly load curve (based on the load data obtained from ECRA):
* These values represent the average regional demands throughout the seasons for
* each load segment.
Table ELlcgw(ELl,ELs,ELday,rr) regional load in GW for each load segment in ELlchours
               wday.east     wday.cent     wday.west     wday.sout
L1.summ        13.227        13.502        11.969        3.638
L2.summ        12.963        13.181        11.600        3.408
L3.summ        13.424        13.918        12.115        3.536
L4.summ        14.112        15.092        13.102        3.855
L5.summ        14.231        15.300        13.042        3.730
L6.summ        14.156        14.911        12.510        3.672
L7.summ        14.020        14.540        12.354        3.850
L8.summ        13.670        14.076        12.268        3.819

L1.wint        8.194         6.007         6.684         2.544
L2.wint        8.047         5.794         6.058         2.239
L3.wint        8.319         6.424         6.370         2.318
L4.wint        8.558         6.759         7.066         2.554
L5.wint        8.879         7.152         7.182         2.575
L6.wint        9.177         7.731         7.393         2.752
L7.wint        9.113         7.802         7.549         2.957
L8.wint        8.723         7.102         7.271         2.849

L1.spfa        10.386        8.537         9.427         3.125
L2.spfa        10.102        8.152         8.769         2.823
L3.spfa        10.418        8.680         9.208         2.958
L4.spfa        10.900        9.423         10.174        3.280
L5.spfa        11.093        9.762         10.211        3.244
L6.spfa        11.197        9.937         10.097        3.313
L7.spfa        11.141        9.871         10.130        3.510
L8.spfa        10.839        9.338         9.936         3.421

+              wendhol.east  wendhol.cent  wendhol.west  wendhol.sout
L1.summ        12.987        12.928        11.533        3.559
L2.summ        12.847        12.741        11.253        3.353
L3.summ        13.269        13.214        11.564        3.392
L4.summ        13.841        14.214        12.380        3.656
L5.summ        13.829        14.447        12.378        3.551
L6.summ        13.704        14.102        11.919        3.522
L7.summ        13.622        13.777        11.836        3.706
L8.summ        13.315        13.309        11.759        3.678

L1.wint        8.038         5.841         6.677         2.536
L2.wint        7.817         5.443         5.989         2.215
L3.wint        8.069         5.955         6.099         2.225
L4.wint        8.361         6.321         6.666         2.452
L5.wint        8.612         6.582         6.794         2.475
L6.wint        8.872         7.172         7.068         2.638
L7.wint        8.817         7.327         7.322         2.854
L8.wint        8.486         6.769         7.168         2.784

L1.spfa        10.202        8.142         9.251         3.077
L2.spfa        9.945         7.716         8.724         2.766
L3.spfa        10.223        8.046         8.933         2.840
L4.spfa        10.635        8.645         9.660         3.130
L5.spfa        10.741        8.937         9.662         3.084
L6.spfa        10.819        9.193         9.585         3.174
L7.spfa        10.795        9.205         9.697         3.381
L8.spfa        10.561        8.776         9.576         3.312

;
*RO plants' power demand values are kept from 2011 since no new RO plants were built since.
parameter WAELpwrdemand2013(rr) RO power demand in GW;
WAELpwrdemand2013('west')=0.252;
WAELpwrdemand2013('sout')=0.068;
WAELpwrdemand2013('east')=0.028;

parameter PCELpwrdemand2013(rr) petrochemical power demand in GW;
PCELpwrdemand2013('west')=0.337;
PCELpwrdemand2013('east')=0.690;
;
Parameter CMELpwrdemand2013(rr) cement power demand in GW;
CMELpwrdemand2013('sout')=0.068;
CMELpwrdemand2013('west')=0.018;
CMELpwrdemand2013('cent')=0.019;
CMELpwrdemand2013('east')=0.129;

*Calculating the maximum regional load for the reserve margin constraint;
Parameter ELlcgwmax(rr) maximum regional load in GW
          Ellmax(rr), ELsmax(rr),ELdaymax(rr);
loop(rr,
ELlcgwmax(rr)=smax((ELl,ELs,ELday),ELlcgw(ELl,ELs,ELday,rr));

loop(ELl$(smax((ELs,ELday),ELlcgw(ELl,ELs,ELday,rr))=ELlcgwmax(rr)),
ELlmax(rr) = ord(ELl)
);
loop(ELs$(smax((ELl,ELday),ELlcgw(ELl,ELs,ELday,rr))=ELlcgwmax(rr)),
ELsmax(rr) = ord(ELs)
);
loop(ELday$(smax((ELl,ELs),ELlcgw(ELl,ELs,ELday,rr))=ELlcgwmax(rr)),
ELdaymax(rr) = ord(ELday)
);

);

* Updated load curve without estimated PC, CM, and RF power demand from the grid in 2013
ELlcgw(ELl,ELs,ELday,rr)= ELlcgw(ELl,ELs,ELday,rr)-PCELpwrdemand2013(rr)
  -CMELpwrdemand2013(rr)-WAELpwrdemand2013(rr);
Display ELlcgwmax;
*The above section determines the time during which the load is maximum. Below,
*since we use average values for the load curves, we manually define the absolute
*peak load in 2013:
ELlcgwmax('West')=14.646;
ELlcgwmax('Sout')=4.350;
ELlcgwmax('Cent')=17.406;
ELlcgwmax('East')=15.333;
ELlcgwmax(rr)=ELlcgwmax(rr)-WAELpwrdemand2013(rr)-PCELpwrdemand2013(rr)-CMELpwrdemand2013(rr);

* Regional demand growth values can be specified here (using old ECRA projections for now, need to update):
         table ELdemgro(time,r) Electricity demand growth rate relative to initial condition
                 west    sout   cent    east
         t1      1       1      1       1
         t2      1.06    1.16   1.06    1.06
         t3      1.11    1.24   1.11    1.11
         t4      1.15    1.33   1.16    1.17
         t5      1.20    1.43   1.20    1.25
         t6      1.25    1.52   1.25    1.33
         t7      1.25    1.61   1.30    1.41
         t8      1.30    1.71   1.35    1.50
         t9      1.35    1.80   1.40    1.59
         t10     1.42    1.90   1.46    1.71
         t11     1.48    2.00   1.51    1.83
         t12     1.55    2.10   1.57    1.97
         t13     1.61    2.22   1.63    2.12
         t14     1.68    2.35   1.69    2.28
         t15     1.74    2.46   1.76    2.40
         t16     1.80    2.57   1.83    2.53
         t17     1.88    2.68   1.90    2.68
         t18     1.96    2.75   1.97    2.82
         t19     2.04    2.82   2.05    2.98
         t20     2.10    2.87   2.11    3.08
         t21     2.16    2.93   2.17    3.19
         t22     2.21    2.98   2.23    3.30
;
*Above data is using t1=2011... To establish 2013 as the year base year:
ELdemgro(time,r)=ELdemgro(time+2,r)/ELdemgro('t3',r);
*display ELdemgro; abort'';
;
*The solar DNI curves were obtained from NREL/KACST. The cities used for each region
*are: West-Jeddah,   South-Abha,  Central-Solar Village,  East-AlQusaimah. The values
*represent average DNI levels for each segment over the seasonal period for each
*region. The data from the year 2002 are used.
Table ELsolcurve(ELl,ELs,r) regional and seasonal solar DNI profiles in W per sq. m
               west       sout        cent        east
L1.summ        0.00        0.00       0.00        0.00
L2.summ        110.09      259.83     308.17      301.34
L3.summ        295.82      530.41     701.85      682.11
L4.summ        364.87      436.38     759.63      741.60
L5.summ        286.14      249.75     537.49      556.56
L6.summ        107.01      83.94      171.54      195.74
L7.summ        0.00        0.00       0.00        0.00
L8.summ        0.00        0.00       0.00        0.00

L1.wint        0.00        0.00       0.00        0.00
L2.wint        118.65      240.74     208.64      147.02
L3.wint        366.36      580.38     544.80      370.83
L4.wint        501.84      646.97     658.06      426.94
L5.wint        385.92      447.85     421.11      253.03
L6.wint        131.80      140.52     99.21       49.90
L7.wint        0.00        0.00       0.00        0.00
L8.wint        0.00        0.00       0.00        0.00

L1.spfa        0.00        0.00       0.00        0.00
L2.spfa        133.59      321.61     268.68      185.34
L3.spfa        366.00      717.74     631.74      453.89
L4.spfa        446.01      725.93     683.32      500.01
L5.spfa        326.06      464.02     401.39      292.48
L6.spfa        112.45      134.21     81.12       61.02
L7.spfa        0.00        0.00       0.00        0.00
L8.spfa        0.00        0.00       0.00        0.00
;
*We let the hourly operation of solar without storage to be proportional to the DNI.
*In actuality, the output from solar plants is equal to some efficiency times the
*irradiance (heat input). For thermal plants, it's the first law thermal efficiency.
*While CSP plants only utilize direct irradiation (DI), the DI is linearly
*proportional to the DNI. From this, we set the solar plant electricity output equal to its
*peak nominal output (i.e. the plant's output capacity) multiplied by the solar irradiance
*normalized by the maximum irradiance value throughout the year.
Parameter ELsolcurvenorm(ELl,ELs,r) normalized DNI profiles from ELsolcurve;
Elsolcurvenorm(ELl,ELs,r)=ELsolcurve(ELl,ELs,r)/smax((ELll,ELss),ELsolcurve(ELll,ELss,r));

*The following table considers the impact of incrementally adding solar capacity
*in each region. These capacities are defined as the nominal peak output
*throughout the year since this is at the point of load. The solar contribution is
*multiplied by 0.96 to account for losses between generation and point of load.
Parameter ELdiffGWsol(ELl,ELs,rr) load difference due to introduction of solar capacity;
ELdiffGWsol(ELl,ELs,r)=ELsolcurvenorm(ELl,ELs,r)*ELsolcap*0.96;

********************************************************************************
*This section deals with calculating the direct irradiance (DI) from the DNI curves above.
*Using trigonometric relations from McQuiston et al (2005), the earth's position and
*the resulting angle of incidence on a surface are computed for each season, region,
*and load segment. The equations are written out in the file Macros.gms.
*Each hour is equivalent to 15 degrees of rotation, and we are assuming single-axis
*tracking along the north-south axis (for CSP).
scalar timezone Saudi Arabian time zone in degrees W relative to Prime Meridian /315/

*georgraphical coordinates for each region. Units are deg W for longitude and
*deg N for latitude. Coordinates obtained from NREL's website.
Table ELgeocoord(coord,r) latitude and longitude
       west    sout    cent    east
lat    21.68   18.23   24.91   28.32
long   320.85  341.77  313.59  313.87

Parameter dayofyear(ELs) day number during the year;
dayofyear('summ')=213;
dayofyear('wint')=37;
dayofyear('spfa')=121;
;
*Table assigns the number of hour to the solar curves:
Parameter hourofday(ELl) hour of day representing each load segment
/L1  2
 L2  6
 L3  10
 L4  13
 L5  15.5
 L6  18
 L7  20
 L8  22.5/
;

Parameter ELpositionofearth(ELs) position of earth in degrees;
Parameter ELequationoftime(ELs) Equation of time in minutes;
Parameter ELlocalsolartime(ELl,ELs,r) Local solar time in hours;
*Hour angle is angle between the projection of the vector of location-to-center of earth on
*the equitorial plane and the associated projection of the line from the center of the sun
*to the center of the earth.
*By convention, the hour angle is negative in the morning, zero at noon, and positive in the afternoon.
Parameter ELhourangle(ELl,ELs,r) the hour angle in degrees;
*sol dec: Angle between the line connecting the origins of the Earth and Sun and the line projection
*of that line on the earth's equitorial plane.
Parameter ELsurazimuth(ELl,ELs,r) the surface azimuth;
*orientation of the aperture plane from the north
Parameter ELtiltangle(ELl,ELs,r) tilt angle of surface;
*orientation of aperture plane in degrees(0 for horizontal 90 for vertical)
Parameter ELsoldeclination(ELs) solar declination angle in degrees;
*sol alt: Angle between the sun's rays and the projection of the rays on a horizontal surface.
Parameter ELsolaltitude(ELl,ELs,r) solar altitude in degrees;
*sol azim: Angle between horizontal projection of the sun's rays and the horizontal direction
*measured from the north (clockwise direction).
Parameter ELsolazimuth(ELl,ELs,r) solar azimuth in degrees;
*solsurfazim: Absolute value of the difference between the solar azimuth (phi) and the surface azimuth (psi).
Parameter ELsolarsurfaceazimuth(ELl,ELs,r) solar surface azimuth in degrees;
*ang of inc: angle between sun's rays and the normal of the surface
Parameter ELangleofincidence(ELl,ELs,r) the angle of incidence in degrees;


ELpositionofearth(ELs)=earthpos(dayofyear(ELs));

ELequationoftime(ELs)=EOT(ELpositionofearth(ELs));

ELlocalsolartime(ELl,ELs,r)=solhr(hourofday(ELl),Dayofyear(ELs),ELgeocoord('long',r),timezone);

ELhourangle(ELl,ELs,r)=hourangle(ELlocalsolartime(ELl,ELs,r));

*To accommodate single-axis tracking, the following is imposed:
*in the morning, hour angle is negative, surface facing east.
*at solar noon, hour angle is zero, value is arbitrary.
*in the afternoon, hour angle is positive, surface facing west.
ELsurazimuth(ELl,ELs,r)$(ELhourangle(ELl,ELs,r)<0)=90;
ELsurazimuth(ELl,ELs,r)$(ELhourangle(ELl,ELs,r)=0)=0;
ELsurazimuth(ELl,ELs,r)$(ELhourangle(ELl,ELs,r)>0)=270;

ELsoldeclination(ELs)=soldecl(ELpositionofearth(ELs));

ELsolaltitude(ELl,ELs,r)=solalt(ELhourangle(ELl,ELs,r),ELsoldeclination(ELs),ELgeocoord('lat',r));

*To have tilt of collectors change throughout the day to match solar zenith:
ELtiltangle(ELl,ELs,r)=90-ELsolaltitude(ELl,ELs,r)$(ELsolaltitude(ELl,ELs,r)>0);

ELsolazimuth(ELl,ELs,r)=solazim(ELhourangle(ELl,ELs,r),ELsoldeclination(ELs),ELgeocoord('lat',r),ELsolaltitude(ELl,ELs,r));
ELsolazimuth(ELl,ELs,r)$(Elhourangle(ELl,ELs,r)>0 or ELlocalsolartime(ELl,ELs,r)>12)=360-ELsolazimuth(ELl,ELs,r);

ELsolarsurfaceazimuth(ELl,ELs,r)=Gamma(ELsolazimuth(ELl,ELs,r),ELsurazimuth(ELl,ELs,r));

ELangleofincidence(ELl,ELs,r)=Incidence(ELsolaltitude(ELl,ELs,r),ELsolarsurfaceazimuth(ELl,ELs,r),ELtiltangle(ELl,ELs,r));

*The direct irradiance is now calculated as a function of DNI, and is used in the
*CSP-related computations.
Parameter ELdirectirradiance(ELl,ELs,r) the direct irradiance in GW per sq. km;
ELdirectirradiance(ELl,ELs,r)=ELsolcurve(ELl,ELs,r)*COS(ELangleofincidence(ELl,ELs,r)*pi/180)$(ELsolaltitude(ELl,ELs,r)>0);

*To rescale the DI to GW/km^2 and neglect very small values (i.e. less than ~2 W/m^2):
ELdirectirradiance(ELl,ELs,r)=1e-3*ELdirectirradiance(ELl,ELs,r);
*ELdirectirradiance(ELl,ELs,r)$(ELdirectirradiance(ELl,ELs,r)<2e-3)=0;
********************************************************************************
;
*nc=no clouds;pc=partly cloudy;oc=overcast;dust=dusty
*sum of regional fractions should be unity.
table ELccfrac(r,cc) fraction of hours for cloud cover scenarios
       nc   pc   oc   dust
west   1
sout   1
cent   1
east   1
;

table ELsolopfrac(ELppv,cc) fraction of solar operation based on cloud cover
       nc   pc   oc   dust
PV     1    .6   .1    0
;
*====Wind power generation parameters below====*
$ontext
We could not obtain hourly wind speed data for Saudi Arabia. To bypass this issue,
we used the monthly data presented by Rehman et al. (1994) to construct cumulative
Weibull distribution functions for Jeddah(west,19 years of data), Riyadh(cent,18 years
of data), Gizan(south,17 years of data), and Dhahran(east,19 years of data).
Using the inverse transform method and a random number generator for probabilities,
we here estimate profiles of the hourly wind speed using season- and region-specific
Weibull shape(which we call "k") and scale(which we call "c") parameters. The shape
of the daily profiles is then calibrated to the distributions' mean values and
diurnal speed variations graphically presented by Al-Abbadi (2005) and Rehman and
Ahmad (2004) for measurements taken over the period of years.

While the distribution of wind speeds closely follows a Weibull curve, this approach
does not take into account the auto-correlation present between hourly wind speeds.
It is therefore a purely probablistic and independent hourly estimation. Weibull
distributions have been commonly applied in the literature to evaluate the LCOE of wind turbine
generation (e.g., Rehman et al. (2003), Adaramola et al. (2014), and Ucar and Balo (2009)).
van Donk et al. (2005) have also applied the Weibull approach in generating hourly
wind speed values from monthly data, and although they do not recommend it in favor of
the direct use of the data distribution, the overall logic of random probability
generation is still applied. Also, they claim that average hourly wind speeds were
under- or over-predicted less than 5% of the time (p. 507).

Other methods, like an autoregressive estimation or a wavelet estimation, have been
proposed (e.g., Aksoy et al. (2004), Carapellucci and Giordano (2013)),
but the lack of hourly data makes them difficult to apply. Additionally, the method
Carapellucci and Giordano (2013) makes an assumption that wind always exhibits
low speeds in the morning hours, higher speeds in the afternoon, and lower again in
the evening (not true for all regions in Saudi Arabia). When they compared to measurements,
their results suggest that with monthly mean wind speeds, the error in hourly speed
is between 12 to 14%, and the error in the maximum hourly speed is between 5.1 to 20.4%.
$offtext
Table ELwindspeed(ELl,ELs,r) wind speeds in meters per second
               west         sout         cent         east
L1.summ        0.785        2.818        2.883        2.641
L2.summ        1.812        3.188        2.255        2.879
L3.summ        4.424        3.782        3.740        4.728
L4.summ        5.329        5.631        2.512        5.502
L5.summ        6.046        6.767        2.353        6.579
L6.summ        3.940        3.837        2.726        5.155
L7.summ        3.411        2.903        5.019        4.292
L8.summ        2.283        2.029        5.833        2.883

L1.wint        1.278        2.680        4.418        2.262
L2.wint        2.061        2.798        3.115        3.454
L3.wint        4.286        3.794        3.991        5.155
L4.wint        4.473        4.280        2.460        6.597
L5.wint        7.411        5.838        2.257        6.662
L6.wint        4.451        3.543        2.996        4.786
L7.wint        4.123        2.601        4.203        3.296
L8.wint        2.436        1.904        4.458        2.724

L1.spfa        0.953        1.052        4.329        1.489
L2.spfa        1.434        2.369        2.244        3.248
L3.spfa        3.128        3.133        4.534        3.847
L4.spfa        6.315        4.612        2.212        5.670
L5.spfa        6.404        6.784        2.022        7.939
L6.spfa        4.006        5.579        2.220        6.743
L7.spfa        2.946        2.621        2.345        4.355
L8.spfa        2.496        0.903        4.826        2.472
;

*If we opt to model wind power generation using different wind turbine technlogies
*or sizes, we may have to include air densities specific to the measurement locations.
Parameter ELairdensity(r) mass density of air in kg per cu. m at wind speed measurement conditions
/west 1.225
 sout 1.225
 cent 1.225
 east 1.225/
;
*The power generated or transfered through a fluid is proportional to the velocity
*raised to the third power.
Parameter ELwindpower(ELl,ELs,r) rate of energy transfer in wind in W per sq. m of swept area;
ELwindpower(ELl,ELs,r)=0.5*ELairdensity(r)*(ELwindspeed(ELl,ELs,r))**3;
*Once the wind speed reaches the rated speed for the turbine, the production reaches a limit:
ELwindpower(ELl,ELs,r)$(ELwindspeed(ELl,ELs,r)>=ELratedspeed)=0.5*ELairdensity(r)*(ELratedspeed)**3;
ELwindpower(ELl,ELs,r)$(ELwindspeed(ELl,ELs,r)<ELcutinspeed)=0;
ELwindpower(ELl,ELs,r)$(ELwindspeed(ELl,ELs,r)>=ELcutoffspeed)=0;

*By taking the normalization approach, we remove the need to specify a sweep area
*or turbine conversion efficiency. Moreover, this approach simulates the wind turbine
*power output to be proportional to the power in the wind:
Parameter ELwindpowernorm(ELl,ELs,r) power generated normalized by maximum annual value (regional);
ELwindpowernorm(ELl,ELs,r)=ELwindpower(ELl,ELs,r)/smax((ELll,ELss),ELwindpower(ELll,ELss,r));


*The following table considers the impact of incrementally adding wind capacity
*in each region. These capacities are defined as the nominal peak output
*throughout the year since this is at the point of load. The wind contribution is
*multiplied by 0.96 to account for losses between generation and point of load.
Parameter ELdiffGWwind(ELl,ELs,r) difference in load resulting from introducing wind turbine output in GW;
ELdiffGWwind(ELl,ELs,r)=ELwindpowernorm(ELl,ELs,r)*ELwindcap*0.96;
*Display ELwindpower,ELdiffGWwind;
*abort''
;


*Source for variable O&M cost: KFUPM generation report (2010) page 3-10.
*CSP costs: from IRENA (2013, p. 18), the total variable cost of a CSP plant is
*3000 USD/GWh. Estimating that around 10% of the variable cost is associated with
*storage (taking the same breakdown as capital cost), a value of 2700 is used.
*Nuclear variable cost from EIA.
*Wind variable cost from EIA.
*Supercritical coal plant cost from EIA.
*For steam with semi-dry scrubber, EPA (2013) estimates an added variable cost of 2790 USD/GWh.
         table ELomcst(ELp,v,r) non-fuel variable operating and main cost in USD per GWh
                             (west,sout,cent,east)
         Steam.(old, new)    1640
         Stscrub.(old,new)   4430
         CoalSteam.(old,new) 4470
         GT.(old, new)       4000
         CC.(old, new)       3300
         CCcon.(old,new)     3300
         PV.(old, new)
         CSP.(old, new)      2700
         Nuclear.(old, new)  2140
         Wind.(old,new)
;
*********Rescale ELomsct to MMUSD per TWH***************************************
         ELomcst(ELp,v,r)=1e-3*ELomcst(ELp,v,r);

* Right now taking 10% of total CSP variable cost from IRENA (2013, p. 18):
*This value is 300 USD/MWhe converted to USD/MWhthermal using the 35.4% efficiency.
         Table ELstoromcst(ELstorage,r)  Variable O&M cost for storing energy in MMUSD per TWh_thermal
                         west    cent    sout    east
         moltensalt      0.11    0.11    0.11    0.11

;
*Existing capacities in 2013:
         Table ELexist(ELp,v,r) existing capacity in GW
                             west      cent    sout    east
         Steam.old           7.722     0       1.02    8.089
*New steam capacties for Rabigh Steam (700 MW) and Rabigh IPP (660 MW) in 2013.
         Steam.new           1.360
         Stscrub.old
         GT.old              7.337     10.83   3.456   7.242
         GT.new              0.122     1.196           0.868
         CC.old              1.433     1.361    0      1.397
*New CC capacities for Shoaiba (760 MW), Qurayyah (1,040 MW), and PP11 (1729 MW) installed in 2013.
         CC.new              0.760     1.729           1.040
         PV.old              2e-3      3.5e-3  5e-4    1e-2
         CSP.old
         Nuclear.old
         Wind.old

* 2e-3      3.5e-3  5e-4    1e-2  {{current PV installed capacities}}
* In ELexist (above) subtracted out capacities included cogen desal plants,
* We have not subtracted cogen plants using RO for water. These are not included
* in cogen cpacity
;


*Source for CC, GT, and Steam: KFUPM Generation Report (2006 ver. on ECRA's
*website for existing plants p. 38). (2010 ver. on ECRA's website for proposed
*plants p. 3-10).
*Nuclear is estimated from Nuclear Energy Institute's website for US plants.
*CSP is assumed to be taken offline for maintenance 6 weeks/year.
Parameter ELcapfactor(ELp) capacity factors for dispatchable plants
/Steam   0.885
 Stscrub 0.885
 CoalSteam 0.885
 GT      0.923
 CC      0.885
 CCcon   0.885
 Nuclear 0.860
*We assume below that CSP maintenance can be done when storage heat is used up
 CSP     1
/

;
* We assume that 80% of total capital costs are for equipment and 20% for
* construction. The costs presented directly below are initial investment costs.
* Capital costs for fossil fuel plants from KFUPM Generation report.
*PV cost from Fraunhofer ISE (2012).
*CSP cost from IRENA (2013, p. 14):
*Nuclear cost from EIA.
*On-shore wind cost from IEA WEO 2014.
*For steam with semi-dry scrubber, EPA (2013) estimates an additional capital cost of 442 USD/kW.
Parameter ELcapital(ELp,time,r) Capital Cost of equipment million USD per GW
;
*CSP 2010 costs from IRENA (2012) are 7550 2010 USD/kW, percent reduction from IEA WEO 2014.
*We inflate CSP capital cost using the imports price deflators from Oxford Economics
*Model (i.e., multiplied by 109.7255/100) and we use the IEA WEO reductions to bring that
*7550 2010 USD/kW to 2013. The result is 7448 2013 USD/kW in 2013 (or 6787.5 2010 USD/kW in 2013).
*Based on percent reductions, below are 2013 costs in 2011 USD/kW, later inflated to 2013 USD.
*Conventional thermal plant costs from KFUPM report (taken in 2013 USD/kW).
*Supercritical coal-fired steam plant costs from EIA in 2012 USD/kW.
*We maintain variable costs constant from our 2011, but in 2013 USD/kWh.
*CSP redefined from 2010 USD/kW to 2013 USD/kW.
         ELcapital('Steam','t1',r)=2120;
         ELcapital('Stscrub','t1',r)=2572;
         ELcapital('GT','t1',r)=1485;
         ELcapital('CC','t1',r)=1740;
         ELcapital('GTtoCC','t1',r)=240;
         ELcapital('PV','t1',r)=2583.75;
         ELcapital('CSP','t1',r)=7448;
         ELcapital('Wind','t1',r)=1568.75;
         ELcapital('Nuclear','t1',r)=4500;
         ELcapital('CoalSteam','t1',r)=2934;

*Redefining capital costs to 2013 USD/kW by using the Saudi Imports price deflators
*for up to 2013 from Oxford Economics Model:
*Redefining capital costs of renewable plants:
*Wind, Supercritical coal, and PV redefined from 2012 USD/kW to 2013 USD/kW;
ELcapital('PV','t1',r)=ELcapital('PV','t1',r)*109.7255/108.1639;
ELcapital('Wind','t1',r)=ELcapital('Wind','t1',r)*109.7255/108.1639;
ELcapital('CoalSteam','t1',r)=ELcapital('CoalSteam','t1',r)*109.7255/108.1639;

* ANDY BARRETT no nukes no CSP
*ELcapital('Nuclear','t1',r)=ELcapital('Nuclear','t1',r)*1e6;
*ELcapital('CSP','t1',r)=ELcapital('CSP','t1',r)*1e6;




*Values sourced from KFUPM report for ECRA pg. 10-8/3-8 for current plants in Kingdom
*PV sourced from IEO WEO 2014
*CSP value from IRENA (2013, p. 18)
*Nuclear based on EIA and IEA WEO.
*Wind cost from IEA WEO 2014.
*For steam with semi-dry scrubber, EPA (2013) estimates an added fixed OM cost of 5.5 USD/kWyr.
Parameter ELfixedOMcst(ELp,time) Fixed O&M costs in million USD per GW;

         ELfixedOMcst('Steam','t1')=11.2;
         ELfixedOMcst('Stscrub','t1')=16.7;
         ELfixedOMcst('GT','t1')=11.2;
         ELfixedOMcst('CC','t1')=12.4;
         ELfixedOMcst('CCcon','t1')=12.4;
         ELfixedOMcst('PV','t1')=26.75;
         ELfixedOMcst('CSP','t1')=70;
         ELfixedOMcst('Wind','t1')=39.625;
         ELfixedOMcst('Nuclear','t1')=100;
         ELfixedOMcst('CoalSteam','t1')=37.8;

*Redefining fixed and variable OM costs to 2013 USD/kW by using the Saudi Imports
*price deflators for up to 2013 from Oxford Economics Model:
ELfixedOMcst('PV','t1')=ELfixedOMcst('PV','t1')*109.7255/108.1639;
ELfixedOMcst('Wind','t1')=ELfixedOMcst('Wind','t1')*109.7255/108.1639;
ELfixedOMcst('CoalSteam','t1')=ELfixedOMcst('CoalSteam','t1')*109.7255/108.1639;

Parameter ELpurcst(ELp,time,r) Cost of purchasing equipment million USD per GW
          ELconstcst(ELp,time,r) Local construction etc. costs million USD per GW;

*We estimate the conversion from GTtoCC adds 50% more capacity based on data on page 5-5 of KFUPM report.
         Table ELcapadd(ELpp,ELp) a factor for adding capacity (only applicable to dispatchable tech)
                  Steam  Stscrub GT  CC  GTtoCC   CCcon  Nuclear  CoalSteam
         Steam      1
         Stscrub         1
         GT                      1
         CC                          1
         GTtoCC                  -1               1.5
         Nuclear                                         1
         CoalSteam                                                1
;
* Amounts of fuels used per GWh produced (i.e. efficiencies).
* Old-vintage efficiencies from actual SEC operation data.
* New-vintage efficiencies from KFUPM (2010) heat rates for proposed units. (e.g. p.3-7)
* New-vintage and converted CC are estimated to have thermal efficiencies of 50% CCcon (gas)
* and 55% for new CC.
* Nuclear plants' thermal efficiency calculated based on information from European Nuclear Society.
* EPA (2013, p. 5-4) claims a 1.33% increase in heat rate due to scrubber operation,
* we apply that to all fuels used in steam plants.
         table ELfuelburn(ELp,v,ELf,r) fuel burn per GWh (BBL Metric Ton and MMBTU)
                               Arablight.(west,sout,cent,east)
         Steam.old              1730.1
         Steam.new              1647.6
         GT.old                 2478.1
         GT.new                 2046.4
         CC.old                 1714.9
         CC.new                 1217.16
         CCcon.old              1238.56

         +                     HFO.(west,sout,cent,east)
         Steam.(old,new)        223.6

         +                     diesel.west diesel.sout diesel.cent diesel.east
         Steam.(old, new)       217.42       217.42       217.42    217.42
         GT.(old, new)          321.48       296.42       371.45    314.86
         CC.old                 215.51       215.51       215.51    215.51
         CC.new                 152.96       152.96       152.96    152.96
         CCcon.old              155.65       155.65       155.65    155.65

         +                     methane.(west,sout,cent,east)
         Steam.(old,new)        8949
         GT.old                 12818
         GT.new                 10000
         CC.old                 8870.6
         CC.new                 6092.86
         CCcon.old              6200

         +                     u-235.(west,sout,cent,east)
         Nuclear.(old,new)      120

         +                     Coal.(west,sout,cent,east)
         CoalSteam.(old,new)   376.23

* CoalSteam is calculated for a supercritical steam plant with a heat rate of 8,800 BTU/kWh
* and a steam coal energy density of 23.39 MMBTU/ton.
* Uranium-235 use is in g/GWh
;
ELfuelburn('Stscrub',v,ELf,r)=ELfuelburn('Steam',v,ELf,r)*1.0133;
ELfuelburn('Stscrub',v,'Methane',r)=ELfuelburn('Steam',v,'methane',r);
*********Rescale fuel burn to MMBBL Million Tonnes and trillion BTU per TWh*****
         ELfuelburn(Elp,v,ELf,r)=1e-3*ELfuelburn(Elp,v,ELf,r);
;
         table Eltransyield(r,rr) net of transmission and distribution losses
               west  sout  cent  east
         west  0.96  0.925 0.905 0.86
         sout  0.925 0.96  0.87  0.81
         cent  0.905 0.87  0.96  0.93
         east  0.86  0.81  0.93  0.96

*Data for 2014 inter-regional transmission capacities were obtained from ECRA correspondence.
         table ELtransexist(r,rr) existing transmission capacity in GW
               west  sout  cent  east
         west  100   1.16  1.2   0.0
         sout  1.5   100   0.0   0.0
         cent  1.2   0.0   100   5.22
         east  0.0   0.0   5.22  100

*Capital and O&M costs are obtained from ECRA generation and transmission plan.
        table ELtransconstcst(r,time,rr)  construction cost of transmission capacity in USD per GW
                t1.west           t1.sout         t1.cent          t1.east
         west   2.53e6            2.71e6          2.69e6           3.15e6
         sout   2.71e6            2.53e6          3.1e6            3.9e6
         cent   2.69e6            3.1e6           2.53e6           2.75e6
         east   3.15e6            3.9e6           2.75e6           2.53e6
;
         table ELtranspurcst(r,time,rr)  purchase cost of transmission capacity in USD per GW
               t1.west           t1.sout         t1.cent          t1.east
         west  10.14e6           10.83e6          10.77e6         12.59e6
         sout  10.83e6           10.14e6          12.4e6          15.6e6
         cent  10.77e6           12.4e6           10.14e6         11e6
         east  12.59e6           15.6e6           11e6            10.14e6
;
*********Rescale transmission capital costs to MMUSD per GW*********************
         ELtransconstcst(r,time,rr) = 1e-6*ELtransconstcst(r,time,rr);
         ELtranspurcst(r,time,rr) = 1e-6*ELtranspurcst(r,time,rr);

         table ELtransomcst(r,rr)  oper. and maint. cost in USD per GWH
                west     sout       cent       east
         west   3.49e3   3.73e3     3.71e3     4.33e3
         sout   3.73e3   3.49e3     4.1e3      4.5e3
         cent   3.71e3   4.1e3      3.49e3     3.78e3
         east   4.33e3   4.5e3      3.78e3     3.49e3
;
*********Rescale transport operation costs to MMUSD per TWH*********************
         ELtransomcst(r,rr)=1e-3*ELtransomcst(r,rr);

         table ELtransleadtime(r,rr)  lead time for building transmission cap
               west  sout  cent  east
         west   0     0    0     0
         sout   0     0    0     0
         cent   0     0    0     0
         east   0     0    0     0
;
*Design operating life for steam, GT, and CC from KFUPM generation report.
*Wind turbine lifetime taken from Rehman et al. (2003, p.578), Adaramola et al. (2014, p.67).
*CSP lifetime from NREL's SAM and NREL's Heath (2011).
         parameter ELlifetime(ELp) Design lifetime of plant in units of time
         /Steam 35
          Stscrub 35
          CoalSteam 35
          GT 25
          CC 30
          GTtoCC 20
          CCcon 20
          PV 25
          CSP 30
          Nuclear 35
          Wind 20/
;
Parameter ELrenprodlow(ELp,time) lower bound on renewables generation in TWh;
ELrenprodlow(ELp,time)=0;

*Parameter ELbldlow(ELp,time) lower bound on renewables bld in TWh;
*ELbldlow(ELp,time)=0;

Parameter ELbldlow(time) lower bound on bld in GW;
ELbldlow(time)=0;

Parameter ELbldlowTot lower bound on bld in GW;
ELbldlowTot=0;

Parameter ELbldlowELp(ELp) lower bound on bld in GW;
ELbldlowELp(ELp)=0;

;
Parameters ELretirement(ELp,v,time,r) capacity to be retired in GW,
           ELaddition(ELp,v,time,r) already-planned capacity addition in GW ;

ELretirement(ELp,v,time,r)=0;
ELaddition(ELp,v,time,r)=0;

*South is only interconnected with West.
*NG availability for power based on 2011 sahres for east and cent consumption.

         ELexistcp.fx(ELpd,v,'t1',r)=ELexist(ELpd,v,r);
         ELbld.fx('CCcon','new',trun,r)=0;
         ELrenexistcp.fx(ELpsw,v,'t1',r)=ELexist(ELpsw,v,r);
         ELgttocc.fx('GTtoCC','old','t1',r)=0.4*ELexist('GT','old',r);
         ELtransexistcp.fx('t1',r,rr)=ELtransexist(r,rr);

Equations

*         ELobjective
*         Budget(time)

         ELcaptot(time,r)           to display total regional capacity over time
         ELoptot(time)              to check the sum of ELop and ELsolop
         ELpurchbal(time)           acumulates all import purchases
         ELcnstrctbal(time)         accumlates all construction activity
         ELopmaintbal(time)         accumulates operations and maintenance costs
         ELfcons(ELpd,ELf,time,r)   balance of fuel use for power generation
         ELfavail(ELf,time,r)       fuel supply constraint
         ELfavailcr(Elf,time,r)        fuel supply constraint credited
         ELgtconvlim(ELpd,v,time,r)  conversion limit for existing OCGT plants
         ELcapbal(ELpd,v,time,r)     capacity balance constraint
         ELrencapbalo(ELpsw,v,time,r) capacity balance for old renewable plants
         ELrencapbaln(ELpsw,v,time,r) capacity balance for new renewable plants
         ELcaplim(ELpd,v,ELl,ELs,ELday,time,r) electricity capacity constraints
         ELnucconstraint(ELl,ELs,Elday,time,r) to force nuclear to operate continuously
         ELsolcaplimo(ELppv,v,time,r) capacity constraint for non-dispatchable solar plants
         ELsolcaplimn(ELppv,v,time,r)
         ELwindcaplim(ELpw,v,time,r)
         ELsolutil(ELppv,v,ELl,ELs,ELday,time,r) measures the operate for solar plants
         ELwindutil(ELpw,v,ELl,ELs,ELday,time,r) measures the operate for wind plants
         ELsolcapsum(time,r)  carries out interpolation within capacity step(s)
         ELwindcapsum(time,r) carries out interpolation within capacity step(s)
         ELupspinres(ELpd,ELl,ELs,ELday,time,r) up spinning reserve (in case of sudden drop in renewable gen)
*         ELdnspinres(ELpd,ELl,ELs,ELday,time,r) down spinning reserve (in case of sudden rise in ren. gen.)
         ELsup(ELl,ELs,ELday,time,r)  electricity supply constraints
         ELdem(ELl,ELs,ELday,time,r)  electricity demand constraints
         ELrsrvreq(time,r)            electricity reserve margin
         ELsolenergybal(ELl,ELs,ELday,time,r) energy balance for solar collection field (CSP)
         ELstorenergybal(ELl,ELs,ELday,time,r) energy balance for CSP storage mechanism
         ELstorenergyballast(ELl,ELs,ELday,time,r) energy balance for CSP storage mechanism (last load segement in the day)
         ELCSPcaplim(ELpcsp,v,ELl,ELs,ELday,time,r) capacity constraint for CSP plants
         ELCSPutil(ELl,ELs,ELday,time,r)
         ELCSPlanduselim(time,r)      To restrict land use to empirical usage per unit capacity
         ELtranscapbal(time,r,rr)     electricity transportation capacity balance
         ELtranscaplim(ELl,ELs,ELday,time,r,rr) electricity transportation capacity constraint
         ELrenprodreq(ELpsw,v,time) renewable electricity generation requirement (not always imposed)
         ELnucprodreq(ELpnuc,v,time)
*         ELrenbldreq(ELpsw,v,time)
*         ELbldreq(ELpd,v,time)
         ELbldreq(time)
         ELstorlim(ELpsw,ELl,ELs,ELday,time,r)

         DELImports(time)             dual from imports
         DELConstruct(time)           dual from construct
         DELOpandmaint(time)          dual from opandmaint
         DELbld(ELpd,v,time,r)        dual from Elbld
         DELrenbld(ELpsw,v,time,r)     dual from ELrenbld
         DELgttocc(Elpd,v,time,r)     dual from ELgttocc
         DELop(ELpd,v,ELl,ELs,ELday,ELf,time,r)  dual from ELop
         DELsolop(ELpsw,v,ELl,ELs,ELday,time,r)  dual from ELsolop
         DELwindop(ELpsw,v,ELl,ELs,ELday,time,r)
         DELexistcp(ELpd,v,time,r)    dual from ELexistcp
         DELrenexistcp(ELpsw,v,time,r) dual from ELrenexistcp
         DELsoloplevel(ELppv,v,time,r) dual from ELsoloplevel
         DELwindoplevel(ELpw,v,time,r) dual from ELwindoplevel
         DELupspincap(ELpd,v,ELl,ELs,ELday,ELf,time,r)  dual from ELupspincap
*         DELdnspincap(ELpd,v,ELl,ELs,ELday,ELf,time,r)  dual from ELdnspincap
         DELCSPlandarea(time,r)
         DELheatstorin(ELl,ELs,ELday,time,r)
         DELheatstorout(ELl,ELs,ELday,time,r)
         DELheatstorage(ELl,ELs,ELday,time,r)
         DELheatinstant(ELl,ELs,ELday,time,r)
         DELtrans(ELl,ELs,ELday,time,r,rr)      dual from ELtrans
         DELtransbld(time,r,rr)       dual from ELtransbld
         DELtransexistcp(time,r,rr)   dual from ELtransexistcp
         DELfconsump(ELpd,f,time,r)
         DELfconsumpcr(f,time,r)
;
$offorder

$ontext
ELobjective.. z =e=sum(t,ELImports(t))+sum(t,ELConstruct(t))+sum(t,ELOpandmaint(t))
+sum((ELf,t,r),ELAPf(ELf,t,r)*ELfconsump(ELf,t,r))-sum((Elf,t,r),fcr(ELf,t)*ELfconsumpcr(ELf,t,r));
;
*Budget(t)..
*          -sum((ELf,r),(Fuelcst(ELf)-(Fuelencon(ELf)*fsubsidy(t)))*Fueluse(ELf,t,r))
-Imports(t)-Construct(t)-Opandmaint(t)=g=-TR;
$offtext
*PRIMAL RELATIONSHIPS
ELpurchbal(t)..
    sum((ELpd,v,r),ELpurcst(ELpd,t,r)*(1-(subsidy(t)+gamma_sub(ELpd,t))$ELpdsub(ELpd))*ELbld(ELpd,v,t,r)$( ((ELpcom(ELpd) and vn(v)) or (vo(v) and ELpgttocc(ELpd)))  ))
   +sum((ELpsw,v,r),ELPurcst(ELpsw,t,r)*(1-(subsidy(t)+gamma_sub(ELpsw,t))$ELprsub(ELpsw))*ELrenbld(ELpsw,v,t,r)$vn(v))
   +sum((r,rr), ELtranspurcst(r,t,rr)*ELtransbld(t,r,rr))
   -ELImports(t)=e=0;



ELcnstrctbal(t)..
    sum((ELpd,v,r),ELconstcst(ELpd,t,r)*(1-(subsidy(t)+gamma_sub(ELpd,t))$ELpdsub(ELpd))*ELbld(ELpd,v,t,r)$( ((ELpcom(ELpd) and vn(v)) or (vo(v) and ELpgttocc(ELpd)))  ))
   +sum((ELpsw,v,r),ELconstcst(ELpsw,t,r)*(1-(subsidy(t)+gamma_sub(ELpsw,t))$ELprsub(ELpsw))*ELrenbld(ELpsw,v,t,r)$vn(v))
   +sum((r,rr), ELtransconstcst(r,t,rr)*ELtransbld(t,r,rr))
   -ELConstruct(t)=e=0;



ELopmaintbal(t)..  sum((ELpd,v,ELl,ELs,ELday,ELf,r)$(Elfuelburn(ELpd,v,ELf,r)>0 and Elpcom(ELpd)),
   ELomcst(ELpd,v,r)*ELop(ELpd,v,ELl,ELs,ELday,ELf,t,r))
   +sum((ELps,v,ELl,ELs,ELday,r),ELomcst(ELps,v,r)*ELsolop(ELps,v,ELl,ELs,ELday,t,r))
   +sum((ELpw,v,ELl,ELs,Elday,r),ELomcst(ELpw,v,r)*ELwindop(ELpw,v,ELl,ELs,ELday,t,r))
   +sum((ELpd,v,r),ELfixedOMcst(ELpd,t)*(
         sum(ELpp$( ((ELpcom(ELpp) and vn(v)) or (vo(v) and ELpgttocc(ELpp))) ),
         ELcapadd(ELpp,ELpd)*ELbld(ELpp,v,t,r))+ELexistcp(ELpd,v,t,r)))
   +sum((ELpsw,v,r),ELfixedOMcst(ELpsw,t)*(ELrenbld(ELpsw,v,t,r)$vn(v)+ELrenexistcp(ELpsw,v,t,r)))
   +sum((ELstorage,ELl,ELs,ELday,r),ELstoromcst(ELstorage,r)*ELheatstorage(ELl,ELs,ELday,t,r))
   +sum((ELl,ELs,ELday,r,rr),ELtransomcst(r,rr)*ELtrans(ELl,ELs,ELday,t,r,rr))
   -ELOpandmaint(t)=e=0;



ELfcons(ELpd,ELf,t,r).. ELfconsump(ELpd,ELf,t,r)
   -sum((v,ELl,ELs,ELday)$(Elfuelburn(ELpd,v,ELf,r)>0 and ELpcom(ELpd)),
    ELfuelburn(ELpd,v,ELf,r)*ELop(ELpd,v,ELl,ELs,ELday,ELf,t,r))
   -sum((v,ELl,ELs,ELday)$(ELfspin(ELf) and Elfuelburn(ELpd,v,ELf,r)>0 and ELpspin(ELpd)),
    ELusrfuelfrac*ELfuelburn(ELpd,v,ELf,r)*ELlchours(ELl)*ELdaysinseason(ELs,ELday)*ELupspincap(ELpd,v,ELl,ELs,ELday,ELf,t,r))=g=0;



ELfavail(ELf,t,r)$(ElfAP(Elf) or ELfref(ELf))..  -sum(ELpd$(ELpnoscrub(ELpd) or ELfnoHFO(ELf)) ,ELfconsump(ELpd,ELf,t,r))=g=-ELfconsumpmax(ELf,t,r);

ELfavailcr(Elf,t,r).. -ELfconsumpcr(ELf,t,r) + sum(ELpd,ELfconsump(ELpd,ELf,t,r)) =g= 0;

ELcapbal(ELpd,v,t,r).. ELexistcp(ELpd,v,t,r)
   +ELaddition(ELpd,v,t+1,r)$(card(t)>1)
   -ELretirement(ELpd,v,t+1,r)$(card(t)>1)
   +sum(ELpp$( ((ELpcom(ELpp) and vn(v)) or (vo(v) and ELpgttocc(ELpp))) and t_ind(t) > ELleadtime(ELpp) ),
         ELcapadd(ELpp,ELpd)*ELbld(ELpp,v,t,r))
   -ELexistcp(ELpd,v,t+1,r)=g=0;


ELrencapbalo(ELpsw,'old',t,r).. ELrenexistcp(ELpsw,'old',t,r)*(1-PVdegrade$(ELppv(ELpsw)))
   -ELrenexistcp(ELpsw,'old',t+1,r)=g=0;


ELrencapbaln(ELpsw,'new',t,r).. ELrenexistcp(ELpsw,'new',t,r)*(1-PVdegrade$(ELppv(ELpsw)))
   +( ELrenbld(ELpsw,'new',t,r)*(1-PVdegrade$(ELppv(ELpsw))) )$( t_ind(t) > ELleadtime(ELpsw))
         -ELrenexistcp(ELpsw,'new',t+1,r)=g=0;


*To ensure that remaining convertible capacity can be positive in the last period
ELgtconvlim(ELpgttocc,vo,t,r).. -ELgttocc(ELpgttocc,vo,t+1,r)
         -ELbld(ELpgttocc,vo,t,r)
         +ELgttocc(ELpgttocc,vo,t,r)=g=0;


ELcaplim(ELpd,v,ELl,ELs,ELday,t,r)$(ELpcom(ELpd))..
         ELcapfactor(ELpd)*ELlchours(ELl)*ELdaysinseason(ELs,ELday)*(ELexistcp(ELpd,v,t,r)
   +sum(ELpp$(((ELpcom(ELpp) and vn(v)) or (vo(v) and ELpgttocc(ELpp))) and t_ind(t) > ELleadtime(ELpp)),
         ELcapadd(ELpp,ELpd)*ELbld(ELpp,v,t,r) )
   -sum(ELfspin$(ELpspin(ELpd) and ELfuelburn(ELpd,v,ELfspin,r)>0),ELupspincap(ELpd,v,ELl,ELs,ELday,ELfspin,t,r)))
   -sum(ELf$(Elfuelburn(ELpd,v,ELf,r)>0 and ELpcom(ELpd)),ELop(ELpd,v,ELl,ELs,ELday,ELf,t,r))=g=0;



****** Requirement to operate nuclear plants continuously:
ELnucconstraint(ELl,ELs,Elday,t,r) ..
    ELcapfactor('Nuclear')*ELlchours(ELl)*ELdaysinseason(ELs,ELday)*(sum((ELpnuc,v),ELexistcp(ELpnuc,v,t,r))
   +sum((ELpnuc,vn)$( t_ind(t) > ELleadtime('Nuclear')),ELbld(ELpnuc,vn,t,r)))
   -sum((ELpnuc,v,ELf)$(Elfuelburn(ELpnuc,v,ELf,r)>0),ELop(ELpnuc,v,ELl,ELs,Elday,ELf,t,r))=e=0;



ELsolcaplimo(ELppv,'old',t,r).. ELrenexistcp(ELppv,'old',t,r)
   -ELsolcap*ELsoloplevel(ELppv,'old',t,r)=g=0;



ELsolcaplimn(ELppv,'new',t,r).. ELrenexistcp(ELppv,'new',t,r)
   +ELrenbld(ELppv,'new',t,r)$( t_ind(t) > ELleadtime(ELppv))
   -ELsolcap*ELsoloplevel(ELppv,'new',t,r)=g=0;



ELsolcapsum(t,r).. -sum((ELppv,v),ELsoloplevel(ELppv,v,t,r))=g=-1;


ELsolutil(ELppv,v,ELl,ELs,ELday,t,r).. sum(cc,ELccfrac(r,cc)*ELsolopfrac(ELppv,cc)*
   ELlchours(ELl)*ELdaysinseason(ELs,ELday)*ELdiffGWsol(ELl,ELs,r)*ELsoloplevel(ELppv,v,t,r))
   -ELsolop(ELppv,v,ELl,ELs,ELday,t,r)=g=0;



ELwindcaplim(ELpw,v,t,r).. ELrenexistcp(ELpw,v,t,r)
  +ELrenbld(ELpw,v,t,r)$(vn(v) and t_ind(t) > ELleadtime(ELpw))
  -ELwindcap*ELwindoplevel(ELpw,v,t,r)=g=0;


ELwindcapsum(t,r).. -sum((ELpw,v),ELwindoplevel(ELpw,v,t,r))=g=-1;


ELwindutil(ELpw,v,ELl,ELs,ELday,t,r)..
    ELlchours(ELl)*ELdaysinseason(ELs,ELday)*ELdiffGWwind(ELl,ELs,r)*ELwindoplevel(ELpw,v,t,r)
   -ELwindop(ELpw,v,ELl,ELs,ELday,t,r)=g=0;



ELupspinres(ELpspin,ELl,ELs,ELday,t,r)..
   -ELsolspin*sum((ELppv,cc,v),ELccfrac(r,cc)*ELsolopfrac(ELppv,cc)*ELdiffGWsol(ELl,ELs,r)*ELsoloplevel(ELppv,v,t,r))
   -ELwindspin*sum((ELpw,v),ELdiffGWwind(ELl,ELs,r)*ELwindoplevel(ELpw,v,t,r))
   +sum((v,ELfspin)$(Elfuelburn(ELpspin,v,ELfspin,r)>0),ELupspincap(ELpspin,v,ELl,ELs,ELday,ELfspin,t,r))=g=0;



ELsolenergybal(ELl,ELs,Elday,t,r)..
    (1-ELCSPtransloss)*ELlchours(ELl)*ELdaysinseason(ELs,ELday)*ELdirectirradiance(ELl,ELs,r)*ELCSPlandarea(t,r)
   -ELheatstorin(ELl,ELs,Elday,t,r)
   -ELheatinstant(ELl,ELs,ELday,t,r)$(ELsolcurve(ELl,ELs,r)>=ELminDNI)=g=0;



ELstorenergybal(ELl,ELs,ELday,t,r)$(ord(ELl)<card(ELl))..
    ((1-ELstorehrloss)**ELlchours(ELl))*ELheatstorage(ELl,ELs,ELday,t,r)
   +(1-ELstorecycloss)*ELheatstorin(ELl,ELs,ELday,t,r)
   -ELheatstorout(ELl,ELs,ELday,t,r)
   -ELheatstorage(ELl+1,ELs,ELday,t,r)=e=0;



*to connect the hourly curves from preceeding days:
ELstorenergyballast(ELl,ELs,ELday,t,r)$(ord(ELl)=card(ELl))..
    ((1-ELstorehrloss)**ELlchours(ELl))*ELheatstorage(ELl,ELs,ELday,t,r)
   +(1-ELstorecycloss)*ELheatstorin(ELl,ELs,ELday,t,r)
   -ELheatstorout(ELl,ELs,ELday,t,r)
   -ELheatstorage('L1',ELs,ELday,t,r)=e=0;



ELCSPutil(ELl,ELs,ELday,t,r)..
    ELCSPthermaleff*(ELheatstorout(ELl,ELs,ELday,t,r)
     +ELheatinstant(ELl,ELs,ELday,t,r)$(ELsolcurve(ELl,ELs,r)>=ELminDNI))
   -sum((ELpcsp,v),ELsolop(ELpcsp,v,ELl,ELs,ELday,t,r))=g=0;



ELCSPlanduselim(t,r).. -ELCSPlandarea(t,r)
   +ELaperturearea*sum((ELpcsp,v),ELrenexistcp(ELpcsp,v,t,r)
   +ELrenbld(ELpcsp,v,t,r)$(vn(v) and t_ind(t) > ELleadtime(ELpcsp)) )=g=0;



ELCSPcaplim(ELpcsp,v,ELl,ELs,ELday,t,r)..
    ELcapfactor(ELpcsp)*ELlchours(ELl)*ELdaysinseason(ELs,Elday)*(
     ELrenexistcp(ELpcsp,v,t,r)
    +ELrenbld(ELpcsp,v,t,r)$(vn(v) and t_ind(t) > ELleadtime(ELpcsp)) )
    -ELsolop(ELpcsp,v,ELl,ELs,ELday,t,r)=g=0;


ELstorlim(ELpcsp,ELl,ELs,ELday,t,r).. -ELheatstorage(ELl,ELs,ELday,t,r)
  +sum(v,(ELrenexistcp(ELpcsp,v,t,r)+ELrenbld(ELpcsp,v,t,r)$(vn(v) and t_ind(t) > ELleadtime(ELpcsp))))*CSPstoragehours/ELCSPthermaleff*ELdaysinseason(ELs,ELday)=g=0;


ELrenprodreq(ELpsw,v,t)$vn(v) .. sum((ELl,ELs,ELday,r)$(ELps(ELpsw)),ELsolop(ELpsw,v,ELl,ELs,ELday,t,r))
  +sum((ELl,ELs,Elday,r)$(ELpw(ELpsw)),ELwindop(ELpsw,v,ELl,ELs,ELday,t,r))=g=ELrenprodlow(ELpsw,t);

ELnucprodreq(ELpnuc,v,t)$vn(v).. sum((ELl,ELs,Elday,ELf,r)$(Elfuelburn(ELpnuc,v,ELf,r)>0),ELop(ELpnuc,v,ELl,ELs,ELday,ELf,t,r))=g=ELrenprodlow(ELpnuc,t);

*ELrenbldreq(ELpsw,v,t)$vn(v) .. sum(r,ELrenbld(ELpsw,v,t,r))=g=ELbldlow(ELpsw,t);

*ELbldreq(ELpd,v,t)$(ELpcom(ELpd) and vn(v)) .. sum(r,ELbld(ELpd,v,t,r))=g=ELbldlow(ELpd,t);
ELbldreq(t).. sum((r,v)$vn(v), sum(ELpnuc,ELbld(ELpnuc,v,t,r))+sum(ELpsw,ELrenbld(ELpsw,v,t,r)) )=g=ELbldlow(t);
*$(ELbldlowELp(ELpnuc)>0)
*$(ELbldlowELp(ELpsw)>0)

ELsup(ELl,ELs,ELday,t,r).. sum((ELpd,v,ELf)$(Elfuelburn(ELpd,v,ELf,r)>0 and ELpcom(ELpd)),ELop(ELpd,v,ELl,ELs,ELday,ELf,t,r))
  +sum((ELps,v),ELsolop(ELps,v,ELl,ELs,ELday,t,r))
  +sum((ELpw,v),ELwindop(ELpw,v,ELl,ELs,ELday,t,r))
  +WAELsupply(ELl,ELs,ELday,t,r)
  -WAELconsump(ELl,ELs,ELday,t,r)
  -sum(rr,ELtrans(ELl,ELs,ELday,t,r,rr))=g=0;
* WAELconsump (hybrid RO) is assumed to take directly from supply, bypassing the grid



ELdem(ELl,ELs,ELday,t,rr)..  sum(r,Eltransyield(r,rr)*ELtrans(ELl,ELs,ELday,t,r,rr))
 -PCELconsump(ELl,ELs,ELday,t,rr)
 -RFELconsump(ELl,ELs,ELday,t,rr)
 -CMELconsump(ELl,ELs,ELday,t,rr)=g=ELlchours(ELl)*ELdaysinseason(ELs,ELday)*ELlcgw(ELl,ELs,ELday,rr)*ELdemgro(t,rr);



ELrsrvreq(t,rr).. sum((ELpd,v),ELexistcp(ELpd,v,t,rr))
   +sum((ELpd,v,ELpp)$(((ELpcom(ELpp) and vn(v)) or (vo(v) and ELpgttocc(ELpp))) and t_ind(t) > ELleadtime(ELpp)),
         ELcapadd(ELpp,ELpd)*ELbld(ELpp,v,t,rr))
   +CSPreservecontr*sum((ELpcsp,v)$(vn(v) and t_ind(t) > ELleadtime(ELpcsp)),ELrenbld(ELpcsp,v,t,rr))
   +CSPreservecontr*sum((ELpcsp,v),ELrenexistcp(ELpcsp,v,t,rr))
   +WAELrsrvcontr(t,rr)=g=ELreserve*(ELlcgwmax(rr)*ELdemgro(t,rr)
         +WAELpwrdemand(t,rr)
         +PCELpwrdemand(t,rr)
         +sum((ELl,ELs,Elday),CMELconsump(ELl,ELs,ELday,t,rr))/(hoursinayear/1000));
*WAELpwrdemand is an estimate of the annual peak power demand for RO plants


*Electricity Transmission:

ELtranscapbal(t,r,rr).. ELtransexistcp(t,r,rr)+ELtransbld(t-ELtransleadtime(r,rr),r,rr)
   -ELtransexistcp(t+1,r,rr)=g=0;



ELtranscaplim(ELl,ELs,ELday,t,r,rr).. ELlchours(ELl)*ELdaysinseason(ELs,ELday)*(ELtransexistcp(t,r,rr)
   +ELtransbld(t-ELtransleadtime(r,rr),r,rr))
   -ELtrans(ELl,ELs,ELday,t,r,rr)=g=0;



*DUAL RELATIONSHIPS
*$ontext
DELimports(t)..  1*ELdiscfact(t)=g=-DELpurchbal(t);
DELConstruct(t).. 1*ELdiscfact(t)=g=-DELcnstrctbal(t);
DELOpandmaint(t).. 1*ELdiscfact(t)=g=-DELopmaintbal(t);


DELfconsump(ELpd,ELf,t,r)..
         (        (Dfdem(ELf,t,r)*ELdiscfact(t)*(1-subsidy(t)$(partialdereg=1)))$ELfup(ELf)
                 +(DRFdem(ELf,t,r)*ELdiscfact(t)*(1-subsidy(t)$(partialdereg=1)))$ELfref(ELf)
         )$(ElfMP(ELf))
*ELdiscfact(t)
*        conditional for deregulate fuel scenario

         +(      ELAPf(ELf,t,r)*ELdiscfact(t))$(ELfAP(ELf))
*        conditional for administered fuel prices
                      =g=DELfcons(ELpd,ELf,t,r)-DELfavail(ELf,t,r)$((ElfAP(Elf) or ELfref(ELf)  ) and (ELpnoscrub(ELpd) or ELfnoHFO(ELf)))
                                 +DELfavailcr(Elf,t,r);

DELfconsumpcr(ELf,t,r)..
                 -fcr(ELf,t)*ELdiscfact(t) =g= -DELfavailcr(Elf,t,r);


DELbld(ELpd,v,t,r)$( ((ELpcom(ELpd) and vn(v)) or (vo(v) and ELpgttocc(ELpd))) )..
   0=g=DELpurchbal(t)*ELpurcst(Elpd,t,r)*(1-(subsidy(t)+gamma_sub(ELpd,t))$ELpdsub(ELpd))
  +DELcnstrctbal(t)*ELconstcst(ELpd,t,r)*(1-(subsidy(t)+gamma_sub(ELpd,t))$ELpdsub(ELpd))
  +sum(ELpp, ELcapadd(ELpd,ELpp)*DELopmaintbal(t)*ELfixedOMcst(ELpp,t))
*((ELpcom(ELpp) and vn(v)) or (vo(v) and ELpgttocc(ELpp))) and
*$((ELpcom(ELpp) and vn(v)) or (vo(v) and ELpgttocc(ELpp)))
  -DELgtconvlim(ELpd,v,t,r)$(ELpgttocc(ELpd) and vo(v))
  +sum(ELpp,DELcapbal(ELpp,v,t,r)*ELcapadd(ELpd,ELpp))$(t_ind(t) > ELleadtime(ELpd))
  +sum((ELpp,ELl,ELs,ELday)$(t_ind(t) > ELleadtime(ELpd)) ,
         ELcapfactor(ELpp)*ELlchours(ELl)*ELdaysinseason(ELs,ELday)*ELcapadd(ELpd,ELpp)*DELcaplim(ELpp,v,ELl,ELs,ELday,t,r))
  +sum(ELpp$(t_ind(t) > ELleadtime(ELpd)) ,DELrsrvreq(t,r)*ELcapadd(ELpd,ELpp))
  +sum((ELl,ELs,ELday)$(ELpnuc(ELpd) and vn(v) and t_ind(t) > ELleadtime(ELpd)),
         ELcapfactor(ELpd)*ELlchours(ELl)*ELdaysinseason(ELs,ELday)*DELnucconstraint(ELl,ELs,Elday,t,r))
*  +DELbldreq(Elpd,v,t)$(ELpcom(ELpd) and vn(v));
  +DELbldreq(t)$(ELpnuc(ELpd) and vn(v));
*and ELbldlowELp(ELpd)>0


DELgttocc(ELpgttocc,vo,t,r).. 0=g=DELgtconvlim(ELpgttocc,vo,t,r)
  -DELgtconvlim(ELpgttocc,vo,t-1,r);



DELtrans(ELl,ELs,ELday,t,r,rr)..0=g=DELopmaintbal(t)*ELtransomcst(r,rr)
  -DELsup(ELl,ELs,ELday,t,r)
  +DELdem(ELl,ELs,ELday,t,rr)*ELtransyield(r,rr)
  -DELtranscaplim(ELl,ELs,ELday,t,r,rr);



DELtransbld(t,r,rr).. 0=g=DELpurchbal(t)*ELtranspurcst(r,t,rr)
  +DELcnstrctbal(t)*ELtransconstcst(r,t,rr)
  +DELtranscapbal(t+ELtransleadtime(r,rr),r,rr)
  +sum((ELl,ELs,ELday),ELlchours(ELl)*ELdaysinseason(ELs,ELday)*DELtranscaplim(ELl,ELs,ELday,t+ELtransleadtime(r,rr),r,rr));



DELtransexistcp(t,r,rr)..
   0=n=DELtranscapbal(t,r,rr)-DELtranscapbal(t-1,r,rr)
  +sum((ELl,ELs,ELday),ELlchours(ELl)*ELdaysinseason(ELs,ELday)*DELtranscaplim(ELl,ELs,ELday,t,r,rr));



DELop(ELpd,v,ELl,ELs,ELday,ELf,t,r)$(Elfuelburn(ELpd,v,ELf,r)>0 and ELpcom(ELpd))..
   0=g=DELopmaintbal(t)*ELomcst(ELpd,v,r)
  -DELcaplim(ELpd,v,ELl,ELs,ELday,t,r)
  +DELsup(ELl,ELs,ELday,t,r)
  -DELfcons(ELpd,ELf,t,r)*ELfuelburn(ELpd,v,ELf,r)
  -DELnucconstraint(ELl,ELs,Elday,t,r)$(ELpnuc(ELpd))
  +DELnucprodreq(ELpd,v,t)$(vn(v) and ELpnuc(ELpd));
;



DELexistcp(ELpd,v,t,r).. 0=n=DELcapbal(ELpd,v,t,r)-DELcapbal(ELpd,v,t-1,r)
  +DELopmaintbal(t)*ELfixedOMcst(ELpd,t)
  +sum((ELl,ELs,ELday)$(ELpcom(ELpd)),ELcapfactor(ELpd)*ELlchours(ELl)*ELdaysinseason(ELs,ELday)*DELcaplim(ELpd,v,ELl,ELs,ELday,t,r))
  +sum((ELl,ELs,ELday)$(ELpnuc(ELpd)),ELcapfactor(ELpd)*ELlchours(ELl)*ELdaysinseason(ELs,ELday)*DELnucconstraint(ELl,ELs,Elday,t,r))
  +DELrsrvreq(t,r);



DELrenbld(ELpsw,v,t,r)$vn(v).. 0=g=DELpurchbal(t)*ELpurcst(Elpsw,t,r)*(1-(subsidy(t)+gamma_sub(ELpsw,t))$ELprsub(ELpsw))
  +DELcnstrctbal(t)*ELconstcst(ELpsw,t,r)*(1-(subsidy(t)+gamma_sub(ELpsw,t))$ELprsub(ELpsw))
  +DELopmaintbal(t)*ELfixedOMcst(ELpsw,t)
  +( DELrencapbal(ELpsw,v,t,r)*(1-PVdegrade$(ELppv(ELpsw))) )$(t_ind(t) > ELleadtime(ELpsw))
  +DELwindcaplim(ELpsw,v,t,r)$(ELpw(ELpsw) and t_ind(t) > ELleadtime(ELpsw))
  +DELsolcaplim(ELpsw,v,t,r)$(ELppv(ELpsw) and t_ind(t) > ELleadtime(ELpsw))
  +ELaperturearea*DELCSPlanduselim(t,r)$(ELpcsp(ELpsw) and t_ind(t) > ELleadtime(ELpsw))
  +sum((ELl,ELs,Elday)$(ELpcsp(ELpsw) and t_ind(t) > ELleadtime(ELpsw)),
         ELcapfactor(ELpsw)*ELlchours(ELl)*ELdaysinseason(ELs,Elday)*
         DELCSPcaplim(ELpsw,v,ELl,ELs,ELday,t,r))
*  +DELrenbldreq(ELpsw,v,t)
  +DELbldreq(t)$(vn(v))
  +(CSPstoragehours/ELCSPthermaleff*sum((ELl,ELs,ELday),ELdaysinseason(ELs,ELday)*DELstorlim(ELpsw,ELl,ELs,ELday,t,r)))$(ELpcsp(ELpsw) and t_ind(t) > ELleadtime(ELpsw))
  +CSPreservecontr*DELrsrvreq(t,r)$(ELpcsp(ELpsw) and t_ind(t) > ELleadtime(ELpsw))
;
*ELbldlowELp(ELpsw)>0 and


DELsolop(ELps,v,ELl,ELs,ELday,t,r)..0=g=DELopmaintbal(t)*ELomcst(ELps,v,r)
  +DELsup(ELl,ELs,ELday,t,r)
  -DELsolutil(ELps,v,ELl,ELs,ELday,t,r)$(ELppv(ELps))
  -DELCSPutil(ELl,ELs,ELday,t,r)$(ELpcsp(ELps))
  -DELCSPcaplim(ELps,v,ELl,ELs,ELday,t,r)$(ELpcsp(ELps))
  +DELrenprodreq(ELps,v,t)$vn(v);


DELrenexistcp(ELpsw,v,t,r).. 0=n=DELrencapbal(ELpsw,v,t,r)*(1-PVdegrade$(ELppv(ELpsw)))
  -DELrencapbal(ELpsw,v,t-1,r)
  +DELopmaintbal(t)*ELfixedOMcst(ELpsw,t)
  +DELwindcaplim(ELpsw,v,t,r)$(ELpw(ELpsw))
  +DELsolcaplim(ELpsw,v,t,r)$(ELppv(ELpsw))
  +ELaperturearea*DELCSPlanduselim(t,r)$(ELpcsp(ELpsw))
  +sum((ELl,ELs,ELday),DELstorlim(ELpsw,ELl,ELs,ELday,t,r)*CSPstoragehours/ELCSPthermaleff*ELdaysinseason(ELs,ELday))$(ELpcsp(ELpsw))
  +sum((ELl,ELs,ELday),ELcapfactor(ELpsw)*ELlchours(ELl)*ELdaysinseason(ELs,Elday)*DELCSPcaplim(ELpsw,v,ELl,ELs,ELday,t,r))$(ELpcsp(ELpsw))
  +CSPreservecontr*DELrsrvreq(t,r)$ELpcsp(ELpsw)
;

DELsoloplevel(ELppv,v,t,r).. 0=g=-DELsolcaplim(ELppv,v,t,r)*ELsolcap
  +sum((ELl,ELs,ELday,cc),ELccfrac(r,cc)*ELsolopfrac(ELppv,cc)*ELlchours(ELl)*ELdaysinseason(ELs,ELday)
         *ELdiffGWsol(ELl,ELs,r)*DELsolutil(ELppv,v,ELl,ELs,ELday,t,r))
  -DELsolcapsum(t,r)
  -ELsolspin*sum((ELpspin,ELl,ELs,ELday,cc),ELccfrac(r,cc)*ELsolopfrac(ELppv,cc)*ELdiffGWsol(ELl,ELs,r)*DELupspinres(ELpspin,ELl,ELs,ELday,t,r));



DELwindop(ELpw,v,ELl,ELs,ELday,t,r)..0=g=DELopmaintbal(t)*ELomcst(ELpw,v,r)
  +DELsup(ELl,ELs,ELday,t,r)
  +DELrenprodreq(ELpw,v,t)$vn(v)
  -DELwindutil(ELpw,v,ELl,ELs,ELday,t,r);



DELwindoplevel(ELpw,v,t,r).. 0=g=-DELwindcaplim(ELpw,v,t,r)*ELwindcap
  +sum((ELl,ELs,ELday),ELlchours(ELl)*ELdaysinseason(ELs,ELday)*ELdiffGWwind(ELl,ELs,r)*DELwindutil(ELpw,v,ELl,ELs,ELday,t,r))
  -DELwindcapsum(t,r)
  -ELwindspin*sum((ELpspin,ELl,ELs,ELday),ELdiffGWwind(ELl,ELs,r)*DELupspinres(ELpspin,ELl,ELs,ELday,t,r));



DELupspincap(ELpspin,v,ELl,ELs,ELday,ELfspin,t,r)$(Elfuelburn(ELpspin,v,ELfspin,r)>0)..
   0=g=DELupspinres(ELpspin,ELl,ELs,ELday,t,r)
  -ELlchours(ELl)*ELdaysinseason(ELs,ELday)*DELcaplim(ELpspin,v,ELl,ELs,ELday,t,r)
  -ELusrfuelfrac*ELlchours(ELl)*ELdaysinseason(ELs,ELday)*Elfuelburn(ELpspin,v,ELfspin,r)*DELfcons(ELpspin,ELfspin,t,r);




DELCSPlandarea(t,r)..
   0=g=sum((ELl,ELs,ELday),(1-ELCSPtransloss)*ELdirectirradiance(ELl,ELs,r)*DELsolenergybal(ELl,ELs,ELday,t,r)*ELlchours(ELl)*ELdaysinseason(ELs,ELday))
  -DELCSPlanduselim(t,r);


DELheatstorin(ELl,ELs,ELday,t,r).. 0=g=-DELsolenergybal(ELl,ELs,ELday,t,r)
  +(1-ELstorecycloss)*DELstorenergybal(ELl,ELs,ELday,t,r)$(ord(ELl)<card(ELl))
  +(1-ELstorecycloss)*DELstorenergyballast(ELl,ELs,ELday,t,r)$(ord(ELl)=card(ELl));



DELheatstorout(ELl,ELs,ELday,t,r).. 0=g=-DELstorenergybal(ELl,ELs,ELday,t,r)$(ord(ELl)<card(ELl))
  +ELCSPthermaleff*DELCSPutil(ELl,ELs,ELday,t,r)
  -DELstorenergyballast(ELl,ELs,ELday,t,r)$(ord(ELl)=card(ELl));



DELheatstorage(ELl,ELs,ELday,t,r).. 0=g=((1-ELstorehrloss)**ELlchours(ELl))*DELstorenergybal(ELl,ELs,ELday,t,r)$(ord(ELl)<card(ELl))
  -DELstorenergybal(ELl-1,ELs,ELday,t,r)
  +((1-ELstorehrloss)**ELlchours(ELl))*DELstorenergyballast(ELl,ELs,ELday,t,r)$(ord(ELl)=card(ELl))
  -DELstorenergyballast('L8',ELs,ELday,t,r)$(ord(ELl)=1)
  -sum(ELpcsp,DELstorlim(ELpcsp,ELl,ELs,ELday,t,r))
  +sum(ELstorage,DELopmaintbal(t)*ELstoromcst(ELstorage,r));



DELheatinstant(ELl,ELs,ELday,t,r)$(ELsolcurve(ELl,ELs,r)>=ELminDNI)..
   0=g=-DELsolenergybal(ELl,ELs,ELday,t,r)
  +ELCSPthermaleff*DELCSPutil(ELl,ELs,ELday,t,r);




