// RLV ADD-ON FOR PMAC 1.0
// by Aine Caoimhe (c. LACM) July 2017
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// Command format for this addon:
// PAO_RLV_SEND{position1commands::position2commands::....}
// where for each position you need to supply either
//      RVL_NO_COM = don't send anything to this position; or
//      one or more valid RLV command in the standard RLV format
// you can send multiple commands by comma-separating them
// DO NOT include any extra spaces between the separators or before/after the curly braces
//
// # # # # # # # # # # # # # #
// USER CONFIGURATION SETTINGS
// # # # # # # # # # # # # # #
// IMPORTANT TO SET THIS ONE CORRECTLY!
integer sendAsRlvComChain=FALSE;
// RLV v1.10 or higher allows multiple commands by using a single "@" followed by the comma-separated command list
// Prior versions allowed only 1 command per send.
// Most Opensim MLP systems with RLV that I've seen use the old syntax but chain them with a pipe-separated list which is later
// parsed out again and sent 1 by one. This add-on supports both.
//
// If your command chain for a position looks like this:
// @tplm=n,@tploc=n,@tplure=n,@sittp=n,@fartouch=n,@showinv=n,@fly=n,@unsit=n,@unsit=n,@edit=n,@rez=n,@showworldmap=n,@showminimap=n,@sendim=n
// then ensure that sendAsRlvComChain = FALSE and each will be sent 1 by 1.
//
// If your command chain looks like this:
// @tplm=n,tploc=n,tplure=n,sittp=n,fartouch=n,showinv=n,fly=n,unsit=n,unsit=n,edit=n,rez=n,showworldmap=n,showminimap=n,sendim=n
// then ensure that the sendAsRlvComChain = TRUE and the entire chain will be sent as a single block (assumes your relay won't choke on it either)
//
// If at all in doubt, use FALSE and make sure that each individual command is preceded by a "@" symbol...it will work on all RLV versions
//
// SETTINGS FOR INTEGRATED CAPTURE:
//
float captureRange=32.0;        // range (in meters) to look for an av to capture...the range is radius from the root prim
float victimTimeout=600.0;     // how long (in seconds) the PMAC object can be idle before any captured victims are released
//
// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
// DO NOT CHANGE ANYTHING BELOW HERE UNLESS YOU KNOW WHAT YOU'RE DOING!
// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
//
// With PMAC all commands must be inside the same line so we need two separators: one to distinguish positions and one to distinguish commands for that position
// a blank can use the (local) global "blank" but just to cover potential swaps or whatever it might be safer to use the global !release command for your blank instead
string pSep="::";   // string separating positions
string cSep=",";    // the official RLV command separator string since then we don't have to do any handling of it at all..if this changes all hell's going to break loose....

integer RELAY=-1812221819;  // channel that RLV protocal defines for relays

key user;                   // for dialog
list butDia;
string txtDia;
string MENU="MENU_NONE";

integer crChannelOffset=84; // capture dialog channel (chosen becasue it's the numeric value of the word "capture")
integer crChannel;         // = user key based - the capture channel offset so it doesn't conflict with anything else based on user key
integer crHandle;
float crTimeout=120.0;     // how long (in seconds) to wait before timing out the victim selection dialog
list victims;

list detectedKeys;
list detectedNames;

