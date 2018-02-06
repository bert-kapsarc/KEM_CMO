*$INCLUDE ACCESS_HLC.gms
$oninline

set hrs hours in the load curve data set /1*8760/ ;

parameter HLC(r,hrs) hourly load curves for represenative day in each month in MW
parameter ELlcgw(r,seasons,l) average power demand load blocks in MW
          ELlcgw_stddev(r,seasons,l) variance power demand load blocks in MW
          EL_Demand(r,seasons,l,s) Stochastic Electricity Demand for scenarios s in GW
          d(seasons,l) duration of segemt l in region r (deterministic)
          prob(r,seasons,l,s,ss) probability off each scenario
;
$gdxin db\load.gdx
$load HLC
$gdxin



parameter day(hrs)    day for each hour in a year
          dayofweek(hrs) day of week for each hour in the year 0 - weekday (sunday to thursday) 1 - weekend (friday to saturday)
          hour(hrs) represents each hour in the hourly demand data year from 0 to 23
;

          day(hrs) = floor((ord(hrs)-1)/24)+1;
*          day('8760') = 1;


          hour(hrs)=ord(hrs)-1-(day(hrs)-1)*24;

parameter duration(seasons,l) duration of segemt l in region r and season e
;

 duration(seasons,'l1')=4;
 duration(seasons,'l2')=4;
 duration(seasons,'l3')=4;
 duration(seasons,'l4')=2;
 duration(seasons,'l5')=3;
 duration(seasons,'l6')=2;
 duration(seasons,'l7')=2;
 duration(seasons,'l8')=3;

 parameter block_start(seasons,l) start hour for hour in load block l
           block_end(seasons,l);

 block_start(seasons,l) = sum(ll$(ord(ll)<ord(l)),duration(seasons,ll));
 block_end(seasons,l) = sum(ll$(ord(ll)<=ord(l)),duration(seasons,ll));

parameter start_day(seasons) first day to sample hourly data from for season e

end_day(seasons) last day to sample hourly data for season e
number_of_days(seasons)
season_day_of_week(seasons)
frac_wkdy_wknd(seasons);

start_day(seasons)$winter(seasons)= 304;
start_day(seasons)$spring(seasons)= 61;
start_day(seasons)$summer(seasons)= 122;


season_day_of_week(e_wkdy) = 0;
season_day_of_week(e_wknd) = 1;


scalar
         start_day_fall first day to sample hourly data from for fall season /243/
         end_day_fall first day to sample hourly data from
;
end_day(seasons)$winter(seasons) = start_day('spring-fall')-1;
end_day(seasons)$spring(seasons) = start_day('summer')-1;
end_day(seasons)$summer(seasons) = start_day_fall-1;
end_day_fall = start_day('winter')-1;

number_of_days(seasons)$(not winter(seasons)) = end_day(seasons)-start_day(seasons)+1;
number_of_days(seasons)$spring(seasons) = number_of_days('spring-fall')+end_day_fall-start_day_fall+1;
number_of_days(seasons)$winter(seasons) = smax(hrs,day(hrs))-sum(e_wkdy,number_of_days(e_wkdy));


scalar day_of_week /5/, hr;
parameter number_of_wkdy_wknd(seasons);
number_of_wkdy_wknd(seasons)=0;

loop(hrs,

         if(floor(day_of_week) >= 8,
             day_of_week = 1;
         );

  dayofweek(hrs)$(floor(day_of_week) <6) = 0;
  dayofweek(hrs)$(floor(day_of_week) >=6) = 1;
  hr = ord(hrs);
*         display hr,day_of_week;

  day_of_week = day_of_week+1/24;

  number_of_wkdy_wknd(seasons)$((
               (day(hrs)>=start_day(seasons) and
                day(hrs)<=end_day(seasons) and (spring(seasons) or summer(seasons)) ) or

               (day(hrs)>=start_day_fall and
                day(hrs)<=end_day_fall and fall(seasons)) or

               ((day(hrs)>=start_day(seasons) or day(hrs)<=end_day(seasons)) and
                       winter(seasons))
               ) and  dayofweek(hrs) = season_day_of_week(seasons)

  ) =  number_of_wkdy_wknd(seasons)+1;
);

 number_of_wkdy_wknd(seasons) = round(number_of_wkdy_wknd(seasons))/24;


duration(seasons,l)=duration(seasons,l)*number_of_wkdy_wknd(seasons);

