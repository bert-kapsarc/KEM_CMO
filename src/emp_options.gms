file empinfo / '%emp.info%' /;
PUT empinfo 'equilibrium';




loop((e,l,s,ss),
   PUT / 'max', arb_profit(e,l,s,ss);
   loop(r,
         PUT arbitrage(r,e,l,s,ss);
   );
   PUT EQ6_1(e,l,s,ss);
   PUT EQ6_2(e,l,s,ss);
);

loop(i,
    PUT / 'max', profit(i);
    loop((h,f,r,e,l,s,ss)$fuel_set(h,f,r), PUT Q(i,h,f,r,e,l,s,ss));
    loop((h,r),
         PUT inv(i,h,r);
         if(not gttocc(h), PUT ret(i,h,r); PUT Cap_avail(i,h,r););
    );
    loop((r,e,l,s,ss),
         PUT sales(i,r,e,l,s,ss);
         if(r_options=1,
            loop(o,
                 PUT Sales(i,o,r,e,l,s,ss);
            );
*            PUT Gamma(i,r,e,l,s,ss);
         );

*         loop(rr$r_trade(r,rr),
*            PUT trade(i,r,rr,e,l,s,ss);
*         );
    );
    IF(r_options=1,
         loop((o,r,e,l), PUT K(i,o,r,e,l));
    );

    PUT EQ4_1(i);

    loop((h,r)$(not gttocc(h)),
      loop((e,l,s,ss),
         PUT EQ4_2(i,h,r,e,l,s,ss);
      );
      PUT EQ4_3(i,h,r);
    );

    loop((e,l,s,ss),
         PUT EQ4_4(i,e,l,s,ss);
    );

         if(r_options=1,
             loop((o,r,e,l,s,ss),
                PUT EQ4_5(i,o,r,e,l,s,ss);
                PUT EQ4_6(i,o,r,e,l,s,ss);
             );
         );

    if(r_options=1,
       loop((e,l),
          loop((r,s,ss),
             PUT EQ4_7(i,r,e,l,s,ss);
             PUT EQ4_8(i,r,e,l,s,ss);
          );
          PUT EQ4_9(i,e,l);
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
    loop((f,r)$(fuel_quota(f,r)>0),
             PUT EqX_5(i,f,r);
    );
    loop((h,r)$(Genco_PPA(h,r)>0 and not gttocc(h)),
             PUT EqX_4(i,h,r);
    );
  loop((h,r,s,ss)$(not ren(h) and not gttocc(h)),
    PUT EQcapuptime(i,h,r,s,ss);
  )
);


if(r_options=1,
   PUT / 'DualVar Omega EQ4_5  ';
   PUT / 'DualVar Gamma EQ4_8 ';
   PUT / 'DualVAR Z EQ4_6';
*   PUT / 'DualVAR Zm EQ4_6_2';
);
*PUT / 'DualVar DEQ5_4 EQ5_4 ';
*PUT / 'DualVar tau_neg EQ5_2 ';


loop(r,
   loop((e,l,s,ss),
*      PUT Eq1(r,e,l,s,ss) price(r,e,l,s,ss);
      if(r_options=1,
      loop(o,
           PUT EQ4_10(o,r,e,l,s,ss) M_p(o,r,e,l,s,ss);
      );
      );
   );
*   loop((o,e,l)$(r_options=1 or (r_options<>1 and ord(o)=1 and m(r,e,l))),
*         PUT Eq2(o,r,e,l) delta(o,r,e,l);
*   );
);
$ontext
loop((e,l,s,ss),
   PUT / 'max', iso_profit(e,l,s,ss);
*   loop(r,PUT Load(r,e,l,s,ss));
*   PUT EQ5_1(e,l,s,ss);
*   loop(r,PUT EQ5_2(r,e,l,s,ss));

   PUT EQ5_1(e,l,s,ss) iso_profit(e,l,s,ss);
*   loop(r,PUT EQ5_2(r,e,l,s,ss) Load(r,e,l,s,ss));

   loop((n,dir),
         PUT EQ5_3(n,e,l,s,ss,dir)
         PUT EQ5_4(n,e,l,s,ss,dir) transn(n,e,l,s,ss,dir);
         PUT EQ5_6(n,e,l,s,ss,dir);
   );
*   loop(r,PUT EQ5_5(r,e,l,s,ss) price_trans(r,e,l,s,ss));

);
$offtext
*PUT / 'vi price_trans'
PUT / 'vi EQ1 price';
PUT / 'vi EQ2 price';
PUT / 'vi EQ3 L';
PUT / 'vi EQ5_3 ';
PUT / 'vi EQ5_4 transn';
PUT / 'vi EQ5_6 ';

*PUT / 'DualVar DEQ5_2 EQ5_2';

PUT / 'DualVar DEQ5_3 EQ5_3';
PUT / 'DualVar DEQ5_4 EQ5_4';
PUT / 'DualEqu EQ5_6 transn';


PUTCLOSE empinfo;
