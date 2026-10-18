require("func")
require("robot")
stopped = false

function OnStop(s)
	stopped = true
	return 5000
end

function OnGraf(place,operation,comment)
	if place ==nil then place=PRICE end
	--func.place_label("price"..'m30'..preffix, place, datetime,tostring(operation),1,comment) 
	func.place_label('ggg', place, datetime,tostring(operation),1,comment) 
end

function dell0(number)
	if number==0 then return ''
	else return tostring(number)
	end
end

function dellnil(number)
	if number==nil then return 0
	else return number
	end
end

function CheckOperation()
	--Выполнение операций
	for number,pos in pairs(Options.pos) do
		if pos.total.vol>0 and pos.Operation=='long' and PriceLow<=pos.StopPrice then
			pos.total.vol=0
			pos.total.profit=pos.total.profit+(PriceLow-pos.total.OpenPrice)
			log ('Stop',pos,number,PriceLow)
			pos.total.OpenPrice=0
		elseif pos.total.vol>0 and pos.Operation=='short' and Pricehigh>=pos.StopPrice then
			pos.total.vol=0
			pos.total.profit=pos.total.profit+(pos.total.OpenPrice-Pricehigh)
			log ('Stop',pos,number,Pricehigh)
			pos.total.OpenPrice=0
		elseif pos.total.vol>0 and pos.ClosePos2 then
			if pos.Operation=='long' then
				pos.total.vol=0
				pos.total.profit=pos.total.profit+(Pricehigh-pos.total.OpenPrice)
				log ('Close',pos,number,Pricehigh)
				pos.total.OpenPrice=0
			elseif pos.Operation=='short' then
				pos.total.vol=0
				pos.total.profit=pos.total.profit+(pos.total.OpenPrice-PriceLow)
				log ('Close',pos,number,PriceLow)
				pos.total.OpenPrice=0
			end
		elseif pos.RiskControl>=3 and pos.total.vol==0 and pos.OpenPos then
			pos.total.vol=1
			pos.total.OpenPrice=PRICE
			log ('Open',pos,number)
		end
	end
end

function closetrade(type)
	local proffit = func.round (func.correctsum (seccode,memory.sell[tframe].vol*memory.sell[tframe].price-memory.buy[tframe].vol*memory.buy[tframe].price))
	
	if type=="restore" or type=="best" or type=="step" then 
		if string.sub(tframe,1,3)=='one' then 
			Options.pos.one.total.proffit=proffit
			robot.TradeRec('one',type)
		elseif string.sub(tframe,1,3)=='two' then 
			Options.pos.two.total.proffit=proffit
			robot.TradeRec('two',type)
		elseif string.sub(tframe,1,5)=='three' then 
			Options.pos.three.total.proffit=proffit
			robot.TradeRec('three',type)
		end
	end
	
	memory.buy[tframe].tool=seccode
	memory.buy[tframe].n=0
	memory.buy[tframe].vol=0
	memory.buy[tframe].price=0
	memory.buy[tframe].lastprice=0
	memory.buy[tframe].closetrade='false'
	memory.buy[tframe].firstdate=0
	memory.buy[tframe].frommemory='false'
	memory.buy[tframe].MaxRiskPrice=0
	memory.buy[tframe].TakeProfit=0
	memory.buy[tframe].stop=''
	memory.buy[tframe].stopvol=0
	memory.buy[tframe].stopprice=0
	
	memory.sell[tframe].tool=seccode
	memory.sell[tframe].n=0
	memory.sell[tframe].vol=0
	memory.sell[tframe].price=0
	memory.sell[tframe].lastprice=0
	memory.sell[tframe].closetrade='false'
	memory.sell[tframe].firstdate=0
	memory.sell[tframe].frommemory='false'
	memory.sell[tframe].MaxRiskPrice=0
	memory.sell[tframe].TakeProfit=0
	memory.sell[tframe].stop=''
	memory.sell[tframe].stopvol=0
	memory.sell[tframe].stopprice=0		
	
end

