

fuel_price_intl('methane',r) = 3;
fuel_price_intl('U-235',r)= 113;
fuel_price_intl('oil',r) = 10;

fuel_price('methane',r) = 3;
fuel_price('oil',r) = 3.01;
fuel_price('u-235',r)= 113;

fuel_price_admin('methane',r) = 1.25;
fuel_price_admin('oil',r) = 1.26;
fuel_price_admin('u-235',r)= 113;

*intl_fuel_price(f,r)=fuel_price(f,r);
;

mc_baseline(h,f,r)$fuel_set(h,f,r) = mc_non_fuel(h,r)+heat_rate(h,f,r)*fuel_price_admin(f,r);
mc_reform(h,f,r)$fuel_set(h,f,r) = mc_non_fuel(h,r)+heat_rate(h,f,r)*fuel_price(f,r);
mc_intl(h,f,r)$fuel_set(h,f,r) = mc_non_fuel(h,r)+heat_rate(h,f,r)*fuel_price_intl(f,r);

$ifThen.fuelprice set fuelPriceAdmin 
    fuel_price(f,r) = fuel_price_admin(f,r) ;
$else.fuelprice 
$ifThen set noFuelSubsidy
    fuel_price(f,r) = fuel_price_intl(f,r);
$endIf
$endIf.fuelprice
mc(h,f,r)$fuel_set(h,f,r)=
    mc_non_fuel(h,r)+heat_rate(h,f,r)*fuel_price(f,r);

*mc(ccgt,f,r)$fuel_set(ccgt,f,r) = 0
