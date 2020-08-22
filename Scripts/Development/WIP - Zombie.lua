local delay, target
local lastdist = math.huge

Settings = {
	Dormant = false,
	CloseDistance = 20,
	FarDistance = 40,
	WalkSpeed = 4,
	MobHeight = This.size.y
}


local function FindTarget()
	delay = delay or os.time() + 1 -- Set if nil

	if os.time() >= delay then
		delay = os.time() + 1

		for k, v in pairs(GetAllPlayers()) do
			local distance = Vector3.Distance(This.position, v.position)

			if distance <= Settings.CloseDistance and distance <= lastdist then
				local ray = RayCast(This.position, v.position)

				if ray.hitObject == v then
					lastdist = distance
					target = v
				end
			end
		end
	end
end

local function FollowTarget()
	if target then
		This.LookAt(target.position)
		This.angles = newVector3(0, This.angles.y, 0)
		
		This.position = Vector3.MoveTowards(This.position, newVector3(target.position.x, This.position.y, target.position.z), Settings.WalkSpeed / 100)
	end
end

function Update()
	if IsHost and not Settings.Dormant then
		if not target then
			FindTarget()
		else
			FollowTarget()
		end
	end
end