function transaction(mem,bs,trend)
	
	mem[tframe].tool=seccode
	mem[tframe].n=0
	mem[tframe].vol=vol
	mem[tframe].price=PRICE
		
	if memory.buy[tframe].vol==memory.sell[tframe].vol and memory.sell[tframe].vol>0 then -- если сделка закрыта, то откладываем архив и обнуляем таблицу оперативной памяти
		--robot.closetrade (tframe,seccode,'operation',trend)
		closetrade()
	end
end

function CheckSO (tframe,seccode,value)
	if memory.sell[tframe].stop=='restore' and memory.sell[tframe].stopprice~=memory.buy[tframe].price	 then
		memory.sell[tframe].stopvol=memory.buy[tframe].vol
		memory.sell[tframe].stopprice=memory.buy[tframe].price	
		--func.inTable (tt1, 'restore stopprice '..memory.sell[tframe].stopprice .. ' price '..memory.buy[tframe].price)
	elseif memory.buy[tframe].stop=='restore' and memory.buy[tframe].stopprice~=memory.sell[tframe].price then
		memory.buy[tframe].stopvol=memory.sell[tframe].vol
		memory.buy[tframe].stopprice=memory.sell[tframe].price
		--func.inTable (tt1, 'restore stopprice '..memory.buy[tframe].stopprice .. ' price '..memory.sell[tframe].price)
	elseif memory.sell[tframe].stop=='best'  then
		memory.sell[tframe].stopvol=memory.buy[tframe].vol
		if StateTableM30.par.stop == "поддержка" and StateTableM30.par.par>memory.buy[tframe].price then 
			memory.sell[tframe].stopprice=StateTableM30.par.par
			memory.sell[tframe].stoptf='m30' 
		elseif memory.sell[tframe].stopprice<memory.buy[tframe].price	then 	
			memory.sell[tframe].stopprice=memory.buy[tframe].price	
		end	
		--func.inTable (tt1, 'Best stopprice '..memory.sell[tframe].stopprice .. ' price '..memory.buy[tframe].price)
	elseif memory.buy[tframe].stop=='best'  then
		memory.buy[tframe].stopvol=memory.sell[tframe].vol
		if StateTableM30.par.stop == "сопротивление" and StateTableM30.par.par<memory.sell[tframe].price then 
			memory.buy[tframe].stopprice=StateTableM30.par.par
			memory.buy[tframe].stoptf='m30' 
		elseif memory.buy[tframe].stopprice>memory.sell[tframe].price then
			memory.buy[tframe].stopprice=memory.sell[tframe].price
		end		
		--func.inTable (tt1, 'Best stopprice '..memory.buy[tframe].stopprice .. ' price '..memory.sell[tframe].price)
	end

	if memory.sell[tframe].stop~='' and memory.sell[tframe].stopprice~=0 and PRICE<=memory.sell[tframe].stopprice then
		memory.sell[tframe].vol=memory.buy[tframe].vol
		memory.sell[tframe].price=memory.sell[tframe].stopprice	
		closetrade(memory.sell[tframe].stop)
	elseif memory.buy[tframe].stop~='' and memory.buy[tframe].stopprice~=0 and PRICE>=memory.buy[tframe].stopprice then
		memory.buy[tframe].vol=memory.sell[tframe].vol
		memory.buy[tframe].price=memory.buy[tframe].stopprice
		closetrade(memory.buy[tframe].stop)
	end

end

function UpStop (pos)
	
	local ratio=tool[seccode]['strategy202106']['pos'][pos].ratio
	--ratio=MN
	local UpStop=StateTableM30.atr.LastMin+StateTableD.atr.atr2*ratio
	if ratio==0 then UpStop=0 end
	--message ('ratio '..ratio..' UpStop '.. UpStop)
	return UpStop
		
	--return StateTableD.atr.min+StateTableD.atr.atr2*MN
	
	--return DMinPrice+StateTableD.atr.atr2*MN
	
	--local UpStop=DMinPrice+StateTableD.atr.atr2*MN--1.2
	--
	--if DMaxPrice>UpStop then return DMaxPrice
	----if DMaxPrice*1.002<UpStop then return DMaxPrice*1.2
	--else return UpStop
	--end

