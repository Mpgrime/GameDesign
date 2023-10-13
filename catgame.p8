pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--cat game
--by xan weatherholtz, matthew grimelli, malik hill, marjon ward

function _init()
 frame=1
 catpos={x=56,y=56}
 pose=7 --frame when still
 flipped=false
 
 --chair locations:
 chairx={40,80,30,10}
 chairy={70,90,20,100}
 --chair bottom locations:
 bchairx={40,80,30,10}
 bchairy={78,98,28,108}
 --ball locations:
	ballposx={60,20}
	ballposy={80,40}
 
 cw=14 --cat width
 ch=14 --cat height
 chairw=14 --chair width
 chairh=16 --chair height
 ballw=6 --ball width
 ballh=6 --ball height
 bchairw=14
 bchairh=7
 cupframe=38
 cupflip=false --true if cup reflected
end


function _update()
	flist={pose,pose,pose} --if no buttons pressed
	--canmove=true

	--frame change
 if frame<3.9 then
 	frame+=.3 --sets anim speed
 else
 	frame=1
 end
 
 --arrow controls
 if btn(⬆️) then
 	local canmove=true
 	for i=1,4 do
 		--if col w/ bchair, can't move:
 		if collision(catpos.x,catpos.y-1,cw,ch,
 															bchairx[i],bchairy[i],bchairw,bchairh) then
 			canmove=false
 		end
 		--if col w/ ball, ball moves:
 		if i<3 and
 					collision(catpos.x,catpos.y-1,cw,ch,
 															ballposx[i],ballposy[i],ballw,ballh) then
 			ballposy[i]-=1
 		end								
 	end
 	--if col w/ cup
 	if collision(catpos.x,catpos.y-1,cw,ch,
 															90,10,8,8) then 															
 			canmove=false
 	end
 	--pos change if able:
 	if(canmove) then catpos.y-=1 end
 	--frame set change
 	flist={32,34,36}
 	--pose change
 	pose=32
 	--no sprite flipping
 	flipped=false
 end
 if btn(⬇️) then
 	local canmove=true
 	for i=1,4 do
 		--if col w/ bchair, can't move:
 		if collision(catpos.x,catpos.y+1,cw,ch,
 															bchairx[i],bchairy[i],bchairw,bchairh) then
 			canmove=false
 		end
 		--if col w/ ball, ball moves:
 		if i<3 and
 					collision(catpos.x,catpos.y+1,cw,ch,
 															ballposx[i],ballposy[i],ballw,ballh) then
 			ballposy[i]+=1
 		end								
 	end
 	--if col w/ cup
 	if collision(catpos.x,catpos.y+1,cw,ch,
 															90,10,8,8) then 															
 			canmove=false
 	end
 	--pos change if able:
 	if(canmove) then catpos.y+=1 end
 	flist={7,9,11}
 	pose = 7
 	flipped=false
 end
 if btn(⬅️) then 	
 	local canmove=true
 	for i=1,4 do
 		--if col w/ bchair, can't move:
 		if collision(catpos.x-1,catpos.y,cw,ch,
 															bchairx[i],bchairy[i],bchairw,bchairh) then
 			canmove=false
 		end
 		--if col w/ ball, ball moves:
 		if i<3 and
 					collision(catpos.x-1,catpos.y,cw,ch,
 															ballposx[i],ballposy[i],ballw,ballh) then
 			ballposx[i]-=1
 		end													
 	end
 	--if col w/ cup, change cup
 	if collision(catpos.x-1,catpos.y,cw,ch,
 															90,10,8,8) then 															
 			canmove=false
 			if cupframe==38 then --if not already changed
 				cupframe=54
 			end
 	end
 	--pos change if able:
 	if(canmove) then catpos.x-=1 end
 	flist={1,3,5}
 	pose=1
 	flipped=false
 end
 if btn(➡️) then
 
 	local canmove=true
 	for i=1,4 do
 		--if col w/ bchair, can't move:
 		if collision(catpos.x+1,catpos.y,cw,ch,
 															bchairx[i],bchairy[i],bchairw,bchairh) then
 		canmove=false
 		end
 		--if col w/ ball, ball moves:
 		if i<3 and
 					collision(catpos.x+1,catpos.y,cw,ch,
 															ballposx[i],ballposy[i],ballw,ballh) then
 			ballposx[i]+=1
 		end			
 	end
 	--if col w/ cup, change cup
 	if collision(catpos.x+1,catpos.y,cw,ch,
 															90,10,8,8) then 															
 			canmove=false
 			if cupframe==38 then --if not already changed
 				cupframe=54
 				cupflip=true
 			end
 	end
 	--pos change if able:
 	if(canmove) then catpos.x+=1 end
 	--catpos.x+=1
 	flist={1,3,5}
 	pose=1
 	flipped=true --backwards ⬅️ sprite
 end
 
