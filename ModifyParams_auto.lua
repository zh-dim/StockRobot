require("func")
require("robot")

stopped = false

function OnStop(s)
	stopped = true
	return 5000
end

function transfer_vol(param)
		
		if param.vol>0 then 
			if param.operation=='S' then 
				op='sell'
			else 
				op='buy'
			end
			func.inTable (tt1, 'operation: '..op)

			sum_old=func.correctsum (param.seccode,memory[op][tframe].vol*memory[op][tframe].price)
			func.inTable (tt1, 'sum_old: '..sum_old)
			sum_new=func.correctsum (param.seccode,param.vol*param.price)
			func.inTable (tt1, 'sum_new: '..sum_new)

			func.inTable (tt1, 'vol_old: '..memory[op][tframe].vol)		
			memory[op][tframe].vol=memory[op][tframe].vol+param.vol
			func.inTable (tt1, 'vol_new: '..memory[op][tframe].vol)

			func.inTable (tt1, 'price_old: '..memory[op][tframe].price)
			memory[op][tframe].price=(sum_old+sum_new)/func.correctsum (param.seccode,memory[op][tframe].vol)
			func.inTable (tt1, 'price_new: '..memory[op][tframe].price)
			memory[op][tframe].lastprice=param.price
			memory[op][tframe].n=memory[op][tframe].n+1
			
			str='ModifyParams '..param.operation..' '..param.key.. ' '..param.seccode.. ' '..tframe..' Total: '..param.vol..' '.. 'Price: '..param.price
			func.inTable (tt1, str)
			func.ToTradeLog (str)
		end
end

function insertTran (key,pos,seccode,vol,op, price)
	n=#params+1
	params[n]={}
	params[n].key=key
	params[n].pos=pos
	params[n].seccode=seccode
	params[n].operation=op
	params[n].vol=vol
	params[n].price=price
	params[n].vol_old=0

	func.inTable (tt1, key..' '..pos..' '..seccode..' '..op.. ' vol: ' ..vol..' price: '..price)
end

function fill_params ()

	top=#params
	for i=1, top, 1 do
		if params[i].pos2~=nil and params[i].vol~=0 then 
			toolKey=tool[params[i].key]
			pos1=toolKey.strategy202106.pos[params[i].pos]
			pos2=toolKey.strategy202106.pos[params[i].pos2]
			seccode1=toolKey.seccode1.seccode
			seccode2=toolKey.seccode2.seccode
			vol=params[i].vol
			
			if pos1.total.vol>0 then 	
				op1='S'
				op2='B'
			elseif pos1.total.vol<0 then 	
				op1='B'
				op2='S'
			end
			insertTran (params[i].key,params[i].pos,seccode1,vol,op1,pos1.total.enterprice)
			insertTran (params[i].key,params[i].pos2,seccode1,vol,op2,pos1.total.enterprice)
			insertTran (params[i].key,params[i].pos,seccode2,vol,op2,pos1.total2.enterprice)
			insertTran (params[i].key,params[i].pos2,seccode2,vol,op1,pos1.total2.enterprice)
			params[i].vol_old=vol			
			params[i].vol=0
		end
	end
end

function main()
	func.logtable()
	ParamPath = getScriptPath()..'//ModifyParams.txt'
	params=func.loadtable(ParamPath)

	ToolPath = getScriptPath()..'//tool.txt'
	tool=func.loadtable(ToolPath)

	fill_params ()
	func.savetable(params,ParamPath)
	
	--for i=1, #params, 1 do 
	----for num,param in pairs(params) do		
	--
	--	func.inTable (tt1, tostring(i))
	--	FPath = getScriptPath()..'//'..params[i].key .. '.params'
	--	memory=func.loadtable(FPath)
	--	func.inTable (tt1, params[i].key .. '.params')
	--
	--	if tool[params[i].key].seccode2.seccode==params[i].seccode then 
	--		tframe=params[i].pos..tool[params[i].key].seccode2.preffix
	--	elseif tool[params[i].key].seccode1.seccode==params[i].seccode then 
	--		tframe=params[i].pos..tool[params[i].key].seccode1.preffix
	--	else return false
	--	end
	--	func.inTable (tt1, 'tframe: '..tframe)
	--
	--	transfer_vol(params[i])
	--	func.savetable(memory,FPath)	
	--	params[i].vol_old=params[i].vol
	--	params[i].vol=0
	--	func.savetable(params,ParamPath)
	--
	--end

	ToLog ("скрипт остановлен")

end