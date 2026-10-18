require("func")
require("robot")

stopped = false

function OnStop(s)
	stopped = true
	return 5000
end

function createtable()
    t_id = AllocTable()
	AddColumn(t_id, 0, "Код клиента", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 1, "Дата", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id, 2, "key", true, QTABLE_STRING_TYPE, 15)
	AddColumn(t_id, 3, "seccode1", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 4, "Цена ВК", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id, 5, "SWAP_RATE", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 6, "кол-во", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 7, "Фандинг", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 8, "изм.кол", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 9, "vm_one", true, QTABLE_STRING_TYPE, 10)	
	AddColumn(t_id, 10,"vm_two", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 11,"vm_three", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 12, "ГО", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 13, "Дох.", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 14, "Итого", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 15, "KeyTotal", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 16, "Комментарий", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 17, "Спрэд", true, QTABLE_STRING_TYPE, 10)
	
	t = CreateWindow(t_id)
    SetWindowCaption(t_id, "Отчет")
end

function createtable2()
    t_id = AllocTable()
	AddColumn(t_id2, 0, "Код клиента", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 1, "Дата", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id2, 2, "key", true, QTABLE_STRING_TYPE, 15)
	AddColumn(t_id2, 3, "seccode1", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 4, "Цена ВК", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id2, 5, "SWAP_RATE", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 6, "кол-во", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 7, "Фандинг", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 8, "ВМаржа", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 9, "seccode2", true, QTABLE_STRING_TYPE, 10)	
	AddColumn(t_id2, 10,"Цена ВК", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 11, "кол-во", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 12, "ВМаржа", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 13, "Итого", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 14, "KeyTotal", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 15, "Комментарий", true, QTABLE_STRING_TYPE, 10)
	
	t = CreateWindow(t_id)
    SetWindowCaption(t_id, "Отчет")
end

function FillRow1(key,seccode,value,PrevValue)
	
	SetCell(t_id, rownumber, 0, tostring(func.setting('client_code')))
	--SetCell(t_id, rownumber, 1, string.gsub(tostring(os.date("%x",os.time(datetime))),'/','.'))
	
	SetCell(t_id, rownumber, 1, string.format("%02d.%02d.%04d", datetime.day, datetime.month, datetime.year))
	--string.format('%d',datetime.day)..'.'..datetime.month..'.'..datetime.year)
	SetCell(t_id, rownumber, 2, tostring(key))
	SetCell(t_id, rownumber, 3, tostring(seccode))
	SetCell(t_id, rownumber, 4, string.gsub(tostring(value.CLPRICE),'%.',','))
	--SetCell(t_id, rownumber, 4, string.gsub(tostring(value.CLPRICE),'%p',','))
	SetCell(t_id, rownumber, 5, string.gsub(tostring(value.PREV_SWAP_RATE),'%.',','))
	printvol=''
	if value.basevol~=nil then 
		vol=value.basevol
		if value.vol~=value.basevol  then printvol='/'.. tostring(value.vol) end
	else vol=value.vol end
	
	SetCell(t_id, rownumber, 6, tostring(func.roundS(vol)..printvol))
	SetCell(t_id, rownumber, 7, tostring(func.roundS(value.funding)))
	if PrevValue~=nil and PrevValue[seccode]~=nil and PrevValue[seccode].CLPRICE~=nil and value.CLPRICE~=nil then 
		
		local vm3=func.correctsum(seccode,(value.CLPRICE-PrevValue[seccode].CLPRICE)*vol)
		--SetCell(t_id, rownumber, 8, tostring(func.roundS(vm3)))
		--VM=VM+vm3+value.funding
		--func.inTable (tt1, key .. ' ' .. string.format("%02d.%02d.%04d", datetime.day, datetime.month, datetime.year)..' '..value.CLPRICE..' '..PrevValue[seccode].CLPRICE)
		vmnew=0
		if value.newvol~=nil and value.newvol~=0 then
			newprice=value.newcost/value.newvol
			if value.newvol>0 and value.vol>0 then vmnew=func.correctsum(seccode,(value.CLPRICE-newprice)*value.newvol)
			elseif value.newvol>0 and value.vol<0 then vmnew=func.correctsum(seccode,(PrevValue[seccode].CLPRICE-newprice)*value.newvol)
			elseif value.newvol<0 and value.vol<0 then vmnew=func.correctsum(seccode,(value.CLPRICE-newprice)*value.newvol)
			elseif value.newvol<0 and value.vol>0 then vmnew=func.correctsum(seccode,(PrevValue[seccode].CLPRICE-newprice)*value.newvol) 
			end		
			SetCell(t_id, rownumber, 8, tostring(func.roundS(value.newvol)))
			--SetCell(t_id, rownumber, 10, tostring(func.roundS(vmnew)))
		end
		if value.correct~=nil then 
			vmnew=value.correct 
			--SetCell(t_id, rownumber, 10, tostring(func.roundS(vmnew)))
		end
		
		SetCell(t_id, rownumber, 9, tostring(func.roundS(value.pos.one.vm)))
		SetCell(t_id, rownumber, 10, tostring(func.roundS(value.pos.two.vm)))
		SetCell(t_id, rownumber, 11, tostring(func.roundS(value.pos.three.vm)))
		
		VM=vm3+value.funding+vmnew
	end
	if value.go~=nil and value.go~=0 then 
		SetCell(t_id, rownumber, 12, (tostring(func.roundS(value.go/1000,1))))
	end
	if PrevValue~=nil and PrevValue[seccode].vol~=value.vol then 
		SetCell(t_id, rownumber, 16, 'Изм.кол-ва')
	end
