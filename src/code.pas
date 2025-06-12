// Copyright 2025 Rick Rutt

unit code;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, Menus, Grids, Types,
  fpjson,
  constants, gameboard, jsonfilemanager, playerperceptrons, perceptron;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonLoadBlack: TButton;
    ButtonLoadWhite: TButton;
    ButtonNextPerceptron: TButton;
    ButtonPriorPerceptron: TButton;
    ButtonReadPerceptronsFromFile: TButton;
    GameBoardDrawGrid: TDrawGrid;
    HeadLabel1: TLabel;
    HeadLabel3: TLabel;
    GameBoardStringGrid: TStringGrid;
    LabelWhitePlayerStatistics: TLabel;
    LabelBlackPlayerStatistics: TLabel;
    LabelCurrentPerceptronMessage: TLabel;
    LabelFileMessage: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;

    procedure ButtonLoadBlackClick(Sender: TObject);
    procedure ButtonLoadWhiteClick(Sender: TObject);
    procedure ButtonNextPerceptronClick(Sender: TObject);
    procedure ButtonPriorPerceptronClick(Sender: TObject);
    procedure DisplayPerceptron(Perceptron: TPerceptron);
    procedure ButtonReadPerceptronsFromFileClick(Sender: TObject);
    procedure ButtonWritePerceptronsToFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GameBoardDrawGridMouseDown(Sender: TObject; Button: TMouseButton;
      {%H-}Shift: TShiftState; X, Y: Integer);
    procedure GameBoardDrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; {%H-}aState: TGridDrawState);
    procedure GameBoardStringGridPrepareCanvas(Sender: TObject; {%H-}aCol,
      {%H-}aRow: Integer; {%H-}aState: TGridDrawState);

  private
    TheBoard: TGameBoard;

    CurrentPlayer: PlayerPiece;
    CurrentPerceptrons: TPerceptronArray;
    PerceptronIndex: integer;

    PlayerName: array[WhitePiece..BlackPiece] of string;
    PlayerPerceptrons: array[WhitePiece..BlackPiece] of TPlayerPerceptrons;

    JsonManager: TJsonFileManager;

    procedure ClearStringGrid;
    procedure UpdatePlayerStatisticsLabels;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  p: TPerceptron;
  i: integer;
  player: PlayerPiece;
  perceptrons: TPerceptronArray;
  pp: TPlayerPerceptrons;
begin
  OpenDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  OpenDialog1.Filter := 'JSON files (*.json)|*.json|All Files (*.*)|*.*';

  SaveDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  SaveDialog1.Filter := 'JSON files (*.json)|*.json|All Files (*.*)|*.*';

  LabelCurrentPerceptronMessage.Caption := '';
  LabelWhitePlayerStatistics.Caption := '';
  LabelBlackPlayerStatistics.Caption := '';
  LabelFileMessage.Caption := '';

  ButtonNextPerceptron.Enabled := false;
  ButtonPriorPerceptron.Enabled := false;

  TheBoard := TGameBoard.Create;

  PlayerName[WhitePiece] := 'White';
  PlayerName[BlackPiece] := 'Black';

  for player := WhitePiece to BlackPiece do begin
    pp := TPlayerPerceptrons.Create;
    pp.PenteWins := 0;
    pp.CaptureWins := 0;
    pp.PenteLosses := 0;
    pp.CaptureLosses := 0;
    SetLength(pp.Perceptrons, PERCEPTRON_COUNT);
    perceptrons := pp.Perceptrons;
    for i := Low(perceptrons) to High(perceptrons) do begin
      p := TPerceptron.Create;
      p.RandomizeWeights;
      perceptrons[i] := p;
    end;
    PlayerPerceptrons[player] := pp;
  end;

  UpdatePlayerStatisticsLabels;

  JsonManager := TJsonFileManager.Create;
end;

