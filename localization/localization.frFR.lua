local _, addon = ...

local L = addon.L

if GetLocale() == "frFR" then
    L["A reload is |cffffff00necessary|r."] = "Un rechargement de l'interface est |cffffff00nécéssaire|r."
    L["Add a recipeID in the blacklist."] = "Ajoute un recipeID dans la blacklist."
    L["Allow to change the factor of the size of the tradeskill UI.\n\nDefault is 55 and Blizzard\"s default is 27.\n\nA reload is necessary."] = "Permet de changer le facteur de taille de la fenêtre d'artisanat.\n\nLa valeur par défaut est 55, celle de blizzard est 27.\n\nUn rechargement est nécessaire."
    L["Arguments :"] = "Arguments :"
    L["Change the color of an icon if the item (merchant, auction, bag, bank) is already learned.\n\nA reload is necessary."] = "Change la couleur de l'icône (Marchant, Hôtel de vente, Sac, Banque de guile) si l'objet est déjà appris.\n\nUn rechargement est nécessaire."
    L["Change the color of an icon if the item is already learned."] = "Change la couleur de l'icône si l'objet est déjà appris."
    L["Content of the blacklist :"] = "Contenu de la blacklist :"
    L["Content of the blacklist with the pattern"] = "Contenu de la blacklist avec le pattern"
    L["Delete the recipeID from the blacklist."] = "Supprime le recipeID de la blacklist."
    L["has been added in the blacklist."] = "a été ajouté dans la blacklist."
    L["has been removed from the blacklist."] = "a été supprimé de la blacklist."
    L["Hide the AH button if the addon Auctionator is loaded."] = "Cache le bouton AH si l'addon Auctionator est activé"
    L["is already in the blacklist."] = "est déjà dans la blacklist."
    L["is in the blacklist."] = "est dans la blacklist."
    L["is not in the blacklist, there is nothing to remove."] = "n'est pas dans la blacklist, il n'y a donc rien à enlever."
    L["isn't in the blacklist."] = "n'est pas dans la blacklist."
    L["No recipe is selected."] = "Aucune recette n'est séléctionnée."
    L["Show if the recipeID is in the blacklist."] = "Affiche si le recipeID est dans la blacklist."
    L["Show the data of the blacklist. If an argument is passed, a pattern case-sensitive while be executed on the recipeID and the name."] = "Affiche le contenu de la blacklist. Si un argument est passé, un pattern sensible à la casse sera fait sur le recipeID et le nom."
    L["Show the option window."] = "Affiche la fenêtre des options."
    L["Show the version of the addon."] = "Affiche la version de l'addon."
    L["Size factor"] = "Facteur de taille"
    L["substring"] = "sous-chaîne"
    L["The addon Auctionator had a button in the tradeskill UI. This options allow you to hide that button.\n\nA reload is necessary."] = "L'addon Auctionator ajoute un bouton dans la fenêtre d'artisanat. Cette option vous permet de cacher ce bouton.\n\nUn rechargement est nécessaire."
    L["The blacklist is empty."] = "La blacklist est vide."
    L["The clicked categoryID is"] = "Le categoryID cliqué est"
    L["The recipeID"] = "Le recipeID"
    L["The selected recipeID is"] = "Le recipeID selectionné est"
    L["The version of the addon is"] = "La version de l'addon est"
end

addon.L = L