end

function FillRow2(seccode,value,PrevValue)
	
	SetCell(t_id, rownumber, 9, tostring(seccode))
	SetCell(t_id, rownumber, 10, string.gsub(tostring(value.CLPRICE),'%.',','))
	SetCell(t_id, rownumber, 11, tostring(func.roundS(value.vol)))
	if PrevValue~=nil and PrevValue[seccode]~=nil and PrevValue[seccode]~=nil and PrevValue[seccode].CLPRICE~=nil and value.CLPRICE~=nil  then 
		local vm2=func.correctsum(seccode,(value.CLPRICE-PrevValue[seccode].CLPRICE)*value.vol)
		SetCell(t_id, rownumber, 12, tostring(func.roundS(vm2)))
		VM=VM+vm2
	end
end

function fillTrades(key)
	
	year1=2024
	rowfill=0
	rownumber=0
	PrevValue=0
	VM=0
	
	ltrades=trades[year1][12]
	
	for month,montharr in pairs(trades[year1]) do	
	--for month,montharr in pairs(ltrades) do		
		for day,dayarr in pairs(montharr) do	
			datetime = { year  = year1, month = month, day   = day}
			
			if dayarr[key]~=nill then 
				if rowfill==rownumber then rownumber=InsertRow(t_id, -1) end
				VM=0
				for seccode,value in pairs(dayarr[key]) do		
					if value.vol~=nil and value.vol~=0 and key~='SRM4' then 
						rowfill=rownumber
						--func.inTable (tt1, rowfill .. ' ' .. func.Tbl2Str(value))
						LOTSIZE=tonumber(getParamEx('SPBFUT', seccode,'LOTSIZE').param_value)
						
						if seccode=='GLDRUBF' or seccode=='IMOEXF' or seccode=='EURRUBF' or seccode=='USDRUBF' or value.number==1 then 
							FillRow1(key,seccode,value,PrevValue) 
						else FillRow2(seccode,value,PrevValue)
						end
						--if value.PREV_SWAP_RATE~=0 then FillRow1(key,seccode,value,PrevValue) end
						--if value.PREV_SWAP_RATE==0 then FillRow2(seccode,value,PrevValue) end
						SetCell(t_id, rownumber, 13, tostring(func.roundS(VM)))
					end
				end
				PrevValue=dayarr[key]
			end
		end
	end
