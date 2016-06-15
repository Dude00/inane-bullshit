#include "Dice.h"
#include <vector>
#include <string>
#include <random>
#include <sstream>
#include "randutils.hpp"

std::mt19937 rng_engine{randutils::auto_seed_128{}.base()};

template <typename T>
std::string to_string(T value)
{
	std::ostringstream os;
	os << value;
	return os.str();
}

Dice::Dice()
{
 num = 0;
 sides = 0;
 hasRolled = false;
 valid = false;
 value = 0;
}

Dice::Dice(int a,int b) : num(a), sides(b)
{
 hasRolled = false;
 if ((num >= 0) && (sides > 0) && num <= 10000)
  valid = true;
 else
  valid = false;
 value = 0;
}

void Dice::roll()
{
 if(valid & !hasRolled)
 {
  std::uniform_int_distribution<> dis(1, sides);
  for(int i = 0; i < num; i++)
  {
   rolls.push_back(dis(rng_engine));
   value += rolls[i];
  }
  hasRolled = true;
 }
}

int Dice::getValue()
{
 roll();
 return value;
}

std::string Dice::printResult()
{
 roll();
 std::string result;
 result = to_string(num) + "d" + to_string(sides) + ": ";
 if(valid)
 {
    if(num > 1)
	{
     result += "[";
	}
	 for(int i = 0; i < num; i++)
	 {
	  bool doit = false;
	  if(double(rolls[i]-1)/double(sides-1) == 0)
	  {
	   result += "\x03";
	   result += "04";
	   doit = true;
	  }
	  else if(double(rolls[i]-1)/double(sides-1) == 1)
	  {
	   result += "\x03";
	   result += "09";
	   doit = true;
	  }
	  else if(double(rolls[i]-1)/double(sides-1) <= 0.2)
	  {
	   result += "\x03";
	   result += "05";
	   doit = true;
	  }
	  else if(double(rolls[i]-1)/double(sides-1) >= 0.79)
	  {
	   result += "\x03";
	   result += "03";
	   doit = true;
	  }
      result += to_string(rolls[i]);
	  if(doit)
	  {
	   result += "\x0F";
	   doit = false;
	  }
	  if(i != (num-1))
	  {
		result += ", ";
	  }
	 }
	if(num > 1)
	{
	 result += "]";
	}
 }
 else
 {
  if(sides < 1)
   result += "Invalid Dice";
  else if(num > 100)
   result += "calm down";
  else
   result += "yell at dude if you see this please";
 }
 return result;
}

ExplodeDice::ExplodeDice()
{
 num = 0;
 sides = 0;
 hasRolled = false;
 valid = false;
 value = 0;
 explode = 0;
 shards = 0;
}

ExplodeDice::ExplodeDice(int a,int b)
{
 num = a;
 sides = b;
 hasRolled = false;
 if ((num >= 0) && (sides > 1) && num <= 10000)
  valid = true;
 else
  valid = false;
 value = 0;
 explode = 0;
 shards = 0;
}

void ExplodeDice::roll()
{
 if(valid & !hasRolled)
 {
  std::uniform_int_distribution<> dis(1, sides);
  for(int i = 0; i < num; i++)
  {
   rolls.push_back(dis(rng_engine));
   value += rolls[i];
   if(rolls[i] >= 4)
    shards++;
   if(rolls[i] == sides)
    explode++;
  }
  hasRolled = true;
 }
}

int ExplodeDice::getExplode()
{
 roll();
 return explode;
}

int ExplodeDice::getShards()
{
 roll();
 return shards;
}

std::string ExplodeDice::printResult()
{
 roll();
 std::string result;
 result = to_string(num) + "e" + to_string(sides) + ": ";
 if(valid)
 {
    if(num > 1)
	{
     result += "[";
	}
	 for(int i = 0; i < num; i++)
	 {
	  bool doit = false;
	  if(double(rolls[i]-1)/double(sides-1) == 0)
	  {
	   result += "\x03";
	   result += "04";
	   doit = true;
	  }
	  else if(double(rolls[i]-1)/double(sides-1) == 1)
	  {
	   result += "\x03";
	   result += "09";
	   doit = true;
	  }
	  else if(double(rolls[i]-1)/double(sides-1) <= 0.2)
	  {
	   result += "\x03";
	   result += "05";
	   doit = true;
	  }
	  else if(double(rolls[i]-1)/double(sides-1) >= 0.79)
	  {
	   result += "\x03";
	   result += "03";
	   doit = true;
	  }
      result += to_string(rolls[i]);
	  if(doit)
	  {
	   result += "\x0F";
	   doit = false;
	  }
	  if(i != (num-1))
	  {
		result += ", ";
	  }
	 }
	if(num > 1)
	{
	 result += "]";
	}
 }
 else
 {
  if(sides <= 1)
   result += "NO";
  else if(num > 100)
   result += "calm down";
  else
   result += "yell at dude if you see this please";
 }
 return result;
}

