require("func")
require("robot")

seccode="SiH1" --  торгуемый инструмент
maxpisitions=4 -- максимальное количество позиций для учреднения
VOLUME=20 -- количество лотов для покупки 


stopped = false
FPath = getScriptPath()..'//'..seccode .. '.params'
SettingPath = getScriptPath()..'//'..seccode .. '.set'
TradePath = getScriptPath()..'//trade.txt'

memory={}
TRANS_ID=nil
STATE=""
ORDERNUM=nil
stopordernum=nil
ORDERCOMPLETED=true
VOLCOMPLETED=0


function OnStop(s)
	stopped = true
	return 5000
end


function main()
-- инициализируем и создаем структуру таблицы 
	tt1=AllocTable() 
	local size=10
	AddColumn(tt1,1,"SecCode",true, QTABLE_STRING_TYPE,size)
		AddColumn(tt1,2,"TimeFrame",true, QTABLE_STRING_TYPE,size)
			AddColumn(tt1,3,"VolBuy",true, QTABLE_STRING_TYPE,size)
				AddColumn(tt1,4,"PriceBuy",true, QTABLE_STRING_TYPE,size)
					AddColumn(tt1,5,"Result",true, QTABLE_STRING_TYPE,size)
						AddColumn(tt1,6,"VolSell",true, QTABLE_STRING_TYPE,size)
							AddColumn(tt1,7,"PriceSell",true, QTABLE_STRING_TYPE,size)
								AddColumn(tt1,8,"Proffit",true, QTABLE_STRING_TYPE,size)
									AddColumn(tt1,9,"Date",true, QTABLE_STRING_TYPE,25)

							
	CreateWindow(tt1)
	SetWindowCaption(tt1, "Завершенные сделки")
	SetWindowPos(tt1, 0, 0, 600, 600)
	
		
	trade=func.loadtable(TradePath)
	local n=1
	message ("кол-во строк " .. #trade)

	for i=1, #trade, 1 do 
		if trade[i]~= nil  then
			InsertRow(tt1,-1)
			for m=1 ,9,1 do
				SetCell(tt1,i,m,tostring(trade[i][m]))
				if m==8 and trade[i][m]>0 then 
					func.green (tt1,i,m)
				elseif  m==8 and trade[i][m]<0 then 
					func.red (tt1,i,m)
				end
			--	--message ("trade[#trade ][m-7] " .. trade[i][m-7])
			--	--message ("trade[#trade ][m] " .. trade[i][m] .. " - " .. tostring(func.correctsum (trade[i][m-7],trade[i][m])))
			--	trade[i][m]=func.round (func.correctsum (trade[i][m-7],trade[i][m]))
			--	SetCell(tt1,i,m,tostring(func.round (func.correctsum (trade[i][m-7],trade[i][m]))))
			--end 
			end
		end 
	end	
	--func.savetable(trade,TradePath)

	local n=#trade
	while stopped==false do
		trade=func.loadtable(TradePath)
		if n~=#trade then
			InsertRow(tt1,-1)
			for m=1 ,9,1 do
				SetCell(tt1,#trade,m,tostring(trade[#trade ][m]))
				if m==8 and trade[#trade][m]>0 then 
					func.green (tt1,#trade,m)
				elseif  m==8 and trade[#trade][m]<0 then 
					func.red (tt1,#trade,m)
				end
			end
		end
		n=#trade
		sleep (1000)
	end

	ToLog ("скрипт остановлен")

end
	
--[[ Бэклог

]]--

-- Changes will take effect once Notepad++ is restarted

