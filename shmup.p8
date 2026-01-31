pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
	mode="start"
	colo = 1
end

function _update()
	if mode == "game" then
		gameup()
	elseif mode == "start" then
		startup()
	elseif mode == "over" then
		overup()
	elseif mode == "wavetext" then
		wavetextup()
	elseif mode == "win" then
		winup()
	end
end

function _draw()
	if mode == "game" then
		gamedr()
	elseif mode == "start" then
		startdr()
	elseif mode == "over" then
		overdr()
	elseif mode == "wavetext" then
		wavetextdr()
	elseif mode == "win" then
		windr()
	end
end
-->8
--player--

function plrin()
	plr={
	x=64, 
	y=64,
	xs=0,
	ys=0,
	sp=19,
	anim=true,
	invurnerable=false,
	i_timer = 0}
	condition = false
end

function plrup()
	plr.xs = 0
	plr.ys = 0
	plr.i_timer -=1
	if plr.i_timer == 0 then
		plr.invurnerable=false
	end
	if btn(➡️) then
		plr.xs =2
	elseif btn(⬅️) then
		plr.xs =-2
	elseif btn(⬇️) then
		plr.ys =2
	elseif btn(⬆️) then
		plr.ys =-2 
	end
	plr.x = plr.x+plr.xs
	plr.y = plr.y+plr.ys
	
	
	if plr.x > 120 then
		plr.x=0
	elseif plr.x < 0 then
		plr.x=0
	end
	if plr.y > 120 then
		plr.y=120
	elseif plr.y < 0 then
		plr.y=0
	end
	if not plr.invurnerable then
		for myen in all(enemies) do
			if col(myen,plr) then
				lives -=1
				sfx(3)
				plr.invurnerable = true
				plr.i_timer = 20
			end
		end
	end
	if plr.invurnerable then
		condition = sin(time()*8) < 0
	else
		condition = true 
	end
end

function plrdr()
	if lives > 0 then
		if condition then
			spr(plr.sp,plr.x,plr.y)
		end
	end
end
-->8
--shooting--
function shootin()
	shooting = false
	shootanim = 5
	cardspr = 0
	cards={}
	cooldown=5
	
end

function shootup()
	for i=#cards,1,-1 do
		local mycard=cards[i]
		mycard.y-=4
		if mycard.y<-8 then
			del(cards, mycard)
		end
	end
	cardspr += 0.5
	if cardspr >= 8 then
		cardspr = 0
	end
 if btnp(🅾️) and not shooting then
 	shooting = true
 	plr.sp = 16
	end
	if shooting then
		shootanim -=1
		if shootanim == 0 and plr.sp<19 then
			plr.sp +=1 
			shootanim = cooldown
		elseif plr.sp == 19 then
			shooting = false
			local newcard={} 
			sfx(2)
			newcard.x = plr.x
			newcard.y = plr.y -8
			add(cards, newcard)
			shootanim = cooldown
		end
	end
end

function shootdr()
	for i=1,#cards do
		local mycard = cards[i]
		spr(cardspr,mycard.x,mycard.y)
	end
end
-->8
-- enemies
function enin()
	enemies = {}
end

function enup()
	for i=1, #enemies do
		local myen = enemies[i]
		myen.counter+=1
		if myen.y < 10 then
			myen.y+=1
		end
		if myen.counter > myen.threshold then
			myen.y +=4
			myen.spr +=1
			if myen.spr>46 then
			 myen.spr = 35
			end
		end
		if myen.y > 120 then
			myen.y = 10
			myen.spr = 35
			myen.threshold = flr(rnd(500))
			myen.counter = 0
		end
	end
end