end

function DownStop (pos)
	
	local ratio=tool[seccode]['strategy202106']['pos'][pos].ratio
	--ratio=MN
	local DownStop=StateTableM30.atr.LastMax-StateTableD.atr.atr2*ratio
	if ratio==0 then DownStop=1000000 end
	--message ('ratio '..ratio..' DownStop '.. DownStop)
	return DownStop
	
	--return StateTableD.atr.max-StateTableD.atr.atr2*MN
	
	--return DMaxPrice-StateTableD.atr.atr2*MN
	
	--local DownStop=DMaxPrice-StateTableD.atr.atr2*MN--1.2
	--
	--if DMinPrice<DownStop then return DMinPrice
	----if DMinPrice*0.998>DownStop then return DMinPrice*0.8
	--else return DownStop
	--end
end


function MoneyManagment(StopPrice,vol)
	return true
end

function CheckCicle_old()
	--========================================
	--Подсчитываем текущий результата по позициям
	robot.CalcPos(value)
	--========================================
	--проверяем условия для точки входа
	robot.CheckEnterSignal()
	--========================================
	--Проверяем условия для точки выхода
	robot.CheckExitSignal(value.preffix)
	--========================================
	--заполняем таблицу
	--setcell(value)
	--========================================
	--выполняем операции
	robot.OperationEngine(value)

	totalarisk=totalarisk+Options.risk
end

function DateTimeStr(datetime)

	return tostring(datetime.day)..'.'..tostring(datetime.month)..' '..tostring(datetime.hour)..'-'..tostring(datetime.min)

end

function CalcProfit(numb,atr)
	prof=0
	mult=atr*100
	for n=numb-2,0,-1 do 
		prof=prof+n*mult
	end
	return prof-mult
end

function CheckCicle_long(atr)
	
	if EnterPrice==0 then 
		EnterPrice=PriceHigh 
		Number=1
		OnGraf(EnterPrice,Number,EnterPrice..' long '..DateTimeStr(datetime).. ' '..datetime.hour..'-'..datetime.min)
		OnGraf(EnterPrice-atr,'***',EnterPrice-atr)
		--func.inTable (tt1, 'Вход '..  Number..' '..EnterPrice ..' ' .. DateTimeStr(datetime)..' ' ..PRICE .. ' '..PriceLow .. ' '..PriceHigh )
	end
	
	if EnterPrice>0 and PriceHigh>EnterPrice+atr then 
		EnterPrice=EnterPrice+atr 
		Number=Number+1
		OnGraf(EnterPrice,Number,EnterPrice)
		--func.inTable (tt1, 'Вход '..  Number..' '..EnterPrice ..' ' .. DateTimeStr(datetime)..' ' ..PRICE .. ' '..PriceLow .. ' '..PriceHigh )
	end
	
	if PriceLow<EnterPrice-atr then 
		OnGraf(EnterPrice-atr,'0',EnterPrice-atr)
		if Number<3 then 
			TOTAL=TOTAL-atr*100 
			TOTALONE=TOTALONE+1
			OnGraf(EnterPrice-atr,'-',CalcProfit(Number,atr))
		end
		if Number==3 then 
			TOTALTWO=TOTALTWO+1
			OnGraf(EnterPrice-atr,'0',CalcProfit(EnterPrice,atr))
		end
		if Number>3 then 
			TOTAL=TOTAL+CalcProfit(Number,atr) 
			TOTALThree=TOTALThree+1
			OnGraf(EnterPrice-atr,'+',CalcProfit(Number,atr))
		end		
		
		--func.inTable (tt1, 'Стоп из ' .. Number..' EnterPrice:'.. EnterPrice ..' ' .. DateTimeStr(datetime)..' Результат:'.. CalcProfit(Number,atr) ..' TOTAL:' ..TOTAL )
		EnterPrice=0
		Number=0
	end 

