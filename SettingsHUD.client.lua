-- ANMOL: LIVING WORLD | SettingsHUD.client.lua
-- Put in StarterPlayer > StarterPlayerScripts as a LocalScript.
-- Client-side settings; does not change server gameplay or other players' graphics.
local Players = game:GetService('Players')
local SoundService = game:GetService('SoundService')
local Lighting = game:GetService('Lighting')
local player = Players.LocalPlayer
local gui = Instance.new('ScreenGui')
gui.Name = 'AnmolSettingsHUD'
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild('PlayerGui')

local function style(obj, radius)
  local corner = Instance.new('UICorner')
  corner.CornerRadius = UDim.new(0, radius or 10)
  corner.Parent = obj
end
local function button(parent, label, position, size)
  local b = Instance.new('TextButton')
  b.Text = label
  b.Font = Enum.Font.GothamBold
  b.TextScaled = true
  b.TextColor3 = Color3.fromRGB(245, 245, 250)
  b.BackgroundColor3 = Color3.fromRGB(45, 62, 84)
  b.Position = position
  b.Size = size
  b.Parent = parent
  style(b)
  return b
end

local toggle = button(gui, '⚙ Settings', UDim2.new(1,-144,0,12), UDim2.fromOffset(132,42))
local panel = Instance.new('Frame')
panel.Name = 'Panel'
panel.AnchorPoint = Vector2.new(.5,.5)
panel.Position = UDim2.fromScale(.5,.5)
panel.Size = UDim2.new(.86,0,0,310)
panel.BackgroundColor3 = Color3.fromRGB(23,30,43)
panel.Visible = false
panel.Parent = gui
style(panel,14)
local constraint = Instance.new('UISizeConstraint')
constraint.MaxSize = Vector2.new(420,310)
constraint.MinSize = Vector2.new(250,270)
constraint.Parent = panel
local title = Instance.new('TextLabel')
title.Text = 'ANMOL  •  SETTINGS'
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(244,232,194)
title.TextScaled = true
title.BackgroundTransparency = 1
title.Position = UDim2.fromScale(.07,.05)
title.Size = UDim2.fromScale(.7,.12)
title.Parent = panel
local close = button(panel,'X',UDim2.new(1,-52,0,10),UDim2.fromOffset(40,35))
local music = button(panel,'Music: ON',UDim2.fromScale(.09,.24),UDim2.fromScale(.82,.14))
local effects = button(panel,'Visual Effects: ON',UDim2.fromScale(.09,.42),UDim2.fromScale(.82,.14))
local hud = button(panel,'HUD: ON',UDim2.fromScale(.09,.60),UDim2.fromScale(.82,.14))
local note = Instance.new('TextLabel')
note.Text = 'Settings apply on this device for this session.'
note.TextWrapped = true
note.TextScaled = true
note.Font = Enum.Font.Gotham
note.TextColor3 = Color3.fromRGB(185,197,210)
note.BackgroundTransparency = 1
note.Position = UDim2.fromScale(.07,.8)
note.Size = UDim2.fromScale(.86,.13)
note.Parent = panel

local musicOn, effectsOn, hudOn = true,true,true
local originalVolume = SoundService.Volume
local originalGlobalShadows = Lighting.GlobalShadows
local originalPostEffects = {}
local function applyMusic()
  -- This affects sounds routed through SoundService's global volume on this client.
  SoundService.Volume = musicOn and originalVolume or 0
  music.Text = 'Music / Audio: ' .. (musicOn and 'ON' or 'OFF')
end
local function applyEffects()
  Lighting.GlobalShadows = effectsOn and originalGlobalShadows or false
  for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA('PostEffect') then
      if originalPostEffects[child] == nil then originalPostEffects[child] = child.Enabled end
      child.Enabled = effectsOn and originalPostEffects[child] or false
    end
  end
  effects.Text = 'Visual Effects: ' .. (effectsOn and 'ON' or 'OFF')
end
local function applyHud()
  for _, child in ipairs(player.PlayerGui:GetChildren()) do
    if child:IsA('ScreenGui') and child ~= gui then
      child.Enabled = hudOn
    end
  end
  hud.Text = 'Other HUDs: ' .. (hudOn and 'ON' or 'OFF')
end
local function setPanel(open)
  panel.Visible = open
  toggle.Visible = not open
end
toggle.MouseButton1Click:Connect(function() setPanel(true) end)
close.MouseButton1Click:Connect(function() setPanel(false) end)
music.MouseButton1Click:Connect(function() musicOn=not musicOn; applyMusic() end)
effects.MouseButton1Click:Connect(function() effectsOn=not effectsOn; applyEffects() end)
hud.MouseButton1Click:Connect(function() hudOn=not hudOn; applyHud() end)
player.PlayerGui.ChildAdded:Connect(function(child)
  if not hudOn and child:IsA('ScreenGui') and child ~= gui then child.Enabled=false end
end)
Lighting.ChildAdded:Connect(function(child)
  if not effectsOn and child:IsA('PostEffect') then
    originalPostEffects[child] = child.Enabled
    child.Enabled = false
  end
end)