end


function fillDate(year,month)
	
	rowfill=0
	rownumber=0
	PrevValue=0
	VM=0
	TotalAll=0
	
	for day,dayarr in pairs(trades[year][month]) do	
		datetime = { year  = year, month = month, day   = day}
		Total=0	
		TotalFun=0
		keytotal=0
		keyGo=0
		yeld=0
		price1=nil
		price2=nil
		spred=0
		miss=false
		if month==12 and day<19 then miss=true end
		for key,keyvalue in pairs(dayarr) do	
			VM=0
			if key~='flag' and not miss then 
				
				for seccode,value in pairs(keyvalue) do		
					if value.vol~=nil and (value.pos.one.vol~=nil or value.pos.two.vol~=nil or value.pos.three.vol~=nil) and (value.pos.one.vol+value.pos.two.vol+value.pos.three.vol~=0) then 
						PrevValue=tradesPrevDate({year=year,month=month,day=day},key)
						LOTSIZE=tonumber(getParamEx('SPBFUT', seccode,'LOTSIZE').param_value)
						rownumber=InsertRow(t_id, -1)
						FillRow1(key,seccode,value,PrevValue) 
						TotalFun=TotalFun+value.funding
						SetCell(t_id, rownumber, 14, tostring(func.roundS(VM)))
						keytotal=keytotal+VM
						if value.go~=nill and math.abs(value.go)>keyGo then keyGo=math.abs(value.go) end
						multiple=1
						if value.number==1 and tool[key]~=nil then multiple=tool[key].seccode1.multiplier
						elseif value.number==2 and tool[key]~=nil  then multiple=tool[key].seccode2.multiplier
						end
						if price1==nil then price1=value.CLPRICE*multiple
						elseif price2==nil then price2=value.CLPRICE*multiple
						end
						Total=Total+VM
					end
				end
				if keytotal~=0 and keyGo~=0 then 
					yeld=keytotal/keyGo*247*100
					SetCell(t_id, rownumber, 13, tostring(func.roundS(yeld)..'%'))
					SetCell(t_id, rownumber-1, 13, tostring(func.roundS(yeld)..'%'))
					SetCell(t_id, rownumber, 15, tostring(func.roundS(keytotal)))
					keyGo=0
					keytotal=0
					if price1~=nil and price2~=nil and price1>price2 then spred=price1-price2
					elseif  price1~=nil and price2~=nil and price2>price1 then spred=price2-price1 end
					SetCell(t_id, rownumber, 17, tostring(func.roundS(spred)))					
					price1=nil
					price2=nil
				end
			end
		end
		if Total~=0 then 
			days=days+1
			rownumber=InsertRow(t_id, -1)
			SetCell(t_id, rownumber, 0, tostring(days))
			SetCell(t_id, rownumber, 14, tostring(func.roundS(Total)))					
			SetCell(t_id, rownumber, 1, string.format("%02d.%02d.%04d", datetime.day, datetime.month, datetime.year))
			SetCell(t_id, rownumber, 7, tostring(func.roundS(TotalFun)))
			func.yellow(t_id,rownumber)
			TotalAll=TotalAll+Total
		end
	end
	rownumber=InsertRow(t_id, -1)
	SetCell(t_id, rownumber, 14, tostring(func.roundS(TotalAll)))
	TotalAllmonth=TotalAllmonth+TotalAll
	func.yellow(t_id,rownumber)

end


function tradesPrevDate(data, key)
	local localTime
	--func.inTable (tt1, 'data '..tostring(func.Tbl2Str(data)))
	if data==nil then 
		localTime=os.time()-86400
	else
		localTime=os.time(data)-86400
	end
	for n=1,31,1 do
		dateT=os.date("*t",localTime)
		if trades[dateT.year][dateT.month][dateT.day]~=nil then 
			--func.inTable (tt1, 'tradesPrevDate '..dateT.day)
			if key~=nil then 
				return trades[dateT.year][dateT.month][dateT.day][key]			
			else return trades[dateT.year][dateT.month][dateT.day] end
		end
		localTime=localTime-86400
		n=n+1
	end

