pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

--cat game
--by xan weatherholtz, matthew grimelli, malik hill, marjon ward

--global variable
flist = { 0, 0, 0 }
doorOpenSFX = true
doorOpenSFX2 = true
level = "house"

function _init()
	title_init()
end

function _update()
end

function _draw()
end
-->8
--[init tab]

--start for title screen
function title_init()
	--states
	_update = title_update
	_draw = title_draw
	--cat animation stuff
	frame = 1
	flist = {1, 3, 5}
end

--start of room1 gameplay
function game_init()
	--set state
	_update = game_update
	_draw = map_draw
	kingratdefeated = false --for win condition
	frame = 1
	pose = 7
	--frame when still

	ratcollided = false --for rat collision
	kingratcollided = false --for kingrat collision
	stage = 1

	--player cat class/table
	cat = {
		x=56, y=56, w=14, h=14, --position(x,y), width, height
		size=2, flipped=false, --sprite size, flipping the sprite
		collision=true --CHANGED FOR TESTING
	}

	--normal enemy rat class/table
	rat = {
		x={60,200}, y={100,200}, --positions(x,y)
		--x=60, y=100,
		w=8, h=5, --width, height
		size=1, flipped=true,
		collision=true,
		direction=1, --stores what direction to go
		rat_num = 0 --stores which rats should be spawned (numbers correlate with position list indexes)
	}

	--boss/king rat class/table (IN PROGRESS)
	kingrat = {
		x=825, y=145, --position(x,y) (initially places it on throne by top of room)
		w=16, h=13, --width, height
		size=2, flipped=true,
		collision=true,
		direction=1, --stores what direction to go
		chase=false --true if it should be moving/chasing
	}

	-- hearts (system for tracking damage taken)
	hearts = {
		x={2, 10, 18}, y=2, --locations of each heart on screen
		w=7, h=8, --width, height
		size=1,
		onscreen={true, true, true} --whether each heart should be on screen
	}

	--chair class/table
	chair = {
		x={488,456,150,232,400,140},y={90,59,20,102,22,232}, --chair locations
		bx={488,456,150,232,400,140},by={94,63,24,106,36,236}, --chair bottom locations
		w=14,h=16,bw=14,bh=7,frame=42 --chair/chair bottom width/height
	}

	--magic_sign class/table
	msign = {
		x={24,96},y={36,36},w=8,h=8,
		size=1,frame={29,13}
	}

	--ball class/table
	ball = {
	x={88,32},y={88,88},w=6,h=6, collision = true
	}

	--cup class/table
	cup = {
		x=224,y=26,w=8,h=8,
		size=1,frame=38,flipped=false --flip=true if reflected
	}
	--puzzle buttons (house(indexes 1-6), forest(7))
	pushbtn={
		x={268,268,364,364,60,700},y={47,22,47,22,36,55},
		w=8,h=8,size=1,
		frame={112,114,116,118,120,120}
	}
	--flowers for flower puzzle
	flower={
		x={664,664,729,729},y={24,81,24,81},
		frame={210,210,210,210},w=16,h=16,size=2
	}
	--[[still needs to be implemented,
	should block path in flower puzzle until solved]]
	fence={
		x={680,688,696,704},y={8,8,8,8},
		frame=207,w=8,h=8
	}

	--king rat room puzzle buttons
	kingbtn={
		x={777,777,879,879}, y={143,240,143,240}, --{top left (tl), bl, tr, br}
		w=8,h=8,size=1,
		frame={118,118,118,118},
		litbtn=1, --which button is being lit up (0 if none are)
		time=0 
	}

	--yellow circles for indicating where to lead king rat
	ycircle={
		x=824, y=190,
		w={16,4}, h={16,4}, size={2,1}, --{big circle, small circle}
		visible=false
	}

	--cage that comes down on rat king
	cage={
		x=825, y=130,
		w=16, h=16, size=2,
		visible=false,
		timedown=0 --how long cage has been on screen
	}

	--attempt for house puzzle
	attempt_h={}
	--attempt for flower puzzle
	attempt_f={"x","x","x","x"}
	--attempt for king rat buttons
	attempt_king={}
	
	--door class/table
	door = {
		x={56,56,64,64},y={8,0,8,0}, -- positions
		frame={89,73,90,74},w=8,h=8, -- frames and hitbox
		unlocked=false -- open or not
	}
	--puzzle door
	door2={
		x={312,312,320,320},y={8,0,8,0},
		w=8,h=8,frame={89,73,90,74},
		unlocked=false
	}
	--house class/table
	house = {
		rx={0,32,16,48,16,48}, --x-pos for rooms/screen house level (remember it uses top-left corner)
		ry={0,0,0,0,16,16}, --y-pos for rooms/screen of house level
		--props = {}
	}
	--forest class/table
	forest = {
		rx={64,80,96},ry={0,0,0}
	}
	--factory class/table
	factory = {
		rx={64,80,96},ry={16,16,16}
	}
	
	--is the puzzle solved
	puzSolve = false
	--showEnd
	showend = false
end
-->8
--[update tab]

--when on title screen
function debug_update()
	cat.collision=false
end

function title_update()
	if frame < 3.9 then
		frame += .3 --sets anim speed
	else
		frame = 1
	end

	if btnp(❎) then
		game_init() --starts game
	end
end

--when on end screen
function end_update()
	if frame < 3.9 then
		frame += .3 --sets anim speed
	else
		frame = 1
	end

	if btnp(❎) then
		game_init()
	end
end

--when in room gameplay
function game_update()
	--debug_update()
	
	flist = { pose, pose, pose }

	if frame < 3.9 then
		frame += .3 --sets anim speed
	else
		frame = 1
	end

	for i = 1, 4 do
		if objcollision(cat.x, cat.y, cat.w, cat.h,
		door.x[i], door.y[i], door.w, door.h)
		and door.unlocked == true then
			cat.x = 312
			cat.y = 110
			stage = 2
		end
	end
	
	rat_move()
	if(rat_num != 0) then
		rat_collide()
	end	

	kingrat_move()
	if(kingrat.chase) then
		kingrat_collide()
	end

	player_ctrl()

	if level=="house" then
		stage_check(cat,house)
		housesigns(ball,msign,door)
		colorcombo_house(cat,pushbtn)
		
		if stage_check(cat,house)==2 then
			if cat.y>117 then
				cat.x=56
				cat.y=18
			end
		end
	
		if colorcombo_house(cat,pushbtn) then
			door2.frame={91,75,92,76}
			door2.unlocked=true
			if doorOpenSFX2 then
				sfx(2)
				doorOpenSFX2 = false
			end
		end
	
		for i=1,4 do
			if objcollision(cat.x,cat.y,cat.w,cat.h,
			door2.x[i],door2.y[i],door2.w,door2.h)
			and door2.unlocked==true then
				cat.x = 564
				cat.y = 110
				level = "forest"
			end
		end
	end
	
	if level=="forest" then
		stage_check(cat,forest)
		forest_transitions()
		
		if stage_check(cat,forest)==2 then
			flower_puzzle(cat,flower,pushbtn)
		end
	end
	
	if level=="factory" then
		stage_check(cat,factory)
		
		if stage_check(cat,factory)==1 then
			if cat.y>=245 then
			 cat.x=869
			 cat.y=5
			 level="forest"
			else
				level="factory"
			end
		end		
	end

	king_buttons(cat,kingbtn)

	--lighting up king rat buttons red to indicate order
	kingbtn.time += .1 --time kept track of so it doesn't go too fast
	if kingbtn.time >= 1 and kingbtn.litbtn > 0 then
		kingbtn.time = 0
		kingbtn.frame[kingbtn.litbtn] = 112 --turns current button red
		if kingbtn.litbtn==4 then
			kingbtn.frame[3] = 118 --turns last button back to yellow
			kingbtn.litbtn=1 --switches to next button
			kingbtn.time=-1 --pauses before next round of indications
		elseif kingbtn.litbtn==1 then
			kingbtn.frame[4] = 118 --turns last button back to yellow
			kingbtn.litbtn+=1 --switches to next button
		else
			kingbtn.frame[kingbtn.litbtn-1] = 118 --turns last button back to yellow
			kingbtn.litbtn+=1 --switches to next button
		end		
	end

	--if buttons pushed right
	if(king_buttons(cat,kingbtn)) then
		ycircle.visible=true --yellow circle shows up

		--if kingrat collides with the yellow circle
		if(objcollision(kingrat.x,kingrat.y,kingrat.w,kingrat.h,
		ycircle.x,ycircle.y,ycircle.w[2],ycircle.h[2])) then
			cage.visible=true --cage shows up
		end
	end

	--bringing cage down
	if cage.visible then
		cage.visible=true --draws cage

		if cage.y < ycircle.y then --if cage is higher than ycircle
			cage.y = cage.y + .5 --sends cage downward
		elseif cage.timedown < 5 then
			cage.timedown = cage.timedown+1
		else
			kingratdefeated=true
		end
		
	end

	if kingratdefeated then
		_draw = end_draw()
		_update = end_update()
	end
