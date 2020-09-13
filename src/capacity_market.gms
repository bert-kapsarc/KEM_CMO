$ifThen exist build%SLASH%energy_cournot.gdx
$gdxin build%SLASH%energy_cournot.gdx
$LOAD demand_actual demand Cap_avail price

* Below we define in what demand segments the capacity market is oeprated
* It is defined when the demand exceeds some ratio of the avabilabe capacity in a given region
scalar price_threshold /1.6/
         capacity_threshold /0.85/
$gdxin
loop(l,
    m(h,r,e,l)$(
     smax((s,ss),demand.l(r,e,l,s,ss)) >
     sum((i,hh),Cap_avail.l(i,hh,r))*capacity_threshold
*    sum((s,ss),prob(r,e,l,s,ss)*price.l(r,e,l,s,ss))>
*    price_threshold*smin((ee,ll),sum((s,ss),prob(r,ee,ll,s,ss)*price.l(r,ee,ll,s,ss)))
    )=yes
);
$endIf

*m(h,r,e,'l4')$summer(e) =  yes;
*m(h,r,e,'l5')$summer(e) =  yes;
*m(h,r,e,'l6')$summer(e) =  yes;
*m(h,r,e,'l7')$summer(e) =  yes;
*m(h,r,e,'l8')$summer(e) =  yes;
;
scalar PVratio /0/;
$ifThen.pv set PVratio
m(h,r,e,l)$(not ren(h)) = 0;
m(h,r,e,l)$(
    (Elsolcurvenorm(l,e,r)>0 and sameas(h,'PV'))
    or (ELwindpowernorm(l,e,r)>0 and sameas(h,'WT'))
)=yes
;
m(h,r,e,l)$(
    (Elsolcurvenorm(l,e,r)<=0 and sameas(h,'PV'))
    or (ELwindpowernorm(l,e,r)<=0 and sameas(h,'WT'))
)=no
;
PVratio = %PVratio%/100;
$endIf.pv

$ifThen %capacity%=="price"
* Capacity Price calibration                                                   *
* assume a flat inverse demand curve for capacity
* price is set to the maximum fixed cost of all generators operating in the market
* spread over the total number of demand hours
theta(h,r,e,l) =
    +smax(hh$(not nuclear(hh) and not ren(hh)),(ici(hh)+om(hh)))/
    sum((ee,ll),d(ee,ll))
;
theta(h,r,e,l)$(ren(h) and sum((ee,ll)$m(h,r,ee,ll),d(ee,ll))>0) =
    (ici(h)+om(h))*PVratio
*    *(Elsolcurvenorm(l,e,r)$sameas(h,'PV')
*     +ELwindpowernorm(l,e,r)$sameas(h,'WT'))
    /sum((ee,ll)$m(h,r,ee,ll),d(ee,ll))
;

$elseIf %capacity%=='auction'
Parameter Cap_target(h,r)
/


    PV.COA  15
    PV.WOA  15
    PV.EOA  10
    PV.SOA  5
/;
scalar capTargetM /1/;
$ifthen set capTargetM
Cap_target(h,r)$ren(h) = Cap_target(h,r)*%capTargetM%;
$endIf
Cap_target('CCGT',r) = 2*sum(i,kind0(i,'CCGT',r));
Cap_target('GT',r) = smax((s,ss,e,l),demand.l(r,e,l,s,ss))*1.2
    -sum(i,kind0(i,'ST',r)*0.5-Cap_target('CCGT',r))
;
Cap_target('GT','EOA') = Cap_target('GT','EOA')*0.5;
Cap_target('GT','WOA') = Cap_target('GT','WOA')*0.5;
Cap_target('GT','SOA') = Cap_target('GT','SOA')*2;
*  Cap_target('COA') = 30;
theta(h,r,e,l)$(not ren(h) and m(h,r,e,l) and Cap_target(h,r)>0) =
    2*(ici(h)+om(h))
    /sum((ee,ll),d(ee,ll))
* theta(h,r,e,l)$m(h,r,e,l) =  2*smax(h$(not nuclear(h)),(ic(h)+om(h)))/sum((ee,ll),d(ee,ll))*(1+0.5$coa(r))
;
xi(h,r,e,l)$(not ren(h) and m(h,r,e,l) and sum((ee,ll),d(ee,ll))>0 and Cap_target(h,r)>0)=
    (ici(h)+om(h))
    /sum((ee,ll),d(ee,ll))/Cap_target(h,r)
;

theta(h,r,e,l)$(ren(h) and sum((ee,ll)$m(h,r,ee,ll),d(ee,ll))>0 and Cap_target(h,r)>0) =
    2*(ici(h)+om(h))*PVratio
    /sum((ee,ll)$m(h,r,ee,ll),d(ee,ll))
;
xi(h,r,e,l)$(ren(h) and sum((ee,ll)$m(h,r,ee,ll),d(ee,ll))>0 and Cap_target(h,r)>0) =
    (ic(h)+om(h))*PVratio
    /sum((ee,ll)$m(h,r,ee,ll),d(ee,ll))/Cap_target(h,r)
;

$endIf