FateDice::FateDice()
{
 num = 0;
 sides = 3;
 hasRolled = false;
 valid = false;
 value = 0;
}

FateDice::FateDice(int a)
{
 num = a;
 sides = 3;
 hasRolled = false;
 if ((num >= 0) && num <= 10000)
  valid = true;
 else
  valid = false;
 value = 0;
}

char FateDice::numToSym(int a)
{
 switch(a)
 {
  case 1:
   return '+';
  case -1:
   return '-';
  default:
   return '0';
 }
}

void FateDice::roll()
{
 if(valid & !hasRolled)
 {
  std::uniform_int_distribution<> dis(1, sides);
  for(int i = 0; i < num; i++)
  {
   rolls.push_back(dis(rng_engine) - 2);
   value += rolls[i];
  }
  hasRolled = true;
 }
}

std::string FateDice::printResult()
{
 roll();
 std::string result;
 result = to_string(num) + "f" + ": ";
 if(valid)
 {
    if(num > 1)
	{
     result += "[";
	}
	 for(int i = 0; i < num; i++)
	 {
	  if(rolls[i] == -1)
	  {
	   result += "\x03";
	   result += "04";
	  }
	  else if(rolls[i] == 1)
	  {
	   result += "\x03";
	   result += "09";
	  }
      result += numToSym(rolls[i]);
	  result += "\x0F";
	  if(i+1 < num)
	   result += " ";
	 }
	if(num > 1)
	{
	 result += "]";
	}
 }
 else
 {
  if(sides < 1)
   result += "Invalid Dice";
  else if(num > 100)
   result += "calm down";
  else
   result += "yell at dude if you see this please";
 }
 return result;
}

EoTEDice::EoTEDice()
{
 type = '\0';
 num = 0;
 sides = 0;
 hasRolled = false;
 valid = false;
 value = 0;
 advantage = 0;
 triumph = 0;
 despair = 0;
 white = 0;
 black = 0;
}

EoTEDice::EoTEDice(char a)
{
 type = tolower(a);
  num = 1;
 switch(type)
 {
  case 'b':
  case 's':
   sides = 6;
   break;
  case 'a':
  case 'd':
   sides = 8;
   break;
  case 'p':
  case 'c':
  case 'f':
   sides = 12;
   break;
  default:
   sides = 0;
   break;
 }
 hasRolled = false;
 if ((num >= 0) && (sides > 0) && num <= 10000)
  valid = true;
 else
  valid = false;
 value = 0;
 advantage = 0;
 triumph = 0;
 despair = 0;
 white = 0;
 black = 0;
}

void EoTEDice::roll()
{
 if(valid & !hasRolled)
 {
  std::uniform_int_distribution<> dis(1, sides);
  for(int i = 0; i < num; i++)
  {
   rolls.push_back(dis(rng_engine));
   switch(type)
   {
	case 'b':
	 switch(rolls[i])
	 {
	  case 4:
	   advantage++;
      case 3:
	   value++;
	   break;
	  case 5:
	   advantage++;
	  case 6:
	   advantage++;
	   break;
	  default:
	   break;
	 }
	 break;
	case 's':
	 switch(rolls[i])
	 {
	  case 3:
	  case 4:
	   value--;
	   break;
	  case 5:
	  case 6:
	   advantage--;
	   break;
	  default:
	   break;
	 }
	 break;
	case 'a':
	 switch(rolls[i])
	 {
	  case 4:
	   value++;
	  case 2:
	  case 3:
	   value++;
	   break;
	  case 7:
	   value++;
	  case 5:
	  case 6:
	   advantage++;
	   break;
	  case 8:
	   advantage += 2;
	  default:
	   break;
	 }
	 break;
	case 'd':
	 switch(rolls[i])
	 {
	  case 8:
	   advantage--;
	  case 2:
	   value--;
	   break;
	  case 3:
	   value -= 2;
	   break;
	  case 7:
	   advantage--;
	  case 4:
	  case 5:
	  case 6:
	   advantage--;
	   break;
	  default:
	   break;
	 }
	 break;
	case 'p':
	 switch(rolls[i])
	 {
	  case 7:
	  case 8:
	  case 9:
	   advantage++;
	  case 2:
	  case 3:
	   value++;
	   break;
	  case 4:
	  case 5:
	   value += 2;
	   break;
	  case 10:
	  case 11:
	   advantage++;
	  case 6:
	   advantage++;
	   break;
	  case 12:
	   value++;
	   triumph++;
	   break;
	  default:
	   break;
	 }
	 break;
	case 'c':
	 switch(rolls[i])
	 {
	  case 2:
	  case 3:
	   value--;
	   break;
	  case 4:
	  case 5:
	   value -= 2;
	   break;
	  case 8:
	  case 9:
	   value--;
	  case 6:
	  case 7:
	   advantage--;
	   break;
	  case 10:
	  case 11:
	   advantage -= 2;
	   break;
	  case 12:
	   value--;
	   despair++;
	   break;
	  default:
	   break;
	 }
	 break;
	case 'f':
	 switch(rolls[i])
	 {
	  case 7:
	   black++;
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	   black++;
	   break;
	  case 10:
	  case 11:
	  case 12:
	   white++;
	  case 8:
	  case 9:
	   white++;
	   break;
	  default:
	   break;
	 }
	 break;
	default:
	 break;
   } 
  }
  hasRolled = true;
 }
}

