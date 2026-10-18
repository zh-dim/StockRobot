function createtable()
	rowmassive['Si']={}
	rowmassive['Si'].row=InsertRow(t_id, -1)
	func.yellow (t_id,rowmassive['Si'].row)	
	
	--rowmassive['CN']={}
	--rowmassive['CN'].row=InsertRow(t_id, -1)
	--func.yellow (t_id,rowmassive['CN'].row)
	
	--for key,value in pairs(tool) do
	--	rowmassive[key..value.seccode1.seccode]={}
	--	rowmassive[key..value.seccode1.seccode].row=InsertRow(t_id, -1)
	--	rowmassive[key..value.seccode2.seccode]={}
	--	rowmassive[key..value.seccode2.seccode].row=InsertRow(t_id, -1)
	--	rowmassive[key.."Delta1"]={}
	--	rowmassive[key.."Delta1"].row=InsertRow(t_id, -1)
	--	rowmassive[key..value.seccode3.seccode]={}
	--	rowmassive[key..value.seccode3.seccode].row=InsertRow(t_id, -1)
	--	rowmassive[key.."Delta2"]={}
	--	rowmassive[key.."Delta2"].row=InsertRow(t_id, -1)
	--end
	
	--rowmassive['portfolioinfo']={}
	--rowmassive['portfolioinfo'].row=InsertRow(t_id, -1)
end

		--tool['USDRUBF'].seccode3.preffix='Si3'	
		--tool['EuH4'].seccode3.preffix='Eu3'	
		--tool['SiH4'].seccode3.preffix='Si3'		
		--tool['EURRUBF'].seccode3.preffix='Eu3'	
		--tool['CRH4'].seccode3.preffix='CN3'	
		--tool['CNYRUBF'].seccode3.preffix='CN3'	
		
		--tool['USDRUBF'].preffix=tool['USDRUBF'].seccode1.preffix		
		--tool['EuH4'].preffix=tool['EuH4'].seccode1.preffix	
		--tool['SiH4'].preffix=tool['SiH4'].seccode1.preffix		
		--tool['EURRUBF'].preffix=tool['EURRUBF'].seccode1.preffix	
		--tool['CRH4'].preffix=tool['CRH4'].seccode1.preffix	
		--tool['CNYRUBF'].preffix=tool['CNYRUBF'].seccode1.preffix
		--
		--tool['USDRUBF'].preffix2=tool['USDRUBF'].seccode2.preffix		
		--tool['EuH4'].preffix2=tool['EuH4'].seccode2.preffix	
		--tool['SiH4'].preffix2=tool['SiH4'].seccode2.preffix		
		--tool['EURRUBF'].preffix2=tool['EURRUBF'].seccode2.preffix	
		--tool['CRH4'].preffix2=tool['CRH4'].seccode2.preffix	
		--tool['CNYRUBF'].preffix2=tool['CNYRUBF'].seccode2.preffix
		--
		--tool['USDRUBF'].seccode1.preffix='Si4'	
		--tool['EuH4'].seccode1.preffix='Eu'	
		--tool['SiH4'].seccode1.preffix='Si'		
		--tool['EURRUBF'].seccode1.preffix='Eu4'	
		--tool['CRH4'].seccode1.preffix='CN'	
		--tool['CNYRUBF'].seccode1.preffix='CN4'			
		--
		--tool['USDRUBF'].seccode2.preffix='Si1'	
		--tool['EuH4'].seccode2.preffix='Eu2'	
		--tool['SiH4'].seccode2.preffix='Si2'		
		--tool['EURRUBF'].seccode2.preffix='Eu1'	
		--tool['CRH4'].seccode2.preffix='CN2'	
		--tool['CNYRUBF'].seccode2.preffix='CN1'			

		--tool['USDRUBF'].seccode1.TranVol=1
		--tool['EuH4'].seccode1.TranVol=1	
		--tool['SiH4'].seccode1.TranVol=1	
		--tool['EURRUBF'].seccode1.TranVol=1
		--tool['CRH4'].seccode1.TranVol=5	
		--tool['CNYRUBF'].seccode1.TranVol=5
		--tool['SiH4-2'].seccode1.TranVol=1	
		--
		--tool['USDRUBF'].seccode2.TranVol=1
		--tool['EuH4'].seccode2.TranVol=1
		--tool['SiH4'].seccode2.TranVol=1	
		--tool['EURRUBF'].seccode2.TranVol=1
		--tool['CRH4'].seccode2.TranVol=5	
        --tool['CNYRUBF'].seccode2.TranVol=5
		--tool['SiH4-2'].seccode2.TranVol=8	
		
				Options=tool['CRH4'].strategy202106
			
			Options.pos.one.vol=0
			Options.pos.two.vol=-100
			Options.pos.three.vol=0
			--
			--Options.pos.one.OldVol=0
			--Options.pos.two.OldVol=0
			--Options.pos.three.OldVol=0
	
			
			Options.pos.one.maxvol=10
			Options.pos.two.maxvol=10
			Options.pos.three.maxvol=0
	
			Options.pos.one.stepvol=10
			Options.pos.two.stepvol=10
			Options.pos.three.stepvol=10
			
			Options.pos.one.step=20
			Options.pos.two.step=20
			Options.pos.three.step=20	
			
		Options=tool['CNYRUBF'].strategy202106
			
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=0
			--
			--Options.pos.one.OldVol=0
			--Options.pos.two.OldVol=0
			--Options.pos.three.OldVol=0
	
			
			Options.pos.one.maxvol=10
			Options.pos.two.maxvol=10
			Options.pos.three.maxvol=0
	
			Options.pos.one.stepvol=10
			Options.pos.two.stepvol=10
			Options.pos.three.stepvol=10
			
			Options.pos.one.step=20
			Options.pos.two.step=20
			Options.pos.three.step=20
			
			
						
					--Options.pos.one.OldVol=Options.pos.one.vol
					--Options.pos.two.OldVol=Options.pos.two.vol
					--Options.pos.three.OldVol=Options.pos.three.vol
					--Options.pos.one.vol=0
					--Options.pos.two.vol=0
					--Options.pos.three.vol=0
					
					
