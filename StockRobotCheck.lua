require("func")
require("robot")
local w32 = require("w32")

stopped = false
TradePath = getScriptPath()..'//trade.txt'
TradeLogFile="//TradeRec.txt"

TRANS_ID=nil
ORDERNUM=nil
ORDERCOMPLETED=true
VOLCOMPLETED=0

SaveTrends=false
SaveOrders=false
SaveOrderTable=false



function OnStop(s)
	stopped = true
	
	func.savetable_new(trades,TradesPath)
	func.savetable(tool,ToolPath)
	func.savetable(Trends,TrendsPath)
	func.savetable(Orders,OrdersPath)	
	func.savetable(OrderTable,OrderTablePath)	
	
	return 5000
end

function FindLoginWindow()
   hLoginWnd = w32.FindWindow("", "Идентификация пользователя")
   if hLoginWnd == 0 then
      hLoginWnd = w32.FindWindow("", "Вход в систему")
      if hLoginWnd == 0 then
         hLoginWnd = w32.FindWindow("", "User identification")
      end
   end
   return hLoginWnd
end

function EnterTime()
	if 1==1 then return 1 end
	if func.TimePassed(17,00,00) and func.TimeNotPassed(18,00,59) then return 1
	elseif func.TimePassed(18,02,00) and func.TimeNotPassed(18,49,55) then return 2
	else return 0
	end

end

function TableRows(key)
		
		--func.inTable (tt1, 'TableRows '..tostring(key))
		rowmassive[key..tool[key].seccode1.seccode]={}
		rowmassive[key..tool[key].seccode1.seccode].row=InsertRow(t_id, -1)
		rowmassive[key..tool[key].seccode1.seccode].key=key
		rowmassive[key..tool[key].seccode1.seccode].seccode=tool[key].seccode1.seccode
		rowmassive[key..tool[key].seccode1.seccode].numb=1
		
		rowmassive[key..tool[key].seccode2.seccode]={}
		rowmassive[key..tool[key].seccode2.seccode].row=InsertRow(t_id, -1)
		rowmassive[key..tool[key].seccode2.seccode].key=key
		rowmassive[key..tool[key].seccode2.seccode].seccode=tool[key].seccode2.seccode
		rowmassive[key..tool[key].seccode2.seccode].numb=2

		rowmassive[key.."Delta1"]={}
		rowmassive[key.."Delta1"].row=InsertRow(t_id, -1)
		rowmassive[key..tool[key].seccode3.seccode]={}
		rowmassive[key..tool[key].seccode3.seccode].row=InsertRow(t_id, -1)
		rowmassive[key.."Delta2"]={}
		rowmassive[key.."Delta2"].row=InsertRow(t_id, -1)
end


function createtable()
    t_id = AllocTable()
    AddColumn(t_id, 0, "Инструмент", true, QTABLE_STRING_TYPE, 20)
    AddColumn(t_id, 1, "Цена", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id, 2, "Цена buy", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 3, "Цена sell", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 4, "1 дн", true, QTABLE_STRING_TYPE, 7)
	AddColumn(t_id, 5, "6 дн", true, QTABLE_STRING_TYPE, 7)	
	AddColumn(t_id, 6, "20 дн", true, QTABLE_STRING_TYPE, 7)
	AddColumn(t_id, 7, "200 дн", true, QTABLE_STRING_TYPE, 1)
	AddColumn(t_id, 8, "1vol", true, QTABLE_STRING_TYPE, 6)
    AddColumn(t_id, 9, "%", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id, 10, "rub", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 11, "2vol", true, QTABLE_STRING_TYPE, 6)
    AddColumn(t_id, 12, "%", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id, 13, "rub", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id, 14, "Фандинг", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id, 15, "Убыток", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id, 16, "ГО", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id, 17, "Дох", true, QTABLE_STRING_TYPE, 10)

	AddColumn(t_id, 18, "3vol", true, QTABLE_STRING_TYPE, 6)
    AddColumn(t_id, 19, "%", true, QTABLE_STRING_TYPE, 8)
    AddColumn(t_id, 20, "rub", true, QTABLE_STRING_TYPE, 8)
    AddColumn(t_id, 21, "lastprice", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id, 22, "step", true, QTABLE_STRING_TYPE, 8) 
    AddColumn(t_id, 23, "stop", true, QTABLE_STRING_TYPE, 8)
    AddColumn(t_id, 24, "price", true, QTABLE_STRING_TYPE, 8)
    AddColumn(t_id, 25, "ParD", true, QTABLE_STRING_TYPE, 8)
    AddColumn(t_id, 26, "ParM30", true, QTABLE_STRING_TYPE, 8)

	t = CreateWindow(t_id)
    SetWindowCaption(t_id, "Портфель")
	SetWindowPos(t_id,550,0,1360,853)

--	tool['IMOEXF-MMZ5']['strategy202106']['enable']=false
--tool['MMZ5-MMH6']['strategy202106']['enable']=false
--tool['GAZPF-GZZ5']['strategy202106']['enable']=false
--tool['USDRUBF-SiZ5']['strategy202106']['enable']=false
--tool['USDRUBF-SiZ5-2']['strategy202106']['enable']=false
--tool['SiZ5-SiH6']['strategy202106']['enable']=false
--tool['EURRUBF-EuZ5']['strategy202106']['enable']=false
--tool['CNYRUBF-CRZ5']['strategy202106']['enable']=false
--tool['GLDRUBF-GLZ5']['strategy202106']['enable']=false
--tool['SBERF-SRZ5']['strategy202106']['enable']=false
--func.savetable(tool,ToolPath)

	rowmassive['Итого']={}
	rowmassive['Итого'].row=InsertRow(t_id, -1)
	rowmassive['stocks']={}
	rowmassive['stocks'].row=InsertRow(t_id, -1)
	SetCell(t_id, rowmassive['stocks'].row, 0, 'stocks')
	func.yellow (t_id,rowmassive['stocks'].row)	
	--TableRows('IMOEXF-2')
	--tool['IMOEXF-2']['strategy202106']['enable']=false
	
	TableRows('IMOEXF-MMH6')
	TableRows('GAZPF-GZH6')
	
	rowmassive['currency']={}
	rowmassive['currency'].row=InsertRow(t_id, -1)
	SetCell(t_id, rowmassive['currency'].row, 0, 'currency')
	func.yellow (t_id,rowmassive['currency'].row)	
	TableRows('USDRUBF-SiH6')
	
	TableRows('EURRUBF-EuH6')	
	TableRows('CNYRUBF-CRH6')

	--tool['CNYRUBF-CRU5'].group='currency'
	
	rowmassive['gold']={}
	rowmassive['gold'].row=InsertRow(t_id, -1)
	SetCell(t_id, rowmassive['gold'].row, 0, 'gold')
	func.yellow (t_id,rowmassive['gold'].row)	
	TableRows('GLDRUBF-GLH6')	
	--tool['GLDRUBF-2'].group='gold'
	--tool['GLDRUBF-GLM5'].group='gold'
	
	rowmassive['other']={}
	rowmassive['other'].row=InsertRow(t_id, -1)
	SetCell(t_id, rowmassive['other'].row, 0, 'other')	
	func.yellow (t_id,rowmassive['other'].row)

	rowmassive['Si']={}	
	rowmassive['Si'].row=InsertRow(t_id, -1)
	func.yellow (t_id,rowmassive['Si'].row)		

	TableRows('BTF6-BTG6')		
	TableRows('SBERF-SRH6')
	TableRows('CNY-USD')
	TableRows('GLD-CNY')
	
	--func.savetable(tool,ToolPath)
	--func.inTable (tt1, 'save tool')
	
	--rowmassive['Eu']={}		
	--rowmassive['Eu'].row=InsertRow(t_id, -1)
	--func.yellow (t_id,rowmassive['Eu'].row)	

end

function MySort(a,b)
        func.inTable (tt1, 'OrdersSort '..a..' '..b)
		if rowmassive[a].row > rowmassive[b].row then
           return true;
        else
           return false;
        end;
end;

function createtableOrders()
    t_id2 = AllocTable()
	n=0
    AddColumn(t_id2, 0, "Наименование", true, QTABLE_STRING_TYPE, 30)
    AddColumn(t_id2, 1, "Order1 key", true, QTABLE_STRING_TYPE, 20)
    AddColumn(t_id2, 2, "seccode", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id2, 3, "tframe", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 4, "op", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 5, "vol", true, QTABLE_STRING_TYPE, 5)
	AddColumn(t_id2, 6, "ID", true, QTABLE_STRING_TYPE, 5)
	AddColumn(t_id2, 7, "price", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 8, "complet", true, QTABLE_STRING_TYPE, 5)
	AddColumn(t_id2, 9, "TradePrice", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, 10, "n", true, QTABLE_STRING_TYPE, 3)	
	AddColumn(t_id2, 11, "n", true, QTABLE_STRING_TYPE, 3)	
	AddColumn(t_id2, 12, "diff", true, QTABLE_STRING_TYPE, 5)	
	n=13
    AddColumn(t_id2, n+0, "", true, QTABLE_STRING_TYPE, 2)
    AddColumn(t_id2, n+1, "Order2 key", true, QTABLE_STRING_TYPE, 20)
    AddColumn(t_id2, n+2, "seccode", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t_id2, n+3, "tframe", true, QTABLE_STRING_TYPE, 10)	
	AddColumn(t_id2, n+4, "op", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, n+5, "vol", true, QTABLE_STRING_TYPE, 5)
	AddColumn(t_id2, n+6, "ID", true, QTABLE_STRING_TYPE, 5)
	AddColumn(t_id2, n+7, "price", true, QTABLE_STRING_TYPE, 10)
	AddColumn(t_id2, n+8, "complet", true, QTABLE_STRING_TYPE, 5)
	AddColumn(t_id2, n+9, "TradePrice", true, QTABLE_STRING_TYPE, 10)

	t = CreateWindow(t_id2)
    SetWindowCaption(t_id2, "Orders")
	SetWindowPos(t_id2,0,0,1500,200)
end

function ClearStateTable()
    local currentTime = os.date("*t")
    local currentMin = currentTime.min
    local currentSec = currentTime.sec
    
    -- Определяем текущий получас (0 или 1)
    local newHalfHour = (currentMin >= 30) and 1 or 0
    
    -- Проверяем смену получаса
    if currentHalfHour ~= newHalfHour then
        currentHalfHour = newHalfHour
        lastTriggerTime = nil  -- Сбрасываем при смене получаса
    end
    
    -- Проверяем, находится ли текущая минута в диапазоне 1-4 или 31-34
    local isTargetMinute = ((currentMin >= 1 and currentMin <= 4) or 
                          (currentMin >= 31 and currentMin <= 34))
    
    -- Если это нужная минута и еще не срабатывали в эту минуту
    if isTargetMinute then
        local currentMinuteTime = os.time{year=2000, month=1, day=1, hour=currentTime.hour, min=currentMin, sec=0}
        
        if not lastTriggerTime or lastTriggerTime ~= currentMinuteTime then
            lastTriggerTime = currentMinuteTime
			func.ToLog  ('StockRobot clear StateTable')-- .. func.Tbl2Str(StateTable) )
			func.inTable (tt1, 'StockRobot clear StateTable')
			StateTableD={} 
			StateTable={}
        end
    end
end

function OrdersReport(key,seccode)
	
	--Orders = func.loadtable(OrdersPath)	
	createtableOrders()
	--table.sort(Orders, MySort)
	for numb,orders in pairs(Orders) do
		if orders.order1.OrderTablePath==nil then OrderTable1 = OrderTable else OrderTable1=func.loadtable(orders.order1.OrderTablePath) end
		if orders.order2.OrderTablePath==nil then OrderTable2 = OrderTable else OrderTable2=func.loadtable(orders.order2.OrderTablePath) end
		if (key==nil and seccode==nil) or (orders.order1.key==key  and orders.order1.seccode==seccode) then 		
			local row=InsertRow(t_id2, -1)
			n=0
			--func.inTable (tt1, numb..' '..row)
			SetCell(t_id2, row, 0, tostring(numb))
			SetCell(t_id2, row, 1, tostring(orders.order1.key))
			SetCell(t_id2, row, 2, tostring(orders.order1.seccode))
			SetCell(t_id2, row, 3, tostring(orders.order1.tframe))		
			SetCell(t_id2, row, 4, tostring(orders.order1.operation))		
			SetCell(t_id2, row, 5, tostring(orders.order1.vol))
			SetCell(t_id2, row, 6, tostring(orders.order1.IdOrder1))
			if OrderTable1[orders.order1.IdOrder1]~=nil then 
				SetCell(t_id2, row, 7, tostring(OrderTable1[orders.order1.IdOrder1].price))
				SetCell(t_id2, row, 8, tostring(OrderTable1[orders.order1.IdOrder1].VolCompleted))
				SetCell(t_id2, row, 9, tostring(OrderTable1[orders.order1.IdOrder1].tradeprice))
				if OrderTable1[orders.order1.IdOrder1].statusorder~=3 then func.red(t_id2,row,6) end
			end
			SetCell(t_id2, row, 10, tostring(orders.order1.n))
			SetCell(t_id2, row, 11, tostring(orders.order2.n))
			if orders.order1.n==0 then func.green(t_id2,row) end
			if not orders.order1.enable then func.gray(t_id2,row) end
			SetCell(t_id2, row, 12, tostring(orders.order1.diff))		
			n=13
			SetCell(t_id2, row, n+1, tostring(orders.order2.key))
			SetCell(t_id2, row, n+2, tostring(orders.order2.seccode))
			SetCell(t_id2, row, n+3, tostring(orders.order2.tframe)	)	
			SetCell(t_id2, row, n+4, tostring(orders.order2.operation))		
			SetCell(t_id2, row, n+5, tostring(orders.order2.vol))
			SetCell(t_id2, row, n+6, tostring(orders.order2.IdOrder1))
			if OrderTable2[orders.order2.IdOrder1]~=nil then 
				SetCell(t_id2, row, n+7, tostring(OrderTable2[orders.order2.IdOrder1].price))
				SetCell(t_id2, row, n+8, tostring(OrderTable2[orders.order2.IdOrder1].VolCompleted))
				SetCell(t_id2, row, n+9, tostring(OrderTable2[orders.order2.IdOrder1].tradeprice))
				if OrderTable1[orders.order2.IdOrder1]~=nil and OrderTable1[orders.order2.IdOrder1].statusorder~=3 then func.red(t_id2,row,n+6) end
			end
			if orders.order1.OrderTablePath==nil or orders.order1.OrderTablePath=='C://StockRobot2024//OrderTable.txt' then func.green(t_id2,row,3) else func.red(t_id2,row,3) end
			if orders.order2.OrderTablePath==nil or orders.order2.OrderTablePath=='C://StockRobot2024//OrderTable.txt' then func.green(t_id2,row,n+3) else func.red(t_id2,row,n+3) end
		end
	end
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

function UpStop (pos)
	--local UpStop=StateTableD.atr.min+StateTableD.atr.atr2*1.2
	local ratio=tool[seccode]['strategy202106']['pos'][pos].ratio
	local UpStop=StateTableM30.atr.LastMin+StateTableD.atr.atr2*ratio
	if ratio==0 then UpStop=0 end
	return UpStop
	--func.inTable (tt1, seccode.. ' UpStop '.. ' StateTableD.atr.min'..StateTableD.atr.min..'+StateTableD.atr.atr2'..StateTableD.atr.atr2..'*1.2='..UpStop)
	
	--if StateTableD.atr.max>UpStop then return StateTableD.atr.max
	--else return UpStop
	--end
end

function DownStop (pos)
	--local DownStop=StateTableD.atr.max-StateTableD.atr.atr2*1.2
	local ratio=tool[seccode]['strategy202106']['pos'][pos].ratio
	local DownStop=StateTableM30.atr.LastMax-StateTableD.atr.atr2*ratio
	if ratio==0 then DownStop=1000000 end
	return DownStop
	--func.inTable (tt1, seccode.. ' DownStop '.. ' StateTableD.atr.max'..StateTableD.atr.max..'-StateTableD.atr.atr2'..StateTableD.atr.atr2..'*1.2='..DownStop)
	
	--if StateTableD.atr.min<DownStop then return StateTableD.atr.min
	--else return DownStop
	--end
end

function GetGo(num)

	if num~=nil then
		go1=Options.pos[num].total.go
		go2=Options.pos[num].total2.go
	else
		go1=Options.pos.one.total.go+Options.pos.two.total.go+Options.pos.three.total.go
		go2=Options.pos.one.total2.go+Options.pos.two.total2.go+Options.pos.three.total2.go
	end

	if math.abs(go1)>math.abs(go2) then return math.abs(go1)
	elseif math.abs(go1)<math.abs(go2) then return math.abs(go2)
	else return 1
	end
	
end

function GetGo1(value)

	local go1=tonumber(getParamEx(CLASS_CODE,value.seccode1.seccode, "SELLDEPO").param_value)
	local go2=tonumber(getParamEx(CLASS_CODE,value.seccode2.seccode, "SELLDEPO").param_value)

	if go1>go2 then return go1
	elseif go1<go2 then return go2
	else return 1
	end
	
end

function setcell(key,seccode,value)

	local div=''
	if SecCollation[seccode.seccode]~=nil and SecCollation[seccode.seccode].total~=nil and SecCollation[seccode.seccode].total~=0 then div='!'..SecCollation[seccode.seccode].total end
	SetCell(t_id, rowmassive[key].row, 0, tostring(seccode.seccode)..'*'.. tostring(seccode.TranVol)..div)
	if div~='' then func.red (t_id,rowmassive[key].row, 0) else func.white (t_id,rowmassive[key].row, 0) end 
	SetCell(t_id, rowmassive[key].row, 1, tostring(seccode.PRICE))
	SetCell(t_id, rowmassive[key].row, 2, tostring(seccode.PRICE_OFFER))
	SetCell(t_id, rowmassive[key].row, 3, tostring(seccode.PRICE_BID))
	SetCell(t_id, rowmassive[key].row, 4, tostring(func.roundS(seccode.StateTableM30_ma20,1)))
	SetCell(t_id, rowmassive[key].row, 5, tostring(func.roundS(seccode.StateTableM30_ma200,1)))
	SetCell(t_id, rowmassive[key].row, 6, tostring(func.roundS(seccode.StateTableD_ma20,1)))
	SetCell(t_id, rowmassive[key].row, 7, tostring(func.roundS(seccode.StateTableD_ma200,1)))

	if seccode.seccode==seccode1 then  								
		SetCell(t_id, rowmassive[key].row, 8, dell0(Options.pos.one.total.vol))
		if Options.pos.one.OpenPos then func.green (t_id,rowmassive[key].row,8) else func.white (t_id,rowmassive[key].row,8) end
		SetCell(t_id, rowmassive[key].row, 9, dell0(tostring(func.roundS((Options.pos.one.total2.enterprice*value.seccode2.multiplier-Options.pos.one.total.enterprice*value.seccode1.multiplier),1))))
		if Options.pos.one.ClosePos then func.red (t_id,rowmassive[key].row,9) else func.white (t_id,rowmassive[key].row,9) end
		SetCell(t_id, rowmassive[key].row, 10, dell0(Options.pos.one.total.proffit))

		SetCell(t_id, rowmassive[key].row, 11, dell0(Options.pos.two.total.vol))
		if Options.pos.two.OpenPos then func.green (t_id,rowmassive[key].row,11) else func.white (t_id,rowmassive[key].row,11) end
		SetCell(t_id, rowmassive[key].row, 12, dell0(tostring(func.roundS(Options.pos.two.total2.enterprice*value.seccode2.multiplier-Options.pos.two.total.enterprice*value.seccode1.multiplier)))..'|'..dell0(func.roundS(Options.pos.two.funding.AvgFunding*(Options.pos.two.funding.duration-Options.pos.two.funding.durationCur),3)))
		if Options.pos.two.ClosePos then func.red (t_id,rowmassive[key].row,12) else func.white (t_id,rowmassive[key].row,12) end
		SetCell(t_id, rowmassive[key].row, 13, dell0(Options.pos.two.total.proffit))
		
		local fundingCurr=Options.pos.two.funding.sum+Options.pos.two.funding2.sum
		SetCell(t_id, rowmassive[key].row, 14, dell0(tostring(func.roundS(fundingCurr))))
		
		--local lost=((value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER)-(Options.pos.two.total2.enterprice*value.seccode2.multiplier-Options.pos.two.total.enterprice*value.seccode1.multiplier))*math.abs(Options.pos.two.total.vol)
		
		local lost=Options.pos.two.total.proffit+Options.pos.two.total2.proffit
		SetCell(t_id, rowmassive[key].row, 15, dell0(tostring(func.roundS(lost))))
		SetCell(t_id, rowmassive[key].row, 16, dell0(tostring(func.roundS(GetGo()/1000,1))))	
		
		if Options.notCalc==nil or Options.notCalc==false then TotalGo=TotalGo+GetGo() end
		if Options.notCalc==nil or Options.notCalc==false then TotalGoTwo=TotalGoTwo+GetGo('two') end
		if (Options.notCalc==nil or Options.notCalc==false) and value.group=='stocks' then TotalGoStocks=TotalGoStocks+GetGo() end
		if (Options.notCalc==nil or Options.notCalc==false) and value.group=='stocks' then TotalGoStocksTwo=TotalGoStocksTwo+GetGo('two') end
		if (Options.notCalc==nil or Options.notCalc==false) and value.group=='gold' then TotalGoGold=TotalGoGold+GetGo() end
		if (Options.notCalc==nil or Options.notCalc==false) and value.group=='gold' then TotalGoGoldTwo=TotalGoGoldTwo+GetGo('two') end
		if (Options.notCalc==nil or Options.notCalc==false) and value.group=='currency' then TotalGoCurrency=TotalGoCurrency+GetGo() end
		if (Options.notCalc==nil or Options.notCalc==false) and value.group=='currency' then TotalGoCurrencyTwo=TotalGoCurrencyTwo+GetGo('two') end

		if Options.pos.two.funding.AvgGo==nil or Options.pos.two.funding.AvgGo==0 then Options.pos.two.funding.AvgGo=1 end
		local CurYield=((fundingCurr+lost)/Options.pos.two.funding.AvgGo)/Options.pos.two.funding2.durationCurReal*365*100

		Options.pos.two.funding.CurYield=CurYield
		Options.pos.two.funding2.CurYield=CurYield
		
		SetCell(t_id, rowmassive[key].row, 17, dell0(tostring(func.roundS(CurYield,1))))				
		
		SetCell(t_id, rowmassive[key].row, 18, dell0(Options.pos.three.total.vol))
		if Options.pos.three.OpenPos then func.green (t_id,rowmassive[key].row,18) else func.white (t_id,rowmassive[key].row,18) end
		SetCell(t_id, rowmassive[key].row, 19, dell0(tostring(func.roundS((Options.pos.three.total2.enterprice*value.seccode2.multiplier-Options.pos.three.total.enterprice*value.seccode1.multiplier),1))))
		if Options.pos.three.ClosePos then func.red (t_id,rowmassive[key].row,19) else func.white (t_id,rowmassive[key].row,19) end
		SetCell(t_id, rowmassive[key].row, 20, dell0(Options.pos.three.total.proffit))
		SetCell(t_id, rowmassive[key].row, 20, dell0(Options.pos.three.total.proffit))
		
		if Options.pos.three.total.vol>0 then 
			SetCell(t_id, rowmassive[key].row, 21, memory.buy['three'..value.preffix].n..'*'..dell0(memory.buy['three'..value.preffix].lastprice))
			--SetCell(t_id, rowmassive[key].row, 24, dell0(memory.buy['three'..value.preffix].price))
			func.yellow (t_id,rowmassive[key].row, 21)	
		elseif Options.pos.three.total.vol<0 then 
			SetCell(t_id, rowmassive[key].row, 21, memory.sell['three'..value.preffix].n..'*'..dell0(memory.sell['three'..value.preffix].lastprice)) 
			--SetCell(t_id, rowmassive[key].row, 24, dell0(memory.sell['three'..value.preffix].price)) 
			func.yellow (t_id,rowmassive[key].row, 21)			
		end
		SetCell(t_id, rowmassive[key].row, 24, dell0(Options.pos.three.total.enterprice))
	elseif seccode.seccode==seccode2 then 
		SetCell(t_id, rowmassive[key].row, 8, dell0(Options.pos.one.total2.vol))
		if Options.pos.one.OpenPos then func.green (t_id,rowmassive[key].row,8) else func.white (t_id,rowmassive[key].row,8) end
		SetCell(t_id, rowmassive[key].row, 9, dell0(Options.pos.one.total2.prc))
		if Options.pos.one.ClosePos then func.red (t_id,rowmassive[key].row,9) else func.white (t_id,rowmassive[key].row,9) end
		SetCell(t_id, rowmassive[key].row, 10, dell0(Options.pos.one.total2.proffit))

		SetCell(t_id, rowmassive[key].row, 11, dell0(Options.pos.two.total2.vol))
		if Options.pos.two.OpenPos then func.green (t_id,rowmassive[key].row,11) else func.white (t_id,rowmassive[key].row,11) end
		--SetCell(t_id, rowmassive[key].row, 12, dell0(Options.pos.two.total2.prc))
		SetCell(t_id, rowmassive[key].row, 12, dell0(func.roundS(Options.pos.two.funding.AvgFunding,3))..'|'..Options.pos.two.funding.duration-Options.pos.two.funding.durationCur)--dell0(func.roundS(Options.pos.two.funding2.AvgFunding*-1,3)))
		if Options.pos.two.ClosePos then func.red (t_id,rowmassive[key].row,12) else func.white (t_id,rowmassive[key].row,12) end
		SetCell(t_id, rowmassive[key].row, 13, dell0(Options.pos.two.total2.proffit))

		SetCell(t_id, rowmassive[key].row, 14, dell0(func.roundS(Options.pos.two.funding.total+Options.pos.two.funding2.total)))

		local multiple=1
		if value.seccode1.seccode=='IMOEXF' then multiple=10 end		
		
		local lostCur=(Options.pos.two.total.proffit+Options.pos.two.total2.proffit) --текущий убыток
		local lostFuture=(value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID)*Options.pos.two.total2.vol*multiple --будущий убыток
		local lost=lostCur-lostFuture --убыток за весь срок позиции
		--local lost=(Options.pos.two.total.enterprice*value.seccode1.multiplier-Options.pos.two.total2.enterprice*value.seccode2.multiplier)*Options.pos.two.total2.vol*multiple
		SetCell(t_id, rowmassive[key].row, 15, dell0(tostring(func.roundS(lost))))

		local profitFuture=Options.pos.two.funding.total-Options.pos.two.funding.sum-lostFuture --будущая прибыль
		local locDur=Options.pos.two.funding2.durationReal-Options.pos.two.funding2.durationCurReal --осталось календарных дней до экспирации
		if locDur==0 then locDur=1 end
		local yieldFuture=profitFuture/GetGo()/locDur*365*100 --будущая доходность
		
		local yield=(Options.pos.two.funding.CurYield*Options.pos.two.funding2.durationCurReal+yieldFuture*locDur)/Options.pos.two.funding2.durationReal --Доходность за весь срок позиции
		--local yield=(Options.pos.two.funding.total+Options.pos.two.funding2.total+lost)/GetGo()/Options.pos.two.funding.durationReal*365*100
		
		Options.pos.two.funding.yield=yield
		Options.pos.two.funding2.yield=yield
		
		local locDur=Options.pos.two.funding2.durationReal-Options.pos.two.funding2.durationCurReal
		if locDur==0 then locDur=1 end
		local NewYield=(Options.pos.two.funding.new+Options.pos.two.funding2.new-multiple*(value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID))/GetGo1(value)/(locDur)*365*100
		SetCell(t_id, rowmassive[key].row, 16, dell0(tostring(func.roundS(NewYield,1))))	
		if NewYield>=70 then func.green(t_id, rowmassive[key].row, 16) end 
		Options.pos.two.funding.NewYield=NewYield
		Options.pos.two.funding2.NewYield=NewYield
		
		--func.inTable (tt1, 'NewYield '..key..' фандинг '..Options.pos.two.funding.new+Options.pos.two.funding2.new..' стоимость '..
		--	value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID	.. ' ГО '.. GetGo1(value).. ' длит.'..Options.pos.two.funding2.durationReal-Options.pos.two.funding2.durationCurReal 	)
		
		SetCell(t_id, rowmassive[key].row, 17, dell0(tostring(func.roundS(yield,1))))			
		
		SetCell(t_id, rowmassive[key].row, 18, dell0(Options.pos.three.total2.vol))
		if Options.pos.three.OpenPos then func.green (t_id,rowmassive[key].row,18) else func.white (t_id,rowmassive[key].row,18) end
		SetCell(t_id, rowmassive[key].row, 19, dell0(Options.pos.three.total2.prc))
		if Options.pos.three.ClosePos then func.red (t_id,rowmassive[key].row,19) else func.white (t_id,rowmassive[key].row,19) end
		SetCell(t_id, rowmassive[key].row, 20, dell0(Options.pos.three.total2.proffit))

		if Options.pos.three.total2.vol>0 then 
			SetCell(t_id, rowmassive[key].row, 21, memory.buy['three'..value.preffix2].n..'*'..dell0(memory.buy['three'..value.preffix2].lastprice))
			--SetCell(t_id, rowmassive[key].row, 24, dell0(memory.buy['three'..value.preffix2].price))
			func.yellow (t_id,rowmassive[key].row, 21)		
		elseif Options.pos.three.total2.vol<0 then 
			SetCell(t_id, rowmassive[key].row, 21, memory.sell['three'..value.preffix2].n..'*'..dell0(memory.sell['three'..value.preffix2].lastprice)) 
			--SetCell(t_id, rowmassive[key].row, 24, dell0(memory.sell['three'..value.preffix2].price))
			func.yellow (t_id,rowmassive[key].row, 21)	
		end
		SetCell(t_id, rowmassive[key].row, 24, dell0(Options.pos.three.total2.enterprice))
	end

	if Options.pos.one.vol==0 then func.gray (t_id,rowmassive[key].row,10)
	elseif Options.pos.one.vol==-100 then func.red (t_id,rowmassive[key].row,10)
	elseif Options.pos.one.vol==1 then func.white (t_id,rowmassive[key].row,10) end

	if Options.pos.two.vol==0 then func.gray (t_id,rowmassive[key].row,13) 
	elseif Options.pos.two.vol==-100 then func.red (t_id,rowmassive[key].row,13)
	elseif Options.pos.two.vol==1 then func.white (t_id,rowmassive[key].row,13) end 
	--if Options.pos.three.vol==0 then func.gray (t_id,rowmassive[key].row,16) else func.white (t_id,rowmassive[key].row,16) end