end

function CheckCicle_short(atr)
	
	if EnterPrice==0 then 
		EnterPrice=PriceLow 
		Number=1
		OnGraf(EnterPrice,Number,EnterPrice..' short '..DateTimeStr(datetime).. ' '..datetime.hour..'-'..datetime.min)
		OnGraf(EnterPrice+atr,'***',EnterPrice+atr)
		--func.inTable (tt1, 'Вход '..  Number..' '..EnterPrice ..' ' .. DateTimeStr(datetime)..' ' ..PRICE .. ' '..PriceLow .. ' '..PriceHigh )
	end
	
	if EnterPrice>0 and PriceLow<EnterPrice-atr then 
		EnterPrice=EnterPrice-atr 
		Number=Number+1
		OnGraf(EnterPrice,Number,EnterPrice)
		--func.inTable (tt1, 'Вход '..  Number..' '..EnterPrice ..' ' .. DateTimeStr(datetime)..' ' ..PRICE .. ' '..PriceLow .. ' '..PriceHigh )
	end
	
	if PriceHigh>EnterPrice+atr then 
		if Number<3 then 
			TOTAL=TOTAL-atr*100 
			TOTALONE=TOTALONE+1
			OnGraf(EnterPrice+atr,'000',CalcProfit(Number,atr))
		end
		if Number==3 then 
			TOTALTWO=TOTALTWO+1
			OnGraf(EnterPrice+atr,'0',CalcProfit(EnterPrice,atr))
		end
		if Number>3 then 
			TOTAL=TOTAL+CalcProfit(Number,atr) 
			TOTALThree=TOTALThree+1
			OnGraf(EnterPrice+atr,'+',CalcProfit(Number,atr))
		end		
		
		--func.inTable (tt1, 'Стоп из ' .. Number..' EnterPrice:'.. EnterPrice ..' ' .. DateTimeStr(datetime)..' Результат:'.. CalcProfit(Number,atr) ..' TOTAL:' ..TOTAL )
		EnterPrice=0
		Number=0
	end 

end

