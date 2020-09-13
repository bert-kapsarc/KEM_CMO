
run(){
	KEM=`echo /c/GAMS/win64/28.2/gams.exe KEM_run idir=src`
	date
	echo $1 $2 $3 $4 $5 $6;
	$KEM $1 $2 $3 $4 $5 $6;
}

cournot=`echo --cournot=false`
noFuelSubsidy=`echo --noFuelSubsidy=true`
capacity_price=`echo --capacity=price`

# calibration scenario
#run --currentPolicy=true --calibration=true;

cp run.gms CMO_run.gms 

run 
run $noFuelSubsidy
run $noFuelSubsidy $cournot
run $cournot
run $cournot $capacity
PVratio=`echo --PVratio=50`
run $cournot $capacity $PVratio
PVratio=`echo --PVratio=55`
run $cournot $capacity $PVratio
PVratio=`echo --PVratio=60`
run $cournot $capacity $PVratio
PVratio=`echo --PVratio=65`
run $cournot $capacity $PVratio
PVratio=`echo --PVratio=70`
run $cournot $capacity $PVratio

rm CMO_run.gms
