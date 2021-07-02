--lib
local cmp = require("component")
local monitor = cmp.get("700")
local gpu = cmp.gpu
local mat = require("math")
local event = require("event")

--var

local foreground = gpu.setForeground
local background = gpu.setBackground

local W, H = gpu.getResolution()
local b_color, f_color = gpu.getBackground(), gpu.getForeground()

--button massive
local databutton = {
    pause                  = {color = 0x0000FF, textColor = 0xffffff, X = W-16, Y = 1, W = 6, H = 5, text = "pause/resume", event = "control", give = " ", cost = " ", count = " "},
    start                  = {color = 0x0000FF, textcolor = 0xffffff, X = W-16, Y = 10, W = 6, H = 5, text = "start", event = "buy", give = ".", cost = "x", count = "1"},
    M16A4                  = {color = 0x0000FF, textColor = 0xffffff, X = 3, Y = 1, W = 2, H = 3, text = "AUTO_6.8 ", event = "buy", give = ".", cost = "50", count = "1"},
    M4A1                   = {color = 0x0000FF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "AUTO 7 ", event = "buy", give = ".", cost = "100", count = "1"},
    FNFAL                 = {color = 0x0000FF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "VINT 13 ", event = "buy", give = ".", cost = "300", count = "1"},
    WebleyMkVI           = {color = 0x0000FF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "PIST 7", event = "buy", give = ".", cost = "50", count = "1"},
    HKP2000               = {color = 0x0000FF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "PIST 5", event = "buy", give = ".", cost = "0", count = "1"},
    taurus                 = {color = 0x0000FF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "PIST 5.5", event = "buy", give = ".", cost = "25", count = "1"},
    Saiga410              = {color = 0x0000FF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "DROB 4.5/15(mag)", event = "buy", give = ".", cost = "300", count = "1"},
    Remington870Express  = {color = 0x0000FF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "DROB 5/10", event = "buy", give = "", cost = "150", count = "1"},
    M249                   = {color = 0x0000FF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "MGun 7", event = "buy", give = ".", cost = "250", count = "1"},
    SprigfieldM1903A3     = {color = 0x0000FF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "VINT 27", event = "buy", give = ".", cost = "300", count = "1"},
    rnd20556x45mmmagazine  = {color = 0xFFFFFF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "20rnd 5.56x45mm", event = "buy", give = ".", cost = "50", count = "1"},
    rnd30556x45mmMagazine = {color = 0xFFFFFF, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "30rnd 5.56x45mm", event = "buy", give = ".", cost = "100", count = "1"},
    rnD                   = {color = 0xFFFFFF, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "40rnd 5.56x45mm", event = "buy", give = ".", cost = "150", count = "1"},
    rnd100556x45mmMagazine = {color = 0xFFFFFF, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "100rnd 5.56x45mm", event = "buy", give = ".", cost = "250", count = "1"},
    rnd200556x45mmMagazine = {color = 0xFFFFFF, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "200rnd 5.56x45mm", event = "buy", give = ".", cost = "400", count = "1"},
    Bullet556x45mmNATO = {color = 0xFFA500, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "5.56x45mm", event = "buy", give = ".", cost = "30", count = "64"},
    mag20rnd762x51mm     = {color = 0xFFFFFF, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "20rnd 7.62x51mm", event = "buy", give = ".", cost = "100", count = "1"},
    mag2015rnd9mmMagazine     = {color = 0xFFFFFF, textcolor = 0x0000FF, X = 1, Y = 1, W = 2, H = 3, text = "15rnd 9mm", event = "buy", give = ".", cost = "20", count = "1"},
    mag15rnd45ACPMagazine     = {color = 0xFFFFFF, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "15rnd .45 ACP", event = "buy", give = ".", cost = "50", count = "1"},
    mag7rnd410ShellMagazine     = {color = 0xFFFFFF, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "7rnd_.410", event = "buy", give = ".", cost = "200", count = "64"},
    bull762x51mmNATOBullet     = {color = 0xFFA500, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "7.62x51mm", event = "buy", give = ".", cost = "100", count = "64"},
    bull3006springfieldBullet     = {color = 0xFFA500, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = ".30-06", event = "buy", give = ".", cost = "200", count = "64"},
    bull455WebleyMkIIBullet     = {color = 0xFFA500, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = ".455", event = "buy", give = ".", cost = "100", count = "64"},
    ball9mmBullet     = {color = 0xFFA500, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "9mm", event = "buy", give = ".", cost = "50", count = "64"},
    bull45ACPBullet     = {color = 0xFFA500, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = ".45", event = "buy", give = ".", cost = "60", count = "64"},
    shell12Gaugeshotgun_shell     = {color = 0xFFA500, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "12_Gauge", event = "buy", give = ".", cost = "150", count = "64"},
    shel410Shell     = {color = 0xFFA500, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = ".410", event = "buy", give = ".", cost = "200", count = "64"},
    Knife = {color = 0x0000FF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "Knife", event = "buy", give = ".", cost = "50", count = "1"},
    Totem = {color = 0xFFD700, textcolor = 0x000000, X = 1, Y = 1, W = 2, H = 3, text = "1 LIVE", event = "buy", give = ".", cost = "500", count = "1"},
    MivroT1 = {color = 0xEE82EE, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 13, text = "(MOD)Mivro-T1", event = "buy", give = ".", cost = "50", count = "1"},
    EOTech_Hologrphic = {color = 0xEE82EE, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "(MOD)Hologrphic", event = "buy", give = ".", cost = "50", count = "1"},
    UTGTacticalLaser = {color = 0xEE82EE, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "(MOD)Laser", event = "buy", give = "0", cost = "25", count = "1"},
    Bipod = {color = 0xEE82EE, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "(MOD)Bipod", event = "buy", give = ".", cost = "25", count = "1"},
    Helmet = {color = 0x808000, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "Helmet", event = "buy", give = ".", cost = "50", count = "1"},
    Chestplate = {color = 0x808000, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "Chestplate", event = "buy", give = ".", cost = "50", count = "1"},
    Boots = {color = 0x808000, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "Boots", event = "buy", give = ".", cost = "50", count = "1"},
    GasMask = {color = 0x808000, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "Gas Mask", event = "buy", give = ".", cost = "100", count = "1"},
    GasDetector = {color = 0x808000, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "Gas Detector", event = "buy", give = ".", cost = "100", count = "1"},
    GasGrenade = {color = 0x808000, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "Gas Grenade", event = "buy", give = ".", cost = "50", count = "1"},
    Grenade42 = {color = 0x0000FF, textcolor = 0xffffff, X = 1, Y = 1, W = 2, H = 3, text = "Grenade", event = "buy", give = ".", cost = "50", count = "1"}
 
}
    
--pre-load
gpu.bind(monitor)
background(0x0)
gpu.fill(1, 1, W, H, " ")

--load
local function draw(but)
  print("                                              "..but)
  foreground(databutton[but].textColor)
  background(databutton[but].color)
  print("заливаю")
  gpu.fill(databutton[but].X, databutton[but].Y, (databutton[but].W+string.len(databutton[but].text)), databutton[but].H, " ")
  print("пишу")
  gpu.set((databutton[but].X+(databutton[but].W/2)),      (databutton[but].Y+((databutton[but].H-1)/2)),      databutton[but].text)
end

for butt, _ in pairs(databutton) do
  draw(butt)
end

gpu.bind(cmp.get("3511"))
--events

while true do 
  local e = {event.pull()}
  print("1")
  if e[1] == "touch" then
    print("2")
    for butt, _ in pairs(databutton) do
      print("3")
      if databutton[butt].X <= e[3] and databutton[butt].W+databutton[butt].X+string.len(databutton[butt].text) >= e[3] and databutton[butt].Y <= e[4] and databutton[butt].Y+databutton[butt].H >= e[4] then
        event.push(databutton[butt].event, databutton[butt].text, databutton[butt].give, databutton[butt].cost, databutton[butt].count)
      end      
    end
  end
end