end

function forest_transitions()
	if stage_check(cat,forest)==1 then
		if cat.y<=0 then
			cat.x=700
			cat.y=110
		elseif cat.y>=112 then
			cat.x=312
			cat.y=15
			level="house"
		else
			level="forest"
		end
	end
		
	if stage_check(cat,forest)==2 then
		if cat.y<=0 then
			cat.x=796
			cat.y=110
		elseif cat.y>=112 then
			cat.x=576
			cat.y=5
		else
			level="forest"
		end
	end
		
	if stage_check(cat,forest)==3 then
		if cat.y<=0 then
			cat.x=568
			cat.y=240
			level="factory"
		elseif cat.y>=112 then
			cat.x=692
			cat.y=5
		else
			level="forest"
		end
	end
end

function player_ctrl()
	--arrow controls	
	if btn(⬆️) then
		local canmove = true
		for i = 1,6 do
			--if col w/ bchair, can't move:
			if objcollision(cat.x,cat.y - 1,cat.w,cat.h,
			chair.x[i], chair.y[i], chair.w, chair.h) then
				canmove = false
			end
			--if col w/ ball, ball moves:
			if i<3 and objcollision(cat.x,cat.y - 1,cat.w,cat.h,
			ball.x[i], ball.y[i], ball.w, ball.h) then
				ball.y[i] -= 1
				sfx(5) --ball rolling sfx
				if mapCollision(ball.x[i],ball.y[i]-8,ball.collision, 0) then
					ball.y[i] += 1
					cat.y += 1
				end
			end
			if i<4 and objcollision(cat.x, cat.y, cat.w, cat.h,
			door.x[i], door.y[i], door.w, door.h) then
				canmove = false
			end
		end
		--if col w/ cup
		if objcollision(
			cat.x, cat.y - 1, cat.w, cat.h,
			cup.x, cup.y, cup.w, cup.h
		) then
			canmove = false
		end
		for i = 1,4 do
			if objcollision(
				cat.x, cat.y - 1, cat.w, cat.h,
				fence.x[i], fence.y[i], fence.w, fence.h
			) then
				canmove = false
			end
		end
		--pos change if able:
		if canmove then cat.y -= 1 end
		if mapCollision(cat.x, cat.y,cat.collision, 0) then cat.y += 1 end
		--frame set change
		flist = { 32, 34, 36 }
		--pose change
		pose = 32
		--no sprite flipping
		cat.flipped = false
	end
	if btn(⬇️) then
		local canmove = true
		for i = 1,6 do
			--if col w/ bchair, can't move:
			if objcollision(
				cat.x, cat.y + 1, cat.w, cat.h,
				chair.x[i], chair.y[i], chair.bw, chair.bh
			) then
				canmove = false
			end
			--if col w/ ball, ball moves:
			if i<3 and objcollision(
				cat.x, cat.y+1, cat.w, cat.h,
				ball.x[i], ball.y[i], ball.w, ball.h
			) then
				ball.y[i]+=1
				sfx(5) --ball rolling sfx
				if mapCollision(ball.x[i],ball.y[i]-8,ball.collision, 0) then
					ball.y[i] -= 1
					cat.y -= 1
				end
			end
		end
		--if col w/ cup
		if objcollision(
			cat.x, cat.y + 1, cat.w, cat.h,
			cup.x, cup.y, cup.w, cup.h
		) then
			canmove = false
		end
		for i = 1,4 do
			if objcollision(
				cat.x, cat.y + 1, cat.w, cat.h,
				fence.x[i], fence.y[i], fence.w, fence.h
			) then
				canmove = false
			end
		end
		--pos change if able:
		if canmove then cat.y += 1 end
		if mapCollision(cat.x, cat.y, cat.collision, 0) then cat.y -= 1 end
		flist = {7, 9, 11}
		pose = 7
		cat.flipped = false
	end
	if btn(⬅️) then
		local canmove = true
		for i = 1,6 do
			--if col w/ bchair, can't move:
			if objcollision(
				cat.x - 1, cat.y, cat.w, cat.h,
				chair.x[i], chair.y[i], chair.bw, chair.bh
			) then
				canmove = false
			end
			--if col w/ ball, ball moves:
			if i < 3 and objcollision(
				cat.x - 1, cat.y, cat.w, cat.h,
				ball.x[i], ball.y[i], ball.w, ball.h
			) then
				ball.x[i] -= 1
				sfx(5) --ball rolling sfx
				if mapCollision(ball.x[i],ball.y[i],ball.collision, 0) then
					ball.x[i] += 1
					cat.x += 1
				end
			end
		end
		--if col w/ cup, change cup
		if objcollision(
			cat.x - 1, cat.y, cat.w, cat.h,
			cup.x, cup.y, cup.w, cup.h
		) then
			canmove = false
			if cup.frame == 38 then
				--if not already changed
				cup.frame = 54
				sfx(4) --water sfx
			end
		end
		for i = 1,4 do
			if objcollision(
				cat.x - 1, cat.y, cat.w, cat.h,
				fence.x[i], fence.y[i], fence.w, fence.h
			) then
				canmove = false
			end
		end
		--pos change if able:
		if canmove then cat.x -= 1 end
	 if mapCollision(cat.x, cat.y,cat.collision, 0) then cat.x += 1 end
		flist = {1, 3, 5}
		pose = 1
		cat.flipped = false
	end
	if btn(➡️) then
		local canmove = true
		for i=1,6 do
			--if col w/ bchair, can't move:
			if objcollision(cat.x + 1,cat.y,cat.w,cat.h,
			chair.x[i],chair.y[i],chair.bw,chair.bh) then
				canmove = false
			end
			--if col w/ ball, ball moves:
			if i < 3 and objcollision(
				cat.x + 1, cat.y, cat.w, cat.h,
				ball.x[i], ball.y[i], ball.w, ball.h
			) then
				ball.x[i] += 1
				sfx(5) --ball rolling sfx
				if mapCollision(ball.x[i],ball.y[i],ball.collision, 0) then
					ball.x[i] -= 1
					cat.x -= 1
				end
			end
		end
		--if col w/ cup, change cup
		if objcollision(cat.x+1,cat.y,cat.w,cat.h,
		cup.x,cup.y,cup.w,cup.h) then
			canmove = false
			if cup.frame == 38 then
				--if not already changed
				cup.frame = 54
				cup.flipped = true
				sfx(4) --water sfx
			end
		end
		for i = 1,4 do
			if objcollision(
				cat.x + 1, cat.y, cat.w, cat.h,
				fence.x[i], fence.y[i], fence.w, fence.h
			) then
				canmove = false
			end
		end
		--pos change if able:
		if canmove then cat.x+=1 end
		if mapCollision(cat.x, cat.y,cat.collision, 0) then cat.x-=1 end
		flist = {1, 3, 5}
		pose = 1
		cat.flipped = true --backwards ⬅️ sprite
	end
end

