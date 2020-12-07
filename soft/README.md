# bigreactorsControl.lua
reactor control, controlling reactor of BigReactors mod. connecting to computer port on reactor and need connect notify interface from random things(you can cut some code to fix it)

# antiWeather.lua
set weather on clean and day. require debug card.

# icReactorManadger.lua
protecting reactor from meltdown. 
1. can read status of batbuffers(now only from gregtech)
2. can output high redstone signal if reactor overheat.
3. have 3 way to connect to reactor(reactor chamber, core(central block), by id)\
**require setting.lua**(you can find it [here](https://github.com/asvdeveloper/lua-opencomputer-projects/blob/master/libs/settings.lua))

# draconicEvolutionReactorControl.lua
Automatically regulating input/output flux gates for supporting temperature and shield reactor.
Attention! This program only for max load reactor(8 awakened draconium block). But it can also work with average load. I recomend test this program in test world before use in main world.
Install:
1. Copy the code and paste into the editor in the game.(e.g. `edit reactor`)
2. Go to the user settings section at the beginning of the file.
3. Change arrdINRegulator and arrdOUTRegulator addresses on yours
4. Save file(Ctrl+S) and exit the editor(Ctrl+W) and run the program(type `reactor`)
Use:
1. Load fuel in reactor
2. Run program
3. Press the 's' button on the open screen to start the reactor or start the reactor in its interface
4. While the program is running, you can change the temperature and shield level from the keyboard. (Use 'h' for key help)
Attention! If you use intermediate buffers(e.g. draconic energy crystal), the program may not work stably with the shield at startup. Because when the reactor heats up a lot of energy remains in the intermediate crystals, which raises the shield level up to 90%, and algorithms trying to equalize this may allow the shield to drop to 20%, which is normal. Once the shield has stabilized, you can slowly lower it down to your desired level by up to 2%! However, if you connect the flux gate directly to the injector, then the shield works stably.

# monitorBinder.lua
bind gpu on specifed monitors.
- need table ```{
{"gpu_addr", "monitor_addr"},
{"gpu_addr", "monitor_addr"},
...
}```

# simplyBackgroundReceiver.lua 
a small program for receiving messages from a modem and printing a message in a chat(need chat upgrade from computronics). also does not block the terminal.

# simplyChestAndBatteryChecker.lua 
small program for calculating the fullness of the buffer chest and the remaining energy in the batbuffer. sends a message via modem if the buffer chest is full or out of energy(you can receive this messages witn __simply_background_receiver.lua__)

# protectComputerFromUntrustedUsers.lua
just shuts down the computer if an unwanted player touches the computer. 
- set ```mode``` variable ```0``` for black list mode(turn off if these players have call the event) and ```1``` for white list mode(turn off if all but these players have call the event)
- fill table ```users``` as ```{
"nick 1",
"nick 2",
...
}``` for block or ignore this players
- fill ```onEvents``` as ```{
{"event", 5(position in the table containing the nickname of the player who caused the event)},
{"event 2", 6}, ...}```
  - by default have ```key_down, key_up, touch, drop, motion(need motion sensor)``` events.

# simplyBlastfurnaceWorkControl.lua
a small program for Blastfurnace(mod: GregTech). This program switches Blastfurnace on or off depending on the state of batbuffer.

# simplyPyroliseControlWithLiquidOutput.lua 
a small program for Pyrolise Oven(mod: GregTech). This program switches Pyrolise Oven on or off depending on the count of fluid in tank.
