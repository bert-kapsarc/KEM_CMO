*$INCLUDE ACCESS_HLC.gms
$oninline

set hrs hours in the load curve data set /1*8760/ ;
parameter HLC(r,hrs) hourly load curves for represenative day in each month in MW
parameter ELlcgw(r,seasons,l) average power demand load blocks in MW
          ELlcgw_stddev(r,seasons,l) variance power demand load blocks in MW
          EL_demand(r,e,l,s,ss) Stochastic Electricity Demand for scenarios s in GW
          d(e,l) duration of segemt l in region r (deterministic)
          prob(r,e,l,s,ss) probability off each scenario
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

ELlcgw_stddev(r,e,l) =
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
         ), (HLC(r,hrs)-ELlcgw(r,e,l))*(HLC(r,hrs)-ELlcgw(r,e,l)) )/(duration(e,l))
;
ELlcgw_stddev(r,e,l) = sqrt(ELlcgw_stddev(r,e,l));

if(card(e)=1 ,
duration(e,l)$(card(e)=1)=duration(e,l)*365/number_of_days(e);

);


*        Rescale demand to GW
*        Rescale duration such taht energy is in units of TWH
*        Marginal costs should be in units of MMUSD/TWH
         d(e,l) = duration(e,l)*1e-3;

parameter CDF_lo(r,e,l), CDF_hi(r,e,l), diff(r,e,l), CDF_alpha(r,e,l), CDF_beta(r,e,l), Z_cdf(r,e,l), X_cdf(r,e,l,scen);
parameter CDF_x(r,e,l,scen) cumulative distribution functions for each scenario s;


         CDF_lo(r,e,l)=ELlcgw(r,e,l)-ELlcgw_stddev(r,e,l)*2;
         CDF_hi(r,e,l)=ELlcgw(r,e,l)+ELlcgw_stddev(r,e,l)*2;

         diff(r,e,l) = CDF_hi(r,e,l) -CDF_lo(r,e,l);

         CDF_alpha(r,e,l) = cdfnorm(CDF_lo(r,e,l),ELlcgw(r,e,l),ELlcgw_stddev(r,e,l));
         CDF_beta(r,e,l) =  cdfnorm(CDF_hi(r,e,l),ELlcgw(r,e,l),ELlcgw_stddev(r,e,l));
         Z_cdf(r,e,l)=CDF_beta(r,e,l)-CDF_alpha(r,e,l);
         prob(r,e,l,s,ss)=0;
         CDF_x(r,e,l,s)=0;

loop(s$(ord(s)<=card(s)),

         X_cdf(r,e,l,s)=CDF_lo(r,e,l)+ord(s)*diff(r,e,l)/card(s);
         CDF_x(r,e,l,s)= (cdfnorm(X_cdf(r,e,l,s),ELlcgw(r,e,l),ELlcgw_stddev(r,e,l))-CDF_alpha(r,e,l))/Z_cdf(r,e,l);
         prob(r,e,l,s,ss) = (CDF_x(r,e,l,s) - CDF_x(r,e,l,s-1))/card(ss);
         X_cdf(r,e,l,s)=X_cdf(r,e,l,s)-(diff(r,e,l)/(2*card(s)))$(card(s)>1);
         EL_Demand(r,e,l,s,ss)= X_cdf(r,e,l,s);
);
       EL_Demand(r,e,l,s,ss)= EL_Demand(r,e,l,s,ss)*1e-3;
*abort prob,EL_Demand,CDF_x,x_cdf,ELlcgw_stddev,ELlcgw


