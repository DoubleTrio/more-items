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
  local universal_states = _DATA.UniversalEvent.UniversalStates:Clone()
  universal_states:Set(skin_state)
  _DATA.UniversalEvent.UniversalStates = universal_states
end