This is B.J. Black, the hero who will save the world.

The code in this repository is my Mon-musu Quest: Paradox RPG bot. Currently, it runs in the Catalyst Chapter; the other chapters aren't out yet.

Let me simply describe how to use this program, for beginners.

First, running the program won't appear to do much (it will add an icon to the task bar); that's because the bot starts in an idle state, waiting for user input.

There are several routines that the bot can run; you can cycle between them using the F7 hotkey, which will also pop up a TrayTip for your information.

Once you've chosen a routine to run, press F5 to run it. While it's running, you can press F5 again to pause it, or F8 to terminate the routine and return to the idle state.

I'd like to specifically disclaim that, since this bot analyzes the video output of the game, differences in video rendering between my computer and yours may result in our video outputs being slightly different; in that case, the bot simply won't understand your video output unless you fix the configuration files, which is WAY beyond the scope of this README.

You can use CheatEngine in conjunction with this bot. If you set CheatEngine hotkeys to "9" and "0", this bot will press those keys at certain points. It presses the "9" key when it wants the game to go fast, and the "0" key when it wants to go slow.

Here is a list of the routines you can run, and a description of what they do and what preconditions they require (they all require you to be running the game, with the game as the active window, on your primary monitor):

MonmusuSeedGrind
	This will grind seeds. To be specific, it will run back and forth on the map, check encounters for enemies that have seeds to steal, and steal them (and kill the enemy). It runs from other enemies.
	Every hour and a half, it will use all of the current seed and save the game.
	Preconditions:
		Be on a map that has applicable enemies. The maps I choose are the first hostile map in the ruins under Luddite (for Speed Seeds), the beach map (not "an area of the beach on the overmap") near Nataliaport (for Defense Seeds), and the northwest zone of the desert ruins (for Strength Seeds).
		Have a thief (or thieves) leading your party, with Banditry skills right next to the Attack command, and with an active skill in the Banditry menu that steals items. I use Mini; as a Harpy, she gets Midare Nusumi ("Steal like crazy", perhaps?), which frequently steals at least once from all enemies.
		Set the active save slot to a slot you don't mind overwriting. This routine will overwrite it.
		Set the active item and active character to be the Seed and character you are stealing and empowering, respectively. When the routine goes to use the seeds, it will open the menu, go to the item menu, and use whatever item is active, on whatever character is active; the routine can't tell the difference between one item or character and another. The easy way to do this is to use one of the given seeds on the given character right before starting the script.
			(If you ever think to message me, "I did that right before using a Harpy Feather to get to the zone, and it didn't work," then you need to, first, slap yourself; second, find a friend to slap you; and, finally, slap yourself again.)
		The characters other than the thief I equip with Berserk masks so the bot doesn't have to tell them to attack, but this is merely a preference; you may elect not to forgo it. Be aware that Berserk takes a long time for characters that have a lot of skills, even if they can only use a few of them; my fighter characters are second-stringers that have only a couple classes and races mastered so they don't have many skills at all.

MonmusuStealGrind
	This will steal from random encounters. It runs back and forth, stealing from every encounter.
	Every hour and a half, it will use all of the current seed and save the game.
	Preconditions:
		Be on a map that has random encounters.
		Have a thief (or thieves) leading your party, with applicable skills right next to the Attack command, and with an active skill in the skill menu that steals items. For instance, several Banditry skills steal items, but Cooking also has a skill that steals food, Maidery has one that steals milk, and Special has one that steals panties.
		Set the active save slot to a slot you don't mind overwriting. This routine will overwrite it.
		Again, characters other than the thieves I equip with Berserk masks so the bot doesn't have to tell them to attack.

MonmusuReplaySteal
	This will steal from replays in the Underworld.
	It cannot save.
	Preconditions:
		Be in the replay menu at the bookcase in the Underworld, with the desired enemy selected.
		Have a thief (or thieves) leading your party, with applicable skills right next to the Attack command, and with an active skill in the skill menu that steals items. For instance, several Banditry skills steal items, but Cooking also has a skill that steals food, Maidery has one that steals milk, and Special has one that steals panties.
		Again, characters other than the thieves I equip with Berserk masks so the bot doesn't have to tell them to attack.

MonmusuAssist
	This will steal from and kill random encounters. Unlike the above routines, it will not attempt to get into random encounters; it will only respond to them as it sees them. I use it in the Labyrinth of Chaos so I don't have to pay much attention to every little battle.
	It cannot save.
	Preconditions:
		Have a thief (or thieves) leading your party, with applicable skills right next to the Attack command, and with an active skill in the skill menu that steals items. For instance, several Banditry skills steal items, but Cooking also has a skill that steals food, Maidery has one that steals milk, and Special has one that steals panties.
		Again, characters other than the thieves I equip with Berserk masks so the bot doesn't have to tell them to attack.

Mash
	This will mash the "Z" key until you stop it. I forget why I wrote it.
	Edit: I remember (probably)! This lets you buy lots of items from the casino vendors, who don't let you buy 99 items all at once.
	Preconditions:
		None.

BuyCoins
	This routine will buy coins from the casino vendors.
	Preconditions:
		Be standing on the map, facing one of the two casino vendors.
		Have lots of gold.

Thieves
	This routine will change the number of thieves that the first four routines will know you have. Each time you use it, a TrayTip will pop up showing the current number of thieves the routines will use.
	Preconditions:
		None.
