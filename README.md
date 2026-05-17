![Build Status](https://github.com/sspivey98/Xenotactic/actions/workflows/build.yml/badge.svg)
# XenoTactic Remastered
This is a remaster of the browser game, Xeno Tactic, in Love2d. I'm aiming to reproduce the behavior of version 1.3.
![Sample](sample.jpg)

## Reference
You can play the original game [here](https://www.newgrounds.com/portal/view/382321).

## Differences from the original
- Shift + Left Click can place multiple
- User can send next wave before current wave is complete
- DCA shoots 50% faster
- password level unlock system
- DCA level 6 has a significant buff with more damage, range, and lower cost
- Helicopters in level 6 waves 50-100 have less health
- Sonic turrets have a higher stun chance
- splitters now add up to the parent enemy value, effectively doubling the value of a slime
- selecting an enemy prioritizes the turret to target selected enemy
- turrets have tooltips

## Developing
It is highly recommend that you use the following extensions in `VS Code` or `VSCodium`:

| Feature | Code Extension | Codium Extension |
| ------- | -------------- | ---------------- |
| Debugger | [Local Lua Debugger](https://marketplace.visualstudio.com/items?itemName=ismoh-games.second-local-lua-debugger-vscode) | [Second Local Lua Debugger](https://open-vsx.org/extension/tomblind/local-lua-debugger-vscode) |
| Weak Typing | [Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) | [Lua](https://open-vsx.org/extension/sumneko/lua)

### Run it yourself

1.) Download `love2d`

2.) `love . --console`

or...

1.) run 'debug' on the `Local Lua Debugger`