util.AddNetworkString("C38_ALERT")

--[[
    Functions
]]

function COVID38.ApplyVirus(name, activator)
    if GetGlobalBool("C38_CD") then
        return
    end

    SetGlobalBool("C38_CD", true)
    timer.Simple(game.SinglePlayer() and COVID38.SinglePlayerCD or COVID38.MultiPlayerCD, function()
        SetGlobalBool("C38_CD", false)
    end)

    local act_hasinfected = false
    local count = 0
    for _, pl in pairs(player.GetAll()) do
        if math.random(1, 100) <= COVID38.List[name].Chance then
            if pl:GetVirus() then
                continue
            end

            if pl:ApplyVirus(name, true) then
                if pl == activator then
                    act_hasinfected = true
                end
                count = count + 1
            end
        end
    end

    if activator then
        net.Start("C38_ALERT")
            net.WriteString(COVID38.List[name].Name)
            net.WriteUInt(count, 8)
            net.WriteBool(act_hasinfected)
        net.Send(activator)
    end
end

--[[
    Meta
]]

local PLAYER = FindMetaTable("Player")

function PLAYER:ApplyVirus(name, bool)
    if not COVID38.List[name] then
        return
    end

    if (self:GetNWBool("C38_" .. string.upper(name)) and bool) or (not self:GetNWBool("C38_" .. string.upper(name)) and not bool) then
        return
    end

    if bool then
        if self:GetVirus() then
            return
        end

        self:SetNWBool("C38_" .. string.upper(name), true)
        self:SetNWBool("C38_INCUBATION", true)

        timer.Simple(COVID38.List[name].Incubation, function()
            if not IsValid(self) then
                return
            end

            local bool, tag = self:GetVirus()
            if not bool or tag ~= name then
                return
            end

            self:SetNWBool("C38_INCUBATION", false)
            self:SetNWBool("C38_ACTIVE", true)
        end)

        timer.Simple(COVID38.List[name].Incubation + COVID38.List[name].Active, function()
            if not IsValid(self) then
                return
            end

            local bool, tag = self:GetVirus()
            if not bool or tag ~= name then
                return
            end

            if not COVID38.List[name].Fatal then
                self:RevokeVirus()
            else
                self:Kill()
            end
        end)

        return true
    else
        self:SetNWBool("C38_" .. string.upper(name), false)
        self:SetNWBool("C38_INCUBATION", false)
        self:SetNWBool("C38_ACTIVE", false)
    end
end

function PLAYER:RevokeVirus()
    if self:GetVirus() then
        local _, name = self:GetVirus()
        self:SetNWBool("C38_" .. string.upper(name), false)
        self:SetNWBool("C38_INCUBATION", false)
        self:SetNWBool("C38_ACTIVE", false)
    end
end

--[[
    lil girls' panties
]]

hook.Add("PlayerDeath", "COVID-38 Zombie", function(pl)
    if pl:GetVirus() then
        if pl:GetNWBool("C38_INCUBATION") or not pl:GetNWBool("C38_ACTIVE") then
            return
        end

        local _, virus = pl:GetVirus()
        if COVID38.List[virus].Zombie then
            local npc = ents.Create("npc_zombie")
            npc:SetPos(pl:GetPos())
            npc:Spawn()
        end

        pl:RevokeVirus()
    end
end)

timer.Create("COVID-38 Infection", 7, 0, function()
    for _, pl in pairs(player.GetAll()) do
        if pl:GetVirus() then
            if not pl:GetNWBool("C38_INCUBATION") or pl:GetNWBool("C38_ACTIVE") then
                continue
            end

            local _, virus = pl:GetVirus()
            if COVID38.List[virus].Infectious then
                for _, ent in pairs(ents.FindInSphere(pl:GetPos(), COVID38.InfectRadius)) do
                    if not ent:IsPlayer() then
                        continue
                    end

                    if math.random(1, 100) <= COVID38.List[virus].Chance then
                        ent:ApplyVirus(virus, true)
                    end
                end
            end
        end
    end
end)

timer.Create("COVID-38 Breathing", 3, 0, function()
    for _, pl in pairs(player.GetAll()) do
        if pl:GetVirus() then
            if pl:GetNWBool("C38_INCUBATION") or not pl:GetNWBool("C38_ACTIVE") then
                continue
            end

            local _, virus = pl:GetVirus()

            if COVID38.List[virus].Breathing then
                pl:EmitSound("covid-38/breath.wav")
            end

            if COVID38.List[virus].Cough then
                pl:EmitSound("ambient/voices/cough" .. math.random(1, 4) .. ".wav")
            end
        end
    end
end)

timer.Create("COVID-38 Symptoms", 15, 0, function()
    for _, pl in pairs(player.GetAll()) do
        if pl:GetVirus() then
            if pl:GetNWBool("C38_INCUBATION") or not pl:GetNWBool("C38_ACTIVE") then
                continue
            end

            local _, virus = pl:GetVirus()

            if COVID38.List[virus].Diarrhea then
                timer.Simple(math.random(2, 10), function()
                    if IsValid(pl) then
                        pl:ViewPunch(Angle(10, 0, 0))

                        local ent = ents.Create("ent_poop")

                        local ang = pl:GetAimVector():Angle()
                        local trail = util.SpriteTrail(ent, 0, Color(94, 71, 7), false, 10, 20, 1, 0.017, "trails/plasma.vmt")

                        pl:EmitSound("covid-38/pooping.wav")

                        ent:SetPos(pl:GetShootPos() + ang:Forward() * -3 + ang:Up() * -20)
                        ent:SetAngles(ang)
                        ent:SetOwner(pl)
                        ent:Spawn()

                        local phys = ent:GetPhysicsObject()
                        phys:ApplyForceCenter(pl:GetAimVector():GetNormalized() * 10)
                        if IsValid(phys) then 
                            phys:ApplyForceCenter(ang:Up() * 10) 
                        end
                    end
                end)
            end

            if COVID38.List[virus].Vomiting then
                timer.Simple(math.random(2, 10), function()
                    if IsValid(pl) then
                        pl:ViewPunch(Angle(10, 0, 0))

                        local ent = ents.Create("ent_poop")

                        local ang = pl:GetAimVector():Angle()
                        local trail = util.SpriteTrail(ent, 0, Color(156, 81, 5), false, 10, 60, 1, 0.0072, "trails/plasma.vmt")

                        pl:EmitSound("covid-38/vomiting.wav")

                        ent:SetPos(pl:GetShootPos() + ang:Forward() * 3 + ang:Up() * -4)
                        ent:SetAngles(ang)
                        ent:SetOwner(pl)
                        ent:Spawn()

                        local phys = ent:GetPhysicsObject()
                        phys:ApplyForceCenter(pl:GetAimVector():GetNormalized() * 60)
                        if IsValid(phys) then 
                            phys:ApplyForceCenter(ang:Forward() * 50 + ang:Up() * 50) 
                        end
                    end
                end)
            end
        end
    end
end)