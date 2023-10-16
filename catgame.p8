pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

--cat game
--by xan weatherholtz, matthew grimelli, malik hill, marjon ward

function _init()
 frame=1
 pose=7 --frame when still
	
 --player cat class/table
 cat={
	x=56,y=56,w=14,h=14, --position(x,y), width, height
 	size=2,flipped=false --sprite size, flipping the sprite
 }
 
 --chair class/table
 chair={
 	x={40,80,30,10},y={70,90,20,100}, --chair locations
 	bx={40,80,30,10},by={78,98,28,108}, --chair bottom locations
 	w=14,h=16,bw=14,bh=7 --chair/chair bottom width/height
 }

	--magic_sign class/table
 msign={
	x=100,y=56,w=8,h=8,
	size=1,frame=124
 }
	
 --ball class/table
 ball={x={60,20},y={80,40},w=6,h=6}
 
 --cup class/table
 cup={
	x=90,y=10,w=8,h=8,
 	size=1,frame=38,flipped=false --flip=true if reflected
 } 
 --door class / table
 door = {
	x={56,56,64,64},y={8,0,8,0}, --door locations
	frame={89,73,90,74},w=8,h=8,
	unlocked=false
 }
	--is the puzzle solved
	puzSolve = false
	--showEnd
	showEnd = false
end

function _update()
 flist={pose,pose,pose} --if no buttons pressed, canmove=true

	--frame change
 if frame<3.9 then
 	frame+=.3 --sets anim speed
 else
 	frame=1
 end
 for i=1,4 do
 	if collision(cat.x,cat.y,cat.w,cat.h, door.x[i],door.y[i],door.w,door.h)
	and door.unlocked == true then
		showEnd = true
	end
end
 player_ctrl()
 signswitch() 
end

function _draw()
	if showEnd then
		cls()
		print("congratulations, you escaped!",3,60)
	else
	--clears screen w/ light blue for sky
 	cls(12) 
 	map(0,0,0,0,16,16) --draws map
 	player_draw()
 	props_draw()
	end
end

-->8
--[update tab]

