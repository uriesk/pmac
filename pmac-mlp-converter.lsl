// Conversion Utility MLP RLV & LG to PMAC 2.5
// by Aine Caoimeh (c. LACM) June 2017
//
// This script is intended to help people who have a fully functioning MLP system that include correct/accurate RLV data and Lockguard data notecards.
// No attempt is made to validate the data, nor is there any other error-checking at all
// DO NOT EVER work on the original version of your item...make a copy and convert it. That way if something goes wrong you will still have your original.
//
// This script has been given only limited testing on RLV/LG items I know are working under the current version. I cannot promise that it will work on
/// a setup that you have. You may need to modify the script to match your own system.
//
// INSTRUCTIONS
// 1. FIRST CONVERT THE OBJECT FROM MLP TO PMAC USING SETH'S SCRIPT
// 2. TEST TO MAKE SURE ALL POSES ARE WORKING
// 3. MAKE A COPY OF THE CONVERTED ITEM
// 4. DROP THIS SCRIPT INTO THE COPY AND IT WILL AUTOMATICALLY TRY TO FIND AND CONVERT THE ".RVL" AND ".CHAINDATA" NOTECARDS, IF FOUND
// 
// Note:
// Data is not cross-checked or validated. If it's broken in the originala it won't get magially fixed after conversion or could even break the PMAC setup
// Data suppled for missing animations is ignored...no effort is made to match it to anything else nor are you told what is skipped
// For any pose, if there is any date for one position and no data for other positions, the other positions are given null entries to ensure valid syntax of those entries
// The is NO CHECK on the RLV or LG data or syntax supplied...if it's wrong in your original it will be in the converted version too
// The original notecards are deleted from the system once complete and the PMAC notecards are updated
// Any animation that has no data is not given zeroed-out data to you may need to do that (ie if your setup was messed up like that in MLP it will still be messed up in PMAC)
//
// RLV command chains are built using "@" prior to each command to ensure compatibility with all RLV relays, etc; even though that's a bit too spammy. If you wish to use
// the v1.10+ chains you can simply change this script to assemble the strings that way, or else do a global search & replace of ",@" >> "," in the new menu notecard.
//
// THIS SCRIPT IS SUPPLIED AS IS PURELY AS SOMETHING THAT HAS THE POTENTIAL TO HELP YOU CONVERT A SYSTEM. I DO NOT OFFICIALLY SUPPORT IT NOR DO I PLAN TO
// EXPAND IT ANY FURTHER TO COVER SPECIAL CASES OR OTHER VERSIONS. YOU'RE WELCOME TO WRITE THOSE VARIATIONS YOURSELF.
// IT IS INTENDED FOR CREATORS WHO ARE FAMILIAR WITH PMAC AND MLP OR PEOPLE WILLING TO EDUCATE THEMSELVES ON THOSE SYSTEMS TO RESOLVE ANY ISSUES THAT CROP UP
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// THERE ARE NO USER SETTINGS....DON'T CHANGE ANYTHING UNLESS YOU KNOW WHAT YOU'RE DOING!
//
integer debug=FALSE;    // if set to TRUE don't delete scrip or old cards and be more verbose...but then don't let this script run a second time or it will completely ruin your menu notecard
string rlvCardName=".RLV";  // expected notecard name where the RLV data is sourced
string lgCardName=".CHAINDATA"; // ditto for LG chain data
list rlvData;
list lgData;
list menucards;

doGatherRLV()
{
    rlvData=[];
    if (llGetInventoryType(rlvCardName)!=INVENTORY_NOTECARD)
    {
        llOwnerSay("Unable to located the RLV data notecard specified: "+rlvCardName);
        return;
    }
    else llOwnerSay("Reading in RLV data");
    list rawData=llParseString2List(osGetNotecard(rlvCardName),["\n"],[]);
    integer i;
    while (i<llGetListLength(rawData))
    {
        string line=llList2String(rawData,i);
        line = llStringTrim(line,STRING_TRIM);
        if (llGetSubString(line,0,0)!="/")
        {
            list thisLineData=llParseString2List(line,["|"],[]);
            rlvData=[]+rlvData+[llStringTrim(llList2String(thisLineData,0),STRING_TRIM)];
            string trimmed=llStringTrim(llList2String(thisLineData,1),STRING_TRIM);
            if (trimmed=="*") rlvData=[]+rlvData+["*"];
            else rlvData=[]+rlvData+[(integer)trimmed];
            integer c=2;
            while (c<llGetListLength(thisLineData))
            {
                thisLineData=[]+llListReplaceList(thisLineData,[llStringTrim(llList2String(thisLineData,c),STRING_TRIM)],c,c);
                c++;
            }
            rlvData=[]+rlvData+[llDumpList2String(llList2List(thisLineData,2,-1),",")];
        }
        i++;
    }
    // can't assemble until we know how many poses so leave in this state for now
    if (debug) llOwnerSay("RLV Data:\n"+llDumpList2String(rlvData,"|"));
}

