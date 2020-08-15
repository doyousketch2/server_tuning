[![OpenSource](https://img.shields.io/badge/Open-Source-orange.svg)](https://github.com/doyousketch2)  [![Lua](https://img.shields.io/badge/Lua-LuaJIT-blue.svg)](https://www.lua.org)  [![License](https://img.shields.io/badge/license-AGPL--v3-lightgrey.svg)](https://www.gnu.org/licenses/agpl-3.0.en.html)  [![Git.io](https://img.shields.io/badge/Git.io-vx7WF-233139.svg)](https://git.io/vx7WF)  

# server_tuning
Minetest server script, to dynamically allocate resources as players join and part  

![image](https://raw.githubusercontent.com/doyousketch2/server_tuning/master/screenshot.png)  

---

Todo:  
- [x] calculate values based on # of active players  
- [x] clamp to min / max  
- [x] tell Minetest to actually set values  
- [x] test if it does as expected  

You'll want to back up your minetest.conf before using this.  
I don't have access to multiple people logging on to my home machine, 
...so I can't really test it.  I rely on your feedback.  

**If** it doesn't do as expected, just disable, then restore your minetest.conf file.  
Not a biggie.  Either way, you can look inside the code,  
and see all the settings it tweaks to gain performance.  

These are quite possibly the main settings to speed up your server.  
If I find other ones, especially in certain mods that make a difference, I'll add them.  
Let me know if you find any other tweaks that help.  
