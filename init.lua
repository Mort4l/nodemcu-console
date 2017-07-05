c=0
wifi.setmode(wifi.STATION)
gpio.mode(1,gpio.OUTPUT)
gpio.mode(2,gpio.INPUT)
wifi.sta.config("ssid","password") --wifi名称与密码
wifi.sta.connect()
--tmr.alarm(0,1000,1,function() hxd() end)

tmr.alarm(0, 1000, tmr.ALARM_AUTO, function()
	if wifi.sta.getip() == nil then
		print('Waiting for IP ...')
		c=c+1
		if c>=30 then
			tmr.stop(1)
			wifi.setmode(wifi.STATIONAP)
			wifi.ap.config({ssid="Nodemcu2",pwd="12345678"}) --如果连接多次无法连接成功则创建热点
			print("creat ap!")
			print("ssid:Nodemcu2 password:12345678")
			tmr.stop(0)
		end
	else
		print('IP is ' .. wifi.sta.getip())
		tmr.stop(0)
	end
end)
dofile("httpServer.lua")
httpServer:listen(80)

httpServer:use('/', function(req, res)
	if req.query.action == "status" then
		dofile("config.lua")
		--res:type('application/json')
		res:send('{"switch0":' ..switch0 .. ',"switch1":' .. switch1 .. ',"switch2":' .. switch2 ..'}')
		--res:send('[' .. switch0 .. ',' .. switch1 .. ',' .. switch2 ..']')
	elseif
		req.query.action == "set" then
		file.open("config.lua","w+")
		file.writeline("switch0=" .. req.query.switch0 .. "\nswitch1=" .. req.query.switch1 .. "\nswitch2=" .. req.query.switch2)
		file.close()
		switch()
		res:send("OK")
	else
		res:sendFile('jdq.html')
	end
end)
function switch()
	dofile("config.lua")
	if switch0 == 1 then
		if switch2 == 1 then
			gpio.write(1,gpio.LOW)
			tmr.stop(1)
			print("Light On")
		elseif switch1 == 1 and switch2 ==0 then
			tmr.alarm(1,1000,1,function() 
				if gpio.read(2) == 1 and switch0 == 1 then 
					gpio.write(1,gpio.LOW) 
				else gpio.write(1,gpio.HIGH) 
				end 
			end)
		else tmr.stop(1)
			gpio.write(1,gpio.HIGH) 
		end
	else 
		gpio.write(1,gpio.HIGH)
		print ("light OFF")
	end
end