require("func")
require("robot")

stopped = false

function OnStop(s)
	stopped = true
	return 5000
end

function MemoryFirstdate(key,position)
	if memory.buy[position..tool[key].seccode1.preffix].firstdate~=0 and memory.buy[position..tool[key].seccode1.preffix].firstdate< memory.sell[position..tool[key].seccode1.preffix].firstdate then 
		return memory.buy[position..tool[key].seccode1.preffix].firstdate
	elseif memory.sell[position..tool[key].seccode1.preffix].firstdate~=0 then 
		return memory.sell[position..tool[key].seccode1.preffix].firstdate
	else return os.time()
	end
end 

function fill()

	dateT=os.date("*t",os.time())
	
	tradesDate=trades[dateT.year][dateT.month][dateT.day]
	--func.inTable (tt1, key..' robot.closetrade ')
	
	for key,value in pairs(tool) do		
		if value.strategy202106.enable then
			if tradesDate[key]==nil then 
				tradesDate[key]={} 
				tradesDate[key][value.seccode1.seccode]={}
				tradesDate[key][value.seccode2.seccode]={}
				tradesDate[key][value.seccode1.seccode]['PREV_SWAP_RATE']=tonumber(getParamEx(CLASS_CODE, value.seccode1.seccode,'PREV_SWAP_RATE').param_value)
				tradesDate[key][value.seccode2.seccode]['PREV_SWAP_RATE']=tonumber(getParamEx(CLASS_CODE, value.seccode2.seccode,'PREV_SWAP_RATE').param_value)
				tradesDate[key][value.seccode1.seccode]['CLPRICE']=tonumber(getParamEx(CLASS_CODE, value.seccode1.seccode,'CLPRICE').param_value)
				tradesDate[key][value.seccode2.seccode]['CLPRICE']=tonumber(getParamEx(CLASS_CODE, value.seccode2.seccode,'CLPRICE').param_value)
				tradesDate[key][value.seccode1.seccode]['vol']=value.strategy202106.pos.one.total.vol+value.strategy202106.pos.two.total.vol+value.strategy202106.pos.three.total.vol
				tradesDate[key][value.seccode2.seccode]['vol']=value.strategy202106.pos.one.total2.vol+value.strategy202106.pos.two.total2.vol+value.strategy202106.pos.three.total2.vol
			
				tradesDate[key][value.seccode1.seccode]['funding']=tradesDate[key][value.seccode1.seccode]['vol']*tradesDate[key][value.seccode1.seccode]['PREV_SWAP_RATE']*tonumber(getParamEx(CLASS_CODE, value.seccode1.seccode,'LOTSIZE').param_value*-1)
				tradesDate[key][value.seccode2.seccode]['funding']=tradesDate[key][value.seccode2.seccode]['vol']*tradesDate[key][value.seccode2.seccode]['PREV_SWAP_RATE']*tonumber(getParamEx(CLASS_CODE, value.seccode2.seccode,'LOTSIZE').param_value*-1)
			
				tradesDate[key][value.seccode1.seccode]['cost']=func.correctsum(value.seccode1.seccode,tradesDate[key][value.seccode1.seccode]['vol']*tradesDate[key][value.seccode1.seccode]['CLPRICE'])
				tradesDate[key][value.seccode2.seccode]['cost']=func.correctsum(value.seccode2.seccode,tradesDate[key][value.seccode2.seccode]['vol']*tradesDate[key][value.seccode2.seccode]['CLPRICE'])
			
			end
		end
	end

	trades[dateT.year][dateT.month][dateT.day]=tradesDate

end

function fillTemp()
	local file = io.open(getScriptPath()..'//temp.txt', "r");
	local arr = {}
	for line in file:lines() do
		table.insert (arr, tonumber(line));
	end
	func.savetable(arr,getScriptPath()..'//temp2.txt')
end

function fillTrades(key,seccode,field,n)
	
	for month,montharr in pairs(trades[2024]) do	
		func.inTable (tt1, '2024 '.. tostring(month))
		for day,dayarr in pairs(montharr) do	
			func.inTable (tt1, month..' '.. tostring(day))
			if dayarr[key]==nill then dayarr[key]={} end
			if dayarr[key][seccode]==nill then dayarr[key][seccode]={} end
			dayarr[key][seccode][field]=temp[n]
			
			dateT=os.date("*t",os.time())
			n=n+1
			if month==5 and day==28 then return true end
		end
	end
end
function main()
	
	func.logtable()
	TradesPath = getScriptPath()..'//trades.txt'
	TradesPath_new = getScriptPath()..'//trades2.txt'
	trades=func.loadtable(TradesPath)

	ToolPath = getScriptPath()..'//tool.txt'
	tool=func.loadtable(ToolPath)

	TempPath = getScriptPath()..'//temp2.txt'
	temp=func.loadtable(TempPath)

	--func.inTable (tt1, key..' robot.closetrade ')
	fillTemp()
	fillTrades('CNYRUBF','CNYRUBF','CLPRICE',1)
	fillTrades('CNYRUBF','CNYRUBF','PREV_SWAP_RATE',42)
	fillTrades('CNYRUBF-2','CNYRUBF','CLPRICE',1)
	fillTrades('CNYRUBF-2','CNYRUBF','PREV_SWAP_RATE',42)
	
	
	func.savetable(trades,TradesPath)--_new)
	ToLog ("скрипт остановлен")
	func.inTable (tt1, 'ver. 22-05-2024 13-50')

end