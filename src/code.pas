// Copyright 2025-2026 Rick Rutt

unit code;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, Menus, Grids, Types, Math,
  fpjson,
  constants, gameboard, jsonfilemanager, playerperceptrons, perceptron;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonLoadNextPlayer: TButton;
    ButtonLoadPriorPlayer: TButton;
    ButtonNextPerceptron: TButton;
    ButtonPriorPerceptron: TButton;
    ButtonReadPerceptronsFromFile: TButton;
    GameBoardDrawGrid: TDrawGrid;
    HeadLabel1: TLabel;
    HeadLabel3: TLabel;
    GameBoardStringGrid: TStringGrid;
    LabelCurrentPerceptronMessage: TLabel;
    LabelFileMessage: TLabel;
    LabelPlayerStatistics: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;

    procedure ButtonLoadNextPlayerClick(Sender: TObject);
    procedure ButtonLoadPriorPlayerClick(Sender: TObject);
    procedure ButtonNextPerceptronClick(Sender: TObject);
    procedure ButtonPriorPerceptronClick(Sender: TObject);
    procedure DisplayPerceptron(Perceptron: TPerceptron);
    procedure ButtonReadPerceptronsFromFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GameBoardDrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; {%H-}aState: TGridDrawState);
    procedure GameBoardStringGridPrepareCanvas(Sender: TObject; {%H-}aCol,
      {%H-}aRow: Integer; {%H-}aState: TGridDrawState);

  private
    TheBoard: TGameBoard;

    PlayerCount: integer;
    CurrentPlayerIndex: integer;
    CurrentPerceptrons: TPerceptronArray;
    PerceptronIndex: integer;

    TournamentPlayers: array[1..MAX_PLAYER_COUNT] of TPlayerPerceptrons;

    JsonManager: TJsonFileManager;

    procedure ClearStringGrid;
    procedure UpdatePlayerStatisticsLabel(const PlayerIndex: integer);
    function CreateEmptyPlayer(const PlayerIndex: integer): TPlayerPerceptrons;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  pi: integer;
  pp: TPlayerPerceptrons;
begin
  OpenDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  OpenDialog1.Filter := 'JSON files (*.json)|*.json|All Files (*.*)|*.*';

  SaveDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  SaveDialog1.Filter := 'JSON files (*.json)|*.json|All Files (*.*)|*.*';

  LabelCurrentPerceptronMessage.Caption := '';
  LabelPlayerStatistics.Caption := '';
  LabelFileMessage.Caption := '';

  TheBoard := TGameBoard.Create;

  for pi := 1 to MAX_PLAYER_COUNT do begin
    pp := CreateEmptyPlayer(pi);
    TournamentPlayers[pi] := pp;
  end;
  PlayerCount := MAX_PLAYER_COUNT;

  CurrentPlayerIndex := 1;
  UpdatePlayerStatisticsLabel(CurrentPlayerIndex);
  CurrentPerceptrons := TournamentPlayers[CurrentPlayerIndex].Perceptrons;
  PerceptronIndex := Low(CurrentPerceptrons);
  DisplayPerceptron(CurrentPerceptrons[PerceptronIndex]);

  JsonManager := TJsonFileManager.Create;
end;

function TForm1.CreateEmptyPlayer(const PlayerIndex: integer): TPlayerPerceptrons;
var
  pp: TPlayerPerceptrons;
  perceptrons: TPerceptronArray;
  p: TPerceptron;
  i: integer;
begin
  pp := TPlayerPerceptrons.Create;
  pp.PlayerName := Format(PLAYER_NAME_FORMAT, [PlayerIndex]);
  pp.PenteWins := 0;
  pp.CaptureWins := 0;
  pp.PenteLosses := 0;
  pp.CaptureLosses := 0;
  SetLength(pp.Perceptrons, PERCEPTRON_COUNT);
  perceptrons := pp.Perceptrons;
  for i := Low(perceptrons) to High(perceptrons) do begin
    p := TPerceptron.Create;
    p.RandomizePatternsAndWeight;
    perceptrons[i] := p;
  end;

  result := pp;
end;

procedure TForm1.UpdatePlayerStatisticsLabel(const PlayerIndex: integer);
begin
  LabelPlayerStatistics.Caption :=
    Format('%s: %d Pente Wins, %d Capture Wins, %d Pente Losses, %d Capture Losses',
    [TournamentPlayers[PlayerIndex].PlayerName,
     TournamentPlayers[PlayerIndex].PenteWins, TournamentPlayers[PlayerIndex].CaptureWins,
     TournamentPlayers[PlayerIndex].PenteLosses, TournamentPlayers[PlayerIndex].CaptureLosses]);
  LabelPlayerStatistics.Repaint;

  {$IFDEF LINUX}
  Application.ProcessMessages;
  {$ELSE}
  TThread.Yield;
  {$ENDIF}
end;

procedure TForm1.DisplayPerceptron(Perceptron: TPerceptron);
var
  col: integer;
  row: integer;
  cell: PatternMatchCell;
begin
  LabelCurrentPerceptronMessage.Caption :=
    Format('%s Perceptron # %d: Weight = %g',
      [TournamentPlayers[CurrentPlayerIndex].PlayerName, PerceptronIndex, Perceptron.Weight]);
  TheBoard.LoadPerceptron(CurrentPerceptrons[PerceptronIndex]);
  GameBoardDrawGrid.Repaint;

  for col := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
    for row := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
      cell := Perceptron.MatchCells[col, row];
      if (cell = DoNotCare) then begin
        GameBoardStringGrid.Cells[col, row] := '';
      end else begin
        GameBoardStringGrid.Cells[col, row] :=
          FloatToStrF(Perceptron.MatchWeights[col, row], ffFixed, 10, 4);
      end;
    end;
  end;
