
run(){
	KEM=`echo /c/GAMS/win64/28.2/gams.exe CMO_run idir=src`
	date
	echo $1 $2 $3 $4 $5 $6;
	$KEM $1 $2 $3 $4 $5 $6;
}

cournot=`echo --cournot=true`
noFuelSubsidy=`echo --noFuelSubsidy=true`
fuelPriceAdmin=`echo --fuelPriceAdmin=true`
capacityPrice=`echo --capacity=price`
capacityAuction=`echo --capacity=auction`
# calibration scenario
#run --currentPolicy=true --calibration=true;

cp run.gms CMO_run.gms 
: '
run --calibration=true
run $fuelPriceAdmin
run $fuelPriceAdmin $cournot
run 
run $cournot
run $noFuelSubsidy
run $noFuelSubsidy $cournot
run $cournot
run $cournot $capacityPrice
#run $cournot $capacityAuction
PVratio=`echo --PVratio=40`
run $cournot $capacityPrice $PVratio
PVratio=`echo --PVratio=45`
run $cournot $capacityPrice $PVratio
PVratio=`echo --PVratio=50`
run $cournot $capacityPrice $PVratio
PVratio=`echo --PVratio=55`
run $cournot $capacityPrice $PVratio
PVratio=`echo --PVratio=60`
run $cournot $capacityPrice $PVratio
PVratio=`echo --PVratio=65`
run $cournot $capacityPrice $PVratio
PVratio=`echo --PVratio=70`
run $cournot $capacityPrice $PVratio
# '
PVratio=`echo --PVratio=50`
capTargetM=`echo --capTargetM=12`
run $cournot $capacityAuction $PVratio $capTargetM
capTargetM=`echo --capTargetM=14`
run $cournot $capacityAuction $PVratio $capTargetM
capTargetM=`echo --capTargetM=16`
run $cournot $capacityAuction $PVratio $capTargetM
capTargetM=`echo --capTargetM=18`
run $cournot $capacityAuction $PVratio $capTargetM
capTargetM=`echo --capTargetM=20`
run $cournot $capacityAuction $PVratio $capTargetM
capTargetM=`echo --capTargetM=10`
run $cournot $capacityAuction $PVratio $capTargetM

:'
reserve=`echo --reserve=true`
run $cournot $capacityAuction $PVratio $capTargetM $reserve
# '

rm CMO_run.gms
