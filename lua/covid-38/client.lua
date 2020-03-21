surface.CreateFont("C38", {font = "RuneScape UF", size = 27, weight = 350, antialias = true})

local function ReadableText(text, font, x, y, color, xalign, yalign)
    draw.SimpleText(text, font, x + 1, y + 1, color_black, xalign, yalign)
    draw.SimpleText(text, font, x, y, color, xalign, yalign)
end

local _, virus, pl, ent
hook.Add("HUDPaint", "COVID-38 HUD", function()
    pl = LocalPlayer()
    if pl:GetVirus() and (!pl:GetNWBool("C38_INCUBATION") and pl:GetNWBool("C38_ACTIVE")) then
        _, virus = pl:GetVirus()
        if COVID38.List[virus].Blindness then
            surface.SetDrawColor(COVID38.List[virus].Cold and ColorAlpha(color_white, 25) or ColorAlpha(color_black, 225))
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end
    end

    ent = pl:GetEyeTrace().Entity
    if IsValid(ent) and ent:GetPos():Distance(pl:GetPos()) < 110 and (ent:GetClass() ~= "c38_vaccine" and tobool(string.find(ent:GetClass(), "c38"))) and GetGlobalBool("C38_CD") then 
		ReadableText("On cooldown", "C38", ScrW() / 2 - 8, ScrH() / 1.85 + 20, Color(255, 191, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
end)

local view = {}
local function SetView(origin, angles, fov)
    view.origin = pos
    view.angles = angles
    view.fov = fov 

    return view
end

local has_weakness, has_temperature, has_cold = false, false, false
hook.Add("CalcView", "COVID-38 HUD", function(pl, pos, angles, fov)
    pl = LocalPlayer()
    if pl:GetVirus() and (!pl:GetNWBool("C38_INCUBATION") and pl:GetNWBool("C38_ACTIVE")) then
        _, virus = pl:GetVirus()
        has_weakness = COVID38.List[virus].Weakness
        has_temperature = COVID38.List[virus].Temperature
        has_cold = COVID38.List[virus].Cold

        if (has_weakness or has_temperature) and not has_cold then
            return SetView(pos, angles + (has_weakness and Angle(0, 0, TimedCos(0.5, 0, 4, 0)) or Angle(0, 0, 0)), fov + TimedSin(has_weakness and 0.5 or 1, 0, has_weakness and 4 or 1, 0))
        elseif (has_weakness or has_cold) and not has_temperature then
            return SetView(pos, angles + (has_weakness and Angle(0, 0, TimedCos(4, 0, 1, 0)) or Angle(0, 0, TimedCos(2, 0, 2, 0))), fov + TimedSin(has_weakness and 0.5 or 1, 0, has_weakness and 4 or 1, 0))
        end
    end
end)

hook.Add("RenderScreenspaceEffects", "COVID-38 HUD", function()
    pl = LocalPlayer()
    if pl:GetVirus() and (!pl:GetNWBool("C38_INCUBATION") and pl:GetNWBool("C38_ACTIVE")) then
        _, virus = pl:GetVirus()
        if has_weakness then
            DrawMaterialOverlay("effects/bleed_overlay", 0.07)
        end

        if has_temperature then
            DrawMaterialOverlay("effects/invuln_overlay_red", 0.07)
        end

        if has_cold then
            DrawMaterialOverlay("effects/invuln_overlay_blue", 0.07)
        end
    end
end)

net.Receive("C38_ALERT", function()
    pl = LocalPlayer()

    local ct = SysTime()
    local p1, p2, p3 = 0, 0, 0

    local name = "You've activated " .. net.ReadString() .. "." 
    local infected = "Infected " .. net.ReadUInt(8) .. " people."
    local got = net.ReadBool() and "You are among them." or " "

    pl:EmitSound("music/HL2_song25_Teleporter.mp3", 75, 100, 0.2, CHAN_AUTO)
    pl:EmitSound("ambient/machines/keyboard_fast3_1second.wav", 75, 100, 0.9, CHAN_AUTO)
    pl:EmitSound("combined/trainyard/trainyard_kl_whatisit01_cc.wav", 75, 100, 0.8, CHAN_AUTO)

    local mf = vgui.Create("EditablePanel")
    mf:SetPos(0, 0)
    mf:SetSize(ScrW(), ScrH())

    function mf:Paint(w, h)
        ReadableText(name:sub(0, p1 > #name and #name - (p1 - #name) or p1), "C38", ScrW() * 0.3, ScrH() - 350, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        ReadableText(infected:sub(0, p2 > #infected and #infected - (p2 - #infected) or p2), "C38", ScrW() * 0.3, ScrH() - 300, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        ReadableText(got:sub(0, p3 > #got and #got - (p3 - #got) or p3), "C38", ScrW() * 0.3, ScrH() - 250, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        if SysTime() > ct and p1 < #name * 2 then
            if (p2 == 0 and p1 < #name) or p2 == #infected * 2 then 
                p1 = p1 + 1
            elseif (p3 == 0 and p2 < #infected) or p3 == #got * 2 then
                p2 = p2 + 1
            else
                p3 = p3 + 1
            end
            ct = SysTime() + (p3 == #got and 10 or (p3 > #got and math.random(0.025, 0.05) or math.random(0.05, 0.1)))
        elseif p1 == #name * 2 then
            self:Remove()
        end
    end
end)