end

function MoneyManagment(stop,qty)
	--Функция управления капиталом - Контроль макисмального убытка за день
	--В день сумма убытка не должна быть больше 1% от капитала. Тогда в худшем случае за месяц потеряю 22%.
	--Если капитал 1.8 млн., тогда макс риск за день 18000, за месяц 396000. Максимальная прибыль за день 54000, за месяц 1188000
	--Реализация: считаю сумму убыточных стопов. Если она больше 18000, то новые сделки не открываю.
	--В расчет нужно включить текущий фин. результат за день. Т.е. прибыль в 10000 в этот день, позволит поставить убыточные стопы на сумму 28000. В худшем случае убыток за день не превысит 18000
	--При открытии сделки проверяю входит ли стоп в суточный лимит (18000)
	if stop==nil then stop=0 end
	if qty==nil then qty=0 end
	
	DayTradePath = getScriptPath()..'//DayTrade.txt'
	DayTradeTable=func.loadtable (DayTradePath)
	
	robot.DayTradeTableInit (DayTradeTable)
	-- считаем прибыль\потери за день
	DayProfit=0
	for number,data in pairs(DayTradeTable[func.date()]) do
		DayProfit=DayProfit+data[8]
	end
	--func.inTable (tt1, 'MoneyManagment '..DayProfit..' '..TotalRiskMemory..' '..tostring(TotalRiskMemory-DayProfit>18000))
	--к текущим стопам добавляем новый стоп - прибыть за день
	
	if TotalRiskMemory+func.correctsum(seccode,math.abs(PRICE-stop)*qty)-DayProfit>18000 then return false
	else return true
	end
end

function CalcToolTotal()--функция считает фин.результат по каждому инструменту по таблице trade
	local TradePath = getScriptPath()..'//trade.txt'
	local trade=func.loadtable(TradePath)
	local BigTotal=0
	if trade==nil then return BigTotal  end
	
	--for key,value in pairs(tool) do	
		local total=0
		for i=1, #trade, 1 do 
			--if trade[i][1]==key then
				total=total+trade[i][8]
				--func.inTable (tt1, 'CalcToolTotal '..tostring(i)..' '..tostring(trade[i][0])..' '..tostring(trade[i][8]).. ' '.. total)
			--end
		end	
		--if value.strategy202106~=nil then value.strategy202106.total=total end
		BigTotal=BigTotal+total
	--end
	return BigTotal
end

function closetradeOne (ttframe,seccode)

	ttframe2='two'..string.sub(ttframe,4)
	func.inTable (tt1, 'closetradeOne ttframe:'..ttframe..' ttframe2:'..ttframe2)
	robot.deletestop (ttframe)

	func.inTable (tt1, seccode..ttframe2..' closetradeOne buy vol:'..memory.buy[ttframe2].vol)	
	func.inTable (tt1, seccode..ttframe2..' closetradeOne buy newvol:'..memory.buy[ttframe2].newvol)

	func.inTable (tt1, seccode..ttframe..' closetradeOne buy vol:'..memory.buy[ttframe].vol)	
	func.inTable (tt1, seccode..ttframe..' closetradeOne buy newvol:'..memory.buy[ttframe].newvol)

	sum=func.correctsum (seccode,memory.buy[ttframe2].vol*memory.buy[ttframe2].price)
	sum2=func.correctsum (seccode,memory.buy[ttframe].vol*memory.buy[ttframe].price)	
	
	memory.buy[ttframe2].vol=memory.buy[ttframe2].vol+memory.buy[ttframe].vol
	memory.buy[ttframe2].price=(sum+sum2)/func.correctsum (seccode,memory.buy[ttframe2].vol)
	newsum=func.correctsum (seccode,memory.buy[ttframe].newvol*memory.buy[ttframe].newprice)
	newsum2=func.correctsum (seccode,memory.buy[ttframe2].newvol*memory.buy[ttframe2].newprice)
	memory.buy[ttframe2].newvol= memory.buy[ttframe2].newvol+memory.buy[ttframe].newvol
	if memory.buy[ttframe2].newvol~=0 then memory.buy[ttframe2].newprice=(newsum+newsum2)/func.correctsum (seccode,memory.buy[ttframe2].newvol) end

	func.inTable (tt1, ttframe2..' closetradeOne after buy vol:'..memory.buy[ttframe2].vol)	
	func.inTable (tt1, ttframe2..' closetradeOne after buy newvol:'..memory.buy[ttframe2].newvol)


	func.inTable (tt1, '-------------')
	
	func.inTable (tt1, seccode..ttframe2..' closetradeOne sell vol:'..memory.sell[ttframe2].vol)	
	func.inTable (tt1, seccode..ttframe2..' closetradeOne sell newvol:'..memory.sell[ttframe2].newvol)
	
	func.inTable (tt1, seccode..ttframe..' closetradeOne sell vol:'..memory.sell[ttframe].vol)	
	func.inTable (tt1, seccode..ttframe..' closetradeOne sell newvol:'..memory.sell[ttframe].newvol)
	
	sum=func.correctsum (seccode,memory.sell[ttframe2].vol*memory.sell[ttframe2].price)
	sum2=func.correctsum (seccode,memory.sell[ttframe].vol*memory.sell[ttframe].price)	
	memory.sell[ttframe2].vol=memory.sell[ttframe2].vol+memory.sell[ttframe].vol
	memory.sell[ttframe2].price=(sum+sum2)/func.correctsum (seccode,memory.sell[ttframe2].vol)
	newsum=func.correctsum (seccode,memory.sell[ttframe].newvol*memory.sell[ttframe].newprice)
	newsum2=func.correctsum (seccode,memory.sell[ttframe2].newvol*memory.sell[ttframe2].newprice)
	memory.sell[ttframe2].newvol= memory.sell[ttframe2].newvol+memory.sell[ttframe].newvol
	if memory.sell[ttframe2].newvol~=0 then memory.sell[ttframe2].newprice= (newsum+newsum2)/func.correctsum (seccode,memory.sell[ttframe2].newvol) end

	func.inTable (tt1, ttframe2..' closetradeOne after sell vol:'..memory.sell[ttframe2].vol)	
	func.inTable (tt1, ttframe2..' closetradeOne after sell newvol:'..memory.sell[ttframe2].newvol)

	memory.buy[ttframe].tool=seccode
	memory.buy[ttframe].n=0
	memory.buy[ttframe].vol=0
	memory.buy[ttframe].price=0
	memory.buy[ttframe].lastprice=0
	memory.buy[ttframe].closetrade='false'
	memory.buy[ttframe].firstdate=0
	memory.buy[ttframe].frommemory='false'
	memory.buy[ttframe].MaxRiskPrice=0
	memory.buy[ttframe].TakeProfit=0
	memory.buy[ttframe].comission=0
	memory.buy[ttframe].newvol=0
	memory.buy[ttframe].newprice=0
	
	memory.sell[ttframe].tool=seccode
	memory.sell[ttframe].n=0
	memory.sell[ttframe].vol=0
	memory.sell[ttframe].price=0
	memory.sell[ttframe].lastprice=0
	memory.sell[ttframe].closetrade='false'
	memory.sell[ttframe].firstdate=0
	memory.sell[ttframe].frommemory='false'
	memory.sell[ttframe].MaxRiskPrice=0
	memory.sell[ttframe].TakeProfit=0
	memory.sell[ttframe].comission=0
	memory.sell[ttframe].newvol=0
	memory.sell[ttframe].newprice=0

	func.inTable (tt1, 'closetradeOne FPath:'..FPath)
	func.savetable(memory,FPath)
end

function transaction(mem,tframe,bs,tool,trend,vol)
 
	ret=robot.transaction (mem,tframe,bs,tool,vol.TranVol)

	--if memory.buy[tframe].vol==memory.sell[tframe].vol and memory.sell[tframe].vol>0 then -- если сделка закрыта, то откладываем архив и обнуляем таблицу оперативной памяти
	--	robot.closetrade (tframe,tool,'operation',trend)
	--end
	return ret
end

function transaction2(key,operation,seccode,price,vol,tframe,classCode)
	--sleep(0)
	TransID= func.random()

	message ('transaction2 '..tostring(TransID))
	OrderTable[TransID]={}
	OrderTable[TransID].DateCtreate=func.datetime()
	OrderTable[TransID].key=key
	OrderTable[TransID].seccode=seccode
	OrderTable[TransID].vol=vol
	OrderTable[TransID].VolCompleted=0
	OrderTable[TransID].completed=false
	OrderTable[TransID].price=price
	OrderTable[TransID].operation=operation
	OrderTable[TransID].tframe=tframe
	OrderTable[TransID].TimeCreate=os.time()
	OrderTable[TransID].account=func.account()
	OrderTable[TransID].classCode=classCode	
	OrderTable[TransID].tradeprice=0
	OrderTable[TransID].lastprice=0
	OrderTable[TransID].statusorder=nil
	tran=func.tran (operation,seccode,price,vol,TransID,OrderTable[TransID].account,classCode) 

	OrderTable[TransID].statusorder=tran.statusorder	
	OrderTable[TransID].numorder=tran.numorder	
	OrderTable[TransID].msgorder=tran.msgorder	
	
	--func.savetable(OrderTable,OrderTablePath)
	SaveOrderTable=true
end

function sendtransaction2(TransID)
	func.inTable (tt1,'sendtransaction2 '..TransID)
	if OrderTable[TransID]==nil then return false end
	--tran=func.tran (OrderTable[TransID].operation,OrderTable[TransID].seccode,OrderTable[TransID].price,OrderTable[TransID].vol,TransID,OrderTable[TransID].account,OrderTable[TransID].classCode) 

	OrderTable[TransID].statusorder=3	
	OrderTable[TransID].numorder='123456789'	
	OrderTable[TransID].msgorder='Тестовая заявка'	
	OrderTable[TransID].balance=0
	OrderTable[TransID].VolCompleted=0
	if OrderTable[TransID].price<=0 then OrderTable[TransID].VolCompleted=OrderTable[TransID].vol end
	OrderTable[TransID].DateUpdate=os.time()
		
	--func.savetable(OrderTableLoc,OrderTablePath)
	SaveOrderTable=true

end

function CheckOrderTable()
	--OrderTable=func.loadtable(OrderTablePath)
	--func.inTable (tt1,'CheckOrderTable '..func.Tbl2Str(OrderTable))
	for id,order in pairs(OrderTable) do
		if order.VolCompleted~=order.vol and  not order.completed and order.statusorder==3 and func.calctrades (order.numorder, order.vol).vol==order.vol then 
			order.VolCompleted=order.vol
			func.inTable (tt1,'CheckOrderTable ID: '..id..' '..order.operation..' '..order.vol..' '..' помечен как исполненный')
		elseif  order.VolCompleted~=order.vol and  not order.completed and (order.statusorder==3 or order.statusorder==4) and func.CheckOrderActive(order.numorder)==false then 
--		elseif  order.VolCompleted~=order.vol and  not order.completed and func.CheckOrderActive(order.numorder)==false then 
			order.statusorder=-100
			func.inTable (tt1,'CheckOrderTable ID: '..id..' '..order.operation..' '..order.vol..' '..' на восстановление')
		end

		if order.statusorder==-100 then 
			sendtransaction2(id)
			--sleep(0)
		end
		--func.inTable (tt1,'CheckOrderTable '..func.Tbl2Str(order).. ' '..tostring(priceCandle))
		if not order.completed and order.VolCompleted~=order.vol and order.operation=='B' and order.price>0 and  order.price>=candlePrice then
			order.VolCompleted=order.vol
		elseif not order.completed and order.VolCompleted~=order.vol and order.operation=='S' and order.price>0 and  order.price<=candlePrice then
			order.VolCompleted=order.vol
		end
		
		if order.VolCompleted==order.vol and not order.completed then
			--FPath = getScriptPath()..'//'..order.key .. '.params'
			--memory=func.loadtable(FPath)
			--if order.operation=='B' then memorytable=memory.buy
			--elseif order.operation=='S' then memorytable=memory.sell
			--else return false end
			order.tradeprice=candlePrice
			order.completed=true
			if order.tradeprice~=0 and order.statusorder==3 and order.LinkedId==nil then
				--OrderTableArh=func.loadtable(OrderTableArhPath)
				--OrderTableArh[id]={}
				--OrderTableArh[id]=order
				OrderTable[id]=nil
				--func.savetable(OrderTableArh,OrderTableArhPath)
			end
			func.inTable (tt1,'CheckOrderTable VolCompleted: ID'..id..' '..order.operation..' '..order.seccode..' '.. order.VolCompleted..' * '..tostring(order.tradeprice))
			SaveOrderTable=true
			--func.savetable(OrderTable,OrderTablePath)
		end
		
		
	end
end

function InsertOrder(OrderTable,LocalOrderTablePath,key,seccode,operation,price,vol,tframe,LinkedId)
	TransID= func.random()

	OrderTable[TransID]={}
	OrderTable[TransID].DateCtraete=func.datetime()
	OrderTable[TransID].key=key
	OrderTable[TransID].seccode=seccode
	OrderTable[TransID].vol=vol
	OrderTable[TransID].VolCompleted=0
	OrderTable[TransID].completed=false
	OrderTable[TransID].price=price
	OrderTable[TransID].operation=operation
	OrderTable[TransID].tframe=tframe
	OrderTable[TransID].TimeCreate=os.time()
	OrderTable[TransID].statusorder=-100
	OrderTable[TransID].tradeprice=0
	OrderTable[TransID].lastprice=0
	OrderTable[TransID].LinkedId=LinkedId
	--func.inTable (tt1, 'InsertOrder OrderTablePath '..func.Tbl2Str(OrderTable[TransID]))

	if LocalOrderTablePath~=nil then 
		func.savetable(OrderTable,LocalOrderTablePath) 
	else SaveOrderTable=true end
	
	return TransID
end

function CalcSpred (order1, order2)
	local _spred=0
	if order1.operation=='B' and order2.operation=='S' then 	
		_spred=order1.vol*(order2.multiplier*OrderTable2[order2.IdOrder1].tradeprice-order1.multiplier*OrderTable1[order1.IdOrder1].tradeprice)
	elseif order2.operation=='B' and order1.operation=='S' then 	
		_spred=order1.vol*(order1.multiplier*OrderTable1[order1.IdOrder1].tradeprice-order2.multiplier*OrderTable2[order2.IdOrder1].tradeprice)
	end
	if order1.trend~=nil then 
		if Trends[order1.trend].profit==nil then Trends[order1.trend].profit=0 end
		Trends[order1.trend].profit=Trends[order1.trend].profit+_spred
		SaveTrends=true
	end
	return _spred
end

