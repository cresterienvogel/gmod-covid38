COVID38.List = {}

hook.Add("Initialize", "COVID-38 Virus Register", function()
    for _, name in pairs(file.Find("covid-38/list/*", "LUA")) do
        if SERVER then
            AddCSLuaFile("covid-38/list/" .. name)
        end

        VIRUS = {}

        VIRUS.Key = string.StripExtension(name)
        VIRUS.Name = "< Unknown Virus >"

        VIRUS.Chance = 50

        VIRUS.Incubation = 150
        VIRUS.Active = 300

        VIRUS.Fatal = false
        VIRUS.Infectious = false

        VIRUS.Nausea = false
        VIRUS.Vomiting = false
        VIRUS.Diarrhea = false
        VIRUS.Cough = false
        VIRUS.Weakness = false
        VIRUS.Zombie = false
        VIRUS.Blindness = false
        VIRUS.Breathing = false
        VIRUS.Temperature = false
        VIRUS.Cold = false

        if CLIENT or SERVER then
            include("covid-38/list/" .. name)
        end

        COVID38.List[VIRUS.Key] = VIRUS

        local ENT = scripted_ents.Get("c38_basic")
        ENT.PrintName = VIRUS.Name
        ENT.Spawnable = true
        ENT.Virus = string.StripExtension(name)
        scripted_ents.Register(ENT, "c38_" .. string.StripExtension(name))
    end
end)