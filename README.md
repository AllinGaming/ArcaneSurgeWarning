# ArcaneSurgeWarning

## Description

`ArcaneSurgeWarning` is a World of Warcraft 1.12.1 addon designed to track the activation and deactivation of the "Arcane Surge" spell. It displays a warning icon when the spell is active, along with a countdown timer. The addon also includes functionality to lock or unlock the icon's position on the screen.

## Features

- **Arcane Surge Detection**: The addon listens for the "Arcane Surge" spell being activated and deactivated.
- **Warning Icon**: Displays an icon that changes when "Arcane Surge" is active. The icon is initially greyed out and becomes fully visible when the spell is active.
- **Countdown Timer**: Shows a countdown on the icon for the duration of the "Arcane Surge" effect.
- **Icon Movement**: The icon can be moved around the screen by holding the Shift key while dragging it.
- **Lock/Unlock Icon**: The icon position can be locked or unlocked with the `/lockicon` command.

## Installation

1. Download the addon files.
2. Place the `ArcaneSurgeWarning` folder into your World of Warcraft `Interface/AddOns` directory.
3. Make sure the addon is enabled in the character selection screen by clicking "AddOns" and checking `ArcaneSurgeWarning`.

## Commands

- `/lockicon`: Lock or unlock the position of the warning icon. When unlocked, hold `Shift` and drag the icon to move it.

## How It Works

- **Event Handling**: The addon listens to the `COMBAT_TEXT_UPDATE` and `CHAT_MSG_SPELL_SELF_DAMAGE` events.
  - When the "Arcane Surge" spell is activated, the addon will show the warning icon.
  - When the "Arcane Surge" spell ends (as detected by the "SPELL_ACTIVE" message or the self-damage message), the warning icon is hidden, and the countdown is reset.

## Configuration

No manual configuration is required, but the following can be customized:
- **Icon Texture**: The default icon texture is `INV_Enchant_EssenceMysticalLarge`, but you can change it in the Lua script.
- **Countdown Timer Font and Color**: The countdown uses the `Fonts\\FRIZQT__.TTF` font with a size of 20. You can change the font size, color, and style in the Lua script.