// Copyright 2025-2026 Rick Rutt

unit constants;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  PLAYER_NAME_FORMAT = 'Plyr %d';
  TOURNAMENT_PLAYER_COUNT = 6;

  MIN_PATTERN_INDEX = 0;
  MIDDLE_PATTERN_INDEX = 5;
  MAX_PATTERN_INDEX = 10;

  PERCEPTRON_COUNT = 100;

  NEGATIVE_INFINITY = -1e99;

  PERCEPTRONS_FILE_NAME = 'Perceptrons.json';

  PERCEPTRON_DENSITY = 3.0;

  MATCH_EMPTY_DENSITY = 0.3;
  MATCH_SELF_DENSITY = 0.3;
  MATCH_OPPONENT_DENSITY = 0.3;

  PERCEPTRON_WEIGHT_BIAS = 0.75;
  PERCEPTRON_CELL_WEIGHT_BIAS = 0.75;

type
  PatternMatchCell = (DoNotCare, MatchEmpty, MatchSelf, MatchOpponent);

implementation

end.

