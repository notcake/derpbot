DerpBot = DerpBot or {}
DerpBot.TargetList = {}

function DerpBot.ArcLengthToAngle (radius, arcLength)
	return arcLength * 180 / 3.1415926 / radius
end

function DerpBot.GetTarget (ply)
	local target = nil
	local priority = 0
	for _, v in ipairs (DerpBot.GetTargetList ()) do
		if DerpBot.ShouldTarget (ply, v) and not DerpBot.ShouldIgnoreTarget (ply, v) then
			local targetPriority = DerpBot.GetTargetPriority (ply, v)
			if targetPriority > priority then
				priority = targetPriority
				target = v
			end
		end
	end
	return target
end

function DerpBot.GetTargetList ()
	return DerpBot.TargetList
end

local npcBones = {
	["npc_antlion"]				= "Antlion.Head_Bone",
	["npc_antlion_worker"]		= "Antlion.Head_Bone",
	["npc_antlionguard"]		= "Antlion_Guard.head",
	["npc_dog"]					= "Dog_Model.Eye",
	["npc_fastzombie"]			= "ValveBiped.Bip01_Spine4",
	["npc_fastzombie_torso"]	= "ValveBiped.Bip01_Spine2",
	["npc_headcrab"]			= "HeadcrabClassic.BodyControl",
	["npc_headcrab_black"]		= "HCblack.torso",
	["npc_headcrab_fast"]		= "HCfast.chest",
	["npc_hunter"]				= "MiniStrider.antennaBase",
	["npc_turret_floor"]		= "Gun",
	["npc_vortigaunt"]			= "ValveBiped.head",
	["npc_zombie"]				= "ValveBiped.Bip01_Spine4",
	["npc_zombie_torso"]		= "ValveBiped.Bip01_Spine2"
}

local npcOffsets = {
	["npc_headcrab"] = Vector (0, 0, 8)
}

local fallbackBones = {
	"ValveBiped.Bip01_Head1",
	"ValveBiped.Bip01_Neck1",
	"ValveBiped.Bip01_Spine4"
}

function DerpBot.GetTargetPos (ply, target)
	local headBoneName = npcBones [target:GetClass ()]
	local headBoneID = headBoneName and target:LookupBone (headBoneName) or nil
	local offset = npcOffsets [target:GetClass ()] or Vector (0, 0, 0)
	
	if headBoneID and headBoneID >= 1 then
		return target:GetBonePosition (headBoneID) + offset
	end
	
	for _, headBoneName in ipairs (fallbackBones) do
		headBoneID = target:LookupBone (headBoneName)
		if headBoneID and headBoneID >= 1 then
			return target:GetBonePosition (headBoneID) + offset
		end
	end
	return target:GetPos () + offset
end

function DerpBot.GetTargetPriority (ply, target)
	if not target or not target:IsValid () then return -1 end

	local targetPos = DerpBot.GetTargetPos (ply, target)
	local distance = (targetPos - ply:GetPos ()):Length ()
	local priority = 1 / distance
	local arcDistance = DerpBot.LinePointDistance (ply:GetShootPos (), ply:GetAimVector (), targetPos)
	local angle = DerpBot.IsoscelesTriangleBaseLengthToAngle (distance, arcDistance)
	
	priority = priority / angle
	return priority
end

function DerpBot.IsAlive (target)
	if target:GetClass () == "npc_antlion_grub" then return true end
	if target:GetMoveType () == MOVETYPE_NONE then return false end
	if target:IsPlayer () and target:Health () <= 0 then return false end
	return true
end

function DerpBot.IsoscelesTriangleBaseLengthToAngle (side, baseLength)
	baseLength = baseLength * 0.5
	return math.asin (baseLength / side) * 180 / 3.1415926
end

function DerpBot.LinePointDistance (linePoint, lineDirection, point)
	return (point - linePoint):Cross (point - linePoint - lineDirection):Length () / lineDirection:Length ()
end

function DerpBot.SetEyeAngles (ply, targetEyeAngles)
	local eyeAngles = ply:EyeAngles ()
	local speed = 2
	
	ply:SetEyeAngles (Angle (
		math.ApproachAngle (eyeAngles.p, targetEyeAngles.p, speed),
		math.ApproachAngle (eyeAngles.y, targetEyeAngles.y, speed),
		eyeAngles.r
	))
end

function DerpBot.ShouldAimbotWeapon (ply, weapon)
	if not weapon or not weapon:IsValid () then return false end
	if weapon:GetPrimaryAmmoType () == -1 then return false end
	return true
end

function DerpBot.ShouldDrawWallhack (ply, target)
	if not target or not target:IsValid () then return false end
	if not DerpBot.IsAlive (target) then return end
	return true
end

function DerpBot.ShouldIgnoreTarget (ply, target)
	if not target or not target:IsValid () then return true end
	if ply == target then return true end
	return false
end

local otherTargetClasses = {
	["fishing_mod_seagull"] = true
}

function DerpBot.ShouldTarget (ply, target)
	if not target or not target:IsValid () then return false end
	if ply == target then return false end
	if not DerpBot.IsAlive (target) then return end
	
	if target:IsPlayer () then return true end
	if target:IsNPC () then return true end
	if target:GetClass ():sub (1, 4) == "npc_" then return true end
	if otherTargetClasses [target:GetClass ()] then return true end
	return false
end

function DerpBot.UpdateTargetList ()
	local targets = {}
	local ply = LocalPlayer ()
	for _, v in ipairs (ents.GetAll ()) do
		if DerpBot.ShouldTarget (ply, v) then
			targets [#targets + 1] = v
		end
	end
	DerpBot.TargetList = targets
end

DerpBot.UpdateTargetList ()

timer.Create ("DerpBot", 0.2, 0, function ()
	DerpBot.UpdateTargetList ()
end)

include ("derpbot/aimbot.lua")
include ("derpbot/hud.lua")