function player_ctrl()
--arrow controls
 if btn(⬆️) then
 	local canmove=true
 	for i=1,4 do
 		--if col w/ bchair, can't move:
 		if collision(cat.x,cat.y-1,cat.w,cat.h,
 		chair.bx[i],chair.by[i],chair.w,chair.h) then
 			canmove=false
 		end
		--if col w/ mapedge, can't move:
		if cat.y-1 < 3 then
			canmove = false
		end
 		--if col w/ ball, ball moves:
 		if i<3 and collision(cat.x,cat.y-1,cat.w,cat.h,
 		ball.x[i],ball.y[i],ball.w,ball.h) then
 			ball.y[i]-=1
 		end
		if collision(cat.x,cat.y,cat.w,cat.h,door.x[i],door.y[i],door.w,door.h) then
			canmove=false
		end							
 	end
 	--if col w/ cup
 	if collision(cat.x,cat.y-1,cat.w,cat.h,
 	cup.x,cup.y,cup.w,cup.h) then 															
 			canmove=false
 	end
 	--pos change if able:
 	if(canmove) then cat.y-=1 end
 	--frame set change
 	flist={32,34,36}
 	--pose change
 	pose=32
 	--no sprite flipping
 	cat.flipped=false
 end
 if btn(⬇️) then
 	local canmove=true
 	for i=1,4 do
 		--if col w/ bchair, can't move:
 		if collision(cat.x,cat.y+1,cat.w,cat.h,
 		chair.bx[i],chair.by[i],chair.bw,chair.bh) then
 			canmove=false
 		end
		--if col w/ mapedge, can't move:
		if cat.y + 1 > 115 then
			canmove = false
		end
 		--if col w/ ball, ball moves:
 		if i<3 and collision(cat.x,cat.y+1,cat.w,cat.h,
 		ball.x[i],ball.y[i],ball.w,ball.h) then
 			ball.y[i]+=1
 		end								
 	end
 	--if col w/ cup
 	if collision(cat.x,cat.y+1,cat.w,cat.h,
 	cup.x,cup.y,cup.w,cup.h) then 															
 			canmove=false
 	end
 	--pos change if able:
 	if(canmove) then cat.y+=1 end
 	flist={7,9,11}
 	pose = 7
 	cat.flipped=false
 end
 if btn(⬅️) then 	
 	local canmove=true
 	for i=1,4 do
 		--if col w/ bchair, can't move:
 		if collision(cat.x-1,cat.y,cat.w,cat.h,
 		chair.bx[i],chair.by[i],chair.bw,chair.bh) then
 			canmove=false
 		end
		-- if col w/ mapedge, can't move:
		if cat.x - 1 < 0 then
			canmove = false
		end
 		--if col w/ ball, ball moves:
 		if i<3 and collision(cat.x-1,cat.y,cat.w,cat.h,
 		ball.x[i],ball.y[i],ball.w,ball.h) then
 			ball.x[i]-=1
 		end													
 	end
 	--if col w/ cup, change cup
 	if collision(cat.x-1,cat.y,cat.w,cat.h,
 	cup.x,cup.y,cup.w,cup.h) then 															
 			canmove=false
 			if cup.frame==38 then --if not already changed
 				cup.frame=54
 			end
 	end
 	--pos change if able:
 	if(canmove) then cat.x-=1 end
 	flist={1,3,5}
 	pose=1
 	cat.flipped=false
 end
 if btn(➡️) then
 	local canmove=true
 	for i=1,4 do
 		--if col w/ bchair, can't move:
 		if collision(cat.x+1,cat.y,cat.w,cat.h,
 		chair.bx[i],chair.by[i],chair.bw,chair.bh) then
 			canmove=false
 		end
		--if col w/map edge, can't move:
		if cat.x + 1 == 115 then
			canmove = false
		end
 		--if col w/ ball, ball moves:
 		if i<3 and collision(cat.x+1,cat.y,cat.w,cat.h,
 		ball.x[i],ball.y[i],ball.w,ball.h) then
 			ball.x[i]+=1
 		end			
 	end
 	--if col w/ cup, change cup
 	if collision(cat.x+1,cat.y,cat.w,cat.h,
 	cup.x,cup.y,cup.w,cup.h) then 															
 			canmove=false
 			if cup.frame==38 then --if not already changed
 				cup.frame=54
 				cup.flipped=true
 			end
 	end
 	--pos change if able:
 	if(canmove) then cat.x+=1 end
 	--catpos.x+=1
 	flist={1,3,5}
 	pose=1
 	cat.flipped=true --backwards ⬅️ sprite
 end
end

--sign turns green when red ball touches it
function signswitch()
	if collision(ball.x[2],ball.y[2],ball.w,ball.h,
	msign.x,msign.y,msign.w,msign.h) then
		msign.frame=125
		puzSolve = true
		door.unlocked = true
		door.frame = {91,75,92,76}
	else 
		puzSolve = false
		msign.frame = 124
		door.unlocked = false
		door.frame = {89,73,90,74}
	end
end
 
