#!/usr/bin/env perl
use strict;
use warnings;

# #############################################################################
# LOST AND FORGOTTEN ISLAND
# Greg Kennedy 2021

# Based on a BASIC code listing from "Big Computer Games" (1984)
# submitted by Ken Modesitt and Jeffery Yuan after first appearing in
#  Creative Computing (March 1980)
# which was in turn ADAPTED FROM "COMPUTERS AND SOCIETY" VOL.7-NO.3,FALL,1976

# #############################################################################
# DEPENDENCIES
use List::Util qw( first );
use Scalar::Util 'looks_like_number';

# #############################################################################
# CONSTANTS
#  Definiton of each tool.
use constant TOOLS => (
  { name => 'AXE',    points_boat => 1, dual_use   => 1, dangerous => 1 },
  { name => 'CHISEL', points_boat => 1, bonus_tool => 'HAMMER' },
  { name => 'HAMMER', points_boat => 1, dangerous  => 1 },
  { name => 'NAILS AND SCREWS', points_boat => 1 },
  { name => 'SAW',              points_boat => 1 },
  { name => 'LUMBER',           points_boat => 2 },

  { name => 'SHOVEL',     points_gold => 1 },
  { name => 'PICKAXE',    points_gold => 1, dangerous => 1 },
  { name => 'EXPLOSIVES', points_gold => 2, explosive => 1 },
);

# #############################################################################
# HELPER FUNCTIONS
#  Take input from keyboard
#  Return trimmed string, uppercased
sub input {
  my $val = <STDIN>;
  $val =~ s/^\s+//;
  $val =~ s/\s+$//;
  return uc($val);
}

# Take and validate input from keyboard.
#  Input must match from a list of acceptable answers.
#  Print $message and repeat until valid input received.
sub input_choice {
  my ( $answers, $message ) = @_;

  my $val;

  do {
    # read input
    $val = input();

    # check if input is in whitelist
    if ( !defined( first { $_ eq $val } @$answers ) ) {
      print $message;
      undef $val;
    }
  } while ( !$val );

  return $val;
}

# validate that value looks like a number and isn't infinity or NaN
sub is_number {
  my $num = shift;
  return looks_like_number($num) && $num !~ /inf|nan/i;
}

# probability functions
sub FNC {
  return exp($_[0]) + exp( -$_[0] );
}

sub FNS {
  return exp($_[0]) - exp( -$_[0] );
}

# print current state
sub status {
  # THE FOLLOWING IS THE SUBROUTINE STATE
  my ($total_work_points, @players) = @_;

  print "YOUR SITUATION AT THIS TIME\n\n";

  foreach my $player (@players) {
    next if $player->{dead};

    print $player->{name} . " HAS "
      . int( $player->{gold} )
      . " DOLLARS WORTH OF GOLD, A TOOL\n";
    print "PROFICIENCY OF "
      . $player->{tool_proficiency} . ", "
      . int( $player->{work_points} )
      . " WORK POINTS, WHICH\n";
    print "IS "
      . int( $player->{work_points} / ( $total_work_points || 1 ) * 100 + .5 )
      . " PERCENT OF THE TOTAL, AND THE FOLLOWING TOOLS:\n";
    foreach my $tool ( @{ $player->{inventory} } ) {
      print "      " . $tool->{name} . "\n";
    }

    print "JUST HIT RETURN WHEN YOU ARE READY TO GO ON.";
    input();
  }

  print "THE SUM OF EVERYONE'S WORK POINTS IS "
    . int($total_work_points) . ".\n\n";
}

##############################################################################
# ENTRY POINT

# INSTRUCTIONS
print "WELCOME TO THE LOST AND FORGOTTEN ISLAND.\n",
      'WOULD YOU LIKE SOME INSTRUCTIONS? ';

my $instructions
  = input_choice( [ 'YES', 'NO' ], "INVALID ANSWER, PLEASE RETYPE. YES OR NO? " );

if ( $instructions eq 'YES' ) {
  print << 'INSTR';
LOST AND FORGOTTEN ISLAND IS A SURVIVAL GAME BASED ON
COOPERATION. IT CONTAINS A MIXTURE OF LIFE'S VALUES.
IMAGINE:
         YOU HAVE BEEN SHIPWRECKED ON A REMOTE ISLAND.
YOU HAVE THE CHOICE OF DIGGING FOR GOLD AND/OR BUILDING
A SHIP TO SURVIVE THE APPROACHING HURRICANE.
CAN YOU SURVIVE?  IF SO, WITH HOW MUCH GOLD?

      GOOD LUCK

INSTR
}

