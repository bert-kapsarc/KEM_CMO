$title Dynamic Programming Investment with Reliability Options
$ontext

$offtext

*$INCLUDE ACCESS_HLC.gms
$INCLUDE Macros.gms
$FuncLibIn stolib stodclib
function cdfnorm /stolib.cdfnormal/;

scalar trading set to 1 to allow regional trade by firms /0/
       fixed_ppa  /0/
       r_options reliability options switch /1/

file empinfo / '%emp.info%' /;

$INCLUDE SetsAndVariables.gms

$INCLUDE Demand.gms
$include parameters.gms
$include marginal_cost.gms


$include demand_calib.gms
$INCLUDE equations.gms
$include scen_config.gms
;

*v(i)=0;
*z(i) = -1;

$ontext
*        Configure capacity market segments
         scalar price_threshold /1.6/
                 capacity_threshold /0.9/
*  Enter file to load previous data from
$gdxin test_1.gdx
$include capacity_market.gms
$offtext
;
m(r,e,l) =yes;
*$(summer(e))
Option Savepoint=1;


PUT empinfo 'equilibrium';

loop(i,
    PUT / 'min', profit(i);

    loop((h,f,r,e,l,s,ss)$fuel_set(h,f,r), PUT Q(i,h,f,r,e,l,s,ss));
    loop((h,r),
         PUT inv(i,h,r);
         if(not gttocc(h), PUT ret(i,h,r));
    );
    loop((r,e,l,s,ss),
         PUT U(i,r,e,l,s,ss);
         if(r_options=1,
            loop(o,
                 PUT Sales(i,o,r,e,l,s,ss);
            );
            PUT Gamma(i,r,e,l,s,ss);
         );

         loop(rr$r_trade(r,rr),
            PUT trade(i,r,rr,e,l,s,ss);
         );
    );
    IF(r_options=1,
         loop((o,r,e,l), PUT K(i,o,r,e,l));
    );


    PUT EQ3_1(i);

    loop((h,r)$(not gttocc(h)),
      loop((e,l,s,ss),
         PUT Eq3_2(i,h,r,e,l,s,ss);
      );
         PUT Eq3_3(i,h,r);
    );

    loop((r,e,l,s,ss),
         PUT Eq3_4(i,r,e,l,s,ss);
    );

    if(r_options=1,
       loop((e,l),
          loop((r,s,ss),
             PUT Eq3_7(i,r,e,l,s,ss);
             PUT EQ3_8(i,r,e,l,s,ss);
          );
          PUT EQ3_9(i,e,l);
       );
    );
    loop(r,
         PUT EqX_1(i,r);
       if(market_share_inv(i)<1,
         PUT EqX_2(i,r);
       );
       if(market_share_prod(i)<1,
         PUT EqX_3(i,r);
       );
    );
);



PUT / 'vi EQ1 price';
if(r_options<>1,
         PUT / 'vi EQ2 delta';
else
   loop((o,r,e,l), PUT EQ2(o,r,e,l) delta(o,r,e,l));

);
   loop((i,h,r)$(not gttocc(h)),
         PUT Eq3_11(i,h,r) Cap_avail(i,h,r);
   );
if(r_options=1,
loop((r,e,l),
    loop(o,
*       PUT delta(o,r,e,l)
       loop((s,ss),
           PUT Eq3_5(o,r,e,l,s,ss);
           PUT Eq3_6(o,r,e,l,s,ss);
           PUT Eq3_10(o,r,e,l,s,ss) M_p(o,r,e,l,s,ss);
       );
    );
);
);
*$offtext

loop((h,r)$(Genco_PPA(h,r)>0 and not gttocc(h)),
*         PUT EqX_4(h,r);
);
loop((f,r)$(fuel_quota(f,r)>0),
*         PUT EqX_5(f,r);
);

PUT / 'DualVar Omega EQ3_5  ';
PUT / 'DualVar Gamma EQ3_8 ';
PUT / 'DualVAR Z EQ3_6';

PUTCLOSE empinfo;


*Execute_Loadpoint 'test_2.gdx';

CMO.optfile = 1 ;

*solve CMO using mcp;
SOLVE CMO using emp;
$include report.gms