--rat movement
function rat_move()

	--checks what stage and thus what rat should be spawned
	if(stage_check(cat, house) == 1) then
		rat_num = 1
	elseif(stage_check(cat, house) == 5) then
		rat_num = 2
	else
		rat_num = 0
	end

	if(rat_num != 0) then --if the room should have a rat in it
		rat.x[rat_num] += rat.direction --changes x position

		--if it collides with map
		if(mapCollision(rat.x, rat.y, rat.collision, rat_num)) then
			rat.direction = -rat.direction --changes direction		
			sfx(3) --plays rat sound effects
			--flips rat		
			if rat.flipped then
				rat.flipped = false
			else
				rat.flipped = true
			end
		end
	end
end

--king rat movement
function kingrat_move()
	--checks what stage and thus whether the movement should be happening
	if(stage_check(cat, factory)==3  and cage.visible==false) then --if in rat boss room and cage hasn't come down yet
		kingrat.chase = true
	else
		kingrat.chase = false
	end

	if(kingrat.chase) then --if kingrat should be chasing cat/player
		--adjust kingrat's position based on x & y values compared to cat's
		if(cat.x < kingrat.x) then
			kingrat.x -= .4
			kingrat.flipped = false
		elseif(cat.x > kingrat.x) then
			kingrat.x += .4
			kingrat.flipped = true
		end

		if(cat.y < kingrat.y) then
			kingrat.y -= .4
		elseif(cat.y > kingrat.y) then
			kingrat.y += .4
		end
	end
end

--rat collision
function rat_collide() 
	if objcollision(rat.x[rat_num],rat.y[rat_num],rat.w,rat.h,
					cat.x,cat.y,cat.w,cat.h) then --if rat & cat collide
		if (ratcollided == false) then --if hasn't been colliding (1st impact)
			--get rid of 1 heart
			if (hearts.onscreen[3]) then
				hearts.onscreen[3]=false
			elseif (hearts.onscreen[2]) then
				hearts.onscreen[2]=false
			elseif (hearts.onscreen[1]) then
				hearts.onscreen[1]=false
				--Resets stage:
				game_init() --(Might need to alter this once game works with multiple stages)
			end
			sfx(1) -- plays damage sound effect
		end
		ratcollided = true --marks that they already impacted
	else --if rat & cat are not colliding
		ratcollided = false
	end
end

--kingrat collision
function kingrat_collide() 
	if objcollision(kingrat.x,kingrat.y,kingrat.w,kingrat.h,
					cat.x,cat.y,cat.w,cat.h) then --if kingrat & cat collide
		if (kingratcollided == false) then --if hasn't been colliding (1st impact)
			--get rid of 1 heart
			if (hearts.onscreen[3]) then
				hearts.onscreen[3]=false
			elseif (hearts.onscreen[2]) then
				hearts.onscreen[2]=false
			elseif (hearts.onscreen[1]) then
				hearts.onscreen[1]=false
				--Resets stage:
				game_init() --(CHANGE THIS TO JUST RESET BOSS ROOM)
			end
			sfx(1) -- plays damage sound effect
		end
		kingratcollided = true --marks that they already impacted
	else --if rat & cat are not colliding
		kingratcollided = false
	end
end
 
--[[by inputting the player(cat)
and the stage,this function checks
which screen/room the player is at.]]
function stage_check(p, s)
	local playertilex = flr(p.x / 128) * 16
	local playertiley = flr(p.y / 128) * 16
	local screen = 0

	if playertilex == s.rx[1]
			and playertiley == s.ry[1] then
		screen = 1 --starting room
	end
	if playertilex == s.rx[2]
			and playertiley == s.ry[2] then
		screen = 2 --central room
	end
	if playertilex == s.rx[3]
			and playertiley == s.ry[3] then
		screen = 3 --leftmost room
	end
	if playertilex == s.rx[4]
			and playertiley == s.ry[4] then
		screen = 4 --rightmost room
	end
	if playertilex == s.rx[5]
			and playertiley == s.ry[5] then
		screen = 5 --down from room3
	end
	if playertilex == s.rx[6]
			and playertiley == s.ry[6] then
		screen = 6 --down from room4
	end

	return screen
end

-- function for button puzzle
function colorcombo_house(p,b)
	local solved=false
	answer={"r","g","b","y"}

	if objcollision(p.x,p.y,p.w,p.h,
	b.x[1],b.y[1],b.w,b.h) and
	btnp(❎) then
	sfx(0)
		b.frame[1]=113
		add(attempt_h,"r")
		if(count(attempt_h)!=1) then
			deli(attempt_h) -- pops last item in list
			if(attempt_h[1] != "r") then
				reset_buttons(b)
				attempt_h = {}
			end
		end
	end
	
	if objcollision(p.x,p.y,p.w,p.h,
	b.x[2],b.y[2],b.w,b.h) and
	btnp(❎) then
		sfx(0)
		b.frame[2]=115
		add(attempt_h,"g")
		if(count(attempt_h)!=2) then
			deli(attempt_h)
			if(attempt_h[2] != "g") then
				reset_buttons(b)
				attempt_h = {}
			end
		end
	end
	
	if objcollision(p.x,p.y,p.w,p.h,
	b.x[3],b.y[3],b.w,b.h) and
	btnp(❎) then
	sfx(0)
		b.frame[3]=117
		add(attempt_h,"b")
		if(count(attempt_h)!=3) then
			deli(attempt_h)
			if(attempt_h[3] != "b") then
				reset_buttons(b)
				attempt_h = {}
			end
		end
	end
	
	if objcollision(p.x,p.y,p.w,p.h,
	b.x[4],b.y[4],b.w,b.h) and
	btnp(❎) then
	sfx(0)
		b.frame[4]=119
		add(attempt_h,"y")
		if(count(attempt_h)!=4) then
		 	deli(attempt_h)
			if(attempt_h[4] != "y") then
				reset_buttons(b)
				attempt_h = {}
			end
		end
	end
	
	if count(attempt_h)==4 and 
	cprtables(attempt_h,answer) then
		solved=true
	elseif count(attempt_h)>4 and
	cprtables(attempt_h,answer)==false then
		solved=false
		while count(attempt_h)>0 do
			deli(attempt_h)
		end
	else
		solved=false
	end
	
	return solved 
end

--[[resets all buttons from button
puzzle to not being pushed]]
function reset_buttons(b)
	b.frame[1]=112
	b.frame[2]=114
	b.frame[3]=116
	b.frame[4]=118
end

--[[Flower puzzle: Cat must match flowers to the answer table
to progress. Press X to change colors of the flowers. 
Press the button to confirm your attempted answer. (Still a WIP!)]]
function flower_puzzle(p,f,b)
	local solved=false
	local answer={"blue","ora","pink","pur"}
	
	--?could use a for loop for this?
	if objcollision(p.x,p.y,p.w,p.h,
	f.x[1],f.y[1],f.w,f.h) and btnp(❎) then
		flower_change(flower,1)
	end
	if objcollision(p.x,p.y,p.w,p.h,
	f.x[2],f.y[2],f.w,f.h) and btnp(❎) then
		flower_change(flower,2)
	end
	if objcollision(p.x,p.y,p.w,p.h,
	f.x[3],f.y[3],f.w,f.h) and btnp(❎) then
		flower_change(flower,3)
	end
	if objcollision(p.x,p.y,p.w,p.h,
	f.x[4],f.y[4],f.w,f.h) and btnp(❎) then
		flower_change(flower,4)
	end

	
	if objcollision(p.x,p.y,p.w,p.h,
	b.x[6],b.y[6],b.w,b.h) and btnp(❎) then
		if cprtables(attempt_f,answer) then
			solved=true
			--[[still needs to be implemented,
			 barrier disapppears]]
		else
			solved=false 
			--[[still needs to be implemented,
			flowers reset and "wrong answer" sfx plays]]
		end
	end
end

