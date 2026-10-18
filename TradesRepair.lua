require("func")
require("robot")

stopped = false

function OnStop(s)
	stopped = true
	return 5000
end

function ToolTradesRepair()
	
	for month,montharr in pairs(trades[2025]) do	
		for day,dayarr in pairs(montharr) do
			func.inTable (tt1, month..' ' .. day)
			for sec1, ToolTradesSec in pairs(ToolTrades[2025][month][day]) do
				for key2,value in pairs(tool) do
					if value.strategy202106.enable and (value.seccode1.seccode==sec1 or value.seccode2.seccode==sec1) then
						if dayarr[key2]==nil then dayarr[key2]={} end 
						if dayarr[key2][sec1]==nil then dayarr[key2][sec1]={} end 
						if (dayarr[key2][sec1].CLPRICE==nil or dayarr[key2][sec1].CLPRICE~=ToolTradesSec.CLPRICE) and ToolTradesSec.CLPRICE~=nil then 
							dayarr[key2][sec1].CLPRICE=ToolTradesSec.CLPRICE
							if dayarr[key2][sec1].vol~=nil then  
								--func.inTable (tt1, month..' ' .. day..' ' ..key..' '..sec .. tostring(ToolTradesSec.CLPRICE))
								dayarr[key2][sec1].cost=func.correctsum(sec1,dayarr[key2][sec1].vol*dayarr[key2][sec1].CLPRICE)
							end
						end
						if dayarr[key2][sec1].PREV_SWAP_RATE==nil or dayarr[key2][sec1].PREV_SWAP_RATE~=ToolTradesSec.PREV_SWAP_RATE then 
							dayarr[key2][sec1].PREV_SWAP_RATE=ToolTradesSec.PREV_SWAP_RATE
							if dayarr[key2][sec1].vol~=nil then  
								dayarr[key2][sec1].funding=dayarr[key2][sec1].vol*dayarr[key2][sec1].PREV_SWAP_RATE*tonumber(getParamEx(CLASS_CODE, sec1,'LOTSIZE').param_value*-1)
							end
						end					
					end
				end				
			end
		end
	end
end
			

function main()
	
	func.logtable()
	TradesPath = getScriptPath()..'//trades.txt'
	TradesPath_new = getScriptPath()..'//trades2.txt'
	trades=func.loadtable(TradesPath)
		
	ToolTradesPath = getScriptPath()..'//ToolTrades.txt'
	ToolTrades=func.loadtable(ToolTradesPath)


	ToolPath = getScriptPath()..'//tool.txt'
	tool=func.loadtable(ToolPath)

	ToolTradesRepair()
	
	func.savetable(trades,TradesPath)
	ToLog ("скрипт остановлен")
	func.inTable (tt1, 'ver. 17-06-2024 10-41')

end