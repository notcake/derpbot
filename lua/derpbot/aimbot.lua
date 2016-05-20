function DerpBot.Aim (ply)
	if not DerpBot.ShouldAimbotWeapon (ply, ply:GetActiveWeapon ()) then return end

	local target = DerpBot.GetTarget (ply)
	if not target then return end
	
	local viewModel = ply:GetViewModel ()
	if not viewModel or not viewModel:IsValid () then return end
	
	local shootPos = ply:GetShootPos ()
	local muzzleAttachmentID = viewModel:LookupAttachment ("muzzle")
	if muzzleAttachmentID >= 1 then
		local muzzleAttachmentData = viewModel:GetAttachment (muzzleAttachmentID)
		shootPos = muzzleAttachmentData.Pos
	end
	
	local aimVector = DerpBot.GetTargetPos (ply, target) - ply:GetShootPos ()
	aimVector:Normalize ()
	local angle = aimVector:Angle ()
	local currentAimVector = ply:GetAimVector ()
	currentAimVector:Normalize ()
	
	local deltaLength = (currentAimVector - aimVector):Length ()
	if deltaLength > 0.25 then return end
	
	DerpBot.SetEyeAngles (ply, angle)
end

local MouseKeys = {
	MOUSE_LEFT,
	MOUSE_RIGHT,
	MOUSE_MIDDLE,
	MOUSE_4,
	MOUSE_5,
	MOUSE_WHEEL_UP,
	MOUSE_WHEEL_DOWN
}
local MouseKey = MOUSE_LEFT
hook.Add ("PlayerBindPress", "DerpBot", function (ply, bind, pressed)
	bind = bind:lower ()
	
	if bind == "+attack" then
		if pressed then
			for i = 1, #MouseKeys do
				if input.IsMouseDown (MouseKeys [i]) then
					MouseKey = MouseKeys [i]
					break
				end
			end
			hook.Add ("Think", "DerpBot", function ()
				if not input.IsMouseDown (MouseKey) then
					hook.Remove ("Think", "DerpBot")
				end
				DerpBot.Aim (ply)
			end)
			hook.Call ("Think")
		end
	end
end)