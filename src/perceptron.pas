// Copyright 2025 Rick Rutt

unit perceptron;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  constants;

type
  TPerceptron = class
  private
  public
    Weight: double;
    UsageCount: integer;

    MatchCells: array[MIN_PATTERN_INDEX..MAX_PATTERN_INDEX, MIN_PATTERN_INDEX..MAX_PATTERN_INDEX] of PatternMatchCell;
    MatchWeights: array[MIN_PATTERN_INDEX..MAX_PATTERN_INDEX, MIN_PATTERN_INDEX..MAX_PATTERN_INDEX] of single;

    Constructor Create;
    procedure ClearPatterns;
    procedure RandomizeWeights;
  end;

  TPerceptronArray = array of TPerceptron;

implementation

  Constructor TPerceptron.Create;
  begin
    ClearPatterns;
  end;

  procedure TPerceptron.ClearPatterns;
  var
    patternCol: integer;
    patternRow: integer;
  begin
    for patternCol := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
      for patternRow := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
        MatchCells[patternCol, patternRow] := DoNotCare;
        MatchWeights[patternCol, patternRow] := 0.0;
      end;
    end;

    UsageCount := 0;
  end;

  procedure TPerceptron.RandomizeWeights;
  var
    patternCol: integer;
    patternRow: integer;
    matchValue: PatternMatchCell;
  begin
    if (Random < 0.5) then begin
      Weight := +1.0;
    end else begin
      Weight := -1.0;
    end;

    for patternCol := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
      for patternRow := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
        matchValue := MatchCells[patternCol, patternRow];
        if (matchValue <> DoNotCare) then begin
          if (Random < 0.5) then begin
            MatchWeights[patternCol, patternRow] := 0.1 + Random;
          end else begin
            MatchWeights[patternCol, patternRow] := - (0.1 + Random);
          end;
        end;
      end;
    end;
  end;
end.