my $again;
do {
  # setup game

  # clear the existing player list
  my @players = ();

  # NUMBER OF PLAYERS
  print "HOW MANY PEOPLE (1/2/3) ARE PLAYING? ";
  my $player_count
    = input_choice( [ "1", "2", "3" ], "YOU MUST PLAY WITH 1, 2 OR 3 PLAYERS" );

  # Initialize all players.
  for my $i ( 1 .. $player_count ) {
    print "PLAYER $i WHAT NAME ARE YOU USING? ";

    my $name;
    do {
      $name = input();

      foreach my $player (@players) {
        if ( $player->{name} eq $name ) {
          print
            "SOMEONE ELSE ALREADY HAS THIS NAME SO PLEASE CHOOSE ANOTHER.\n";
          undef $name;
          last;
        }
      }
    } while ( !$name );

    # We have a name.  Set up a player info hash, and
    #  add it to the array.
    my %player = (
      name             => $name,
      dead             => 0,
      gold             => 0,
      work_points      => 0,
      tool_proficiency => int( rand(11) + 2 ),
      inventory        => []
    );

    # put random tools into the inventory
    #  these are "copies" of tools from the TOOLS constant
    for my $j ( 0 .. 5 - $player_count ) {
      my $toolId = int( rand( scalar TOOLS ) );
      push @{ $player{inventory} }, { %{ (TOOLS)[$toolId] } };
    }

    push @players, \%player;
  }

  # other variables
  my $storm_distance    = 4;
  my $total_work_points = 0;

  # main loop
  for my $day ( 1 .. 5 ) {

    # WHICH DAY?
    print "THIS IS DAY $day\n";

    status($total_work_points, @players);

    # Storm handling (?)
    if ( $storm_distance == 1 ) {

      # storm has hit today
      my $team_work_points = 0;
      foreach my $player (@players) {

        # players who put >= 25% into the Work Points get to
        #  pool all their points together as a Team
        if ( $total_work_points * 0.25 <= $player->{work_points} ) {
          $team_work_points += ( $player->{work_points} || 0 );
          $player->{team_player} = 1;
        }
      }

      # time to calculate / show final results
      foreach my $player (@players) {
        next if $player->{dead};

        print "THE RESULTS FOR " . $player->{name} . ":\n";

        if ( $player->{team_player} ) {
          $player->{work_points} = $team_work_points;
        }

        my $z1 = int( 60 * exp( -$player->{work_points} / 6 ) );
        my $z2 = int(
          50 * (
            1 + FNS( ( 7 - $player->{work_points} ) / 8.5 )
              / FNC( ( 7 - $player->{work_points} ) / 8.5 )
          )
        );
        my $z3 = int(
          50 * (
            1 + FNS( ( 14 - $player->{work_points} ) / 5 )
              / FNC( ( 14 - $player->{work_points} ) / 5 )
          )
        );
        my $r5 = int( rand(101) );

print "z1=$z1, z2=$z2, z3=$z3, r5=$r5\n";

        if ( $player->{boat_work} ) {
          if ( $r5 <= $z1 ) {
            print "PROPER CONDOLENCES WILL BE SENT TO THE FRIENDS\n";
            print "AND RELATIVES OF "
              . $player->{name}
              . " WHO DROWNED DURING\n";
            print "TYPHOON URSULA.\n";
          } elsif ( $r5 <= $z2 ) {
            print $player->{name} . ", YOU MADE IT BACK TO HONOLULU BUT A\n";
            print "LARGE WAVE WASHED YOUR GOLD OVERBOARD. SORRY.\n";
          } elsif ( $r5 <= $z3 ) {
            print $player->{name}
              . ", YOU MADE IT BACK BUT THE BOAT NEARLY SWAMPED.\n";
            print "SO, HALF YOUR GOLD WAS THROWN OVERBOARD.\n";
            print "THIS MEANS YOU HAVE "
              . int( $player->{gold} / 2 )
              . " DOLLARS WORTH OF GOLD LEFT.\n";
          } else {
            print $player->{name} . ", CONGRATULATIONS!\n";
            print "YOU MADE IT WITH ALL YOUR GOLD, "
              . int( $player->{gold} )
              . " DOLLARS WORTH.\n";
          }
        } else {
          if ( $r5 < 97 ) {
            print $player->{name} . ", DID NOT GET OFF THE ISLAND AND WAS\n";
            print "KILLED BY TYPHOON URSULA.\n";
          } else {
            print $player->{name}
              . ", YOU SURVIVED TYPHOON URSULA, BUT LOST ALL YOUR GOLD\n";
            print
              "AND HAD BETTER START MAKING SMOKE SIGNALS BECAUSE YOU WERE\n";
            print "LEFT BEHIND.\n";
          }
        }
      }
      last;

    } elsif ( $storm_distance < 4 ) {
      $storm_distance--;
      print "THE STORM IS ABOUT TO HIT\n";
    } else {

      # chance to start the storm countdown
      if ( $day == 3 ) { $storm_distance = 3; }    # always start by Wednesday
      else {
        if ( int( rand(4) ) + 1 == 4 ) {
          $storm_distance = 3;    # 25% chance to start the storm earlier
        }
      }
    }

    # Tool trading
    if ( $player_count > 1 ) {
      print "DO ANY OF YOU WISH TO TRADE TOOLS? ";
      my $response = input_choice( [ 'YES', 'NO' ],
        "PLEASE TRY AGAIN. YOU MUST ANSWER YES OR NO. " );
      if ( $response eq 'YES' ) {

        print "WHO (ONE NAME ONLY PLEASE) WISHES TO TRADE? ";
        my $first_trader;
        do {
          my $name = input();
          $first_trader = first { $name eq $_->{name} } @players;
          if (! $first_trader) {
            print "YOU MUST ANSWER WITH ONE OF THE FOLLOWING:\n";
            foreach my $player (@players) {
              print "'$player->{name}'\n";
            }
            print "PLEASE TRY AGAIN\n";
          }
        } while ( !$first_trader );

        print "WHO ELSE WISHES TO TRADE? ";
        my $second_trader;
        do {
          my $name = input();
          $second_trader = first { $name eq $_->{name} } @players;
          if (! $second_trader) {
            print "YOU MUST ANSWER WITH ONE OF THE FOLLOWING:\n";
            foreach my $player (@players) {
              print "'$player->{name}'\n";
            }
            print "PLEASE TRY AGAIN\n";
          }
        } while ( !$second_trader );

        my $trade_on = 1;
        for my $trader ($first_trader, $second_trader) {
          print "$trader->{name},\n",
                "ARE YOU GIVING ANY GOLD IN THIS TRADE? ";
          my $giving_gold = input_choice( [ 'YES', 'NO', 'T', 'X' ],
            "PLEASE TRY AGAIN. YOU MUST ANSWER\nYES, NO,\nX (TO CALL OFF THE TRADE), OR T (TO SEE THE LIST OF\nTOOLS WHICH EVERYONE HAD BEFORE THE START OF THIS TRADE.\n" );
          if ($giving_gold eq 'X') {
            $trade_on = 0;
            last;
          } elsif ($giving_gold eq 'T') {
            status($total_work_points, @players);
            redo;
          } elsif ($giving_gold eq 'YES') {
            my $gold;
            do {
              print "$trader->{name},\n",
                    "HOW MUCH GOLD (IN DOLLARS) ARE YOU GOING TO GIVE? ";
              my $gold = input();
              if (! is_number($gold) || $gold < 0) {
                undef $gold;
              }
              elsif ($gold > $trader->{gold}) {
                print "YOU MAY NOT GIVE MORE THAN YOU HAVE\n ( $trader->{gold} ) DOLLARS\n";
              }
            } while (!defined $gold);

            # put gold into escrow
            $trader->{gold} -= $gold;
          }
        }
      }
    }

    # Daily work
    foreach my $player (@players) {
      next if $player->{dead};

      print $player->{name} . " WHAT ARE YOU GOING TO WORK ON TODAY? ";
      my $work = input_choice(
        [ 'BOAT', 'GOLD' ],
        "PLEASE ANSWER BOAT IF YOU WANT TO WORK ON THE BOAT\nOR GOLD IF YOU WANT TO MINE GOLD. "
      );

      if ( $work eq 'GOLD' ) {

        # WORKING ON SOME GOLD

        # loop through every tool in tool-slots
        my $work_points = 0;
        foreach my $tool ( @{ $player->{inventory} } ) {
          if ( $tool->{dual_use} ) {
            print $player->{name}
              . " DO YOU WISH TO USE THE "
              . $tool->{name}
              . " TO MINE GOLD?\n";
            print "REMEMBER THAT THE "
              . $tool->{name}
              . " DROPS GREATLY IN VALUE\n";
            print "IF IT IS USED TO MINE GOLD. ";
            my $use_tool = input_choice( [ 'YES', 'NO' ],
              "PLEASE TRY AGAIN. YOU MUST USE YES OR NO." );
            if ($use_tool) {

# Using the dual_use tool gives you points_boat, but then cuts its value in half (round up)
              $work_points
                += $tool->{points_boat} * $player->{tool_proficiency};

     # This formula seems awkward, but the result is: 1 -> 0.5 -> 0.3 -> 0.2 ...
              $tool->{points_boat}
                = int( ( $tool->{points_boat} || 0 ) * 5 + .5 ) / 10;
            }
          } else {

            # non dual-use tool just uses points_gold
            $work_points
              += ( $tool->{points_gold} || 0 ) * $player->{tool_proficiency};
          }
        }

        my $multiplier = rand(2) + 1;

      # The original had a bug that gave Player 1 twice as much as the other two
      #  this has been fixed to use player_count instead
        if ( $player_count == 1 ) {
          $multiplier *= .5;
        } else {
          $multiplier *= .25;
        }
        my $gold = $multiplier * 200 * $work_points;

        print $player->{name}
          . " HAS JUST MADE "
          . int($gold)
          . " DOLLARS MORE GOLD.\n";
        $player->{gold} += $gold;
      } elsif ( $work eq 'BOAT' ) {

        # boat work

        # give player credit for boat work
        $player->{boat_work} = 1;

        # loop through every tool in tool-slots
        my $work_points = 0;
        foreach my $tool ( @{ $player->{inventory} } ) {
          if ( $tool->{bonus_tool} ) {

          # This tool gets a bonus if paired with another (e.g. Chisel + Hammer)
            my $matching_tool = 0;
            foreach my $check_tool ( @{ $player->{inventory} } ) {
              if ( $tool->{bonus_tool} eq $check_tool->{name} ) {
                $matching_tool = 1;
                last;
              }
            }

            if ($matching_tool) {

              # double points
              $work_points += 2 * ( $tool->{points_boat} || 0 )
                * $player->{tool_proficiency};
            } else {

              # no bonus
              $work_points
                += ( $tool->{points_boat} || 0 ) * $player->{tool_proficiency};
            }

          } else {

            # Flat bonus
            $work_points
              += ( $tool->{points_boat} || 0 ) * $player->{tool_proficiency};
          }
        }

        $work_points /= 12;
        print $player->{name}
          . " HAS EARNED "
          . int($work_points)
          . " MORE WORK POINTS.\n";
        $player->{work_points} += $work_points;
        $total_work_points += $work_points;
      }

  # After work there is a chance of tool effects.
  #  The original game did this in an odd way (chose a tool type and if you hold
  #  that type you're harmed.)
  # Replaced this with "select a tool slot, and if that slot is dangerous
  #  there are Effects."
      my $slot = int( rand(9) );
      my $tool = $player->{inventory}[$slot];
      if ($tool) {
        if ( $tool->{dangerous} ) {
          print $player->{name}
            . " HAS BEEN INJURED BY THE "
            . $tool->{name}
            . ". HIS/HER\n";
          print "TOOL PROFICIENCY WILL NOW BE CUT IN HALF.\n";
          $player->{tool_proficiency}
            = int( $player->{tool_proficiency} / 2 + .5 );
        } elsif ( $tool->{explosive} ) {
          print $player->{name} . " HAS BEEN KILLED IN THE ACCIDENTAL\n";
          print "DISCHARGE OF SOME OF THE " . $tool->{name} . ". PLEASE\n";
          print "NOTIFY HIS/HER FRIENDS AND RELATIVES IF YOU MAKE IT BACK.\n";

          $player->{dead} = 1;

          # randomly distribute tools to other players
          foreach my $c_tool ( @{ $player->{inventory} } ) {
            my $target = int( rand($player_count) );
            next if $player->{name} eq $players[$target]{name};

            push @{ $players[$target]{inventory} }, $c_tool;
          }
        }
      }
    }
  }

  print "DO YOU WISH TO PLAY ANOTHER GAME? ";
  $again = input_choice( [ 'YES', 'NO' ],
    "YOU MUST ANSWER YES OR NO. PLEASE TRY AGAIN. " );
} while ( $again eq 'YES' );