relay(key who, string message)
{
    // SEND MESSAGE TO RELAY
    if ((who!=NULL_KEY)&&(osIsUUID(who))) llSay(RELAY,llGetObjectName()+","+(string)who+","+ message);
}
capture(key who)
{
    relay(who,"@sit:"+(string)llGetKey()+"=force");
    victims=[]+victims+[who];
}
release(key who)
{
    // RELEASE A VICTIM
    // it's possible due to asynch handling that the victim list is already updated but remove if not
    integer victimIndex=llListFindList(victims,[who]);
    if (victimIndex>-1) victims=[]+llDeleteSubList(victims,victimIndex,victimIndex);
    relay(who,"@unsit=y");
    relay(who,"!release");
    if(llGetListLength(victims)>0) llSetTimerEvent(victimTimeout);
    else llSetTimerEvent(0.0);
}
validateVictims(string vicList)
{
    // passed pipe-delimited list of users
    // make sure each victim I think I have is still in that list...if not, release
    list currentUsers=llParseString2List(vicList,["|"],[]);
    integer check=llGetListLength(victims);
    while (--check>=0)
    {
        key who=llList2Key(victims,check);
        if (llListFindList(currentUsers,[who])==-1) release(who);
    }
}
returnPMAC()
{
    // RETURN CONTROL TO THE MAIN PMAC MENU
    if (llGetListLength(victims)>0) llSetTimerEvent(victimTimeout);
    else llSetTimerEvent(0.0);
    user=NULL_KEY;
    llMessageLinked(LINK_THIS,-1,"MAIN_RESUME_MAIN_DIALOG",NULL_KEY);       // return to the PMAC main menu handler
}    
showMenu()
{
    crChannel=(0x80000000 | (integer)("0x"+(string)user))-crChannelOffset;
    crHandle=llListen(crChannel,"",user,"");
    llDialog(user,txtDia,llList2List(butDia,9,11)+llList2List(butDia,6,8)+llList2List(butDia,3,5)+llList2List(butDia,0,2),crChannel);
    llSetTimerEvent(crTimeout);
}
default
{
    state_entry()
    {
        victims=[];
        crHandle=FALSE;
        user=NULL_KEY;
    }
    timer()
    {
        if (user!=NULL_KEY) returnPMAC();
        else
        {
            // this is an inactivity timeout...release all
            while (llGetListLength(victims)>0) {release(llList2Key(victims,0));}
        }
        llSetTimerEvent(0.0);   //either way stop the timer
    }
    touch_start(integer num)
    {
        if (llDetectedKey(0)!=user) return;
        showMenu();
    }
    no_sensor()
    {
        llRegionSayTo(user,0,"Unable to detect anyone in range to capture");
        returnPMAC();
    }
    sensor(integer num)
    {
        // build the dialog here so we can access the detected data
        detectedKeys=[];
        detectedNames=[];
        list numbers;
        integer i;
        while (i<num)
        {
            key who=llDetectedKey(i);
            string name=llKey2Name(who);
            if ((who!=user)&&!osIsNpc(who)) // can't capture yourself or any npcs
            {
                detectedKeys=[]+detectedKeys+[who];
                detectedNames=[]+detectedNames+[name];
                numbers=[]+numbers+[(string)llGetListLength(detectedNames)];
            }
            i++;
        }
        if (llGetListLength(numbers)<1)
        {
            // No valid capture targets
            llRegionSayTo(user,0,"Unable to detect anyone in range to capture");
            returnPMAC();
            return;
        }
        txtDia="Select the victim to capture:\n\n"+llDumpList2String(llList2List(detectedNames,0,10),"\n");
        butDia=[]+llList2List(numbers,0,10);
        while (llGetListLength(butDia)<11) { butDia=[]+butDia+["-"]; }
        butDia=[]+butDia+["CANCEL"];
        MENU="MENU_CAPTURE";
        showMenu();
    }
    listen(integer channel, string name, key who, string message)
    {
        llSetTimerEvent(0.0);
        llListenRemove(crHandle);
        // the "CANCEL" response can just fall through
        if (message=="-")
        {
            showMenu();
            return;
        }
        if (MENU=="MENU_CAPTURE")
        {
            integer indexToCapture=(integer)message-1;
            key whoToCapture=llList2Key(detectedKeys,indexToCapture);
            string vic=llList2String(detectedNames,indexToCapture);
            llRegionSayTo(user,0,"Capturing "+vic);
            capture(whoToCapture);
            llSetTimerEvent(victimTimeout);
        }
        else if (MENU=="MENU_RELEASE")
        {
            if (message=="ALL CAPTIVES")
            {
                while (llGetListLength(victims)>0) { release(llList2Key(victims,0)); }
            }
            else
            {
                integer indexToRelease=(integer)message-1;
                key whoToRelease=llList2Key(victims,indexToRelease);
                string vic=llKey2Name(whoToRelease);
                llRegionSayTo(user,0,"Releasing "+vic);
                release(whoToRelease);
            }
        }
        // either way, we return control to PMAC now
        returnPMAC();
    }
    link_message (integer sender, integer num, string message, key id)
    {
        list parsed=llParseString2List(message,["|"],[]);
        string command=llList2String(parsed,0);
        list userList=llParseString2List(id,["|"],[]);
        if (llGetListLength(victims)>0)llSetTimerEvent(victimTimeout);
        if (command=="GLOBAL_SYSTEM_RESET")
        {
            while (llGetListLength(victims)>0)
            {
                release(llList2Key(victims,0));
            }
            llResetScript();
        }
        else if (command=="GLOBAL_NEW_USER_ASSUMED_CONTROL")
        {
            // new PMAC menu user so need to register the Capture button to the Specials menu
            // anyone with permission to access PMAC menu has permission to capture
            llMessageLinked(LINK_THIS,-1,"MAIN_REGISTER_MENU_BUTTON|RLV Capture","PAO_RLV_Capture");
            llMessageLinked(LINK_THIS,-1,"MAIN_REGISTER_MENU_BUTTON|RLV Release","PAO_RLV_Release");
        }
        else if (command=="GLOBAL_USER_STOOD")
        {
            // check if the user who stood was supposedly a victim...if so, release
            release(llList2Key(parsed,2));
        }
        else if (command=="PAO_RLV_Capture")
        {
            // user selected Capture from the PMAC OPTIONS>SPECIALS menu
            user=llList2Key(parsed,1);
            validateVictims((string)id);
            llSensor("", NULL_KEY, AGENT, captureRange, PI);
        }
        else if (command=="PAO_RLV_Release")
        {
            // handle it here
            user=llList2Key(parsed,1);
            validateVictims((string)id);
            integer vicCount=llGetListLength(victims);
            if (vicCount==0)
            {
                // nobody on the list...the release button should have been deregistered but there could be asynch or glitchy handling so return
                llRegionSayTo(user,0,"I don't think I have any victims to release");
                returnPMAC();
                return;
            }
            else if (vicCount==1)
            {
                // only one possible person to release so....
                release(llList2Key(victims,0));
                // and can send back to main
                returnPMAC();
                return;
            }
            // getting here means that we have 2 more more victims so we need to ask who to release
            integer i;
            butDia=[];
            txtDia="Who would you like to release?\n";
            while (llGetListLength(butDia)<10)
            {
                if(i<vicCount)
                {
                    txtDia+="\n"+(string)(i+1)+". "+llKey2Name(llList2Key(victims,i));
                    butDia=[]+butDia+[(string)(i+1)];
                    i++;
                }
                else butDia=[]+butDia+["-"];
            }
            butDia=[]+butDia+["ALL CAPTIVES","CANCEL"];
            MENU="MENU_RELEASE";
            showMenu();
        }
        else if (command=="GLOBAL_NEXT_AN")
        {
            // look at the command block for the animation to see if there's anything there for us
            // first break it into individual
            list anCommands=llParseString2List(llList2String(parsed,1),["{","}"],[]);
            integer rlvIndex=llListFindList(anCommands,["PAO_RLV_SEND"]);
            if (rlvIndex>-1)
            {
                //this command block contains commands for us
                list rlvCommands=llParseString2List(llList2String(anCommands,rlvIndex+1),[pSep],[]);
                // error check for mismatch
                if (llGetListLength(rlvCommands)!=llGetListLength(userList))
                {
                    llSay(0,"ERROR: Detected a RLV command block but the number of positions in the block doesn't match the number of positions sent");
                    return;
                }
                integer position;
                while (position<llGetListLength(rlvCommands))
                {
                    string theseCommands=llList2String(rlvCommands,position);
                    if (theseCommands!="RLV_NO_COM")
                    {
                        if (sendAsRlvComChain) relay(llList2Key(userList,position),theseCommands);
                        else
                        {
                            list whatToSend=llParseString2List(theseCommands,[cSep],[]);
                            integer c=llGetListLength(whatToSend);
                            while (--c>=0) { relay(llList2Key(userList,position),llList2String(whatToSend,c)); }
                        }
                    }
                    position++;
                }
            }
        }
    }
}
