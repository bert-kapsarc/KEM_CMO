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
Table ELwindspeed(l,seasons,r) wind speeds in meters per second
            WOA          SOA          COA          EOA
L1.summer   0.785        2.818        4.883        2.641
L2.summer   1.812        3.188        3.255        2.879
L3.summer   4.424        3.782        3.740        4.728
L4.summer   5.329        5.631        3.512        5.502
L5.summer   6.046        6.767        3.353        6.579
L6.summer   3.940        3.837        3.726        5.155
L7.summer   3.411        2.903        5.019        4.292
L8.summer   2.283        2.029        5.833        2.883

L1.winter   1.278        2.680        4.418        2.262
L2.winter   2.061        2.798        3.115        3.454
L3.winter   4.286        3.794        3.991        5.155
L4.winter   4.473        4.280        3.460        6.597
L5.winter   7.411        5.838        3.257        6.662
L6.winter   4.451        3.543        3.996        4.786
L7.winter   4.123        2.601        4.203        3.296
L8.winter   2.436        1.904        4.458        2.724
L1.spfa     0.953        1.052        4.329        1.489
L2.spfa     1.434        2.369        3.244        3.248
L3.spfa     3.128        3.133        4.534        3.847
L4.spfa     6.315        4.612        3.212        5.670
L5.spfa     6.404        6.784        3.022        7.939
L6.spfa     4.006        5.579        3.220        6.743
L7.spfa     2.946        2.621        3.345        4.355
L8.spfa     2.496        0.903        4.826        2.472
;

parameter average_wind_spee_80m(r)
/
    WOA     7.2
    EOA     6.5
    COA     7
    SOA     7.2
/;

 ELwindspeed(l,seasons,r) = ELwindspeed(l,seasons,r)/(sum((ll,ee),ELwindspeed(ll,ee,r)*d(ee,ll))/sum((ll,ee),d(ee,ll)))*average_wind_spee_80m(r);

*If we opt to model wind power generation using different wind turbine technlogies
*or sizes, we may have to include air densities specific to the measurement locations.
Parameter ELairdensity(r) mass density of air in kg per cu. m at wind speed measurement conditions
/WOA 1.225
 SOA 1.225
 COA 1.225
 EOA 1.225/
;
Scalars
*Wind-related coefficients:
ELcutinspeed cut-in speed for wind turbine operation in m per sec /3/
ELcutoffspeed cut-off speed for wind turbine operation in m per sec /25/
ELratedspeed rated speed for wind turbine in m per sec /13/

*Source for cut-in speed: Adaramola et al. (2014), Al-Abbadi (2005), Ucar and Balo (2009), and Ahmed (2012)
*Source for cut-off speed: Adaramola et al. (2014), Al-Abbadi (2005), and Ucar and Balo (2009)
*Source for rated speed: Adaramola et al. (2014), Al-Abbadi (2005), and Ucar and Balo (2009)

*The power generated or transfered through a fluid is proportional to the velocity
*raised to the third power.
Parameter ELwindpower(l,seasons,r) rate of energy transfer in wind in W per sq. m of swept area;
ELwindpower(l,seasons,r)=0.5*ELairdensity(r)*(ELwindspeed(l,seasons,r))**3;
*Once the wind speed reaches the rated speed for the turbine, the production reaches a limit:
ELwindpower(l,seasons,r)$(ELwindspeed(l,seasons,r)>=ELratedspeed)=0.5*ELairdensity(r)*(ELratedspeed)**3;
ELwindpower(l,seasons,r)$(ELwindspeed(l,seasons,r)<ELcutinspeed)=0;
ELwindpower(l,seasons,r)$(ELwindspeed(l,seasons,r)>=ELcutoffspeed)=0;

*By taking the normalization approach, we remove the need to specify a sweep area
*or turbine conversion efficiency. Moreover, this approach simulates the wind turbine
*power output to be proportional to the power in the wind:
table ELwindpowernorm(l,seasons,r) power generated normalized by maximum annual value (regional)
            WOA         SOA         COA         EOA
L1.summer   0           0           0.4416      0
L2.summer   0.0154      0.0409      0.0615      0.0657
L3.summer   0.1599      0.0946      0.5074      0.1092
L4.summer   0.9600      0.3016      0.0589      0.3497
L5.summer   0.9600      0.9600      0.0450      0.9600
L6.summer   0.3359      0.5339      0.0596      0.5882
L7.summer   0.1336      0.0554      0.0702      0.1585
L8.summer   0           0.0812      0.6119      0
L1.winter   0           0.0688      0.1304      0.0353
L2.winter   0.0311      0.0996      0.0624      0.0458
L3.winter   0.4524      0.1663      0.2848      0.2028
L4.winter   0.7907      0.5490      0.0863      0.3195
L5.winter   0.9600      0.9528      0.0709      0.5463
L6.winter   0.3196      0.1737      0.1103      0.2628
L7.winter   0.2074      0.0752      0.6883      0.1517
L8.winter   0.0622      0.0257      0.9600      0.0460
L1.spfa     0           0.0592      0.4694      0
L2.spfa     0.0457      0.0674      0.1645      0.0791
L3.spfa     0.4114      0.1679      0.3461      0.2628
L4.spfa     0.4676      0.2411      0.0810      0.5508
L5.spfa     0.9600      0.6118      0.0626      0.5673
L6.spfa     0.4607      0.1367      0.1464      0.2103
L7.spfa     0.3662      0.0541      0.4042      0.0687
L8.spfa     0.0755      0.0212      0.4823      0.0388
;


ELwindpowernorm(l,seasons,r)
=0.96*ELwindpower(l,seasons,r)/(0.5*ELairdensity(r)*(ELratedspeed)**3);

ELwindpowernorm(l,'summer-wknd',r)=ELwindpowernorm(l,'summer',r);
ELwindpowernorm(l,'winter-wknd',r)=ELwindpowernorm(l,'winter',r);
ELwindpowernorm(l,'spf-wknd',r)=ELwindpowernorm(l,'spfa',r);
