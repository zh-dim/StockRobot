require("func")
require("robot")

stopped = false

function OnStop(s)
	stopped = true
	return 5000
end

function InsertOrder(OrderTable,OrderTablePath,key,seccode,operation,price,vol,tframe,LinkedId)
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
	--func.inTable (tt1, 'InsertOrder OrderTablePath '..func.Tbl2Str(OrderTable))
	func.savetable(OrderTable,OrderTablePath)
	return TransID
end

function trade(order1, order2)
	OrderTable1 = func.loadtable(order1.OrderTablePath)	
	OrderTable2 = func.loadtable(order2.OrderTablePath)	
	if order2.IdOrder1~=nil and OrderTable2[order2.IdOrder1].completed then 
		order1.n=order1.n+1
		func.inTable (tt1, order1.n..' Цена исполнения ордера 1 '..OrderTable1[order1.IdOrder1].tradeprice..' '..order1.IdOrder1.. ' '..order1.operation..' '..order1.vol..' '..order1.key..' '..order1.seccode )	
		func.inTable (tt1, order1.n..' Цена исполнения ордера 2 '..OrderTable2[order2.IdOrder1].tradeprice..' '..order2.IdOrder1.. ' '..order2.operation..' '..order2.vol..' '..order2.key..' '..order2.seccode )	
		OrderTable1[order1.IdOrder1]=nil
		OrderTable2[order2.IdOrder1]=nil
		order1.IdOrder1=nil
		order2.IdOrder1=nil
		func.savetable(OrderTable1,order1.OrderTablePath)
		func.savetable(OrderTable2,order2.OrderTablePath)		
	elseif order1.IdOrder1~=nil and OrderTable1[order1.IdOrder1].completed and order2.IdOrder1==nil then 
		--func.inTable (tt1, order1.n..' 'Создаем ордер 2 '..' '..order2.operation..' '..order2.vol..' '..order2.key..' '..order2.seccode )	
		UpPrice=0
		if order2.operation=='B' then UpPrice=order1.diff*-1
		elseif order2.operation=='S' then UpPrice=order1.diff
		end
		order2.IdOrder1=InsertOrder(OrderTable2,order2.OrderTablePath,order2.key,order2.seccode,order2.operation,OrderTable1[order1.IdOrder1].tradeprice+UpPrice,order2.vol,order2.tframe,order1.IdOrder1)	
		func.inTable (tt1, order1.n..' Ждем исполнения ордера 2 '..order2.IdOrder1.. ' '..order2.operation..' '..order2.vol..' '..order2.key..' '..order2.seccode)	
	elseif order1.IdOrder1==nil then 
		--func.inTable (tt1, order1.n..' 'Создаем ордер 1 '..' '..order1.operation..' '..order1.vol..' '..order1.key..' '..order1.seccode )
		order1.IdOrder1=InsertOrder(OrderTable1,order1.OrderTablePath,order1.key,order1.seccode,order1.operation,0,order1.vol,order1.tframe,0)
		func.inTable (tt1, order1.n..' Ждем исполнения ордера 1 '..order1.IdOrder1.. ' '..order1.operation..' '..order1.vol..' '..order1.key..' '..order1.seccode )			
	end
end

function tradeRun(sber, alpha)
	
	SberOrder1=func.ArrayCopy(sber)
	SberOrder2=func.ArrayCopy(sber)
	AlphaOrder1=func.ArrayCopy(alpha)
	AlphaOrder2=func.ArrayCopy(alpha)
	--func.inTable (tt1, 'AlphaOrder1 '..func.Tbl2Str(SberOrder1))
	--func.inTable (tt1, 'AlphaOrder2 '..func.Tbl2Str(SberOrder1))

	while stopped==false do
		trade(SberOrder1, AlphaOrder1)
		sleep(5000)
		trade(AlphaOrder2, SberOrder2)
	
		if SberOrder1.n>10 or  AlphaOrder2.n>10 then break end
	end

end

function main()

	func.logtable()

	alpha={}
	alpha.OrderTablePath='C://StockRobot2024_AD//OrderTable.txt'
	alpha.key='GLDRUBF-2'
	alpha.seccode='GLH5'
	alpha.operation='B'
	alpha.vol=5
	alpha.tframe='twoGL2'
	alpha.n=1
	alpha.diff=4

	sber={}
	sber.OrderTablePath='C://StockRobot2024//OrderTable.txt'
	sber.key='GLM5'
	sber.seccode='GLH5'
	sber.operation='S'
	sber.vol=5
	sber.tframe='threeGL2'
	sber.n=1
	sber.diff=4
	
	tradeRun(sber, alpha)

end