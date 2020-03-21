COVID38 = COVID38 or {}

COVID38.Author = "crester & alexsnowrun"
COVID38.Build = "03/21/20"

COVID38.SinglePlayerCD = 60
COVID38.MultiPlayerCD = 300
COVID38.InfectRadius = 120

local PLAYER = FindMetaTable("Player")

function PLAYER:GetVirus()
    for name, _ in pairs(COVID38.List) do
        if self:GetNWBool("C38_" .. string.upper(name)) then
            return true, name
        end
    end
    return false
end