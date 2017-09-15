/*hospstの文字情報を数字に置換*/
gen state =1 if hospst == "AR"
replace state =2 if hospst == "CA"
replace state =3 if hospst == "FL"
replace state =4 if hospst == "IA"
replace state =5 if hospst == "NE"
replace state =6 if hospst == "NY"
replace state =7 if hospst == "UT"
replace state =8 if hospst == "WA"

/*id番号作成*/
gen id=visitlink*10+state
format %16.0g id
recast double id
replace id=visitlink*10+state

/*主病名としてのasthma入院(asthma1)を定義*/
gen asthma1=1 if dx1=="49300" | dx1=="49301" | dx1=="49302" |dx1=="49310" | dx1=="49311" | dx1=="49312" |dx1=="49320" | dx1=="49321" | dx1=="49322"  |dx1=="49380" | dx1=="49381" |dx1=="49390" | dx1=="49391" | dx1=="49392" 

/*Index_hospitalizationの除外基準*/
gen exclusion=1 if dispuniform==2 | dispuniform==7 | died==1
replace exclusion=0 if exclusion==.

/*第一回目の基準入院index_hopitalizationを作る*/
gsort id -asthma1 daystoevent
bysort id: gen strokeadm_timeline =_n if asthma1==1
gen index_hospitalization=1 if strokeadm_timeline ==1 & exclusion==0
replace index_hospitalization=1 if strokeadm_timeline ==2 & exclusion==0 & exclusion[n-1]==1

/*intervalを計算　stroke==1かつn+1DTE - nDTE - nlos*/
sort id daystoevent
gen interval = daystoevent[_n+1] - daystoevent - los

/*各IDごとの最終イベントを欠損値に変換*/
gsort id -daystoevent
bysort id: gen inverse_timeline =_n
replace interval=. if inverse_timeline == 1

/*ID毎にstroke=1を先に持ってくるようにして、かつDTE順にもどし、IHの次のイベントがIHとなるケースを同定*/
gsort id daystoevent
replace index_hospitalization=1 if id==id[_n-1] & asthma1==1 & daystoevent-daystoevent[_n-1]-los[_n-1]>30 & index_hospitalization[_n-1]==1 & exclusion==0

/*第一回目入院基準の２つ次のイベントがIHとなるケースを同定*/
replace index_hospitalization=1 if id==id[_n-2] & asthma1==1 & daystoevent-daystoevent[_n-2]-los[_n-2]>30 & index_hospitalization[_n-2]==1 & index_hospitalization[_n-1]==. & exclusion==0

/*第一回目入院基準の３つ次のイベントがIHとなるケースを同定*/
replace index_hospitalization=1 if id==id[_n-3] & asthma1==1 & daystoevent-daystoevent[_n-3]-los[_n-3]>30 & index_hospitalization[_n-3]==1 & index_hospitalization[_n-1]==. & index_hospitalization[_n-2]==. & exclusion==0

/*第一回目入院基準の４つ次のイベントがIHとなるケースを同定*/
replace index_hospitalization=1 if id==id[_n-4] & asthma1==1 & daystoevent-daystoevent[_n-4]-los[_n-4]>30 & index_hospitalization[_n-4]==1 & index_hospitalization[_n-1]==. & index_hospitalization[_n-2]==. & index_hospitalization[_n-3]==. & exclusion==0

/*第一回目入院基準の５つ次のイベントがIHとなるケースを同定*/
replace index_hospitalization=1 if id==id[_n-5] & asthma1==1 & daystoevent-daystoevent[_n-5]-los[_n-5]>30 & index_hospitalization[_n-5]==1 & index_hospitalization[_n-1]==. & index_hospitalization[_n-2]==. & index_hospitalization[_n-3]==. & index_hospitalization[_n-4]==. & exclusion==0

/*第一回目入院基準の６つ次のイベントがIHとなるケースを同定*/
replace index_hospitalization=1 if id==id[_n-6] & asthma1==1 & daystoevent-daystoevent[_n-6]-los[_n-6]>30 & index_hospitalization[_n-6]==1 & index_hospitalization[_n-1]==. & index_hospitalization[_n-2]==. & index_hospitalization[_n-3]==. & index_hospitalization[_n-4]==. & index_hospitalization[_n-5]==. & exclusion==0

/*第一回目入院基準の７つ次のイベントがIHとなるケースを同定*/
replace index_hospitalization=1 if id==id[_n-7] & asthma1==1 & daystoevent-daystoevent[_n-7]-los[_n-7]>30 & index_hospitalization[_n-7]==1 & index_hospitalization[_n-1]==. & index_hospitalization[_n-2]==. & index_hospitalization[_n-3]==. & index_hospitalization[_n-4]==. & index_hospitalization[_n-5]==. & index_hospitalization[_n-6]==. & exclusion==0

/*第一回目入院基準の８つ次のイベントがIHとなるケースを同定*/
replace index_hospitalization=1 if id==id[_n-8] & asthma1==1 & daystoevent-daystoevent[_n-8]-los[_n-8]>30 & index_hospitalization[_n-8]==1 & index_hospitalization[_n-1]==. & index_hospitalization[_n-2]==. & index_hospitalization[_n-3]==. & index_hospitalization[_n-4]==. & index_hospitalization[_n-5]==. & index_hospitalization[_n-6]==. & index_hospitalization[_n-7]==. & exclusion==0

/*第一回目入院基準の９つ次のイベントがIHとなるケースを同定*/
replace index_hospitalization=1 if id==id[_n-9] & asthma1==1 & daystoevent-daystoevent[_n-9]-los[_n-9]>30 & index_hospitalization[_n-9]==1 & index_hospitalization[_n-1]==. & index_hospitalization[_n-2]==. & index_hospitalization[_n-3]==. & index_hospitalization[_n-4]==. & index_hospitalization[_n-5]==. & index_hospitalization[_n-6]==. & index_hospitalization[_n-7]==. & index_hospitalization[_n-8]==. & exclusion==0

