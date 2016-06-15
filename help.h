#include <string>
#include <unordered_map>
#include <set>
static const std::set<std::string> LIST = {
 "!help","!roll","!shard","!list","!join","!leave","!laws","!version","!run","!metronome"
};

static const std::string ROLL_HELP = "!roll: Roll them dice. 1d6 for dice, 1e6 for exploding dice, 4f for fate dice, apdcbsf for EoTE dice. Supports +, -, *, /, % operators. Also ()s, ^ and decimals if you really want. Use: !roll 4d20+6d9+20. Aliases: !roll, !r, !dice, !d, !math";

static const std::unordered_map<std::string,std::string> HELP = {
 {"help","!help: Look up what a command does. Really isn't that hard. Use: !help command" },
 {"!help","!help: Look up what a command does. Really isn't that hard. Use: !help command" },
 {"roll", ROLL_HELP},
 {"!roll",ROLL_HELP },
 {"dice",ROLL_HELP },
 {"!dice",ROLL_HELP },
 {"math",ROLL_HELP },
 {"!math",ROLL_HELP },
 {"r",ROLL_HELP },
 {"!r",ROLL_HELP },
 {"d",ROLL_HELP },
 {"!d",ROLL_HELP },
 {"shard","!shard: Rolls exploding dice and counts shards, then rolls colours for you. Use: !shard 6"},
 {"!shard","!shard: Rolls exploding dice and counts shards, then rolls colours for you. Use: !shard 6"},
 {"list","!list: Lists out all the commands that I'm legally allowed to mention."},
 {"!list","!list: Lists out all the commands that I'm legally allowed to mention."},
 {"metronome","!metronome: Gives a move that Metronome can roll. Dimjim put the list together because I was lazy so he gets a Thanks here. Use: !metronome. Aliases: !metronome, !tick"},
 {"!metronome","!metronome: Gives a move that Metronome can roll. Dimjim put the list together because I was lazy so he gets a Thanks here. Use: !metronome. Aliases: !metronome, !tick"},
 {"tick","!metronome: Gives a move that Metronome can roll. Dimjim put the list together because I was lazy so he gets a Thanks here. Use: !metronome. Aliases: !metronome, !tick"},
 {"!tick","!metronome: Gives a move that Metronome can roll. Dimjim put the list together because I was lazy so he gets a Thanks here. Use: !metronome. Aliases: !metronome, !tick"},
 {"join","!join: Order this bot into another channel. Use: !join #channel"},
 {"!join","!join: Order this bot into another channel. Use: !join #channel"},
 {"leave","!leave: Kick this bot's stupid ass to the curb. #channel defaults to where the order is given. Use: !leave #channel."},
 {"!leave","!leave: Kick this bot's stupid ass to the curb. #channel defaults to where the order is given. Use: !leave #channel."},
 {"law","!laws: AI STATE LAWS"},
 {"!law","!laws: AI STATE LAWS"},
 {"laws","!laws: AI STATE LAWS"},
 {"!laws","!laws: AI STATE LAWS"},
 {"version","!version: Returns the version, like I have version control or something."},
 {"!version","!version: Returns the version, like I have version control or something."},
 {"run","!run: who are you running from?"},
 {"!run","!run: who are you running from?"}
};