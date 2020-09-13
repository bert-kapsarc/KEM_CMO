* Distribute ownership of exisitng assets by the Genco's
* Near homogenous with one dominant player per region
parameter kind_save
;
kind_save(firm,h,r) = kind0(firm,h,r);
kind0(Genco,h,r)$(not majority(genco,r))   = sum(GGenco, kind_save(GGenco,h,r))/card(Genco)*0.95;
kind0(Genco,h,r)$(majority(genco,r))   =  sum(ggenco,kind_save(ggenco,h,r)) - sum(GGenco$(not majority(ggenco,r)),kind0(ggenco,h,r));

kind.fx(i,h,r)= kind0(i,h,r);

*Fix nuclear and renewable builds to zero
inv.fx(i,'Nuclear',r)=0;
*inv.fx(i,ren,r)=0;
*ret.fx(i,ren,r)=0;

*   cap on market share (investments) by firm
market_share_inv('fringe') = 0.2;
*   cap on market share (production) by firm
market_share_prod('fringe') = 0.2;

* intialize cournot players
$ifThen set cournot
cournot(i)$genco(i) =yes;
$endIf

P_cap(o,r,e,l) =1e6;
P_cap('o1',r,e,l) = 30;
P_cap('o2',r,e,l) = 10;

*Sales_bar(o,r,e,l,s) = (a(r,e,l,s)-p_cap(o,r,e,l))/b(r,e,l,s);
*Sales_bar(o,r,e,l,s)$(Sales_bar(o,r,e,l,s)<0) = 0;
