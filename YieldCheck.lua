require("func")
require("robot")

stopped = false

function OnStop(s)
	stopped = true
	return 5000
end

function GetGo1(value)

	local go1=tonumber(getParamEx(CLASS_CODE,value.seccode1.seccode, "SELLDEPO").param_value)
	local go2=tonumber(getParamEx(CLASS_CODE,value.seccode2.seccode, "SELLDEPO").param_value)

	if go1>go2 then return go1
	elseif go1<go2 then return go2
	else return 1
	end
	
end

function YieldCalc(key)
	
	multiple=1
	value=tool[key]
	Options=value.strategy202106
	if value.seccode1.seccode=='IMOEXF' then multiple=10 end
	
	multiplier1=tonumber(getParamEx(CLASS_CODE, tool[key].seccode1.seccode,'LOTSIZE').param_value)
	multiplier2=tonumber(getParamEx(CLASS_CODE, tool[key].seccode2.seccode,'LOTSIZE').param_value)
	
	Options.pos.two.funding.new=(Options.pos.two.funding.duration-Options.pos.two.funding.durationCur)*Options.pos.two.funding.AvgFunding*multiplier1
	Options.pos.two.funding2.new=(Options.pos.two.funding2.duration-Options.pos.two.funding2.durationCur)*Options.pos.two.funding2.AvgFunding*multiplier2

	string=key		
	string=string..' фандинг('..func.roundS(Options.pos.two.funding.new,1)..')=('
	string=string..'длительность('..Options.pos.two.funding.duration..')-'
	string=string..'длительность.тек('..Options.pos.two.funding.durationCur..'))*'
	string=string..'ср.фандинг('..func.roundS(Options.pos.two.funding.AvgFunding,1)..'), '
	string=string..'фандинг2('..func.roundS(Options.pos.two.funding2.new,1)..')'	
	func.inTable (tt1, string)
	
	local locDur=Options.pos.two.funding2.durationReal-Options.pos.two.funding2.durationCurReal
	if locDur==0 then locDur=1 end
	local NewYield=(Options.pos.two.funding.new+Options.pos.two.funding2.new-multiple*(value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID))/GetGo1(value)/(locDur)*365*100	

	string=key	
	string=string..' Доходность('..func.roundS(NewYield,1)..')='
	string=string..'фандинг('..func.roundS(Options.pos.two.funding.new+Options.pos.two.funding2.new,1)..')-'
	string=string..'спрэд('..func.roundS(multiple*(value.seccode2.PRICE_OFFER-value.seccode1.PRICE_BID),1)..')/'
	string=string..'ГО('..func.roundS(GetGo1(value),1)..')/'
	string=string..'длительность('..func.roundS(locDur,1)..')*365*100'
	
	func.inTable (tt1, string)
end
			

function main()
	
	func.logtable()
	TradesPath = getScriptPath()..'//trades.txt'
	trades=func.loadtable(TradesPath)
	ToolPath = getScriptPath()..'//tool.txt'
	tool=func.loadtable(ToolPath)

	YieldCalc('IMOEXF-2')
	YieldCalc('IMOEXF-MMM5')

	
	ToLog ("скрипт остановлен")

end