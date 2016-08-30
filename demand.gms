*$INCLUDE ACCESS_HLC.gms
$oninline

set hrs            hours in the load curve data set /1*8760/
parameter HLC(r,hrs) hourly load curves for represenative day in each month
parameter ELlcgw(r,e,l) power demand load blocks

;
$gdxin db\load.gdx
$load HLC
$gdxin

* convert to GW
*HLC(r,hrs) = HLC(r,hrs)*1e-3;

parameter EL_demand(r,e,l,s) Electricity Demand (MW)


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

*                                 l1  l2  l3
*(winter,spring-fall,summer)      12   6   6
 ;

 parameter block_start(e,l) start hour for hour in load block l
           block_end(e,l);

 block_start(e,l) = sum(ll$(ord(ll)<ord(l)),duration(e,ll));
 block_end(e,l) = sum(ll$(ord(ll)<=ord(l)),duration(e,ll));

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

number_of_days(e)$(not winter(e)) = end_day(e)-start_day(e)+1;
number_of_days('spring-fall') = number_of_days('spring-fall')+end_day_fall-start_day_fall+1;
number_of_days('winter') = smax(hrs,day(hrs))-sum(e,number_of_days(e));


*
if(card(e)=1 ,
duration(e,l)$(card(e)=1)=duration(e,l)*365;
else
   duration(e,l)$(card(e)=1)=duration(e,l)*number_of_days(e);

);
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





