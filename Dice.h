#ifndef DICE_H
#define DICE_H

#include <vector>
#include <string>
#include <random>

class Dice {
 protected:
  int num, sides;
  std::vector<int> rolls;
  bool hasRolled;
  bool valid;
  unsigned int value;
  virtual void roll();
 public:
  Dice(); //default
  Dice(int, int); //proper
 
  int getValue();
  virtual std::string printResult();
};

class ExplodeDice : public Dice {
 protected:
  void roll();
  unsigned int explode;
  unsigned int shards;
 public:
  ExplodeDice();
  ExplodeDice(int, int);
  
  int getExplode();
  int getShards();
  std::string printResult();
};

class FateDice : public Dice {
 protected:
  void roll();
  char numToSym(int);
 public:
  FateDice();
  FateDice(int);

  std::string printResult();
};

class EoTEDice : public Dice {
 protected:
  void roll();
  char type;
 public:
  EoTEDice();
  EoTEDice(char);
  
  int advantage;
  int triumph;
  int despair;
  int white;
  int black;

  std::string printResult();
};


#endif