function InitSeccode()

		Options=tool['SiM4'].strategy202106
			Options.pos.one.vol=1
			Options.pos.two.vol=1
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5--45
			Options.pos.two.maxvol=5--40
			Options.pos.three.maxvol=5--20
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40

		Options=tool['SiH4'].strategy202106
			Options.pos.one.vol=1
			Options.pos.two.vol=1
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5--45
			Options.pos.two.maxvol=5--40
			Options.pos.three.maxvol=5--20
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40

		Options=tool['USDRUBF-2'].strategy202106
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5--45
			Options.pos.two.maxvol=5--40
			Options.pos.three.maxvol=5--20
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40

		
		Options=tool['USDRUBF'].strategy202106
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=1000
			
			Options.pos.one.maxvol=10--45
			Options.pos.two.maxvol=10--40
			Options.pos.three.maxvol=30--20
	
			Options.pos.one.stepvol=10
			Options.pos.two.stepvol=10
			Options.pos.three.stepvol=10
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40

		Options=tool['EuH4'].strategy202106
			Options.pos.one.vol=1
			Options.pos.two.vol=1
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5
			Options.pos.two.maxvol=5
			Options.pos.three.maxvol=5
	
			Options.pos.one.stepvol=1
			Options.pos.two.stepvol=1
			Options.pos.three.stepvol=1
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40
		
		Options=tool['EURRUBF'].strategy202106
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=1000
			
			Options.pos.one.maxvol=5
			Options.pos.two.maxvol=5
			Options.pos.three.maxvol=20
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=10
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40	
						
		Options=tool['SiH4-2'].strategy202106
			Options.pos.one.vol=1
			Options.pos.two.vol=1
			Options.pos.three.vol=0
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=3--45
			Options.pos.two.maxvol=3--40
			Options.pos.three.maxvol=0--20
	
			Options.pos.one.stepvol=3
			Options.pos.two.stepvol=3
			Options.pos.three.stepvol=0
			
			Options.pos.one.step=130
			Options.pos.two.step=130
			Options.pos.three.step=100
		
		Options=tool['CRH4'].strategy202106
			
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=0
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5
			Options.pos.two.maxvol=5
			Options.pos.three.maxvol=5
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=20
			Options.pos.two.step=20
			Options.pos.three.step=20	
			
		Options=tool['CNYRUBF'].strategy202106
			
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=100
				
			Options.pos.one.maxvol=5
			Options.pos.two.maxvol=5
			Options.pos.three.maxvol=5
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=20
			Options.pos.two.step=20
			Options.pos.three.step=20
	
