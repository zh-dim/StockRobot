require("func")
require("robot")

stopped = false

function OnStop(s)
	stopped = true
	return 5000
end

function main()
	year=2026
	
	func.logtable()
	TradesPath = getScriptPath()..'//trades.txt'
	TradesPath_new = getScriptPath()..'//trades2.txt'
	trades=func.loadtable(TradesPath)
	
	DataTbl={}
	DataTbl.year=year
	for i=1, 12, 1 do 
		if trades[year][i]==nil then trades[year][i]={} end
		DataTbl.month=i
		for m=1,31, 1 do
			DataTbl.day=m
			ddate=os.date("*t",os.time(DataTbl))
			if ddate.wday>1 and ddate.wday<7 and not (m==31 and (i==2 or i==4 or i==6 or i==9 or i==11)) then 
				if trades[year][i][m]==nil then trades[year][i][m]={} end
			end
		end
		
	end
	
	func.savetable_old(trades,TradesPath)--_new)
	ToLog ("скрипт остановлен")
	func.inTable (tt1, 'ver. 22-10-2024')

end