function endr()
	for i = 1, #enemies do
		local myen = enemies[i]
		if myen.flash > 0 then
			myen.flash -=1
			pal(0,7)
		end
		spr(myen.spr, myen.x, myen.y,myen.w,myen.h)
		pal(0,0)
	end
	
	for myp in all(partics) do
		circfill(myp.x,myp.y,myp.size,myp.col)
		myp.x += myp.sx
		myp.y += myp.sy
		myp.age +=1
		if myp.age/myp.max_age <0.10 then
			myp.col= 7
		elseif myp.age/myp.max_age <0.30 then
		 myp.col= 10
		elseif myp.age/myp.max_age <0.40 then
		 myp.col= 9
		elseif myp.age/myp.max_age <0.60 then
			myp.col= 8
		elseif myp.age/myp.max_age <0.80 then
			myp.col= 2
		end
		if myp.age>myp.max_age then
			myp.size -=0.5
			if myp.size < 0 then
				del(partics,myp)
			end
		end
	end
end

function spawnen(entype)
	if spawned then 
		return 
	end
	spawned=true
	
	if entype == 1 then
		for i=1,wave do
			local myen = {}
			myen.x = i*9-8
			myen.y = -8
			myen.spr = 35
			myen.counter = 0
			myen.hp = 2
			myen.flash = 0
			myen.threshold =flr(rnd(500))
			add(enemies, myen)
		end
	elseif entype == 2 then
		local myen = {}
		myen.x = 1
		myen.y = -8
		myen.spr = 12
		myen.counter = 0
		myen.hp = 6
		myen.flash = 0
		myen.threshold =flr(rnd(500))
		myen.w = 2
		myen.h = 2
		add(enemies, myen)
	end

end
-->8
--general functions--
function col(a,b)
	local a_left=a.x
	local a_top=a.y
	local a_right=a.x+7
	local a_bottom=a.y+7
	
	local b_left=b.x
	local b_top=b.y
	local b_right=b.x+7
	local b_bottom=b.y+7
	
	if a_top>b_bottom then
		return false
	end
	if b_top>a_bottom then
		return false
	end
	if a_left>b_right then
		return false
	end
	if b_left>a_right then
		return false
	end
	return true
end


function startup()
	if sin(time()*20) < 0 then
		colo +=1
	else
	 colo +=2
	end
	if btnp(🅾️) or btnp(❎) or btnp(⬆️) or btnp(⬇️) or btnp(⬅️) or btnp(➡️)then
	 mode="game"
	 startgame()
	end
end

function startdr()
	cls(1)
	print("game",20,30,12)
	print("press any key to start",20,60,colo)
end
function overup()
	if btn(🅾️)==false and btn(❎)==false and btn(⬆️)==false and btn(⬇️)==false and  btn(⬅️)==false and btn(➡️)==false then 
		no_btn_pressed = true
	end
	if no_btn_pressed then
	 if btnp(🅾️) or btnp(❎) or btnp(⬆️) or btnp(⬇️) or btnp(⬅️) or btnp(➡️)then
		 mode="start"
		end
	end
end
function overdr()
	print("game over",20,25,2)
	print("press any key to restart",20,60,2)
end

function startgame()
	enin()
	plrin()
	shootin()
	palt(0,false)
	palt(14, true)
	animation = 0
	frame=35
	x=64
	y=64
	score = 0
	lives = 3
	t=0
	partics = {}
	wave=0
	dots={}
	nextwave()
	bgin()
end

function explode(expx,expy)
	for i=1,20 do
	 local myp = {}
	 myp.x = expx
	 myp.y = expy
	 myp.sx = (rnd()-0.5)*3
	 myp.sy = (rnd()-0.5)*3
	 myp.age = 0
	 myp.coln = 7
	 myp.max_age = rnd()*30
	 myp.size = 3
	 add(partics, myp)
	end
end

