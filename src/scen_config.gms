* Distribute ownership of exisitng assets by the Genco's
* Near homogenous with one dominant player per region
 kind0(Genco,h,r)$(not majority(genco,r))   = sum(GGenco, kind_save(GGenco,h,r))/card(Genco)*0.97;
 kind0(Genco,h,r)$(majority(genco,r))   =  sum(ggenco,kind_save(ggenco,h,r)) - sum(GGenco$(not majority(ggenco,r)),kind0(ggenco,h,r));


  kind.fx(i,h,r)= kind0(i,h,r);

*        conjectural variations of the firms

*        cap on market share (investments) by firm
     market_share_inv('fringe') = 0.2;
*        cap on market share (production) by firm
     market_share_prod('fringe') = 0.2;

*        Capacity market configuration
*     m(r,e,"l6") = yes;

* identify cournot players
     cournot(i)$genco(i)  =yes;

     P_cap(o,r,e,l) =1e6;


     P_cap('o1',r,e,l) = 60;
*     P_cap('o2',r,e,l) = 50;

     Sales_bar(o,r,e,l,s,ss) = (a(r,e,l,s,ss)-p_cap(o,r,e,l))/b(r,e,l,s,ss);
     Sales_bar(o,r,e,l,s,ss)$(Sales_bar(o,r,e,l,s,ss)<0) = 0;