end


function _draw()
 cls()
 map(0,0,0,0,16,16) --draws map
 --🐱 cat sprite:
 spr(flist[flr(frame)],catpos.x,catpos.y,2,2,flipped)
 	--flr rounds down to nearest int
 	--gets item 1-3 from flist
 	--spr(framenum,x,y,framesize,framesize,flipped?)
 --chair + ball sprites:
 spr(42,chairx[1],chairy[1],2,2)
 spr(42,chairx[2],chairy[2],2,2)
 spr(42,chairx[3],chairy[3],2,2)
 spr(42,chairx[4],chairy[4],2,2,true)
 spr(44,ballposx[1],ballposy[1],1,1)
 spr(44,ballposx[2],ballposy[2],1,1)
 
 --bottoms of chairs sprites
 spr(45,bchairx[1],bchairy[1],2,2)
 spr(45,bchairx[2],bchairy[2],2,2)
 spr(45,bchairx[3],bchairy[3],2,2)
 spr(45,bchairx[4],bchairy[4],2,2,true)
 
 --cup sprite:
 spr(cupframe,90,10,1,1,cupflip)
 --water sprite:
 if cupframe==54 then
 	if cupflip then
 		spr(39,98,10,1,1,true)
 	else
 		spr(39,82,10,1,1)
 	end
 end
end


--returns true if 2 objs collided
function collision(
	x1,y1,w1,h1, --position,width obj1
	x2,y2,w2,h2) --pos, width obj2
	
	local hit=false
	
	--collision distance:
	local coldisx=w1*.5+w2*.5
	local coldisy=h1*.5+h2*.5
	
	--current distances each axis:
	local curdisx=abs((x1+(w1/2))-(x2+(w2/2)))
	local curdisy=abs((y1+(h1/2))-(y2+(h2/2)))
	
	if curdisx<coldisx and curdisy<coldisy then
		hit=true
	end
	
	return hit
	
