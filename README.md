# PMAC - Paramour Multi-Animation Controller
Animation system for OpenSim that uses OSSL functions.
Credits go to Aine Caoimhe
http://ainetutorials.blogspot.com/2017/07/major-release-pmac-25-with-rlv-and.html
http://ainetutorials.blogspot.com/2015/08/tutorial-new-pmac-system-from-scratch.html


## OVERVIEW

The Paramour Multi-Animation Controller (PMAC) is a no-poseball script system
intended for use in 
almost any piece of furniture that needs to be able to position and animate
multiple avatars at once. 
PMAC is designed to offer a high performance alternative to existing systems
such as MLP, nPose, and 
xPose. PMAC uses a core engine that leverages the powerful OSSL functions
available only in Opensim
 to drastically increase the script's speed and reliability, while at the same
time using only a
 fraction of the sim resources of the existing systems.

## KEY FEATURES *****

* WORKS IN ANYTHING - The PMAC system can be put into anything, from a
single-prim scultpy blanket or 
one-piece mesh sofa to an elaborate multi-piece bedroom linkset. You can put it
in a simple pine cube 
prim if you feel like it. There's nothing extra to attach and hide or position
nearby. All it takes 
is a single prim. The only "requirement" is that PMAC must be in the root prim
of an object.

* NO POSEBALLS - There are no poseballs used at all for PMAC. None to disguise
or hide as part of the
 furniture, none that have to be rezzed and sat on, none to get lost inside a
sofa or buried underground
 or scattered around a sim...all of the users simply sit on the furniture item
that contains the main 
script and PMAC takes care of the rest using a "virtual poseball" approach that
exists within the logic of the script.

* A TRUE MULTI-AVATAR CONTROLLER - PMAC systems can be set up to handle
animations designed for 1 to as
 many as 9 avatars with the flexibility to load any preset configuration on the
fly. You could set it up
 in a sofa to act like a sit AO when you're lounging around alone, and quickly
turn it into a couples 
controller when that special someone comes to visit, and then switch it into a
multi-person handler
 when you have even more company...and it's all available virtually instantly
from the menu without 
the need to stand up or reset...all adjustments are done on the fly during use.
Now your VL furniture
 items can be just as flexible as your RL ones are.

* REGION-FRIENDLY - Most multi-avatar controllers are pretty harsh on a
simulator, eating up valuable 
cycles, and memory and other script resources. PMAC's extensive use of OSSL
functions allows it to 
drastically reduce this overhead. The core PMAC system is a single script. Yep,
a fully functional 
controller for up to 9 avi all done with one low-footprint script. When not in
use, it is completely 
dormant and uses virtually no simulator resources at all (just the tiny amount
of memory required for 
the script itself). Even when in use, the system's footprint barely changes --
unlike SL systems with 
poseball scripts, animation handler scripts, multiple timers, multiple
listeners, high message traffic, 
large menu memory consumption, and all the other complications that LSL-based
scripts are subject to. 
Even with 9 avatars seated all it uses is a single script and single listener.
The only time it ever uses a timer is on those rare occasions when you're
editing positions or setting up a new system.

* SPEED - The total time to initialize a typical PMAC system is approximately
one second. That's right, 
just 1 second! If for some reason you need to reset it you'll be ready to use it
again almost instantly. 
Due to its unique OSSL-based menu method, PMAC dialogs pop up right away even
for very extensive set-ups 
with hundreds of different animations.

* SYNCH - PMAC uses the tried and true Paramour synch method, keeping up to 9
avatars moving in perfect 
unison once their animations are in your viewer's cache.

* FULL NPC INTEGRATION - Want some company but none of your friends are online?
PMAC can rez a NPC 
(or two, or three, or up to eight!) to join you instead. When you're done, PMAC
tucks them away again 
for next time. You can pick who, where, and when at the touch of a few simple
dialog buttons.


* AUTO-MODE - Don't want to have to change your own animations? Simply engage
PMAC's auto mode and
 let the system do it for you, more or less like engaging a sit AO for up to 9
people. Timing can be chosen from a variety of options and changed on the fly;
and you can configure the system to engage it automatically so you can have your
furniture fully useable without ever even needing to see a dialog (but of course
you can simply touch the object to bring up the menu and disengage this at any
time).

* SWAPPING - You can quickly and easily swap positions with anyone else -- even
if they aren't there
 and it's just an unoccupied "virtual position".

* AUTO HEIGHT ADJUSTMENTS - PMAC automatically adjusts positions based on each
avatar's height (although admittedly this is a very rudimentary estimate and
depends a lot on how the original animation was created). In many cases this
will be sufficient unless you have a very tall or short avatar.

* ON-THE-FLY POSITION ADJUSTMENTS - The owner can make more detailed adjustments
to animation positioning at any time, rapidly and on the fly, and it remains
temporarily stored in the script's memory.

* NO NOTECARD EDITING FOR USERS - If the owner wishes to persist any position
adjustments to the system's notecards, PMAC facilitates this by handling it all
done with the touch of a single dialog button. No more copy-pasting reams of
text from chat into a notecard and hoping you don't mess something up! Typically
the only time you'll manually open and edit a notecard is when making major
changes such as adding new animations or deleting existing ones.

* EASY CONFIGURATION - PMAC can be fully configured in the script or via an
optional configuration notecard which some users might find a little less
intimidating to do.

* USER ACCESS RESTRICTIONS - The PMAC system has a variety of settings allowing
you to control who can use it, who can access which menus or animations, who can
rez which NPCs, and other similar access-control restrictions.

* POWERFULL ADD-ON COMMAND SYSTEM INTEGRATION - As a design goal, I wanted the
PMAC system to be easy and intuitive enough to just "rez and play" without what
can be a rather nasty learning curve of many other systems. I also felt it was
imperative to optimize PMAC's performance, simulator footprint, and XEngine
demands. As a result, only the most important and commonly-demanded features are
part of the core "out of the box" PMAC system. But I also wanted to offer the
flexibility  for more advanced builders and users to enhance its functions,
capabilities and offerings, so PMAC incorporates an integrated and extremely
powerful command system that opens up almost endless possibilities via the use
of scripted add-ons. If PMAC doesn't do something you want it to do, it's very
likely that an add-on can be scripted to do it in conjunction with PMAC's
command system -- at the expense of the additional script(s) overhead. I will
likely create add-ons for the most often-requested extra features; but anyone
with reasonable scripting skills can write their own custom applications for
specialized requirements. The only limits are likely to be your imagination (and
ability to script it).

* FREE - The PMAC system is the culmination of many months of work and almost 5
years of development and testing of various approaches to making the "next
generation" multi-avatar controller, and I'm releasing it to the Opensim
community for free (under Creative Commons Attribution-Non-Commercial-ShareAlike
4.0 International license). Any add-ons I create for it in future will be free,
too, and I sincerely hope that other add-on creators will follow suit and donate
their enhancements to the community as well.

* COMPANION MLP CONVERTER - Thanks to Seth Nygard, existing MLP 2.x systems can
be easily converted to PMAC in a matter of minutes using a supplied conversion
script. Look for the "PMAC Builder's Kit" which contains everything you need to
take an existing MLP system and turn it into a PMAC system.