function gameup()
	 enup()
		plrup()
		shootup()
		bgup()
		for myen in all(enemies) do
			for mycard in all(cards) do
				if col(myen,mycard) then
					myen.hp -=1
					del(cards,mycard)
					sfx(3)
					myen.flash = 3 
					if myen.hp <= 0 then
						explode(myen.x,myen.y)
						del(enemies,myen)
				 	score += 10
				 	if #enemies == 0 then
							nextwave()
						end
					end
				end 
			end
		end
		animation += 1
		t+=1
		if lives <= 0 then
	 	mode = "over"
		end
end


function gamedr()
		cls(3)
		bgdr()
		rect(0,-1,127,128,4)
		endr()
		plrdr()
		shootdr()
		print(score,40, 1, 7)
		spr(21,30,1)
		for i=1,3 do
			if lives >= i then
				spr(22,i*9-8,1)
			else
				spr(23,i*9-8,1)
			end
		end
end 


function winup()

end

function windr()
	print("you win!")
end
-->8
--backround/waves--


function wavetextup()
	gameup()
	wavetime -=1
	if wavetime <= 0 then
		spawnwave()
		mode="game"
	end
end

function wavetextdr()
	gamedr()
	print("wave "..wave,50,30,7)
end

function spawnwave()
	spawnen(1)
end

function nextwave()
	spawned = false
	wavetime=100
	wave+=1
	
	if wave >= 4 then
		mode = "win"
	else
		mode="wavetext"
	end
end
function bgin()
 for i=1,100 do
		local mydot = {}
		mydot.x = rnd(128)
		mydot.y = rnd(128)
		local random = flr(rnd(2)) 
		if random  == 0 then
			mydot.col = 10
		elseif random == 1 then
			mydot.col = 11
		elseif random == 2 then
			mydot.col = 10
		end
		add(dots, mydot)
	end
end



function bgdr()
		for i = 1, #dots do
			local mydot = dots[i]
			pset(mydot.x, mydot.y,mydot.col)
		end
end

function bgup()
	for i = 1, #dots do
		local mydot = dots[i]
		mydot.y+=1
		if mydot.y >= 128 then
		 mydot.y=0
		end
	end
