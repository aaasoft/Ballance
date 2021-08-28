local GameSoundType = Ballance2.Sys.Services.GameSoundType
local ObjectStateBackupUtils = Ballance2.Sys.Utils.ObjectStateBackupUtils
local SmoothFly = Ballance2.Game.Utils.SmoothFly
local Physics = UnityEngine.Physics
local Vector3 = UnityEngine.Vector3
local AudioSource = UnityEngine.AudioSource

---@class P_Extra_Point : ModulBase 
---@field P_Extra_Point_Tigger PhysicsPhantom
---@field P_Extra_Point_Floor GameObject
---@field P_Extra_Point_Ball0 GameObject
---@field P_Extra_Point_Ball1 GameObject
---@field P_Extra_Point_Ball2 GameObject
---@field P_Extra_Point_Ball3 GameObject
---@field P_Extra_Point_Ball4 GameObject
---@field P_Extra_Point_Ball5 GameObject
---@field P_Extra_Point_Ball6 GameObject
---@field P_Extra_Point_Ball_Povit1 GameObject
---@field P_Extra_Point_Ball_Povit2 GameObject
---@field P_Extra_Point_Ball_Povit4 GameObject
---@field P_Extra_Point_Ball_Povit5 GameObject
---@field P_Extra_Point_Ball_Povit6 GameObject
P_Extra_Point = ModulBase:extend()

function P_Extra_Point:new()
  self._RotDegree = 6
  self._Rotate = true
  self._FlyUpTime = 1.3
  self._FlyFollowTime = 2
end

function P_Extra_Point:Start()
  
  self._P_Extra_Point_Ball_Fly1 = self.P_Extra_Point_Ball1:GetComponent(SmoothFly) ---@type SmoothFly
  self._P_Extra_Point_Ball_Fly2 = self.P_Extra_Point_Ball2:GetComponent(SmoothFly) ---@type SmoothFly
  self._P_Extra_Point_Ball_Fly3 = self.P_Extra_Point_Ball3:GetComponent(SmoothFly) ---@type SmoothFly
  self._P_Extra_Point_Ball_Fly4 = self.P_Extra_Point_Ball4:GetComponent(SmoothFly) ---@type SmoothFly
  self._P_Extra_Point_Ball_Fly5 = self.P_Extra_Point_Ball5:GetComponent(SmoothFly) ---@type SmoothFly
  self._P_Extra_Point_Ball_Fly6 = self.P_Extra_Point_Ball6:GetComponent(SmoothFly) ---@type SmoothFly

  self._Sound_Extra_Start = Game.SoundManager:RegisterSoundPlayer(GameSoundType.Normal, 'core.sounds:Extra_Start.wav', false, true, 'Sound_Extra_Start')

  for i = 1, 6, 1 do
    local fly = self['P_Extra_Point_Ball'..i]:GetComponent(SmoothFly) ---@type SmoothFly
    local hitAudio = self.transform:Find('P_Extra_Point_Ball'..i..'/P_Extra_Point_Hit'):GetComponent(AudioSource) ---@type AudioSource
    Game.SoundManager:RegisterSoundPlayer(GameSoundType.Normal, hitAudio)
    self['_P_Extra_Point_Ball_Fly'..i] = fly

    fly.StopWhenArrival = true
    fly.ArrivalDiatance = 2
    ---@param fly SmoothFly
    fly.ArrivalCallback = function (fly)
      fly.gameObject:SetActive(false)
      GamePlay.GamePlayManager:AddPoint(20) --小球是20分
      hitAudio:Play()
    end
  end

  ---@param phantom PhysicsPhantom
  ---@param otherBody PhysicsBody
  self.P_Extra_Point_Tigger.onOverlappingCollidableAdd = function (phantom, otherBody)
    if not self._Actived and otherBody.gameObject.tag == 'Ball' then
      self._Actived = true
      self:StartFly()
      self._Sound_Extra_Start:Play()
      GamePlay.GamePlayManager:AddPoint(100) --大球是100分
    end
  end
  --触发射线，检查当前下方是不是路面，如果是，则显示 Shadow 
  ---@type boolean
  local ok, 
  ---@type RaycastHit
  hitinfo = Physics.Raycast(self.transform.position, Vector3(0, -1, 0), Slua.out, 5) 
  if ok and hitinfo.collider ~= nil then
    local parentName = hitinfo.collider.gameObject.tag
    if parentName == 'Phys_Floors' or parentName == 'Phys_FloorWoods' then
      self.P_Extra_Point_Floor:SetActive(true)
    else
      self.P_Extra_Point_Floor:SetActive(false)
    end
  else
    self.P_Extra_Point_Floor:SetActive(false)
  end

  self._RotCenter = self.transform.position
  self._RotAxis1 = self.P_Extra_Point_Ball_Povit1.transform.up
  self._RotAxis2 = self.P_Extra_Point_Ball_Povit2.transform.up
  self._RotAxis4 = self.P_Extra_Point_Ball_Povit4.transform.up
  self._RotAxis5 = self.P_Extra_Point_Ball_Povit5.transform.up
  self._RotAxis6 = self.P_Extra_Point_Ball_Povit6.transform.up
  self.P_Extra_Point_Ball_Povit1:SetActive(false)
  self.P_Extra_Point_Ball_Povit2:SetActive(false)
  self.P_Extra_Point_Ball_Povit4:SetActive(false)
  self.P_Extra_Point_Ball_Povit5:SetActive(false)
  self.P_Extra_Point_Ball_Povit6:SetActive(false)
