-- Create characters
local Character = require('bin/lua/domain/model/character')

local anonsky = Character.new("1", "Anonsky", "experienced", "stalker", "shotgun")
Character.set_personality(anonsky, "brave")
local sarik = Character.new("2", "Sarik", "very inexperienced", "Freedom", "pistol")
Character.set_personality(sarik, "cautious")
local danila = Character.new("3", "Danila Matador", "inexperienced", "stalker", "rifle")
Character.set_personality(danila, "reckless")
local fanatic = Character.new("4", "Fanatic", "experienced", "stalker", "Ak-47")
Character.set_personality(fanatic, "zealous")
local egorka = Character.new("5", "Egorka Orderly", "very inexperienced", "stalker", "colt 1991")
Character.set_personality(egorka, "nervous")
local hip = Character.new("6", "Hip", "experienced", "stalker", "knife")
Character.set_personality(hip, "calm")

return {anonsky, sarik, danila, fanatic, egorka, hip}
