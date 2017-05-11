
if(r_options=1000,
PUT / 'min', arb_profit;
loop((r,rr,e,l,s,ss)$r_trade(r,rr),
         PUT arbitrage(r,rr,e,l,s,ss);
);

loop((r,e,l),
    loop((s,ss),
       if(r_options=1,
          loop(o,
*             PUT M_p(o,r,e,l,s,ss);
*             PUT Z(o,r,e,l,s,ss);
*             PUT Omega(o,r,e,l,s,ss);
          );
       );
       loop(rr$r_trade(r,rr),
          PUT price_trans(r,rr,e,l,s,ss);
       );
    );
$ontext
    loop(o,
       if(r_options=1 or (r_options<>1 and ord(o)=1 and m(r,e,l)),
          PUT delta(o,r,e,l);
       );
    );
$offtext
);

PUT EQ4_1;
loop((r,rr,e,l,s,ss)$r_trans(r,rr),
         PUT Eq5_1(r,rr,e,l,s,ss);
         PUT Eq5_2(r,rr,e,l,s,ss);
         PUT Eq5_3(r,rr,e,l,s,ss);
         PUT Eq5_4(r,rr,e,l,s,ss);
);
*$ontext

PUT / 'DualVar tau_pos EQ5_1 ';
PUT / 'DualVar tau_neg EQ5_2 ';
);