end

function vm()

	dateT=os.date("*t",os.time())
	tradesDate={}
	tradesDate=trades[dateT.year][dateT.month][dateT.day]
	--if func.TimePassed(19,10,00) and func.TimeNotPassed(23,49,55) then 
	--	tradesDate=trades[dateT.year][dateT.month][dateT.day]
	--elseif func.TimePassed(09,01,00) and func.TimeNotPassed(18,45,55) then	
	--	tradesDate=tradesPrevDate()
	--	--tradesDate=trades[dateT.year][dateT.month][dateT.day-3]
	--else
	--	return false
	--end	
	
	t_id_1 = AllocTable()
	AddColumn(t_id_1, 0, "Инструмент", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id_1, 1, "итого", true, QTABLE_STRING_TYPE, 10)
	rowmassive={}
	colmassive={}
	n=2

	for key, value in pairs(tradesDate) do	
		if key~='flag' then 
			for sec, value2 in pairs(value) do	
				if value2.vol~=0 then 
					if rowmassive[sec]==nil then rowmassive[sec]={} end
					if colmassive[key]==nil then 
						colmassive[key]={}
						colmassive[key].col1=n 
						AddColumn(t_id_1, n, key, true, QTABLE_STRING_TYPE, 13)	
						colmassive[key].col2=n+1 
						AddColumn(t_id_1, n+1, key, true, QTABLE_STRING_TYPE, 13)	
						colmassive[key].col3=n+2
						AddColumn(t_id_1, n+2, '3', true, QTABLE_STRING_TYPE, 10)							
						colmassive[key].sum1=0	
						colmassive[key].sum2=0	
						colmassive[key].sum3=0							
					end
					if rowmassive[sec][key]==nil then 
						rowmassive[sec][key]={} 
						rowmassive[sec][key].col1=colmassive[key].col1	
						rowmassive[sec][key].col2=colmassive[key].col2	
						rowmassive[sec][key].col3=colmassive[key].col3							
						n=n+3					
					end 
					rowmassive[sec][key].oneVM=value2.pos.one.vm
					rowmassive[sec][key].twoVM=value2.pos.two.vm
					rowmassive[sec][key].threeVM=value2.pos.three.vm
					rowmassive[sec][key].Spred1=value2.pos.one.Spred
					rowmassive[sec][key].Spred2=value2.pos.two.Spred
					rowmassive[sec][key].Spred3=value2.pos.three.Spred
					rowmassive[sec][key].vol1=value2.pos.one.vol
					rowmassive[sec][key].vol2=value2.pos.two.vol
					rowmassive[sec][key].vol3=value2.pos.three.vol
					
					colmassive[key].sum1=colmassive[key].sum1+(value2.pos.one.vm or 0)
					colmassive[key].sum2=colmassive[key].sum2+(value2.pos.two.vm or 0)
					colmassive[key].sum3=colmassive[key].sum3+(value2.pos.three.vm or 0)
				end
			end
		end
	end
	t = CreateWindow(t_id_1)
	SetWindowCaption(t_id_1, "Вариационная маржа")
	InsertRow(t_id_1, -1)
	
	for sec, value in pairs(rowmassive) do	
		row=InsertRow(t_id_1, -1)
		totalsec=0
		SetCell(t_id_1, row, 0, sec)
		for key, value2 in pairs(value) do	
			SetCell(t_id_1, 1, value2.col1, func.roundS(value2.Spred1)..'*'..math.abs(func.round(value2.vol1)))
			SetCell(t_id_1, 1, value2.col2, func.roundS(value2.Spred2)..'*'..math.abs(func.round(value2.vol2)))
			SetCell(t_id_1, 1, value2.col3, func.roundS(value2.Spred3)..'*'..math.abs(func.round(value2.vol3)))
			SetCell(t_id_1, row, value2.col1, tostring(value2.oneVM))
			SetCell(t_id_1, row, value2.col2, tostring(value2.twoVM))
			SetCell(t_id_1, row, value2.col3, tostring(value2.threeVM))
			totalsec=totalsec+(value2.oneVM or 0)+(value2.twoVM or 0)+(value2.threeVM or 0)
		end
		SetCell(t_id_1, row,1, tostring(totalsec))
		func.yellow (t_id_1,row,1)
	end
	row=InsertRow(t_id_1, -1)
	InsertRow(t_id_1, -1)
	totalkey1=0
	totalkey2=0
	totalkey3=0
	for key, value in pairs(colmassive) do	
		SetCell(t_id_1, row, value.col1, tostring(value.sum1))
		SetCell(t_id_1, row, value.col2, tostring(value.sum2))
		SetCell(t_id_1, row, value.col3, tostring(value.sum3))
		SetCell(t_id_1, row+1, value.col3, tostring(value.sum1+value.sum2+value.sum3))
		totalkey1=totalkey1+value.sum1
		totalkey2=totalkey2+value.sum2
		totalkey3=totalkey3+value.sum3		
	end
	SetCell(t_id_1, row, 1, tostring(totalkey1+totalkey2+totalkey3))
	func.yellow (t_id_1,1)
	func.yellow (t_id_1,row)
	func.savetable(rowmassive,getScriptPath()..'//rowmassive.txt')