function CheckStrategy(seccode,preffix,atr,trend)
	--func.logtable()
	--value=tool[seccode]
	Options={}
	Options['pos']={}
    Options['pos']['one']={}
    Options['pos']['two']={}
    Options['pos']['three']={}

	--Options['pos']['one']['vol']=value.strategy202106['VolDefault']
    --Options['pos']['two']['vol']=value.strategy202106['VolDefault']
    --Options['pos']['three']['vol']=value.strategy202106['VolDefault']
	
	Options['pos']['one']['total']={}
    Options['pos']['one']['total'].vol=0
	Options['pos']['one']['total'].profit=0
	Options['pos']['two']['total']={}
    Options['pos']['two']['total'].vol=0
    Options['pos']['two']['total'].profit=0
	Options['pos']['three']['total']={}	
	Options['pos']['three']['total'].vol=0
    Options['pos']['three']['total'].profit=0
	
	tf=preffix
	--tool[seccode]['RiscCapitalTf']['one'..tf]={} 
	--tool[seccode]['RiscCapitalTf']['one'..tf].proffit=0
	--tool[seccode]['RiscCapitalTf']['one'..tf].bar=0
	--tool[seccode]['RiscCapitalTf']['two'..tf]={} 
	--tool[seccode]['RiscCapitalTf']['two'..tf].proffit=0
	--tool[seccode]['RiscCapitalTf']['two'..tf].bar=0
	--tool[seccode]['RiscCapitalTf']['three'..tf]={} 
	--tool[seccode]['RiscCapitalTf']['three'..tf].proffit=0
	--tool[seccode]['RiscCapitalTf']['three'..tf].bar=0
	
	EnterPrice=0
	B=0
	TOTAL=0
	TOTALONE=0
	TOTALTWO=0
	TOTALThree=0
	StateTableD={}
	PRICE=0
	ProfitPrice=0
	rowmassive={}
	TotalRiskMemory=0
	DayProfit=0
	ProfitOne=0
	ProfitTwo=0
	ProfitThree=0
	CHECK=true
	local LastBarD=1
	DMinPrice=100000000
	DMaxPrice=0
	
	if memory==nil then 
		robot.memoryinit ('one'..preffix,'d')
		robot.memoryinit ('two'..preffix,'d')
		robot.memoryinit ('three'..preffix,'d')
	end
	
	Bars={}
	BarTableCreate(preffix)
	timePeriod='m1'
	
	local barnum=getNumCandles("price"..timePeriod..preffix)
	local price, BarNprice, toolprice = getCandlesByIndex ("price"..timePeriod..preffix, 0, 0, barnum);
	DelAllLabels("price"..timePeriod..preffix)
		DelAllLabels("ggg")
	local i=barnum-5000 --barnum-2244--func.round(barnum*0.8)--barnum-40 --func.round(barnum*0.6)--1 день это 34 свечи m30. Месяц - это ~748 свечей
	if i<0 then i=150 end
	
	InsertRow(tt1,-1)

	func.inTable (tt1, DateTimeStr(price[i].datetime))
	while i < barnum-1 do 
		B=i
		ProfitPrice=0
		TotalRiskMemory=0
		DayProfit=0
		totalarisk=0
			PRICE=price[i].close
			PriceLow=price[i].low
			Pricehigh=price[i].high
			PriceOpen=price[i].open
			datetime=price[i].datetime
			
			
			--StateTableM30=robot.StateCapture (seccode,timePeriod,preffix,'close',i-1,datetime)
			--
			--if BarD~=nil then LastBarD=BarD end
			--if Bars[datetime.year][robot.PrevMonth(datetime)][robot.PrevDay(datetime)]~=nil then 
			--	BarD=Bars[datetime.year][robot.PrevMonth(datetime)][robot.PrevDay(datetime)][0][0]['d']['bar']
			--else 
			--	BarD=LastBarD+1 
			--	Bars[datetime.year][robot.PrevMonth(datetime)][robot.PrevDay(datetime)]={}
			--	Bars[datetime.year][robot.PrevMonth(datetime)][robot.PrevDay(datetime)][0]={}
			--	Bars[datetime.year][robot.PrevMonth(datetime)][robot.PrevDay(datetime)][0][0]={}
			--	Bars[datetime.year][robot.PrevMonth(datetime)][robot.PrevDay(datetime)][0][0]['d']={}
			--	Bars[datetime.year][robot.PrevMonth(datetime)][robot.PrevDay(datetime)][0][0]['d']['bar']=BarD
			--end
			----func.inTable (tt1, 'BardD '..BarD..' M30datetime ' .. datetime.month .. '-'.. datetime.day..' '..datetime.hour..':'..datetime.min..' ' ..price[i].low)
			--
			--SetCell(tt1, 1, 1, TestName..' ' ..seccode .. ' BardD '..BarD..' M30datetime ' .. datetime.month .. '-'.. datetime.day..' '..datetime.hour..':'..datetime.min..' PRICE:'..PRICE)
			--StateTableD=robot.StateCapture (seccode,'d',preffix,'close',BarD+1,datetime)
			----Options.trend=StateTableD.ich.trend
			--
			--if datetime.hour==9 and datetime.min==0 then 
			--	DMinPrice=100000000
			--	DMaxPrice=0
			--	--func.inTable (tt1, seccode ..'сброс DMinPrice и DMaxPrice '..' M30datetime ' .. datetime.month .. '-'.. datetime.day..' '..datetime.hour..':'..datetime.min)
			--end
			
			if price[i].low<DMinPrice then DMinPrice=price[i].low end
			if price[i].high>DMaxPrice then DMaxPrice=price[i].high end
						
			local PriceStep = tonumber(getParamEx('SPBFUT', seccode, "SEC_PRICE_STEP").param_value)
			PRICE=price[i].open
			PriceLow=price[i].low
			PriceHigh=price[i].high
			
			func.inTable (tt1, 'ich '.. ' PRICE ' .. PRICE .. ' '.. DateTimeStr(datetime))
			
			--if EnterPrice==0 and StateTableM30.ich.trend=='long' then CheckCicle_long(atr) 
			--elseif EnterPrice==0 and StateTableM30.ich.trend=='short' then CheckCicle_short(atr) 
			--elseif lasttrend=='short' and StateTableM30.ich.trend=='short' then CheckCicle_short(atr) 
			--elseif lasttrend=='long' and StateTableM30.ich.trend=='short' then CheckCicle_long(atr) end
			--
			--if StateTableM30.ich.trend=='long' or StateTableM30.ich.trend=='short' then lasttrend= StateTableM30.ich.trend end
			
			--условие задает порядок прохождения  мин и макс в зависимости от того падающая или растущая свеча
			
			--if price[i].open<price[i].close then 
			--	while PRICE>=price[i].low do
			--		CheckCicle()
			--		PRICE=PRICE-PriceStep
			--	end
			--	PRICE=price[i].open+PriceStep
			--	while PRICE<=price[i].high do
			--		CheckCicle()
			--		PRICE=PRICE+PriceStep
			--	end
			--else
			--	while PRICE<=price[i].high do
			--		CheckCicle()
			--		PRICE=PRICE+PriceStep
			--	end
			--	PRICE=price[i].open-PriceStep
			--	while PRICE>=price[i].low do
			--		CheckCicle()
			--		PRICE=PRICE-PriceStep
			--	end
			--end
			
		i=i+1
	end
	func.inTable (tt1, TestName..' ' ..seccode .. ' atr:'..atr..' тотаl '..TOTAL)
	func.inTable (tt1, TestName..' ' ..seccode .. ' тотаlOne '..TOTALONE)
	func.inTable (tt1, TestName..' ' ..seccode .. ' тотаlTwo '..TOTALTWO)
	func.inTable (tt1, TestName..' ' ..seccode .. ' тотаlThree '..TOTALThree)
