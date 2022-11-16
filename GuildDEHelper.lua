function GuildDEHelper_OnLoad(self)
  UIPanelWindows["GuildDEHelper"] = {
    area = "center",
    pushable = 1,
    whileDead = 1,
  }
  self:RegisterEvent("ADDON_LOADED")
end


local ITEMS_TO_COUNT = {
  ["34057"] = true, -- "Abyss Crystal"
  ["34054"] = true, -- "Infinite Dust"
  ["34052"] = true, -- "Dream Shard"
  ["34055"] = true, -- "Greater Cosmic Essence"
  ["34056"] = true, -- "Lesser Cosmic Essence"
  -- ["7073"] = true, -- "Broken Fang"
}


local function print_all_items()
  for item_id, count in pairs(GuildDEHelper_Item_Counts) do
    _, item_link = GetItemInfo(item_id)
    print(item_link, count)
  end
end


function GuildDEHelper_OnEvent(self, event, ...)
  if event == "ADDON_LOADED" and ... == "GuildDEHelper" then
    if GuildDEHelper_Logging_On == nil then
      GuildDEHelper_Logging_On = false
    end

    if GuildDEHelper_Item_Counts == nil then
      GuildDEHelper_Item_Counts = { }
    end

    self:UnregisterEvent("ADDON_LOADED")
    self:RegisterEvent("CHAT_MSG_LOOT")
  elseif event == "CHAT_MSG_LOOT" and GuildDEHelper_Logging_On then
    chat_msg = select(1, ...)
    _, _, item_id = chat_msg:find("item:(%d+).*")

    if ITEMS_TO_COUNT[item_id] == nil then
      return
    end

    _, _, quantity = chat_msg:find("|h|rx(%d+)%.")
    if quantity == nil then quantity = 1 end
    if GuildDEHelper_Item_Counts[item_id] == nil then GuildDEHelper_Item_Counts[item_id] = 0 end
    GuildDEHelper_Item_Counts[item_id] = GuildDEHelper_Item_Counts[item_id] + quantity

    GuildDEHelper_AddToPanel(item_id, quantity)
  end
end


function GuildDEHelper_AddToPanel(item_id, quantity)
  print("Looted item: ", item_id, "x", quantity)
  local frame_name = "GuildDEHelper_Item_" .. item_id
  local item = CreateFrame("Frame", frame_name, GuildDEHelper, "GuildDEHelperItemTemplate")
end


SLASH_GUILDDEHELPER1 = "/gdeh"
SlashCmdList["GUILDDEHELPER"] = function(cmd)
  cmd = cmd:lower()
  if cmd == "" or cmd == "show" then
    ShowUIPanel(GuildDEHelper)
  elseif cmd == "on" then
    GuildDEHelper_Logging_On = true
    print("GuildDEHelper: on")
  elseif cmd == "off" then
    GuildDEHelper_Logging_On = false
    print("GuildDEHelper: off")
  elseif cmd == "reset" then
    GuildDEHelper_Item_Counts = { }
  elseif cmd == "print" then
    print_all_items()
  elseif cmd == "status" then
    if GuildDEHelper_Logging_On then print("GuildDEHelper: on") else print("GuildDEHelper: off") end
  else
    print("Usage: /gdeh on|off|show|reset|print")
  end
end
