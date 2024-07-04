Lost & Forgotten Island
=======================
Ken Modesitt and Jeffery Yuan, 1980

Perl conversion by Greg Kennedy, 2021

Overview
--------
This is a Perl conversion of the simulation game "Lost & Forgotten Island" by Ken Modesitt and Jeffery Yuan.  The game first appeared in Creative Computing, March 1980, although the code hints at a previous version from 1976.

The object of the game is to escape a deserted island before a hurricane hits, by repairing the ship in the days leading up to the storm's arrival.  However, there is also treasure on the island, and players' individual score is based on the amount of gold they manage to carry out.  Striking a balance between cooperative boat repair and every-man-for-himself gold digging poses an interesting strategic consideration.

This version is based on the printout in "Big Computer Games", a collection of BASIC games edited by David Ahl and published in 1984.  The original code appears somewhat rushed: there are unreachable code blocks, and bugs that can appear when playing the game a second time through.  There are also hints at places to expand the game.  I have rebuilt this in Perl using modern practices, which should preserve the original formulas and gameplay while using sensible variable names and data structures.

Original Description
--------------------
**Lost & Forgotten Island** was passed along to us by Ken Modesitt of Texas Instruments and converted to Microsoft Basic by Jeffery Yuan.  It first appeared in *Creative Computing*, March 1980.

Lost & Forgetten Island is a game of survival for one to three players.  Unlike other similar games, to survive requires cooperation and joint decision-making among players.

In the scenario, you and all the other players have been shipwrecked and are now stranded on a remote island in the Pacific Ocean.  Also on the island is a pirate's cache of buried treasure and, of course, your damaged ship.  To complicate matters, a typhoon is approaching.

On each turn, each player must make a decision as to whether to do repair work on the ship or to dig for gold.  The longer you remain on the island collecting treasure, the higher the risk that the typhoon will catch up with your ship when you leave the island.

In addition to your race against the approaching typhoon, you will encounter other problems - mainly injuries from mishandling your tools or explosives.  You may trade tools among players for either other tools or gold.  Certain tools will perform two functions, although using a tool for the wrong function will diminish its ability to perform its main function.  For example, using an axe to dig dulls it and makes it less useful for cutting down trees for ship repairs.

There are several ways in which the game can end, some of which are not at all pleasant.  But with persistence, sensible decisions, and cooperation among players, you can all make it back to safety with enough gold to buy a fleet of Rolls Royces.  Good Luck!