--cycles thru flower colors
function flower_change(f,n)
	--initial color
	attempt_f[n]="red"

	if f.frame[n]==210 then
	 f.frame[n]=212
	 attempt_f[n]="blue" --blue
	elseif f.frame[n]==212 then
	 f.frame[n]=214
	 attempt_f[n]="pink" --pink
	elseif f.frame[n]==214 then
	 f.frame[n]=216
	 attempt_f[n]="ora" --orange
	elseif f.frame[n]==216 then
	 f.frame[n]=218
	 attempt_f[n]="bro" --brown
	elseif f.frame[n]==218 then
	 f.frame[n]=220
	 attempt_f[n]="pur" --purple
	else
	 f.frame[n]=210
	 attempt_f[n]="red"
	end
end

-- function for king rat button puzzle
-- parameters: (cat, kingbtn)
function king_buttons(p,b)
	local solved = false
	king_answer = {"tl", "bl", "tr", "br"}

	if objcollision(p.x,p.y,p.w,p.h,
	b.x[1],b.y[1],b.w,b.h) and
	btnp(❎) then
		sfx(0)
		b.frame[1]=113
		add(attempt_king,"tl")
		if(count(attempt_king)!=1) then
			deli(attempt_king) -- pops last item in list
			if(attempt_king[1] != "tl") then
				reset_king_buttons(b)
				attempt_king = {}
			else
				kingbtn.litbtn = 0 --stops the button order indicators
				--turns all the other buttons back to yellow
				b.frame[2]=118
				b.frame[3]=118
				b.frame[4]=118
			end
		end
	end

	if objcollision(p.x,p.y,p.w,p.h,
	b.x[2],b.y[2],b.w,b.h) and
	btnp(❎) then
		sfx(0)
		b.frame[2]=113
		add(attempt_king,"bl")
		if(count(attempt_king)!=2) then
			deli(attempt_king) -- pops last item in list
			if(attempt_king[2] != "bl") then
				reset_king_buttons(b)
				attempt_king = {}
			end
		end
	end

	if objcollision(p.x,p.y,p.w,p.h,
	b.x[3],b.y[3],b.w,b.h) and
	btnp(❎) then
		sfx(0)
		b.frame[3]=113
		add(attempt_king,"tr")
		if(count(attempt_king)!=3) then
			deli(attempt_king) -- pops last item in list
			if(attempt_king[3] != "tr") then
				reset_king_buttons(b)
				attempt_king = {}
			end
		end
	end

	if objcollision(p.x,p.y,p.w,p.h,
	b.x[4],b.y[4],b.w,b.h) and
	btnp(❎) then
		sfx(0)
		b.frame[4]=113
		add(attempt_king,"br")
		if(count(attempt_king)!=4) then
			deli(attempt_king) -- pops last item in list
			if(attempt_king[4] != "br") then
				reset_king_buttons(b)
				attempt_king = {}
			end
		end
	end

	if count(attempt_king)==4 and 
	cprtables(attempt_king,king_answer) then
		solved=true
	elseif count(attempt_king)>4 and
	cprtables(attempt_king,king_answer)==false then
		solved=false
		while count(attempt_king)>0 do
			deli(attempt_king)
		end
	else
		solved=false
	end
	
	return solved 
end

--resets all buttons from king button puzzle to not being pushed
--parameter: kingbtn
function reset_king_buttons(b)
	b.frame[1]=118
	b.frame[2]=118
	b.frame[3]=118
	b.frame[4]=118

	kingbtn.litbtn = 1 --resumes the button order indicators
end

--compares 2 four-indexed tables
function cprtables(t1,t2)
	local a=false
	local b=false
	local c=false
	local d=false
	local match=false
	
	if t1[1]==t2[1] then a=true end
	if t1[2]==t2[2] then b=true end
	if t1[3]==t2[3] then c=true end
	if t1[4]==t2[4] then d=true end
	if a and b and c and d then match=true end
	
	return match
end

--[[magic sign puzzle:
signs turn green when correct
ball is placed]]
function housesigns(b,m,d)
	local sign1=false
	local sign2=false
	
	if objcollision(b.x[1],b.y[1],b.w,b.h,
	m.x[1],m.y[1],m.w,m.h) then
		sign1=true
		m.frame[1]=30
	else
		sign1=false
		m.frame[1]=29
	end
	if objcollision(b.x[2],b.y[2],b.w,b.h,
	m.x[2],m.y[2],m.w,m.h) then
		sign2=true
		m.frame[2]=14
	else
		sign2=false
		m.frame[2]=13
	end
	
	if objcollision(cat.x,cat.y,cat.w,cat.h,
	pushbtn.x[5],pushbtn.y[5],pushbtn.w,pushbtn.h) and
	btnp(❎) then
		--[[resets balls when button is pressed.
		meant to make a function for this]]
		b.x[1]=88
		b.y[1]=88
		b.x[2]=32
		b.y[2]=88
	end
	
	if sign1 and sign2 then
		d.unlocked = true
		d.frame = {91,75,92,76}
		if doorOpenSFX then 
			sfx(2)
			doorOpenSFX = false
		end
	else
		d.unlocked = false
		d.frame = {89,73,90,74}
	end
end

--returns true if 2 objs collided
function objcollision(x1, y1, w1, h1, x2, y2, w2, h2)
	--pos, width obj2

	local hit = false

	--collision distance:
	local coldisx = (w1 * .5) + (w2 * .5)
	local coldisy = (h1 * .5) + (h2 * .5)

	--current distances each axis:
	local curdisx = abs((x1 + (w1 / 2)) - (x2 + (w2 / 2)))
	local curdisy = abs((y1 + (h1 / 2)) - (y2 + (h2 / 2)))

	if curdisx < coldisx and curdisy < coldisy then
		hit = true
	end

	return hit
end
--returns true if colliding with edge tile
function mapCollision(objx, objy, objcollision, num) --num is index of location in list of locations (0 means that x & y coordinates are not in list form)
	local d = false --is colliding left
	local c = false --is colliding bottom
	local b = false --is colliding right
	local a = false --is colliding top

	local x1 = 0 --left bound
	local y1 = 0 --top bound
	local x2 = 0 --right bound
	local y2 = 0 --bottom bound
	
	-- get coords of object
	if (num == 0) then
		x1 = (objx+7)/8 --left bound
		y1 = (objy+15)/8 --top bound
		x2 = (objx+23)/8 --right bound
		y2 = (objy+23)/8 --bottom bound
	else
		x1 = (objx[num]+7)/8 --left bound
		y1 = (objy[num]+15)/8 --top bound
		x2 = (objx[num]+23)/8 --right bound
		y2 = (objy[num]+23)/8 --bottom bound
	end
	d = fget(mget(x1, y1), 0) --check if the next tile has flag 0 set
	c = fget(mget(x1, y2), 0)
	b = fget(mget(x2, y1), 0)
	a = fget(mget(x2, y2), 0) 
	if objcollision then
		if a or b or c or d then --if there will be a collision
			return true
		else 
			return false
		end
	else
		return false
	end
end
-->8
--[draw tab]

--debug - comment out if unneeded
function debug_draw()
	print(cat.x,cat.x,cat.y,8)
	print(cat.y,cat.x+16,cat.y,1)
	print(level,cat.x,cat.y+16,9)
	print(stage_check(cat,forest),cat.x+16,cat.y+24,12)
end

--draws end screen
function end_draw()
	cls()
	map(1, 18, 0, 0, 128, 64)
	print("furball productions presents", 9, 20, 6)
	print("protect your catsle", 26, 55, 1)
	print("thanks for playing!", 32, 102, 10)
	print("press ❎ to replay", 32, 120, 10)
	spr(flist[flr(frame)], 55, 75, 2, 2)
end

--draws title screen stuff
function title_draw()
	cls()
	map(1, 18, 0, 0, 128, 64)
	print("furball productions presents", 9, 20, 6)
	print("protect your catsle", 26, 55, 1)
	print("press ❎ to start", 32, 102, 10)
	print("⬆️⬇️⬅️➡️ - move, ❎ - interact",4.5,118,6)
	spr(flist[flr(frame)], 55, 75, 2, 2)
	--cat sprite
end

