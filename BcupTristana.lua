require "VPrediction"
require "SourceLib"
require "SOW"

if myHero.charName ~= "Tristana" then return end


champsToStun = {
                { charName = "Katarina",        spellName = "KatarinaR" ,                  important = 0},
                { charName = "Galio",           spellName = "GalioIdolOfDurand" ,          important = 0},
                { charName = "FiddleSticks",    spellName = "Crowstorm" ,                  important = 1},
                { charName = "FiddleSticks",    spellName = "DrainChannel" ,               important = 1},
                { charName = "Nunu",            spellName = "AbsoluteZero" ,               important = 0},
                { charName = "Shen",            spellName = "ShenStandUnited" ,            important = 0},
                { charName = "Urgot",           spellName = "UrgotSwap2" ,                 important = 0},
                { charName = "Malzahar",        spellName = "AlZaharNetherGrasp" ,         important = 0},
                { charName = "Karthus",         spellName = "FallenOne" ,                  important = 0},
                { charName = "Pantheon",        spellName = "PantheonRJump" ,              important = 0},
		            { charName = "Pantheon",        spellName = "PantheonRFall",               important = 0},
                { charName = "Varus",           spellName = "VarusQ" ,                     important = 1},
                { charName = "Caitlyn",         spellName = "CaitlynAceintheHole" ,        important = 1},
                { charName = "MissFortune",     spellName = "MissFortuneBulletTime" ,      important = 1},
                { charName = "Warwick",         spellName = "InfiniteDuress" ,             important = 0}
}


function OnLoad()
--[[
	RapidFire = {charName = "Tristana", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = .5, spellType = "selfCast", riskLevel = "noDmg", cc = false, hitLineCheck = false},
    RocketJump = {charName = "Tristana", spellSlot = "W", range = 900, width = 270, speed = 1150, delay = .5, spellType = "skillShot", riskLevel = "kill", cc = false, hitLineCheck = false},
    DetonatingShot = {charName = "Tristana", spellSlot = "E", range = 625, width = 0, speed = 1400, delay = .5, spellType = "enemyCast", riskLevel = "kill", cc = false, hitLineCheck = false},
    BusterShot = {charName = "Tristana", spellSlot = "R", range = 700, width = 0, speed = 1600, delay = .5, spellType = "enemyCast", riskLevel = "extreme", cc = true, hitLineCheck = false},
		]]
	VP = VPrediction()
	qRng, wRng, eRng, rRng = (550 + 9 *(myHero.level - 1)), 900, (550 + 9 *(myHero.level - 1)), (550 + 9 * (myHero.level - 1))
	Q = Spell(_Q, qRng)
	W = Spell(_W, wRng):SetSkillshot(VP, SKILLSHOT_CIRCULAR, 270, 0.5, 1150, false)
	E = Spell(_E, eRng)
	R = Spell(_R, rRng)
	DLib = DamageLib()
	--DamageLib:RegisterDamageSource(spellId, damagetype, basedamage, perlevel, scalingtype, scalingstat, percentscaling, condition, extra)
	DLib:RegisterDamageSource(_W, _MAGIC, 70, 45, _MAGIC, _AP, 0.80, function() return (player:CanUseSpell(_W) == READY)end)
	DLib:RegisterDamageSource(_E, _MAGIC, 110, 40, _MAGIC, _AP, 1, function() return (player:CanUseSpell(_E) == READY)end)
	DLib:RegisterDamageSource(_R, _MAGIC, 300, 100, _MAGIC, _AP, 1.5, function() return (player:CanUseSpell(_R) == READY)end)
	DFG = Item(3188,750)
	
	Config = scriptConfig("Tristana","Tristana")
	-- Key Binds
	Config:addSubMenu("Key Bindings","bind")
	Config.bind:addParam("active", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config.bind:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	Config.bind:addParam("auto", "Auto Spell", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("N"))
	Config.bind:addParam("interrupt", "Interrupt With R", SCRIPT_PARAM_ONKEYTOGGLE, true,string.byte("L"))
	Config:addSubMenu("Draw","Draw")
	Config.Draw:addParam("drawq", "Draw Q", SCRIPT_PARAM_ONOFF, true)
	Config.Draw:addParam("draww", "Draw W", SCRIPT_PARAM_ONOFF, true)
	Config.Draw:addParam("drawe", "Draw E", SCRIPT_PARAM_ONOFF, true)
	Config.Draw:addParam("drawr", "Draw R", SCRIPT_PARAM_ONOFF, true)
	
	Orbwalker = SOW(VP)
	Config:addSubMenu("Orbwalker", "SOWorb")
	Orbwalker:LoadToMenu(Config.SOWorb)
	
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
	Config:addSubMenu("Set Target Selector Priority", "STS")
	STS:AddToMenu(Config.STS)
	Combo = {_W, _E, _R,_ITEMS}
	DLib:AddToMenu(Config.Draw,Combo)
	
	PrintChat("<font color='#E97FA5'> >> ButterCupTristana Loaded!</font>")
end

function OnTick()
	target = STS:GetTarget(rRng)
	if Config.bind.active then
		active(target)
	end
	if Config.bind.harass then
		harass(target)
	end
	if Config.bind.auto then
		auto(target)
	end
end

function OnDraw()
	if Config.Draw.drawq then
		DrawCircle(myHero.x,myHero.y,myHero.z,qRng,0xFFFF0000)
	end 
	if Config.Draw.draww then
		DrawCircle(myHero.x,myHero.y,myHero.z,wRng,0xFFFF0000)
	end
		
	if Config.Draw.drawe then
		DrawCircle(myHero.x,myHero.y,myHero.z,eRng,0xFFFF0000)
	end
	if Config.Draw.drawr then
		DrawCircle(myHero.x,myHero.y,myHero.z,rRng,0xFFFF0000)
	end
end

function OnProcessSpell(unit,spell)
	if Config.bind.interrupt then
		if unit.type == 'obj_AI_Hero' and unit.team == TEAM_ENEMY and GetDistance(unit) < rRng then
		  local spellName = spell.name
			for i = 1, #champsToStun do
				if unit.charName == champsToStun[i].charName and spellName == champsToStun[i].spellName then
					if champsToStun[i].important == 0 then
						if R:IsReady() and R:IsInRange(unit,myHero) then
							R:Cast(unit)
						end
					else
						if R:IsReady() and R:IsInRange(unit,myHero) then
							R:Cast(unit)
						end
					end
				end
			end
		end
	end
end

function castQ(target)
	if target and Q:IsInRange(target) and Q:IsReady() then
		Q:Cast()
	end
end

function castW(target,chance)
	if target and W:IsInRange(target) and W:IsReady() then
		wP, wC = W:GetPrediction(target)
		if wP and wC >= chance then
			W:Cast(wP.x,wP.z)
		end
	end
end

function castE(target)
	if target and E:IsInRange(target) and E:IsReady() then
		E:Cast(target)
	end
end

function castR(target)
	if target and R:IsInRange(target) and R:IsReady() then
		R:Cast(target)
	end
end

function castDFG(target)
	if target and  DFG:InRange(target) and DFG:IsReady() then
		DFG:Cast(target)
	end
end
		
function active(target)
	if target then
		castQ(target)
		castW(target,1)
		castDFG(target)
		castE(target)
		castR(target)
	end
end

function harass(target)
	if target then
		castQ(target)
		castE(target)
	end
end

function auto(target)
	if target then
		castE(target)
	end
end
