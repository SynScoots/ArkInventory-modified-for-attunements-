## Description ##

This is a modified ArkInventory that adds support for attunements. Additionally, there are some extra display options available via `/ai config`.

## Installation ##

Download this repository, then extract the contents of the `src` directory into your `World of Warcraft/Interface/AddOns` directory.

## Custom rules ##
For help with rules, see [the rules wiki](https://github.com/arkayenro/arkinventory/wiki/Rules) - please note some of the rule functions shown on this wiki will be from newer versions of the game only.

- `resist([(string) resistName])` - Matches items that grant resistance. Can be called standalone `resist()` to match all resistances, or with specific resistances `resist('fire', 'frost')`.
- `mythic()` - Matches mythic items.
- `attunable()` - Matches items that can be attuned by the current character.
- `attunableatall()` - Matches items that can be attuned by anyone.
- `attuned()` - Matches items that have been attuned.
- `attunedanyaffix([(integer) forgelevel])` - Matches items which you have attuned any affix for. Pass a number 0 - 3 to specify the minimum forgelevel it must have been attuned at (0 = unforged, 1 = titanforged, 2 = warforged, 3 = lightforged). Leave blank to use the forge level of the item  in your inventory.
- `optimalforme()` - Matches items that are optimal for the current character - e.g. leather for rogues and druids, plate and low level mail for warriors, paladins, and deathknights etc.
- `hasbounty([(integer) gold])` - Matches items which have an active bounty. Optionally specify a minimum gold value for the bounty.
- `hasaffix()` - Matches items which have an affix (e.g. "Of the Eagle", "Of the Bandit", etc.)
