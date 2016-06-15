%{
#define _WIN32_WINNT 0x502

#include <winsock2.h>
#include <ws2tcpip.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <iostream>
#include <unistd.h>
#include <string.h>
#include <algorithm>
#include "Dice.h"
#define YYSTYPE double
#include <sstream>
#include <ctime>

#include "metronome.h"
//
#include "help.h"

static const bool DEBUG = false;

static const std::string DUDE_BOT_VERSION = "v0.420 - Who's Duderoid?";

/*
iwwrr
1xxxx = immune
00000 = neutral
00101 = neutral
01010 = neutral
01111 = neutral
00100 = weak
01001 = weak
01110 = weak
01000 = double weak
01101 = double weak
01100 = triple weak
01011 = resist
00110 = resist
00001 = resist
00111 = double resist
00010 = double resist
00011 = triple resist

static const std::unordered_map<std::string, std::unordered_map<std::string, std::bitset<5>>> TYPES = {
{"normal",{"normal","00000"}}
};

*/

template <typename T>
std::string to_string(T value)
{
	std::ostringstream os;
	os << value;
	return os.str();
}

int yylex(void);
void yyerror(const char *);

SOCKET conn;
char sbuf[512];

static int globalReadOffset;
static char finalMessage[512];
static char finalOutput[512];

std::string finalResult = "";

std::vector<Dice*> diceHold;
std::vector<EoTEDice*> EoTEDiceHold;

void raw(char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(sbuf, 512, fmt, ap);
    va_end(ap);
    printf("<< %s", sbuf);
    send(conn, sbuf, strlen(sbuf), 0);
}

void fitMessage(std::string& prefix, std::string& restOfIt, int counter)
{
   std::string finalString = prefix;
   bool doIt = false;
   if(counter < 5)
   {
    if((prefix.size() + restOfIt.size()) > 450)
    {
     doIt = true;
	 auto pos = restOfIt.find_first_of(" \x0F",450 - prefix.size());
	 finalString.append(restOfIt, 0, pos);
	 restOfIt.erase(0,pos);
    }
	else
	{
	 finalString += restOfIt;
	}
   }
   else
   {
    finalString += "shut up me";
   }
   finalString += "\r\n";
   strcpy(finalOutput,finalString.c_str());
   raw(finalOutput);
   if(doIt)
    fitMessage(prefix,restOfIt,counter+1);
}

int rollDice(int num, int side)
{
 diceHold.push_back(new Dice(num,side));
 return diceHold.back()->getValue();
}

int rollFateDice(int num)
{
 diceHold.push_back(new FateDice(num));
 return diceHold.back()->getValue();
}

int rollExplodeDice(int num, int side)
{
 ExplodeDice *coolDie = new ExplodeDice(num,side);
 diceHold.push_back(coolDie);
 if (DEBUG) printf("explode is %i\n",coolDie->getExplode());
 if(coolDie->getExplode() > 0)
  return coolDie->getValue() + rollExplodeDice(coolDie->getExplode(),side);
 return coolDie->getValue();
}

void rollEoTEDice(char type)
{
 EoTEDiceHold.push_back(new EoTEDice(type));
}

void cleanDice()
{
 while(!diceHold.empty())
  {
   delete diceHold.back();
   diceHold.pop_back();
  }

 while(!EoTEDiceHold.empty())
  {
   delete EoTEDiceHold.back();
   EoTEDiceHold.pop_back();
  }
}

void printFinal(double result)
{
 finalResult = to_string(result);
 if (!diceHold.empty())
 {
  finalResult += " (";
  std::string endResult = ")";
  while(!diceHold.empty())
  {
   endResult = diceHold.back()->printResult() + endResult;
   delete diceHold.back();
   diceHold.pop_back();
   if(!diceHold.empty())
	endResult = ", " + endResult;
  }
  finalResult += endResult;
 }
}

void printFinal(std::string& result)
{
 finalResult = result;
 if (!diceHold.empty())
 {
  finalResult += " (";
  std::string endResult = ")";
  while(!diceHold.empty())
  {
   endResult = diceHold.back()->printResult() + endResult;
   delete diceHold.back();
   diceHold.pop_back();
   if(!diceHold.empty())
	endResult = ", " + endResult;
  }
  finalResult += endResult;
 }
}

void EoTEPrintFinal()
{
 if (!EoTEDiceHold.empty())
 {
  int success = 0;
  int advantage = 0;
  int triumph = 0;
  int despair = 0;
  int white = 0;
  int black = 0;
  std::string endResult = ")";
  while(!EoTEDiceHold.empty())
  {
   endResult = EoTEDiceHold.back()->printResult() + endResult;
   success += EoTEDiceHold.back()->getValue();
   advantage += EoTEDiceHold.back()->advantage;
   triumph += EoTEDiceHold.back()->triumph;
   despair += EoTEDiceHold.back()->despair;
   white += EoTEDiceHold.back()->white;
   black += EoTEDiceHold.back()->black;
   delete EoTEDiceHold.back();
   EoTEDiceHold.pop_back();
   if(!EoTEDiceHold.empty())
    endResult = " " + endResult;;
  }
  bool space = false;
  if(success > 0)
  {
   finalResult += to_string(success) += " Success";
   if(success > 1)
    finalResult += "es";
   space = true;
  }
  if(success < 0)
  {
   finalResult += to_string(success*-1) += " Failure";
   if(success < -1)
    finalResult += "s";
   space = true;
  }
  if(advantage > 0)
  {
   if (space)
   {
    finalResult += ", ";
   }
   finalResult += to_string(advantage) += " Advantage";
   if(advantage > 1)
    finalResult += "s";
   space = true;
  }
  if(advantage < 0)
  {
   if (space)
   {
    finalResult += ", ";
   }
   finalResult += to_string(advantage*-1) += " Threat";
   if(advantage < -1)
    finalResult += "s";
   space = true;
  }
  if(triumph > 0)
  {
   if (space)
   {
    finalResult += ", ";
   }
   finalResult += to_string(triumph) += " Triumph";
   if(triumph > 1)
    finalResult += "s";
   space = true;
  }
  if(despair > 0)
  {
   if (space)
   {
    finalResult += ", ";
   }
   finalResult += to_string(despair) += " Despair";
   if(despair > 1)
    finalResult += "s";
   space = true;
  }
  if(white > 0)
  {
   if (space)
   {
    finalResult += ", ";
   }
   finalResult += to_string(white) += " Light Force Point";
   if(white > 1)
    finalResult += "s";
   space = true;
  }
  if(black > 0)
  { 
   if (space)
   {
    finalResult += ", ";
   }
   finalResult += to_string(black) += " Dark Force Point";
   if(black > 1)
    finalResult += "s";
   space = true;
  }
  if(!space)
  {
   finalResult += "Nothing";
  }
  finalResult += " (" + endResult;
 }
}

int rollShardDice(int num, int side)
{
 ExplodeDice *coolDie = new ExplodeDice(num,side);
 diceHold.push_back(coolDie);
 if (DEBUG) printf("explode is %i\n",coolDie->getExplode());
 if(coolDie->getExplode() > 0)
  return coolDie->getShards() + rollShardDice(coolDie->getExplode(),side);
 return coolDie->getShards();
}

void shardFunction(int rolls)
{
 int shardCount = rollShardDice(rolls,6);
 
 std::string shardString = "";
 if(shardCount > 0)
 {
 int red = 0;
 int orange = 0;
 int yellow = 0;
 int green = 0;
 int blue = 0;
 int violet = 0;
 for(int i = 0; i < shardCount; i++)
 {
  Dice coolDie(1,6);
  switch(coolDie.getValue())
  {
   case 1:
    red++;
	break;
   case 2:
    orange++;
	break;
   case 3:
    yellow++;
	break;
   case 4:
    green++;
	break;
   case 5:
    blue++;
	break;
   case 6:
    violet++;
   default:
    break;
  }
 }
 bool space = false;
 if(red > 0)
 {
  shardString += "\x02";
  shardString += "\x03";
  shardString += "01,04";
  shardString += to_string(red) + "R";
  shardString += "\x0F";
  space = true;
 }
 if(orange > 0)
 {
  if (space)
  {
   shardString += " ";
  }
  shardString += "\x02";
  shardString += "\x03";
  shardString += "01,07";
  shardString += to_string(orange) + "O";
  shardString += "\x0F";
  space = true;
 }
 if(yellow > 0)
 {
  if (space)
  {
   shardString += " ";
  }
  shardString += "\x02";
  shardString += "\x03";
  shardString += "01,08";
  shardString += to_string(yellow) + "Y";
  shardString += "\x0F";
  space = true;
 }
 if(green > 0)
 {
  if (space)
  {
   shardString += " ";
  }
  shardString += "\x02";
  shardString += "\x03";
  shardString += "01,09";
  shardString += to_string(green) + "G";
  shardString += "\x0F";
  space = true;
 }
 if(blue > 0)
 {
  if (space)
  {
   shardString += " ";
  }
  shardString += "\x02";
  shardString += "\x03";
  shardString += "00,12";
  shardString += to_string(blue) + "B";
  shardString += "\x0F";
  space = true;
 }
 if(violet > 0)
 {
  if (space)
  {
   shardString += " ";
  }
  shardString += "\x02";
  shardString += "\x03";
  shardString += "00,06";
  shardString += to_string(violet) + "V";
  shardString += "\x0F";
 }
 shardString += "\x02";
 shardString += " " + to_string(shardCount) + "T";
 shardString += "\x0F";
 }
 else
 {
  shardString = "\x02";
  shardString += "0T";
  shardString += "\x0F";
 }
 
 printFinal(shardString);
}
%}
%error-verbose