function trade(order1, order2)
	if order1.OrderTablePath~=nil and order1.OrderTablePath~=func.setting('OrderTablePath') then 
		OrderTable1 = func.loadtable(order1.OrderTablePath) 
		func.inTable (tt1, 'trade '..tostring (order1.key)..' загрузка '..tostring(order1.OrderTablePath))		
	else OrderTable1 = OrderTable end	
	if order2.OrderTablePath~=nil and order2.OrderTablePath~=func.setting('OrderTablePath')  then 
		OrderTable2 = func.loadtable(order2.OrderTablePath) 
		func.inTable (tt1, 'trade '..tostring (order2.key)..' загрузка '..tostring(order2.OrderTablePath))
	else OrderTable2 = OrderTable end	
	--func.inTable (tt1, 'order1:'..tostring(order1.IdOrder1)..' order2:'..tostring(order2.IdOrder1)..tostring(func.Tbl2Str(OrderTable2)))
	if order2.IdOrder1~=nil and OrderTable2[order2.IdOrder1].completed then 
		order1.n=order1.n-1
		local _spred=0
		_spred=CalcSpred(order1, order2)
		func.inTable (tt1, order1.n..' ордер1 ID'..order1.IdOrder1.. ': '..tostring(order1.trend)..' '..order1.seccode..' '..order1.operation..' '..order1.vol..'*'..OrderTable1[order1.IdOrder1].tradeprice..' '..tostring(order1.name))	
		func.inTable (tt1, order1.n..' ордер2 ID'..order2.IdOrder1.. ': '..tostring(order2.trend)..' '..order2.seccode..' '..order2.operation..' '..order2.vol..'*'..OrderTable2[order2.IdOrder1].tradeprice..' '..tostring(order2.name)..' Спред:'.._spred..'р '..order2.multiplier*OrderTable2[order2.IdOrder1].tradeprice-order1.multiplier*OrderTable1[order1.IdOrder1].tradeprice)
		--robot.inform ('Close trend '..tostring(order1.trend)..' spred:'.._spred..'р '..order2.multiplier*OrderTable2[order2.IdOrder1].tradeprice-order1.multiplier*OrderTable1[order1.IdOrder1].tradeprice)
		OrderTable1[order1.IdOrder1]=nil
		OrderTable2[order2.IdOrder1]=nil
		order1.IdOrder1=nil
		order2.IdOrder1=nil
		if order1.OrderTablePath~=nil then func.savetable(OrderTable1,order1.OrderTablePath) else SaveOrderTable=true end	
		if order2.OrderTablePath~=nil then func.savetable(OrderTable2,order2.OrderTablePath) end	
		--func.savetable(Orders,OrdersPath)
		SaveOrders=true
	elseif order1.IdOrder1~=nil and OrderTable1[order1.IdOrder1].completed and order2.IdOrder1==nil then 
		--func.inTable (tt1, order1.n..' 'Создаем ордер 2 '..' '..order2.operation..' '..order2.vol..' '..order2.key..' '..order2.seccode )	
		UpPrice=0
		if order2.operation=='B' then UpPrice=order1.diff*-1
		elseif order2.operation=='S' then UpPrice=order1.diff
		end
		local mult1=1
		if order1.multiplier~=nil then mult1=order1.multiplier end
		local mult2=1
		if order2.multiplier~=nil then mult2=order2.multiplier end
		order2.IdOrder1=InsertOrder(OrderTable2,order2.OrderTablePath,order2.key,order2.seccode,order2.operation,((OrderTable1[order1.IdOrder1].tradeprice)*mult1+UpPrice)/mult2,order2.vol,order2.tframe,order1.IdOrder1)	
		--func.savetable(Orders,OrdersPath)	
		SaveOrders=true
		func.inTable (tt1, order1.n..' Ждем ордер2 ID'..order2.IdOrder1.. ' '..tostring(order2.trend)..' :'..order2.operation..' '..order2.seccode..' '..order2.vol..' '..tostring(((OrderTable1[order1.IdOrder1].tradeprice)*mult1+UpPrice)/mult2))	
	elseif order1.IdOrder1==nil then 
		--func.inTable (tt1, order1.n..' 'Создаем ордер 1 '..' '..order1.operation..' '..order1.vol..' '..order1.key..' '..order1.seccode )
		order1.IdOrder1=InsertOrder(OrderTable1,order1.OrderTablePath,order1.key,order1.seccode,order1.operation,-1,order1.vol,order1.tframe,0)
		--func.savetable(Orders,OrdersPath)	
		SaveOrders=true
		func.inTable (tt1, order1.n..' Ждем ордер1 ID'..order1.IdOrder1.. ' '..tostring(order1.trend)..' :'..order1.operation..' '..order1.seccode..' '..order1.vol..' '..tostring(order1.name))			
		--robot.inform ('Open trend '..tostring(order1.trend))
		--func.inTable (tt1, 'trade OrderTable1:'..func.Tbl2Str(OrderTable1[order1.IdOrder1]))
		--func.inTable (tt1, 'trade OrderTable:'..func.Tbl2Str(OrderTable[order1.IdOrder1]))
	end
end


function SmartTrade()

	--Orders = func.loadtable(OrdersPath)	
	
	for numb,orders in pairs(Orders) do
		--func.inTable (tt1, 'SmartTrade '..numb)
		if orders.order1.n>0 and orders.order1.enable then 
			trade(orders.order1, orders.order2)
			--sleep(0)
		end
		--if orders.order1.n==0 then 
		--	NewTrade(numb)
		--end
	end
end

function CompleteOrders(key,mode,operation, trend)

	--Orders = func.loadtable(OrdersPath)	
	--Trends = func.loadtable(TrendsPath)	
	--if key=='IMOEXF-MMU' then return true end
	
	--func.inTable (tt1, 'CompleteOrders '..operation)
	
	for numb,orders in pairs(Orders) do
		if orders.order2.key==key 
			and orders.order1.mode~=nil 
			and orders.order1.mode==mode 
			and orders.order1.n>0 
			and orders.order1.enable 
			and (trend==nil or (orders.order1.trend~=nil and orders.order1.trend==trend))
			and orders.order2.IdOrder1~=nil 
			and orders.order2.operation==operation
			and (orders.order2.OrderTablePath==nil or orders.order2.OrderTablePath==func.setting('OrderTablePath'))  then 
				--local OrderTableLoc = func.loadtable(OrderTablePath)
				local OrderTableLoc=OrderTable
				if not OrderTableLoc[orders.order2.IdOrder1].completed then 
--					if func.killorder(OrderTableLoc[orders.order2.IdOrder1].numorder,OrderTableLoc[orders.order2.IdOrder1].seccode) then 
						--func.inTable (tt1, 'CompleteOrders OrderTableId='..orders.order2.IdOrder1)
						orders.order1.n=1
						OrderTableLoc[orders.order2.IdOrder1].price=0
						OrderTableLoc[orders.order2.IdOrder1].statusorder=-100
						--func.savetable(Orders,OrdersPath)
						--func.savetable(OrderTableLoc,OrderTablePath)
						SaveOrders=true
						SaveOrderTable=true
						if operation=='B' then Trends[trend].StopSell=Trends[trend].StopSell+1
						elseif operation=='S' then Trends[trend].StopBuy=Trends[trend].StopBuy+1 end
						func.inTable (tt1, 'CompleteOrders '..trend..' '..mode..' '.. operation.. ' ID:'..orders.order2.IdOrder1)
--					end
				end
		end
	end
	--Trends = func.loadtable(TrendsPath)	
	for name,trend in pairs(Trends) do	
		if trend.key==key and trend.mode==mode and (trend==nil or (name==trend))then 
			if operation=='B' then trend.mode='long'
			elseif operation=='S' then trend.mode='short' end
		end
	end
	--func.savetable(Trends,TrendsPath)
	SaveTrends=true
end

function CompleteIdOrder(IdOrder,stopSeccode,stopTframe)

	--Orders = func.loadtable(OrdersPath)	
	
	if Orders[IdOrder]~=nil then
		--local OrderTableLoc = func.loadtable(OrderTablePath)
		local OrderTableLoc
		if Orders[IdOrder].order2.OrderTablePath~=nil then 
			--OrderTableLoc = func.loadtable(Orders[IdOrder].order2.OrderTablePath)
			func.inTable (tt1, 'CompleteIdOrder OrderTableLoc='..tostring(Orders[IdOrder].order2.OrderTablePath)..' ID:'..tostring(IdOrder)..' order:'..tostring(Orders[IdOrder].order2.IdOrder1))
			return
		else OrderTableLoc=OrderTable end
		
		if Orders[IdOrder].order2.IdOrder1~=nil and not OrderTableLoc[Orders[IdOrder].order2.IdOrder1].completed then 
			--if func.killorder(OrderTableLoc[Orders[IdOrder].order2.IdOrder1].numorder,OrderTableLoc[Orders[IdOrder].order2.IdOrder1].seccode) then 
				Orders[IdOrder].order1.n=1
				OrderTableLoc[Orders[IdOrder].order2.IdOrder1].price=0
				OrderTableLoc[Orders[IdOrder].order2.IdOrder1].statusorder=-100
				if stopSeccode~=nil then OrderTableLoc[Orders[IdOrder].order2.IdOrder1].seccode=stopSeccode end
				if stopTframe~=nil then OrderTableLoc[Orders[IdOrder].order2.IdOrder1].tframe=stopTframe end
				--func.savetable(Orders,OrdersPath)
				--func.savetable(OrderTableLoc,OrderTablePath)
				SaveOrders=true
				--if Orders[IdOrder].order2.OrderTablePath~=nil then 
				--	func.savetable(OrderTableLoc,Orders[IdOrder].order2.OrderTablePath)
				--	func.inTable (tt1, 'CompleteIdOrder запись OrderTableLoc='..tostring(func.Tbl2Str(OrderTableLoc[Orders[IdOrder].order2.IdOrder1])))
				--else SaveOrderTable=true end
				SaveOrderTable=true
				func.inTable (tt1, 'CompleteIdOrder '..' ID:'..IdOrder)
				return true
			--end
		end
	end
end

function InsertOrders(order1,order2)
	
	--Orders = func.loadtable(OrdersPath)	
	OrdersID=func.random()
	func.inTable (tt1, 'InsertOrders '..OrdersID..' order1:' ..func.Tbl2Str(order1))		
	func.inTable (tt1, 'InsertOrders '..OrdersID..' order2:' ..func.Tbl2Str(order2))	

	Orders[OrdersID]={}
    Orders[OrdersID]['order1']={}
    Orders[OrdersID]['order1']['vol']=order1.vol
    Orders[OrdersID]['order1']['seccode']=order1.seccode
    Orders[OrdersID]['order1']['n']=order1.n
    Orders[OrdersID]['order1']['operation']=order1.operation
    Orders[OrdersID]['order1']['key']=order1.key
    Orders[OrdersID]['order1']['diff']=order1.diff
    Orders[OrdersID]['order1']['tframe']=order1.tframe
	Orders[OrdersID]['order1']['enable']=true
	Orders[OrdersID]['order1']['mode']=order1.mode
	Orders[OrdersID]['order1']['multiplier']=order1.multiplier
	Orders[OrdersID]['order1']['trend']=order1.trend

    Orders[OrdersID]['order2']={}
    Orders[OrdersID]['order2']['vol']=order2.vol
    Orders[OrdersID]['order2']['seccode']=order2.seccode
    Orders[OrdersID]['order2']['n']=order2.n
    Orders[OrdersID]['order2']['operation']=order2.operation
    Orders[OrdersID]['order2']['key']=order2.key
    Orders[OrdersID]['order2']['diff']=order2.diff
    Orders[OrdersID]['order2']['tframe']=order2.tframe
    Orders[OrdersID]['order2']['enable']=true
	Orders[OrdersID]['order2']['mode']=order1.mode
	Orders[OrdersID]['order2']['multiplier']=order2.multiplier
	Orders[OrdersID]['order2']['trend']=order2.trend

	if order1.OrderTablePath~=nil and order2.OrderTablePath~=nil then 
		Orders[OrdersID]['order1']['OrderTablePath']=order1.OrderTablePath
		Orders[OrdersID]['order2']['OrderTablePath']=order2.OrderTablePath
	end
	
	--func.savetable(Orders,OrdersPath)
	SaveOrders=true
	return OrdersID
end


function CheckOrdersComplete(ordersID)
	local LocSumOrders=0
	if ordersID~=0 and Orders[ordersID]~=nil and Orders[ordersID].order1.IdOrder1==nil and Orders[ordersID].order2.IdOrder1==nil and Orders[ordersID].order1.n==0 then 
			LocSumOrders=Orders[ordersID].order2.n
			Orders[ordersID]=nil
			--func.savetable(Orders,OrdersPath)
			SaveOrders=true
			func.inTable (tt1, 'CheckOrdersComplete '..	ordersID..' последовательность ордеров завершена')
			return LocSumOrders
	end
	return LocSumOrders
end

function InsertTrends(arr,op,OpMult,trends,QtyStep)
	if trends.mode~='flat' and trends.mode~='all' then return false end
	if QtyStep==nil then QtyStep=2 end
	local arr2={}
	if op=='B' then  arr2=trends.sell
	elseif op=='S' then  arr2=trends.buy end
	local m=0
	local PriceSec2 --=arr.tradeprice-OpMult*arr.spred-OpMult*trends.step/seccode2.multiplier 

	for n=1, #arr2,1 do 
		if arr2[n].ordersID~=0 then 
			PriceSec2=arr.price1
			func.inTable (tt1, '1 InsertTrends OpMult='..OpMult..' '..tostring(OpMult*arr.price1-QtyStep*trends.step-OpMult*arr2[n].price1<0)..' Price1('..OpMult*arr.price1..')-QtyStep*trends.step('..QtyStep*trends.step..')-OpMult*arr2[n].price1('..OpMult*arr2[n].price1..'<0')		
			if OpMult*arr.price1-QtyStep*trends.step-OpMult*arr2[n].price1<0 then return false end
		end
	end
	local ret=false
	for n=1, #arr2,1 do 
		if ret and arr2[n].ordersID==0  and arr2[n+1]==nil and arr2[n+2]==nil and arr2[n+3]==nil then arr2[n]=nil 
		elseif arr2[n].ordersID==0 and not ret then 
			arr2[n].price1=arr.price1-OpMult*trends.step--/arr2[n].multiplier
			func.inTable (tt1, '2 InsertTrends '..op..' n='..n..' обновление цены входа в позицию на '..arr2[n].price1)	
			ret=true 
		end		
		m=n
	end
	if ret then return true end  
	arr2[m+1]={}
	arr2[m+1].price1=arr.price1-OpMult*trends.step--/arr2[m].multiplier
	arr2[m+1].multiplier=arr2[m].multiplier
	arr2[m+1].ordersID=0
	func.inTable (tt1, '2 InsertTrends '..op..' n '..(m+1)..' '..func.Tbl2Str(arr2[m+1]))	
	return true 
end

function FindNearOrder(op,trends, FindPrice)
	local arr2={}
	local locOpnum=0
	if op=='B' then  
		arr2=trends.buy
		locOpnum=1
	elseif op=='S' then  
		arr2=trends.sell 
		locOpnum=-1
	end
	local locPrice=0
	
	for n=1, #arr2,1 do 
		if 	arr2[n].ordersID~=nil and locOpnum*arr2[n].price1-locOpnum*FindPrice>0 then
			locPrice=arr2[n].price1
		end		
	end
	if locPrice==0 and op=='B' then return trends.long1
	elseif locPrice==0 and op=='S' then return trends.short1
	else return locPrice end
end

function TrendsCicle(arr,op,trends,seccode1,seccode2,name)
	local OpMult=0
	
	if op=='B' then OpMult=1
	elseif op=='S' then OpMult=-1 end
	for n=1, #arr,1 do 
		--проверяем выполнены ли ордера 
		--func.inTable (tt1, name..tostring(func.Tbl2Str(arr[n])))
		if CheckOrdersComplete(arr[n].ordersID)>0 then 
			func.inTable (tt1,tostring(candles[CandleNum].open)..' '..DateTimeStr(candles[CandleNum].datetime)..' профит:'..trends.profit)
			InsertTrends(arr[n],op,OpMult,trends,2)
			--InsertTrends(arr[n],'B',1,trends,1)
			--InsertTrends(arr[n],'S',-1,trends,1)			
			if n==1 then 
				arr[n].ordersID=0
				arr[n].price1=0
				arr[n].stopprice=0
				arr[n].tradeprice=0
			elseif arr[n+1]==nil and arr[n+2]==nil and arr[n+3]==nil then   
				arr[n]=nil 
			else 
				arr[n].ordersID=0
				arr[n].price1=0		
				arr[n].stopprice=0
				arr[n].tradeprice=0				
			end
			--trends.orders=trends.orders+1
			--func.savetable(Trends,TrendsPath)
			SaveTrends=true
		end
		--if arr[n]==nil then break end
		--заполняем цену первого ордера 
		--func.inTable (tt1, '0 TrendsCicle '..tostring(arr[n].ordersID))
		if arr[n]~=nil and arr[n].ordersID~=0 
		and OrderTable[Orders[arr[n].ordersID].order1.IdOrder1]~=nil
		and OrderTable[Orders[arr[n].ordersID].order1.IdOrder1].tradeprice~=0
		and arr[n].tradeprice~=OrderTable[Orders[arr[n].ordersID].order1.IdOrder1].tradeprice then
			arr[n].tradeprice=OrderTable[Orders[arr[n].ordersID].order1.IdOrder1].tradeprice
			--arr[n].price1=(arr[n].tradeprice-arr[n].spred)*arr[n].multiplier
			arr[n].price1=arr[n].tradeprice*arr[n].multiplier-arr[n].spred
			arr[n].stopprice=arr[n].price1-OpMult*trends.step*4
			if trends.StopStep~=nil and trends.StopStep~=0 then arr[n].stopprice=arr[n].price1-OpMult*trends.StopStep end
			trends.orders=trends.orders+1
			func.inTable (tt1, '1 TrendsCicle key:'..trends.key..' op:'..op..' tradeprice:' ..	arr[n].tradeprice..' price1 '..arr[n].price1..' stopprice '..arr[n].stopprice..' Orders+1='..trends.orders)
			--устанавливаем условие цены для открытия позиции short
			InsertTrends(arr[n],op,OpMult,trends)
			--func.savetable(Trends,TrendsPath)
			SaveTrends=true
		end
		
		local BuySign=false
		local SellSign=false
		local orderSeccode1={}
		local orderSeccode2={}
		local diff=0
		local num=1
		
		local spred=seccode2.PRICE-seccode1.PRICE
		if trends.spred~=nil then spred=trends.spred end 

		if trends.op1~=trends.op2 and trends.op1=='S' then diff=spred*-1+trends.step
		elseif trends.op1~=trends.op2 and trends.op1=='B' then diff=spred+trends.step end
		if arr[n]~=nil and arr[n].step~=nil and arr[n].step~=0 then diff=arr[n].step end

		orderSeccode1.vol=trends.stepvol
		orderSeccode1.key=trends.key
		orderSeccode1.seccode=trends.seccode1
		orderSeccode1.operation=trends.op1
		orderSeccode1.tframe=trends.pos1..seccode1.preffix
		orderSeccode1.diff=diff
		orderSeccode1.mode=trends.mode
		orderSeccode1.multiplier=seccode1.multiplier
		orderSeccode1.trend=name
		
		orderSeccode2.multiplier=seccode2.multiplier				
		orderSeccode2.mode=trends.mode
		orderSeccode2.vol=trends.stepvol
		orderSeccode2.key=trends.key
		orderSeccode2.seccode=trends.seccode2
		orderSeccode2.operation=trends.op2
		orderSeccode2.tframe=trends.pos2..seccode2.preffix
		orderSeccode2.diff=diff
		orderSeccode2.trend=name
		
		if trends.OrderTablePath1~=nil and trends.OrderTablePath2~=nil then 
			orderSeccode1.OrderTablePath=trends.OrderTablePath1
			orderSeccode2.OrderTablePath=trends.OrderTablePath2
		end
		
		--проверяем условия для открытия позиций
		if seccode1.PRICE==0 and seccode2.PRICE==0 then return false end
		
		if  arr[n]~=nil and arr[n].price1~=0 and arr[n].stopprice~=0 and op=='B' and arr[n].ordersID~=0 and arr[n].stopprice>seccode1.PRICE_OFFER and seccode1.PRICE_OFFER~=0  then  
			if arr[n].StopTime==nil then arr[n].StopTime=0 end
			arr[n].StopTime=arr[n].StopTime+1
			local timer=300
			if arr[n].price1<=arr[n].stopprice then  arr[n].StopTime=5  end
			func.inTable (tt1, '2.1!!! StopTime=' ..arr[n].StopTime)
			--func.inTable (tt1, '2.1!!! ' ..os.time()-arr[n].StopTime..' '..arr[n].StopTime ..' TrendsCicle стопцена='..arr[n].stopprice..' для ordersID='..arr[n].ordersID..' '..op..' key:'..trends.key..' StopBuy+1='..trends.StopBuy..' timer='..timer)
			if arr[n].StopTime>=5 and CompleteIdOrder(arr[n].ordersID,trends.stopSeccode,trends.stopTframe)	then 
				arr[n].price1=arr[n].stopprice				
				trends.StopBuy=trends.StopBuy+1 
				--InsertTrends(arr[n],'S',OpMult*-1,trends,1)
				func.inTable (tt1, '2!!! TrendsCicle стопцена='..arr[n].stopprice..' для ordersID='..arr[n].ordersID..' '..op..' key:'..trends.key..' StopBuy+1='..trends.StopBuy..' timer='..timer)
				--robot.inform ('!STOP trend '..trends.key..' StopPrice='..arr[n].stopprice)
			end
			--func.savetable(Trends,TrendsPath)
			SaveTrends=true		
		elseif arr[n]~=nil and arr[n].price1~=0 and arr[n].stopprice~=0 and op=='S' and arr[n].ordersID~=0 and arr[n].stopprice<seccode1.PRICE_BID and seccode1.PRICE_BID~=0 then  
			if arr[n].StopTime==nil then arr[n].StopTime=0 end
			arr[n].StopTime=arr[n].StopTime+1
			local timer=300
			if arr[n].price1>=arr[n].stopprice then arr[n].StopTime=5 end
			func.inTable (tt1, '2.1!!! StopTime=' ..arr[n].StopTime)
			if arr[n].StopTime>=5 and CompleteIdOrder(arr[n].ordersID,trends.stopSeccode,trends.stopTframe)	then 
				arr[n].price1=arr[n].stopprice
				trends.StopSell=trends.StopSell+1 
				--InsertTrends(arr[n],'B',OpMult*-1,trends,1)
				func.inTable (tt1, '3!!! TrendsCicle стопцена='..arr[n].stopprice..' для ordersID='..arr[n].ordersID..' '..op..' key:'..trends.key..' StopSell+1='..trends.StopSell..' timer='..timer)			
				--robot.inform ('!STOP trend '..trends.key..' StopPrice='..arr[n].stopprice)
			end
			--func.savetable(Trends,TrendsPath)
			SaveTrends=true
		elseif arr[n]~=nil and arr[n].price1~=0 and op=='B' and arr[n].price1<seccode1.PRICE_OFFER and  arr[n].ordersID==0  then 
			BuySign=true
			num=func.round((FindNearOrder(op,trends, arr[n].price1)-seccode1.PRICE_OFFER)/(trends.step),0)
			--func.inTable (tt1, '4.5 TrendsCicle tradeprice '..tostring(trends.key).. ' num:'..tostring(num))
		elseif arr[n]~=nil and arr[n].price1~=0 and op=='S' and arr[n].price1>seccode1.PRICE_BID and  arr[n].ordersID==0 then 
			SellSign=true 
			num=func.round((seccode1.PRICE_BID-FindNearOrder(op,trends, arr[n].price1))/trends.step,0)
		elseif arr[n]~=nil and arr[n].StopTime~=nil and arr[n].StopTime>0 then 
			arr[n].StopTime=0
			func.inTable (tt1, '2.2 StopTime=' ..arr[n].StopTime)
			SaveTrends=true
		end

		if trends.num~=nil and trends.num<num then num=trends.num end
		orderSeccode1.n=num
		orderSeccode2.n=num
		
		if BuySign and trends.op1=='B' and num>=1 then 
			arr[n].ordersID=InsertOrders(orderSeccode1,orderSeccode2)
			arr[n].spred=0
			arr[n].multiplier=seccode1.multiplier
			arr[n].tradeprice=0
			arr[n].stopprice=0
		elseif BuySign and trends.op2=='B' and num>=1  then 
			arr[n].ordersID=InsertOrders(orderSeccode2,orderSeccode1) 
			arr[n].spred=spred
			arr[n].multiplier=seccode2.multiplier
			arr[n].tradeprice=0
			arr[n].stopprice=0
		elseif SellSign and trends.op1=='S' and num>=1  then 
			arr[n].ordersID=InsertOrders(orderSeccode1,orderSeccode2)
			arr[n].spred=0
			arr[n].multiplier=seccode1.multiplier
			arr[n].tradeprice=0
			arr[n].stopprice=0
		elseif SellSign and trends.op2=='S' and num>=1  then 
			arr[n].ordersID=InsertOrders(orderSeccode2,orderSeccode1) 
			arr[n].spred=spred
			arr[n].multiplier=seccode2.multiplier
			arr[n].tradeprice=0
			arr[n].stopprice=0
		end
		if (BuySign or SellSign) and num>=1  then 
			func.inTable (tt1, 'TrendsCicle '..trends.key ..' BuySign '..tostring(BuySign)..' SellSign '..tostring(SellSign) )
			--func.savetable(Trends,TrendsPath)
			--func.savetable(Orders,OrdersPath)
			SaveOrders=true
			SaveTrends=true
			
			--func.inTable (tt1, 'TrendsCicle '..	trends.key..' num:'..num..' orderSeccode1:' ..func.Tbl2Str(orderSeccode1))			
			--func.inTable (tt1, 'TrendsCicle '..	trends.key..' num:'..num..' orderSeccode2:' ..func.Tbl2Str(orderSeccode2))						
		end
	end
end

function ClearOrderTable()
	Orders = func.loadtable(OrdersPath)	
	Trends = func.loadtable(TrendsPath)	
	OrderTable=func.loadtable(OrderTablePath)

	for id, order in pairs (OrderTable) do
		local isFind=false
		for orderId, orders in pairs (Orders) do
			if orders.order1.IdOrder1==id or orders.order2.IdOrder1==id then isFind=true end
		end
		if not isFind then 
			func.inTable (tt1, 'not Find id: '..id)
			OrderTable[id]=nil 
		end
	end
	func.savetable(OrderTable,OrderTablePath)
end

function CompleteOrders2()

--CompleteIdOrder(35144)
--Orders[42752]=nil
--SaveOrders=true

end

function ClearOrders()

	local OrderTableLoc=func.loadtable(OrderTablePath)
	for orderId, orders in pairs (Orders) do
		if not FindInTrends (orderId) and orders.order2.IdOrder1~=nil and orders.order2.OrderTablePath==nil then 
			func.inTable (tt1, 'not Find id: '..orderId..' '..tostring(orders.order1.trend)..' '..orders.order1.operation.. ' '..orders.order1.vol..' '..OrderTableLoc[orders.order1.IdOrder1].tradeprice)
		end
	end
end

function FindInTrends(idOrders)

	for _trend,_trends in pairs(Trends) do
		if _trends.enable then   
			for _order,_orders in pairs(_trends.buy) do
				if  _orders.ordersID==idOrders then return true end
			end
			for _order,_orders in pairs(_trends.sell) do
				if  _orders.ordersID==idOrders then return true end
			end
		end
	end
	return false
end

function trends()

	--Trends = func.loadtable(TrendsPath)	
	--Orders = func.loadtable(OrdersPath)	
	if 1==2 and func.TimePassed(18,48,50) and not func.TimePassed(18,50,50) and Trends['IMOEXF-MMZ5-fun']~=nil and Trends['IMOEXF-MMZ5-fun'].enable==false then 
		Trends['IMOEXF-MMZ5-fun'].enable=true
		SaveTrends=true
		func.inTable (tt1, 'trends IMOEXF-MMZ5-fun enable')
	end 
	if 1==2 and func.TimePassed(18,48,50) and not func.TimePassed(18,50,50) and Trends['EURRUBF-EuZ5-fun']~=nil and Trends['EURRUBF-EuZ5-fun'].enable==false then 
		Trends['EURRUBF-EuZ5-fun'].enable=true		
		SaveTrends=true		
		func.inTable (tt1, 'trends EURRUBF-EuZ5-fun enable')
	end 
	if 1==2 and func.TimePassed(18,48,50)  and not func.TimePassed(18,50,50) and Trends['USDRUBF-SiZ5-fun2']~=nil and Trends['USDRUBF-SiZ5-fun'].enable==false then 
		Trends['USDRUBF-SiZ5-fun'].enable=true		
		SaveTrends=true		
		func.inTable (tt1, 'trends USDRUBF-SiZ5-fun enable')
	end 
	for name,trends in pairs(Trends) do
		if trends.enable then 

			local seccode1={}
			local seccode2={}
			--заполняем массивы seccode1 и seccode2 по данным из tool
			if tool[trends.key].seccode1.seccode==trends.seccode1 then seccode1=tool[trends.key].seccode1
			elseif  tool[trends.key].seccode2.seccode==trends.seccode1 then seccode1=tool[trends.key].seccode2 end
			if tool[trends.key].seccode1.seccode==trends.seccode2 then seccode2=tool[trends.key].seccode1
			elseif  tool[trends.key].seccode2.seccode==trends.seccode2 then seccode2=tool[trends.key].seccode2 end
			if seccode1~=nil or seccode2~=nil then 
				if (trends.mode=='trend' or trends.mode=='trendReverse') then TrendStrategy(seccode1,seccode2)
				else
					TrendsCicle(trends.buy,'B',trends,seccode1,seccode2,name)
					TrendsCicle(trends.sell,'S',trends,seccode1,seccode2,name)
					TrendsCalculate(true)
					GridStrategy()
				end
				--CompleteOrders2()
				--if progessbar==0 then func.yellow (t_id,rowmassive[trends.key..trends.seccode1].row, 9)
				--elseif progessbar==1 then func.white (t_id,rowmassive[trends.key..trends.seccode1].row, 9) end
			end
		end
	end
end

function FindPrice(value,isBuy,multiplier)	
	--if isBuy then _op='B'
	--else _op='S' end
	--if value.op1==_op then _seccode=value.seccode1
	--elseif 	value.op2==_op then _seccode=value.seccode2 end

	if tool[value.key].seccode1.seccode==value.seccode1 then _secObj=tool[value.key].seccode1
	elseif tool[value.key].seccode2.seccode==value.seccode1 then _secObj=tool[value.key].seccode2 end	
	
	if isBuy and _secObj.StateTableM30_parType=="сопротивление" then return _secObj.StateTableM30_par*multiplier
	elseif not isBuy and _secObj.StateTableM30_parType=="поддержка" then return _secObj.StateTableM30_par*multiplier
	else return 0 end
end

function TrendsCheck()

	for _trend,_trends in pairs(Trends) do
		if _trends.enable then   
			func.inTable (tt1, 'CheckTrends '.. _trend)
			local _isEmpty=true
			for _order,_orders in pairs(_trends.buy) do
				if _orders.price1~=0 then _isEmpty=false end
				_orders.parM30=0
				if _orders.ordersID==0 then _orders.parM30=FindPrice(_trends,true,_orders.multiplier) end
				--if 	_orders.parM30~=0 then func.inTable (tt1, '	CheckTrends '.. _trend .. ' buy price1='.._orders.price1..' par price1='.._orders.parM30) end
			end
			if _isEmpty then func.inTable (tt1, '	CheckTrends '.. _trend .. ' buy price1=0') end

			local _isEmpty=true
			for _order,_orders in pairs(_trends.sell) do
				if _orders.price1~=0 then _isEmpty=false end
				_orders.parM30=0
				if _orders.ordersID==0 then _orders.parM30=FindPrice(_trends,false,_orders.multiplier) end
				--if 	_orders.parM30~=0 then func.inTable (tt1, '	CheckTrends '.. _trend .. ' sell price1='.._orders.price1..' par price1='.._orders.parM30) end
			end
			if _isEmpty then func.inTable (tt1, '	CheckTrends '.. _trend .. ' sell price1=0') end
		end
	end
	func.savetable(Trends,TrendsPath)
end
	
function TrendsFindPrice(op, trend)
	local price=0
	if trend.op1==op and tool[trend.key].seccode1.seccode==trend.seccode1 then price=tool[trend.key].seccode1.PRICE 
	elseif trend.op2==op and tool[trend.key].seccode2.seccode==trend.seccode2 then price=tool[trend.key].seccode2.PRICE 
	elseif trend.op1==op and tool[trend.key].seccode2.seccode==trend.seccode1 then price=tool[trend.key].seccode2.PRICE 
	elseif trend.op2==op and tool[trend.key].seccode1.seccode==trend.seccode2 then price=tool[trend.key].seccode1.PRICE 
	end
	
	return price
end

function TrendsProfitTake(_trend,_trends, volRest,sum)
	func.inTable (tt1,  'TrendsProfitTake '.. _trend .. ' profit('.._trends.profit..')>MaxProfit('.._trends.MaxProfit..')')
	--robot.inform (_trend ..' profit>'.._trends.MaxProfit)
	CompleteOrders(_trends.key,'grid','B', _trend)
	CompleteOrders(_trends.key,'grid','S', _trend)
	_trends.orders=0-volRest
	_trends.StopSell=0
	_trends.StopBuy=0
	--_trends.profit=0-sum
	_trends.mode='grid'
	SaveTrends=true
end

function inPriceRange(priceMax, priceMin, step)
	if (priceMax-priceMin)<step*2 and (priceMax-priceMin)>0 then return true
	else return false end
end

function TimerInit(field)
	if field==nil then field=0 end
	if field==0 then field=os.time() end
end
function TimerCheck(field, timer)
	if (field~=0 and field>=timer) then  return true end
	return false
end

function DateTbl(year,month,day,hour,min)

	local epoch_time = os.time()
	local datetime = os.date("*t",epoch_time)
	
	datetime.year = year
	datetime.month = month
	datetime.year = year
	datetime.day = day
	datetime.hour = hour
	datetime.min = min
	return datetime
end

function CheckDate(date1,date2)
	
	--func.inTable (tt1,'CheckDate '..DateTimeStr(candles[CandleNum].datetime)..' date1 '..DateTimeStr(date1)..' date2 '..DateTimeStr(date2))
	if os.time(candles[CandleNum].datetime)>=os.time(date1) and os.time(candles[CandleNum].datetime)<=os.time(date2) then 
		func.inTable (tt1,'CheckDate '..tostring(candles[CandleNum].open)..' '..DateTimeStr(candles[CandleNum].datetime))
		return true
	else 
		return false 
	end
	
end

function LongTrendCheck()
	
	if 1==1 then return false end
	
	local date1=DateTbl(2026,1,30,9,30)
	local date2=DateTbl(2027,8,19,10,0)
	
	local date3=DateTbl(2027,12,09,12,0)
	local date4=DateTbl(2027,12,22,8,30)
	
	local date5=DateTbl(2027,2,9,10,0)
	local date6=DateTbl(2027,12,09,11,30)

	if CheckDate(date1,date2) then 
		return true
	elseif CheckDate(date3,date4) then 
		return true
	elseif CheckDate(date5,date6) then 
		return true
	else 
		return false
	end

end

function ShortTrendCheck()
	--func.inTable (tt1,'ShortTrendCheck')
	if 1==1 then return true end
	 
	local date1=DateTbl(2025,11,19,10,0)
	local date2=DateTbl(2025,12,09,11,30)
	
	local date3=DateTbl(2025,12,22,9,0)
	local date4=DateTbl(2025,12,30,10,30)
	
	local date5=DateTbl(2026,1,9,10,0)
	local date6=DateTbl(2026,12,09,11,30)

	if CheckDate(date1,date2) then 
		return true
	elseif CheckDate(date3,date4) then 
		return true
	elseif CheckDate(date5,date6) then 
		return true
	else 
		return false
	end

end

function CheckMaxLevel (_trends, isBuy)
	
	if _trends.MaxLevel==0 then return false end

	local levels={}
	if isBuy then levels=_trends.buy
	else levels=_trends.sell end

	local n=0
	for i, level in pairs(levels) do
		if isBuy and level.stopprice~=0 and level.ordersID~=0 and level.tradeprice~=0 and level.stopprice<level.price1 then n=n+1
		elseif not isBuy and level.stopprice~=0 and level.ordersID~=0 and level.tradeprice~=0 and level.stopprice>level.price1 then n=n+1 end
	end
	if _trends.MaxLevel==nil then 
		_trends.MaxLevel=3
		SaveTrends=true
	end
	if n>=_trends.MaxLevel then 
		--func.inTable (tt1, 'CheckMaxLevel='..n ..' '..tostring(candles[CandleNum].open)..' '..DateTimeStr(candles[CandleNum].datetime)..' ' .. func.Tbl2Str(_trends.buy) )
		return true
	else return false end

end

function InsertTrendArray(arr,n)
	arr[n].ordersID=0
	arr[n].parM30=0
	arr[n].tradeprice=0
	arr[n].stopprice=0
	arr[n].multiplier=arr[n-1].multiplier
	arr[n].step=arr[n-1].step
	arr[n].spred=0
end

function CheckOrderTableComleted(arr)
	for i, level in pairs(arr.buy) do
		--func.inTable (tt1, 'CheckOrderTableComleted 1 '..tostring(level.ordersID).. ' '..tostring(OrderTable[level.ordersID].completed))--..' ' ..tostring(level.tradeprice))
		if level.ordersID~=0 and level.tradeprice==0 and OrderTable[level.ordersID].completed then 
			--func.inTable (tt1, ' CheckOrderTableComleted 2 '..level.ordersID)
			level.tradeprice=OrderTable[level.ordersID].tradeprice
			SaveTrends=true
		end
	end
	for i, level in pairs(arr.sell) do
		if level.ordersID~=0 and level.tradeprice==0 and OrderTable[level.ordersID].completed then 
			level.tradeprice=OrderTable[level.ordersID].tradeprice
			SaveTrends=true
		end
	end
end

function TrendStrategy(seccode1,seccode2)
	for _trend,_trends in pairs(Trends) do
		priceBuy=seccode1.PRICE_OFFER
		priceSell=seccode1.PRICE_BID
		if _trends.enable and (_trends.mode=='trend' or _trends.mode=='trendReverse') then   
			CheckOrderTableComleted(_trends)
			local buyArray={}
			local sellArray={}
			local nArr=0
			if _trends.mode=='trend' then 
				priceBuy=seccode1.PRICE_OFFER
				priceSell=seccode1.PRICE_BID
				buyArray.op='B'				
				sellArray.op='S'
				if _trends.op1=='B' and _trends.op2=='S' then 
					buyArray.seccode=_trends.seccode1
					buyArray.tframe=_trends.pos1..seccode1.preffix
					sellArray.seccode=_trends.seccode2
					sellArray.tframe=_trends.pos2..seccode2.preffix
				elseif _trends.op1=='S' and _trends.op2=='B'  then 
					buyArray.seccode=_trends.seccode2
					buyArray.tframe=_trends.pos2..seccode2.preffix
				 	sellArray.seccode=_trends.seccode1
					sellArray.tframe=_trends.pos1..seccode1.preffix
				end
			elseif _trends.mode=='trendReverse' then 
				priceSell=seccode1.PRICE_OFFER
				priceBuy=seccode1.PRICE_BID
				buyArray.op='S'
				sellArray.op='B'
				if _trends.op1=='B' and _trends.op2=='S'  then 
					buyArray.seccode=_trends.seccode2
					buyArray.tframe=_trends.pos2..seccode2.preffix
					sellArray.seccode=_trends.seccode1
					sellArray.tframe=_trends.pos1..seccode1.preffix
				elseif _trends.op1=='S' and _trends.op2=='B' then 
					buyArray.seccode=_trends.seccode1
					buyArray.tframe=_trends.pos1..seccode1.preffix
					sellArray.seccode=_trends.seccode2
					sellArray.tframe=_trends.pos2..seccode2.preffix
				end
			end
			if _trends.buy[#_trends.buy].ordersID==0 and  priceBuy>_trends.buy[#_trends.buy].price1 then 
				func.inTable (tt1, #_trends.buy.. ' TrendStrategy 1 '.. seccode1.seccode..' '  .. priceBuy..' ' .._trends.buy[#_trends.buy].price1)				
				_trends.buy[#_trends.buy].ordersID=InsertOrder(OrderTable,nil,_trends.key,buyArray.seccode,buyArray.op,-1,_trends.stepvol,buyArray.tframe,0)
				_trends.buy[#_trends.buy].price1=priceBuy
				nArr=#_trends.buy
				_trends.buy[nArr+1]={}
				_trends.buy[nArr+1].price1=priceBuy+_trends.buy[nArr].step
				InsertTrendArray(_trends.buy,nArr+1)
				if _trends.sell[#_trends.sell].ordersID==0 then nArr=#_trends.sell
				else 
					nArr=#_trends.sell+1
					_trends.sell[nArr]={}
					InsertTrendArray(_trends.sell,nArr)
				end
				_trends.sell[nArr].price1=priceSell-_trends.sell[nArr].step
				SaveTrends=true
			end

			if _trends.sell[#_trends.sell].ordersID==0 and priceSell<_trends.sell[#_trends.sell].price1 then 
				func.inTable (tt1, #_trends.buy.. ' TrendStrategy 2 '.. seccode1.seccode..' '  .. priceBuy..' ' .._trends.buy[#_trends.buy].price1)	
				_trends.sell[#_trends.sell].ordersID=InsertOrder(OrderTable,nil,_trends.key,sellArray.seccode,sellArray.op,-1,_trends.stepvol,sellArray.tframe,0)
				_trends.sell[#_trends.sell].price1=priceSell
				nArr=#_trends.sell
				_trends.sell[nArr+1]={}
				_trends.sell[nArr+1].price1=priceSell-_trends.sell[nArr].step
				InsertTrendArray(_trends.sell,nArr+1)
				if _trends.buy[#_trends.buy].ordersID==0 then nArr=#_trends.buy
				else 
					nArr=#_trends.buy+1
					_trends.buy[nArr]={}
					InsertTrendArray(_trends.buy,nArr)
				end
				_trends.buy[nArr].price1=priceBuy+_trends.buy[nArr].step
				SaveTrends=true
			end
		end
	end
end

function GridStrategy()
	for _trend,_trends in pairs(Trends) do
		priceBuy=tool[_trends.key].seccode1.PRICE_OFFER
		priceSell=tool[_trends.key].seccode1.PRICE_BID
		if _trends.enable and _trends.mode=='grid' then   
			--func.inTable (tt1, 'GridStrategy priceBuy='..priceBuy)
			inRange=false
			isCheckMaxStop=false
			isCheckMinStop=false
			n=0
			m=0
			local maxPrice=0
			local minPrice=1000000
			local timer=10
			local isMinStop=(_trends.MinStop~=nil and _trends.MinStop~=0)
			local isMaxStop=(_trends.MaxStop~=nil and _trends.MaxStop~=0)
			local simpleSeccode=(_trends.seccode1==_trends.seccode2)
			for i, level in pairs(_trends.buy) do
				if level.price1~=0 and level.ordersID~=0 and level.tradeprice~=0 and level.tradeprice*level.multiplier>maxPrice then
					maxPrice=level.tradeprice*level.multiplier
				end
				if inPriceRange(level.price1, priceBuy, _trends.step) then inRange=true end
				local isStop=(level.stopprice~=nil and level.stopprice~=0)
				local TraiStop=priceBuy-_trends.StopStep
				
				if isStop and level.stopprice>level.price1+_trends.step and level.stopprice<TraiStop then 
					level.stopprice=TraiStop
					SaveTrends=true
					func.inTable (tt1, 'GridStrategy 1.1 buy '.. _trend..' stopprice=TraiStop='.. TraiStop)
				elseif isStop and priceBuy-_trends.step>level.price1 and level.stopprice<level.price1 then 
					func.inTable (tt1, 'GridStrategy 1 buy '.. _trend..' stopprice=price1='..level.price1)
					level.stopprice=level.price1
					SaveTrends=true
				elseif isStop and priceBuy-level.price1>_trends.step*2 and level.stopprice<level.price1+_trends.step then 
					func.inTable (tt1, 'GridStrategy 2 buy '.. _trend..' stopprice=price1+step='.. level.price1..'+'.._trends.step)
					level.stopprice=level.price1+_trends.step
					SaveTrends=true				
				elseif isStop and level.stopprice<level.price1 then 
					if isMinStop and level.stopprice>_trends.MinStop then 
						level.stopprice=_trends.MinStop
						SaveTrends=true	
						func.inTable (tt1, 'GridStrategy 3 buy '.. _trend..' stopprice=MinStop='.. _trends.MinStop)
					elseif isMinStop and level.stopprice<_trends.MinStop and level.stopprice< TraiStop then 
						level.stopprice=TraiStop
						SaveTrends=true
						func.inTable (tt1, 'GridStrategy 3.1 buy '.. _trend..' stopprice=TraiStop='.. TraiStop)
					end
				end
				
				if level.price1==0 and level.ordersID==0 and level.stopprice and tonumber(i)~=1 and n==0 then n=tonumber(i) end
			end
			if _trends.MaxStop<maxPrice and simpleSeccode then 
				if _trends.MaxStopTimer==nil then 
					_trends.MaxStopTimer=0 
					SaveTrends=true	
				end
				_trends.MaxStopTimer=_trends.MaxStopTimer+1
				SaveTrends=true	
				if TimerCheck(_trends.MaxStopTimer,timer) then 
					_trends.MaxStop=maxPrice
					_trends.MaxStopTimer=0
					SaveTrends=true		
					isCheckMinStop=true
					func.inTable (tt1, 'GridStrategy 9 buy '.. _trend..' MaxStop='.._trends.MaxStop..'<maxPrice='.. maxPrice)
				end
			elseif _trends.MaxStopTimer~=0 then 
				_trends.MaxStopTimer=0
				SaveTrends=true	
			end
			if not inRange and LongTrendCheck()  and not CheckMaxLevel(_trends,true) then 
				if n==0 then n=#_trends.buy+1 end
				_trends.buy[n]={}
				_trends.buy[n].price1=priceBuy+_trends.step
				_trends.buy[n].multiplier=_trends.buy[n-1].multiplier
				_trends.buy[n].step=_trends.buy[n-1].step
				_trends.buy[n].ordersID=0
				_trends.buy[n].stopprice=0
				SaveTrends=true
				func.inTable (tt1, 'GridStrategy 3 buy '.. _trend..' insert price1='.. priceBuy+_trends.step)
			end
			inRange=false
			for i, level in pairs(_trends.sell) do
				if level.price1~=0 and level.ordersID~=0 and level.tradeprice~=0 and level.tradeprice*level.multiplier<minPrice then
					minPrice=level.tradeprice*level.multiplier
				end
				
				if inPriceRange(priceSell, level.price1,_trends.step)  then inRange=true end
				local isStop=(level.stopprice~=nil and level.stopprice~=0)

				local TraiStop=priceSell+_trends.StopStep
				
				if isStop and level.stopprice<level.price1-_trends.step and level.stopprice>TraiStop then 
					level.stopprice=TraiStop
					SaveTrends=true
					func.inTable (tt1, 'GridStrategy 4.1 sell '.. _trend..' stopprice=TraiStop='.. TraiStop)
				elseif isStop and level.price1-priceSell>_trends.step*2 and level.stopprice>level.price1-_trends.step then 
					func.inTable (tt1, 'GridStrategy 4 sell '.. _trend..' stopprice=price1+step='.. level.price1-_trends.step)
					level.stopprice=level.price1-_trends.step
					SaveTrends=true				
				elseif isStop and level.price1-priceSell>_trends.step and level.stopprice>level.price1 then 
					func.inTable (tt1, 'GridStrategy 5 sell '.. _trend..' stopprice=price1='..level.price1)
					level.stopprice=level.price1
					SaveTrends=true			
				elseif isStop and level.stopprice>level.price1 then 
					if isMaxStop and level.stopprice<_trends.MaxStop then 
						level.stopprice=_trends.MaxStop
						SaveTrends=true	
						func.inTable (tt1, 'GridStrategy 6 sell '.. _trend..' stopprice=MaxStop='.. _trends.MaxStop)
					elseif isMaxStop and level.stopprice>_trends.MaxStop and level.stopprice>TraiStop then 
						level.stopprice=TraiStop
						SaveTrends=true
						func.inTable (tt1, 'GridStrategy 7 sell '.. _trend..' stopprice=TraiStop='.. TraiStop)
					end
				end
				
				if level.price1==0 and level.ordersID==0 and level.stopprice and tonumber(i)~=1 and m==0 then m=tonumber(i) end
			end
			
			if (_trends.MinStop>minPrice or _trends.MinStop==0) and simpleSeccode and minPrice~=1000000 then 
				--TimerInit(_trends.MinStopTimer)
				if _trends.MinStopTimer==nil then 
					_trends.MinStopTimer=0 
					SaveTrends=true	
				end
				_trends.MinStopTimer=_trends.MinStopTimer+1
				SaveTrends=true	
				func.inTable (tt1, 'GridStrategy MinStopTimer='..  _trends.MinStopTimer)
				if TimerCheck(_trends.MinStopTimer,timer) then 
					_trends.MinStop=minPrice
					_trends.MinStopTimer=0 
					SaveTrends=true		
					isCheckMaxStop=true
					func.inTable (tt1, 'GridStrategy 10 sell '.. _trend..' MinStop='.._trends.MinStop..'>minPrice='.. minPrice)
				end
			elseif _trends.MinStopTimer~=0 then
				_trends.MinStopTimer=0
				SaveTrends=true	
			end
			if not inRange and ShortTrendCheck() and not CheckMaxLevel(_trends,false) then 
				if m==0 then m=#_trends.sell+1 end
				_trends.sell[m]={}
				_trends.sell[m].price1=priceSell-_trends.step
				_trends.sell[m].multiplier=_trends.sell[m-1].multiplier
				_trends.sell[m].step=_trends.sell[m-1].step
				_trends.sell[m].ordersID=0
				_trends.sell[m].stopprice=0				
				SaveTrends=true
				func.inTable (tt1, 'GridStrategy 6 sell '.. _trend..' insert price1='.. priceSell-_trends.step)
			end
			
			if isCheckMinStop and minPrice~=1000000 and _trends.MinStop<minPrice then 
				_trends.MinStop=minPrice
				SaveTrends=true				
				func.inTable (tt1, 'GridStrategy 12 sell '.. _trend..' MinStop='.._trends.MinStop..'=minPrice='.. minPrice)
			end
			if isCheckMaxStop and maxPrice~=0 and _trends.MaxStop>maxPrice then 
				_trends.MaxStop=maxPrice
				SaveTrends=true		
				func.inTable (tt1, 'GridStrategy 13 buy '.. _trend..' MaxStop='.._trends.MaxStop..'=maxPrice='.. maxPrice)
			end
			--if priceBuy>_trends.MaxStop and _trends.MaxStop~=0 then 
			--	_trends.stepvol=1
			--	--func.inTable (tt1, 'GridStrategy 14 buy stepvol=5')
			--	SaveTrends=true	
			--elseif priceSell<_trends.MinStop and _trends.MinStop~=0 then 
			--	_trends.stepvol=1
			--	--func.inTable (tt1, 'GridStrategy 15 sell stepvol=5')
			--	SaveTrends=true	
			--else  
			--	_trends.stepvol=5
			--	--func.inTable (tt1, 'GridStrategy 15 stepvol=1')
			--	SaveTrends=true	
			--end
		end
	end
end


function TrendsCalculate(NoInTable)
	local inform=true
	if NoInTable~=nil and NoInTable then inform=false end
	for _trend,_trends in pairs(Trends) do
		if _trends.enable and (string.match(_trend,'scalp') or _trends.mode=='grid' or string.match(_trend,'trend')) then   
			if inform then 	func.inTable (tt1, 'TrendsCalculate '.. _trend) end
			local price=0
			local priceBuy=0
			local priceSell=0
			local volBuy=0
			for _order,_orders in pairs(_trends.buy) do
				if _orders.ordersID~=0 and _orders.tradeprice~=0 then 
					price=price+_orders.price1
					volBuy=volBuy+1
				end
			end
			if volBuy~=0 then priceBuy=price/volBuy end
			if inform then 	func.inTable (tt1, '	'.. _trend .. ' buy price1='..priceBuy..' * '..volBuy ) end

			price=0
			local volSell=0
			for _order,_orders in pairs(_trends.sell) do
				if _orders.ordersID~=0 and _orders.tradeprice~=0 then 
					price=price+_orders.price1
					volSell=volSell+1
				end
			end
			if volSell~=0 then  priceSell=price/volSell end
			if inform then 	func.inTable (tt1, '	'.. _trend .. ' sell price1='..priceSell..' * '..volSell ) end
			local vol=0
			local result=0
			local volRest=0
			local rest=0
			if volBuy>volSell then 
				vol=volSell  
				volRest=volBuy-volSell
				price=TrendsFindPrice('B', _trends)
				rest=(price-priceBuy)*volRest*_trends.stepvol
			else vol=volBuy 
				volRest=volSell-volBuy
				price=TrendsFindPrice('S', _trends)
				rest=(priceSell-price)*volRest*_trends.stepvol
			end	
			result=(priceSell-priceBuy)*vol*_trends.stepvol
			
			--local summLoss = (_trends.StopBuy + _trends.StopSell);
            if _trends.StopStep~=nil and _trends.StopStep~=0 then stopStep=_trends.StopStep
			else stopStep=_trends.step*4 end
			--local profit =((_trends.orders - summLoss)- summLoss*4)*_trends.step*_trends.stepvol
			--local profit =(_trends.orders - (volSell+volBuy)- (_trends.StopBuy + _trends.StopSell))*_trends.step*_trends.stepvol-stopStep*_trends.stepvol*(_trends.StopBuy + _trends.StopSell)
			profit=_trends.profit
		
			if inform then 	
				local minTimer=0 
				local maxTimer=0 
				if _trends.MaxStopTimer~=nil and _trends.MaxStopTimer~=0 then  maxTimer=os.time()-_trends.MaxStopTimer end
				if _trends.MinStopTimer~=nil and _trends.MinStopTimer~=0 then  minTimer=os.time()-_trends.MinStopTimer end
				--func.inTable (tt1, os.time() ..' MaxStopTimer ' .. tostring(_trends.MaxStopTimer))
				--func.inTable (tt1, os.time() ..' MinStopTimer ' .. tostring(_trends.MinStopTimer))
				func.inTable (tt1, 'MaxProfit='..tostring(_trends.MaxProfit)..' StopStep='..tostring(stopStep)..' MaxStop='..tostring(_trends.MaxStop)..'-'..maxTimer..' MinStop='..tostring(_trends.MinStop)..'-'..minTimer ) 
				--func.inTable (tt1, 'StopStep='..tostring(stopStep)) 
				--func.inTable (tt1, 'stopStep*_trends.stepvol*(_trends.StopBuy + _trends.StopSell)='..tostring(stopStep*_trends.stepvol*(_trends.StopBuy + _trends.StopSell))) 
				--func.inTable (tt1, '(_trends.orders - (volSell+volBuy)- (_trends.StopBuy + _trends.StopSell))='..tostring((_trends.orders - (volSell+volBuy)- (_trends.StopBuy + _trends.StopSell)))) 
				func.inTable (tt1, 'result='..result..' rest='..rest .. ' profit='..profit ..' final='..profit+result+rest) 
				
				if _trends.MaxLevel~=nil then 
					func.inTable (tt1, 'MaxLevel='.._trends.MaxLevel..' MaxRisk='.._trends.MaxLevel*stopStep*_trends.stepvol) 
				end
				func.inTable (tt1, '----------------------------------')
			end
			allProfit=profit+result+rest
			if _trends.MaxProfit~=nil and _trends.MaxProfit~=0 and allProfit>_trends.MaxProfit and price>0 then 
				func.inTable (tt1,  '!!! TrendsCalculate '.. _trend .. ' profit('..allProfit..')>MaxProfit('.._trends.MaxProfit..')')
				--if isTrendsProfitTake then TrendsProfitTake(_trend,_trends, volRest,result+rest) end
				TrendsProfitTake(_trend,_trends, volRest,result+rest)
				_trends.MaxProfit=_trends.MaxProfit+allProfit
				SaveTrends=true
				isTrendsProfitTake=false
			end
		end
	end
end
	
function CheckSO (tframe,tool,value)
	robot.checkstoporder (tframe,tool,value)
end

function InitSeccode(key)

	ToolSetPath = getScriptPath()..'//toolset.txt'
	toolset=func.loadtable(ToolSetPath)

	tool[key].strategy202106.pos.one.vol=toolset.vol[key][key..'_1_vol_one']
	tool[key].strategy202106.pos.two.vol=toolset.vol[key][key..'_2_vol_two']
	tool[key].strategy202106.pos.three.vol=toolset.vol[key][key..'_3_vol_three']
	
	tool[key].strategy202106.pos.one.minProffit=	toolset.minProffit[key][key..'_1_minProffit_one']
	tool[key].strategy202106.pos.two.minProffit=    toolset.minProffit[key][key..'_2_minProffit_two']
	tool[key].strategy202106.pos.three.minProffit=  toolset.minProffit[key][key..'_3_minProffit_three']
	
	tool[key].strategy202106.pos.one.maxvol=		toolset.maxvol[key][key..'_1_maxvol_one']
	tool[key].strategy202106.pos.two.maxvol=        toolset.maxvol[key][key..'_2_maxvol_two']
	tool[key].strategy202106.pos.three.maxvol=      toolset.maxvol[key][key..'_3_maxvol_three']
	
	tool[key].strategy202106.pos.one.stepvol=		toolset.stepvol[key][key..'_1_stepvol_one']
	tool[key].strategy202106.pos.two.stepvol=       toolset.stepvol[key][key..'_2_stepvol_two']
	tool[key].strategy202106.pos.three.stepvol=     toolset.stepvol[key][key..'_3_stepvol_three']
	
	tool[key].strategy202106.pos.one.step=			toolset.step[key][key..'_1_step_one']
	tool[key].strategy202106.pos.two.step=          toolset.step[key][key..'_2_step_two']
	tool[key].strategy202106.pos.three.step=        toolset.step[key][key..'_3_step_three']

	--if tool[key].strategy202106.pos.one.manualentersignal==nil then   tool[key].strategy202106.pos.one.manualentersignal=0 end
	--if tool[key].strategy202106.pos.two.manualentersignal==nil then   tool[key].strategy202106.pos.two.manualentersignal=0 end
	--if tool[key].strategy202106.pos.three.manualentersignal==nil then tool[key].strategy202106.pos.three.manualentersignal=0 end
	
	tool[key].strategy202106.pos.one.manualentersignal=			toolset.manualentersignal[key][key..'_1_manualentersignal_one']
	tool[key].strategy202106.pos.two.manualentersignal=          toolset.manualentersignal[key][key..'_2_manualentersignal_two']
	tool[key].strategy202106.pos.three.manualentersignal=        toolset.manualentersignal[key][key..'_3_manualentersignal_three']
	
	tool[key].strategy202106.minrest=			toolset.minrest
	
end

function tradesPrevDate(data, key)

	local localTime
	if data==nil then 
		localTime=os.time()-86400
	else
		localTime=os.time(data)-86400
	end

	for n=1,31,1 do
		dateT=os.date("*t",localTime)
		--func.inTable (tt1, 'tradesPrevDate n='..n..' ' ..func.Tbl2Str(dateT))
		if trades[dateT.year][dateT.month][dateT.day]~=nil then 
			if key~=nil then 
				return trades[dateT.year][dateT.month][dateT.day][key]			
			else return trades[dateT.year][dateT.month][dateT.day] end		
		end
		localTime=localTime-86400
		n=n+1
	end

end

function getExpireTbl(seccode)
	if getSecurityInfo(CLASS_CODE, seccode)~=nil then mat_date=getSecurityInfo(CLASS_CODE, seccode).mat_date 
	else return false end
	local ExpireTbl={}
	ExpireTbl.year=tonumber(string.sub(mat_date,1,4))
    ExpireTbl.month=tonumber(string.sub(mat_date,5,6))
    ExpireTbl.day=tonumber(string.sub(mat_date,7))
	return ExpireTbl
end

function CalcVM(tradesDate)
	
	--dateT=os.date("*t",os.time())
	--tradesDate={}
	--if func.TimePassed(19,10,00) and func.TimeNotPassed(23,49,55) then 
	--	tradesDate=trades[dateT.year][dateT.month][dateT.day]
	--elseif func.TimePassed(10,01,00) and func.TimeNotPassed(18,58,55) then	
	--	tradesDate=tradesPrevDate()
	--	--tradesDate=trades[dateT.year][dateT.month][dateT.day-3]
	--else
	--	return false
	--end	

	if tradesDate~=nil then
		for key,value in pairs(tradesDate) do	
			if tool[key]~=nil then 
				sec1=value[tool[key].seccode1.seccode]
				sec2=value[tool[key].seccode2.seccode]
				if sec1.pos==nil or  sec2.pos==nil then 
					sec1.pos={}
					sec1.pos.one={}
					sec1.pos.two={}
					sec1.pos.three={}
					sec2.pos={}
					sec2.pos.one={}
					sec2.pos.two={}
					sec2.pos.three={}
				end
				if sec1.vol~=0 or sec2.vol~=0 then 
					if sec1.CLPRICE==nil then sec1.CLPRICE=0 end
					if sec2.CLPRICE==nil then sec2.CLPRICE=0 end
					price1=tool[key].strategy202106.pos.two.total.price
					price2=tool[key].strategy202106.pos.two.total2.price
					
					sec1.pos.one.vol=tool[key].strategy202106.pos.one.total.vol
					sec1.pos.one.vm=func.round(func.correctsum(tool[key].seccode1.seccode,(sec1.pos.one.vol*(price1-sec1.CLPRICE))))
					sec1.pos.one.price=price1
					sec1.pos.one.CLPRICE=sec1.CLPRICE
					sec1.pos.one.OpenSpred=sec2.CLPRICE-sec1.CLPRICE
					sec1.pos.one.CurSpred=price2-price1
					sec1.pos.one.Spred=sec1.pos.one.OpenSpred-sec1.pos.one.CurSpred
					
					sec1.pos.two.vol=tool[key].strategy202106.pos.two.total.vol
					sec1.pos.two.vm=func.round(func.correctsum(tool[key].seccode1.seccode,(sec1.pos.two.vol*(price1-sec1.CLPRICE))))			
					sec1.pos.two.price=price1
					sec1.pos.two.CLPRICE=sec1.CLPRICE
					sec1.pos.two.OpenSpred=sec2.CLPRICE-sec1.CLPRICE
					sec1.pos.two.CurSpred=price2-price1
					sec1.pos.two.Spred=sec1.pos.two.CurSpred-sec1.pos.two.OpenSpred					
					
					sec1.pos.three.vol=tool[key].strategy202106.pos.three.total.vol
					sec1.pos.three.vm=func.round(func.correctsum(tool[key].seccode1.seccode,(sec1.pos.three.vol*(price1-sec1.CLPRICE))))
					sec1.pos.three.price=price1
					sec1.pos.three.CLPRICE=sec1.CLPRICE
					sec1.pos.three.OpenSpred=sec2.CLPRICE-sec1.CLPRICE
					sec1.pos.three.CurSpred=price2-price1
					sec1.pos.three.Spred=sec1.pos.three.OpenSpred-sec1.pos.three.CurSpred
						
					sec2.pos.one.vol=tool[key].strategy202106.pos.one.total2.vol
					sec2.pos.one.vm=func.round(func.correctsum(tool[key].seccode2.seccode,(sec2.pos.one.vol*(price2-sec2.CLPRICE))))
					sec2.pos.one.price=price2
					sec2.pos.one.CLPRICE=sec2.CLPRICE
					sec2.pos.one.OpenSpred=sec2.CLPRICE-sec1.CLPRICE
					sec2.pos.one.CurSpred=price2-price1
					sec2.pos.one.Spred=sec1.pos.one.OpenSpred-sec1.pos.one.CurSpred

					sec2.pos.two.vol=tool[key].strategy202106.pos.two.total2.vol
					sec2.pos.two.vm=func.round(func.correctsum(tool[key].seccode2.seccode,(sec2.pos.two.vol*(price2-sec2.CLPRICE))))			
					sec2.pos.two.price=price2
					sec2.pos.two.CLPRICE=sec2.CLPRICE
					sec2.pos.two.OpenSpred=sec2.CLPRICE-sec1.CLPRICE
					sec2.pos.two.CurSpred=price2-price1
					sec2.pos.two.Spred=sec1.pos.two.CurSpred-sec1.pos.two.OpenSpred	
				
					sec2.pos.three.vol=tool[key].strategy202106.pos.three.total2.vol
					sec2.pos.three.vm=func.round(func.correctsum(tool[key].seccode2.seccode,(sec2.pos.three.vol*(price2-sec2.CLPRICE))))
					sec2.pos.three.price=price2
					sec2.pos.three.CLPRICE=sec2.CLPRICE		
					sec2.pos.three.OpenSpred=sec2.CLPRICE-sec1.CLPRICE
					sec2.pos.three.CurSpred=price2-price1
					sec2.pos.three.Spred=sec1.pos.three.OpenSpred-sec1.pos.three.CurSpred
				end
			end
		end
		func.inTable (tt1, 'CalcVM обновлена дата '..dateT.day)
	end
end

function InitNewVol(value)
	if value.strategy202106.pos.one.total.newvolsell==nil then value.strategy202106.pos.one.total.newvolsell=0 end
	if value.strategy202106.pos.two.total.newvolsell==nil then value.strategy202106.pos.two.total.newvolsell=0 end		
	if value.strategy202106.pos.three.total.newvolsell==nil then value.strategy202106.pos.three.total.newvolsell=0 end
	if value.strategy202106.pos.one.total.newvolbuy==nil then value.strategy202106.pos.one.total.newvolbuy=0 end
	if value.strategy202106.pos.two.total.newvolbuy==nil then value.strategy202106.pos.two.total.newvolbuy=0 end		
	if value.strategy202106.pos.three.total.newvolbuy==nil then value.strategy202106.pos.three.total.newvolbuy=0 end

	if value.strategy202106.pos.one.total.newpricesell==nil then value.strategy202106.pos.one.total.newpricesell=0 end
	if value.strategy202106.pos.two.total.newpricesell==nil then value.strategy202106.pos.two.total.newpricesell=0 end		
	if value.strategy202106.pos.three.total.newpricesell==nil then value.strategy202106.pos.three.total.newpricesell=0 end
	if value.strategy202106.pos.one.total.newpricebuy==nil then value.strategy202106.pos.one.total.newpricebuy=0 end
	if value.strategy202106.pos.two.total.newpricebuy==nil then value.strategy202106.pos.two.total.newpricebuy=0 end		
	if value.strategy202106.pos.three.total.newpricebuy==nil then value.strategy202106.pos.three.total.newpricebuy=0 end

	if value.strategy202106.pos.one.total2.newvolsell==nil then value.strategy202106.pos.one.total2.newvolsell=0 end
	if value.strategy202106.pos.two.total2.newvolsell==nil then value.strategy202106.pos.two.total2.newvolsell=0 end		
	if value.strategy202106.pos.three.total2.newvolsell==nil then value.strategy202106.pos.three.total2.newvolsell=0 end
	if value.strategy202106.pos.one.total2.newvolbuy==nil then value.strategy202106.pos.one.total2.newvolbuy=0 end
	if value.strategy202106.pos.two.total2.newvolbuy==nil then value.strategy202106.pos.two.total2.newvolbuy=0 end		
	if value.strategy202106.pos.three.total2.newvolbuy==nil then value.strategy202106.pos.three.total2.newvolbuy=0 end

	if value.strategy202106.pos.one.total2.newpricesell==nil then value.strategy202106.pos.one.total2.newpricesell=0 end
	if value.strategy202106.pos.two.total2.newpricesell==nil then value.strategy202106.pos.two.total2.newpricesell=0 end		
	if value.strategy202106.pos.three.total2.newpricesell==nil then value.strategy202106.pos.three.total2.newpricesell=0 end
	if value.strategy202106.pos.one.total2.newpricebuy==nil then value.strategy202106.pos.one.total2.newpricebuy=0 end
	if value.strategy202106.pos.two.total2.newpricebuy==nil then value.strategy202106.pos.two.total2.newpricebuy=0 end		
	if value.strategy202106.pos.three.total2.newpricebuy==nil then value.strategy202106.pos.three.total2.newpricebuy=0 end

end

function CalcNewVol(value)
	return value.strategy202106.pos.one.total.newvolsell+
	value.strategy202106.pos.two.total.newvolsell+
	value.strategy202106.pos.three.total.newvolsell+
	value.strategy202106.pos.one.total.newvolbuy+
	value.strategy202106.pos.two.total.newvolbuy+
    value.strategy202106.pos.three.total.newvolbuy
end

function CalcNewVol2(value)
	return value.strategy202106.pos.one.total2.newvolsell+
	value.strategy202106.pos.two.total2.newvolsell+
	value.strategy202106.pos.three.total2.newvolsell+
	value.strategy202106.pos.one.total2.newvolbuy+
	value.strategy202106.pos.two.total2.newvolbuy+
    value.strategy202106.pos.three.total2.newvolbuy
end

function CalcNewCost(value)
	return value.strategy202106.pos.one.total.newvolsell*value.strategy202106.pos.one.total.newpricesell+
	value.strategy202106.pos.two.total.newvolsell  *value.strategy202106.pos.two.total.newpricesell+
	value.strategy202106.pos.three.total.newvolsell*value.strategy202106.pos.three.total.newpricesell+
	value.strategy202106.pos.one.total.newvolbuy   *value.strategy202106.pos.one.total.newpricebuy+
	value.strategy202106.pos.two.total.newvolbuy   *value.strategy202106.pos.two.total.newpricebuy+
    value.strategy202106.pos.three.total.newvolbuy *value.strategy202106.pos.three.total.newpricebuy
end

function CalcNewCost2(value)
	return value.strategy202106.pos.one.total2.newvolsell*value.strategy202106.pos.one.total2.newpricesell+
	value.strategy202106.pos.two.total2.newvolsell  *value.strategy202106.pos.two.total2.newpricesell+
	value.strategy202106.pos.three.total2.newvolsell*value.strategy202106.pos.three.total2.newpricesell+
	value.strategy202106.pos.one.total2.newvolbuy   *value.strategy202106.pos.one.total2.newpricebuy+
	value.strategy202106.pos.two.total2.newvolbuy   *value.strategy202106.pos.two.total2.newpricebuy+
    value.strategy202106.pos.three.total2.newvolbuy *value.strategy202106.pos.three.total2.newpricebuy
end

function CalcVmNew (value, prevvalue, seccode)
	if value.newvol~=0 then
		local newprice=value.newcost/value.newvol
		if value.newvol>0 and value.vol>0 then value.vmnew=func.correctsum(seccode,(value.CLPRICE-newprice)*value.newvol)
			elseif value.newvol>0 and value.vol<0 then value.vmnew=func.correctsum(seccode,(prevvalue.CLPRICE-newprice)*value.newvol)
			elseif value.newvol<0 and value.vol<0 then value.vmnew=func.correctsum(seccode,(value.CLPRICE-newprice)*value.newvol)
			elseif value.newvol<0 and value.vol>0 then value.vmnew=func.correctsum(seccode,(prevvalue.CLPRICE-newprice)*value.newvol) 
		end		
	end
end


function ResetNewMemory(value)
	timename='one'..value.seccode1.preffix
	memory.buy[timename].newvol=0
	memory.buy[timename].newprice=0
	memory.sell[timename].newvol=0
	memory.sell[timename].newprice=0
	timename='two'..value.seccode1.preffix
	memory.buy[timename].newvol=0
	memory.buy[timename].newprice=0
	memory.sell[timename].newvol=0
	memory.sell[timename].newprice=0
	timename='three'..value.seccode1.preffix
	memory.buy[timename].newvol=0
	memory.buy[timename].newprice=0
	memory.sell[timename].newvol=0
	memory.sell[timename].newprice=0
	
	timename='one'..value.seccode2.preffix
	memory.buy[timename].newvol=0
	memory.buy[timename].newprice=0
	memory.sell[timename].newvol=0
	memory.sell[timename].newprice=0
	timename='two'..value.seccode2.preffix
	memory.buy[timename].newvol=0
	memory.buy[timename].newprice=0
	memory.sell[timename].newvol=0
	memory.sell[timename].newprice=0
	timename='three'..value.seccode2.preffix
	memory.buy[timename].newvol=0
	memory.buy[timename].newprice=0
	memory.sell[timename].newvol=0
	memory.sell[timename].newprice=0
	
	func.savetable(memory,FPath)
	value.strategy202106.resetnew=false
	func.inTable (tt1, 'ResetNewMemory '..value.seccode1.preffix..' '..value.seccode2.preffix)
end

function CalcTrades()
	dateT=os.date("*t",os.time())
	tradesDate={}
	if func.TimePassed(19,10,00) and func.TimeNotPassed(23,49,55) then 
		tradesDate=trades[dateT.year][dateT.month][dateT.day]
	elseif func.TimePassed(09,01,00) and func.TimeNotPassed(18,45,55) then	
		tradesDate=tradesPrevDate()
		--tradesDate=trades[dateT.year][dateT.month][dateT.day-3]
	else
		return false
	end	

	if tradesDate~=nil and (tradesDate.flag==nil or os.time()-tradesDate.flag>900) then
		for key,value in pairs(tool) do		
			if value.strategy202106.enable then
				if tradesDate[key]==nil then 
					tradesDate[key]={} 
					tradesDate[key][value.seccode1.seccode]={}
					tradesDate[key][value.seccode2.seccode]={}
				end
				if tradesDate[key][value.seccode1.seccode]==nil then tradesDate[key][value.seccode1.seccode]={} end
				if tradesDate[key][value.seccode2.seccode]==nil then tradesDate[key][value.seccode2.seccode]={} end
				PrevValue=tradesPrevDate()
				
					tradesDate[key][value.seccode1.seccode]['PREV_SWAP_RATE']=tonumber(getParamEx(CLASS_CODE, value.seccode1.seccode,'PREV_SWAP_RATE').param_value)
					tradesDate[key][value.seccode2.seccode]['PREV_SWAP_RATE']=tonumber(getParamEx(CLASS_CODE, value.seccode2.seccode,'PREV_SWAP_RATE').param_value)
					if tradesDate[key][value.seccode2.seccode]['IMOEXDiv']~=nil then 
						tradesDate[key][value.seccode2.seccode]['PREV_SWAP_RATE']=tradesDate[key][value.seccode2.seccode]['PREV_SWAP_RATE']-tradesDate[key][value.seccode2.seccode]['IMOEXDiv']
					end
					if tradesDate[key][value.seccode1.seccode]['IMOEXDiv']~=nil then 
						tradesDate[key][value.seccode1.seccode]['PREV_SWAP_RATE']=tradesDate[key][value.seccode1.seccode]['PREV_SWAP_RATE']-tradesDate[key][value.seccode1.seccode]['IMOEXDiv']
					end
					--tradesDate[key][value.seccode1.seccode]['CLPRICE']=tonumber(getParamEx(CLASS_CODE, value.seccode1.seccode,'CLPRICE').param_value)
					--tradesDate[key][value.seccode2.seccode]['CLPRICE']=tonumber(getParamEx(CLASS_CODE, value.seccode2.seccode,'CLPRICE').param_value)
					
					if func.TimePassed(14,15,59) and func.TimeNotPassed(18,49,59) then
						tradesDate[key][value.seccode1.seccode]['CLPRICE_day']=tonumber(getParamEx(CLASS_CODE, value.seccode1.seccode,'CLPRICE').param_value)
						tradesDate[key][value.seccode2.seccode]['CLPRICE_day']=tonumber(getParamEx(CLASS_CODE, value.seccode2.seccode,'CLPRICE').param_value)
					elseif func.TimePassed(19,10,00) or func.TimeNotPassed(12,00,59) then
						tradesDate[key][value.seccode1.seccode]['CLPRICE']=tonumber(getParamEx(CLASS_CODE, value.seccode1.seccode,'CLPRICE').param_value)
						tradesDate[key][value.seccode2.seccode]['CLPRICE']=tonumber(getParamEx(CLASS_CODE, value.seccode2.seccode,'CLPRICE').param_value)
					end
					
					tradesDate[key][value.seccode1.seccode].number=1
					tradesDate[key][value.seccode2.seccode].number=2
					
					--func.inTable (tt1,'CLPRICE '..tostring(CLASS_CODE)..' '..tostring(value.seccode2.seccode) ..tonumber(getParamEx(CLASS_CODE, value.seccode2.seccode,'CLPRICE').param_value))
					--tradesDate[key][value.seccode1.seccode]['SELLDEPO']=tonumber(getParamEx(CLASS_CODE,value.seccode1.seccode, "SELLDEPO").param_value)
					--tradesDate[key][value.seccode2.seccode]['SELLDEPO']=tonumber(getParamEx(CLASS_CODE,value.seccode2.seccode, "SELLDEPO").param_value)
					--tradesDate[key][value.seccode1.seccode]['ExpireDate']={}
					--tradesDate[key][value.seccode1.seccode]['ExpireDate']=getExpireTbl(value.seccode1.seccode)
					--tradesDate[key][value.seccode2.seccode]['ExpireDate']={}
					--tradesDate[key][value.seccode2.seccode]['ExpireDate']=getExpireTbl(value.seccode2.seccode)

					if func.TimePassed(19,10,00) and func.TimeNotPassed(23,50,00) and tradesDate[key][value.seccode1.seccode]['index']==nil then
						
						if tradesDate[key][value.seccode1.seccode]['newvol']==nil then
							tradesDate[key][value.seccode1.seccode]['newvol']=0
							tradesDate[key][value.seccode2.seccode]['newvol']=0
							tradesDate[key][value.seccode1.seccode]['newcost']=0
							tradesDate[key][value.seccode2.seccode]['newcost']=0
						end
						
						NewVol=CalcNewVol(value)
						NewVol2=CalcNewVol2(value)
						if NewVol~=0 or NewVol2~=0 then 
							tradesDate[key][value.seccode1.seccode]['newvol']=tradesDate[key][value.seccode1.seccode]['newvol']+NewVol 
							tradesDate[key][value.seccode2.seccode]['newvol']=tradesDate[key][value.seccode2.seccode]['newvol']+NewVol2
							tradesDate[key][value.seccode1.seccode]['newcost']=tradesDate[key][value.seccode1.seccode]['newcost']+CalcNewCost(value)
							tradesDate[key][value.seccode2.seccode]['newcost']=tradesDate[key][value.seccode2.seccode]['newcost']+CalcNewCost2(value)
							value.strategy202106.resetnew=true
							func.inTable (tt1, 'CalcTrades '..key..' пересчет newvol, newcost')
						end
						
						tradesDate[key][value.seccode1.seccode]['vol']=value.strategy202106.pos.one.total.vol+value.strategy202106.pos.two.total.vol+value.strategy202106.pos.three.total.vol
						tradesDate[key][value.seccode2.seccode]['vol']=value.strategy202106.pos.one.total2.vol+value.strategy202106.pos.two.total2.vol+value.strategy202106.pos.three.total2.vol
						
						tradesDate[key][value.seccode1.seccode]['go']=math.abs(value.strategy202106.pos.one.total.go+value.strategy202106.pos.two.total.go+value.strategy202106.pos.three.total.go)
						tradesDate[key][value.seccode2.seccode]['go']=math.abs(value.strategy202106.pos.one.total2.go+value.strategy202106.pos.two.total2.go+value.strategy202106.pos.three.total2.go)
																
						if (tradesDate[key][value.seccode1.seccode]['vol']>0 and tradesDate[key][value.seccode1.seccode]['newvol']>0) or 
							(tradesDate[key][value.seccode1.seccode]['vol']<0 and tradesDate[key][value.seccode1.seccode]['newvol']<0) then 
								tradesDate[key][value.seccode1.seccode]['basevol']=tradesDate[key][value.seccode1.seccode]['vol']-tradesDate[key][value.seccode1.seccode]['newvol']
						else tradesDate[key][value.seccode1.seccode]['basevol']=tradesDate[key][value.seccode1.seccode]['vol'] end
						
						if (tradesDate[key][value.seccode2.seccode]['vol']>0 and tradesDate[key][value.seccode2.seccode]['newvol']>0) or 
							(tradesDate[key][value.seccode2.seccode]['vol']<0 and tradesDate[key][value.seccode2.seccode]['newvol']<0) then 
								tradesDate[key][value.seccode2.seccode]['basevol']=tradesDate[key][value.seccode2.seccode]['vol']-tradesDate[key][value.seccode2.seccode]['newvol']
						else tradesDate[key][value.seccode2.seccode]['basevol']=tradesDate[key][value.seccode2.seccode]['vol'] end
							
						tradesDate[key][value.seccode1.seccode]['funding']=tradesDate[key][value.seccode1.seccode]['vol']*tradesDate[key][value.seccode1.seccode]['PREV_SWAP_RATE']*tonumber(getParamEx(CLASS_CODE, value.seccode1.seccode,'LOTSIZE').param_value*-1)
						tradesDate[key][value.seccode2.seccode]['funding']=tradesDate[key][value.seccode2.seccode]['vol']*tradesDate[key][value.seccode2.seccode]['PREV_SWAP_RATE']*tonumber(getParamEx(CLASS_CODE, value.seccode2.seccode,'LOTSIZE').param_value*-1)
						tradesDate[key][value.seccode1.seccode]['cost']=func.correctsum(value.seccode1.seccode,tradesDate[key][value.seccode1.seccode]['basevol']*tradesDate[key][value.seccode1.seccode]['CLPRICE'])
						tradesDate[key][value.seccode2.seccode]['cost']=func.correctsum(value.seccode2.seccode,tradesDate[key][value.seccode2.seccode]['basevol']*tradesDate[key][value.seccode2.seccode]['CLPRICE'])
						
						-- Блок расчета финансового результата за текущий день после торговой сессии
						if PrevValue[key]~=nil then
							tradesDate[key][value.seccode1.seccode]['vm']=func.correctsum(value.seccode1.seccode,(tradesDate[key][value.seccode1.seccode]['CLPRICE']-PrevValue[key][value.seccode1.seccode]['CLPRICE'])*tradesDate[key][value.seccode1.seccode]['basevol'])
							tradesDate[key][value.seccode2.seccode]['vm']=func.correctsum(value.seccode2.seccode,(tradesDate[key][value.seccode2.seccode]['CLPRICE']-PrevValue[key][value.seccode2.seccode]['CLPRICE'])*tradesDate[key][value.seccode2.seccode]['basevol'])
							CalcVmNew (tradesDate[key][value.seccode1.seccode], PrevValue[key][value.seccode1.seccode], value.seccode1.seccode)
							CalcVmNew (tradesDate[key][value.seccode2.seccode], PrevValue[key][value.seccode2.seccode], value.seccode2.seccode)						
						end
						-- конец блока
						tradesDate[key][value.seccode1.seccode]['index']=key..'_'..func.datetime() --os.date("%x",os.time(dateT))					
						tradesDate[key][value.seccode2.seccode]['index']=key..'_'..func.datetime() --os.date("%x",os.time(dateT))
						
						func.inTable (tt1, 'CalcTrades '..key..' пересчет vol, basevol, funding, cost')
						func.savetable_new(trades,getScriptPath()..'//trades//trades_'..os.date("%Y%m%d")..'.txt')
					end
				
					if tradesDate[key][value.seccode1.seccode]['cost']==0 and tradesDate[key][value.seccode1.seccode]['vol']~=0 then 
						tradesDate[key][value.seccode1.seccode]['cost']=func.correctsum(value.seccode1.seccode,tradesDate[key][value.seccode1.seccode]['basevol']*tradesDate[key][value.seccode1.seccode]['CLPRICE'])
						--tradesDate[key][value.seccode1.seccode]['index']=key..'_'..os.date("%x",os.time(dateT))	
					end
					if tradesDate[key][value.seccode2.seccode]['cost']==0 and tradesDate[key][value.seccode2.seccode]['vol']~=0 then 
						tradesDate[key][value.seccode2.seccode]['cost']=func.correctsum(value.seccode2.seccode,tradesDate[key][value.seccode2.seccode]['basevol']*tradesDate[key][value.seccode2.seccode]['CLPRICE'])
						--tradesDate[key][value.seccode2.seccode]['index']=key..'_'..os.date("%x",os.time(dateT))
					end
			end
		end
		CalcVM(tradesDate)
		tradesDate.flag=os.time()
		--trades[dateT.year][dateT.month][dateT.day]=tradesDate
		func.savetable_new(trades,TradesPath)
		func.savetable_new(trades,TradesPath2)
		func.inTable (tt1, 'CalcTrades созданы резервная копия trades')
		func.savetable(tool,ToolPath)
		func.savetable(tool,ToolPath2)
		func.inTable (tt1, 'CalcTrades созданы резервная копия tool')
		--Orders = func.loadtable(OrdersPath)	
		func.savetable(Orders,OrdersPath2)
		func.savetable(Trends,TrendsPath2)
		--OrderTable=func.loadtable(OrderTablePath)
		func.savetable(OrderTable,OrderTablePath2)
		func.inTable (tt1, 'CalcTrades созданы резервные копии ключевых таблиц')
		--func.inTable (tt1, 'CalcTrades обновлена дата '..dateT.day)
	end
	
end

function MemoryFirstdate(key,position)
	if memory.buy[position..tool[key].seccode1.preffix].firstdate~=0 and memory.buy[position..tool[key].seccode1.preffix].firstdate< memory.sell[position..tool[key].seccode1.preffix].firstdate then 
		return memory.buy[position..tool[key].seccode1.preffix].firstdate
	elseif memory.sell[position..tool[key].seccode1.preffix].firstdate~=0 then 
		return memory.sell[position..tool[key].seccode1.preffix].firstdate
	else return os.time()
	end
end 

function GetAvgFunding(key,seccode, days)
	
	local localTime=os.time()
	local funding=0
	m=0
	for n=days,0,-1 do
		dateT=os.date("*t",localTime)
		tradesDate=trades[dateT.year][dateT.month][dateT.day]
		if trades[dateT.year][dateT.month][dateT.day]~=nil and trades[dateT.year][dateT.month][dateT.day][key]~=nil 
			and trades[dateT.year][dateT.month][dateT.day][key][seccode]~=nil and trades[dateT.year][dateT.month][dateT.day][key][seccode].PREV_SWAP_RATE~=nil then 
				m=m+1
				funding=funding+trades[dateT.year][dateT.month][dateT.day][key][seccode].PREV_SWAP_RATE
				--func.inTable (tt1, 'GetAvgFunding '..key..' '..m..' ' ..os.date("%x",localTime)..' SWAP_RATE '.. trades[dateT.year][dateT.month][dateT.day][key][seccode].PREV_SWAP_RATE..' funding '..funding)
		end
		localTime=localTime-86400
	end
	if m==0 then m=1 end
	return funding/m
end

function FundingCalc(key,position)

	dateT=os.date("*t",os.time())
	--if trades[dateT.year][dateT.month][dateT.day][key]==nil then dateS=os.date("%x",os.time()-86400) 
	--else dateS=os.date("%x",os.time())
	--end
	dateS=os.time()
	
	if Options.pos[position].funding==nil or Options.pos[position].funding.date<dateS-1800 then  --(Options.pos[position].funding.date~=dateS and Options.pos[position].funding2.date~=dateS)  then 
		Options.pos[position].funding={}
		Options.pos[position].funding.sum=0
		Options.pos[position].funding2={}
		Options.pos[position].funding2.sum=0
		Options.pos[position].funding.avg=0
		Options.pos[position].funding2.avg=0
		localTime=MemoryFirstdate(key,position)
		Options.pos[position].funding.date=dateS
		Options.pos[position].funding2.date=dateS
		Options.pos[position].funding.EnterDate=os.date("%x",localTime)
		Options.pos[position].funding2.EnterDate=os.date("%x",localTime)	

		--func.inTable (tt1, 'FundingCalc '..key..' ' ..os.date("%x",localTime))
		n=0
		k=0
		local AverageGo1=0
		local AverageGo2=0
		local AverageGo=0
		local AverageGoCount=0
		while localTime<os.time() do
			dateT=os.date("*t",localTime)
			tradesDate=trades[dateT.year][dateT.month][dateT.day]
			if tradesDate~=nil and tradesDate[key]~=nil then 
				--func.inTable (tt1, 'FundingCalc '..key)
				if tradesDate[key][tool[key].seccode1.seccode]['funding']==nil then tradesDate[key][tool[key].seccode1.seccode]['funding']=0 end
				if tradesDate[key][tool[key].seccode2.seccode]['funding']==nil then tradesDate[key][tool[key].seccode2.seccode]['funding']=0 end
				Options.pos[position].funding.sum=Options.pos[position].funding.sum+tradesDate[key][tool[key].seccode1.seccode]['funding']
				Options.pos[position].funding2.sum=Options.pos[position].funding2.sum+tradesDate[key][tool[key].seccode2.seccode]['funding']
				Options.pos[position].funding.date=dateS
				Options.pos[position].funding2.date=dateS
				
				Options.pos[position].funding.avg=Options.pos[position].funding.avg+tradesDate[key][tool[key].seccode1.seccode]['PREV_SWAP_RATE']
				Options.pos[position].funding2.avg=Options.pos[position].funding2.avg+tradesDate[key][tool[key].seccode2.seccode]['PREV_SWAP_RATE']	
				if tradesDate[key][tool[key].seccode1.seccode].go~=nil then 
					AverageGo1=AverageGo1+tradesDate[key][tool[key].seccode1.seccode].go
					AverageGo2=AverageGo2+tradesDate[key][tool[key].seccode2.seccode].go
					AverageGoCount=AverageGoCount+1
				end
				--func.inTable (tt1, 'FundingCalc выполнен расчет до '..os.date("%x",localTime))
				--func.inTable (tt1, 'FundingCalc '..key..' '..n..' ' ..os.date("%x",localTime)..' ' ..Options.pos[position].funding.avg)
				n=n+1
			end
			localTime=localTime+86400
			k=k+1
		end
		if AverageGo1>AverageGo2 then AverageGo=AverageGo1 else AverageGo=AverageGo2 end

		local ExpireTbl={}
		ExpireTbl=getExpireTbl(tool[key].seccode2.seccode)
		if ExpireTbl.year==2100 then ExpireTbl=getExpireTbl(tool[key].seccode1.seccode) end
		if ExpireTbl.year==2100 then --or ExpireTbl.year==2026 then 	
			ExpireTbl.year=2025
			ExpireTbl.month=12
			ExpireTbl.day=18
		end
		m=0
		l=0
		while localTime<os.time(ExpireTbl) do
			dateT=os.date("*t",localTime)
			--func.inTable (tt1, key..' 2 '..tool[key].seccode2.seccode..' '..func.Tbl2Str(dateT))
			tradesDate=trades[dateT.year][dateT.month][dateT.day]
			if tradesDate~=nil then 
				m=m+1
			end
			localTime=localTime+86400
			l=l+1
		end
		if n==0 then n=1 end
		if k==0 then k=1 end

		Options.pos[position].funding.avg=Options.pos[position].funding.avg/n
		--func.inTable (tt1, 'FundingCalc avg '..key..' ' ..Options.pos[position].funding.avg)
		Options.pos[position].funding2.avg=Options.pos[position].funding2.avg/n
		Options.pos[position].funding.durationCur=n
		Options.pos[position].funding2.durationCur=n
		Options.pos[position].funding.duration=n+m
		Options.pos[position].funding2.duration=n+m

		Options.pos[position].funding.durationCurReal=k
		Options.pos[position].funding2.durationCurReal=k
		Options.pos[position].funding.durationReal=k+l
		Options.pos[position].funding2.durationReal=k+l
		
		if AverageGoCount==0 then AverageGoCount=1 end
		Options.pos[position].funding.AvgGo=AverageGo/AverageGoCount
		--if Options.pos[position].funding.AvgGo==nil then Options.pos[position].funding.AvgGo=1 end
		Options.pos[position].funding2.AvgGo=Options.pos[position].funding.AvgGo

		local multiplier1=tonumber(getParamEx(CLASS_CODE, tool[key].seccode1.seccode,'LOTSIZE').param_value)
		local multiplier2=tonumber(getParamEx(CLASS_CODE, tool[key].seccode2.seccode,'LOTSIZE').param_value)
		
		--Options.pos[position].funding.total=Options.pos[position].funding.duration*Options.pos[position].funding.avg*multiplier1*math.abs(Options.pos[position].total.vol)
		--Options.pos[position].funding2.total=Options.pos[position].funding2.duration*Options.pos[position].funding2.avg*multiplier2*math.abs(Options.pos[position].total2.vol)

		Options.pos[position].funding.AvgFunding=GetAvgFunding(key,tool[key].seccode1.seccode,20)
		Options.pos[position].funding2.AvgFunding=GetAvgFunding(key,tool[key].seccode2.seccode,20)
		
		Options.pos[position].funding.total=Options.pos[position].funding.sum+(
			(Options.pos[position].funding.duration-Options.pos[position].funding.durationCur)*Options.pos[position].funding.AvgFunding*tonumber(getParamEx(CLASS_CODE, tool[key].seccode1.seccode,'LOTSIZE').param_value*-1)*(Options.pos[position].total.vol))

		Options.pos[position].funding2.total=Options.pos[position].funding2.sum+(
			(Options.pos[position].funding2.duration-Options.pos[position].funding2.durationCur)*Options.pos[position].funding2.AvgFunding*tonumber(getParamEx(CLASS_CODE, tool[key].seccode2.seccode,'LOTSIZE').param_value*-1)*(Options.pos[position].total2.vol))
		--if key='GLD-CNY' then 
		--	func.inTable (tt1, 'Options.pos[position].funding2.sum '..Options.pos[position].funding2.sum)
		--	func.inTable (tt1, 'Options.pos[position].funding2.duration-Options.pos[position].funding2.durationCur '..Options.pos[position].funding2.duration-Options.pos[position].funding2.durationCur)
		--	func.inTable (tt1, 'Options.pos[position].funding2.AvgFunding '..Options.pos[position].funding2.AvgFunding)
		--	func.inTable (tt1, 'LOTSIZE '..tonumber(getParamEx(CLASS_CODE, tool[key].seccode2.seccode,'LOTSIZE').param_value)
		--	func.inTable (tt1, 'Options.pos[position].funding2.sum '..Options.pos[position].funding2.sum)
		--end
		Options.pos[position].funding.new=(Options.pos[position].funding.duration-Options.pos[position].funding.durationCur)*Options.pos[position].funding.AvgFunding*multiplier1
		Options.pos[position].funding2.new=(Options.pos[position].funding2.duration-Options.pos[position].funding2.durationCur)*Options.pos[position].funding2.AvgFunding*multiplier2
		
	end

end

function YieldCalc(value)
	
	local_price=value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER
	local_days=getParamEx(CLASS_CODE, value.seccode2.seccode,'DAYS_TO_MAT_DATE').param_value
	local_go=getParamEx(CLASS_CODE,value.seccode2.seccode, "SELLDEPO").param_value

	yield=local_price/local_go*100/local_days*365
	--func.inTable (tt1, 'YieldCalc '..value.seccode2.seccode.. ': ' .. tostring(yield))
	return yield
	
end

function CalcSignals(value,trend)
	
	Options.pos.one.Operation='long'
	Options.pos.two.Operation='short'
	Options.pos.three.Operation='long'
	
	longmaxvol=Options.pos.one.maxvol
	longstepvol=Options.pos.one.stepvol
	longstep=Options.pos.one.step
	shortmaxvol=Options.pos.two.maxvol
	shortstepvol=Options.pos.two.stepvol
	shortstep=Options.pos.two.step
	shortn=1
	longn=1
	
	if trend=='long' then 
		if value.DeltaD_20>value.DeltaM30_200 and value.DeltaD_20<value.DeltaM30_20 then 
			longexitsignal=value.DeltaD_20
			shortentersignal=value.DeltaD_20
		else
			longexitsignal=value.DeltaM30_200
			shortentersignal=value.DeltaM30_200
		end
		--if value.seccode2.seccode=='GLH5' then 
		--	func.inTable (tt1,'GLH5 '..shortentersignal..' shortstep '..shortstep.. ' '..shortentersignal-shortstep )
		--
		--end 
		longentersignal=value.DeltaM30_20+longstep
		shortexitsignal=longentersignal
		for n=1,10 do
			if value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER>longentersignal+longstep then 
				longmaxvol=longmaxvol+longstepvol
				longentersignal=longentersignal+longstep
				longn=n
			end
			if value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID<shortentersignal-shortstep then 
				shortmaxvol=shortmaxvol+shortstepvol
				shortentersignal=shortentersignal-shortstep
				shortn=n						
			--func.inTable (tt1,'GLH5 shortmaxvol '..shortmaxvol..' shortstepvol '..shortstepvol)

			end
		end
	elseif trend=='short' then 
		if value.DeltaD_20<value.DeltaM30_200 and value.DeltaD_20>value.DeltaM30_20 then 
			shortexitsignal=value.DeltaD_20
			longentersignal=value.DeltaD_20
		else
			shortexitsignal=value.DeltaM30_200
			longentersignal=value.DeltaM30_200
		end
		shortentersignal=value.DeltaM30_20-shortstep
		longexitsignal=shortentersignal
		for n=1,10 do
			if value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID<shortentersignal-shortstep then 
				shortmaxvol=shortmaxvol+shortstepvol
				shortentersignal=shortentersignal-shortstep
				shortn=n
			end
			if value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER>longentersignal+longstep then 
				longmaxvol=longmaxvol+longstepvol
				longentersignal=longentersignal+longstep
				longn=n
			end
		end
	end

	Options.pos.one.entersignal=longentersignal
	Options.pos.one.exitsignal=longexitsignal
	Options.pos.one.maxvol=longmaxvol
	Options.pos.one.n=longn
		
	--Options.pos.three.entersignal=longentersignal
	--Options.pos.three.exitsignal=longexitsignal
	--Options.pos.three.maxvol=longmaxvol
	--Options.pos.three.n=longn

	Options.pos.two.entersignal=shortentersignal
	Options.pos.two.exitsignal=shortexitsignal
	Options.pos.two.maxvol=shortmaxvol
	Options.pos.two.n=shortn

	if Options.pos.one.manualentersignal~=0 then Options.pos.one.entersignal=Options.pos.one.manualentersignal end
	if Options.pos.two.manualentersignal~=0 then Options.pos.two.entersignal=Options.pos.two.manualentersignal end	

end

function CheckEnterSignal_Arb(value)
	Options.pos.one.OpenPos=false
	Options.pos.two.OpenPos=false
	Options.pos.three.OpenPos=false

	--func.inTable (tt1, 'CheckEnterSignal_Arb '..value.seccode1.seccode..' '..value.seccode2.seccode..' ' ..tostring (Options.pos.one.entersignal)..tostring(func.Tbl2Str(value)))
	if Options.pos.one.Operation=='long' then 
		if value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER>Options.pos.one.entersignal   then Options.pos.one.OpenPos=true end
		if value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID<Options.pos.two.entersignal then Options.pos.two.OpenPos=true end -- and math.abs(Options.pos.two.entersignal-Options.pos.two.exitsignal)>Options.pos.two.step then Options.pos.two.OpenPos=true end
		--if value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER>Options.pos.three.entersignal and math.abs(Options.pos.three.entersignal-Options.pos.three.exitsignal)>Options.pos.three.step  then Options.pos.three.OpenPos=true end		
	elseif Options.pos.one.Operation=='short' then 
		if value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID<Options.pos.one.entersignal  then Options.pos.one.OpenPos=true end	
		if  value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER>Options.pos.two.entersignal then Options.pos.two.OpenPos=true end -- and math.abs(Options.pos.two.entersignal-Options.pos.two.exitsignal)>Options.pos.two.step then Options.pos.two.OpenPos=true end
		--if value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER>Options.pos.three.entersignal and math.abs(Options.pos.three.entersignal-Options.pos.three.exitsignal)>Options.pos.three.step  then Options.pos.three.OpenPos=true end		
	end
	
end

function CheckExitSignal_Arb(value)
	Options.pos.one.ClosePos=false
	Options.pos.two.ClosePos=false
	Options.pos.three.ClosePos=false
	
	local OneProffit=Options.pos.one.total.proffit+Options.pos.one.total2.proffit
	local TwoProffit=Options.pos.two.total.proffit+Options.pos.two.total2.proffit	
	local ThreeProffit=Options.pos.three.total.proffit+Options.pos.three.total2.proffit	
	
	if Options.pos.one.Operation=='short' then 
		if value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER>Options.pos.one.exitsignal and Options.pos.one.total.vol~=0 and OneProffit>Options.pos.one.minProffit then Options.pos.one.ClosePos=true end
		if value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID<Options.pos.two.exitsignal and Options.pos.two.total.vol~=0 and TwoProffit>Options.pos.two.minProffit then Options.pos.two.ClosePos=true end
		--if value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID<Options.pos.three.exitsignal and Options.pos.three.total.vol~=0 and ThreeProffit>Options.pos.three.minProffit then Options.pos.three.ClosePos=true end		
	elseif Options.pos.one.Operation=='long' then 
		if value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID<Options.pos.one.exitsignal and Options.pos.one.total.vol~=0 and OneProffit>Options.pos.one.minProffit then Options.pos.one.ClosePos=true end	
		if value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER>Options.pos.two.exitsignal and Options.pos.two.total.vol~=0 and TwoProffit>Options.pos.two.minProffit then Options.pos.two.ClosePos=true end
		--if value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID<Options.pos.three.exitsignal and Options.pos.three.total.vol~=0 and ThreeProffit>Options.pos.three.minProffit then Options.pos.three.ClosePos=true end		
	end

	if Options.pos.one.vol==-100 and OneProffit>Options.pos.one.minProffit then Options.pos.one.ClosePos=true end	
	if Options.pos.two.vol==-100 and TwoProffit>Options.pos.two.minProffit  then Options.pos.two.ClosePos=true end	
	if Options.pos.three.vol==-100 and ThreeProffit>Options.pos.three.minProffit then Options.pos.three.ClosePos=true end	
		
end

function CheckRest(value,op,number,open)
	if value.strategy202106.minrest==0 then return true end
	
	--if value.strategy202106.OnlyShort then return true end
	if number~=nil and number=='one' and open~=nil and open==true then 
		return true 
	elseif number~=nil and number=='two' and open~=nil and not open then 
		return true 
	end

	local rest=func.GetPlanRest()
	--func.inTable (tt1, 'CheckRest '..rest)
	
	if rest==0 then return true end	
	if rest<value.strategy202106.minrest then return false end	
	
	if op==1 and getParamEx("SPBFUT",value.seccode1.seccode, "buydepo").param_value
		+getParamEx("SPBFUT",value.seccode2.seccode, "SELLDEPO").param_value<rest then return true
	elseif getParamEx("SPBFUT",value.seccode1.seccode, "SELLDEPO").param_value
		+getParamEx("SPBFUT",value.seccode2.seccode, "buydepo").param_value<rest then return true
	else return false
	end
	
end

function ChangeMemoryTrend_Arb(value)
	
	local two1='two'..value.seccode1.preffix
	local two2='two'..value.seccode2.preffix
	local one1='one'..value.seccode1.preffix
	local one2='one'..value.seccode2.preffix
	local temp1='temp'..value.seccode1.preffix
	local temp2='temp'..value.seccode2.preffix
	func.inTable (tt1, 'начало смены тренда '..func.Tbl2Str(memory))
	
	memory.buy[temp1]={}
	memory.buy[temp2]={}
	memory.buy[temp1]=memory.buy[one1]
	memory.buy[temp2]=memory.buy[one2]	
	memory.buy[one1]=memory.buy[two1]
	memory.buy[one2]=memory.buy[two2]
	memory.buy[two1]=memory.buy[temp1]
	memory.buy[two2]=memory.buy[temp2]
	memory.buy[temp1]=nil
	memory.buy[temp2]=nil

	memory.sell[temp1]={}
	memory.sell[temp2]={}
	memory.sell[temp1]=memory.sell[one1]
	memory.sell[temp2]=memory.sell[one2]	
	memory.sell[one1]=memory.sell[two1]
	memory.sell[one2]=memory.sell[two2]
	memory.sell[two1]=memory.sell[temp1]
	memory.sell[two2]=memory.sell[temp2]
	memory.sell[temp1]=nil
	memory.sell[temp2]=nil
	func.inTable (tt1, 'смена тренда '..func.Tbl2Str(memory))
end

function OperationEngine_Arb(value)

	--Выполнение операций
	for number,pos in pairs(Options.pos) do
		--func.inTable (tt1, 'OperationEngine_Arb '..number..value.preffix..' ' ..tostring(pos.vol))
		vol=pos.vol
		tframe=number..value.preffix
		tframe2=number..value.preffix2
		--func.inTable (tt1, 'OperationEngine_Arb '..tframe)
		if number=='one' and	Options.pos.one.total2.vol==0 and Options.pos.one.total.vol==0  
		and memory.buy[tframe].vol==memory.sell[tframe].vol and memory.sell[tframe].vol>0 
		and memory.buy[tframe2].vol==memory.sell[tframe2].vol and memory.sell[tframe2].vol>0   
		then
			func.inTable (tt1, 'OperationEngine_Arb closetradeOne '..tframe ..' '..tframe2)
			closetradeOne (tframe,memory.buy[tframe].tool)
			closetradeOne (tframe2,memory.buy[tframe2].tool)
		end
		if pos.total.vol~=0 and pos.ClosePos then
			if pos.Operation=='long' and memory.buy[tframe].vol>0 and CheckRest(value,1,number,false) then
				if transaction(memory.buy,tframe2,'B',memory.buy[tframe2].tool,'short',value.seccode2) then
					transaction(memory.sell,tframe,'S',memory.sell[tframe].tool,pos.Operation,value.seccode1) 
					--robot.inform (Key..' ClosePos '..number..' exitsignal:'..func.roundS(pos.exitsignal)..' '..memory.buy[tframe].tool..'*'..tostring(memory.buy[tframe].newvol)..'; '..memory.buy[tframe2].tool..'*'..tostring(memory.buy[tframe2].newvol))
				end
					
				return true
			elseif pos.Operation=='short' and memory.sell[tframe].vol>0 and CheckRest(value,2,number,false) then
				if transaction(memory.sell,tframe2,'S',memory.sell[tframe2].tool,'long',value.seccode2) then
					transaction(memory.buy,tframe,'B',memory.buy[tframe].tool,'long',value.seccode1) 
					--robot.inform (Key..' ClosePos '..number..' exitsignal:'..func.roundS(pos.exitsignal)..' '..memory.buy[tframe].tool..'*'..tostring(memory.buy[tframe].newvol)..'; '..memory.buy[tframe2].tool..'*'..tostring(memory.buy[tframe2].newvol))
				end
				return true
			end
		end
	end	
	
	for number,pos in pairs(Options.pos) do
		vol=pos.vol
		tframe=number..value.preffix
		tframe2=number..value.preffix2
		
		if vol>0 and pos.OpenPos and not pos.ClosePos then --and pos.total.vol==0
			if pos.Operation=='long' and memory.buy[tframe].vol-memory.sell[tframe].vol<pos.maxvol and CheckRest(value,1,number,true) then
				if transaction(memory.buy,tframe,'B',memory.buy[tframe].tool, pos.Operation,value.seccode1) then 
					transaction(memory.sell,tframe2,'S',memory.sell[tframe2].tool,'short',value.seccode2) 
					--robot.inform (Key..' OpenPos '..number..' entersignal:'..func.roundS(pos.entersignal)..' '..memory.buy[tframe].tool..'*'..tostring(memory.buy[tframe].newvol)..'; '..memory.buy[tframe2].tool..'*'..tostring(memory.buy[tframe2].newvol))
				end
				return true
			elseif pos.Operation=='short' and memory.sell[tframe].vol-memory.buy[tframe].vol<pos.maxvol  and CheckRest(value,2,number,true) then
				if transaction(memory.sell,tframe,'S',memory.sell[tframe].tool, pos.Operation,value.seccode1) then 
					transaction(memory.buy,tframe2,'B',memory.buy[tframe2].tool,'long',value.seccode2) 
					--robot.inform (Key..' OpenPos '..number..' entersignal:'..func.roundS(pos.entersignal)..' '..memory.buy[tframe].tool..'*'..tostring(memory.buy[tframe].newvol)..'; '..memory.buy[tframe2].tool..'*'..tostring(memory.buy[tframe2].newvol))
				end
				return true
			end		
		end
	end

	
	--func.inTable (tt1, 'OperationEngine_Arb '..tframe2)
	--if tframe2=='twoEu2' or tframe2=='oneEu2'  or tframe2=='threeEu2' then
	--	func.inTable (tt1, 'OperationEngine_Arb '..tframe2)
	--	closetradeOne ('oneEu2','EuH5')
	--	closetradeOne ('oneEu4','EURRUBF')
	--end
	
	return false
end

function ResetN(tframe1,tframe2)
	func.inTable (tt1,'ResetN '..tostring(tframe1)..' '..tostring(tframe2))
	if tframe1~=nil then 
		memory.buy[tframe1].n=0 
		memory.sell[tframe1].n=0 
	end

	if tframe2~=nil then 
		memory.buy[tframe2].n=0 
		memory.sell[tframe2].n=0 
	end
	func.savetable(memory,FPath)
end

function ThreePosEngine(value, key)

	tframe='three'..value.preffix
	tframe2='three'..value.preffix2
	step=Options.pos.three.step
	stepvol=Options.pos.three.stepvol
	maxvol=Options.pos.three.maxvol
	step1=step
	step2=step
	delta_sell=value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER --дельта для продажи
	delta_buy=value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID --дельта для покупки
	numb=2
	numbstop=4
	numbstop2=6

	TotalVol=Options.pos.three.total.vol+Options.pos.three.total2.vol
	stopvol=math.abs(Options.pos.three.total.vol+Options.pos.three.total2.vol)
	stepprice=0
	stopprice=0
	if value.seccode1.PRICE_OFFER==0 or value.seccode2.PRICE_OFFER==0 or value.seccode1.PRICE_BID==0 or value.seccode2.PRICE_BID==0 then return false end
	if Options.pos.three.total.vol+Options.pos.three.total2.vol==0 and Options.pos.three.total.vol~=0 and (memory.buy[tframe].n~=0 or memory.buy[tframe2].n~=0 or memory.sell[tframe].n~=0 or memory.sell[tframe2].n~=0) then 
		ResetN(tframe,tframe2) 
	end
	if Options.pos.three.total.vol>0 and Options.pos.three.total.vol<maxvol then 			
		--проверка для увеличения позиции
		stepprice=(memory.buy[tframe].lastprice)*value.seccode1.multiplier+(step1/2)
		if value.seccode1.PRICE_OFFER>stepprice and TotalVol>=0 then 
			func.inTable (tt1,value.seccode1.PRICE_OFFER..' '..key..' 1 ThreePosEngine В '..tframe..' '.. memory.buy[tframe].tool..' '..stepvol/2)
			func.green(t_id, rowmassive[key..memory.buy[tframe].tool].row, 22)
			robot.transaction(memory.buy,tframe,'B',memory.buy[tframe].tool,stepvol/2,-1)
			CompleteOrders(key,'flat','B')
		end
		-- проверка для закрытия позиции
		if memory.buy[tframe].n>numbstop then step1=step/2 end --уменьшение стопа если тренд уже идет долго 
		stopprice=memory.buy[tframe].lastprice*value.seccode1.multiplier-step1
		if memory.buy[tframe].n<=numbstop2 and  StateTableM30.par.stop == "поддержка" and StateTableM30.par.par*value.seccode1.multiplier<stopprice then 
			stopprice=StateTableM30.par.par*value.seccode1.multiplier
		end
		if (Options.pos.three.mode==nil or Options.pos.three.mode=='arb') and TotalVol>0 and value.seccode1.PRICE_BID<stopprice then 
			
			func.inTable (tt1, value.seccode1.PRICE_BID..' '..key..' 2 ThreePosEngine стоп для '..tframe..' '.. memory.buy[tframe].tool..' продаем '..stopvol..' '..tframe2..' '.. memory.sell[tframe2].tool..' timer='..os.time()-Options.pos.three.StopTime)
			func.red(t_id, rowmassive[key..memory.buy[tframe].tool].row, 23)
			
			if Options.pos.three.StopTime==nil then Options.pos.three.StopTime=0 end
			if Options.pos.three.StopTime==0 then Options.pos.three.StopTime=os.time() end
			if Options.pos.three.StopTime~=0 and os.time()-Options.pos.three.StopTime<300 then return false end 

			lastprice=memory.sell[tframe2].lastprice
			if memory.buy[tframe].n<=numb and math.abs(TotalVol)-stepvol/2~=0 then 
				stopvol=stepvol/2
				memory.buy[tframe].lastprice=(value.seccode1.PRICE_BID+step1/2)/value.seccode1.multiplier
			end
			robot.transaction(memory.sell,tframe2,'S',memory.sell[tframe2].tool,stopvol,-1)
			memory.sell[tframe2].lastprice=lastprice
			if memory.buy[tframe].n>numb then ResetN(tframe,tframe2) end
			func.savetable(memory,FPath)
		elseif  Options.pos.three.mode=='stoploss' and TotalVol>0  then 
			memory.sell[tframe].stop='step'
			memory.sell[tframe].stopprice=stopprice/value.seccode1.multiplier	
			memory.sell[tframe].stopvol=math.abs(TotalVol)
			func.savetable(memory,FPath)				
		else Options.pos.three.StopTime=0 end
		SetCell(t_id, rowmassive[key..memory.buy[tframe].tool].row, 22, dell0(stepprice))
		SetCell(t_id, rowmassive[key..memory.buy[tframe].tool].row, 23, dell0(stopprice))
		if StateTableD.par.stop == "сопротивление" then 
			SetCell(t_id, rowmassive[key..memory.buy[tframe].tool].row, 25, dell0(StateTableD.par.par))
			value.seccode1.par=StateTableD.par.par
		else
			SetCell(t_id, rowmassive[key..memory.buy[tframe].tool].row, 25, '')
			value.seccode1.par=0
		end
		if StateTableM30.par.stop == "сопротивление" then 
			SetCell(t_id, rowmassive[key..memory.buy[tframe].tool].row, 26, dell0(StateTableM30.par.par))
			value.seccode1.parM30=StateTableM30.par.par
		else
			SetCell(t_id, rowmassive[key..memory.buy[tframe].tool].row, 26, '')
			value.seccode1.parM30=0
		end
		--func.yellow (t_id,rowmassive[key..memory.sell[tframe].tool].row, 22)
	elseif Options.pos.three.total.vol<0 and math.abs(Options.pos.three.total.vol)<maxvol then 			
		stepprice=(memory.sell[tframe].lastprice)*value.seccode1.multiplier -(step1/2)
		if value.seccode1.PRICE_BID<stepprice and TotalVol<=0  then 
			func.inTable (tt1, value.seccode1.PRICE_BID..' '..key..' 3 ThreePosEngine S '..tframe..' '.. memory.sell[tframe].tool..' '..stepvol/2)				
			func.green(t_id, rowmassive[key..memory.sell[tframe].tool].row, 22)
			robot.transaction(memory.sell,tframe,'S',memory.sell[tframe].tool,stepvol/2,-1)
			CompleteOrders(key,'flat','S')
		end
		if memory.sell[tframe].n>numbstop then step1=step/2 end --уменьшение стопа если тренд уже идет долго 
		stopprice=memory.sell[tframe].lastprice*value.seccode1.multiplier+step1
		if memory.sell[tframe].n<=numbstop2 and  StateTableM30.par.stop == "сопротивление" and StateTableM30.par.par*value.seccode1.multiplier>stopprice then 
			stopprice=StateTableM30.par.par*value.seccode1.multiplier
		end
		if (Options.pos.three.mode==nil or Options.pos.three.mode=='arb') and TotalVol<0 and value.seccode1.PRICE_OFFER>stopprice then 
			func.inTable (tt1, value.seccode1.PRICE_OFFER..' '..key..' 4 ThreePosEngine стоп для '..tframe..' '.. memory.buy[tframe].tool..' покупаем '..stopvol..' '..tframe2..' '.. memory.sell[tframe2].tool..' timer='..os.time()-Options.pos.three.StopTime)
			func.red(t_id, rowmassive[key..memory.sell[tframe].tool].row, 23)
			
			if Options.pos.three.StopTime==nil then Options.pos.three.StopTime=0 end
			if Options.pos.three.StopTime==0 then Options.pos.three.StopTime=os.time() end
			if Options.pos.three.StopTime~=0 and os.time()-Options.pos.three.StopTime<300 then return false end 
			
			lastprice=memory.buy[tframe2].lastprice
			if memory.sell[tframe].n<=numb  and math.abs(TotalVol)-stepvol/2~=0 then 
				stopvol=stepvol/2
				memory.sell[tframe].lastprice=(value.seccode1.PRICE_OFFER-step1/2)/value.seccode1.multiplier
			end
			robot.transaction(memory.buy,tframe2,'B',memory.buy[tframe2].tool,stopvol,-1)
			memory.buy[tframe2].lastprice=lastprice
			if memory.sell[tframe].n>numb then ResetN(tframe,tframe2) end
			func.savetable(memory,FPath)
		elseif   Options.pos.three.mode=='stoploss' and TotalVol<0  then 
			memory.buy[tframe].stop='step'
			memory.buy[tframe].stopprice=stopprice/value.seccode1.multiplier
			memory.buy[tframe].stopvol=math.abs(TotalVol)
			func.savetable(memory,FPath)
		else Options.pos.three.StopTime=0 	
		end
		
		SetCell(t_id, rowmassive[key..memory.sell[tframe].tool].row, 22, dell0(stepprice))
		SetCell(t_id, rowmassive[key..memory.sell[tframe].tool].row, 23, dell0(stopprice))
		if StateTableD.par.stop == "поддержка" then 
			SetCell(t_id, rowmassive[key..memory.sell[tframe].tool].row, 25, dell0(StateTableD.par.par))
			value.seccode1.par=StateTableD.par.par
		else
			SetCell(t_id, rowmassive[key..memory.sell[tframe].tool].row, 25, '')
			value.seccode1.par=0
		end
		if StateTableM30.par.stop == "поддержка" then 
			SetCell(t_id, rowmassive[key..memory.sell[tframe].tool].row, 26, dell0(StateTableM30.par.par))
			value.seccode1.parM30=StateTableM30.par.par
		else
			SetCell(t_id, rowmassive[key..memory.sell[tframe].tool].row, 26, '')
			value.seccode1.parM30=0
		end
		--func.yellow (t_id,rowmassive[key..memory.sell[tframe].tool].row, 22)
	end

	if Options.pos.three.total2.vol>0 and Options.pos.three.total2.vol<maxvol then 			
		stepprice=(memory.buy[tframe2].lastprice)*value.seccode2.multiplier+(step2/2)
		if value.seccode2.PRICE_OFFER>stepprice and TotalVol>=0  then 
			func.inTable (tt1, value.seccode2.PRICE_OFFER..' '..key..' 5 ThreePosEngine В '..tframe2..' '.. memory.buy[tframe2].tool..' '..stepvol/2 ..' price '..value.seccode2.PRICE_OFFER)
			func.green(t_id, rowmassive[key..memory.buy[tframe2].tool].row, 22)
			robot.transaction(memory.buy,tframe2,'B',memory.buy[tframe2].tool,stepvol/2,-1)
			CompleteOrders(key,'flat','B')
		end
		if  memory.buy[tframe2].n>numbstop then step2=step/2 end --уменьшение стопа если тренд уже идет долго 			
		stopprice=memory.buy[tframe2].lastprice*value.seccode2.multiplier-step2
		if memory.buy[tframe2].n<=numbstop2 and  StateTableM302.par.stop == "поддержка" and StateTableM302.par.par*value.seccode2.multiplier<stopprice then 
			stopprice=StateTableM302.par.par*value.seccode2.multiplier
		end
		if (Options.pos.three.mode==nil or Options.pos.three.mode=='arb') and TotalVol>0 and value.seccode2.PRICE_BID<stopprice then 
			func.inTable (tt1, value.seccode2.PRICE_BID..' '..key..' 6 ThreePosEngine стоп для '..tframe2..' '.. memory.buy[tframe2].tool..' продаем '..stopvol..' '..tframe..' '.. memory.sell[tframe].tool..' timer='..os.time()-Options.pos.three.StopTime2)
			func.red(t_id, rowmassive[key..memory.buy[tframe2].tool].row, 23)
			
			if Options.pos.three.StopTime2==nil then Options.pos.three.StopTime2=0 end
			if Options.pos.three.StopTime2==0 then Options.pos.three.StopTime2=os.time() end
			if Options.pos.three.StopTime2~=0 and os.time()-Options.pos.three.StopTime2<300 then return false end 
			
			lastprice=memory.sell[tframe].lastprice
			if memory.buy[tframe2].n<=numb and math.abs(TotalVol)-stepvol/2~=0 then 
				stopvol=stepvol/2
				memory.buy[tframe2].lastprice=(value.seccode2.PRICE_BID+step2/2)/value.seccode2.multiplier
			end				
			robot.transaction(memory.sell,tframe,'S',memory.sell[tframe].tool,stopvol,-1)
			memory.sell[tframe].lastprice=lastprice
			if memory.buy[tframe2].n<numb then ResetN(tframe,tframe2) end
			func.savetable(memory,FPath)
		elseif   Options.pos.three.mode=='stoploss' and TotalVol>0  then 
			memory.sell[tframe2].stop='step'
			memory.sell[tframe2].stopprice=stopprice/value.seccode2.multiplier
			memory.sell[tframe2].stopvol=TotalVol
			func.savetable(memory,FPath)
		else Options.pos.three.StopTime2=0 		end
		SetCell(t_id, rowmassive[key..memory.buy[tframe2].tool].row, 22, dell0(stepprice))
		SetCell(t_id, rowmassive[key..memory.buy[tframe2].tool].row, 23, dell0(stopprice))
		if StateTableD2.par.stop == "сопротивление" then 
			SetCell(t_id, rowmassive[key..memory.buy[tframe2].tool].row, 25, dell0(StateTableD2.par.par))
			value.seccode2.par=StateTableD2.par.par
		else
			SetCell(t_id, rowmassive[key..memory.buy[tframe2].tool].row, 25, '')
			value.seccode2.par=0
		end
		if StateTableM302.par.stop == "сопротивление" then 
			SetCell(t_id, rowmassive[key..memory.buy[tframe2].tool].row, 26, dell0(StateTableM302.par.par))
			value.seccode2.parM30=StateTableM302.par.par
		else
			SetCell(t_id, rowmassive[key..memory.buy[tframe2].tool].row, 26, '')
			value.seccode2.parM30=0
		end
		--func.yellow (t_id,rowmassive[key..memory.sell[tframe2].tool].row, 22)
	elseif Options.pos.three.total2.vol<0  and math.abs(Options.pos.three.total2.vol)<maxvol then 			
		stepprice=(memory.sell[tframe2].lastprice)*value.seccode2.multiplier-(step2/2)
		if value.seccode2.PRICE_BID<stepprice and TotalVol<=0  then 
			func.inTable (tt1, value.seccode1.PRICE_BID..' '..key..' 7 ThreePosEngine S '..tframe2..' '.. memory.sell[tframe2].tool..' '..stepvol/2)
			func.green(t_id, rowmassive[key..memory.sell[tframe2].tool].row, 22)
			robot.transaction(memory.sell,tframe2,'S',memory.sell[tframe2].tool,stepvol/2,-1)
			CompleteOrders(key,'flat','S')
		end 
		if  memory.sell[tframe2].n>numbstop then step2=step/2 end --уменьшение стопа если тренд уже идет долго 			
		stopprice=memory.sell[tframe2].lastprice*value.seccode2.multiplier+step2	
		if memory.sell[tframe2].n<=numbstop2 and  StateTableM302.par.stop == "сопротивление" and StateTableM302.par.par*value.seccode2.multiplier>stopprice then 
			stopprice=StateTableM302.par.par*value.seccode2.multiplier
		end

		if (Options.pos.three.mode==nil or Options.pos.three.mode=='arb') and TotalVol<0 and value.seccode2.PRICE_OFFER>stopprice then 
			func.inTable (tt1, value.seccode2.PRICE_OFFER..' '..key..' 8 ThreePosEngine стоп для '..tframe2..' '.. memory.buy[tframe2].tool..' покупаем '..stopvol..' '..tframe..' '.. memory.sell[tframe].tool..' '..value.seccode2.PRICE_OFFER..' '..memory.buy[tframe2].lastprice..' timer='..os.time()-Options.pos.three.StopTime2)
			func.red(t_id, rowmassive[key..memory.sell[tframe2].tool].row, 23)
			
			if Options.pos.three.StopTime2==nil then Options.pos.three.StopTime2=0 end
			if Options.pos.three.StopTime2==0 then Options.pos.three.StopTime2=os.time() end
			func.inTable (tt1, 'StopTime '..Options.pos.three.StopTime2)
			if Options.pos.three.StopTime2~=0 and os.time()-Options.pos.three.StopTime2<300 then 
				return false 
			end 

			lastprice=memory.buy[tframe].lastprice				
			if memory.sell[tframe2].n<=numb and math.abs(TotalVol)-stepvol/2~=0 then 
				stopvol=stepvol/2
				memory.sell[tframe2].lastprice=(value.seccode2.PRICE_OFFER-step2/2)/value.seccode2.multiplier
			end
			robot.transaction(memory.buy,tframe,'B',memory.buy[tframe].tool,stopvol,-1)
			memory.buy[tframe].lastprice=lastprice
			if memory.sell[tframe2].n>numb then ResetN(tframe,tframe2) end				
			func.savetable(memory,FPath)
		elseif   Options.pos.three.mode=='stoploss' and TotalVol<0  then 
			memory.buy[tframe2].stop='step'
			memory.buy[tframe2].stopprice=stopprice/value.seccode2.multiplier
			memory.buy[tframe2].stopvol=math.abs(TotalVol)
			func.savetable(memory,FPath)
		else
			Options.pos.three.StopTime2=0 	
		end
		SetCell(t_id, rowmassive[key..memory.sell[tframe2].tool].row, 22, dell0(stepprice))
		SetCell(t_id, rowmassive[key..memory.sell[tframe2].tool].row, 23, dell0(stopprice))
		if StateTableD2.par.stop == "поддержка" then 
			SetCell(t_id, rowmassive[key..memory.sell[tframe2].tool].row, 25, dell0(StateTableD2.par.par))
			value.seccode2.par=StateTableD2.par.par
		else
			SetCell(t_id, rowmassive[key..memory.sell[tframe2].tool].row, 25, '')
			value.seccode2.par=0
		end
		if StateTableM302.par.stop == "поддержка" then 
			SetCell(t_id, rowmassive[key..memory.sell[tframe2].tool].row, 26, dell0(StateTableM302.par.par))
			value.seccode2.parM30=StateTableM302.par.par
		else
			SetCell(t_id, rowmassive[key..memory.sell[tframe2].tool].row, 26, '')
			value.seccode2.parM30=0
		end
		--func.yellow (t_id,rowmassive[key..memory.sell[tframe2].tool].row, 22)
	end

end

function SeccodeCollation()
	
	SecCollation={}
	
	for key,value in pairs(tool) do
		if value.strategy202106.enable then 
			if SecCollation[value.seccode1.seccode]==nil then 
				SecCollation[value.seccode1.seccode]={} 
				SecCollation[value.seccode1.seccode].tool=0
				SecCollation[value.seccode1.seccode].TotalFut=0
				SecCollation[value.seccode1.seccode].group=''
				SecCollation[value.seccode1.seccode].groupVol=0
			end
			if SecCollation[value.seccode2.seccode]==nil then 
				SecCollation[value.seccode2.seccode]={} 
				SecCollation[value.seccode2.seccode].tool=0
				SecCollation[value.seccode2.seccode].TotalFut=0
				SecCollation[value.seccode2.seccode].group=''
				SecCollation[value.seccode2.seccode].groupVol=0
			end
			SecCollation[value.seccode1.seccode].tool=SecCollation[value.seccode1.seccode].tool+value.strategy202106.pos.one.total.vol+value.strategy202106.pos.two.total.vol+value.strategy202106.pos.three.total.vol
			SecCollation[value.seccode2.seccode].tool=SecCollation[value.seccode2.seccode].tool+value.strategy202106.pos.one.total2.vol+value.strategy202106.pos.two.total2.vol+value.strategy202106.pos.three.total2.vol
			SecCollation[value.seccode1.seccode].TotalFut=func.GetTotalnetFut (value.seccode1.seccode)
			SecCollation[value.seccode2.seccode].TotalFut=func.GetTotalnetFut (value.seccode2.seccode)
			SecCollation[value.seccode1.seccode].total=SecCollation[value.seccode1.seccode].TotalFut-SecCollation[value.seccode1.seccode].tool
			SecCollation[value.seccode2.seccode].total=SecCollation[value.seccode2.seccode].TotalFut-SecCollation[value.seccode2.seccode].tool
			if value.seccode1.group~=nil then SecCollation[value.seccode1.seccode].group=value.seccode1.group end
			if value.seccode2.group~=nil then SecCollation[value.seccode2.seccode].group=value.seccode2.group end
		end
		--func.inTable (tt1,key..func.Tbl2Str(SecCollation))
	end

	--for key,value in pairs(SecCollation) do
	--	if value.group~=nil then 
	--		value.groupVol=value.groupVol+value.TotalFut
	--	end
	--	func.inTable (tt1,key..' Итого '..tostring(value.group)..' '..tostring(value.groupVol))
	--end
	--SecCollation['SiH4'].total=SecCollation['SiH4'].total+3
end

function weekendShedule()

	if func.TimePassed(18,59,30) then return false end

	if isConnected() == 1 and func.TimePassed(10,13,1) then return true
	elseif isConnected() == 0  and func.TimePassed(9,55,0) then login() 
	else return false
	end
end

function connect()
	
	if isConnected() == 1 then return true end	
	if os.date('%w')==0 or os.date('%w')==6 then return weekendShedule() end  
	
	if func.TimePassed(13,59,30) and func.TimeNotPassed(14,5,30) then return false end
	if func.TimePassed(18,49,50) and func.TimeNotPassed(19,15,30) then return false end
	if func.TimePassed(23,48,59) then return false end

	if isConnected() == 1 and func.TimePassed(9,13,1) then return true
	elseif isConnected() == 0  and func.TimePassed(8,55,0) then login() 
	else return false
	end
end

function connect2()
	
	if isConnected() == 1 then return true end	
	if func.TimePassed(13,59,30) and func.TimeNotPassed(14,5,30) then return false end
	if func.TimePassed(18,49,50) and func.TimeNotPassed(19,5,5) then return false end
	if func.TimePassed(23,48,59) then return false end

	if func.TimePassed(9,0,1) then return true
	else return false
	end
end

function rowmassiveParsing (row)
	--func.inTable (tt1,'rowmassiveParsing '.. tostring(row))
	for key,value in pairs(rowmassive) do	
		--func.inTable (tt1,'rowmassiveParsing '.. tostring(key)..' '..func.Tbl2Str(value))
		if value.row==row then 
			rowObj={}
			rowObj.key=value.key
			rowObj.seccode=value.seccode
			rowObj.row=row
			rowObj.numb=value.numb
			func.inTable (tt1,'rowmassiveParsing '.. tostring(func.Tbl2Str(rowObj)))
			return rowObj
		end
	end
end

function setLastPrice (key,seccode,numb, pos, op, lastprice)
	func.inTable (tt1,'старт setLastPrice '..key..' '..tframe.. ' '..lastprice..' '..op )	
	FPathTemp = getScriptPath()..'//'..key .. '.params'
	memoryTemp=func.loadtable(FPathTemp)
	tframe=pos..tool[key]['seccode'..numb].preffix
	memoryTemp[op][tframe].lastprice=lastprice
	func.savetable(memoryTemp,FPathTemp)
	func.inTable (tt1,'setLastPrice '..key..' '..tframe.. ' '..lastprice..' '..op )	
end

function setToolSetParameter (key,numb,pos,param,value)

	toolset[param][key][key..'_'..numb..'_'..param..'_'..pos]=value
	func.savetable(toolset,ToolSetPath)
	func.inTable (tt1,'setToolSetParameter '..key..'-'..pos..'-'..param..'-'..value)
end

function login()
-- логин и пароль для терминала
	quik_login = func.setting('quik_login')
	quik_passw = func.setting('quik_passw')
 
      if isConnected() == 0 then
        -- константа из windows.h
		local WM_COMMAND = 0x0111
		-- поиск главного окна
		hWnd = w32.FindWindow("InfoClass","")
		-- нажимаем кнопку Усьтановить соединение
		w32.PostMessage(hWnd,WM_COMMAND,100,0)
		-- нажимаем кнопку разорвать соединение
		--w32.PostMessage(hWnd,WM_COMMAND,101,0)
		
		local hLoginWnd = FindLoginWindow()
		--func.inTable (tt1,'FindLoginWindow='..tostring(hLoginWnd))
        if hLoginWnd ~= 0 then
 
            local n1 = w32.FindWindowEx(hLoginWnd, 0, "", "")
            local n2 = w32.FindWindowEx(hLoginWnd, n1, "", "")
            local n3 = w32.FindWindowEx(hLoginWnd, n2, "", "")
            local n4 = w32.FindWindowEx(hLoginWnd, n3, "", "")
            local n5 = w32.FindWindowEx(hLoginWnd, n4, "", "")
 
            w32.SetWindowText(n2, quik_login)
            w32.SetWindowText(n3, quik_passw)
            w32.SetFocus(n5)
            w32.PostMessage(n5, w32.BM_CLICK, 0, 0)
         end 
      end
end

function ClearTrades()
	trades[2024]=nil
   	trades[2025][1]={}
   	trades[2025][2]={}	
   	trades[2025][3]={}
   	trades[2025][4]={}
   	trades[2025][5]={}

	func.savetable_new(trades,TradesPath)
	trades=func.loadtable(TradesPath)
end

function event_callback_message(t_id, msg, par1, par2)
	if msg == QTABLE_LBUTTONUP and par2 == 25 then
		func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' установка lastprice по дневному параболику')
		toolObj=rowmassiveParsing (par1)
		strTotal=''
		if toolObj.numb==1 then strTotal='total'
		elseif toolObj.numb==2 then strTotal='total2' end
		op=''
		if tool[toolObj.key]~=nil and tool[toolObj.key].strategy202106.pos.three[strTotal].vol>0 then op='buy' 
		elseif tool[toolObj.key]~=nil and tool[toolObj.key].strategy202106.pos.three[strTotal].vol<0 then  op='sell' end 
		if strTotal~='' and op~='' then 
			lastprice=tool[toolObj.key]['seccode'..toolObj.numb].par 
		end
		if lastprice~=nil and lastprice~=0 then setLastPrice (toolObj.key,toolObj.seccode,toolObj.numb,'three',op,lastprice) end	
	end
	if msg == QTABLE_LBUTTONUP and par2 == 26 then
		func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' установка lastprice по параболику M30')
		toolObj=rowmassiveParsing (par1)
		strTotal=''
		if toolObj.numb==1 then strTotal='total'
		elseif toolObj.numb==2 then strTotal='total2' end
		op=''
		if tool[toolObj.key]~=nil and tool[toolObj.key].strategy202106.pos.three[strTotal].vol>0 then op='buy' 
		elseif tool[toolObj.key]~=nil and tool[toolObj.key].strategy202106.pos.three[strTotal].vol<0 then  op='sell' end 
		if strTotal~='' and op~='' then 
			lastprice=tool[toolObj.key]['seccode'..toolObj.numb].parM30 
		end
		if lastprice~=nil and lastprice~=0 then setLastPrice (toolObj.key,toolObj.seccode,toolObj.numb,'three',op,lastprice) end	
	end
	if msg == QTABLE_LBUTTONUP and par2 == 9 then 
		func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' закрыть покупку')
		toolObj=rowmassiveParsing (par1-1)
		setToolSetParameter (toolObj.key,1,'one','vol',0)	
	end	
	if msg == QTABLE_LBUTTONUP and par2 == 12 then 
		func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' закрыть покупку')
		toolObj=rowmassiveParsing (par1-1)
		setToolSetParameter (toolObj.key,2,'two','vol',0)	
	end
	if msg == QTABLE_LBUTTONUP and par2 == 8 then 
		if rowmassiveParsing (par1).key==nil and rowmassiveParsing (par1-1).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' открыть покупку')
			toolObj=rowmassiveParsing (par1-1)
			setToolSetParameter (toolObj.key,1,'one','vol',1)	
		elseif rowmassiveParsing (par1-2).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' уменьшения maxvol')
			toolObj=rowmassiveParsing (par1-2)
			setToolSetParameter (toolObj.key,1,'one','maxvol',tool[toolObj.key].strategy202106.pos.one.maxvol-tool[toolObj.key].strategy202106.pos.one.stepvol)	
		elseif rowmassiveParsing (par1).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' Таблица Orders по выбранному инструменту')
			toolObj=rowmassiveParsing (par1)
			OrdersReport(toolObj.key,toolObj.seccode)
		end
	end	
	if msg == QTABLE_RBUTTONUP and par2 == 8 then 
		if rowmassiveParsing (par1).key==nil and rowmassiveParsing (par1-1).key==nil and rowmassiveParsing (par1-2).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' увеличения maxvol')
			toolObj=rowmassiveParsing (par1-2)
			setToolSetParameter (toolObj.key,1,'one','maxvol',tool[toolObj.key].strategy202106.pos.one.maxvol+tool[toolObj.key].strategy202106.pos.one.stepvol)	
		end
	end	
	if msg == QTABLE_LBUTTONUP and par2 == 11 then 
		if rowmassiveParsing (par1).key==nil and rowmassiveParsing (par1-1).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' открыть покупку')
			toolObj=rowmassiveParsing (par1-1)
			setToolSetParameter (toolObj.key,2,'two','vol',1)	
		elseif rowmassiveParsing (par1-2).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' уменьшения maxvol')
			toolObj=rowmassiveParsing (par1-2)
			setToolSetParameter (toolObj.key,2,'two','maxvol',tool[toolObj.key].strategy202106.pos.two.maxvol-tool[toolObj.key].strategy202106.pos.two.stepvol)	
		end
	end	
	if msg == QTABLE_RBUTTONUP and par2 == 11 then 
		if rowmassiveParsing (par1).key==nil and rowmassiveParsing (par1-1).key==nil and rowmassiveParsing (par1-2).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' увеличения maxvol')
			toolObj=rowmassiveParsing (par1-2)
			setToolSetParameter (toolObj.key,2,'two','maxvol',tool[toolObj.key].strategy202106.pos.two.maxvol+tool[toolObj.key].strategy202106.pos.two.stepvol)	
		end
	end	
	if msg == QTABLE_LBUTTONUP and par2 == 10 then 
		if rowmassiveParsing (par1).key==nil and rowmassiveParsing (par1-1).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' закрыть позицию')
			toolObj=rowmassiveParsing (par1-1)
			setToolSetParameter (toolObj.key,1,'one','vol',-100)	
		elseif rowmassiveParsing (par1-2).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' уменьшения minProffit')
			toolObj=rowmassiveParsing (par1-2)
			setToolSetParameter (toolObj.key,1,'one','minProffit',tool[toolObj.key].strategy202106.pos.one.minProffit-5000)	
		end
	end	
	if msg == QTABLE_RBUTTONUP and par2 == 10 then 
		if rowmassiveParsing (par1).key==nil and rowmassiveParsing (par1-1).key==nil and rowmassiveParsing (par1-2).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' увеличения minProffit')
			toolObj=rowmassiveParsing (par1-2)
			setToolSetParameter (toolObj.key,1,'one','minProffit',tool[toolObj.key].strategy202106.pos.one.minProffit+5000)	
		end
	end		
	if msg == QTABLE_LBUTTONUP and par2 == 13 then 
		if rowmassiveParsing (par1).key==nil and rowmassiveParsing (par1-1).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' закрыть позицию')
			toolObj=rowmassiveParsing (par1-1)
			setToolSetParameter (toolObj.key,2,'two','vol',-100)	
		elseif rowmassiveParsing (par1-2).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' уменьшения minProffit')
			toolObj=rowmassiveParsing (par1-2)
			setToolSetParameter (toolObj.key,2,'two','minProffit',tool[toolObj.key].strategy202106.pos.two.minProffit-5000)	
		end
	end
	if msg == QTABLE_RBUTTONUP and par2 == 13 then 
		if rowmassiveParsing (par1).key==nil and rowmassiveParsing (par1-1).key==nil and rowmassiveParsing (par1-2).key~=nil then 
			func.inTable (tt1,'event_callback_message Нажата кнопка '..par1..'-'..par2..' увеличения minProffit')
			toolObj=rowmassiveParsing (par1-2)
			setToolSetParameter (toolObj.key,2,'two','minProffit',tool[toolObj.key].strategy202106.pos.two.minProffit+5000)	
		end
	end
	if msg == QTABLE_LBUTTONUP and par1 == 1 and par2 == 3 then
		func.inTable (tt1,'event_callback_message Нажата кнопка Orders ')
		toolObj=rowmassiveParsing (par1)
		OrdersReport()
	end
	if msg == QTABLE_LBUTTONUP and par1 == 1 and par2 == 4 then
		func.inTable (tt1,'event_callback_message Нажата кнопка ScalpProfit ')
		toolObj=rowmassiveParsing (par1)
		TrendsCalculate()
	end
	if msg == QTABLE_LBUTTONUP and par1 == 1 and par2 == 5 then
		toolObj=rowmassiveParsing (par1)
		isTrendsProfitTake=true
		func.inTable (tt1,'isTrendsProfitTake='..tostring(isTrendsProfitTake))
	end
	
	if msg == QTABLE_LBUTTONUP and par1 == 1 and par2 == 21 then
		func.inTable (tt1,'event_callback_message Нажата кнопка Отладка '..os.time())
		toolObj=rowmassiveParsing (par1)
		--robot.inform("тест")
		ClearOrders()
	end
	if msg == QTABLE_LBUTTONUP and par1 == 1 and par2 == 22 then
		func.inTable (tt1,'event_callback_message Нажата кнопка ClearOrderTable() '..os.time())
		toolObj=rowmassiveParsing (par1)
		ClearOrderTable()
		
	end
	if msg == QTABLE_LBUTTONUP and par1 == 1 and par2 == 23 then
		func.inTable (tt1,'event_callback_message Нажата кнопка TrendsCheck() '..os.time())
		toolObj=rowmassiveParsing (par1)
		TrendsCheck()
	end	

