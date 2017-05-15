* Below we define in what demand segments the capacity market is oeprated
* It is defined when the demand exceeds some ratio of the avabilabe capacity in a gien region
scalar price_threshold /1.6/
         capacity_threshold /0.9/
$gdxin
loop(l,
 m(r,e,l)$(
         smax((s,ss),demand_actual(r,e,l,s,ss))/d(e,l) >
         sum((i,h),Cap_avail.l(i,h,r))*capacity_threshold

*        sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss))>
*        price_threshold*smin((ee,ll),sum((s,ss),prob(r,ee,ll,s,ss)*price.l(r,ee,ll,s,ss)))
        )=yes
);

