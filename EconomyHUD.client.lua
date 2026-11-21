-- ANMOL LIVING WORLD — Mobile coins, village shop, coin trade GUI V1
-- LocalScript -> StarterPlayer > StarterPlayerScripts
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local events=RS:WaitForChild("AnmolEconomy")
local Action=events:WaitForChild("Action")
local Update=events:WaitForChild("Update")
local TradeOffer=events:WaitForChild("TradeOffer")
local OpenShop=events:WaitForChild("OpenShop")
local gui=Instance.new("ScreenGui")
gui.Name="AnmolEconomyHUD";gui.ResetOnSpawn=false
-- Avoid covering Roblox topbar and other game HUDs.
gui.Parent=player:WaitForChild("PlayerGui")
local function box(parent,name,pos,size,visible)
 local f=Instance.new("Frame");f.Name=name;f.Position=pos;f.Size=size
 f.BackgroundColor3=Color3.fromRGB(18,35,40);f.BackgroundTransparency=.1
 f.Visible=visible;f.Parent=parent
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,12)
 return f
end
local function label(parent,text,pos,size)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size
 t.Text=text;t.TextColor3=Color3.fromRGB(238,255,242);t.TextScaled=true
 t.Font=Enum.Font.GothamBold;t.Parent=parent;return t
end
local function button(parent,text,pos,size,callback)
 local b=Instance.new("TextButton");b.Position=pos;b.Size=size;b.Text=text
 b.TextScaled=true;b.Font=Enum.Font.GothamSemibold
 b.TextColor3=Color3.fromRGB(255,255,255);b.BackgroundColor3=Color3.fromRGB(48,105,90)
 b.Parent=parent;Instance.new("UICorner",b).CornerRadius=UDim.new(0,9)
 b.Activated:Connect(callback);return b
end
local top=box(gui,"CoinTop",UDim2.new(1,-152,0,108),UDim2.fromOffset(140,42),true)
local balance=label(top,"🪙 --- Coins",UDim2.fromScale(.04,.08),UDim2.fromScale(.92,.84))
local status=label(gui,"",UDim2.new(.17,0,1,-82),UDim2.new(.66,0,0,37))
status.BackgroundTransparency=.35;status.BackgroundColor3=Color3.fromRGB(15,30,36)
status.Visible=false
local function notice(s)
 status.Text=tostring(s);status.Visible=true
 task.delay(3,function() if status.Text==s then status.Visible=false end end)
end
local shop=box(gui,"VillageShop",UDim2.fromScale(.5,.25),UDim2.fromOffset(300,360),false)
shop.AnchorPoint=Vector2.new(.5,0)
label(shop,"🏡 HEART VILLAGE SHOP",UDim2.fromOffset(12,10),UDim2.fromOffset(272,34))
button(shop,"✕",UDim2.fromOffset(256,48),UDim2.fromOffset(30,28),function()shop.Visible=false end)
local listing={
 {"1 Wood — 4 🪙","WoodBundle"},
 {"1 Stone — 5 🪙","StoneBundle"},
 {"1 Fiber — 4 🪙","FiberBundle"},
 {"1 Crystal — 35 🪙","CrystalBundle"},
}
for i,item in ipairs(listing) do
 button(shop,item[1],UDim2.fromOffset(16,82+(i-1)*62),UDim2.fromOffset(268,49),function()
  Action:FireServer("Buy",item[2])
 end)
end
local trade=box(gui,"TradePanel",UDim2.fromScale(.5,.25),UDim2.fromOffset(305,310),false)
trade.AnchorPoint=Vector2.new(.5,0)
label(trade,"🪙 COIN TRADING",UDim2.fromOffset(10,10),UDim2.fromOffset(255,33))
button(trade,"✕",UDim2.fromOffset(263,8),UDim2.fromOffset(32,32),function()trade.Visible=false end)
label(trade,"Recipient Username",UDim2.fromOffset(10,53),UDim2.fromOffset(275,24))
local nameBox=Instance.new("TextBox");nameBox.Position=UDim2.fromOffset(15,85);nameBox.Size=UDim2.fromOffset(275,40)
nameBox.PlaceholderText="Exact Roblox username";nameBox.Text="";nameBox.TextScaled=true
nameBox.BackgroundColor3=Color3.fromRGB(230,240,231);nameBox.Parent=trade
Instance.new("UICorner",nameBox).CornerRadius=UDim.new(0,8)
label(trade,"Amount",UDim2.fromOffset(15,135),UDim2.fromOffset(275,24))
local amountBox=Instance.new("TextBox");amountBox.Position=UDim2.fromOffset(15,168);amountBox.Size=UDim2.fromOffset(275,40)
amountBox.PlaceholderText="1 - 1000 coins";amountBox.Text="25";amountBox.TextScaled=true
amountBox.BackgroundColor3=Color3.fromRGB(230,240,231);amountBox.Parent=trade
Instance.new("UICorner",amountBox).CornerRadius=UDim.new(0,8)
button(trade,"Send Trade Offer",UDim2.fromOffset(15,230),UDim2.fromOffset(275,50),function()
 local other=Players:FindFirstChild(nameBox.Text)
 local n=tonumber(amountBox.Text)
 if not other or not n then notice("Username/amount invalid") return end
 Action:FireServer("Offer",other.UserId,n)
end)
local offer=box(gui,"IncomingTrade",UDim2.fromScale(.5,.33),UDim2.fromOffset(300,155),false)
offer.AnchorPoint=Vector2.new(.5,0)
local offerLabel=label(offer,"Incoming trade",UDim2.fromOffset(10,12),UDim2.fromOffset(280,75))
local offerId=nil
button(offer,"Accept",UDim2.fromOffset(12,103),UDim2.fromOffset(130,43),function()
 if offerId then Action:FireServer("Accept",offerId) end;offer.Visible=false;offerId=nil
end)
button(offer,"Decline",UDim2.fromOffset(155,103),UDim2.fromOffset(130,43),function()
 if offerId then Action:FireServer("Decline",offerId) end;offer.Visible=false;offerId=nil
end)
local tradeButton=button(gui,"🪙 Trade",UDim2.new(1,-138,0,158),UDim2.fromOffset(126,40),function()
 trade.Visible=not trade.Visible;shop.Visible=false
end)
OpenShop.OnClientEvent:Connect(function() shop.Visible=true;trade.Visible=false end)
Update.OnClientEvent:Connect(function(kind,value)
 if kind=="Coins" then balance.Text="🪙 "..tostring(value).." Coins"
 elseif kind=="Message" then notice(value) end
end)
TradeOffer.OnClientEvent:Connect(function(id,displayName,coins)
 offerId=id;offerLabel.Text=tostring(displayName).." offers you "..tostring(coins).." coins";offer.Visible=true
end)
Action:FireServer("Sync")
