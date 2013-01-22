local tdAddon = tdCore(...)local Addon = tdAddon:NewModule('Addon')local L = tdAddon:GetLocale()local enabledstatus = {}local function Refresh()    tdAddon:GetOption():GetFrame():Update()endhooksecurefunc('EnableAddOn', function(name)    enabledstatus[GetAddOnInfo(name)] = true    Refresh()end)hooksecurefunc('DisableAddOn', function(name)    enabledstatus[GetAddOnInfo(name)] = false    Refresh()end)hooksecurefunc('EnableAllAddOns', function()    for name in pairs(enabledstatus) do        enabledstatus[GetAddOnInfo(name)] = true    end    Refresh()end)hooksecurefunc('DisableAllAddOns', function()    for name in pairs(enabledstatus) do        enabledstatus[GetAddOnInfo(name)] = false    end    Refresh()end)function Addon:New(addon)    local obj = self:Bind{}        local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addon)        obj.name = name    obj.title = title    obj.notes = notes    obj.author = GetAddOnMetadata(addon, 'Author')    obj.version = GetAddOnMetadata(addon, 'Version')    obj.lod = IsAddOnLoadOnDemand(addon)        enabledstatus[name] = not not enabled        return objendfunction Addon:GetName()    return self.nameendfunction Addon:GetTitle()    return self.titleendfunction Addon:GetAuthor()    return self.authorendfunction Addon:GetVersion()    return self.versionendfunction Addon:GetNotes()    return self.notesendfunction Addon:GetReason()    local loaded = self:IsLoaded()    if loaded and not self:IsEnabled() then        return 'DISABLED_AT_RELOAD'    end    local reason = select(6, GetAddOnInfo(self.name))    if not loaded and self:IsLoadOnDemand() and (not reason or reason == 'DISABLED') then        return 'LOAD_ON_DEMAND'    end    return reasonendfunction Addon:IsLoaded()    return IsAddOnLoaded(self.name)endfunction Addon:IsLoadOnDemand()    return self.lodendfunction Addon:IsEnabled()    return enabledstatus[self.name]endfunction Addon:Enable()    EnableAddOn(self.name)endfunction Addon:Disable()    DisableAddOn(self.name)endfunction Addon:Load()    if self:IsEnabled() then        LoadAddOn(self.name)    else        EnableAddOn(self.name)        LoadAddOn(self.name)        DisableAddOn(self.name)    endend