end

function main()

	TestName1='3complex_3M_1_check'
	
	MN=0
	seccode1='SiM4'

	func.logtable()
	ToolPath = getScriptPath()..'//tool.txt'
	tool=func.loadtable(ToolPath)
	RecPath = getScriptPath()..'//'..'rec_check' .. '.txt'
	rec = func.loadtable(RecPath)
	if rec==nil then rec={} end

			StateTablePath = getScriptPath()..'//StateTable//StateTable.txt'
			StateTable = func.loadtable(StateTablePath)

--	for key,v in pairs(tool) do	
--		if key ==seccode1 or seccode1=='' then 
			seccode='GLDRUBF'
			--value=v
			preffix='GL4'
					
--			StateTablePath = getScriptPath()..'//StateTable//StateTable'..seccode..'.txt'
--			StateTable = func.loadtable(StateTablePath)
			if StateTable==nil then StateTable={} end
			func.inTable (tt1,seccode)
			func.inTable (tt1,preffix)
			
			FPath = getScriptPath()..seccode .. 'check.params'
			memory=nil--func.loadtable(FPath)
			
			--for n=0.8,1.5,0.1 do
			--	memory=nil
				TestName=TestName1--..' '..n
			--	MN=n

				seccode='IMOEXF'
				preffix='MX4'
				--func.inTable (tt1,'------------long')
				--CheckStrategy(seccode,preffix,30,'long')
				CheckStrategy(seccode,preffix,50,'long')
				--CheckStrategy(seccode,preffix,50,'long')
				--func.inTable (tt1,'short')
				--CheckStrategy(seccode,preffix,30,'short')
				--CheckStrategy(seccode,preffix,40,'short')
				--CheckStrategy(seccode,preffix,50,'short')
				--
				--seccode='CNYRUBF'
				--preffix='CN4'
				--func.inTable (tt1,'------------long')
				--
				----CheckStrategy(seccode,preffix,0.090,'long')
				----CheckStrategy(seccode,preffix,0.10,'long')
				----CheckStrategy(seccode,preffix,0.11,'long')
				----CheckStrategy(seccode,preffix,0.12,'long')
				--CheckStrategy(seccode,preffix,0.13,'long')
				--CheckStrategy(seccode,preffix,0.14,'long')
				--CheckStrategy(seccode,preffix,0.15,'long')
				--func.inTable (tt1,'------------short')
				--
				----CheckStrategy(seccode,preffix,0.090,'short')
				----CheckStrategy(seccode,preffix,0.10,'short')
				----CheckStrategy(seccode,preffix,0.11,'short')
				----CheckStrategy(seccode,preffix,0.12,'short')
				--CheckStrategy(seccode,preffix,0.13,'short')
				--CheckStrategy(seccode,preffix,0.14,'short')
				--CheckStrategy(seccode,preffix,0.15,'short')


			--end
			
			--func.savetable(StateTable,StateTablePath)

