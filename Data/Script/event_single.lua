require "constants"
require "helpers"

SINGLE_CHAR_SCRIPT = {}

function SINGLE_CHAR_SCRIPT.AdjustShinyRate(owner, ownerChar, context, args)
  local wild_rate = CONSTANTS.WILD_SHINY_RATE
  local charm_rate = CONSTANTS.CHARM_SHINY_RATE
  local item = "bag_shiny_charm"

  if type(args.WildRate) == "number" then wild_rate = args.WildRate end
  if type(args.CharmRate) == "number" then charm_rate = args.CharmRate end
  if type(args.ShinyItem) == "string" then item = args.ShinyItem end

  HELPERS.AdjustShinySpawnRate(item, wild_rate, charm_rate)
end


--TODO - Finish LuckyEggEvent event...
--The problem is HandoutExpEvent applies to all members at once
function SINGLE_CHAR_SCRIPT.LuckyEggEvent(owner, ownerChar, context, args)
  local priority = RogueElements.Priority(10)
  local index = 0
  local event = _DATA.UniversalEvent.OnDeaths:Get(priority, index)
  --context.CancelState.Cancel = true
end