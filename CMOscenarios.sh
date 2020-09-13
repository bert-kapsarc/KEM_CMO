
run(){
	KEM=`echo /c/GAMS/win64/28.2/gams.exe CMO_run idir=src`
	date
	echo $1 $2 $3 $4 $5 $6;
	$KEM $1 $2 $3 $4 $5 $6;
}

cournot=`echo --cournot=true`
noFuelSubsidy=`echo --noFuelSubsidy=true`
capacityPrice=`echo --capacity=price`
capacityAuction=`echo --capacity=auction`
# calibration scenario
#run --currentPolicy=true --calibration=true;

cp run.gms CMO_run.gms 
#run --calibration=true
#run 
#run $noFuelSubsidy
#un $noFuelSubsidy $cournot
#run $cournot
#run $cournot $capacityPrice
run $cournot $capacityAuction
PVratio=`echo --PVratio=40`
#run $cournot $capacityAuction $PVratio
PVratio=`echo --PVratio=45`
#run $cournot $capacityAuction $PVratio
PVratio=`echo --PVratio=50`
#run $cournot $capacityAuction $PVratio
capTargetM=`echo --capTargetM=1.2`
#run $cournot $capacityAuction $PVratio $capTargetM
capTargetM=`echo --capTargetM=1.4`
#run $cournot $capacityAuction $PVratio $capTargetM
capTargetM=`echo --capTargetM=1.6`
#run $cournot $capacityAuction $PVratio $capTargetM
capTargetM=`echo --capTargetM=1.8`
#run $cournot $capacityAuction $PVratio $capTargetM
capTargetM=`echo --capTargetM=2`
#run $cournot $capacityAuction $PVratio $capTargetM
#PVratio=`echo --PVratio=65`
#run $cournot $capacity $PVratio
#PVratio=`echo --PVratio=70`
#run $cournot $capacity $PVratio#

rm CMO_run.gms