--draws first room map
function map_draw()
	cls(12)
	map(1, 1, 0, 0, 128, 64)
	--draws map
	room_cam(cat)
	interact_draw()
	player_draw()
	props_draw()
	rat_draw()
	--debug_draw()

	if ycircle.visible then
		ycircle_draw()
	end

	kingrat_draw()
	hearts_draw()
	
	if cage.visible then
		cage_draw()
	end

	if showend==true then
		cls()
		print("you escaped the house!",275,56)
	end
end

function player_draw()
	--🐱 cat sprite:
	spr(flist[flr(frame)], cat.x, cat.y, cat.size, cat.size, cat.flipped)
	--flr rounds down to nearest int
	--gets item 1-3 from flist
	--spr(framenum,x,y,framesize,framesize,flipped?)
end

function hearts_draw()
	--hearts sprites:
	if (hearts.onscreen[1]) then
		spr(62, hearts.x[1], hearts.y, hearts.size, hearts.size)
	end
	if (hearts.onscreen[2]) then
		spr(62, hearts.x[2], hearts.y, hearts.size, hearts.size)
	end
	if (hearts.onscreen[3]) then
		spr(62, hearts.x[3], hearts.y, hearts.size, hearts.size)
	end

end

function rat_draw()
	--rat sprite
	if (ratcollided == false) then 
		spr(61, rat.x[rat_num], rat.y[rat_num], rat.size, rat.size, rat.flipped)
	else
		spr(63, rat.x[rat_num], rat.y[rat_num], rat.size, rat.size, rat.flipped)
	end
end

function kingrat_draw()
	--kingrat sprite
	spr(150, kingrat.x, kingrat.y, kingrat.size, kingrat.size, kingrat.flipped)
end

--draws yellow circle indicating where king rat should go
function ycircle_draw()
	spr(154, 828, 190, 1, 1) --draws smaller yellow circle (collision happens with this one)
	--spr(152, 825, 190, 2, 2)
	spr(152, ycircle.x, ycircle.y, ycircle.size[1], ycircle.size[1]) --draws larger yellow circle
end

--draws cage
function cage_draw()
	spr(155, cage.x, cage.y, cage.size, cage.size)
end

function props_draw()
	--chairs in blue room
	spr(chair.frame,chair.x[3],chair.y[3],2,2)
	spr(chair.frame,chair.x[4],chair.y[4],2,2,true)
	--chairs in yellow room
	spr(chair.frame,chair.x[1],chair.y[1],2,2)
	spr(chair.frame,chair.x[2],chair.y[2],2,2)
	spr(chair.frame,chair.x[5],chair.y[5],2,2,true)
	--chair in green room
	spr(chair.frame,chair.x[6],chair.y[6],2,2)
	--balls in spawn room
	spr(44, ball.x[1], ball.y[1], 1, 1)
	spr(60, ball.x[2], ball.y[2], 1, 1)
	--fence in flower puzzle (still needs work)
	spr(fence.frame,fence.x[1],fence.y[1],1,1)
	spr(fence.frame,fence.x[2],fence.y[2],1,1)
	spr(fence.frame,fence.x[3],fence.y[3],1,1)
	spr(fence.frame,fence.x[4],fence.y[4],1,1)
	
	--cup sprite:
	spr(cup.frame, cup.x, cup.y, cup.size, cup.size, cup.flipped)
	--water sprite:
	if cup.frame == 54 then
		if cup.flipped then
			spr(39,232,26,1,1,true)
		else
			spr(39,216,26,1,1)
		end
	end
end

function interact_draw()
	--door
	spr(door.frame[1], door.x[1], door.y[1])
	spr(door.frame[2], door.x[2], door.y[2])
	spr(door.frame[3], door.x[3], door.y[3])
	spr(door.frame[4], door.x[4], door.y[4])
	--puzzle door
	spr(door2.frame[1],door2.x[1],door2.y[1])
	spr(door2.frame[2],door2.x[2],door2.y[2])
	spr(door2.frame[3],door2.x[3],door2.y[3])
	spr(door2.frame[4],door2.x[4],door2.y[4])
	--magic sign
	spr(msign.frame[1],msign.x[1],msign.y[1], msign.size, msign.size)
	spr(msign.frame[2],msign.x[2],msign.y[2],msign.size,msign.size)
	--buttons
	spr(pushbtn.frame[1],pushbtn.x[1],pushbtn.y[1],pushbtn.size,pushbtn.size)
	spr(pushbtn.frame[2],pushbtn.x[2],pushbtn.y[2],pushbtn.size,pushbtn.size)
	spr(pushbtn.frame[3],pushbtn.x[3],pushbtn.y[3],pushbtn.size,pushbtn.size)
	spr(pushbtn.frame[4],pushbtn.x[4],pushbtn.y[4],pushbtn.size,pushbtn.size)
	spr(pushbtn.frame[5],pushbtn.x[5],pushbtn.y[5],pushbtn.size,pushbtn.size)
	spr(pushbtn.frame[6],pushbtn.x[6],pushbtn.y[6],pushbtn.size,pushbtn.size)
	--flowers
	spr(flower.frame[1],flower.x[1],flower.y[1],flower.size,flower.size)
	spr(flower.frame[2],flower.x[2],flower.y[2],flower.size,flower.size)
	spr(flower.frame[3],flower.x[3],flower.y[3],flower.size,flower.size)
	spr(flower.frame[4],flower.x[4],flower.y[4],flower.size,flower.size)
	--king rat room buttons
	spr(kingbtn.frame[1],kingbtn.x[1],kingbtn.y[1],kingbtn.size,kingbtn.size)
	spr(kingbtn.frame[2],kingbtn.x[2],kingbtn.y[2],kingbtn.size,kingbtn.size)
	spr(kingbtn.frame[3],kingbtn.x[3],kingbtn.y[3],kingbtn.size,kingbtn.size)
	spr(kingbtn.frame[4],kingbtn.x[4],kingbtn.y[4],kingbtn.size,kingbtn.size)
end

--changes the camera to whichever screen/room...
--the player is moving towards to.
function room_cam(p)
	local mapx = flr(p.x/128)*16 
	local mapy = flr(p.y/128)*16
	camera(mapx*8,mapy*8)

	--changes hearts to the corner of whichever screen/room player goes to
	hearts.x[1] = mapx*8 + 2;
	hearts.x[2] = mapx*8 + 10;
	hearts.x[3] = mapx*8 + 18;
	hearts.y = mapy*8 + 2;
