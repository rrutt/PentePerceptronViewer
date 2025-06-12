// Copyright 2025 Rick Rutt

unit gameboard;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  perceptron, constants;

type
  TGameBoard = class
  private

  public
    Cells: array[MIN_PATTERN_INDEX..MAX_PATTERN_INDEX, MIN_PATTERN_INDEX..MAX_PATTERN_INDEX] of PatternMatchCell;

    Constructor Create;
    procedure ClearBoard;
    procedure LoadPerceptron(perceptron: TPerceptron);
  end;

var
  TheGameBoard: TGameBoard;

implementation
  Constructor TGameBoard.Create;
  begin
    ClearBoard;
  end;

  procedure TGameBoard.ClearBoard;
  var
    col: integer;
    row: integer;
  begin
    for col := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
      for row := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
        Cells[col, row] := DoNotCare;
      end;
    end;
  end;

  procedure TGameBoard.LoadPerceptron(Perceptron: TPerceptron);
  var
    col: integer;
    row: integer;
  begin
    for col := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
      for row := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
        Cells[col, row] := Perceptron.MatchCells[col, row];
      end;
    end;
  end;

end.