end;

procedure TForm1.ButtonLoadNextPlayerClick(Sender: TObject);
begin
  Inc(CurrentPlayerIndex);
  if (CurrentPlayerIndex > PlayerCount) then begin
    CurrentPlayerIndex := Low(TournamentPlayers);
  end;

  UpdatePlayerStatisticsLabel(CurrentPlayerIndex);
  CurrentPerceptrons := TournamentPlayers[CurrentPlayerIndex].Perceptrons;
  PerceptronIndex := Low(CurrentPerceptrons);
  DisplayPerceptron(CurrentPerceptrons[PerceptronIndex]);
end;

procedure TForm1.ButtonLoadPriorPlayerClick(Sender: TObject);
begin
  Dec(CurrentPlayerIndex);
  if (CurrentPlayerIndex < Low(TournamentPlayers)) then begin
    CurrentPlayerIndex := Max(PlayerCount, 1);
  end;

  UpdatePlayerStatisticsLabel(CurrentPlayerIndex);
  CurrentPerceptrons := TournamentPlayers[CurrentPlayerIndex].Perceptrons;
  PerceptronIndex := Low(CurrentPerceptrons);
  DisplayPerceptron(CurrentPerceptrons[PerceptronIndex]);
end;

procedure TForm1.ButtonNextPerceptronClick(Sender: TObject);
begin
  inc(PerceptronIndex);
  if (PerceptronIndex > High(CurrentPerceptrons)) then begin
    PerceptronIndex := Low(CurrentPerceptrons);
  end;
  DisplayPerceptron(CurrentPerceptrons[PerceptronIndex]);
end;

procedure TForm1.ButtonPriorPerceptronClick(Sender: TObject);
begin
  dec(PerceptronIndex);
  if (PerceptronIndex < Low(CurrentPerceptrons)) then begin
    PerceptronIndex := High(CurrentPerceptrons);
  end;
  DisplayPerceptron(CurrentPerceptrons[PerceptronIndex]);
end;

procedure TForm1.ClearStringGrid;
var
  col: integer;
  row: integer;
begin
  for col := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
    for row := MIN_PATTERN_INDEX to MAX_PATTERN_INDEX do begin
      GameBoardStringGrid.Cells[col, row] := '';
    end;
  end;
end;

procedure TForm1.GameBoardDrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  theCanvas: TCanvas;
  cell: PatternMatchCell;
  selfColor: TColor;
  opponentColor: TColor;
begin
  theCanvas := TDrawGrid(Sender).Canvas;

  selfColor := clWhite;
  opponentColor := clBlack;

  cell := TheBoard.Cells[aCol, aRow];

  if (cell = DoNotCare) then begin
    theCanvas.Brush.Color := clGray;
    theCanvas.FillRect(aRect);
  end else if (cell = MatchEmpty) then begin
    theCanvas.Brush.Color := clOlive;
    theCanvas.FillRect(aRect);
  end else if (cell = MatchSelf) then begin
    theCanvas.Brush.Color := selfColor;
    theCanvas.Ellipse(aRect);
  end else if (cell = MatchOpponent) then begin
    theCanvas.Brush.Color := opponentColor;
    theCanvas.Ellipse(aRect);
  end;
end;

procedure TForm1.GameBoardStringGridPrepareCanvas(Sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
var
  ts: TTextStyle;
begin
  ts := TStringGrid(Sender).Canvas.TextStyle;
  ts.Alignment := taCenter;
  TStringGrid(Sender).Canvas.TextStyle := ts;
end;

procedure TForm1.ButtonReadPerceptronsFromFileClick(Sender: TObject);
var
  filename: string;
  jsonObj: TJSONObject;
  jsonPlayer: TJSONObject;
  pi: integer;
  perceptrons: TPerceptronArray;
  pp: TPlayerPerceptrons;
  playerName: string;
begin
  if (OpenDialog1.Execute) then begin
    filename := OpenDialog1.Filename;
    if (not fileExists(filename)) then begin
      LabelFileMessage.Caption := 'File not found: ' + filename;
    end else begin
      jsonObj := JsonManager.ReadJsonFromFile(filename);

      PlayerCount := 0;
      for pi := 1 to MAX_PLAYER_COUNT do begin
        playerName := Format(PLAYER_NAME_FORMAT, [pi]);
        jsonPlayer := jsonManager.ParseJsonPlayer(jsonObj, playerName);

        if (jsonPlayer = nil) then begin
          break; // out of for loop
        end else begin
          Inc(PlayerCount);
          pp := TournamentPlayers[pi];
          JsonManager.ParsePlayerWinsAndLosses(jsonPlayer, pp);
          perceptrons := pp.Perceptrons;
          JsonManager.ParseJsonPerceptrons(jsonPlayer, perceptrons);
        end;
      end;

      CurrentPlayerIndex := 1;
      UpdatePlayerStatisticsLabel(CurrentPlayerIndex);
      CurrentPerceptrons := TournamentPlayers[CurrentPlayerIndex].Perceptrons;
      PerceptronIndex := Low(CurrentPerceptrons);
      DisplayPerceptron(CurrentPerceptrons[PerceptronIndex]);

      LabelFileMessage.Caption := 'Perceptrons read from file ' + filename;
    end;
  end else begin
    LabelFileMessage.Caption := '(File read operation cancelled.)';
  end;
end;

end.
