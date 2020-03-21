AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Poop"

if CLIENT then
	function ENT:Draw() 
		self:DrawModel() 
	end

	function ENT:IsTranslucent() 
		return true 
	end
end

if SERVER then
	function ENT:Initialize()
		if not IsValid(self:GetOwner()) then 
			self:Remove() 
			return 
		end

		self:SetModel("models/alyx_emptool_prop.mdl")
		self:SetMaterial("models/effects/vol_light001")

		self:PhysicsInitSphere(10)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self:DrawShadow(false)
		self:GetPhysicsObject():EnableGravity(true)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end

	function ENT:PhysicsCollide(data, physobj)
		ParticleEffect("slime_splash_01_droplets", data.HitPos, data.HitNormal:Angle())
		timer.Simple(0, function() 
			self:Remove() 
		end)
	end
end