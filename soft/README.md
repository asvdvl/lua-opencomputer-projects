# bigreactors_reactor_control.lua
reactor control, controlling reactor of BigReactors mod. connecting to computer port on reactor and need connect notify interface from random things(you can cut some code to fix it)

# anti_weather.lua 
set weather on clean and day. require debug card.

# ic_reactor_protect
protecting reactor from meltdown. 
1. can read status of batbuffers(now only from gregtech)
2. can output high redstone signal if reactor overheat.
3. have 3 way to connect to reactor(reactor chamber, core(central block), by id)\
**require setting.lua**(you can find it [here](https://github.com/asvdeveloper/lua-opencomputer-projects/blob/master/libs/settings.lua))

# monitor_binder.lua 
bind gpu on specifed monitors.
- need table ```{
{"gpu_addr", "monitor_addr"},
{"gpu_addr", "monitor_addr"},
...
}```

# simply_background_receiver.lua 
a small program for receiving messages from a modem and printing a message in a chat(need chat upgrade from computronics). also does not block the terminal.

# simply_chest_and_battery_checker.lua 
small program for calculating the fullness of the buffer chest and the remaining energy in the batbuffer. sends a message via modem if the buffer chest is full or out of energy(you can receive this messages witn __simply_background_receiver.lua__)

# turn_off_if_some_people_tuch_computer.lua
just shuts down the computer if an unwanted player touches the computer. 
- set ```mode``` variable ```0``` for black list mode(turn off if these players have call the event) and ```1``` for white list mode(turn off if all but these players have call the event)
- fill table users as ```{
"nick 1",
"nick 2",
...
}``` for for block or ignore this players

