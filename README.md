## Description ##

This is a modified ArkInventory that adds support for attunements.

## Installation ##

Download this repository, then extract the contents of the `src` directory into your `World of Warcraft/Interface/AddOns` directory.

## Custom rules ##

- `resist([resistName])` - Matches items that grant resistance. Can be called standalone `resist()` to match all resistances, or with specific resistances `resist('fire', 'frost')`.
- `mythic()` - Matches mythic items.
- `attunable()` - Matches items that can be attuned by the current character.
- `attunableatall()` - Matches items that can be attuned by anyone.
- `attuned()` - Matches items that have been attuned.
- `optimalforme()` - Matches items that are optimal for the current character.