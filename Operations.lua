require("func")
require("robot")

stopped = false

function OnStop(s)
	stopped = true
	return 5000
end

function transfer_vol()
		
		if operation=='S' then 
			op='sell'
		else 
			op='buy'
		end

		sum=memory_new[op][tframe_permanent].vol*memory_new[op][tframe_permanent].price

		comission=memory_old[op][tframe_permanent].comission/memory_old[op][tframe_permanent].vol*vol
		memory_new[op][tframe_permanent].comission=memory_new[op][tframe_permanent].comission+comission
		memory_old[op][tframe_permanent].comission=memory_old[op][tframe_permanent].comission-comission
		
		memory_new[op][tframe_permanent].vol=memory_new[op][tframe_permanent].vol+vol
		memory_new[op][tframe_permanent].price=(sum+(memory_old[op][tframe_permanent].price*vol))/memory_new[op][tframe_permanent].vol

		memory_old[op][tframe_permanent].vol=memory_old[op][tframe_permanent].vol-vol
end

function main()
	--Настроечный блок
	
	key_old='GLDRUBF'
	key_new='GLDRUBF-2'
	seccode_permanent='GLDRUBF' --инструмент, который не меняется
	seccode_old='GLU4'
	seccode_new='GLM4'
	pos='three'
	vol=5 --сколько контрактов переносим

	--key_old='EuH4'
	--key_new='EURRUBF-2'
	--seccode_permanent='EuM4' --инструмент, который не меняется
	--seccode_old='EuH4'
	--seccode_new='EURRUBF'
	--pos='three'
	--vol=0 --сколько контрактов переносим
	
	operation='S' --что делаем с заменяемым инструментом 'S' продажа, 'B' 
	-----------------
	func.logtable()
	ToolPath = getScriptPath()..'//tool.txt'
	tool=func.loadtable(ToolPath)
	
	FPath_new = getScriptPath()..'//'..key_new .. '.params'
	FPath_old = getScriptPath()..'//'..key_old .. '.params'
	memory_new=func.loadtable(FPath_new)
	memory_old=func.loadtable(FPath_old)
	tframe_new=''
	tframe_old=''

	if tool[key_old].seccode2.seccode==seccode_old then 
		tframe_old=pos..tool[key_old].seccode2.preffix
		tframe_permanent=pos..tool[key_old].seccode1.preffix
	elseif tool[key_old].seccode1.seccode==seccode_old then 
		tframe_old=pos..tool[key_old].seccode1.preffix
		tframe_permanent=pos..tool[key_old].seccode2.preffix
	else return false
	end
	
	if tool[key_new].seccode2.seccode==seccode_new then 
		tframe_new=pos..tool[key_new].seccode2.preffix
	elseif tool[key_new].seccode1.seccode==seccode_new then 
		tframe_new=pos..tool[key_new].seccode1.preffix
	else 
		func.inTable (tt1, 'Выход')
		return false
	end
	
	if operation=='S' and vol>0 then 
		memory=memory_old
		FPath=FPath_old
		robot.transaction (memory_old.sell,tframe_old,'S',seccode_old,vol)
		memory=memory_new		
		FPath=FPath_new
		robot.transaction (memory_new.buy,tframe_new,'B',seccode_new,vol)
		--sleep(10000)
		transfer_vol()
	elseif vol>0 then 
		memory=memory_old
		FPath=FPath_old
		robot.transaction (memory_old.buy,tframe_old,'B',seccode_old,vol)
		memory=memory_new		
		FPath=FPath_new
		robot.transaction (memory_new.sell,tframe_new,'S',seccode_new,vol)	
		--sleep(10000)
		transfer_vol()
	end
	
	proffit=0
	old_vol=0
	delta_price=0

	if memory_old.buy[tframe_old].vol==memory_old.sell[tframe_old].vol and memory_old.sell[tframe_old].vol>0 then 
		old_vol=memory_old.sell[tframe_old].vol
		memory=memory_old
		FPath=FPath_old
		proffit=robot.closetrade (tframe_old,seccode_old)
		func.inTable (tt1, 'proffit '..tostring(proffit))
		if operation=='S' then op='buy'
		else op='sell'
		end
		func.inTable (tt1, 'price '..tostring(memory_new[op][tframe_new].price))
	
		memory_new[op][tframe_new].price=(func.correctsum (seccode_new,memory_new[op][tframe_new].vol*memory_new[op][tframe_new].price))
			/func.correctsum (seccode_new,memory_new[op][tframe_new].vol)	
	
		func.inTable (tt1, 'price '..tostring(memory_new[op][tframe_new].price))
	end
	
	func.savetable(memory_old,FPath_old)
	func.savetable(memory_new,FPath_new)
	
	ToLog ("скрипт остановлен")

end