--		end
--	end

--		for i=1, 31, 1 do 
--			for m=8,23, 1 do
--				for n=0,30,30 do 
--					--func.inTable (tt1,'SiM4 '.. i..'.01.2024 - '.. m ..'-'.. n)
--					if StateTable['SiM4'][2024][1][i]~=nil and StateTable['SiM4'][2024][1][i][m]~=nil and StateTable['SiM4'][2024][1][i][m][n]~=nil then
--						local sim_price = StateTable['SiM4'][2024][1][i][m][n]['m30']['par']['price']
--						local sih_price = StateTable['SiH4'][2024][1][i][m][n]['m30']['par']['price']
--						local sim_ma200 = StateTable['SiM4'][2024][1][i][m][n]['m30']['ma200']['ma']
--						local sim_ma20 = StateTable['SiM4'][2024][1][i][m][n]['m30']['ma20']['ma']
--						local sih_ma200 = StateTable['SiH4'][2024][1][i][m][n]['m30']['ma200']['ma']
--						local sih_ma20 = StateTable['SiH4'][2024][1][i][m][n]['m30']['ma20']['ma']
--						local sih_dma200 = StateTable['SiH4'][2024][1][i][0][0]['d']['ma200']['ma']
--						local sih_dma20 = StateTable['SiH4'][2024][1][i][0][0]['d']['ma20']['ma']
--						local sim_dma200 = StateTable['SiM4'][2024][1][i][0][0]['d']['ma200']['ma']
--						local sim_dma20 = StateTable['SiM4'][2024][1][i][0][0]['d']['ma20']['ma']
--						
--						func.inTable (tt1,'SiM4 '.. i..'.01.2024 - '.. m ..'-'.. n .. ' ' ..  sim_price .. ' - ' ..sih_price .. ' = ' .. sim_price - sih_price)
--						func.inTable (tt1,'Si D MA200 '.. i..'.01.2024 - '.. m ..'-'.. n .. ' ' ..  sim_dma200 .. ' - ' ..sih_dma200 .. ' = ' .. sim_dma200 - sih_dma200)
--						func.inTable (tt1,'Si D MA20 '.. i..'.01.2024 - '.. m ..'-'.. n .. ' ' ..  sim_dma20 .. ' - ' ..sih_dma20 .. ' = ' .. sim_dma20 - sih_dma20)						
--						func.inTable (tt1,'Si m30 MA200 '.. i..'.01.2024 - '.. m ..'-'.. n .. ' ' ..  sim_ma200 .. ' - ' ..sih_ma200 .. ' = ' .. sim_ma200 - sih_ma200)
--						func.inTable (tt1,'Si m30 MA20 '.. i..'.01.2024 - '.. m ..'-'.. n .. ' ' ..  sim_ma20 .. ' - ' ..sih_ma20 .. ' = ' .. sim_ma20 - sih_ma20)						
--						func.inTable (tt1,'--------------')						
--
--						
--					end
--				end
--			end
--		end
			
	func.savetable(StateTable,StateTablePath)
	func.savetable(rec,RecPath)
end
	