end
__gfx__
e787877eee7878eeeeeeeeeeee778eeee778787eeee877eeeeeeeeeeee8787eee787877eeeeeeeeeeeeeeeeeee8888eeeeeeeee55eeeeeeeeeeeeeeeeeeeeeee
e788877ee778887777777777e7888eeee778887eeee8887e777777777788877ee788877eeeeeeeeeeeeeeeeee8eeee8eeeeee557755eeeeeeeeeeeeeeeeeeeee
e778777ee777777777777788778787eee777877eee787877887777777777777ee778777eeeeeeeeeeeeeeeee8eeeeee8eee5577777755eeeeeeeeeeeeeeeeeee
e777777e7777777e88777887777777eee777777eee77777778877788e7777777e777777ee99999999999999e8ee88ee8e55777707777755eeeeeeeeeeeeeeeee
e777777e777777ee788777887777777ee777777ee777777788777887ee777777e777777ee97779777797779e8ee88ee85557777777777555eeeeeeeeeeeeeeee
e777877e778787ee88777777e7777777e778777e7777777e77777788ee787877e777877ee97779777797779e8eeeeee85775577777755665eeeeeeeeeeeeeeee
e778887ee7888eee77777777e7788877e788877e7788877e77777777eee8887ee778887ee97779777797779ee8eeee8e5777755775566665eeeeeeeeeeeeeeee
e778787eee778eeeeeeeeeeeee7878eee787877eee8787eeeeeeeeeeeee877eee778787ee97779777797779eee8888ee5787777556666665eeeeeeeeeeeeeeee
eeee7787ee7f77ee777787eeeeeeeeeeeeeeeeeeee7cc7eee88ee88ee88ee88eeeeeeeeee97779777797779eeeeeeeee5787787756066665eeeeeeeeeeeeeeee
efffff77eff77f7e877f7feeeeefefeeeeeeeeeeec7777ce878888888e888ee8eeeeeeeee97779777797779eeeeeeeee5787787756666665eeeeeeeeeeeeeeee
ffff7777fffff7877f7f7feeefefefeeeeeeeeee77777777888888888eeeeee8eeeeeeeee97779777797779eeeeeeeee5777787756666065eeeeeeeeeeeeeeee
fffffff7ffff77f77f7f7feeefefefeeeeeeeeeec777777ce888888ee8eeee8eeeeeeeeee97779777797779eeeeeeeee5777777756666665eeeeeeeeeeeeeeee
ffff7778ffffffeeefffffeeefffffeeeeeeeeeec777777cee8888eeee8ee8eeeeeeeeeee97779777797779eeeeeeeeee55777775666655eeeeeeeeeeeeeeeee
effffff7ffffeeeeefffffefefffffefeeeeeeee77777777eee88eeeeee88eeeeeeeeeeee99999999999999eeeeeeeeeeee5577756655eeeeeeeeeeeeeeeeeee
efeeeeeeeefeeeeeeffffffeeffffffeeeeeeeeeec7777ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee557555eeeeeeeeeeeeeeeeeeeee
eefeeeeeeeffeeeeeefffeeeeefffeeeeeeeeeeeee7cc7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55eeeeeeeeeeeeeeeeeeeeeee
e777777eeeeeeeeeeeeeeeeeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee7777eeee7117eeee7177eeee7777eeee0000ee00000000
e700077eeee00eeeeee00eeee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000ee077770ee071170ee071770ee077770e00000000
e700077eee0000eeeee00eee00777700000000000000000000000000000000000000000000000000000000000000000000777700007117000071770000000000
e000007ee00ee00ee000000e00717700007777000000000000000000000000000000000000000000000000000000000000000000007777000071170000000000
e000007ee00ee00ee000000e00711700007177000077770000000000000000000000000000000000000000000000000000000000000000000077770000000000
e770777eeeeeeeeeeee00eee00777700007117000071770000777700000000000000000000000000000000000000000000000000000000000000000000000000
e770777eeee00eeeeee00eeee000000ee077770ee071170ee071770ee077770ee000000ee000000ee000000ee000000ee000000ee000000ee000000e00000000
e700077eee0000eeee0000eeee0000eeee0000eeee7777eeee7117eeee7177eeee7777eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000ee00000000
eee777ee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee7eee7e00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e7eee7e700000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e7777ee700000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e7ee7ee700000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e7ee7e7700000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e77777ee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeee7ee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
444444444444444444444444eeeeeee55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eeeee557755eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eee5577777755eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334e55777707777755eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
4333333333333333333333345557777777777555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
4333333333333333333333345775577777755665eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
4333333333333333333333345777755775566665eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
4333333333333333333333345787777556666665eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
4333333333333333333333345787787756066665eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
4333333333333333333333345787787756666665eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
4333333333333333333333345777787756666065eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
4333333333333333333333345777777756666665eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334e55777775666655eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eee5577756655eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eeeee557555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eeeeeee55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
433333333333333333333334eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
444444444444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
__map__
5050414141414141414141414141414200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515141415200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5000000000000000000000000000005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5000000000000000000000000000005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5000000000000000000000000000005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5000000000000000000000000000005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
001000000c1530765500000000000c15300000000000765500000000000c1530c153000000765500000000000c1530c1530c1530765500000000000c15300000000000765500000000000c1530c1530000000000
001000183d0303f6003d0303c0303e0303f6003e030386003c0303e0303d0300f600190300a6001003012030120300760017030140301703018030180302660001650036502565023650206501c6500000000000
000100003a15038150361503315010150311502e15016150291501a150261501d15023150211501f1501e1501c1501b1501a15019150181501715016150151501415012150111500e1500d1500c1500c1500b150
0001000038650386503865038650376503765036650346503365032650306502f6502d6602c6502a6502964026640206401d6401b6401863015630126200d6200a61007650046500265000650106001060000000
__music__
07 01004344