end

function DateTimeStr(datetime)

	return tostring(datetime.day)..'.'..tostring(datetime.month)..'.'..tostring(datetime.year)..' '..tostring(datetime.hour)..'-'..tostring(datetime.min)

end

function DateStr(datetime)

	return tostring(datetime.day)..'.'..tostring(datetime.month)..'.'..tostring(datetime.year)

end

function GetCandles()

	barnum=getNumCandles("price")
	candles, BarNprice, toolprice = getCandlesByIndex ("price", 0, 0, barnum);
	
	func.inTable (tt1, 'GetCandles '..barnum)
	func.inTable (tt1, 'GetCandles '..barnum..' '..DateTimeStr(candles[1].datetime)..' ' .. tostring(func.Tbl2Str(candles)))
	--barnum-2244--func.round(barnum*0.8)--barnum-40 --func.round(barnum*0.6)--1 день это 34 свечи m30. Месяц - это ~748 свечей
end


function main()

	bot_token = 'bot_token'
	chat_id = 'telegram_ID'

	func.logtable()
	ToolPath = getScriptPath()..'//tool_clone.txt'
	ToolPath2 = getScriptPath()..'//tool_clone.txt'	
	tool=func.loadtable(ToolPath)
	--TradesPath = getScriptPath()..'//trades_clone.txt'
	--TradesPath2 = getScriptPath()..'//trades_clone.txt'
	--trades=func.loadtable(TradesPath)
	trades={}
	--RecPath = getScriptPath()..'//'..'rec' .. '.txt'
	--rec = func.loadtable(RecPath)
	OrderTablePath=getScriptPath()..'//OrderTable_test.txt'
	OrderTablePath2=getScriptPath()..'//OrderTable_test.txt'
	--OrderTable = func.loadtable(OrderTablePath)	
	--OrderTablePathArh=getScriptPath()..'//OrderTable.txt'
	--OrderTablePathArh2=getScriptPath()..'//OrderTable_clone.txt'
	OrdersPath = getScriptPath().. '//orders_test.txt'
	OrdersPath2 = getScriptPath()..'//orders_test.txt'
	TrendsPath = getScriptPath()..'//trends_test.txt'
	TrendsPath2 = getScriptPath()..'//trends_test2.txt'
	Trends = func.loadtable(TrendsPath)	
	TrendsPath = getScriptPath()..'//trends_test2.txt'
	func.savetable(Trends,TrendsPath)
	--Orders = func.loadtable(OrdersPath)	

	Orders ={}
	OrderTable={}
	
	func.savetable(Orders,OrdersPath)
	func.savetable(OrderTable,OrderTablePath)
			
	local lastTriggerTime = nil  -- Время последнего срабатывания
	local currentHalfHour = nil  -- Текущий получас (0 или 1)
	
	if rec==nil then rec={} end
	
	--OptOrderTablePath = getScriptPath()..'//OptOrderTable.txt'
	--OptOrderTable=func.loadtable(OptOrderTablePath)
	--OptProfileTablePath = getScriptPath()..'//OptProfileTable.txt'
	--OptProfileTable=func.loadtable(OptProfileTablePath)
	
	StateTable={} --Таблица для кэша данных
	StateTableD={}
	SecCollation={}
	tradesDate=nil
	PRICE=0
	ProfitPrice=0
	rowmassive={}
	TotalRiskMemory=0
	DayProfit=0
	TOTAL=0
	CHECK=false
	TestName=''
	DMinPrice=100000000
	DMaxPrice=0
	progessbar=0
	createtable()
	isTrendsProfitTake=false
	Key=''
	SetTableNotificationCallback(t_id, event_callback_message);

	local monitor=os.time()
	--local flagFile = io.open(getScriptPath()..'\\stockrobot_active.flag', "w")
 	--flagFile:write(monitor)
	--flagFile:close()
	candles={}
	barnum=0
	GetCandles()
	CandleNum=1--barnum-4000
    
	func.inTable (tt1, 'Пропускаем свечу c '..DateTimeStr(candles[CandleNum].datetime))
	while candles[CandleNum].datetime.month~=12 or candles[CandleNum].datetime.year~=2025  do
			CandleNum=CandleNum+1
			--func.inTable (tt1, 'Пропускаем свечу '..DateTimeStr(candles[CandleNum].datetime))
	end
	
	func.inTable (tt1, 'ver.20-11-2025 '.. tostring(os.date('%H:%M:%S')))
	while stopped==false and CandleNum < barnum-2 do

		--if os.time()-monitor>40 then 
		--	--func.inTable (tt1, 'monitor '..monitor)
		--	monitor=os.time()
		--	flagFile = io.open(getScriptPath()..'\\stockrobot_active.flag', "w")
 		--	flagFile:write(monitor)
		--	flagFile:close()
		--end
		
		ProfitOne=0
		ProfitTwo=0
		ProfitThree=0
		
		totalarisk=0
		TotalIncome=0
		TotalGo=0
		TotalGoTwo=0
		TotalGoStocks=0
		TotalGoStocksTwo=0
		TotalGoGold=0
		TotalGoGoldTwo=0
		TotalGoCurrency=0
		TotalGoCurrencyTwo=0
		
		for key,value in pairs(tool) do			
			--условие работы со стратегией в файле tools по инструменту strategy202106=true
			if 1==2 and value.strategy202106~=nil and value.strategy202106.enable and connect() then
				seccode1=value.seccode1.seccode
				seccode2=value.seccode2.seccode
				seccode=seccode1
				Key=key

				--открываем файл params по инструменту
				FPath = getScriptPath()..'//'..key .. '.params'
				memory=func.loadtable(FPath)

				seccode=seccode1
				if memory==nil then 
					robot.memoryinit ('one'..value.seccode1.preffix,'d')
					robot.memoryinit ('two'..value.seccode1.preffix,'d')
					robot.memoryinit ('three'..value.seccode1.preffix,'d')
					seccode=seccode2
					robot.memoryinit ('one'..value.seccode2.preffix,'d')
					robot.memoryinit ('two'..value.seccode2.preffix,'d')
					robot.memoryinit ('three'..value.seccode2.preffix,'d')
				end
								
				--считываем текущее состояние индикаторов и графиков
				StateTableD=robot.StateCapture (seccode1,'d',value.seccode1.preffix,'close')
				StateTableM30=robot.StateCapture (seccode1,'m30',value.seccode1.preffix,'close') 
				StateTableD2=robot.StateCapture (seccode2,'d',value.seccode2.preffix,'close')
				StateTableM302=robot.StateCapture (seccode2,'m30',value.seccode2.preffix,'close') 
				if func.TimePassed(23,46,59) or value.seccode1.MaxPrice==nil or value.seccode2.MaxPrice==nil or value.seccode1.MinPrice==0 or value.seccode2.MinPrice==0 then 
					value.seccode1.MaxPrice=0
					value.seccode2.MaxPrice=0
					value.seccode1.MinPrice=1000000
					value.seccode2.MinPrice=1000000
				end

				CandleNum=CandleNum+1
				func.inTable (tt1,tostring(candles[CandleNum].open)..' '..DateTimeStr(candles[CandleNum].datetime))
				
				candlePrice=candles[CandleNum].open
				value.seccode1.PRICE=func.getprice (seccode1)*value.seccode1.multiplier
				value.seccode1.PRICE_BID=candlePrice*value.seccode1.multiplier
				value.seccode1.PRICE_OFFER=candlePrice*value.seccode1.multiplier
				value.seccode1.StateTableM30_ma200=StateTableM30.ma200.ma
				value.seccode1.StateTableM30_ma20=StateTableM30.ma20.ma
				value.seccode1.StateTableD_ma200=StateTableD.ma200.ma
				value.seccode1.StateTableD_ma20=StateTableD.ma20.ma
				value.seccode1.StateTableM30_par=StateTableM30.par.par
				value.seccode1.StateTableD_par=StateTableD.par.par
				value.seccode1.StateTableM30_parType=StateTableM30.par.stop
				value.seccode1.StateTableD_parType=StateTableD.par.stop
				if value.seccode1.MaxPrice~=nil and value.seccode1.MaxPrice<value.seccode1.PRICE then value.seccode1.MaxPrice=value.seccode1.PRICE end
				if value.seccode1.MinPrice~=nil and value.seccode1.MinPrice>value.seccode1.PRICE then value.seccode1.MinPrice=value.seccode1.PRICE end
				
				PRICE2_old=func.getprice (seccode2)
				value.seccode2.PRICE=func.get_SETTLEPRICE (seccode2)*value.seccode2.multiplier		
				value.seccode2.PRICE_BID=func.get_BID (seccode2)*value.seccode2.multiplier
				value.seccode2.PRICE_OFFER=func.get_OFFER (seccode2)*value.seccode2.multiplier
				value.seccode2.StateTableM30_ma200=StateTableM302.ma200.ma
				value.seccode2.StateTableM30_ma20=StateTableM302.ma20.ma
				value.seccode2.StateTableD_ma200=StateTableD2.ma200.ma
				value.seccode2.StateTableD_ma20=StateTableD2.ma20.ma
				value.seccode2.StateTableM30_par=StateTableM302.par.par
				value.seccode2.StateTableD_par=StateTableD2.par.par
				value.seccode2.StateTableM30_parType=StateTableM302.par.stop
				value.seccode2.StateTableD_parType=StateTableD2.par.stop
				if value.seccode2.MaxPrice~=nil and value.seccode2.MaxPrice<value.seccode2.PRICE then value.seccode2.MaxPrice=value.seccode2.PRICE end
				if value.seccode2.MinPrice~=nil and value.seccode2.MinPrice>value.seccode2.PRICE then value.seccode2.MinPrice=value.seccode2.PRICE end

				value.Delta=value.seccode2.PRICE-value.seccode1.PRICE
				Delta_old=PRICE2_old-value.seccode1.PRICE
				value.DeltaM30_200=StateTableM302.ma200.ma*value.seccode2.multiplier-StateTableM30.ma200.ma*value.seccode1.multiplier
				value.DeltaD_200=StateTableD2.ma200.ma*value.seccode2.multiplier-StateTableD.ma200.ma*value.seccode1.multiplier
				value.DeltaM30_20=StateTableM302.ma20.ma*value.seccode2.multiplier-StateTableM30.ma20.ma*value.seccode1.multiplier
				value.DeltaD_20=StateTableD2.ma20.ma*value.seccode2.multiplier-StateTableD.ma20.ma*value.seccode1.multiplier

				--func.inTable (tt1,key..' '..seccode1..' '..value.seccode1.PRICE..' min=' ..value.seccode1.MinPrice..' max=' ..value.seccode1.MaxPrice..' atr=' ..StateTableD.par.atr*0.9*value.seccode1.multiplier) 

				--if value.seccode1.PRICE<value.seccode1.MaxPrice-StateTableD.par.atr*0.9*value.seccode1.multiplier then 
				--	func.inTable (tt1,key..' '..seccode1..' минимальная цена за день') 
				--elseif value.seccode1.PRICE>value.seccode1.MinPrice+StateTableD.par.atr*0.9*value.seccode1.multiplier then 
				--	func.inTable (tt1,key..' '..seccode1..' максимальная цена за день') end
				--if value.seccode2.PRICE<value.seccode2.MaxPrice-StateTableD2.par.atr*0.9*value.seccode2.multiplier then 
				--	func.inTable (tt1,key..' '..seccode2..' минимальная цена за день') 
				--elseif value.seccode2.PRICE>value.seccode2.MinPrice+StateTableD2.par.atr*0.9*value.seccode2.multiplier then 
				--	func.inTable (tt1,key..' '..seccode2..' максимальная цена за день') end

				--Данные по базовому активу
				--CLASS_CODE=value.seccode3.CLASS_CODE 
				--seccode3=value.seccode3.seccode --'USD000UTSTOM'
				--	      
				--value.seccode3.PRICE=func.roundS(func.getprice (seccode3)*value.seccode3.multiplier,2)
				--value.seccode3.PRICE_BID=func.roundS(func.get_BID (seccode3)*value.seccode3.multiplier,2)
				--value.seccode3.PRICE_OFFER=func.roundS(func.get_OFFER (seccode3)*value.seccode3.multiplier,2)
				--
				--StateTableD3=robot.StateCapture (seccode3,'d',value.seccode3.preffix,'close')
				--StateTableM303=robot.StateCapture (seccode3,'m30',value.seccode3.preffix,'close') 
				--
				--value.seccode3.StateTableM30_ma200=StateTableM303.ma200.ma
				--value.seccode3.StateTableM30_ma20=StateTableM303.ma20.ma
				--value.seccode3.StateTableD_ma200=StateTableD3.ma200.ma
				--value.seccode3.StateTableD_ma20=StateTableD3.ma20.ma
				--
				--value.Delta3=value.seccode1.PRICE*value.seccode1.multiplier-(value.seccode3.PRICE*value.seccode3.multiplier)
				--value.Delta_seccode3_M30_200=StateTableM30.ma200.ma*value.seccode1.multiplier-(StateTableM303.ma200.ma*value.seccode3.multiplier)
				--value.Delta_seccode3_D_200=StateTableD.ma200.ma*value.seccode1.multiplier-(StateTableD3.ma200.ma*value.seccode3.multiplier)
				--value.Delta_seccode3_M30_20=StateTableM30.ma20.ma*value.seccode1.multiplier-(StateTableM303.ma20.ma*value.seccode3.multiplier)
				--value.Delta_seccode3_D_20=StateTableD.ma20.ma*value.seccode1.multiplier-(StateTableD3.ma20.ma*value.seccode3.multiplier)

				CLASS_CODE='SPBFUT'  	
				
				InitSeccode(key)
				--CalcTrades()
				--CalcVM()
				Options=value.strategy202106
				
				Options.short=nil
				Options.notSwapRate=nil
				Options.OnlyLong=nil 			
				Options.OnlyShort=nil			
				
				Options.pos.one.n=''
				Options.pos.two.n=''
				
				--if key=='SiH4-2' and 	value.seccode2.seccode=='CRH4' then	
				------if key=='SiH4' then	
				----	func.inTable (tt1, key..' robot.closetrade ')
				--	robot.closetrade ('twoSi1','SiH4') 
				--end
				
				local trend=''
				if value.DeltaM30_20 > value.DeltaM30_200 then 
					trend='long'
				elseif value.DeltaM30_20 < value.DeltaM30_200 then 
					trend='short'
				end
				
				if Options.pos.one.OldVol==nil then	Options.pos.one.OldVol=0 end
				if Options.pos.two.OldVol==nil then	Options.pos.two.OldVol=0 end
				if Options.pos.three.OldVol==nil then Options.pos.three.OldVol=0 end
				
				local sumTotalVol=Options.pos.one.total.vol+Options.pos.two.total.vol+Options.pos.three.total.vol
				local sumVol=Options.pos.one.vol+Options.pos.two.vol+Options.pos.three.vol
				local sumOldVol=Options.pos.one.OldVol+Options.pos.two.OldVol+Options.pos.three.OldVol
								
				CalcSignals(value,trend)
				
				--========================================
				--Подсчитываем текущий результата по позициям
				--func.inTable (tt1,key..' '..func.Tbl2Str(value.seccode1)) 

				PRICE=value.seccode1.PRICE
				robot.CalcPos(value)
				PRICE=value.seccode2.PRICE
				robot.CalcPos2(value)
				SeccodeCollation()
				FundingCalc(key,'two')
				--========================================				
				--проверяем условия для точки входа
				CheckEnterSignal_Arb(value)
		
				--========================================
				--Проверяем условия для точки выхода
			
				CheckExitSignal_Arb(value)

				--========================================
				--заполняем таблицу
				--func.inTable (tt1,' setcell '..value.seccode1.seccode) 
				setcell(key..value.seccode1.seccode,value.seccode1,value)
				setcell(key..value.seccode2.seccode,value.seccode2,value)
				setcell(key..value.seccode3.seccode,value.seccode3,value)
				--setcell(value.seccode4)
				
				func.gray (t_id,rowmassive[key..'Delta1'].row)
				func.gray (t_id,rowmassive[key..'Delta2'].row)
				--func.gray (t_id,rowmassive[key..'Delta3'].row)
				SetCell(t_id, rowmassive[key..'Delta1'].row, 0, key)--'Дох:'..tostring(func.roundS(YieldCalc(value),2))..'%год')
				if tradesDate~=nil and tradesDate[key]~=nil then 
					--func.inTable (tt1,key..' '..tradesDate.flag) 
					SetCell(t_id, rowmassive[key..'Delta1'].row, 1, tostring(func.roundS(tradesDate[key][value.seccode2.seccode].CLPRICE*value.seccode2.multiplier-tradesDate[key][value.seccode1.seccode].CLPRICE*value.seccode1.multiplier)))		
				end
				SetCell(t_id, rowmassive[key..'Delta1'].row, 2, tostring(func.roundS(value.seccode2.PRICE_BID-value.seccode1.PRICE_OFFER,2)))
				func.yellow (t_id,rowmassive[key..'Delta1'].row,2)
				SetCell(t_id, rowmassive[key..'Delta1'].row, 3, tostring(func.roundS(value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID,2)))
				func.yellow (t_id,rowmassive[key..'Delta1'].row,3)
				SetCell(t_id, rowmassive[key..'Delta1'].row, 4, tostring(func.roundS(value.DeltaM30_20,1)))
				SetCell(t_id, rowmassive[key..'Delta1'].row, 5, tostring(func.roundS(value.DeltaM30_200,1)))
				SetCell(t_id, rowmassive[key..'Delta1'].row, 6, tostring(func.roundS(value.DeltaD_20,1)))
				SetCell(t_id, rowmassive[key..'Delta1'].row, 7, tostring(func.roundS(value.DeltaD_200,1)))
				SetCell(t_id, rowmassive[key..'Delta1'].row, 8, tostring(func.roundS(Options.pos.one.entersignal,1)))
				func.green (t_id,rowmassive[key..'Delta1'].row,8)
				SetCell(t_id, rowmassive[key..value.seccode3.seccode].row, 8, tostring(Options.pos.one.maxvol)..'-'..tostring(Options.pos.one.n))
				
				SetCell(t_id, rowmassive[key..'Delta1'].row, 9, tostring(func.roundS(Options.pos.one.exitsignal,1)))
				func.red (t_id,rowmassive[key..'Delta1'].row,9)
				SetCell(t_id, rowmassive[key..value.seccode3.seccode].row, 9, tostring(Options.pos.one.stepvol))
				SetCell(t_id, rowmassive[key..'Delta1'].row, 10, tostring(func.roundS(Options.pos.one.total.proffit+Options.pos.one.total2.proffit)))
				if Options.pos.one.total.proffit+Options.pos.one.total2.proffit>0 then func.green (t_id,rowmassive[key..'Delta1'].row,10)
				elseif Options.pos.three.total.proffit+Options.pos.three.total2.proffit<0 then func.red (t_id,rowmassive[key..'Delta1'].row,10)
				else func.white (t_id,rowmassive[key..'Delta1'].row,10)
				end
				SetCell(t_id, rowmassive[key..value.seccode3.seccode].row, 10,tostring(func.roundS(Options.pos.one.minProffit,0)))
				SetCell(t_id, rowmassive[key..'Delta1'].row, 11, tostring(func.roundS(Options.pos.two.entersignal,1)))
				func.green (t_id,rowmassive[key..'Delta1'].row,11)
				SetCell(t_id, rowmassive[key..value.seccode3.seccode].row, 11, tostring(Options.pos.two.maxvol)..'-'..tostring(Options.pos.two.n))
				SetCell(t_id, rowmassive[key..'Delta1'].row, 12, tostring(func.roundS(Options.pos.two.exitsignal,1)))
				func.red (t_id,rowmassive[key..'Delta1'].row,12)
				SetCell(t_id, rowmassive[key..value.seccode3.seccode].row, 12, tostring(Options.pos.two.stepvol))				
				SetCell(t_id, rowmassive[key..'Delta1'].row, 13,  tostring(func.roundS(Options.pos.two.total.proffit+Options.pos.two.total2.proffit)))
				SetCell(t_id, rowmassive[key..value.seccode3.seccode].row, 13,tostring(func.roundS(Options.pos.two.minProffit,0)))
				SetCell(t_id, rowmassive[key..'Delta1'].row, 14, tostring(Options.pos.two.funding.EnterDate))
				
				if Options.pos.two.total.vol~=0 and (Options.notCalc==nil or Options.notCalc==false) then 
					local lost2=(Options.pos.two.total.enterprice*value.seccode1.multiplier-Options.pos.two.total2.enterprice*value.seccode2.multiplier)*Options.pos.two.total2.vol
					if value.seccode1.seccode=='IMOEXF' then lost2=lost2*10 end
					SetCell(t_id, rowmassive[key..'Delta1'].row, 15, dell0(tostring(func.roundS((lost2+Options.pos.two.funding.total+Options.pos.two.funding2.total)/1000)))..'т.всего')
					TotalIncome=TotalIncome+lost2+Options.pos.two.funding.total+Options.pos.two.funding2.total
					local multiplier2=tonumber(getParamEx(CLASS_CODE, value.seccode1.seccode,'LOTSIZE').param_value)
					SetCell(t_id, rowmassive[key..'Delta1'].row, 16, dell0(tostring(func.roundS((Options.pos.two.funding.avg*multiplier2*math.abs(Options.pos.two.total.vol))/1000)))..'т.день')
				
				end
			
				SetCell(t_id, rowmassive[key..'Delta1'].row, 20, tostring(func.roundS(Options.pos.three.total.proffit+Options.pos.three.total2.proffit)))
				if Options.pos.three.total.proffit+Options.pos.three.total2.proffit>0 then func.green (t_id,rowmassive[key..'Delta1'].row,20)
				elseif Options.pos.three.total.proffit+Options.pos.three.total2.proffit<0 then func.red (t_id,rowmassive[key..'Delta1'].row,20)
				else func.white (t_id,rowmassive[key..'Delta1'].row,20)
				end
				SetCell(t_id, rowmassive[key..value.seccode3.seccode].row, 20,tostring(func.roundS(Options.pos.three.minProffit,0)))				
				SetCell(t_id, rowmassive[key..'Delta1'].row, 21, tostring(Options.pos.three.maxvol)..'*'..tostring(Options.pos.three.stepvol)..'*'..tostring(Options.pos.three.step))
				
				SetCell(t_id, rowmassive[key..'Delta2'].row, 2, tostring(value.seccode1.PRICE_BID-value.seccode3.PRICE_OFFER))
				SetCell(t_id, rowmassive[key..'Delta2'].row, 3, tostring(value.seccode1.PRICE_OFFER-value.seccode3.PRICE_BID))
				SetCell(t_id, rowmassive[key..'Delta2'].row, 4, tostring(func.roundS(value.Delta_seccode3_M30_20,1)))
				SetCell(t_id, rowmassive[key..'Delta2'].row, 5, tostring(func.roundS(value.Delta_seccode3_M30_200,1)))
				SetCell(t_id, rowmassive[key..'Delta2'].row, 6, tostring(func.roundS(value.Delta_seccode3_D_20,1)))
				SetCell(t_id, rowmassive[key..'Delta2'].row, 7, tostring(func.roundS(value.Delta_seccode3_D_200,1)))
								
				--SetCell(t_id, rowmassive[key..'Delta3'].row, 2, tostring(value.seccode1.PRICE_BID-value.seccode4.PRICE_OFFER))
				--SetCell(t_id, rowmassive[key..'Delta3'].row, 3, tostring(value.seccode1.PRICE_OFFER-value.seccode4.PRICE_BID))
				--SetCell(t_id, rowmassive[key..'Delta3'].row, 4, tostring(func.roundS(value.Delta_seccode4_M30_20,1)))
				--SetCell(t_id, rowmassive[key..'Delta3'].row, 5, tostring(func.roundS(value.Delta_seccode4_M30_200,1)))
				--SetCell(t_id, rowmassive[key..'Delta3'].row, 6, tostring(func.roundS(value.Delta_seccode4_D_20,1)))
				--SetCell(t_id, rowmassive[key..'Delta3'].row, 7, tostring(func.roundS(value.Delta_seccode4_D_200,1)))

				--========================================
				--выполняем операции
				--Operation(value)
				local operflag
				--if value.seccode1.PRICE~=0 and value.seccode2.PRICE~=0 then operflag=OperationEngine_Arb(value) end
				--========================================
				if operflag then 
					func.green (t_id,rowmassive[key..'Delta1'].row)
				else func.gray (t_id,rowmassive[key..'Delta1'].row)
				end
				
				--ThreePosEngine(value,key)
				--if Options.pos.three.total.vol~=0 then robot.checkstoporder ('three'..value.seccode1.preffix,value.seccode1.seccode) end
				--if Options.pos.three.total2.vol~=0 then robot.checkstoporder ('three'..value.seccode2.preffix,value.seccode2.seccode) end

				--func.savetable(tool,ToolPath)
				--func.savetable(memory,FPath)
				totalarisk=totalarisk+Options.risk
			--end;
		--TotalRiskMemory=totalarisk
		--MoneyManagment()
				if isConnected() == 1  then func.green(t_id, rowmassive['Итого'].row,2) else func.red(t_id, rowmassive['Итого'].row,2) end
			end
		end
		
		--ClearStateTable()
		--Алтернативный код для очистки таблицы
		local timer={0,1,2,3,4,30,31,32,33,34}
		local curMinute=os.date("*t").min
		
		--if func.isInArray(timer, curMinute) and not isClearStateTable and os.date("*t").sec<30  then 
		--	func.ToLog  ('StockRobot clear StateTable')-- .. func.Tbl2Str(StateTable) )
		--	func.inTable (tt1, 'StockRobot clear StateTable')
		--	StateTableD={} 
		--	StateTable={}
		--	isClearStateTable = true  -- Ставим флаг выполнения
		--elseif os.date("*t").sec>30 then
		--	isClearStateTable = false
		--end
		------------------------
		if progessbar==0 then progessbar=1
		elseif progessbar==1 then progessbar=0 end

			
		CandleNum=CandleNum+1

		--func.inTable (tt1,tostring(candles[CandleNum].open)..' '..DateTimeStr(candles[CandleNum].datetime))
		
		if _datetime~=DateStr(candles[CandleNum].datetime) then
			_datetime=DateStr(candles[CandleNum].datetime)
			func.inTable (tt1,tostring(_datetime))
		end
		
		
		candlePrice=candles[CandleNum].open
		
		if candlePrice==0 then 
			func.inTable (tt1, 'candlePrice==0 '..DateTimeStr(candles[CandleNum].datetime))
			--func.inTable (tt1, Trends['IMOEXF-scalp'].orders..' stopsell='..Trends['IMOEXF-scalp'].StopSell..'  stopbuy='..Trends['IMOEXF-scalp'].StopBuy)
			--func.inTable (tt1, Trends['GLDRUBF-scalp'].orders..' stopsell='..Trends['GLDRUBF-scalp'].StopSell..'  stopbuy='..Trends['GLDRUBF-scalp'].StopBuy)
			--func.inTable (tt1, Trends['CNYRUBF-scalp'].orders..' stopsell='..Trends['CNYRUBF-scalp'].StopSell..'  stopbuy='..Trends['CNYRUBF-scalp'].StopBuy)
			--func.inTable (tt1, Trends['USDRUBF-scalp'].orders..' stopsell='..Trends['USDRUBF-scalp'].StopSell..'  stopbuy='..Trends['USDRUBF-scalp'].StopBuy)			
			
			TrendsCalculate()
			func.inTable (tt1, 'ver.20-11-2025 '.. tostring(os.date('%H:%M:%S')))
			return 
		end
		
		--tool['CNYRUBF-CRH6'].seccode1.PRICE_BID=candlePrice*tool['CNYRUBF-CRH6'].seccode1.multiplier
		--tool['CNYRUBF-CRH6'].seccode1.PRICE_OFFER=candlePrice*tool['CNYRUBF-CRH6'].seccode1.multiplier
		
		--tool['USDRUBF-SiH6'].seccode1.PRICE_BID=candlePrice*tool['USDRUBF-SiH6'].seccode1.multiplier
		--tool['USDRUBF-SiH6'].seccode1.PRICE_OFFER=candlePrice*tool['USDRUBF-SiH6'].seccode1.multiplier

		tool['GLDRUBF-GLH6'].seccode1.PRICE_BID=candlePrice*  tool['GLDRUBF-GLH6'].seccode1.multiplier
		tool['GLDRUBF-GLH6'].seccode1.PRICE_OFFER=candlePrice*tool['GLDRUBF-GLH6'].seccode1.multiplier

		--tool['IMOEXF-MMH6'].seccode1.PRICE_BID=candlePrice*  tool['IMOEXF-MMH6'].seccode1.multiplier
		--tool['IMOEXF-MMH6'].seccode1.PRICE_OFFER=candlePrice*tool['IMOEXF-MMH6'].seccode1.multiplier

		if connect() then 
			
			Orders = func.loadtable(OrdersPath)	
			Trends = func.loadtable(TrendsPath)	
			OrderTable=func.loadtable(OrderTablePath)
			
			trends()
			--CalcTrades()
			SmartTrade() --функция умной сделки
		end
		if connect2() then 
			--OrderTable=func.loadtable(OrderTablePath)
			CheckOrderTable() -- функция обработки таблицы с ордерами
		end
		
		if SaveTrends then 
			func.savetable(Trends,TrendsPath)
			SaveTrends=false
			--func.inTable (tt1, 'SaveTrends '..TrendsPath)
		end
		if SaveOrders then 
			func.savetable(Orders,OrdersPath)
			SaveOrders=false
			--func.inTable (tt1, 'SaveOrders '.. OrdersPath)
		end
		if SaveOrderTable then 
			func.savetable(OrderTable,OrderTablePath)
			SaveOrderTable=false
			--func.inTable (tt1, 'SaveOrderTable '..OrderTablePath)
		end

		--========================================
		--В таблице заполняем строку Итого
		
		portfolioinfo=getPortfolioInfo(func.setting('firm_id'), func.setting('account'))
		--func.inTable (tt1, 'StockRobot '..func.setting('account')..' '..func.setting('client_code')..tostring(func.Tbl2Str(portfolioinfo)))
		allrest=portfolioinfo.start_limit_open_pos
		if allrest==nil then allrest=0 end
		
		--SetCell(t_id, rowmassive['Итого'].row, 0, tostring(CalcToolTotal()))
		--SetCell(t_id, rowmassive['Итого'].row, 1, tostring(DayProfit))		
		--SetCell(t_id, rowmassive['Итого'].row, 2, tostring(os.date('%H:%M:%S')))
		--SetCell(t_id, rowmassive['Итого'].row, 3, 'Orders')
		--SetCell(t_id, rowmassive['Итого'].row, 4, 'SProfit')
		--SetCell(t_id, rowmassive['Итого'].row, 5, 'SPTake')		
		--SetCell(t_id, rowmassive['Итого'].row, 15, tostring(func.roundS(TotalGoTwo/1000))..' ГО two')
		--SetCell(t_id, rowmassive['Итого'].row, 16, tostring(func.roundS(TotalGo/1000))..' ГО')
		--SetCell(t_id, rowmassive['Итого'].row, 19, tostring(func.roundS(TotalIncome/1000))..' дох')
		--SetCell(t_id, rowmassive['Итого'].row, 17, tostring(func.roundS(allrest/1000))..' ост')
		--SetCell(t_id, rowmassive['Итого'].row, 21, 'Отладка')
		--SetCell(t_id, rowmassive['Итого'].row, 22, 'ClearOrderTable')	
		--SetCell(t_id, rowmassive['Итого'].row, 23, 'TrendsCheck')			
		--SetCell(t_id, rowmassive['stocks'].row, 17, tostring(func.roundS(allrest/1000/3)))
		--SetCell(t_id, rowmassive['gold'].row, 17, tostring(func.roundS(allrest/1000/3)))
		--SetCell(t_id, rowmassive['currency'].row, 17, tostring(func.roundS(allrest/1000/3)))
		--SetCell(t_id, rowmassive['stocks'].row, 16, tostring(func.roundS(TotalGoStocks/1000)))
		--SetCell(t_id, rowmassive['stocks'].row, 15, tostring(func.roundS(TotalGoStocksTwo/1000)))
		--SetCell(t_id, rowmassive['gold'].row, 16, tostring(func.roundS(TotalGoGold/1000)))
		--SetCell(t_id, rowmassive['gold'].row, 15, tostring(func.roundS(TotalGoGoldTwo/1000)))
		--SetCell(t_id, rowmassive['currency'].row, 16, tostring(func.roundS(TotalGoCurrency/1000)))
		--SetCell(t_id, rowmassive['currency'].row, 15, tostring(func.roundS(TotalGoCurrencyTwo/1000)))
		
		
		
		--transaction2('MMM5','S','MMH5',3257,15,'threeMX2')
		--func.red(t_id, rowmassive['Итого'].row)		
		--func.inTable (tt1, func.Tbl2Str(rowmassive))
		--func.savetable(tool,ToolPath)
		
		--sleep(1)
	end
	ToLog ("скрипт остановлен")
end
--04.02.2024 22-56

