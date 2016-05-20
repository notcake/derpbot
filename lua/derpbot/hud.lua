if DerpBot.ShouldDrawOverlay == nil then
	DerpBot.ShouldDrawOverlay = false
	DerpBot.ShouldDrawPlayers = false
end

if not DerpBot.SolidMaterial then
	DerpBot.SolidMaterial = CreateMaterial ("derpbot_solid", "UnlitGeneric",
	{
		["$basetexture"] = "models/debug/debugwhite",
		["$ignorez"] = 1
	})
end

local NPCNames = {
	["npc_alyx"] = "Alyx",
	["npc_antlion"] = "Antlion",
	["npc_antlion_grub"] = "Antlion Grub",
	["npc_antlion_worker"] = "Antlion Worker",
	["npc_antlionguard"] = "Antlion Guard",
	["npc_barney"] = "Barney",
	["npc_breen"] = "Breen",
	["npc_citizen"] = "Citizen",
	["npc_combine"] = "Combine Soldier",
	["npc_combine_s"] = "Combine Elite",
	["npc_crow"] = "Crow",
	["npc_cscannar"] = "Scanner",
	["npc_dog"] = "Dog",
	["npc_eli"] = "Eli",
	["npc_fastzombie"] = "Fast Zombie",
	["npc_fastzombie_torso"] = "Fast Zombie Torso",
	["npc_gman"] = "G Man",
	["npc_headcrab"] = "Headcrab",
	["npc_headcrab_black"] = "Poison Headcrab",
	["npc_headcrab_fast"] = "Fast Headcrab",
	["npc_hunter"] = "Hunter",
	["npc_kleiner"] = "Kleiner",
	["npc_magnusson"] = "Magnusson",
	["npc_manhack"] = "Manhack",
	["npc_metropolice"] = "Metropolice",
	["npc_monk"] = "Father Grigori",
	["npc_mossman"] = "Mossman",
	["npc_pigeon"] = "Pigeon",
	["npc_rollermine"] = "Rollermine",
	["npc_seagull"] = "Seagull",
	["npc_turret_floor"] = "Turret",
	["npc_vortigaunt"] = "Vortigaunt",
	["npc_zombie"] = "Zombie",
	["npc_zombie_torso"] = "Zombie Torso",
	["npc_zombine"] = "Zombine"
}

function DerpBot.FormatName (target)
	if target:IsPlayer () then
		return target:Name ()
	end
	local name = target:GetClass ()
	return NPCNames [name] or name
end

local ScrW = ScrW ()
local ScrH = ScrH ()
hook.Add ("HUDPaint", "DerpBot", function ()
	if not DerpBot.ShouldDrawOverlay then
		return
	end

	local ply = LocalPlayer ()
	local fontHeight = draw.GetFontHeight ("TargetID") - 8
	for _, v in ipairs (DerpBot.GetTargetList ()) do
		if DerpBot.ShouldDrawWallhack (ply, v) then
			local targetPos = DerpBot.GetTargetPos (ply, v)
			targetPos.z = targetPos.z + 10
			local screenPos = targetPos:ToScreen ()
			if screenPos.x > 0 and screenPos.x < ScrW and
				screenPos.y > 0 and screenPos.y < ScrH then
				draw.SimpleText (DerpBot.FormatName (v), "TargetID", screenPos.x, screenPos.y, Color (255, 0, 0, 192), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			else
				local verticalTextAlign = TEXT_ALIGN_BOTTOM
				if screenPos.x < 0 then
					if screenPos.y < 0 then
						screenPos.y = 0
						verticalTextAlign = TEXT_ALIGN_TOP
					end
					if screenPos.y > ScrH then
						screenPos.y = ScrH
					end
					draw.SimpleText ("◄ " .. DerpBot.FormatName (v), "TargetID", 0, screenPos.y, Color (255, 0, 0, 192), TEXT_ALIGN_LEFT, verticalTextAlign)
				elseif screenPos.x > ScrW then
					if screenPos.y < 0 then
						screenPos.y = 0
						verticalTextAlign = TEXT_ALIGN_TOP
					end
					if screenPos.y > ScrH then
						screenPos.y = ScrH
					end
					draw.SimpleText (DerpBot.FormatName (v) ..  " ►", "TargetID", ScrW, screenPos.y, Color (255, 0, 0, 192), TEXT_ALIGN_RIGHT, verticalTextAlign)
				elseif screenPos.y < 0 then
					draw.SimpleText ("▴", "TargetID", screenPos.x, 0, Color (255, 0, 0, 192), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					draw.SimpleText (DerpBot.FormatName (v), "TargetID", screenPos.x, fontHeight, Color (255, 0, 0, 192), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				elseif screenPos.y > ScrH then
					draw.SimpleText (DerpBot.FormatName (v), "TargetID", screenPos.x, ScrH - fontHeight, Color (255, 0, 0, 192), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText ("▾", "TargetID", screenPos.x, ScrH, Color (255, 0, 0, 192), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
				end
			end
		end
	end
end)

hook.Add ("PostDrawTranslucentRenderables", "DerpBot", function ()
	if not DerpBot.ShouldDrawPlayers then
		return
	end
	local ply = LocalPlayer ()
	for _, v in ipairs (DerpBot.GetTargetList ()) do
		if DerpBot.ShouldDrawWallhack (ply, v) then
			local scale = v:GetModelScale ()
			local weapon = nil
			
			if v.GetActiveWeapon then
				weapon = v:GetActiveWeapon ()
				if weapon and not weapon:IsValid () then
					weapon = nil
				end
			end
			
			v:SetModelScale (Vector (1.05, 1.05, 1.05))
			SetMaterialOverride (DerpBot.SolidMaterial)
			render.SuppressEngineLighting (true)
			
			render.SetColorModulation (1, 0, 0)
			v:DrawModel ()
			
			render.SetColorModulation (0, 1, 0)
			if weapon then
				weapon:DrawModel ()
			end
			
			render.SuppressEngineLighting (false)
			
			render.SetColorModulation (1, 1, 1)
			v:SetModelScale (scale)
			SetMaterialOverride (nil)
			
			v:DrawModel ()
			if weapon then
				weapon:DrawModel ()
			end
		end
	end
end)