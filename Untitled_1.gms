* Capacity constraint for conventional and renewables
* Q is the total production (ELop in KEM) for a given technology indexed by h (ELp in KEM)
*        and a fuel indexed by f (ELf in KEM)
* Note that in the China model you only need one operation variable block
*        You dont need ELsolop or ELwindop
* For renwables subsets WT(h) and PV(h) we apply a some power distribution to
*        the total avaialble capacity in each load block (ELl) and season (ELs)

Eq9_5(i,h,r,ELl,ELs)$(not gttocc(h)) ..
         Cap_avail(i,h,r)*(
                 1$(not ren(h))
                 +ELwindpowernorm(ELl,ELs,r)$WT(h)
                 +Elsolcurvenorm(ELl,ELs,r)$PV(h)
         )
         -sum(f$fuel_set(h,f,r),Q(i,h,f,r,ELl,ELs))=g=0;

*IN KEM China the new ELcaplim equation should look like *
* Note that I removed ther ELpd(Elp) subset condition for convention plants only

ELcaplim(ELp,v,ELl,t,r)..
   ELcapfac(ELp,v)*ELlchours(ELl,ELs)*(
          ELexistcp(ELp,v,t,r)
         +sum(Elpp$ELpbld(Elpp,v),
                 ELcapadd(Elpp,ELp)*ELbld(Elpp,v,t-ELleadtime(Elpp),r))
   )*(
                 1$(not WT(ELp) and not PV(ELp)) // Not renewables
                 +ELwindpowernorm(ELl,ELs,r)$WT(ELp) // Power distribution for wind
                 +Elsolcurvenorm(ELl,ELs,r)$PV(ELp)  // Power distribution for solar
         )

  -sum(ELf$ELpELf(ELp,ELf),
          ELop(ELp,v,ELl,ELs,ELf,t,r)
         +ELupspincap(Elp,v,ELl,ELs,ELf,t,r)*ELlchours(ELl,ELs)$Elpspin(Elp)
*         +ELlchours(ELl)*
*         ELoploc(ELp,v,ELl,ELf,t,r)$(not ELpnuc(ELp))
  )
                 =g=0
;

* To add PV to KEM China we need to add ELl and ELs sets to all ELop and ELtrans
*        decision variables,
* You can remove the follownig constraints for wind. Only required when using a
* sorted Load Duration Curve

ELwindcaplim(ELpw,v,t,r)..
;

* Electricity produced by wind [GWh]
ELwindutil(ELpw,ELl,v,t,r)..
;

ELwindcapsum(wstep,t,r).. ;