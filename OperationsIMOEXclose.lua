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
		n=n+1
		func.inTable (tt1, n..' Цена исполнения ордера 1 '..OrderTable1[order1.IdOrder1].tradeprice..' '..order1.IdOrder1.. ' '..order1.operation..' '..order1.vol..' '..order1.key..' '..order1.seccode )	
		func.inTable (tt1, n..' Цена исполнения ордера 2 '..OrderTable2[order2.IdOrder1].tradeprice..' '..order2.IdOrder1.. ' '..order2.operation..' '..order2.vol..' '..order2.key..' '..order2.seccode )	
		OrderTable1[order1.IdOrder1]=nil
		OrderTable2[order2.IdOrder1]=nil
		order1.IdOrder1=nil
		order2.IdOrder1=nil
		func.savetable(OrderTable1,order1.OrderTablePath)
		func.savetable(OrderTable2,order2.OrderTablePath)		
	elseif order1.IdOrder1~=nil and OrderTable1[order1.IdOrder1].completed and order2.IdOrder1==nil then 
		--func.inTable (tt1, n..' 'Создаем ордер 2 '..' '..order2.operation..' '..order2.vol..' '..order2.key..' '..order2.seccode )	
		UpPrice=0
		if order2.operation=='B' then UpPrice=diff*1
		elseif order2.operation=='S' then UpPrice=diff*-1
		end
		order2.IdOrder1=InsertOrder(OrderTable2,order2.OrderTablePath,order2.key,order2.seccode,order2.operation,OrderTable1[order1.IdOrder1].tradeprice+UpPrice,order2.vol,order2.tframe,order1.IdOrder1)	
		func.inTable (tt1, n..' Ждем исполнения ордера 2 '..order2.IdOrder1.. ' '..order2.operation..' '..order2.vol..' '..order2.key..' '..order2.seccode)	
	elseif order1.IdOrder1==nil then 
		--func.inTable (tt1, n..' 'Создаем ордер 1 '..' '..order1.operation..' '..order1.vol..' '..order1.key..' '..order1.seccode )
		order1.IdOrder1=InsertOrder(OrderTable1,order1.OrderTablePath,order1.key,order1.seccode,order1.operation,0,order1.vol,order1.tframe)
		func.inTable (tt1, n..' Ждем исполнения ордера 1 '..order1.IdOrder1.. ' '..order1.operation..' '..order1.vol..' '..order1.key..' '..order1.seccode )			
	end
end


function main()

	func.logtable()

		
	alpha={}
	alpha.OrderTablePath='C://StockRobot2024_AD//OrderTable.txt'
	alpha.key='IMOEXF-MMM5'
	alpha.seccode='IMOEXF'
	alpha.operation='S'
	alpha.vol=1
	alpha.tframe='threeMX4'

	sber={}
	sber.OrderTablePath='C://StockRobot2024//OrderTable.txt'
	sber.key='IMOEXF-MMM5'
	sber.seccode='MMM5'
	sber.operation='B'
	sber.vol=1
	sber.tframe='threeMX'

	alpha2={}
	alpha2.OrderTablePath='C://StockRobot2024_AD//OrderTable.txt'
	alpha2.key='IMOEXF-MMM5'
	alpha2.seccode='IMOEXF'
	alpha2.operation='S'
	alpha2.vol=1
	alpha2.tframe='threeMX4'

	sber2={}
	sber2.OrderTablePath='C://StockRobot2024//OrderTable.txt'
	sber2.key='IMOEXF-MMM5'
	sber2.seccode='MMM5'
	sber2.operation='B'
	sber2.vol=1
	sber2.tframe='threeMX'

	diff=182
	
	--order1={}
	--order2={}
	SberOrder1=sber
	SberOrder2=sber2
	AlphaOrder1=alpha
	AlphaOrder2=alpha2
	
	--order2=alpha
	--order1.IdOrder1=nil
	--order2.IdOrder1=nil	

	n=0

	while stopped==false do

		trade(AlphaOrder2, SberOrder2)
		sleep(5000)
		trade(SberOrder1, AlphaOrder1)
		if n>10 then break end

	end

end