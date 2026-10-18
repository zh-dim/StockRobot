require("func")
require("robot")

stopped = false

function OnStop(s)
	stopped = true
	return 5000
end

function main()
	year=2025
	
	func.logtable()
	TradesPath = getScriptPath()..'//trades.txt'
	TradesPath_new = getScriptPath()..'//trades2.txt'
	trades=func.loadtable(TradesPath)
	
	DataTbl={}
	DataTbl.year=year
	for i=1, 11, 1 do 
		trades[year][i]={}
	end
	
	func.savetable(trades,TradesPath_new)
	ToLog ("скрипт остановлен")
	func.inTable (tt1, 'ver. 22-10-2024')

end