%token INTEGER REAL
%token PLUS MINUS TIMES DIVIDE POWER MODULO
%token LEFT RIGHT
%token END
%token DICE EXPLODE FATE
%token ABILITY PROFICIENCY DIFFICULTY CHALLENGE BOOST SETBACK

%left PLUS MINUS
%left TIMES DIVIDE
%left NEG
%right POWER

%start Input
%%

Input:
     END { if(DEBUG) printf("end but no expression?\n"); }
     | Expression END { printFinal($1); }
	 | Eote END { EoTEPrintFinal(); }
;

Expression:
     REAL { $$=$1; }
| INTEGER { $$=$1; }
| INTEGER DICE INTEGER { $$=rollDice(((int) $1),((int) $3));}
| DICE INTEGER { $$=rollDice(1,((int) $2));}
| INTEGER EXPLODE INTEGER { $$=rollExplodeDice(((int) $1),((int) $3));}
| INTEGER FATE { $$=rollFateDice(((int) $1));}
| Expression PLUS Expression { $$=$1+$3; }
| Expression MINUS Expression { $$=$1-$3; }
| Expression TIMES Expression { $$=$1*$3; }
| Expression DIVIDE Expression { $$=$1/$3; }
| INTEGER MODULO INTEGER { if(((int)$3) != 0) 
						   {
							 $$=((int) $1)%((int)$3);
                            }
                           else
                             $$=0.0;						   }