end

function main()
	
	--func.logtable()
	TradesPath = getScriptPath()..'//trades.txt'
	trades=func.loadtable(TradesPath)

	ToolPath = getScriptPath()..'//tool.txt'
	tool=func.loadtable(ToolPath)

	createtable()	

	--for key,value in pairs(tool) do			
	--	if value.strategy202106~=nil and value.strategy202106.enable and value.strategy202106.pos.two.total.vol~=0 then
	--		fillTrades(key)	
	--		InsertRow(t_id, -1)
	--	end
	--end
	--fillTrades('USDRUBF-2')	
	--InsertRow(t_id, -1)
	--fillTrades('USDRUBF-SiZ')
	--InsertRow(t_id, -1)
	--fillTrades('EURRUBF')	
	--InsertRow(t_id, -1)
	--fillTrades('EURRUBF')
	--InsertRow(t_id, -1)
	--fillTrades('GLDRUBF-2')
	--InsertRow(t_id, -1)
	--fillTrades('GLDRUBF')
	--InsertRow(t_id, -1)
	--fillTrades('GLDRUBF-2')
	--InsertRow(t_id, -1)
	--fillTrades('IMOEXF')
	--InsertRow(t_id, -1)
	--fillTrades('IMOEXF-2')
	--InsertRow(t_id, -1)
	--fillTrades('GLD-CNY')
	--InsertRow(t_id, -1)
	--fillTrades('GLZ-CNY')
	--InsertRow(t_id, -1)	
	--fillDate(2024,12)
	TotalAllmonth=0
	days=0
	rownumber=InsertRow(t_id, -1)
	SetCell(t_id, rownumber, 2, tostring('IMOEXF-MMH6'))
	SetCell(t_id, rownumber, 16, tostring('53'))
	rownumber=InsertRow(t_id, -1)
	SetCell(t_id, rownumber, 2, tostring('USDRUBF-SiH6'))
	SetCell(t_id, rownumber, 16, tostring('984'))
	rownumber=InsertRow(t_id, -1)
	--SetCell(t_id, rownumber, 2, tostring('GLDRUBF-GLH6'))
	--SetCell(t_id, rownumber, 16, tostring('470'))
	--fillDate(2025,9)
	--fillDate(2025,10)
	--fillDate(2025,11)
	--fillDate(2025,12)
	--fillDate(2026,1)
	--fillDate(2026,2)
	fillDate(2026,3)
	fillDate(2026,4)
	
	rownumber=InsertRow(t_id, -1)

	SetCell(t_id, rownumber, 13, tostring(func.roundS(TotalAllmonth)))
	vm()
	
end