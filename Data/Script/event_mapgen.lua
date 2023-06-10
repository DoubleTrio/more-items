MapEffectStepType = luanet.import_type('RogueEssence.LevelGen.MapEffectStep`1')
MapGenContextType = luanet.import_type('RogueEssence.LevelGen.ListMapGenContext')
EntranceType = luanet.import_type('RogueEssence.LevelGen.MapGenEntrance')
SkinTableStateType = luanet.import_type('PMDC.Dungeon.SkinTableState')

ZONE_GEN_SCRIPT = {}

function ZONE_GEN_SCRIPT.Test(zoneContext, context, queue, seed, args)
  PrintInfo("Test")
end

function ZONE_GEN_SCRIPT.ShinyZoneStep(zoneContext, context, queue, seed, args)
  local slot = GAME:FindPlayerItem("bag_shiny_charm", true, true)
  local chance = CONSTANTS.WILD_SHINY_RATE
  if slot:IsValid() then 
    chance = CONSTANTS.CHARM_SHINY_RATE
  end
  local skin_state = PMDC.Dungeon.SkinTableState(chance, "shiny", "shiny")
  _DATA.UniversalEvent.UniversalStates:Set(skin_state)
end