doGatherLG()
{
    lgData=[];
    if (llGetInventoryType(lgCardName)!=INVENTORY_NOTECARD)
    {
        llOwnerSay("Unable to located the lockguard data notecard specified: "+lgCardName);
        return;
    }
    else llOwnerSay("Reading in Lockguard data");
    list rawData=llParseString2List(osGetNotecard(lgCardName),["\n"],[]);
    integer i;
    while (i<llGetListLength(rawData))
    {
        string line=llList2String(rawData,i);
        line = llStringTrim(line,STRING_TRIM);
        if (llGetSubString(line,0,0)!="/")
        {
            list thisLineData=llParseString2List(line,["|"],[]);
            lgData=[]+lgData+[llStringTrim(llList2String(thisLineData,0),STRING_TRIM)];
            string trimmed=llStringTrim(llList2String(thisLineData,1),STRING_TRIM);
            if (trimmed=="*") lgData=[]+lgData+["*"];
            else lgData=[]+lgData+[(integer)trimmed];
            lgData=[]+lgData+[llStringTrim(llList2String(thisLineData,2),STRING_TRIM)]+[llStringTrim(llList2String(thisLineData,3),STRING_TRIM)];
        }
        i++;
    }
    // can't assemble until we know how many poses so leave in this state for now
    if (debug) llOwnerSay("LG Data:\n"+llDumpList2String(lgData,"|"));
}

doGatherMenus()
{
    menucards=[];
    integer i=llGetInventoryNumber(INVENTORY_NOTECARD);
    while (--i>=0)
    {
        string name=llGetInventoryName(INVENTORY_NOTECARD,i);
        if (llSubStringIndex(name,".menu")==0) menucards=[]+[name]+menucards;
    }
    llOwnerSay("Found "+(string)llGetListLength(menucards)+" menu notecards to check and update...");
}

doDataIntegrate(string menucard)
{
    integer nameStarts=llSubStringIndex(menucard," ")+1;
    integer posCount=(integer)(llGetSubString(menucard,7,nameStarts-3));
    llOwnerSay("Processing menu: "+llGetSubString(menucard,nameStarts,-1));
    list data=llParseString2List(osGetNotecard(menucard),["\n"],[]);
    //data is LINE-SEPARATED
    string newData;
    integer i;
    while (i<llGetListLength(data))
    {
        list thisLineData=llParseString2List(llList2String(data,i),["|"],[]);
        string anName=llList2String(thisLineData,0);
        string command=llList2String(thisLineData,1);
        string rlvCommand;
        string lgCommand;
        if (command=="NO COM") command="";
        else if (command=="NO_COM") command="";
        // build new rlv command if a card exists at all
        if (llGetListLength(rlvData)>0)
        {
            rlvCommand=""+"PAO_RLV_SEND{";
            integer p;
            while (p<posCount)
            {
                integer indRLV=llListFindList(rlvData,[anName,p]);
                if(p>0) rlvCommand+="::";
                if (indRLV==-1) rlvCommand+="RLV_NO_COM";
                else rlvCommand+=llList2String(rlvData,indRLV+2);
                p++;
            }
            rlvCommand+="}";
        }
        // build new lockguard command if a card exists at all
        if (llGetListLength(lgData)>0)
        {
            lgCommand="PAO_LOCK{";
            integer q;
            while (q<posCount)
            {
                integer indLG=llListFindList(lgData,[anName,q]);
                if(q>0) lgCommand+="::";
                if (indLG==-1) lgCommand+="LOCK_NO_COM";
                else
                {
                    // have to build this differently because LG commands are often multple lines for 1 position so we need to assemble by position as well
                    lgCommand+=llList2String(lgData,indLG+2)+"="+llList2String(lgData,indLG+3);
                    list remainingList=llList2List(lgData,indLG+4,-1);
                    while (llListFindList(remainingList,[anName,q])>-1)
                    {
                        integer nextInd=llListFindList(remainingList,[anName,q]);
                        lgCommand+="&&"+llList2String(remainingList,nextInd+2)+"="+llList2String(remainingList,nextInd+3);
                        remainingList=[]+llDeleteSubList(remainingList,0,nextInd+3);
                    }
                }
                q++;
            }
            lgCommand+="}";
        }
        command=""+lgCommand+rlvCommand+command;
        // updated command is now built -- update in data
        thisLineData=[]+llListReplaceList(thisLineData,[command],1,1);
        // dump into new data
        newData+=llDumpList2String(thisLineData,"|")+"\n";
        i++;
    }
    // replace with the new data and while we're at it, update the list of menu cards not yet proceessed
    menucards=[]+llDeleteSubList(menucards,0,0);
    llRemoveInventory(menucard);
    llSleep(0.25);  // evil sleep required to give inventory removal time to execute
    osMakeNotecard(menucard,newData);
}

cleanUp()
{
    if (debug) llOwnerSay("DEBUG MODE: note removing notecards");
    else
    {
        if (llGetInventoryType(rlvCardName)==INVENTORY_NOTECARD) llRemoveInventory(rlvCardName);
        if (llGetInventoryType(lgCardName)==INVENTORY_NOTECARD) llRemoveInventory(lgCardName);
        llRemoveInventory(llGetScriptName());
    }
}

doConversion()
{
    doGatherRLV();
    doGatherLG();
    doGatherMenus();
    if (llGetListLength(rlvData)+llGetListLength(lgData)<1) llOwnerSay("Unable to retrieve any RLV or Lockguard data....aborting");
    else { while (llGetListLength(menucards)>0) { doDataIntegrate(llList2String(menucards,0)); } }
    cleanUp();
}

default
{
    state_entry()
    {
        llOwnerSay("Initiating MLP RLV/LG conversion....please wait...");
        doConversion();
    }
}
