function GuildDEHelper_OnLoad(self)
  self:RegisterEvent("ADDON_LOADED")
  self:RegisterForDrag("LeftButton")
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


local function add_all_items(self)
  for item_id, count in pairs(GuildDEHelper_Item_Counts) do
    GuildDEHelper_AddToPanel(self, item_id, count)
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

    add_all_items(self)
  elseif event == "CHAT_MSG_LOOT" and GuildDEHelper_Logging_On then
    chat_msg = select(1, ...)

    if select(5, ...) ~= UnitName("player") then
      return
    end

    _, _, item_id = chat_msg:find("item:(%d+).*")

    if ITEMS_TO_COUNT[item_id] == nil then
      return
    end

    _, _, quantity = chat_msg:find("|h|rx(%d+)%.")
    if quantity == nil then quantity = 1 end
    if GuildDEHelper_Item_Counts[item_id] == nil then GuildDEHelper_Item_Counts[item_id] = 0 end
    GuildDEHelper_Item_Counts[item_id] = GuildDEHelper_Item_Counts[item_id] + quantity

    GuildDEHelper_AddToPanel(self, item_id, GuildDEHelper_Item_Counts[item_id])
  elseif event == "GET_ITEM_INFO_RECEIVED" then
    item_id = tostring(select(1, ...))

    if ITEMS_TO_COUNT[item_id] ~= nil and GuildDEHelper_Item_Counts[item_id] > 0 then
      GuildDEHelper_AddToPanel(self, item_id, GuildDEHelper_Item_Counts[item_id])
    end
  end
end


function GuildDEHelper_OnKeyDown(self, key)
  if key == "ESCAPE" then
    self:Hide()
    self:SetPropagateKeyboardInput(false)
    return
  end
  self:SetPropagateKeyboardInput(true)
end


function GuildDEHelper_OnDragStart(self, button)
  if button == "LeftButton" then
    self:StartMoving()
  end
end


function GuildDEHelper_OnDragStop(self)
  self:StopMovingOrSizing()
end


local item_frames = { }
local nitems = 0


function GuildDEHelper_AddToPanel(self, item_id, quantity)
  item_name = GetItemInfo(item_id)
  if item_name == nil then
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    item_name = "?"
  end

  item_icon = GetItemIcon(item_id)
  if item_frames[item_id] == nil then
    local frame_name = "GuildDEHelper_Item_" .. item_id
    local item_frame = CreateFrame("Frame", frame_name, GuildDEHelper, "GuildDEHelperItemTemplate")
    item_frame.name:SetText(item_name)
    item_frame.count:SetText(quantity)
    item_frame.icon:SetTexture(item_icon)
    item_frame:SetHeight(24)
    item_frame:SetWidth(24)
    item_frame:SetPoint("TOPLEFT", 10, -16 - 24*nitems)
    item_frames[item_id] = item_frame
    nitems = nitems + 1
  else
    item_frame = item_frames[item_id]
    item_frame.name:SetText(item_name)
    item_frame.count:SetText(quantity)
  end
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