end
function P_Extra_Point:StartFly()
  self._Rotate = false

  local posMult = Vector3(1.2, 1, 1.2)
  local upY = self.transform.position.y + 13

  for i = 1, 6, 1 do
    local fly = self['_P_Extra_Point_Ball_Fly'..i] ---@type SmoothFly
    fly.Fly = true
    fly.TargetTransform = nil
    fly.TargetPos = self['P_Extra_Point_Ball'..i].transform.position * posMult
    fly.TargetPos.y = upY
    fly.Time = self._FlyUpTime
  end

  LuaTimer.Add(self._FlyUpTime * 1000, function ()
    self._FlyModUp = true
    local followTarget = GamePlay.CamManager.Target

    for i = 1, 6, 1 do
      local fly = self['_P_Extra_Point_Ball_Fly'..i] ---@type SmoothFly
      fly.Fly = true
      fly.TargetTransform = followTarget
      fly.Time = self._FlyFollowTime
    end
  end)
end
function P_Extra_Point:Update()
  --旋转小球
  if self._Rotate then
    self.P_Extra_Point_Ball1.transform:RotateAround(self._RotCenter, self._RotAxis1, self._RotDegree)
    self.P_Extra_Point_Ball2.transform:RotateAround(self._RotCenter, self._RotAxis2, self._RotDegree)
    self.P_Extra_Point_Ball3.transform:RotateAround(self._RotCenter, self._RotAxis1, -self._RotDegree)
    self.P_Extra_Point_Ball4.transform:RotateAround(self._RotCenter, self._RotAxis4, self._RotDegree)
    self.P_Extra_Point_Ball5.transform:RotateAround(self._RotCenter, self._RotAxis5, self._RotDegree)
    self.P_Extra_Point_Ball6.transform:RotateAround(self._RotCenter, self._RotAxis6, self._RotDegree)
  end 
end

function P_Extra_Point:Active()
  self.gameObject:SetActive(true)
  self.P_Extra_Point_Ball0:SetActive(true)
  self.P_Extra_Point_Ball1:SetActive(true)
  self.P_Extra_Point_Ball2:SetActive(true)
  self.P_Extra_Point_Ball3:SetActive(true)
  self.P_Extra_Point_Ball4:SetActive(true)
  self.P_Extra_Point_Ball5:SetActive(true)
  self.P_Extra_Point_Ball6:SetActive(true)
  self._Rotate = true
  self._FlyModUp = false
  self._FlyModFollow = false
end
function P_Extra_Point:Deactive()
  self.gameObject:SetActive(false)
end
function P_Extra_Point:Reset(type)
  self._Actived = false
  if(type == 'levelRestart') then
    ObjectStateBackupUtils.RestoreObject(self.P_Extra_Point_Ball1)
    ObjectStateBackupUtils.RestoreObject(self.P_Extra_Point_Ball2)
    ObjectStateBackupUtils.RestoreObject(self.P_Extra_Point_Ball3)
    ObjectStateBackupUtils.RestoreObject(self.P_Extra_Point_Ball4)
    ObjectStateBackupUtils.RestoreObject(self.P_Extra_Point_Ball5)
    ObjectStateBackupUtils.RestoreObject(self.P_Extra_Point_Ball6)
    self._P_Extra_Point_Ball_Fly1.Fly = false
    self._P_Extra_Point_Ball_Fly2.Fly = false
    self._P_Extra_Point_Ball_Fly3.Fly = false
    self._P_Extra_Point_Ball_Fly4.Fly = false
    self._P_Extra_Point_Ball_Fly5.Fly = false
    self._P_Extra_Point_Ball_Fly6.Fly = false
  end
end
function P_Extra_Point:Backup()
  ObjectStateBackupUtils.BackUpObject(self.P_Extra_Point_Ball1)
  ObjectStateBackupUtils.BackUpObject(self.P_Extra_Point_Ball2)
  ObjectStateBackupUtils.BackUpObject(self.P_Extra_Point_Ball3)
  ObjectStateBackupUtils.BackUpObject(self.P_Extra_Point_Ball4)
  ObjectStateBackupUtils.BackUpObject(self.P_Extra_Point_Ball5)
  ObjectStateBackupUtils.BackUpObject(self.P_Extra_Point_Ball6)
end

function CreateClass_P_Extra_Point()
  return P_Extra_Point()
end