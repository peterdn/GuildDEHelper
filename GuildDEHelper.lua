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


local item_frames = { }


function GuildDEHelper_CreateItemFrames(self)
  for i = 1, 4 do
    local frame_name = "GuildDEHelper_Item_" .. i
    local item_frame = CreateFrame("Frame", frame_name, GuildDEHelper, "GuildDEHelperItemTemplate")

    item_frame:SetHeight(24)
    item_frame:SetWidth(24)
    item_frame:SetPoint("TOPLEFT", 10, -16 - 24*i)
    item_frames[i] = item_frame
  end
end


function GuildDEHelper_LayoutItems(self)
  i = 1
  items = { }
  for item_id, quantity in pairs(GuildDEHelper_Item_Counts) do
    if quantity > 0 then
      items[i] = { ["item_id"] = item_id, ["quantity"] = quantity }
      i = i + 1
    end
  end

  for i = 1, 4 do
    if items[i] == nil then
      item_frames[i]:Hide()
    else
      item_id = items[i].item_id
      quantity = items[i].quantity

      item_name = GetItemInfo(item_id)
      if item_name == nil then
        self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        item_name = "?"
      end

      item_icon = GetItemIcon(item_id)

      item_frame = item_frames[i]
      item_frame.item_id = item_id
      item_frame.icon:SetTexture(item_icon)
      item_frame.name:SetText(item_name)
      item_frame.count:SetText(quantity)
      item_frame:Show()
    end
  end
end


function GuildDEHelper_ResetItems(self)
  GuildDEHelper_Item_Counts = { }
  self:LayoutItems()
end


function GuildDEHelper_UpdateEnableButtonText(self)
  if GuildDEHelper_Logging_On then
    self.enable_button:SetText("Disable")
  else
    self.enable_button:SetText("Enable")
  end
end


function GuildDEHelper_OnEvent(self, event, ...)
  if event == "ADDON_LOADED" and ... == "GuildDEHelper" then
    if GuildDEHelper_Logging_On == nil then
      GuildDEHelper_Logging_On = false
    end
    self:UpdateEnableButtonText()

    if GuildDEHelper_Item_Counts == nil then
      GuildDEHelper_Item_Counts = { }
    end

    self:UnregisterEvent("ADDON_LOADED")
    self:RegisterEvent("CHAT_MSG_LOOT")

    self:CreateItemFrames()
    self:LayoutItems()
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

    self:LayoutItems()
  elseif event == "GET_ITEM_INFO_RECEIVED" then
    item_id = tostring(select(1, ...))

    if ITEMS_TO_COUNT[item_id] ~= nil and GuildDEHelper_Item_Counts[item_id] > 0 then
      self:LayoutItems()
    end
  end
end


function GuildDEHelper_OnKeyDown(self, key)
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


function GuildDEHelper_OnResetClick(self)
  GuildDEHelper:ResetItems()
end


function GuildDEHelper_OnEnableClick(self)
  if GuildDEHelper_Logging_On then
    GuildDEHelper_Logging_On = false
  else
    GuildDEHelper_Logging_On = true
  end
  GuildDEHelper:UpdateEnableButtonText()
end


function GuildDEHelper_OnItemIncrClick(self)
  item_id = self:GetParent().item_id
  GuildDEHelper_Item_Counts[item_id] = GuildDEHelper_Item_Counts[item_id] + 1
  GuildDEHelper:LayoutItems()
end


function GuildDEHelper_OnItemDecrClick(self)
  item_id = self:GetParent().item_id
  GuildDEHelper_Item_Counts[item_id] = GuildDEHelper_Item_Counts[item_id] - 1
  GuildDEHelper:LayoutItems()
end


function GuildDEHelper_OnLoad(self)
  self.CreateItemFrames = GuildDEHelper_CreateItemFrames
  self.LayoutItems = GuildDEHelper_LayoutItems
  self.ResetItems = GuildDEHelper_ResetItems
  self.UpdateEnableButtonText = GuildDEHelper_UpdateEnableButtonText

  self:RegisterEvent("ADDON_LOADED")
  self:RegisterForDrag("LeftButton")
end


SLASH_GUILDDEHELPER1 = "/gdeh"
SlashCmdList["GUILDDEHELPER"] = function(cmd)
  cmd = cmd:lower()
  if cmd == "" or cmd == "show" then
    ShowUIPanel(GuildDEHelper)
  elseif cmd == "on" then
    GuildDEHelper_Logging_On = true
    print("GuildDEHelper: on")
    GuildDEHelper:UpdateEnableButtonText()
  elseif cmd == "off" then
    GuildDEHelper_Logging_On = false
    print("GuildDEHelper: off")
    GuildDEHelper:UpdateEnableButtonText()
  elseif cmd == "reset" then
    GuildDEHelper:ResetItems()
  elseif cmd == "print" then
    print_all_items()
  elseif cmd == "status" then
    if GuildDEHelper_Logging_On then print("GuildDEHelper: on") else print("GuildDEHelper: off") end
  else
    print("Usage: /gdeh on|off|show|reset|print")
  end
end
