ITEM_SCRIPT = {}

SkinTableStateType = luanet.import_type('PMDC.Dungeon.SkinTableState')

function ITEM_SCRIPT.ShinyCharmEvent(owner, ownerChar, context, args)
  local wild_rate = CONSTANTS.WILD_SHINY_RATE
  local charm_rate = CONSTANTS.CHARM_SHINY_RATE
  local item = "bag_shiny_charm"

  if type(args.WildRate) == "number" then wild_rate = args.WildRate end
  if type(args.CharmRate) == "number" then charm_rate = args.CharmRate end
  if type(args.ShinyItem) == "string" then item = args.ShinyItem end

  if (context.Item.Value == item) then
    _DATA.UniversalEvent.UniversalStates:GetWithDefault(luanet.ctype(SkinTableStateType)).AltColorOdds = charm_rate
  elseif (context.PrevItem.Value == item) then
    _DATA.UniversalEvent.UniversalStates:GetWithDefault(luanet.ctype(SkinTableStateType)).AltColorOdds = wild_rate
  end
end