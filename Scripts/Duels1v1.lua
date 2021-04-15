import(Module_System)
import(Module_Players)
import(Module_Defines)
import(Module_PopScript)
import(Module_Game)
import(Module_Objects)
import(Module_Map)
import(Module_Person)
import(Module_Commands)
include("UtilPThings.lua")
include("UtilRefs.lua")
include("AIShaman.lua")

computer_init_player(_gsi.Players[TRIBE_RED])

botSpells = {M_SPELL_BLAST}

for u,v in ipairs(botSpells) do
    PThing.SpellSet(TRIBE_RED, v, TRUE, FALSE)
end

AIShamanRed = AIShaman:new(nil, TRIBE_RED, 1, 1, 1, 1, 1, 0, 0, 1, 1, 15000, 7)

function OnTurn()
    --Simulate 160 pop for mana regen to reduce lag
    if (everyPow(1, 1)) then
        GIVE_MANA_TO_PLAYER(TRIBE_BLUE, 667)
        GIVE_MANA_TO_PLAYER(TRIBE_RED, 667)
    end
    
    if (GetTurn() > 128) then
       AIShamanRed:handleShamanCombat()
    end

    if (everyPow(240, 1)) then
        MOVE_SHAMAN_TO_MARKER(TRIBE_RED, 0)
    end
end