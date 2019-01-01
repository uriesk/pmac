// LOCKGUARD ADD-ON FOR PMAC 1.0
// by Aine Caoimhe (c. LACM) July 2017
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// Command format for this addon:
// PAO_LOCK{chain_data_pos1::chain_data_pos12...}
// for each position the following is needed:
//          child_prim_name=lockguard_link_name and any other valid lg commands
//          to do multiples, separate each with "&&"
//  if a position has no data, it needs to be given "LOCK_NO_COM" instead
//
// Example #1: for a 2-person pose where the 1st position has 3 chains and the 2nd position has none...
// Pose1|POA_LOCK{Point-1=rightwrist&&Point-3=leftwrist&&Point-8=leftankle::LOCK_NO_COM}|...the rest of the animation line data
// Example #2" the exact same pose, except this time it's position 1 that has no chains and position 2 that has 3
// Pose2|POA_LOCK{LOCK_NO_COM::Point-1=rightwrist&&Point-3=leftwrist&&Point-8=leftankle}|...the rest of the animation line data
//
// Each possible LG attachment point of the PMAC object must be a child prim (cannot be root) and must have a UNIQUE name (it also can't
// be "Primitive" even it it's the only prim with that name)
//
integer warnAboutDupes=FALSE;
// During initialization ths add-on has to check child-prim names and retain a list of any that are unique. When discovering duplicated named prims it will
// ignore them but by setting this TRUE you will be notified that it's doing so which could be useful when creating a new item or during an MLP conversion process.
// Leaving it at the default FALSE will have it ignore them silently.
//
// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
// DO NOT CHANGE ANYTHING BELOW HERE UNLESS YOU KNOW WHAT YOU'RE DOING
// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
//
integer lgChannel=-9119;    // LG channel per spec.
list targets;       //[child prim name, key,....]
list existingLinks; // pairs of data for avatar and which lg points are being used... [avatar key, point1|point2|point3|....]...order doesn't matter
//
// FOR REFERENCE: LG syntax expected by the receiving object )cuff or whatever):
// llWhisper( -9119, "lockguard " + (string)[targetUUID] +" "+ (string)[item to link]+" " + (string)[commands using space separation] );
// only critical commands are the link and unlink....link is followed by the key of the PMAC object attachment point and unlink has no argument
// 
addLinks(key who, string dataBlock)
{
    //ignore invalid or null keys and datablocks marked as empty
    if (who==NULL_KEY) return;
    if (!osIsUUID(who)) return;
    if (dataBlock=="LOCK_NO_COM") return;
    // getting here means we ought to have something we need to draw so now we need to break it by attach points
    list pointsData=llParseString2List(dataBlock,["&&"],[]);
    integer p=llGetListLength(pointsData);
    list targetLinkData=[];
    while (--p>=0)
    {
        list thisPointData=llParseString2List(llList2String(pointsData,p),["="],[]);
        string thisPoint=llList2String(thisPointData,0); // the name of the PMAC attachment point prim
        integer indexThisPoint=llListFindList(targets,[thisPoint]);
        if (indexThisPoint==-1) llOwnerSay("ERROR: told to draw a chain to child prim "+thisPoint+" but it doesn't exist");
        else
        {
            key thisPointKey=llList2Key(targets,indexThisPoint+1);
            string attachString=llList2String(thisPointData,1);
            integer firstSpace=llSubStringIndex(attachString," ");
            if (firstSpace>-1) firstSpace--;    // we don't want to bring the space with it too
            string attachName=llGetSubString(attachString,0,firstSpace); // this is just the cuff name to store in the user list
            targetLinkData=[]+targetLinkData+[attachName];
            llWhisper(lgChannel,"lockguard "+(string)who+" "+attachString+" link "+(string)thisPointKey);
        }
    }
    existingLinks=[]+existingLinks+[who,llDumpList2String(targetLinkData,"|")];
}
stripLinks(key who)
{
    // remove any links
    integer lInd=llListFindList(existingLinks,[who]);
    if (lInd>-1)
    {
        // there are some so parse them to list and remove one by one
        list pointsToStrip=llParseString2List(llList2String(existingLinks,lInd+1),["|"],[]);
        integer p=llGetListLength(pointsToStrip);
        while (--p>=0) { llWhisper(lgChannel,"lockguard "+(string)who+" "+llList2String(pointsToStrip,p)+" unlink"); }
        // delete the entry
        existingLinks=[]+llDeleteSubList(existingLinks,lInd,lInd+1);
    }
}
buildTargetList()
{
    list ignore=[];
    targets=[];
    integer link=llGetNumberOfPrims();
    if (link==1)
    {
        llOwnerSay("LOCKGUARD PMAC addon cannot work with an object that has only 1 prim. Please read the instructions!");
        return;
    }
    while (link>1)
    {
        string name=llGetLinkName(link);
        if (name!="Primitive")
        {
            if (llListFindList(ignore,[name])>-1)
            {
                if (warnAboutDupes) llOwnerSay("WARNING! LOCKGUARD for PMAC found another child prim with the name \""+name+"\" and will ignore it too.");
            }
            if (llListFindList(targets,[name])>-1)
            {
                if (warnAboutDupes) llOwnerSay("WARNING! LOCKGUARD for PMAC found two child prims with the same name \""+name+"\" and will ignore them. They cannot be called as attachment points");
                targets=[]+llDeleteSubList(targets,llListFindList(targets,[name]),llListFindList(targets,[name]));
                ignore=[]+ignore+[name];
            }
            else targets=[]+[name,llGetLinkKey(link)]+targets;
        }
        link--;
    }
}
default
{
    state_entry()
    {
        // we need a quick-access list of attachment points to potentially attach chains to so might as well build it on start-up when there's no appreciable load
        buildTargetList();
        existingLinks=[];
    }
    link_message(integer fromLink,integer num, string message, key ID)
    {
        list parsed=llParseString2List(message,["|"],[]);
        // see if this is a main PMAC command that we need to pay attention to
        string mainCommand=llList2String(parsed,0);
        if (mainCommand=="GLOBAL_SYSTEM_RESET")
        {
            // release any existingLinks
            while (llGetListLength(existingLinks)>0) { stripLinks(llList2Key(existingLinks,0)); }
            llResetScript();
        }
        else if (mainCommand=="GLOBAL_USER_STOOD")
        {
            // release any existingLinks
            stripLinks(llList2Key(parsed,2));
        }
        else if (mainCommand=="GLOBAL_NEXT_AN")
        {
            // whether or not there's data for the new animation, we need to remove any old
            while (llGetListLength(existingLinks)>0) { stripLinks(llList2Key(existingLinks,0)); }
            // find out if the command block has anything for us..
            list theseCommands=llParseString2List(llList2String(parsed,1),["{","}"],[]);
            integer indexThisBlock=(llListFindList(theseCommands,["PAO_LOCK"]));
            if (indexThisBlock==-1) return; // finished if there isn't any new data
            // otherwise let's read our block and break it into positions first
            list positionData=llParseString2List(llList2String(theseCommands,indexThisBlock+1),["::"],[]);
            // pull the users list from the passed data
            list users=llParseString2List((string)ID,["|"],[]);
            integer u=llGetListLength(users);
            // error-check length match
            if (llGetListLength(positionData)!=u)
            {
                llOwnerSay("ERROR! LOCKGUARD add-on encountered a mismatch between number of postions in the card chain data and number of positions in the pose. Can't draw chains");
                return;
            }
            // otherwise send each
            llSleep(0.1);   // yes, this is a deliberate thread-lock - due to potential asynch sending we need to do a short delay to ensure that any new draw commands arrive *after* the last of the strip ones
            while (--u>=0) { addLinks(llList2Key(users,u),llList2String(positionData,u)); }
        }
    }
}
