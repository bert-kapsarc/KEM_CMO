* Distribute ownership of exisitng assets by the Genco's
* Near homogenous with one dominant player per region
 kind0(Genco,h,r) = sum(GGenco, kind_save(GGenco,h,r))*
 ( 1/card(ggenco)*(1-1/card(ggenco))$(not oli(genco,r))
  +((2*card(ggenco)-1)/card(ggenco)**2)$oli(genco,r)) ;


if(legacy_auction = 1,
         ret.fx(i,h,r)$(not fringe(i))= 0;

else
         kind.fx(i,h,r)= kind0(i,h,r);
);
         kind.fx(fringe,h,r) = kind0(fringe,h,r);

*        conjectural variations of the firms

*        cap on market share (investments) by firm
*     market_share_inv('fringe') = 0.2;
*        cap on market share (production) by firm
     market_share_prod('fringe') = 0.2;

*        Capacity market configuration
     m(r,e,l) = no;
