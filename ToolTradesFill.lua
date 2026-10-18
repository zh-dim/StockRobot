require("func")
require("robot")

stopped = false

function OnStop(s)
	stopped = true
	return 5000
end

function fillToolTrades()
	
	--ToolTrades[2025]={}
	for month,montharr in pairs(trades[2025]) do	
		--func.inTable (tt1, key..' '..tostring(month))
		if ToolTrades[2025][month]==nil then ToolTrades[2025][month]={} end
		for day,dayarr in pairs(montharr) do	
			if ToolTrades[2025][month][day]==nil then ToolTrades[2025][month][day]={} end
			for key,keyarr in pairs(dayarr) do
				--func.inTable (tt1, key..' '..tostring(func.Tbl2Str(keyarr)))
				if key~='flag' then 
					for sec,secarr in pairs(keyarr) do
						if ToolTrades[2025][month][day][sec]==nil and secarr.CLPRICE~=0 then 
							ToolTrades[2025][month][day][sec]={} 
							ToolTrades[2025][month][day][sec].CLPRICE=secarr.CLPRICE
							ToolTrades[2025][month][day][sec].PREV_SWAP_RATE=secarr.PREV_SWAP_RATE
							ToolTrades[2025][month][day][sec].seccode=sec
							local datetime = { year  = 2025, month = month, day   = day   }
							ToolTrades[2025][month][day][sec].time=os.time(datetime)
							ToolTrades[2025][month][day][sec].data=os.date("%x",os.time(datetime))
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
	ToolTradesPath = getScriptPath()..'//ToolTrades.txt'
	trades=func.loadtable(TradesPath)

	ToolPath = getScriptPath()..'//tool.txt'
	tool=func.loadtable(ToolPath)
	
	--ToolTrades={}
	ToolTrades=func.loadtable(ToolTradesPath)

	fillToolTrades()

	
	func.savetable(ToolTrades,ToolTradesPath)
	ToLog ("скрипт остановлен")
	func.inTable (tt1, 'ver. 24-07-2025 17-20')

end