﻿Log = Ballance2.Utils.Log
LogLevel = Ballance2.Utils.LogLevel
GameManager = Ballance2.Sys.GameManager
GamePackage = Ballance2.Sys.Package.GamePackage
GameEventNames = Ballance2.Sys.Bridge.GameEventNames
GameActionCallResult = Ballance2.Sys.Bridge.GameActionCallResult

---@type GameLuaObjectHostClass
DebugOptWindow = { 
  CheckBoxShowSystemInfo = nil,---@type Toggle
  CheckBoxShowStats = nil,---@type Toggle
  CheckBoxShowPackageManager = nil,---@type Toggle
  CheckBoxWireframe = nil,---@type Toggle
  ContentView = nil,---@type RectTransform

}



---调试功能列表窗口
function CreateClass_DebugOptWindow()
  function DebugOptWindow:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
  end

  function DebugOptWindow:Start()
    GlobalDebugOptWindow.onShow = { "+=", function ()
      self:LoadAllStatus()
    end  }
    GameManager.Instance.GameActionStore:RegisterAction(GamePackage.GetSystemPackage(), "DebugOptAddOption", "DebugOptWindow", function (arr)
      local name = arr[1]
      local text = arr[2]
      local type = arr[3]
      if type == 'Button' then
        self:AddButtonItem(name, text)
      elseif type == 'Toggle' then
        self:AddToggleItem(name, text)
      end
      return GameActionCallResult.SuccessResult
    end, nil)
    GameManager.Instance.GameActionStore:RegisterAction(GamePackage.GetSystemPackage(), "DebugOptRemoveOption", "DebugOptWindow", function (arr)
      local name = arr[1]
      self:RemoveItem(name)
      return GameActionCallResult.SuccessResult
    end, nil)
    GameManager.GameMediator:DispatchGlobalEvent(DebugOptStandByEvent, "*", nil)
    self:LoadAllStatus()
  end
  function DebugOptWindow:OnDestroy()
    GameManager.Instance.GameActionStore:UnRegisterActions({ "DebugOptAddOption", "DebugOptRemoveOption" })
  end

  ---添加和删除条目
  function DebugOptWindow:AddButtonItem(name, text) 
    ---@type Button
    local newButton = CloneUtils.CloneNewObjectWithParent(GameUIManager:GetUIPrefab("Button"), self.ContentView):GetComponent(UnityEngine.UI.Button) 
    ---@type Text
    local newButtonText = newButton.transform:Find('Text'):GetComponent(UnityEngine.UI.Text) 
    newButtonText.text = text
    newButton.name = name
    newButton.onClick:AddListener(function ()
      GameManager.GameMediator:DispatchGlobalEvent(DebugOptEvent, "*", {name,'click'})
    end)
  end
  function DebugOptWindow:AddToggleItem(name, text) 
    ---@type Toggle
    local newToggle = CloneUtils.CloneNewObjectWithParent(GameUIManager:GetUIPrefab("CheckBox"), self.ContentView):GetComponent(UnityEngine.UI.Toggle) 
    ---@type Text
    local newToggleText = newToggle.transform:Find('Label'):GetComponent(UnityEngine.UI.Text) 
    newToggleText.text = text
    newToggle.name = name
    newToggle.onValueChanged:AddListener(function (value)
      GameManager.GameMediator:DispatchGlobalEvent(DebugOptEvent, "*", { name, value })
    end)
  end
  function DebugOptWindow:RemoveItem(name) 
    local transform = self.LogContentView
    local c = transform.childCount
    for i = c - 1, 0, -1 do
      local go = transform:GetChild(i).gameObject
      if (go.name == name) then
        UnityEngine.Object.Destroy(go)
      end
    end
  end

  ---固定的条目状态控制
  function DebugOptWindow:LoadAllStatus()
    self.CheckBoxShowSystemInfo.isOn = GameManager.Instance.GameStore['DbgStatShowSystemInfo']
    self.CheckBoxShowStats.isOn = GameManager.Instance.GameStore['DbgStatShowStats']
    self.CheckBoxShowPackageManager.isOn = GameManager.Instance.GameStore['DbgShowPackageManageWindow']
    self.CheckBoxWireframe.isOn = DebugCamera.Instance.Wireframe
  end
  function DebugOptWindow:OnCheckBoxShowSystemInfoCheckChanged() 
    GameManager.Instance.GameStore['DbgStatShowSystemInfo'] = self.CheckBoxShowSystemInfo.isOn
  end
  function DebugOptWindow:OnCheckBoxWireframeCheckChanged()
    DebugCamera.Instance.Wireframe = self.CheckBoxWireframe.isOn
  end
  function DebugOptWindow:OnCheckBoxShowStatsCheckChanged() 
    GameManager.Instance.GameStore['DbgStatShowStats'] = self.CheckBoxShowStats.isOn
  end
  function DebugOptWindow:OnCheckBoxShowPmgrCheckChanged()
    GameManager.Instance.GameStore['DbgShowPackageManageWindow'] = self.CheckBoxShowPackageManager.isOn
  end

  return DebugOptWindow:new(nil)
end