procedure TForm1.UpdatePlayerStatisticsLabels;
begin
  LabelWhitePlayerStatistics.Caption :=
    Format('%d Wins by Pente, %d Wins by Capture, %d Losses by Pente, %d Losses by Capture',
    [PlayerPerceptrons[WhitePiece].PenteWins, PlayerPerceptrons[WhitePiece].CaptureWins,
     PlayerPerceptrons[WhitePiece].PenteLosses, PlayerPerceptrons[WhitePiece].CaptureLosses]);
  LabelWhitePlayerStatistics.Repaint;

  LabelBlackPlayerStatistics.Caption :=
    Format('%d Wins by Pente, %d Wins by Capture, %d Losses by Pente, %d Losses by Capture',
    [PlayerPerceptrons[BlackPiece].PenteWins, PlayerPerceptrons[BlackPiece].CaptureWins,
     PlayerPerceptrons[BlackPiece].PenteLosses, PlayerPerceptrons[BlackPiece].CaptureLosses]);
  LabelBlackPlayerStatistics.Repaint;

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
    Format('%s Perceptron # %d: Weight = %s',
      [PlayerName[CurrentPlayer], PerceptronIndex,
      FloatToStrF(Perceptron.Weight, ffFixed, 10,4)]);
  ButtonNextPerceptron.Enabled := true;
  ButtonPriorPerceptron.Enabled := true;
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

procedure TForm1.ButtonLoadWhiteClick(Sender: TObject);
begin
  CurrentPlayer := WhitePiece;
  CurrentPerceptrons := PlayerPerceptrons[WhitePiece].Perceptrons;
  PerceptronIndex := Low(CurrentPerceptrons);
  DisplayPerceptron(CurrentPerceptrons[PerceptronIndex]);
end;

procedure TForm1.ButtonLoadBlackClick(Sender: TObject);
begin
  CurrentPlayer := BlackPiece;
  CurrentPerceptrons := PlayerPerceptrons[BlackPiece].Perceptrons;
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

procedure TForm1.GameBoardDrawGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  col: integer;
  row: integer;
begin
  if (Button = mbLeft) then begin
    CurrentPlayer := WhitePiece;
  end else begin
    CurrentPlayer := BlackPiece;
  end;

  GameBoardDrawGrid.MouseToCell(X, Y, col, row);
  TheBoard.Cells[col, row] := DoNotCare;
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

  if (CurrentPlayer = WhitePiece) then begin
    selfColor := clWhite;
    opponentColor := clBlack;
  end else begin
      selfColor := clBlack;
      opponentColor := clWhite;
  end;

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
  player: PlayerPiece;
  perceptrons: TPerceptronArray;
  pp: TPlayerPerceptrons;
begin
  if (OpenDialog1.Execute) then begin
    filename := OpenDialog1.Filename;
    if (not fileExists(filename)) then begin
      LabelFileMessage.Caption := 'File not found: ' + filename;
    end else begin
      jsonObj := JsonManager.ReadJsonFromFile(filename);

      for player := WhitePiece to BlackPiece do begin
        pp := PlayerPerceptrons[player];

        jsonPlayer := jsonManager.ParseJsonPlayer(jsonObj, player);
        JsonManager.ParsePlayerWinsAndLosses(jsonPlayer, pp);

        perceptrons := pp.Perceptrons;
        JsonManager.ParseJsonPerceptrons(jsonPlayer, perceptrons);
      end;

      UpdatePlayerStatisticsLabels;
      LabelFileMessage.Caption := 'Perceptrons read from file ' + filename;
    end;
  end else begin
    LabelFileMessage.Caption := '(File read operation cancelled.)';
  end;
end;

procedure TForm1.ButtonWritePerceptronsToFileClick(Sender: TObject);
var
  filename: string;
  jsonText: string;
begin
  if (SaveDialog1.Execute) then begin
    filename := SaveDialog1.Filename;
    jsonText := JsonManager.GenerateJsonString(PlayerPerceptrons);
    JsonManager.WriteJsonToFile(filename, jsonText);
    LabelFileMessage.Caption := 'Perceptrons written to file ' + PERCEPTRONS_FILE_NAME;
  end else begin
    LabelFileMessage.Caption := '(File write operation cancelled.)';
  end;
end;

end.
