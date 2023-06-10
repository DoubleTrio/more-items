require 'constants'
require 'helpers'

MapEffectStepType = luanet.import_type('RogueEssence.LevelGen.MapEffectStep`1')
MapGenContextType = luanet.import_type('RogueEssence.LevelGen.ListMapGenContext')
EntranceType = luanet.import_type('RogueEssence.LevelGen.MapGenEntrance')
SkinTableStateType = luanet.import_type('PMDC.Dungeon.SkinTableState')

ZONE_GEN_SCRIPT = {}

function ZONE_GEN_SCRIPT.Test(zoneContext, context, queue, seed, args)
  PrintInfo("Test")
end

function ZONE_GEN_SCRIPT.ShinyZoneStep(zoneContext, context, queue, seed, args)
  local wild_rate = CONSTANTS.WILD_SHINY_RATE
  local charm_rate = CONSTANTS.CHARM_SHINY_RATE
  local item = "bag_shiny_charm"

  if type(args.WildRate) == "number" then wild_rate = args.WildRate end
  if type(args.CharmRate) == "number" then charm_rate = args.CharmRate end
  if type(args.ShinyItem) == "string" then item = args.ShinyItem end
  HELPERS.AdjustShinySpawnRate(item, wild_rate, charm_rate)
end