end
__gfx__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000f000000088880000bbbb0000000000
00000000000000000000000000000000000000000f0000f00000000000000f0000f00000000000000000000000000ff77ff00000080000800b0000b000000000
007007000f0000f00000000000000000000000000ff77ff000000f0000000ff77ff0000000000f0000f0000000000ff77ff0000080000008b000000b00000000
000770000ff77ff000000f000f0000f0000000000f77fff00000f0f000000ff77ff0000000000ff77ff0000000000fa77af0000088888888bbbbbbbb00000000
000770000f77fff00000f0f00ff77ff0000000000a7afff00000007000000fa77af0000000000ff77ff00000000007f77f70000088888888bbbbbbbb00000000
007007000a7afff0000000700f77fff00000ff000f777ff100000770000007f77f70000000000fa77af00000000000777700000080000008b000000b00000000
000000000f777ff1000007700a7afff0000f00700777771fffff77700000007777000000000007f77f7000000000001111000000080000800b0000b000000000
000000000777771fffff77700f777ff10000077000111177fff777000000001111000000000000777700000000000ff77ff000000088880000bbbb0000000000
0000000000111177fff777000777771fffff7770000777777f77700000000ff77ff00000000000111100000000000f7777f000000088880000bbbb0000000000
00000000000777777f77700000111177fff77700000777777777700000000f7777f0000000000ff77ff000000000077777700000080000800b0000b000000000
000000000007777777777000000777777f7770000007777777777700000007777770000000000f7777f00000000007777770000088000088bb0000bb00000000
0000000000077777777777000007777777777700000ff0ff07f07f000000077777700000000007777770000000000ff00ff0000080800808b0b00b0b00000000
00000000000f707f077077000007777777777700000000000000000000000f7007f000000000077777700000000000000000000080800808b0b00b0b00000000
000000000000f0f000f00f000000f0f000f00f000000000000000000000000f00f000000000000f00f000000000000000000000088000088bb0000bb00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000800b0000b000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088880000bbbb0000000000
0000000000000000000000000000000000000f0000f00000ffffffff000000000666666006666660000006666666666000000000000066666666666000000000
00000f0000f00000000000000000000000000ff77ff000008888888800000000088888800bbbbbb0000006666666666000999900000666666666666000000000
00000ff77ff0000000000f0000f0000000000f7777f0000088888888000000000686686006b66b60000006666666666007999970006666666666606000000000
00000f7777f0000000000ff77ff000000000077ff7700000888888880000000006688660066bb660000006666666666009799790066666666666006000000000
0000077ff770000000000f7777f0000000000077f7000000088888800000000006688660066bb660000006666666666009799790060060000006000000000000
00000077f7000000000007777770000000000017710000000888888000000ccc0686686006b66b60000006666666666007999970060000000006000000000000
00000017710000000000007ff7000000000007f77f7000000088880000cccccc088888800bbbbbb0000006666666666000999900060000000006000000000000
00000ff77ff0000000000017f1000000000007777770000000888800cccccccc0666666006666660000000000000000000000000060000000006000000000000
00000f7777f0000000000ff77ff0000000000777777000007888000000000000085555800b5555b0000066666666666000000000000000000000000000044400
000007777770000000000f7777f000000000077777700000788888000000000086666668b666666b000666666666666000eeee00000044400088088000e48440
0000077777700000000007777770000000000f7007f0000078888888000000005686686556b66b6500666666666660600eeeeee0004444440888888800044444
000007700770000000000777777000000000000000000000788888880000000056688665566bb665066666666666006007777770048444440088888006664444
00000f0000f0000000000f0000f000000000000000000000788888880000000056688665566bb665060060000006006007777770e44444440008880000004444
00000000000000000000000000000000000000000000000078888888000000005686686556b66b6506000000000600000eeeeee00000000e0000800000000444
000000000000000000000000000000000000000000000000788888000000000086666668b666666b060000000006000000eeee00000eeeee000000000000000e
0000000000000000000000000000000000000000000000007888000000000000085555800b5555b006000000000600000000000000000000000000000000eeee
dd444444dd444444444444dd4444444444444444444444dd22222222dddddddd99944999dddddddddddddddddddddddddddddddddddddddddddddddd55555555
dd444444dd444444444444dd4444444444444444444444dd22222222dddddddd99499499dddddddddddddddddddddddddddddddddddddddddddddddd50000075
dd444444dd444444444444dd4444444444444444444444dd22222222dddddddd94999949dd444444444444dddd447777777777ddff444444444444ff50007705
dd555555dd555555555555dd5555555555555555555555dd22255222dddddddd44999944dd444444444444dddd447777777777ddf44444444444444f50000705
dd444444dd444444444444dd4444444444444444444444dd22255222dddddddd44999944dd644444444444dddd647777777777dd444444444444444450000005
dd444444dd444444444444dd4444444444444444444444dd22222222dddddddd94999949dd644444444444dddd647777777777dd444444444444444457000005
dd444444dddddddddddddddd44444444dddddddd444444dd22222222dddddddd99499499dd444444444444dddd447777777777dd444444444444444457700005
dd444444dddddddddddddddd44444444dddddddd444444dd22222222dddddddd99944999dd444444444444dddd447777777777ddffffffffffffffff55555555
11111111ffffffff111111dddd11111111111111788888878888888833333333bbbbbbbbdd444444444444dddd447777777777ddf44444444444444f76666666
11111111ffffffff111551dddd15511111155111878888788888888833333333bbbbbbbbdd444444445554dddd447777777777ddf44445444454444f66555556
11111111ffffffff115555dddd55551111555511887777888888888833333333bbbbbbbbdd444444444484dddd447777777777ddf44445444454444f65555556
11111111ffffffff155555dddd555551155555518878878888822888333bb333bbb33bbbdd444444444444dddd447777777777ddf44445444454444f65555557
11111111ffffffff155555dddd555551155555518878878888822888333bb333bbb33bbbdd644444444444dddd647777777777ddf44444444444444f65555557
11111111ffffffff115555dddd55551111555511887777888888888833333333bbbbbbbbdd644444444444dddd647777777777ddffffffffffffffff65555557
11111111ffffffff111551dddd15511111155111878888788888888833333333bbbbbbbbdd444444444444dddd447777777777dd111551111115511165555577
1111111111111111111111dddd11111111111111788888878888888833333333bbbbbbbbdd555555555555dddd557777777777dd11111111111111116667777d
4f4444444555545555555555d5555555555555555555555d55555555d55555555555555d3b33b3b333b333b3433bbb3b333bb33bddddddd666ddddddbbbbbbbb
444444f4d5d5555dd555555dd5555555555555555555555d55555555d55555555555555d3333a33b3a3333ba4b3bb33bbb3bbb3bdddd8dd66ddcddddb33bb3bb
444444444554555577777777d5555555555555555555555d55555555d55555555555555d333b3333b33333334bbbb3bbbbbbbbbbff47887667cc74ffbb3bbb3b
444444445555554577777777d5555555555555555555555d55555555d55555555555555db3333ab3333333334bbbbbbbbbbbbbbbf47666566566674fbbbbbb3b
4444444454d5555577777777d5555555555555555555555d55555555d55555555555555d3b3b3333b3b33bb34b3b33bbbbbbbbb34476655555566744b3bbbbbb
4f444444d55555dd77777777d5555555555555555555555d55555555d55555555555555d3a333333bab33a3b4b3b333bbb33b3334476555555556744bb3bbb33
44444ff45554555545555554d5555555555555555555555d55555555d55555555555555d3b33b3b3333333334bbbbbbbbbb3b3bb4446666666666444bb3bbb3b
44444f445d555d5455555555d555555555555555dddddddddddddddddddddddd5555555db333333b444444444444444444444444ffffffffffffffffbbb3bb3b
00000000000000000000000000000000000000000000000000000000000000000000000066666666566666668888888998888888f44444444444444fbbbbbbbb
000000000000000000000000000000000000000000000000000000000000000000000000655555565ddddd768888888998888888f44445444454444fbc3bb3bb
008888000000000000bbbb0000000000001111000000000000aaaa000000000000555500655555565dddddd68888888998888888f44445444454444fcacbeb3b
08888880008888000bbbbbb000bbbb0001111110001111000aaaaaa000aaaa0005555550655555565dddddd6888aa889988aa888f44445444454444fbcbeae3b
68888886688888866bbbbbb66bbbbbb661111116611111166aaaaaa66aaaaaa665555556655555565dddddd6888aa889988aa888f44444444444444fb3bbebdb
68888886688888866bbbbbb66bbbbbb661111116611111166aaaaaa66aaaaaa665555556655555565dddddd68888888998888888ffffffffffffffffb93bbdad
066666600666666006666660066666600666666006666660066666600666666006666660655555565dddddd6888888899888888811155111111551119a9bbbdb
000000000000000000000000000000000000000000000000000000000000000000000000666666665566666688888889988888881111111111111111b9b3bb3b
74747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474
7497979706060606161606060606979797a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7f5f5f52cf5f5f54646f5f5f52cf5f5f5000000000005000000000000000000
74747474747474747474747474747474740000000000000000000000000000001515151515151515151515151515151515150000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000
74747474747474747474747474747474740000000000000000000000000000001515151515151515151515151515151515150000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000005000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d111111ddd1111dd111111111111111d11dddd11dd11111100000000000000000000aaaaaaaa0000000000007777777777777777000000000000000000000000
1111111dd111111d111111111111111d11dddd11d11111110000000000000000000aaaaaaaaaa000000000007777777777777777000000000000000000000000
11dddddd11dddd11ddd11ddd11ddd11d111dd111d1dddddd00a0a0a00444440000aaaaaaaaaaaa00000aa0007007007007007007000000000000000000000000
11dddddd11111111ddd11ddd1111111dd11dd11dd111111d00aaaaa0444444400aaaaaaaaaaaaaa000aaaa007007007007007007000000000000000000000000
11dddddd11111111ddd11ddd11111dddd11dd11ddd11111100aaaaa444444444aaaaaaaaaaaaaaaa00aaaa007007007007007007000000000000000000000000
11dddddd11dddd11ddd11ddd11d111dddd1111ddddddddd10044444444444444aaaaaaaaaaaaaaaa000aa0007007007007007007000000000000000000000000
1111111d11dddd11ddd11ddd11dd111ddd1111ddd11111110448444444444444aaaaaaaaaaaaaaaa000000007007007007007007000000000000000000000000
d111111d11dddd11ddd11ddd11ddd11dddd11dddd111111de444444444444444aaaaaaaaaaaaaaaa000000007007007007007007000000000000000000000000
0000000000000000000000000000000000000000000000000444444444444444aaaaaaaaaaaaaaaa000000007007007007007007000000000000000000000000
000000000000000000000000000000000000000000000000000444444444444eaaaaaaaaaaaaaaaa000000007007007007007007000000000000000000000000
000000000000000000000000000000000000000000000000000004e4444e400eaaaaaaaaaaaaaaaa000000007007007007007007000000000000000000000000
0000000000000000000000000000000000000000000000000000eee00eee000eaaaaaaaaaaaaaaaa000000007007007007007007000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000e0aaaaaaaaaaaaaa0000000007007007007007007000000000000000000000000
00000000000000000000000000000000000000000000000000000000000eeeee00aaaaaaaaaaaa00000000007007007007007007000000000000000000000000
000000000000000000000000000000000000000000000000000000eeeeee0000000aaaaaaaaaa000000000007007007007007007000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000aaaaaaaa0000000000007007007007007007000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444ffffffff68999986a11555555555511aa9a9a9a99a9a9a9aa9a9a9a95555511aa1155555655555561111111166666666ddddddd11111111100055000
44444444ffffffff6889a986911555555555511991111111111111191111111155555119911555556dddddd6111111115d55d55dddddddd1ddddddd100544600
44444444ffffffff688aa856a11555555555511aa11111111111111a111111115555511aa11555556dddddd6111111115d55d55dddddddd1ddddddd105444460
44444444ffffffff658aa8569115555555555119911555555555511955555555555551199115555565555556111111115d55d55dddddddd1ddddddd105444460
44444444ffffffff65444456a11555555555511aa11555555555511a555555555555511aa11555556dddddd6111111115d55d55dddddddd1ddddddd105444450
44444444ffffffff65544556911555555555511991155555555551195555555555555119911111116dddddd6111111115d55d55dddddddd1ddddddd105444450
44444444ffffffff65544556a11555555555511aa11555555555511a555555555555511aa1111111655555561111111166666666ddddddd1ddddddd105444450
4444444444444444665445669115555555555119911555555555511955555555555551199a9a9a9a6dddddd61111111166666666ddddddd1ddddddd105444450
dd666666666666dd00000008800000000000000cc00000000000000ee0000000000000099000000000000004400000000000000dd00000000000000000000000
dd666666666666dd0000008888000000000000cccc000000000000eeee00000000000099990000000000004444000000000000dddd0000000000000000000000
dd666666666666dd0000008888000000000000cccc000000000000eeee00000000000099990000000000004444000000000000dddd0000000000000000000000
dd688888888886dd00008808808800000000cc0cc0cc00000000ee0ee0ee0000000099099099000000004404404400000000dd0dd0dd00000000000000000000
dd688888888886dd0008888aa8888000000ccccaacccc000000eeeeaaeeee0000009999aa99990000004444aa4444000000ddddaadddd0000000000000000000
dd666666666666dd0008888aa8888000000ccccaacccc000000eeeeaaeeee0000009999aa99990000004444aa4444000000ddddaadddd0000000000000000000
dd666666666666dd00008808808800000000cc0cc0cc00000000ee0ee0ee0000000099099099000000004404404400000000dd0dd0dd00000000000000000000
dd666666666666dd0000008888000000000000cccc000000000000eeee00000000000099990000000000004444000000000000dddd0000000000000000000000
dd688888888886dd0000008888000000000000cccc000000000000eeee00000000000099990000000000004444000000000000dddd0000000000000000000000
dd688888888886ddbbbbbbb88bbbbbbbbbbbbbbccbbbbbbbbbbbbbbeebbbbbbbbbbbbbb99bbbbbbbbbbbbbb44bbbbbbbbbbbbbbddbbbbbbb0000000000000000
dd666666666666ddb3bbbbb33bbb33bbb3bbbbb33bbb33bbb3bbbbb33bbb33bbb3bbbbb33bbb33bbb3bbbbb33bbb33bbb3bbbbb33bbb33bb0000000000000000
dd666666666666ddbb3bb333333bbb3bbb3bb333333bbb3bbb3bb333333bbb3bbb3bb333333bbb3bbb3bb333333bbb3bbb3bb333333bbb3b0000000000000000
dd666666666666ddbbbbbb3333bb3bbbbbbbbb3333bb3bbbbbbbbb3333bb3bbbbbbbbb3333bb3bbbbbbbbb3333bb3bbbbbbbbb3333bb3bbb0000000000000000
dd688888888886ddbbbb3bb33bbb3bbbbbbb3bb33bbb3bbbbbbb3bb33bbb3bbbbbbb3bb33bbb3bbbbbbb3bb33bbb3bbbbbbb3bb33bbb3bbb0000000000000000
dd688888888886ddbb3bb3b33bb3bbbbbb3bb3b33bb3bbbbbb3bb3b33bb3bbbbbb3bb3b33bb3bbbbbb3bb3b33bb3bbbbbb3bb3b33bb3bbbb0000000000000000
dd666666666666ddb3bb3bb33bbbbb3bb3bb3bb33bbbbb3bb3bb3bb33bbbbb3bb3bb3bb33bbbbb3bb3bb3bb33bbbbb3bb3bb3bb33bbbbb3b0000000000000000
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

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100010100010000000000000001000000000000000000000000000101010000000000000000000100000000000000000000000000000001010000010100
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747696969696969696f6f6f6f696969696969696969696f6f6f6f6969696969696969696969696969696969696960606069000000000000000000000000000000
4747474747474747474747474747474747474f4f474747474747474747474f4f47474f4f474747474747474747474f4f47474f4f474747474747474747474f4f47696969696969696f6f6f6f696969696969696969696f6f6f6f6969696969696969696969696969696969696960606069000000000000000000000000000000
47474747474747474747474747474747474747474d4e4d4e6d6e4d4e4d4e474747474747474747474747474747474747474747474747474747474747474747474769696f6f6f6f6f6f6f6f6f6f6f6f6f6969697f7f7f6f6f6f6f7f7f7f7f696969696f7f6f6f6f6f6f6f6f6f6f60606069000000000000000000000000000000
47474343434343434343434343434343474754545d5e5d5e7d7e5d5e5d5e5454474743434343434343434343434343434747434343434343434343434343434347696f6f6f6f6f6f6f6f6f6f6f6f6f6f6969697f7f6f6f6f6f6f6f6f6f7f7f7f69697f7f6f6f6f6f6f6f6f6f6f60606069000000000000000000000000000000
4747434343434343434343434343434347475454545454545454545454545454474743434343434343434343434343434747434343434343434343434343434347696f6f6f6f6f6f6f6f6f6f6f6f6f6f69697f7f6f6f6f6f6f6f6f6f6f6f6f7f69697f7f6f6f6f6f6f6f6f6f6f60606069000000000000000000000000000000
4747434646464646464646464646464347475454545454545454545454545454474743434343434343434343434343434747434343434343434343434343434347696f6f6f6f6f6f6f6f6f6f6f6f6f6f69697f6f6f6f7f7f7f7f7f7f6f6f6f7f69696f6f6f6f6f6f6f6f6f6f6f60606069000000000000000000000000000000
4747434646464646464646464646464347475454545454545454545454545454474743434343434343434343434343434747434343434343434343434848484347696f6f6f6f6f6f6f6f6f6f6f6f6f6f69697f6f6f7f7f7f7f7f7f7f7f6f6f7f69696f6f6f6f6f6f6f6f6f6f6060606069000000000000000000000000000000
4747434646464646464646464646464347475454545454545454545454545454474743434343434343434343434343434747434343434343434343434848484347696f6f6f6f6f6f6f6f6f6f6f6f6f6f69697f6f6f7f7f7f6f6f7f7f7f6f6f7f69696f6f6f6f6f6f606060606060606069000000000000000000000000000000
4747434646464646464646464646464347475454545454544343434343434343434343434343434343434343434343434343434343434343434343434848484347696f6f6f6f6f6f6f6f6f6f6f6f6f6f69697f6f6f7f7f7f6f6f7f7f7f6f6f7f69696f6f6f6f60606060606060606f6f69000000000000000000000000000000
4747434646464646464646464646464347475454545454434343434343434343434343434343434343434343434343434343434343434343434343434848484347696f6f6f6f6f6f6f6f6f6f6f6f6f6f69697f6f6f7f7f7f6f6f7f7f7f6f6f7f69696f6f6f6f6060606f6f6f6f6f6f6f69000000000000000000000000000000
4747434646464646464646464646464347475454545443434343434343434343434343434343434343434343434343434343434343434343434343434848484347696f6f6f6f6f6f6f6f6f6f6f6f6f6f69697f6f6f7f7f7f7f7f7f7f7f6f6f7f69696f6f6f6f60606f6f6f6f6f6f6f6f69000000000000000000000000000000
4747434646464646464646464646464347475454544343434343434343434343474743434343434343434343434343434747434343434343434343434848484347696f6f6f6f6f6f6f6f6f6f6f6f6f6f69697f6f6f6f7f7f7f7f7f7f6f6f6f7f69696f6f6f6060606f6f6f6f6f6f6f6f69000000000000000000000000000000
4747434646464646464646464646464347475454434343434343434343434343474743434343434343434343434343434747434343434343434343434343434347697f7f7f7f6f6f60606f6f6f7f7f7f69697f7f6f6f6f6f6f6f6f6f6f6f7f7f69696f6f6f6060606f6f6f6f6f6f6f6f69000000000000000000000000000000
4747434646464646464646464646464347475443434343434343434343434343474743434343434343434343434343434747434343434343434343434343434347697f7f7f7f6f606060606f6f7f7f7f69697f7f7f6f6f6f6f6f6f6f6f7f7f7f69696060606060606f6f6f6f7f7f6f6f69000000000000000000000000000000
4747434646464646464646464646464347474343434343434343434343434343474743434343434343434343434343434747434343434343434343434343434347697f7f7f7f6f606060606f6f7f7f7f696969696f6f6f6f6f6f6f6f6f6f6f6969696060606060606f6f6f6f7f7f6f6f69000000000000000000000000000000
4747434343434343434343434343434347474343434343434343434343434343474743434343434343434343434343434747434343434343434343434343434347696f6f6f6f6f606060606f6f6f6f6f69696969696969696f6f6f6f6969696969696060606060606f6f6f6f6f6f6f6f69000000000000000000000000000000
47474747474747474747474747474747474747474747474343434347474747474747474747474743434343474747474747474747474747434343434747474747476a69696969696060606069696969696a696969696969696f6f6f6f6969696969696060606060606f6969696969696969000000000000000000000000000000
4747474747474747474747474747474747474747474747434343434747474747474747474747474343434347474747474747474747474743434343474747474747797979797979797979797979797979797a7a7a7a7a7a7a7a7a7ad0d17a7a7a7a5f5f5fc25f5f5f5f5f5f5f5fc25f5f5f000000000000000000000000000000
4747474747474747474747474747474747474747474747434343434747474747474747474747474343434347474747474747474747474743434343474747474747796261626162616261626162616261797a7a7a7a7a7a7a7a7a7ae0e17a7a7a795f5f5f5f5f5f5f50505f5f5f5f5f5f5f000000000000000000000000000000
4747474747474747474747474747474747474343434343434343434343434343474743434343434343434343434343434747434343434343434343434343434347796261626162616261626162616261797ace64646464646464646464646464795f64646464645050505064646464645f000000000000000000000000000000
4747474747474747474747474747474747474343434343434343434343434343474743434343434343434343434343434747434343434343434343434343434347796261626162616261626162616261797acd64646464646464646464646464795f64646464646451516464646464645f000000000000000000000000000000
4747474747474747474747474747474747474343434343434343434343434343474743464646464646464646464646434747434343434343434343434343434347796261626162616261626162616261797acd6464646464646464646464646479c26464646464647c7b646464646464c2000000000000000000000000000000
4747474747474747474747474747474747474343434343434343434343434343474743464646464646464646464646434747435555555555555555555555554347796161616161616161616161616161797acb64646464646464646464646464795f6464646464647c7b6464646464645f000000000000000000000000000000
474747479091924794954793919247474747434343435858585858584343434347474346464646464646464646464643474743555656565656565656565655434779616161616161616161616161616161646464646464646464646464646464795f6464646464647c7b6464646464645f000000000000000000000000000000
474747474747474747474747474747474747434343585757575757575843434347474346464646464646464646464643474743555656565656565656565655434779616161616161616161616161616161646464646464646464646464646464795f6464646464647c7b6464646464645f000000000000000000000000000000
47474747474747474747474747474747474743435857575757575757575843434747434646464646464646464646464347474355565656565656565656565543477961616161616161616161616161616164646464646464646464646464cacb795f6464646464647c7b6464646464645f000000000000000000000000000000
47474747474747474747474747474747474743435857575757575757575843434747434646464646464646464646464347474355565656565656565656565543477961616161616161616161616161616164646464646464646464646464cacb795f6464646464647c7b6464646464645f000000000000000000000000000000
4747474747474747474747474747474747474343585757575757575757584343474743464646464646464646464646434747435556565656565656565656554347796161616161616161616161616161797ace6464646464646464646464cacb79c26464646464647c7b646464646464c2000000000000000000000000000000
4747474747474747474747474747474747474343435857575757575758434343474743464646464646464646464646434747435556565656565656565656554347796261626162616261626162616261797acd64c5c7c7c7c7c7c7c66464cacb795f6464646464647c7b6464646464645f000000000050000000000000000000
4747474747474747474747474747474747474343434358585858585843434343474743464646464646464646464646434747435555555555555555555555554347796261626162616261626162616261797acd64c3646464646464c86464cacb795f6464646464647c7b6464646464645f000000000050000000000000000000
4747474747474747474747474747474747474343434343434343434343434343474743464646464646464646464646434747434343434343434343434343434347796261626162616261626162616261797acb64c3ccccccccccccc86464cacb795f6464646464647c7b6464646464645f000000000050000000000000000000
4747474747474747474747474747474747474343434343434343434343434343474743434343434343434343434343434747434343434343434343434343434347796261626162616261626162616261797a6464c3cbcbcbcbcbcbc864646464795f6464646464647c7b6464646464645f000000000050000000000000000000
__sfx__
0001000000000000002a0502b0502f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00021f02000503a0500305005050070502f0500b0502c0500b0500c0500e0500e0501005013050150501705018050190501b0501f0502205024050270502c05031050370503c0503e0503f0503e0503f05000000
4e040000276501f650006002b7002760000600106002b650356500260002600036001d600216001e60002700206001e60000600056000160020600296002e6000000000000000000000000000000000000000000
660223021b0501f050230501505013600186002b6000f050170501a05018050150503c0003e000140501d0502105025050180501405000600046000d60018050230502c050370503a050330502a0503e0003e000
00020000260502a0503105032050330503605037050350503505037550370503705032650346503d650315502f5502d55025550276502a650205501c6501d650216501b5501655015050226500b5501565014650
a6100000066100561006610076000860009100066000660007600022000a6000e3000a6000860008600076000a400076000560003600036000360016500076000860008600216000760005600046000260001600
__music__
04 01024344

