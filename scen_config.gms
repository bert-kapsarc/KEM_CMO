* Distribute ownership of exisitng assets by the Genco's
* Near homogenous with one dominant player per region
 kind0(Genco,h,r) = sum(GGenco, kind_save(GGenco,h,r))*
 ( 1/card(ggenco)*(1-1/card(ggenco))$(not oli(genco,r))
  +((2*card(ggenco)-1)/card(ggenco)**2)$oli(genco,r)) ;


  kind.fx(i,h,r)= kind0(i,h,r);

*        conjectural variations of the firms

*        cap on market share (investments) by firm
*     market_share_inv('fringe') = 0.2;
*        cap on market share (production) by firm
     market_share_prod('fringe') = 0.2;

*        Capacity market configuration
     m(r,e,l) = no;

loop(h$(not ren(h)),
     P_cap(h,r,e,l) =1e3;
);

     P_cap("GT",r,e,l) = 50;
     P_cap("PV",r,e,l) = 50;
     P_cap("WT",r,e,l) = 45;

     parameter temp(h), p_cap_index(h);

LOOP((r,e,l),
         temp(h) =P_cap(h,r,e,l);
*         execute_unload "rank_in.gdx", temp;
*         execute 'gdxrank rank_in.gdx rank_out.gdx';

*         execute_load "rank_out.gdx", p_cap_index=temp;
*         abort p_cap_index, temp;

  loop(h,
    if(ord(h)=1,
         Sales_bar(h,r,e,l,s,ss) = (a(r,e,l,s,ss)-p_cap(h,r,e,l))/b(r,e,l,s,ss);
    else
        Sales_bar(h,r,e,l,s,ss) = (p_cap(h-1,r,e,l)-p_cap(h,r,e,l))/b(r,e,l,s,ss)+Sales_bar(h-1,r,e,l,s,ss);

*        abort sales_bar;
    );
  );
);
*        abort Sales_bar;
