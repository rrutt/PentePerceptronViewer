program PentePerceptronViewer;

{$mode objfpc}{$H+}

uses
  Forms, Interfaces, SysUtils,
  code, jsonfilemanager, constants, gameboard, perceptron, playerperceptrons;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