/*index_hospitalizatin=0をつくる*/
replace index_hospitalization=0 if index_hospitalization==.

/*12月入院もindex_hospitalizatin=0にする*/
replace index_hospitalization=0 if unabletoanalyze==1

/*index時点で55歳以上の人を除外*/
replace index_hospitalization=0 if age>=55


/*Readmissionを同定*/
gsort id daystoevent
gen readmission=1 if id==id[_n-1] & daystoevent-daystoevent[_n-1]-los[_n-1]<31 & daystoevent-daystoevent[_n-1]-los[_n-1]>=0 & index_hospitalization[_n-1]==1 & index_hospitalization==0
replace readmission=0 if readmission==.

/*readm_hospを作成。各index_hospitalizationにreadmissionがあるかないか*/
gen readm_hosp=1 if index_hospitalization==1 & readmission[_n+1]==1
replace readm_hosp=0 if index_hospitalization==1 & readmission[_n+1]==0

/*55歳以上の人は落とす。index時点で55歳以上の人を除外　index_hospitalzation*/
drop if age>=55


/* 年齢2区分　agecat(<40, >=40)*/
gen agecat=1 if age<40
replace agecat=2 if age>=40

/*Age10つくる*/
gen age10=1 if age<20
replace age10=2 if age>=20 & age<30
replace age10=3 if age>=30 & age<40
replace age10=4 if age>=40 & age<50
replace age10=5 if age>=50 & age<60

/*race category*/
gen racecat=1 if race==1
replace racecat=2 if race==2
replace racecat=3 if race==3
replace racecat=4 if race==4 |race==5 |race==6 |race==9

/*metro, nonmetro*/
gen metro=1 if pl_ur_cat4==1
replace metro=1 if pl_ur_cat4==2
replace metro=0 if pl_ur_cat4==3
replace metro=0 if pl_ur_cat4==4


/*Elixhauser*/
elixhauser dx1-dx31, index(e),

/*obesity*/
gen obesity=1 if dx1=="27800" | dx1=="27801" | dx1=="V8530" | dx1=="V8531" | dx1=="V8532" | dx1=="V8533" | dx1=="V8534" | dx1=="V8535" | dx1=="V8536" | dx1=="V8537" | dx1=="V8538" | dx1=="V8539" | dx1=="V8541" | dx1=="V8542" | dx1=="V8543" | dx1=="V8544" | dx1=="V8545"  
forvalues k = 2/31 {
	replace obesity=1 if dx`k'=="27800" | dx`k'=="27801"  | dx`k'=="V8530" | dx`k'=="V8531" | dx`k'=="V8532" | dx`k'=="V8533" | dx`k'=="V8534" | dx`k'=="V8535" | dx`k'=="V8536" | dx`k'=="V8537" | dx`k'=="V8538" | dx`k'=="V8539" | dx`k'=="V8541" | dx`k'=="V8542" | dx`k'=="V8543" | dx`k'=="V8544" | dx`k'=="V8545" 
}	
replace obesity=0 if obesity==.

/*OSAS*/
gen osas=1 if dx1=="32723" | dx1=="78053" | dx1=="78057"
forvalues k = 2/31 {
        replace osas=1 if dx`k'=="32723" | dx`k'=="78053" | dx`k'=="78057"
}
replace osas=0 if osas==.


/*以下Readmission rate解析*/
drop if readm_hosp==.

/*Readmission rate 確認*/
tab readm_hosp osas, col
by agecat, sort: tab readm_hosp osas, col
by female, sort: tab readm_hosp osas, col


/*GEE*/
xtset id
xtgee readm_hosp osas, family(binomial 1) link(logit) corr(exchangeable) eform
xtgee readm_hosp osas i.age10 female i.racecat i.pay1 i.medincstq metro i.state weightel1 weightel2 weightel3 weightel4 weightel5 weightel6 weightel7 weightel8 weightel10 weightel11 weightel12 weightel13 weightel14 weightel15 weightel16 weightel17 weightel18 weightel19 weightel20 weightel21 weightel22 weightel23 weightel24 weightel25 weightel26 weightel27 weightel28 weightel29 weightel30 weightel31, family(binomial 1) link(logit) corr(exchangeable) eform

by agecat, sort: xtgee readm_hosp osas, family(binomial 1) link(logit) corr(exchangeable) eform
by agecat, sort: xtgee readm_hosp osas female i.racecat i.pay1 i.medincstq metro i.state weightel1 weightel2 weightel3 weightel4 weightel5 weightel6 weightel7 weightel8 weightel10 weightel11 weightel12 weightel13 weightel14 weightel15 weightel16 weightel17 weightel18 weightel19 weightel20 weightel21 weightel22 weightel23 weightel24 weightel25 weightel26 weightel27 weightel28 weightel29 weightel30 weightel31, family(binomial 1) link(logit) corr(exchangeable) eform

by female, sort: xtgee readm_hosp osas, family(binomial 1) link(logit) corr(exchangeable) eform
by female, sort: xtgee readm_hosp osas i.age10 i.racecat i.pay1 i.medincstq metro i.state weightel1 weightel2 weightel3 weightel4 weightel5 weightel6 weightel7 weightel8 weightel10 weightel11 weightel12 weightel13 weightel14 weightel15 weightel16 weightel17 weightel18 weightel19 weightel20 weightel21 weightel22 weightel23 weightel24 weightel25 weightel26 weightel27 weightel28 weightel29 weightel30 weightel31, family(binomial 1) link(logit) corr(exchangeable) eform

