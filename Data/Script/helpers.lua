HELPERS = {}

---@param item_name string
---@param wild_chance number
---@param charm_chance number
---Adjusts the shiny rate for the entire dungeon when if the player has item.
function HELPERS.AdjustShinySpawnRate(item_name, wild_chance, charm_chance)
  local slot = GAME:FindPlayerItem(item_name, true, true)
  local chance = wild_chance
  if slot:IsValid() then
    chance = charm_chance
  end
  local skin_state = PMDC.Dungeon.SkinTableState(chance, "shiny", "shiny")
  -- NOTE: This line needs to be replaced with something more safer
  -- _DATA.UniversalEvent.UniversalStates:Set(skin_state)
end