ELlcgw(r,seasons,l) =
sum(hrs$(
                (        (day(hrs)>=start_day(seasons) and
                          day(hrs)<=end_day(seasons) and (spring(seasons) or summer(seasons)) ) or

                         (day(hrs)>=start_day_fall and
                          day(hrs)<=end_day_fall and fall(seasons)) or

                         ((day(hrs)>=start_day(seasons) or day(hrs)<=end_day(seasons)) and
                                 winter(seasons))

                )and
                dayofweek(hrs) = season_day_of_week(seasons) and
                hour(hrs)>=block_start(seasons,l) and
                hour(hrs)<block_end(seasons,l)
         ), HLC(r,hrs))/duration(seasons,l)
;

*abort ELlcgw;

ELlcgw_stddev(r,seasons,l) =
sum(hrs$(
                (        (day(hrs)>=start_day(seasons) and
                          day(hrs)<=end_day(seasons) and (spring(seasons) or summer(seasons)) ) or

                         (day(hrs)>=start_day_fall and
                          day(hrs)<=end_day_fall and fall(seasons)) or

                         ((day(hrs)>=start_day(seasons) or day(hrs)<=end_day(seasons)) and
                                 winter(seasons))

                )and
                dayofweek(hrs) = season_day_of_week(seasons) and
                hour(hrs)>=block_start(seasons,l) and
                hour(hrs)<block_end(seasons,l)
         ), (HLC(r,hrs)-ELlcgw(r,seasons,l))*(HLC(r,hrs)-ELlcgw(r,seasons,l)) )/(duration(seasons,l))
;

ELlcgw_stddev(r,seasons,l) = sqrt(ELlcgw_stddev(r,seasons,l));

if(card(e)=1 ,
*duration(seasons,l)$(card(seasons)=1)=duration(seasons,l)*365/number_of_wkdy_wknd(seasons);

);


*        Rescale demand to GW
*        Rescale duration such taht energy is in units of TWH
*        Marginal costs should be in units of MMUSD/TWH
         d(seasons,l) = duration(seasons,l)*1e-3;

parameter        CDF_lo(r,seasons,l),
                 CDF_hi(r,seasons,l),
                 diff(r,seasons,l),
                 CDF_alpha(r,seasons,l),
                 CDF_beta(r,seasons,l),
                 Z_cdf(r,seasons,l),
                 X_cdf(r,seasons,l,scen),
                 CDF_x(r,seasons,l,scen) cumulative distribution functions for each scenario s;


         CDF_lo(r,seasons,l)=ELlcgw(r,seasons,l)-ELlcgw_stddev(r,seasons,l)*2;
         CDF_hi(r,seasons,l)=ELlcgw(r,seasons,l)+ELlcgw_stddev(r,seasons,l)*2;

*        CDF_lo(r,seasons,l)$spring(seasons)=ELlcgw(r,seasons,l)-ELlcgw_stddev(r,seasons,l)*2;
*        CDF_hi(r,seasons,l)$spring(seasons)=ELlcgw(r,seasons,l)+ELlcgw_stddev(r,seasons,l)*2;

         diff(r,seasons,l) = CDF_hi(r,seasons,l) -CDF_lo(r,seasons,l);

         CDF_alpha(r,seasons,l) = cdfnorm(CDF_lo(r,seasons,l),ELlcgw(r,seasons,l),ELlcgw_stddev(r,seasons,l));
         CDF_beta(r,seasons,l) =  cdfnorm(CDF_hi(r,seasons,l),ELlcgw(r,seasons,l),ELlcgw_stddev(r,seasons,l));
         Z_cdf(r,seasons,l)=CDF_beta(r,seasons,l)-CDF_alpha(r,seasons,l);
         prob(r,seasons,l,s,ss)=0;
         CDF_x(r,seasons,l,s)=0;

if(card(s)>1,
  loop(s$(ord(s)<=card(s)),

         X_cdf(r,seasons,l,s)=CDF_lo(r,seasons,l)+ord(s)*diff(r,seasons,l)/card(s);
         CDF_x(r,seasons,l,s)= (cdfnorm(X_cdf(r,seasons,l,s),ELlcgw(r,seasons,l),ELlcgw_stddev(r,seasons,l))-CDF_alpha(r,seasons,l))/Z_cdf(r,seasons,l);
         prob(r,seasons,l,s,ss) = (CDF_x(r,seasons,l,s) - CDF_x(r,seasons,l,s-1))/card(ss);
         X_cdf(r,seasons,l,s)=X_cdf(r,seasons,l,s)-(diff(r,seasons,l)/(2*card(s)))$(card(s)>1);
         EL_Demand(r,seasons,l,s)= X_cdf(r,seasons,l,s);
  );
else
         prob(r,seasons,l,s,ss) = 1;
         EL_Demand(r,seasons,l,s)=ELlcgw(r,seasons,l);
);
       EL_Demand(r,seasons,l,s)= EL_Demand(r,seasons,l,s)*1e-3;

*abort prob,EL_Demand,CDF_x,x_cdf,ELlcgw_stddev,ELlcgw