end

for key,value in pairs(tool) do			
		
		Options=value.strategy202106
		toolset[key]={}
		toolset[key].one={}
		toolset[key].two={}
		toolset[key].three={}
		setting=toolset[key]
		
		setting.one.vol=             Options.pos.one.vol
		setting.two.vol=             Options.pos.two.vol
		setting.three.vol=           Options.pos.three.vol
		                               
		setting.one.minProffit=      Options.pos.one.minProffit
		setting.two.minProffit=      Options.pos.two.minProffit
		setting.three.minProffit=    Options.pos.three.minProffit
		                               
		setting.one.maxvol=		     Options.pos.one.maxvol
		setting.two.maxvol=		     Options.pos.two.maxvol
		setting.three.maxvol=		 Options.pos.three.maxvol
		                               
		setting.one.stepvol=         Options.pos.one.stepvol
		setting.two.stepvol=         Options.pos.two.stepvol
		setting.three.stepvol=       Options.pos.three.stepvol
		                               
		setting.one.step=            Options.pos.one.step
		setting.two.step=            Options.pos.two.step
		setting.three.step=          Options.pos.three.step
	end
	func.savetable(toolset,ToolSetPath)
	ToLog ("скрипт остановлен")
	
	robot.InitSeccode()


			Options.pos.one.vol=1
			Options.pos.two.vol=1
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5--45
			Options.pos.two.maxvol=5--40
			Options.pos.three.maxvol=5--20
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40


		Options=tool['SiM4'].strategy202106
			Options.pos.one.vol=1
			Options.pos.two.vol=1
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5--45
			Options.pos.two.maxvol=5--40
			Options.pos.three.maxvol=5--20
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40

		Options=tool['SiH4'].strategy202106
			Options.pos.one.vol=1
			Options.pos.two.vol=1
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5--45
			Options.pos.two.maxvol=5--40
			Options.pos.three.maxvol=5--20
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40

		Options=tool['USDRUBF-2'].strategy202106
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5--45
			Options.pos.two.maxvol=5--40
			Options.pos.three.maxvol=5--20
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40

		
		Options=tool['USDRUBF'].strategy202106
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=1000
			
			Options.pos.one.maxvol=10--45
			Options.pos.two.maxvol=10--40
			Options.pos.three.maxvol=30--20
	
			Options.pos.one.stepvol=10
			Options.pos.two.stepvol=10
			Options.pos.three.stepvol=10
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40

		Options=tool['EuM4'].strategy202106
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=0
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5
			Options.pos.two.maxvol=5
			Options.pos.three.maxvol=5
	
			Options.pos.one.stepvol=1
			Options.pos.two.stepvol=1
			Options.pos.three.stepvol=1
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40

		Options=tool['EuH4'].strategy202106
			Options.pos.one.vol=1
			Options.pos.two.vol=1
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5
			Options.pos.two.maxvol=5
			Options.pos.three.maxvol=5
	
			Options.pos.one.stepvol=1
			Options.pos.two.stepvol=1
			Options.pos.three.stepvol=1
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40

		Options=tool['EURRUBF-2'].strategy202106
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=0
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5
			Options.pos.two.maxvol=5
			Options.pos.three.maxvol=5
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40
		
		Options=tool['EURRUBF'].strategy202106
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5
			Options.pos.two.maxvol=5
			Options.pos.three.maxvol=5
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40	
						
		Options=tool['SiH4-2'].strategy202106
			Options.pos.one.vol=1
			Options.pos.two.vol=1
			Options.pos.three.vol=0
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=3--45
			Options.pos.two.maxvol=3--40
			Options.pos.three.maxvol=0--20
	
			Options.pos.one.stepvol=3
			Options.pos.two.stepvol=3
			Options.pos.three.stepvol=0
			
			Options.pos.one.step=130
			Options.pos.two.step=130
			Options.pos.three.step=100
		
		Options=tool['CRH4'].strategy202106
			
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=0
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=5
			Options.pos.two.maxvol=5
			Options.pos.three.maxvol=5
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=20
			Options.pos.two.step=20
			Options.pos.three.step=20	
			
		Options=tool['CNYRUBF'].strategy202106
			
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=1
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=100
				
			Options.pos.one.maxvol=5
			Options.pos.two.maxvol=5
			Options.pos.three.maxvol=5
	
			Options.pos.one.stepvol=5
			Options.pos.two.stepvol=5
			Options.pos.three.stepvol=5
			
			Options.pos.one.step=20
			Options.pos.two.step=20
			Options.pos.three.step=20
		
		Options=tool['SRH4'].strategy202106
			
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=0
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=3
			Options.pos.two.maxvol=3
			Options.pos.three.maxvol=3
	
			Options.pos.one.stepvol=3
			Options.pos.two.stepvol=3
			Options.pos.three.stepvol=3
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40	
	
		Options=tool['SRM4'].strategy202106
			
			Options.pos.one.vol=0
			Options.pos.two.vol=0
			Options.pos.three.vol=0
			
			Options.pos.one.minProffit=50
			Options.pos.two.minProffit=50
			Options.pos.three.minProffit=50
			
			Options.pos.one.maxvol=3
			Options.pos.two.maxvol=3
			Options.pos.three.maxvol=3
	
			Options.pos.one.stepvol=3
			Options.pos.two.stepvol=3
			Options.pos.three.stepvol=3
			
			Options.pos.one.step=40
			Options.pos.two.step=40
			Options.pos.three.step=40
			
			
				if Options.pos.one.Operation=='short' and sumTotalVol~=0 then --and sumOldVol==0 then 
					ChangeMemoryTrend_Arb(value)
					Options.pos.two.Operation=Options.pos.one.Operation 
					--Options.pos.three.Operation=Options.pos.one.Operation	
					Options.pos.one.Operation='long' 	
					func.inTable (tt1, 'StockRobot 602: смена тренда ' ..key)
				elseif Options.pos.one.Operation=='long' and sumVol==0 and sumOldVol~=0 then 
					func.inTable (tt1, 'StockRobot 610: отмена смены тренда ' ..key)
					Options.pos.one.vol=Options.pos.one.OldVol
					Options.pos.two.vol=Options.pos.two.OldVol
					--Options.pos.three.vol=Options.pos.three.OldVol
					Options.pos.one.OldVol=0
					Options.pos.two.OldVol=0
					--Options.pos.three.OldVol=0
				end	

				if sumOldVol~=0 then --условие смены тренда
					func.red (t_id,rowmassive[key..'Delta1'].row,4)
				else
					func.gray (t_id,rowmassive[key..'Delta1'].row,4)
				end			


