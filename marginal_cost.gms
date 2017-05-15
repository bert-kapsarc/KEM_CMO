parameter intl_fuel_price(f,r) price of fuels in USD per mmbtu and KG U235;
parameter fuel_price_admin(f,r) price of fuels in USD per mmbtu and KG U235;
parameter fuel_price(f,r) price of fuels in USD per mmbtu and KG U235;
intl_fuel_price('methane',r) = 3;
intl_fuel_price('U-235',r)= 113;
intl_fuel_price('oil',r) = 10;

fuel_price('methane',r) = 3;
fuel_price('oil',r) = 3;
fuel_price('u-235',r)= 113;

fuel_price_admin('methane',r) = 1.25;
fuel_price_admin('oil',r) = 1.26;
fuel_price_admin('u-235',r)= 113;

*intl_fuel_price(f,r)=fuel_price(f,r);

parameters  mc_baseline(h,f,r) marginal cost of baseline scenario
            mc_reform(h,f,r) marginal cost after price reform  ;

mc_baseline(h,f,r)$fuel_set(h,f,r) = mc_non_fuel(h,r)+heat_rate(h,f)*fuel_price_admin(f,r);
mc_reform(h,f,r)$fuel_set(h,f,r) = mc_non_fuel(h,r)+heat_rate(h,f)*fuel_price(f,r);

if(fixed_ppa=1,
         fuel_price(f,r) = fuel_price_admin(f,r) ;
         mc(h,f,r)$fuel_set(h,f,r) = mc_baseline(h,f,r);
else
         mc(h,f,r)$fuel_set(h,f,r) = mc_reform(h,f,r);
);