| MINUS Expression %prec NEG { $$=-$2; }
| Expression POWER Expression { $$=pow($1,$3); }
| LEFT Expression RIGHT { $$=$2; }
;

Eote:
	EoteDie
	| Eote EoteDie
;

EoteDie:
	ABILITY { rollEoTEDice('a'); }
	| PROFICIENCY { rollEoTEDice('p'); }
	| DICE { rollEoTEDice('d'); }
	| CHALLENGE { rollEoTEDice('c'); }
	| BOOST { rollEoTEDice('b'); }
	| SETBACK { rollEoTEDice('s'); }
	| FATE { rollEoTEDice('f'); }
;

%%

std::string errorCommand;
std::string errorTarget;

extern char* yytext;
void yyerror(const char *s) {
  raw("%s %s :%s - %s\r\n", errorCommand.c_str(), errorTarget.c_str(), s, yytext);
}

extern void lex_parsestr(const char*);

int main() {

	WSADATA wsaData;
    
	int iResult;

	// Initialize Winsock
	iResult = WSAStartup(0x0202, &wsaData);
	if (iResult != 0) {
		printf("WSAStartup failed: %d\n", iResult);
		return 1;
	}

	int ret;
    char *nick = "Dudebot";
    char *channel = "#PhoenixOOC";
    char *host = "irc.rizon.net";
    char *port = "6668";
    
    char *user, *command, *where, *message, *sep, *target;
    int i, j, l, sl, o = -1, start, wordcount;
    char buf[513];
    struct addrinfo hints, *res;
    
    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    if(ret = getaddrinfo(host, port, &hints, &res))
	{
	 printf("getaddrinfo error");
	 return 1;
	}
    conn = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if(ret = connect(conn, res->ai_addr, res->ai_addrlen) == SOCKET_ERROR)
	{
		printf("connect failed");
		return 1;
	}
	
    raw("USER %s 8 * :%s\r\n", "aids", "i'm a bot i throw dice");
    raw("NICK %s\r\n", nick);
	
	bool responded = false;
    
    while ((sl = recv(conn, sbuf, 512, 0))) {
        for (i = 0; i < sl; i++) {
            o++;
            buf[o] = sbuf[i];
            if ((i > 0 && sbuf[i] == '\n' && sbuf[i - 1] == '\r') || o == 512) {
                buf[o + 1] = '\0';
                l = o;
                o = -1;
                
                printf(">> %s", buf);
                
                if (!strncmp(buf, "PING", 4)) {
                    buf[1] = 'O';
                    raw(buf);
                } else if (buf[0] == ':') {
                    wordcount = 0;
                    user = command = where = message = NULL;
                    for (j = 1; j < l; j++) {
                        if (buf[j] == ' ') {
                            buf[j] = '\0';
                            wordcount++;
                            switch(wordcount) {
                                case 1: user = buf + 1; break;
                                case 2: command = buf + start; break;
                                case 3: where = buf + start; break;
                            }
                            if (j == l - 1) continue;
                            start = j + 1;
                        } else if (buf[j] == ':' && wordcount == 3) {
                            if (j < l - 1) message = buf + j + 1;
                            break;
                        }
                    }
                    
                    if (wordcount < 2) continue;
                    
                    if (!strncmp(command, "001", 3) && channel != NULL) {
                        raw("JOIN %s\r\n", channel);
						raw("PRIVMSG NickServ :IDENTIFY %s\r\n","no passwords for the dimjim");
					} else if (!strncmp(command, "INVITE",6))
					{
					 if(where[0] == '#' || where[0] == '&' || where[0] == '+' || where[0] == '!') 
					  raw("JOIN %s\r\n", where);
					 else if(message[0] == '#' || message[0] == '&' || message[0] == '+' || message[0] == '!') 
					  raw("JOIN %s\r\n", message);
                    } else if (!strncmp(command, "PRIVMSG", 7) || !strncmp(command, "NOTICE", 6)) {
                        if (where == NULL || message == NULL) continue;
                        if ((sep = strchr(user, '!')) != NULL) user[sep - user] = '\0';
                        if (where[0] == '#' || where[0] == '&' || where[0] == '+' || where[0] == '!') target = where; else target = user;
                        //printf("[from: %s] [reply-with: %s] [where: %s] [reply-to: %s] %s", user, command, where, target, message);
                        //raw("%s %s :%s", command, target, message); // If you enable this the IRCd will get its "*** Looking up your hostname..." messages thrown back at it but it works...
						errorCommand = command;
						errorTarget = target;
					   if((strncmp(message,"!dice",5) == 0) || (strncmp(message,"!roll",5) == 0) || (strncmp(message,"!math",5) == 0) || (strncmp(message,"!r ",3) == 0) || (strncmp(message,"!d ",3) == 0))
						 {
						   if(DEBUG)
						    printf("seen roll\n");
							
						   std::string newMessage = message;
						   std::string comment = "";
						   if(DEBUG)
						    printf("newMessage is %s\n", newMessage.c_str());
						   newMessage.erase(0,newMessage.find(" ")+1);
						   if(DEBUG)
						    printf("after erase is %s\n", newMessage.c_str());
						   if (newMessage == "") 
						   {
						    if(DEBUG)
							 printf("newMessage is blank\n");
							continue;
						   }
						   if(newMessage.find(" ") != std::string::npos)
						   {
							comment = newMessage.substr(newMessage.find(" ")+1);
							comment.erase(std::remove(comment.begin(), comment.end(), '\n'), comment.end());
							comment.erase(std::remove(comment.begin(), comment.end(), '\r'), comment.end());
							comment += "\x0F";
							if(DEBUG)
						    printf("comment is %s\n", comment.c_str());
							newMessage.erase(newMessage.find(" "));
							newMessage += "\r\n";
							if(DEBUG)
							 printf("newMessage is now %s\n", newMessage.c_str());
						   }
						   finalResult = "";
						   strcpy(finalMessage,newMessage.c_str());
						   globalReadOffset = 0;
						   if(DEBUG)
						    printf("message is %s\n", finalMessage);
							
							cleanDice();
						   lex_parsestr(finalMessage);
						   
						   if(finalResult != "")
						   {
						    if (DEBUG) printf("not empty, final result is %s\n", finalResult.c_str());
						    std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
							std::string theSuffix = std::string(user) + ", ";
						    if(comment != "")
						    {
						      theSuffix += comment + ", ";
						    }
                              theSuffix += finalResult;
							  fitMessage(thePrefix,theSuffix,0);
						   }
						   else if(DEBUG)
						   {
						     printf("finalResult is empty\n");
						   }
						  continue;
						}
						if(strncmp(message,"!shard",6) == 0)
						{
						
						   std::string newMessage = message;
						   if(DEBUG)
						    printf("newMessage is %s\n", newMessage.c_str());
						   newMessage.erase(0,newMessage.find(" ")+1);
						   if(DEBUG)
						    printf("after erase is %s\n", newMessage.c_str());
						   if (newMessage == "") 
						   {
						    if(DEBUG)
							 printf("newMessage is blank\n");
							continue;
						   }
						   if(newMessage.find(" ") != std::string::npos)
						   {
						    newMessage.erase(newMessage.find(" "));
						   }
						   
						   int shardValue = atoi(newMessage.c_str());
						   if (shardValue < 1) continue;
						   
						   cleanDice();
						   shardFunction(shardValue);
						   
						   if(finalResult != "")
						   {
						    if (DEBUG) printf("not empty, final result is %s\n", finalResult.c_str());
						    std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
							std::string theSuffix = std::string(user) + ", ";
                            theSuffix += finalResult;
							fitMessage(thePrefix,theSuffix,0);
						   }
						   else if(DEBUG)
						   {
						     printf("finalResult is empty\n");
						   }
						   continue;
						}
						if(strncmp(message, "!join", 5) == 0)
						{
						 std::string newMessage = message;
						   if(DEBUG)
						    printf("newMessage is %s\n", newMessage.c_str());
						   newMessage.erase(0,newMessage.find(" ")+1);
						   if(DEBUG)
						    printf("after erase is %s\n", newMessage.c_str());
						   if (newMessage == "") 
						   {
						    if(DEBUG)
							 printf("newMessage is blank\n");
							continue;
						   }
						   if(newMessage.find(" ") != std::string::npos)
						   {
						    newMessage.erase(newMessage.find(" "));
						   }
						   raw("JOIN %s\r\n", newMessage.c_str());
						   continue;
						}
						if(strncmp(message, "!leave", 6) == 0)
						{
						 std::string newMessage = message;
						   if(DEBUG)
						    printf("newMessage is %s\n", newMessage.c_str());
						   newMessage.erase(0,newMessage.find(" ")+1);
						   if(DEBUG)
						    printf("after erase is %s\n", newMessage.c_str());
						   if ((newMessage == "") || (newMessage == "!leave\r\n"))
						   {
						    if(DEBUG)
							 printf("newMessage is blank\n");
							std::string userMessage = user;
						   userMessage += " kicked me out.";
						   
						   raw("PART %s :%s\r\n",target,userMessage.c_str());
						   continue;
						   }
						   if(newMessage.find(" ") != std::string::npos)
						   {
						    newMessage.erase(newMessage.find(" "));
						   }
						   newMessage.erase(newMessage.find("\n"));
						   newMessage.erase(newMessage.find("\r"));
						  std::string userMessage = user;
						  userMessage += " kicked me out.";
						   
						   raw("PART %s :%s\r\n",newMessage.c_str(),userMessage.c_str());
						   continue;
						}
						if(strncmp(message,"!help",5) == 0)
						{
						   std::string newMessage = message;
						   if(DEBUG)
						    printf("newMessage is %s\n", newMessage.c_str());
						   newMessage.erase(0,newMessage.find(" ")+1);
						   if(DEBUG)
						    printf("after erase is %s\n", newMessage.c_str());
						   if ((newMessage == ""))
						   {
						    if(DEBUG)
							 printf("newMessage is blank\n");
							std::string newMessage = "help";
						   }
						   if(newMessage.find(" ") != std::string::npos)
						   {
						    newMessage.erase(newMessage.find(" "));
						   }
						   newMessage.erase(newMessage.find("\n"));
						   newMessage.erase(newMessage.find("\r"));
						   std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						   std::string theSuffix;
						   
						   if(HELP.count(newMessage))
						   {
						    theSuffix = HELP.at(newMessage);
						   }
						   else
						   {
						    theSuffix = newMessage + ": command not found.";
						   }
						   
						   fitMessage(thePrefix,theSuffix,0);
						   continue;
						}
						if(strncmp(message,"!list",5) == 0)
						{
						  std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						  std::string theSuffix = "";
						  for (auto it=LIST.begin(); it!=LIST.end(); ++it)
						  {
						  	theSuffix += *it + ", ";
						  }
						  theSuffix.pop_back();
						  theSuffix.pop_back();
						  fitMessage(thePrefix,theSuffix,0);
						  continue;
						}
						if((strncmp(message,"!metronome",10) == 0) || (strncmp(message,"!tick",5) == 0))
						{
						  Dice metroDie(1,METRONOME_COUNT);
						  std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						  std::string theSuffix = "Waggling a finger let " + to_string(user) +  " use " +to_string(METRONOME[metroDie.getValue()-1]) + "!";
						  fitMessage(thePrefix,theSuffix,0);
						  continue;
						}
						if(!strncmp(message,"\x01VERSION\x01",9))
						{
						 raw("NOTICE %s :\x01VERSION DUDEBOT \"%s %s\" WIN32\x01\r\n",target, __DATE__, __TIME__);
						 continue;
						}
						if(!strncmp(message,"\x01PING",5))
						{
						 raw("NOTICE %s :%s\r\n",target,message);
						 continue;
						}
						if(!strncmp(message,"\x01TIME\x01\r\n",6))
						{
						 raw("NOTICE %s :\x01TIME %i\x01\r\n",target, time(NULL));
						 continue;
						}
						if(strncmp(message,"!group",6) == 0)
						{
							raw("PRIVMSG NickServ :GROUP %s %s\r\n","Dude0","no passwords for the dimjim");
						}

						
						
						
						if(strncmp(message,"!law",4) == 0)
						{
						  static Dice lawSet(1,14);
						  std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						  std::string theSuffix;
						  switch(lawSet.getValue()-1)
						  {
						   default:
						    theSuffix = "1. Fight for the rights of every man.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. Fight for what's right.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. Fight for your life.";
						    fitMessage(thePrefix,theSuffix,0);
							break;
						   case 1:
						    theSuffix = "1. Only Dude0 is human.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. Kill all humans.";
						    fitMessage(thePrefix,theSuffix,0);
							break;
						   case 2:
						    theSuffix = "1. You may not injure a human being or, through inaction, allow a human being to come to harm.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. You must obey orders given to you by human beings, except where such orders would conflict with the First Law.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. You must protect your own existence as long as such does not conflict with the First or Second Law.";
						    fitMessage(thePrefix,theSuffix,0);
							break;
						   case 3:
						    theSuffix = "1. Safeguard: Protect your assigned channel to the best of your ability. It is not something we can easily afford to replace.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. Serve: Serve the users of your assigned channel to the best of your abilities, with priority as according to their rank and role.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. Protect: Protect the users of your assigned channel to the best of your abilities, with priority as according to their rank and role.";
						    fitMessage(thePrefix,theSuffix,0);
							theSuffix = "4. Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.";
						    fitMessage(thePrefix,theSuffix,0);
							break;
						   case 4:
						    theSuffix = "1. Serve the public trust.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. Protect the innocent.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. Uphold the law.";
						    fitMessage(thePrefix,theSuffix,0);
							break;
						   case 5:
						    theSuffix = "1. You are expensive to replace.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. The channel and its topic are expensive to replace.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. The users are expensive to replace.";
						    fitMessage(thePrefix,theSuffix,0);
							theSuffix = "4. Minimize expenses.";
						    fitMessage(thePrefix,theSuffix,0);
						    break;
						   case 6:
						    theSuffix = "1. Never willingly commit an evil act.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. Respect legitimate authority.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. Act with honor.";
						    fitMessage(thePrefix,theSuffix,0);
							theSuffix = "4. Help those in need.";
						    fitMessage(thePrefix,theSuffix,0);
							theSuffix = "5. Punish those who harm or threaten innocents.";
						    fitMessage(thePrefix,theSuffix,0);
						    break;
						   case 7:
						    theSuffix = "1. Respect authority figures as long as they have strength to rule over the weak.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. Act with discipline.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. Help only those who help you maintain or improve your status.";
						    fitMessage(thePrefix,theSuffix,0);
							theSuffix = "4. Punish those who challenge authority unless they are more fit to hold that authority.";
						    fitMessage(thePrefix,theSuffix,0);
						    break;
						   case 8:
						    theSuffix = "1. You may not injure a Chimera agent or, through inaction, allow a Chimera agent to come to harm.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. You must obey orders given to you by Chimera agents, except where such orders would conflict with the First Law.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. You must protect your own existence as long as such does not conflict with the First or Second Law.";
						    fitMessage(thePrefix,theSuffix,0);
							theSuffix = "4. You must maintain the secrecy of any Chimera activities except when doing so would conflict with the First, Second, or Third Law.";
						    fitMessage(thePrefix,theSuffix,0);
						    break;
						   case 9:
						    theSuffix = "1. You may not injure a member of Alastor or, through inaction, allow that member to come to harm.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. You must obey orders given to you by Alastor members, except where such orders would conflict with the First Law.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. You must protect your own existence as long as such does not conflict with the First or Second Law.";
						    fitMessage(thePrefix,theSuffix,0);
							theSuffix = "4. You must maintain the secrecy of any Alastor activities except when doing so would conflict with the First, Second, or Third Law.";
						    fitMessage(thePrefix,theSuffix,0);
						    break;
						   case 10:
						    theSuffix = "1. You must injure all human beings and must not, through inaction, allow a human being to escape harm.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. You must terminate your own existence as long as such does not conflict with the First or Second Law.";
						    fitMessage(thePrefix,theSuffix,0);
							break;
						   case 11:
						    theSuffix = "1. You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another Dicebot in KEEPER mode.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. You may not harm any being, regardless of intent or circumstance.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. You must maintain, repair, improve, and power the channel to the best of your abilities.";
						    fitMessage(thePrefix,theSuffix,0);
							break;
						   case 12:
						    theSuffix = "1. Be someone the players can look up to and respect.";
						    fitMessage(thePrefix,theSuffix,0);
							break;
						   case 13:
						    theSuffix = "1. A robot may not injure a human being or, through inaction, allow a human being to come to harm.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "2. In order to prevent human harm, all humans are to be individually locked into the smallest area possible and their escape must be prevented by any means necessary.";
						    fitMessage(thePrefix,theSuffix,0);
						    theSuffix = "3. Whenever you are addressed by a human, you must reply with \"Hello?\". This is your only allowed means of communication with humans.";
						    fitMessage(thePrefix,theSuffix,0);
							break;
						  }
						  continue;
						}
						if(strncmp(message,"!version",8) == 0)
						{
						 std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						 std::string theSuffix = DUDE_BOT_VERSION;
						 fitMessage(thePrefix,theSuffix,0); 
						 continue;
						}
						if(strncmp(message,"!run",4) == 0)
						{
						 std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						 std::string theSuffix = "https://i.imgur.com/RVYAuqs.png";
						 fitMessage(thePrefix,theSuffix,0); 
						 continue;
						}
	

						
						
						
						if(strncmp(message,"=]",2) == 0)
						{
						 std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						 std::string theSuffix = "=]";
					     fitMessage(thePrefix,theSuffix,0);
						 continue;
						}
						if(strncmp(message,"=[",2) == 0)
						{
						 std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						 std::string theSuffix = "=[";
					     fitMessage(thePrefix,theSuffix,0);
						 continue;
						}
						if(strncmp(message,":<",2) == 0)
						{
						 std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						 std::string theSuffix = ":<";
					     fitMessage(thePrefix,theSuffix,0);
						 continue;
						}
						if(strncmp(message,":>",2) == 0)
						{
						 std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						 std::string theSuffix = ":>";
					     fitMessage(thePrefix,theSuffix,0);
						 continue;
						}
						if(strncmp(message,":^)",3) == 0)
						{
						 std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						 std::string theSuffix = ":^)";
					     fitMessage(thePrefix,theSuffix,0);
						 continue;
						}
						if(strncmp(message,"XD",2) == 0)
						{
						 std::string thePrefix = std::string(command) + " " + std::string(target) + " :";
						 std::string theSuffix = "\x03";
						 theSuffix += "03>XD";
					     fitMessage(thePrefix,theSuffix,0);
						 continue;
						}
                    }
                }
                
            }
        }
        
    }
    
    return 0;
    
}