local a = {
   [1]={
      ['price']=2641.2,
      ['pos']='two',
      ['vol']=0,
      ['operation']='S',
      ['vol_old']=0,
      ['seccode']='MMZ4',
      ['key']='IMOEXF-MMZ'
   },
   [2]={
      ['price']=2681.11,
      ['pos']='two',
      ['vol']=0,
      ['operation']='S',
      ['vol_old']=0,
      ['seccode']='IMOEXF',
      ['key']='IMOEXF-MMZ'
   },
   [3]={
      ['price']=2769,
      ['pos']='three',
      ['vol']=0,
      ['operation']='B',
      ['vol_old']=0,
      ['seccode']='MMH5',
      ['key']='MMZ4'
   },
   [4]={
      ['price']=9366.72,
      ['pos']='three',
      ['vol']=0,
      ['operation']='B',
      ['vol_old']=150,
      ['seccode']='GLH5',
      ['key']='GLDRUBF-2'
   },
   [5]={
      ['price']=8569.2101818182,
      ['pos']='two',
      ['vol']=0,
      ['operation']='S',
      ['vol_old']=0,
      ['seccode']='GLZ4',
      ['key']='GLDRUBF-GLZ'
   },
   [6]={
      ['price']=8913,
      ['pos']='three',
      ['vol']=0,
      ['operation']='S',
      ['vol_old']=0,
      ['seccode']='GLZ4',
      ['key']='GLZ4'
   },
   [7]={
      ['price']=8923,
      ['pos']='three',
      ['vol']=0,
      ['operation']='B',
      ['vol_old']=0,
      ['seccode']='GLZ4',
      ['key']='GLZ4'
   },
   [8]={
      ['price']=2567,
      ['pos']='three',
      ['vol']=0,
      ['operation']='S',
      ['vol_old']=0,
      ['seccode']='MMZ4',
      ['key']='IMOEXF-MMZ'
   },
   [9]={
      ['price']=2567,
      ['pos']='three',
      ['vol']=0,
      ['operation']='B',
      ['vol_old']=0,
      ['seccode']='IMOEXF',
      ['key']='IMOEXF-MMZ'
   },
   [10]={
      ['price']=116.91,
      ['pos']='three',
      ['vol']=0,
      ['operation']='S',
      ['vol_old']=0,
      ['seccode']='GAZPF',
      ['key']='GAZPF-GZH5'
   },
   [11]={
      ['price']=12533,
      ['pos']='three',
      ['vol']=0,
      ['operation']='B',
      ['vol_old']=0,
      ['seccode']='GZH5',
      ['key']='GAZPF-GZH5'
   },
   [12]={
      ['price']=228.62,
      ['pos']='three',
      ['vol']=0,
      ['operation']='S',
      ['vol_old']=0,
      ['seccode']='SBERF',
      ['key']='SBERF-SRH5'
   },
   [13]={
      ['price']=24493,
      ['pos']='three',
      ['vol']=0,
      ['operation']='B',
      ['vol_old']=0,
      ['seccode']='SRH5',
      ['key']='SBERF-SRH5'
   }
}
return a