--returns true if 2 objs collided
function collision(
	x1,y1,w1,h1, 
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
-->8
--[draw tab]

function player_draw()
--🐱 cat sprite:
 spr(flist[flr(frame)],cat.x,cat.y,cat.size,cat.size,cat.flipped)
 	--flr rounds down to nearest int
 	--gets item 1-3 from flist
 	--spr(framenum,x,y,framesize,framesize,flipped?)
end

function props_draw()
--chair + ball sprites:
 spr(42,chair.x[1],chair.y[1],2,2)
 spr(42,chair.x[2],chair.y[2],2,2)
 spr(42,chair.x[3],chair.y[3],2,2)
 spr(42,chair.x[4],chair.y[4],2,2,true)
 spr(44,ball.x[1],ball.y[1],1,1)
 spr(60,ball.x[2],ball.y[2],1,1)
 
 --bottoms of chairs sprites
 spr(45,chair.bx[1],chair.by[1],2,2)
 spr(45,chair.bx[2],chair.by[2],2,2)
 spr(45,chair.bx[3],chair.by[3],2,2)
 spr(45,chair.bx[4],chair.by[4],2,2,true)
 
 --cup sprite:
 spr(cup.frame,cup.x,cup.y,cup.size,cup.size,cup.flipped)
 --water sprite:
 if cup.frame==54 then
 	if cup.flipped then
 		spr(39,98,10,1,1,true)
 	else
 		spr(39,82,10,1,1)
 	end
 end
 --door
 spr(door.frame[1],door.x[1],door.y[1])
 spr(door.frame[2],door.x[2],door.y[2])
 spr(door.frame[3],door.x[3],door.y[3])
 spr(door.frame[4],door.x[4],door.y[4])
 --magic sign
 spr(msign.frame,msign.x,msign.y,msign.size,msign.size)
end
__gfx__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000f00000000000000000000000000000
00000000000000000000000000000000000000000f0000f00000000000000f0000f00000000000000000000000000ff77ff00000000000000000000000000000
007007000f0000f00000000000000000000000000ff77ff000000f0000000ff77ff0000000000f0000f0000000000ff77ff00000000000000000000000000000
000770000ff77ff000000f000f0000f0000000000f77fff00000f0f000000ff77ff0000000000ff77ff0000000000fa77af00000000000000000000000000000
000770000f77fff00000f0f00ff77ff0000000000a7afff00000007000000fa77af0000000000ff77ff00000000007f77f700000000066666666666000000000
007007000a7afff0000000700f77fff00000ff000f777ff100000770000007f77f70000000000fa77af000000000007777000000000666666666666000000000
000000000f777ff1000007700a7afff0000f00700777771fffff77700000007777000000000007f77f7000000000001111000000006666666666606000000000
000000000777771fffff77700f777ff10000077000111177fff777000000001111000000000000777700000000000ff77ff00000066666666666006000000000
0000000000111177fff777000777771fffff7770000777777f77700000000ff77ff00000000000111100000000000f7777f00000060060000006006000000000
00000000000777777f77700000111177fff77700000777777777700000000f7777f0000000000ff77ff000000000077777700000060000000006000000000000
000000000007777777777000000777777f7770000007777777777700000007777770000000000f7777f000000000077777700000060000000006000000000000
0000000000077777777777000007777777777700000ff0ff07f07f000000077777700000000007777770000000000ff00ff00000060000000006000000000000
00000000000f707f077077000007777777777700000000000000000000000f7007f0000000000777777000000000000000000000000000000000000000000000
000000000000f0f000f00f000000f0f000f00f000000000000000000000000f00f000000000000f00f0000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000f0000f00000ffffffff000000000000000000000000000006666666666000000000000066666666666000000000
00000f0000f00000000000000000000000000ff77ff0000088888888000000000000000000000000000006666666666000aaaa00000666666666666000000000
00000ff77ff0000000000f0000f0000000000f7777f0000088888888000000004444444444444440000006666666666007aaaa70006666666666606000000000
00000f7777f0000000000ff77ff000000000077ff77000008888888800000000444444444444444000000666666666600a7aa7a0066666666666006000000000
0000077ff770000000000f7777f0000000000077f70000000888888000000000444444444444444000000666666666600a7aa7a0060060000006000000000000
00000077f7000000000007777770000000000017710000000888888000000ccc4444444044444440000006666666666007aaaa70060000000006000000000000
00000017710000000000007ff7000000000007f77f7000000088880000cccccc4444444444444440000006666666666000aaaa00060000000006000000000000
00000ff77ff0000000000017f1000000000007777770000000888800cccccccc4444444444444440000000000000000000000000060000000006000000000000
00000f7777f0000000000ff77ff00000000007777770000078880000000000004000000000000040000066666666666000000000000000000000000000000000
000007777770000000000f7777f00000000007777770000078888800000000004444444444444440000666666666666000888800000000000000000000000000
0000077777700000000007777770000000000f7007f0000078888888000000004444444444444440006666666666606008888880000000000000000000000000
00000770077000000000077777700000000000000000000078888888000000004444444044444440066666666666006007777770000000000000000000000000
00000f0000f0000000000f0000f00000000000000000000078888888000000004444444444444440060060000006006007777770000000000000000000000000
00000000000000000000000000000000000000000000000078888888000000004444444444444440060000000006000008888880000000000000000000000000
00000000000000000000000000000000000000000000000078888800000000004444444444444440060000000006000000888800000000000000000000000000
00000000000000000000000000000000000000000000000078880000000000000000000000000000060000000006000000000000000000000000000000000000
d4444444d44444444444444d44444444444444444444444d22222222dddddddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000
d4444444d44444444444444d44444444444444444444444d22222222dddddddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000
d4444444d44444444444444d44444444444444444444444d22222222dddddddddddddddddd444444444444dddd447777777777dd000000000000000000000000
d5555555d55555555555555d55555555555555555555555d22255222dddddddddddddddddd444444444444dddd447777777777dd000000000000000000000000
d4444444d44444444444444d44444444444444444444444d22255222dddddddddddddddddd644444444444dddd647777777777dd000000000000000000000000
d4444444d44444444444444d44444444444444444444444d22222222dddddddddddddddddd644444444444dddd647777777777dd000000000000000000000000
d4444444d44444444444444d44444444444444444444444d22222222dddddddddddddddddd444444444444dddd447777777777dd000000000000000000000000
d4444444dddddddddddddddd44444444dddddddd4444444d22222222dddddddddddddddddd444444444444dddd447777777777dd000000000000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddddddddddd444444444444dddd447777777777dd000000000000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddddddddddd444444445554dddd447777777777dd000000000000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddddddddddd444444444484dddd447777777777dd000000000000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddddddddddd444444444444dddd447777777777dd000000000000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddddddddddd644444444444dddd647777777777dd000000000000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddddddddddd644444444444dddd647777777777dd000000000000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddddddddddd444444444444dddd447777777777dd000000000000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddddddddddd555555555555dddd557777777777dd000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088880000bbbb000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000800b0000b00000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080800808b0b00b0b0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080888808b0bbbb0b0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080888808b0bbbb0b0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080088008b00bb00b0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000800b0000b00000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088880000bbbb000000000000000000
__label__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd444444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd444444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd644444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd644444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd444444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd444444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd444444444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd444444445554dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd444444444484ddddddddddddddddddddffffffffdddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd444444444444dddddddddddddddddddd88888888dddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd644444444444dddddddddddddddddddd88888888dddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd644444444444dddddddddddddddddddd88888888dddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd444444444444ddddddddddddddddddddd888888ddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd555555555555ddddddddddddddddddddd888888ddddddddddddddddddddddddddddddd
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444488884444444444444444444444444444444d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444488884444444444444444444444444444444d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555d
d444444444444444444444444444444444466666666664444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444444444444444444444466666666664444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444444444444444444444466666666664444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444444444444444444444466666666664444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444222222222222222222266666666662222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222266666666662222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222266666666662222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d555555555555555222552222225522222255222222552222225522222255222222552222225522222255222222552222225522222255222555555555555555d
d444444444444444222552222225522222666666666662222225522222255222222552222225522222255222222552222225522222255222444444444444444d
d444444444444444222222222222222226666666666662222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222266666666666262222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222666666666662262222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222622622222262262222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222622222222262222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222622222222262222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d555555555555555222552222225522622255222262552222225522222255222222552222225522222255222222552222225522222255222555555555555555d
d444444444444444222552222225522222255222222552222225522222255222222552222225522222255222222552222225522222255222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222888822222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222228888882222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d555555555555555222557777775522222255222222552222225522222255222222552222225522222255222222552222225522222255222555555555555555d
d444444444444444222557777775522222255222222552222225522222255222222552222225522222255222222552222225522222255222444444444444444d
d444444444444444222228888882222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222888822222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d555555555555555222552222225522222255222222552222225522222255222222552222225522222255222222552222225522222255222555555555555555d
d444444444444444222552222225522222255222222552222225522222255222222552222225522222255222222552222225522222255222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222228888222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222f2222f222222222222222222222222222222222282222822222444444444444444d
d444444444444444222222222222222222222222222222222222222222222ff77ff222222222222222222222222222222222828228282222444444444444444d
d555555555555555222552222225522222255222222552222225522222255ff77ff552222225522222255222222552222225828888285222555555555555555d
d444444444444444222552222225522222255222222552222225522222255fa77af552222225522222255222222552222225828888285222444444444444444d
d4444444444444442222222222222222222222222222222222222222222227f77f7222222222222222222222222222222222822882282222444444444444444d
d444444444444444222222222222222222222222222222222222222222222277772222222222222222222222222222222222282222822222444444444444444d
d444444444444444222222222222222222222222222222222222222222222211112222222222222222222222222222222222228888222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222ff77ff222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222f7777f222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222777777222222222222222222222222222222222222222222222444444444444444d
d555555555555555222552222225522222255222222552222225522222255777777552222225522222255222222552222225522222255222555555555555555d
d444444444444444222552222225522222255222222552222225522222255f7227f552222225522222255222222552222225522222255222444444444444444d
d4444444444444442222222222222222222222222222222222222222222222f22f2222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222226666666666222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222226666666666222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222226666666666222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222226666666666222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222226666666666222222222222222222222222222222222222222222222222222222222444444444444444d
d555555555555555222552222225522222255222222556666666666222255222222552222225522222255222222552222225522222255222555555555555555d
d444444444444444222552222225522222255222222556666666666222255222222552222225522222255222222552222225522222255222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222266666666666222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222666666666666222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222226666666666626222222222222222222222222222222222222222222222222222222222444444444444444d
d4444444444444442222222222222222222222222666666666662262222222aaaa2222222222222222222222222222222222222222222222444444444444444d
d4444444444444442222222222222222222222222622622222262262222227aaaa7222222222222222222222222222222222222222222222444444444444444d
d555555555555555222552222225522222255222262552222226522222255a7aa7a552222225522222255222222552222225522222255222555555555555555d
d444444444444444222552222225522222255222262552222226522222255a7aa7a552222225522222255222222552222225522222255222444444444444444d
d4444444444444442222222222222222222222222622222222262222222227aaaa7222222222222222222222222222222222222222222222444444444444444d
d4444444444444442222222222222222222222222222222222222222222222aaaa2222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222666666666622222222222222222444444444444444d
d555555555555555222552222225522222255222222552222225522222255222222552222225522222255666666666622225522222255222555555555555555d
d444444444444444222552222225522222255222222552222225522222255222222552222225522222255666666666622225522222255222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222666666666622222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222666666666622222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222666666666622222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222666666666622222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444444444222222222222222222222222222222222222222222222222222222222222222222226666666666622222222222222222444444444444444d
d555555555555555222552222225522222255222222552222225522222255222222552222225522222266666666666622225522222255222555555555555555d
d444444444466666666662222225522222255222222552222225522222255222222552222225522222666666666662622225522222255222444444444444444d
d444444444466666666662222222222222222222222222222222222222222222222222222222222226666666666622622222222222222222444444444444444d
d444444444466666666662222222222222222222222222222222222222222222222222222222222226226222222622622222222222222222444444444444444d
d444444444466666666662222222222222222222222222222222222222222222222222222222222226222222222622222222222222222222444444444444444d
d444444444466666666662222222222222222222222222222222222222222222222222222222222226222222222622222222222222222222444444444444444d
d444444444466666666662222222222222222222222222222222222222222222222222222222222226222222222622222222222222222222444444444444444d
d444444444466666666662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d555555555555555222552222225522222255222222552222225522222255222222552222225522222255222222552222225522222255222555555555555555d
d444444444466666666666222225522222255222222552222225522222255222222552222225522222255222222552222225522222255222444444444444444d
d444444444466666666666622222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444464666666666662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444464466666666666222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444444444444d
d444444444464464444446446444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444464444444446444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444464444444446444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d555555555555565555555556555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
d444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd

__map__
474847484748474b4c4847484748474800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
575857585758575b5c5857585758575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043434343434343434343434343434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043464646464646464646464646434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043464646464646464646464646434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043464646464646464646464646434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043464646464646464646464646434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043464646464646464646464646434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043464646464646464646464646434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043464646464646464646464646434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043464646464646464646464646434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043464646464646464646464646434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043464646464646464646464646434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043464646464646464646464646434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4043434343434343434343434343434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4144444444444444444444444444444200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
