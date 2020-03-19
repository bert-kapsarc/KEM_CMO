file empinfo / '%emp.info%' /;
PUT empinfo 'equilibrium';

loop((e,l,s,ss),
  PUT / 'max', iso_profit(e,l,s,ss);
  loop(r,PUT Load(r,e,l,s,ss));
  PUT EQ5_1(e,l,s,ss);
  loop((n,dir),PUT EQ5_2(n,e,l,s,ss,dir));
);
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
       PUT$(not gttocc(h)) ret(i,h,r);
  );
  loop((r,e,l,s,ss),
       PUT sales(i,r,e,l,s,ss);
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

  loop(r,
       PUT EqX_1(i,r);
     if(market_share_inv(i)<1,
       PUT EqX_2(i,r);
     );
     if(market_share_prod(i)<1,
       PUT EqX_3(i,r);
     );
  );
  loop((h,r)$(Genco_PPA(h,r)>0 and not gttocc(h)),
           PUT EqX_4(i,h,r);
  );
  loop((f,r)$(fuel_quota(f,r)>0),
           PUT EqX_5(i,f,r);
  );
$ontext
  loop((h,r,s,ss)$(not ren(h) and not gttocc(h)),
    PUT EQcapuptime(i,h,r,s,ss);
  )
$offtext
);

PUT / 'vi EQ1 price';
PUT / 'vi EQ1_demand demand';
PUT$(sum((r,e,l)$m(r,e,l),1)>0) / 'vi EQ2 delta';
PUT / 'vi EQ2_capacity total_capacity';
PUT / 'vi EQ2_firm_capacity Cap_avail';
PUT / 'vi EQ3 price_trans';

PUTCLOSE empinfo;