,
   [3]={
      ['vol']=0,
      ['key']='MMZ4',
      ['seccode']='MMH5',
      ['pos']='three',
      ['vol_old']=0,
      ['operation']='B',
      ['price']=2769
   },
   [4]={
      ['vol']=0,
      ['key']='GLDRUBF-2',
      ['seccode']='GLH5',
      ['pos']='three',
      ['vol_old']=0,
      ['operation']='B',
      ['price']=9366.72
   },
   [5]={
      ['vol']=0,
      ['key']='GLDRUBF-GLZ',
      ['seccode']='GLZ4',
      ['pos']='two',
      ['vol_old']=0,
      ['operation']='S',
      ['price']=8569.2101818182
   },
   [6]={
      ['vol']=0,
      ['key']='GLZ4',
      ['seccode']='GLZ4',
      ['pos']='three',
      ['vol_old']=0,
      ['operation']='S',
      ['price']=8913
   },
   [7]={
      ['vol']=0,
      ['key']='GLZ4',
      ['seccode']='GLH5',
      ['pos']='three',
      ['vol_old']=50,
      ['operation']='B',
      ['price']=9490
   },
   [8]={
      ['vol']=0,
      ['key']='IMOEXF-MMZ',
      ['seccode']='MMZ4',
      ['pos']='three',
      ['vol_old']=0,
      ['operation']='S',
      ['price']=2567
   },
   [9]={
      ['vol']=0,
      ['key']='IMOEXF-MMZ',
      ['seccode']='IMOEXF',
      ['pos']='three',
      ['vol_old']=0,
      ['operation']='B',
      ['price']=2567
   },
   [10]={
      ['vol']=0,
      ['key']='GAZPF-GZH5',
      ['seccode']='GAZPF',
      ['pos']='three',
      ['vol_old']=0,
      ['operation']='S',
      ['price']=116.91
   },
   [11]={
      ['vol']=0,
      ['key']='GAZPF-GZH5',
      ['seccode']='GZH5',
      ['pos']='three',
      ['vol_old']=0,
      ['operation']='B',
      ['price']=12533
   },
   [12]={
      ['vol']=0,
      ['key']='SBERF-SRH5',
      ['seccode']='SBERF',
      ['pos']='three',
      ['vol_old']=0,
      ['operation']='S',
      ['price']=228.62
   },
   [13]={
      ['vol']=0,
      ['key']='SBERF-SRH5',
      ['seccode']='SRH5',
      ['pos']='three',
      ['vol_old']=0,
      ['operation']='B',
      ['price']=24493
   }