std::string EoTEDice::printResult()
{
 roll();
 std::string result = "";
 if(valid)
 {
   switch(type)
   {
	case 'b':
	 switch(rolls[0])
	 {
      case 3:
	   result += "\u2736"; //success
	   break;
	  case 4:
	   result += "\u2736"; //success
	   result += "\u2127"; //advantage
	   break;
	  case 5:
	   result += "\u2127"; //advantage
	  case 6:
	   result += "\u2127"; //advantage
	   break;
	  default:
	   result += "0";
	   break;
	 }
	 break;
	case 's':
	 switch(rolls[0])
	 {
	  case 3:
	  case 4:
	   result += "\u25BC"; //failure
	   break;
	  case 5:
	  case 6:
	   result += "\u2394"; //threat
	   break;
	  default:
	   result += "0";
	   break;
	 }
	 break;
	case 'a':
	 switch(rolls[0])
	 {
	  case 4:
	   result += "\u2736"; //success
	  case 2:
	  case 3:
	   result += "\u2736"; //success
	   break;
	  case 7:
	   result += "\u2736"; //success
	  case 5:
	  case 6:
	   result += "\u2127"; //advantage
	   break;
	  case 8:
	   result += "\u2127"; //advantage
	   result += "\u2127"; //advantage
	   break;
	  default:
	   result += "0";
	   break;
	 }
	 break;
	case 'd':
	 switch(rolls[0])
	 {
	  case 3:
	   result += "\u25BC"; //failure
	  case 2:
	   result += "\u25BC"; //failure
	   break;
	  case 7:
	  result += "\u2394"; //threat
	  case 4:
	  case 5:
	  case 6:
	   result += "\u2394"; //threat
	   break;
	  case 8:
	   result += "\u25BC"; //failure
	   result += "\u2394"; //threat
	   break;
	  default:
	   result += "0";
	   break;
	 }
	 break;
	case 'p':
	 switch(rolls[0])
	 {
	  case 4:
	  case 5:
	   result += "\u2736"; //success
	  case 2:
	  case 3:
	   result += "\u2736"; //success
	   break;
	  case 10:
	  case 11:
	   result += "\u2127"; //advantage
	  case 6:
	   result += "\u2127"; //advantage
	   break;
	  case 7:
	  case 8:
	  case 9:
	   result += "\u2736"; //success
	   result += "\u2127"; //advantage
	   break;
	  case 12:
	   result += "\u2388"; //triumph
	   break;
	  default:
	   result += "0";
	   break;
	 }
	 break;
	case 'c':
	 switch(rolls[0])
	 {
	  case 4:
	  case 5:
	   result += "\u25BC"; //failure
	  case 2:
	  case 3:
	   result += "\u25BC"; //failure
	   break;
	  case 8:
	  case 9:
	   result += "\u25BC"; //failure
	  case 6:
	  case 7:
	   result += "\u2394"; //threat
	   break;
	  case 10:
	  case 11:
	   result += "\u2394"; //threat
	   result += "\u2394"; //threat
	   break;
	  case 12:
	   result += "\u238A"; //despair
	   break;
	  default:
	   result += "0";
	   break;
	 }
	 break;
	case 'f':
	 switch(rolls[0])
	 {
	  case 7:
	   result += "\u25CF"; //black
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	   result += "\u25CF"; //black
	   break;
	  case 10:
	  case 11:
	  case 12:
	   result += "\u25CB"; //white
	  case 8:
	  case 9:
	   result += "\u25CB"; //white
	   break;
	  default:
	   result += "0";
	   break;
	 }
	 break;
	default:
	 break;
   } 
 }
 else
 {
  if(sides < 1)
   result += "Invalid Dice";
  else if(num > 100)
   result += "calm down";
  else
   result += "yell at dude if you see this please";
 }
 return result;
}