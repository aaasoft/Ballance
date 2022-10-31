---@gendoc

local CommonUtils = Ballance2.Utils.CommonUtils
local ObjectStateBackupUtils = Ballance2.Utils.ObjectStateBackupUtils
local FadeManager = Game.UIManager.UIFadeManager
local Yield = UnityEngine.Yield
local WaitForSeconds = UnityEngine.WaitForSeconds

---默认的球碎片抛出和回收器。提供默认的球碎片抛出和回收效果控制。
---@class BallPiecesControll : GameLuaObjectHostClass
BallPiecesControll = {
  _CamMgr = nil, ---@type CamManager
  _Rigidbody = nil, ---@type PhysicsObject
  _Force = 0,
  _UpForce = 0,
  _DownForce = 0,
  _TimerIds = {}
} 

---球碎片数据结构定义
---@class BallPiecesData
---@field bodys PhysicsObject[] 所有的碎片物理体
---@field parent GameObject 父级游戏对象
---@field fadeOutTimerID number|nil 淡出延时定时器
---@field delayHideTimerID number|nil 隐藏延时定时器
---@field throwed boolean 获取碎片是否已经抛出了
---@field fadeObjects FadeObject[] 淡出控制对象
BallPiecesData = {}

function CreateClass:BallPiecesControll()
  
  function BallPiecesControll:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
  end

  function BallPiecesControll:Start()
    GamePlay.BallPiecesControll = self
  end
    
  ---开始抛出碎片
  ---@param data BallPiecesData 碎片数据集
  ---@param pos Vector3 抛出的位置
  ---@param minForce number 推动最小力
  ---@param maxForce number 推动最大力
  ---@param timeLive number|nil 碎片存活时间（30个tick为单位）
  function BallPiecesControll:ThrowPieces(data, pos, minForce, maxForce, timeLive)

    local parent = data.parent
    if not parent.activeSelf then
      --去除物理
      for _, body in ipairs(data.bodys) do
        if body.IsPhysicalized then
          body:UnPhysicalize(true) 
        end
      end

      parent:SetActive(true)

      --还原初始状态
      ObjectStateBackupUtils.RestoreObjectAndChilds(parent)
      --设置位置
      data.parent.transform.position = pos
      data.throwed = true

      ---清除上一次的延时
      if data.delayHideTimerID then
        LuaTimer.Delete(data.delayHideTimerID)
      end
      if data.fadeOutTimerID then
        LuaTimer.Delete(data.fadeOutTimerID)
      end

      --渐变未完成，需要强制清除正在运行的渐变
      if data.fadeObjects then
        for _, value in pairs(data.fadeObjects) do
          if value then
            value:ResetTo(1)
            value:Delete()
          end
        end
        data.fadeObjects = nil
      else
        --快速显示
        for i = 0, parent.transform.childCount - 1 do
          FadeManager:AddFadeIn(parent.transform:GetChild(i).gameObject, 0.1, nil)
        end
      end

      ---延时消失
      data.delayHideTimerID = LuaTimer.Add((timeLive or 20) * 2000, function ()
        data.delayHideTimerID = nil
        self:ResetPieces(data)
      end)

      local count = 0

      --物理化并且抛出碎片
      coroutine.resume(coroutine.create(function()

        for _, body in ipairs(data.bodys) do

          --防止一下抛出太多碎片
          count = count + 1
          if count > 3 then
            Yield(WaitForSeconds(0.01))
            count = 0
          end

          body:Physicalize() --物理
        end

        for _, body in ipairs(data.bodys) do

          count = count + 1
          if count > 3 then
            Yield(WaitForSeconds(0.01))
            count = 0
          end

          local forceDir = body.transform.localPosition
          body.gameObject:SetActive(true)
          forceDir.y = forceDir.y + 2
          forceDir:Normalize()
          body:Impluse(forceDir * CommonUtils.RandomFloat(minForce, maxForce)) --施加力
        end
      end))
    end
  end
  ---回收碎片
  ---@param data BallPiecesData 碎片数据集
  function BallPiecesControll:ResetPieces(data)

    local parent = data.parent
    if parent.activeSelf then
      
      ---清除上一次的延时
      if data.delayHideTimerID then
        LuaTimer.Delete(data.delayHideTimerID)
      end

      if not data.fadeObjects then
        data.fadeObjects = {}
      end

      --渐变淡出隐藏其材质
      for i = 0, parent.transform.childCount - 1 do
        local obj = FadeManager:AddFadeOut(parent.transform:GetChild(i).gameObject, 3, true, nil)
        table.insert(data.fadeObjects, obj)
      end

      data.throwed = false

      if data.fadeOutTimerID then
        LuaTimer.Delete(data.fadeOutTimerID)
      end

      --延时
      data.fadeOutTimerID = LuaTimer.Add(2990, function ()
        
        if data.fadeObjects then
          data.fadeObjects = nil
        end
  
        --去除物理
        for _, body in ipairs(data.bodys) do
          body:UnPhysicalize(true) 
        end

        parent:SetActive(false) --隐藏
      end)
    end
  end

  return BallPiecesControll:new(nil)
end
