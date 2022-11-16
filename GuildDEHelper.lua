function GuildDEHelper_OnLoad(self)
  UIPanelWindows["GuildDEHelper"] = {
    area = "center",
    pushable = 1,
    whileDead = 1,
  }
  self:RegisterEvent("ADDON_LOADED")
end

local logging_on = false

local item_counts = { }


local function print_all_items()
  for item_id, count in pairs(item_counts) do
    _, item_link = GetItemInfo(item_id)
    print(item_link, count)
  end
end


function GuildDEHelper_OnEvent(self, event, ...)
  if event == "ADDON_LOADED" and ... == "GuildDEHelper" then
    self:UnregisterEvent("ADDON_LOADED")
    self:RegisterEvent("CHAT_MSG_LOOT")
  elseif event == "CHAT_MSG_LOOT" and logging_on then
    chat_msg = select(1, ...)
    _, _, item_id = chat_msg:find("item:(%d+).*")
    _, _, quantity = chat_msg:find("|h|rx(%d+)%.")
    if quantity == nil then quantity = 1 end
    if item_counts[item_id] == nil then item_counts[item_id] = 0 end
    item_counts[item_id] = item_counts[item_id] + quantity

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
    logging_on = true
    print("GuildDEHelper: on")
  elseif cmd == "off" then
    logging_on = false
    print("GuildDEHelper: off")
  elseif cmd == "reset" then
    item_counts = { }
  elseif cmd == "print" then
    print_all_items()
  elseif cmd == "status" then
    if logging_on then print("GuildDEHelper: on") else print("GuildDEHelper: off") end
  else
    print("Usage: /gdeh on|off|show|reset|print")
  end
end
