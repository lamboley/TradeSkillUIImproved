# TradeSkillUIImproved

TradeSkillUIImproved improve the default tradeskill UI. His major feature allow the player to hide recipe in the tradeskill UI.

## Features

* Allow to change the size of the tradeskill UI with a slash command.
* Allow to move the tradeskill UI by dragging the top of the UI.
* Close the tradeskill UI with the echap key.
* Add two button for collapse and expand all recipe.
* Add two checkbox for filter has materials and has skill up.
* Replace the 'Quit' button by a button which print in chat the id of the selected recipe (recipeID).
* If the addon Auctionator is installed, hide the 'AH' button in the tradeskill UI.
* Add a system of blacklist of recipe for hidding them in the tradeskill UI.

## Slash command

TradeSkillUIImproved provide 7 slashs commands. 4 of them are used for managing the blacklist database, 2 of them are for controlling the height of the tradeskill UI and the last one is used for displayng the version of the addon.

```
/tsuii addBL recipeID
```

The `addBL` command will add a recipe in the blacklist. If you want to hide a recipe, this is the command you are looking for. For example, if I want to hide the recipe **Smelt Copper** you should do `/tsuii addBL 2657`. If the tradeskill UI was opened, you have to close it and reopen if for change take effect.

```
/tsuii delBL recipeID
```

The `delBL` command will remove a recipe if he exist in the blaclist. If you want to show a recipe you have hided, this his the command you are looking for. For example, if I want to show **Smelt Copper** again, you should do `/tsuii delBL 2657`. If the tradeskill UI was opened, you have to close it and reopen if for change take effect.

```
/tsuii showBL [substring]
```

The showBL commande with no argument will print in chat the content of the blacklist in the format index,recipeID,recipeName. If an argument his given, he will be used as a case sensitive pattern and will be checked in recipeID and nameRecipe. For example if we do /tsuii showBL tu, all recipe which have 'tu' in there name or in the recipeID will be displayed.

```
/tsuii isBL recipeID
```

The 'isBL' command will print in chat if the recipe is in the blacklist or not.

```
/tsuii setSize 30
```

Allow to change the height of the tradeskill UI. The default value for the blizzard's tradeskillUI is 25. This addon change it to 55 by default.

```
/tsuii getSize
```

Print in chat the value of the height of the tradeskill UI.

```
/tsuii version
```

Print the version of the addon in the chat frame.

## Localization

* English (arlaios)
* French (arlaios)

## Bugs know

* Filter check box are not cleaned when you change of profession (will be fixed in v1.0.3).
* Actually you cannot hide header and subheader, only the recipe can be hided (will be fixed in v1.0.3).

## Issues

* If you found a bug or have an error, you can create an issue on [github](https://github.com/lamboley/TradeSkillUIImproved/issues).
* If you have a general comment or concern, feel free to comment on the main page.
