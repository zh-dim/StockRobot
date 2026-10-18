require("func")
require("robot")

stopped = false

function OnStop(s)
	stopped = true
	return 5000
end


function main()

	--seccode1='USDRUBF'
	--operation1='B'
	--seccode2='SiU4'
	--operation2='S'
	--vol=5 

	seccode1='EURRUBF'
	operation1='B'
	seccode2='EuU4'
	operation2='S'
	vol=10 

	--seccode1='EURRUBF'
	--operation1='S'
	--seccode2='EuU4'
	--operation2='B'
	--vol=10 

	--seccode1='USDRUBF'
	--operation1='S'
	--seccode2='SiU4'
	--operation2='B'
	--vol=3 


	TRANS_ID= func.random()
	robot.message(seccode1 .. ' ' .. operation1 .. ' vol: '..vol)
	func.tran (operation1,seccode1,0,vol,TRANS_ID)
	
	TRANS_ID= func.random()
	robot.message(seccode2 .. ' ' .. operation2 .. ' vol: '..vol)
	func.tran (operation2,seccode2,0,vol,TRANS_ID)
	
	ToLog ("скрипт остановлен")

end