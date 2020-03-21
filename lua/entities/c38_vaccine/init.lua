AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/mosi/fallout4/ammo/cryocell.mdl")

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)

    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator)
    activator:RevokeVirus()
    
    activator:EmitSound("items/medshot4.wav")
    activator:EmitSound("vo/Citadel/al_yes_nr.wav")

    self:Remove()
end