end
__gfx__
00000000000000000000000000000000000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000770000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000070000000000000077000700070000000700000000000000000000000000000000000000070007000000000000000000000000000000
00077000070007000000070000000000000007000777770000000700000007000700000000000000000000000000077777000000000000000000000000000000
00077000077777000000070007000700000007000a7a77000000070000000777770000000000070007000000000007a7a7000000000044444444444000000000
007007000a7a77000000070007777700000007000777777777777700000007a7a700000000000777770000000000077777000000000444444444444000000000
0000000007777777777777000a7a77000000070007777777777777000000077777000000000007a7a70000000000077777000000004444444444404000000000
00000000077777777777770007777777777777000777777777777700000007777700000000000777770000000000077777000000044444444444004000000000
00000000077777777777770007777777777777000777777777777700000007777700000000000777770000000000077777000000040040000004004000000000
00000000077777777777770007777777777777000777777777777700000007777700000000000777770000000000077777000000040000000004000000000000
00000000077777777777770007777777777777000700700000700700000007777700000000000777770000000000070007000000040000000004000000000000
00000000070070000070070007777777777777000700700000700700000007000700000000000777770000000000070007000000040000000004000000000000
00000000070070000070070007007000007007000000000000000000000007000700000000000700070000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000007700000000ffffffff000000000000000000000000000004444444444000000000000044444444444000000000
00000077000000000000000000000000000000070000000088888888000000000000000000000000000004444444444000bbbb00000444444444444000000000
0000000700000000000000770000000000000007000000008888888800000000444444444444444000000444444444400bbbbbb0004444444444404000000000
0000000700000000000000070000000000000007000000008888888800000000444444444444444000000444444444400bbbbbb0044444444444004000000000
0000000700000000000000070000000000000007000000000888888000000000444444444444444000000444444444400bbbbbb0040040000004000000000000
0000000700000000000000070000000000000777770000000888888000000ccc444444404444444000000444444444400bbbbbb0040000000004000000000000
000007777700000000000007000000000000077e770000000088880000cccccc4444444444444440000004444444444000bbbb00040000000004000000000000
0000077e770000000000077777000000000007777700000000888800cccccccc4444444444444440000000000000000000000000040000000004000000000000
00000777770000000000077e77000000000007777700000078880000000000004000000000000040000044444444444000000000000000000000000000000000
00000777770000000000077777000000000007777700000078888800000000004444444444444440000444444444444000000000000000000000000000000000
00000777770000000000077777000000000007000700000078888888000000004444444444444440004444444444404000000000000000000000000000000000
00000700070000000000077777000000000007000700000078888888000000004444444044444440044444444444004000000000000000000000000000000000
00000700070000000000070007000000000000000000000078888888000000004444444444444440040040000004004000000000000000000000000000000000
00000000000000000000000000000000000000000000000078888888000000004444444444444440040000000004000000000000000000000000000000000000
00000000000000000000000000000000000000000000000078888800000000004444444444444440040000000004000000000000000000000000000000000000
00000000000000000000000000000000000000000000000078880000000000000000000000000000040000000004000000000000000000000000000000000000
55555555444444442222222211115111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555444444442122222211115111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55655555444444442222222211115111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555444444442222212211115111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555655444444442222222255555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555000000002212222211115111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56555555444444442222222211115111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555444444442222221211115111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88888888888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee88888e88888888888888888888888888888888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8888eee8888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee88888e88888888888888888888888888888888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111ddd1ddd1ddd11dd1d1d111111dd11dd1dd11ddd1ddd11dd1d1111dd111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1d1d1d1d1d1d1d1d11111d111d1d1d1d11d11d1d1d1d1d111d11111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd1ddd1dd11dd11d1d1d1d11111d111d1d1d1d11d11dd11d1d1d111ddd111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1d1d1d1d1d1d1ddd11111d111d1d1d1d11d11d1d1d1d1d11111d111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1d1d1d1d1dd11ddd111111dd1dd11d1d11d11d1d1dd11ddd1dd1111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee11111bbb1bbb1bb1117111666661117111111eee1e1e1eee1ee11111111111111111111111111111111111111111111111111111111111111111
111111e11e1111111b1b11b11b1b1711166616661117111111e11e1e1e111e1e1111111111111111111111111111111111111111111111111111111111111111
111111e11ee111111bb111b11b1b1711166111661117111111e11eee1ee11e1e1111111111111111111111111111111111111111111111111111111111111111
111111e11e1111111b1b11b11b1b1711166111661117111111e11e1e1e111e1e1111111111111111111111111111111111111111111111111111111111111111
11111eee1e1111111bbb11b11b1b1171116666611171111111e11e1e1eee1e1e1111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e1111ee11ee1eee1e111111116616661661166611661616166611111ccc1ccc1c1c1ccc111111111111111111111111111111111111111111111111
111111111e111e1e1e111e1e1e1111111611161616161666161616161611177711c11c1c1c1c1c11111111111111111111111111111111111111111111111111
111111111e111e1e1e111eee1e1111111611166616161616161616161661111111c11cc11c1c1cc1111111111111111111111111111111111111111111111111
111111111e111e1e1e111e1e1e1111111611161616161616161616661611177711c11c1c1c1c1c11111111111111111111111111111111111111111111111111
111111111eee1ee111ee1e1e1eee11111166161616161616166111611666111111c11c1c11cc1ccc111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee11ee1eee1111166611111cc111111c1c11111ee111ee111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e11111161177711c111111c1c11111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111
111111111ee11e1e1ee111111161111111c111111ccc11111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e11111161177711c11171111c11111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111ee11e1e1111166611111ccc1711111c11111eee1ee1111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111ddd1ddd111111dd11dd1d1111111d1d111d11111ddd11dd1d1d1ddd1ddd1ddd1111111111dd1ddd1dd111d11ddd11111ddd11dd1d1d
1111111111111111111111d11d1111111d111d1d1d1111111d1d11d111111d1d1d111d1d1d1d11d11d1d111111111d111d1d1d1d1d1111d111111ddd1d1d1d1d
1111111111111ddd1ddd11d11dd111111d111d1d1d1111111d1d11d111111dd11d111ddd1ddd11d11dd1111111111d111ddd1d1d111111d111111d1d1d1d1d1d
1111111111111111111111d11d1111111d111d1d1d1111111ddd11d111111d1d1d111d1d1d1d11d11d1d11d111111d111d1d1d1d111111d111111d1d1d1d1ddd
111111111111111111111ddd1d11111111dd1dd11ddd11111ddd1d1111111ddd11dd1d1d1d1d1ddd1d1d1d11111111dd1d1d1d1d111111d111111d1d1dd111d1
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1eee111111661166161116111666116616661166166111711166166616661666116611661111161611111166166616661666116611661111
11111111111111e11e11111116111616161116111161161111611616161617111611161611611616161616111111161611111611161611611616161616111111
11111111111111e11ee1111116111616161116111161166611611616161617111611166611611666161616661111116111111611166611611666161616661111
11111111111111e11e11111116111616161116111161111611611616161617111611161611611611161611161111161611711611161611611611161611161111
1111111111111eee1e11111111661661166616661666166116661661161611711166161611611611166116611171161617111166161611611611166116611171
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111666116616161666166616661616177116661177111116661166161616661666
11111111111111111111111111111111111111111111111111111111111111111616161116161616116116161616171111611117111116161611161616161161
11111111111111111111111111111111111111111111111111111111111111111661161116661666116116611161171111611117111116611611166616661161
11111111111111111111111111111111111111111111111111111111111111111616161116161616116116161616171111611117117116161611161616161161
11111111111111111111111111111111111111111111111111111111111111111666116616161616166616161616177116661177171116661166161616161666
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111116616661661166611661616166611111ccc1ccc1c1111cc1ccc111111111111111111111111111111111111111111111111111111111111
1111111111111111161116161616166616161616161117771c111c1c1c111c111c11111111111111111111111111111111111111111111111111111111111111
1111111111111111161116661616161616161616166111111cc11ccc1c111ccc1cc1111111111111111111111111111111111111111111111111111111111111
1111111111111111161116161616161616161666161117771c111c1c1c11111c1c11111111111111111111111111111111111111111111111111111111111111
1111111111111111116616161616161616611161166611111c111c1c1ccc1cc11ccc111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111ddd1ddd111111dd11dd1d1111111d1d111d11111ddd1ddd1d111d11111111111ddd1ddd1d111d1111111ddd11dd1d1d1ddd11dd1111
1111111111111111111111d11d1111111d111d1d1d1111111d1d11d111111d1d1d1d1d111d11111111111d1d1d1d1d111d1111111ddd1d1d1d1d1d111d1111d1
1111111111111ddd1ddd11d11dd111111d111d1d1d1111111d1d11d111111dd11ddd1d111d11111111111dd11ddd1d111d1111111d1d1d1d1d1d1dd11ddd1111
1111111111111111111111d11d1111111d111d1d1d1111111ddd11d111111d1d1d1d1d111d1111d111111d1d1d1d1d111d1111111d1d1d1d1ddd1d11111d11d1
111111111111111111111ddd1d11111111dd1dd11ddd11111ddd1d1111111ddd1d1d1ddd1ddd1d1111111ddd1d1d1ddd1ddd11111d1d1dd111d11ddd1dd11111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1eee1111166611171ccc11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111e11e11111111611171111c11111e1e1e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111e11ee111111161171111cc11111eee1e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111e11e11111111611171111c11111e1e1e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1e111111166611171ccc11111e1e1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111661166161116111666116616661166166111711166166616661666116611661111161611111166166616661666116611661111
11111111111111111111111116111616161116111161161111611616161617111611161611611616161616111111161611111611161611611616161616111111
11111111111111111111111116111616161116111161166611611616161617111611166611611666161616661111116111111611166611611666161616661111
11111111111111111111111116111616161116111161111611611616161617111611161611611611161611161111161611711611161611611611161611161111
11111111111111111111111111661661166616661666166116661661161611711166161611611611166116611171161617111166161611611611166116611171
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111666166616111611166611661166161617711666117711111666166616111611
11111111111111111111111111111111111111111111111111111111111111111616161616111611161616161611161617111161111711111616161616111611
11111111111111111111111111111111111111111111111111111111111111111661166616111611166616161666116117111161111711111661166616111611
11111111111111111111111111111111111111111111111111111111111111111616161616111611161116161116161617111161111711711616161616111611
11111111111111111111111111111111111111111111111111111111111111111666161616661666161116611661161617711666117717111666161616661666
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111116661666161116111666116611661616177116661177111111111cc111111111111111111111111111111111111111111111111111111111
1111111111111111161616161611161116161616161116161711116111171111177711c111111111111111111111111111111111111111111111111111111111
1111111111111111166116661611161116661616166616661711116111171777111111c111111111111111111111111111111111111111111111111111111111
1111111111111111161616161611161116111616111611161711116111171111177711c111111111111111111111111111111111111111111111111111111111
111111111111111116661616166616661611166116611666177116661177111111111ccc11111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1ee11ee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ee11e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1e1e1eee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111ddd1ddd111111dd11dd1d1111111d1d111d111111dd1d1d1ddd111111111111111111111111111111111111111111111111111111111111
111111111111111111d11d1111111d111d1d1d1111111d1d11d111111d111d1d1d1d111111111111111111111111111111111111111111111111111111111111
111111111ddd1ddd11d11dd111111d111d1d1d1111111d1d11d111111d111d1d1ddd111111111111111111111111111111111111111111111111111111111111
111111111111111111d11d1111111d111d1d1d1111111ddd11d111111d111d1d1d11111111111111111111111111111111111111111111111111111111111111
11111111111111111ddd1d11111111dd1dd11ddd11111ddd1d11111111dd11dd1d11111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1eee1111116611661611161116661166166611661661117111661666166616661166116611111616111111661666166616661166116611111616
1111111111e11e111111161116161611161111611611116116161616171116111616116116161616161111111616111116111616116116161616161111111616
1111111111e11ee11111161116161611161111611666116116161616171116111666116116661616166611111161111116111666116116661616166611111666
1111111111e11e111111161116161611161111611116116116161616171116111616116116111616111611111616117116111616116116111616111611111116
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822288828222822282228888888888888888888888888888888888888888888888888222822282288882822282288222822288866688
82888828828282888888828288288882888282828888888888888888888888888888888888888888888888888282828288288828828288288282888288888888
82888828828282288888822288288222822282828888888888888888888888888888888888888888888888888222828288288828822288288222822288822288
82888828828282888888888288288288828882828888888888888888888888888888888888888888888888888282828288288828828288288882828888888888
82228222828282228888888282888222822282228888888888888888888888888888888888888888888888888222822282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__map__
4343434343434343434343434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434242424242424242424243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434242424242424242424243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434242424242424242424243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434242424242424242424243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434242424242424242424243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434242424242424242424243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434242424242424242424243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434242424242424242424243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434242424242424242424243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434242424242424242424243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
