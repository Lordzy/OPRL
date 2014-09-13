/*______________________________________________________________________________

						Lordz's Second RCON System!
						Copyright(c) - 2014 "SecondRCON"
						Author : Lordz™ AKA Lordzy

NOTE:
This script is created as a filterscript, mainly as an example for the include
"OPRL" AKA "OnPlayerRconLogin". This script ensures that the second RCON request
is only sent to the player who RCON logins, not to the players who got the same
IP address.

______________________________________________________________________________*/

#define FILTERSCRIPT

#include <a_samp>
#include <OPRL3>

new
	bool:RCON2LoggedIn[MAX_PLAYERS],
	RCON2WrongLogins[MAX_PLAYERS];
	
#define SECOND_RCON_DIALOG	1126 //Dialog ID of the second RCON.
#define SECOND_RCON_PASS 	"testing" //Second RCON password, you can change it but keep it in quotes.
#define MAX_FALSE_2RCON_ATTEMPTS    3 //Maximum number of second RCON fails.
#define MAX_HOLD_SECONDS    120 //Maximum seconds in which a player could stay as RCON without confirming second RCON.

public OnPlayerConnect(playerid)
{
	if(IsPlayerAdmin(playerid))	RCON2LoggedIn[playerid] = true;
	else RCON2LoggedIn[playerid] = false;
	RCON2WrongLogins[playerid] = 0;
	return 1;
}

public OnFilterScriptInit()
{
	for(new i; i< GetMaxPlayers(); i++)
	{
	    if(!IsPlayerConnected(i)) continue;
	    if(IsPlayerAdmin(i)) RCON2LoggedIn[i] = true;
	    else RCON2LoggedIn[i] = false;
	    RCON2WrongLogins[i] = 0;
	}
	printf("-------------------------------------------------");
	printf("    OnPlayerRconLogin - Second RCON system");
	printf("                    Loaded!");
	printf("-------------------------------------------------");
	return 1;
}

public OnPlayerRconLogin(playerid)
{
	if(RCON2LoggedIn[playerid] == false)
	{
	    SendClientMessage(playerid, -1, "{FF0000}Server : {880088}Before playing as RCON Administrator, please login to the second RCON option too.");
	    ShowPlayerDialog(playerid, SECOND_RCON_DIALOG, DIALOG_STYLE_INPUT, "Second RCON Login", "Hello,\nBefore accessing RCON, please login to the second RCON.", "Login", "");
	    SetTimerEx("DetectSecondRconLogin", 1000*MAX_HOLD_SECONDS, false, "d", playerid);
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == SECOND_RCON_DIALOG)
	{
	    if(response)
	    {
	        if(!strlen(inputtext))
	        {
	            RCON2WrongLogins[playerid]++;
	            new
					string[128];
 				if(RCON2WrongLogins[playerid] >= MAX_FALSE_2RCON_ATTEMPTS)
				{
				    new
						Lname[MAX_PLAYER_NAME];
				    GetPlayerName(playerid, Lname, sizeof(Lname));
				    format(string, sizeof(string), "%s (ID:%d) has been automatically kicked from the server! (Reason : %d/%d)", Lname, playerid, RCON2WrongLogins[playerid], MAX_FALSE_2RCON_ATTEMPTS);
				    SendClientMessageToAll(0xFF0000FF, string);
					return SetTimerEx("KickPlayer", 150, false, "d", playerid);
				}
				format(string, sizeof(string), "ERROR! The previous second RCON given was incorrect! (Warnings : %d/%d)", RCON2WrongLogins[playerid], MAX_FALSE_2RCON_ATTEMPTS);
				SendClientMessage(playerid, 0xFF0000FF, string);
    			return ShowPlayerDialog(playerid, SECOND_RCON_DIALOG, DIALOG_STYLE_INPUT, "Second RCON Login", "Hello,\nBefore accessing RCON, please login to the second RCON.", "Login", "");
	        }
			if(!strcmp(inputtext, SECOND_RCON_PASS, false))
			{
			    GameTextForPlayer(playerid, "~G~ACCESS GRANTED!", 2000, 3);
			    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			    RCON2LoggedIn[playerid] = true;
			    return 1;
			}
			else if(strcmp(inputtext, SECOND_RCON_PASS, false))
			{
				RCON2WrongLogins[playerid]++;
    			new
					string[128];
				if(RCON2WrongLogins[playerid] >= MAX_FALSE_2RCON_ATTEMPTS)
				{
				    new
						Lname[MAX_PLAYER_NAME];
				    GetPlayerName(playerid, Lname, sizeof(Lname));
				    format(string, sizeof(string), "%s (ID:%d) has been automatically kicked from the server! (Reason : Wrong RCON logins | %d/%d)", Lname, playerid, RCON2WrongLogins[playerid], MAX_FALSE_2RCON_ATTEMPTS);
				    SendClientMessageToAll(0xFF0000FF, string);
					return SetTimerEx("KickPlayer", 150, false, "d", playerid);
				}
				format(string, sizeof(string), "ERROR! The previous second RCON given was incorrect! (Warnings : %d/%d)", RCON2WrongLogins[playerid], MAX_FALSE_2RCON_ATTEMPTS);
				SendClientMessage(playerid, 0xFF0000FF, string);
    			return ShowPlayerDialog(playerid, SECOND_RCON_DIALOG, DIALOG_STYLE_INPUT, "Second RCON Login", "Hello,\nBefore accessing RCON, please login to the second RCON.", "Login", "");
			}
		}
		if(!response)
		{
		    new
		        string[128],
				Lname[MAX_PLAYER_NAME];
			format(string, sizeof(string), "%s (ID:%d) has been automatically kicked from the server! (Reason : Wrong RCON login)", Lname, playerid);
			SendClientMessageToAll(0xFF000FF, string);
			return SetTimerEx("KickPlayer", 150, false, "d", playerid);
		}
	}
	return 1;
}


forward KickPlayer(playerid);
forward DetectSecondRconLogin(playerid);


public DetectSecondRconLogin(playerid)
{
	if(IsPlayerAdmin(playerid))
	{
	    if(RCON2LoggedIn[playerid] == false)
	    {
	        new
	            Lname[MAX_PLAYER_NAME],
	            string[128];
			GetPlayerName(playerid, Lname, sizeof(Lname));
			format(string, sizeof(string), "%s (ID:%d) has been automatically kicked from the server! (Reason : Delayed RCON confirmation)", Lname, playerid);
			SendClientMessageToAll(0xFF0000FF, string);
			return SetTimerEx("KickPlayer", 150, false, "d", playerid);
		}
	}
	return 1;
}

public KickPlayer(playerid) return Kick(playerid);
