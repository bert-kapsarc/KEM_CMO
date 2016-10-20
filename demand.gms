*$INCLUDE ACCESS_HLC.gms
$oninline

set hrs            hours in the load curve data set /1*8760/
parameter HLC(r,hrs) hourly load curves for represenative day in each month in MW
parameter ELlcgw(r,seasons,l) power demand load blocks in MW
          EL_demand(r,e,l,s,ss) Stochastic Electricity Demand for scenarios s in GW
          d(e,l) duration of segemt l in region r (deterministic)
          prob(s,ss) probability off each scenario
;
$gdxin db\load.gdx
$load HLC
$gdxin



parameter day(hrs)    day for each hour in a year
          hour(hrs) represents each hour in the hourly demand data year from 0 to 23
;


          day(hrs) = floor(ord(hrs)/24)+1;
          day('8760') = 1;


          hour(hrs)=ord(hrs)-(day(hrs)-1)*24

table duration(seasons,l) duration of segemt l in region r and season e

* these are the hour blocks used to average the actual hourly demand patterns
* must sum to 24
*$ontext
                                 l1  l2  l3  l4  l5  l6  l7  l8
(winter,spring-fall,summer)       4   4   4   2   3   2   2   3
*$offtext

*                                 l1  l2
*(winter,spring-fall,summer)      12  12
 ;

 parameter block_start(seasons,l) start hour for hour in load block l
           block_end(seasons,l);

 block_start(seasons,l) = sum(ll$(ord(ll)<ord(l)),duration(seasons,ll));
 block_end(seasons,l) = sum(ll$(ord(ll)<=ord(l)),duration(seasons,ll));

parameter start_day(seasons) first day to sample hourly data from for season e

/
winter 304
spring-fall 61
summer 122
/
          end_day(seasons) last day to sample hourlyy data for season e


number_of_days(seasons)
       ;
scalar
         start_day_fall first day to sample hourly data from for fall season /243/
         end_day_fall first day to sample hourly data from




;
end_day('winter') = start_day('spring-fall')-1;
end_day('spring-fall') = start_day('summer')-1;
end_day('summer') = start_day_fall-1;
end_day_fall = start_day('winter')-1;

number_of_days(seasons)$(not winter(seasons)) = end_day(seasons)-start_day(seasons)+1;
number_of_days('spring-fall') = number_of_days('spring-fall')+end_day_fall-start_day_fall+1;
number_of_days('winter') = smax(hrs,day(hrs))-sum(seasons,number_of_days(seasons));


   duration(seasons,l)=duration(seasons,l)*number_of_days(seasons);

ELlcgw(r,e,l) =
sum(hrs$(
                (        (day(hrs)>=start_day(e) and
                          day(hrs)<=end_day(e) and (spring(e) or summer(e)) ) or

                         (day(hrs)>=start_day_fall and
                          day(hrs)<=end_day_fall and fall(e)) or

                         ((day(hrs)>=start_day(e) or day(hrs)<=end_day(e)) and
                                 winter(e))

                )and
                hour(hrs)>=block_start(e,l) and
                hour(hrs)<block_end(e,l)
         ), HLC(r,hrs))/(duration(e,l))
;


if(card(e)=1 ,
duration(e,l)$(card(e)=1)=duration(e,l)*365/number_of_days(e);

);


scalar random, mean, stddev;
mean = 1;
stddev =0.2;

scalar CDF_lo /0.5/, CDF_hi /1.5/, diff, CDF_alpha,CDF_beta,Z_cdf,X_cdf;
parameter CDF_x(s) cumulative distribution functions for each scenario s;


          diff = CDF_hi -CDF_lo;

*        apply growth equally to all demand segments
*        Rescale demand to GW
*        Rescale duration such taht energy is in units of TWH
*        Marginal costs should be in units of MMUSD/TWH

         EL_Demand(r,e,l,s,ss) = ELlcgw(r,e,l)*1e-3;
         d(e,l) = duration(e,l)*1e-3;
         ;

         CDF_alpha = cdfnorm(CDF_lo,mean,stddev);
         CDF_beta =  cdfnorm(CDF_hi,mean,stddev);
         Z_cdf=CDF_beta-CDF_alpha;
         prob(s,ss)=0;
         CDF_x(s)=0;

loop(s$(ord(s)<=card(s)),

         X_cdf=CDF_lo+ord(s)*diff/card(s);
         CDF_x(s)= (cdfnorm(X_cdf,mean,stddev)-CDF_alpha)/Z_cdf;
         prob(s,ss) = CDF_x(s) - CDF_x(s-1);
         X_cdf=X_cdf-(diff/(2*card(s)))$(card(s)>1);
         EL_Demand(r,e,l,s,ss)= EL_Demand(r,e,l,s,ss)*X_cdf;
         display x_cdf;
);

display prob,EL_Demand,CDF_x



