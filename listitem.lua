
local tdAddon = tdCore(...)
local GUI = tdCore('GUI')
local L = tdAddon:GetLocale()

local GOLD_TEXT = {1.0, 0.82, 0}
local RED_TEXT = {1, 0, 0}
local STATUS_COLORS = setmetatable({
	DISABLED = {157/256, 157/256, 157/256},
	DEP_DISABLED = {157/256, 157/256, 157/256},
	NOT_DEMAND_LOADED = {1, 0.5, 0},
	DEP_NOT_DEMAND_LOADED = {1, 0.5, 0},
	LOAD_ON_DEMAND = {30/256, 1, 0},
	DISABLED_AT_RELOAD = {163/256, 53/256, 238/256},
	DEP_MISSING = {1, 0.5, 0},
}, {__index = function() return RED_TEXT end})

local WHITE_LIST = {
    tdAddon = true,
    tdCore = true,
}

local LoadButton = tdAddon:NewModule('LoadButton', GUI('Button'):New(), 'Event')

function LoadButton:OnInit()
    self:RegisterEvent('ADDON_LOADED')
end

function LoadButton:ADDON_LOADED()
    tdAddon:Refresh()
end

function LoadButton:New(parent)
    local obj = self:Bind(GUI('Button'):New(parent))
    
    obj:SetText(L['Load'])
    obj:SetPoint('RIGHT', -5, 0)
    obj:SetWidth(50)
    obj:SetScript('OnClick', self.OnClick)
    obj:SetScript('OnEnter', self.OnEnter)
    obj:SetScript('OnLeave', self.OnLeave)
    
    return obj
end

function LoadButton:OnEnter()
    self:GetParent():LockHighlight()
    self:GetParent():OnEnter()
end

function LoadButton:OnLeave()
    self:GetParent():UnlockHighlight()
    self:GetParent():OnLeave()
end

function LoadButton:OnClick()
    self:GetParent():GetValue():Load()
end

local CheckBox = tdAddon:NewModule('CheckBox', GUI('CheckBox'):New())

function CheckBox:New(parent)
    local obj = self:Bind(GUI('CheckBox'):New(parent))
    
    obj:SetPoint('LEFT')
    obj:SetScript('OnClick', self.OnClick)
    obj:SetScript('OnEnter', LoadButton.OnEnter)
    obj:SetScript('OnLeave', LoadButton.OnLeave)
    
    return obj
end

function CheckBox:OnClick()
    self:GetParent():OnClick()
end

local AddonItem = tdAddon:NewModule('AddonItem', GUI('ListWidgetItem'):New())

function AddonItem:New(parent)
    local obj = self:Bind(GUI('ListWidgetItem'):New(parent))
    
    local loadbutton = LoadButton:New(obj)
    local checkbox = CheckBox:New(obj)
    
    obj.loadbutton = loadbutton
    obj.checkbox = checkbox
    
    local label = obj:GetLabelFontString()
    label:ClearAllPoints()
    label:SetPoint('LEFT', checkbox, 'RIGHT', 2, 0)
    label:SetJustifyV('LEFT')
    
    local value = obj:GetValueFontString()
    value:ClearAllPoints()
    value:SetPoint('RIGHT', loadbutton, 'LEFT')
    value:SetJustifyV('RIGHT')
    
    obj:SetScript('OnClick', self.OnClick)
    obj:SetScript('OnEnter', self.OnEnter)
    obj:SetScript('OnLeave', self.OnLeave)
    
    return obj
end

function AddonItem:OnEnter()
    local addon = self:GetAddon()
    GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM')
    GameTooltip:SetText(addon:GetTitle())
    GameTooltip:AddLine(addon:GetNotes(), 1, 1, 1, true)
    if addon:GetAuthor() then
        GameTooltip:AddDoubleLine(L['Author:'], addon:GetAuthor(), 1, 0.4, 0, 1, 1, 1)
    end
    if addon:GetVersion() then
        GameTooltip:AddDoubleLine(L['Version:'], addon:GetVersion(), 1, 0.4, 0, 1, 1, 1)
    end
    
    for i, depend in ipairs({GetAddOnDependencies(addon:GetName())}) do
        local loaded = IsAddOnLoaded(depend) and 1 or 0
        GameTooltip:AddDoubleLine(i == 1 and L['Dependencies:'] or ' ', depend, 1, 0.4, 0, 1, loaded, loaded)
    end
    GameTooltip:Show()
end

function AddonItem:OnLeave()
    GameTooltip:Hide()
end

function AddonItem:OnClick()
    local addon = self:GetAddon()
    
    if addon:IsEnabled() and not WHITE_LIST[addon:GetName()] then
        addon:Disable()
    else
        addon:Enable()
    end
    self:GetParent():Refresh()
end

function AddonItem:GetShowText(addon)
    if not addon:GetVersion() then
        return addon:GetTitle()
    else
        return ('%s |cffff6600(%s)|r'):format(addon:GetTitle(), addon:GetVersion():trim())
    end
end

function AddonItem:SetValue(addon)
    self.__value = addon
    
    local reason = addon:GetReason()
    
    self:SetLabelText(self:GetShowText(addon))
    self:SetValueText(reason and (_G['ADDON_' .. reason] or L[reason]))
    self:GetValueFontString():SetTextColor(unpack(STATUS_COLORS[reason]))
    self:GetLabelFontString():SetTextColor(unpack(reason and STATUS_COLORS[reason] or GOLD_TEXT))
    self.checkbox:SetChecked(addon:IsEnabled())
    if addon:IsLoadOnDemand() and not addon:IsLoaded() then
        self.loadbutton:Show()
        self:GetValueFontString():SetPoint('RIGHT', self.loadbutton, 'LEFT')
    else
        self.loadbutton:Hide()
        self:GetValueFontString():SetPoint('RIGHT', -5, 0)
    end
    if WHITE_LIST[addon:GetName()] then
        self.checkbox:Disable()
        self.checkbox:EnableMouse(false)
    else
        self.checkbox:Enable()
        self.checkbox:EnableMouse(true)
    end
end
AddonItem.GetAddon = AddonItem.GetValue
