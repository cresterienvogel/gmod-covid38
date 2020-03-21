AddCSLuaFile("covid-38/client.lua") 

AddCSLuaFile("covid-38/shared.lua") 
include("covid-38/shared.lua")

include("covid-38/register.lua")
AddCSLuaFile("covid-38/register.lua") 

if SERVER then 
    include("covid-38/server.lua")
else
    include("covid-38/client.lua")
end