// Copyright 2025 Rick Rutt

unit constants;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  MIN_PATTERN_INDEX = 0;
  MAX_PATTERN_INDEX = 10;

  PERCEPTRON_COUNT = 100;

  NEGATIVE_INFINITY = -1e99;

  PERCEPTRONS_FILE_NAME = 'Perceptrons.json';

type
  PlayerPiece = (WhitePiece, BlackPiece);
  PatternMatchCell = (DoNotCare, MatchEmpty, MatchSelf, MatchOpponent);

implementation

end.

