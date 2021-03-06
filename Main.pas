﻿unit Main;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors,
  FMX.Types3D, FMX.MaterialSources, FMX.Objects3D, FMX.Controls3D, FMX.Viewport3D,
  LUX.FMX.Blocks;

type
  TForm1 = class(TForm)
    Viewport3D1: TViewport3D;
    Dummy1: TDummy;
    Dummy2: TDummy;
    Light1: TLight;
    Camera1: TCamera;
    Grid3D1: TGrid3D;
    StrokeCube1: TStrokeCube;
    LightMaterialSource1: TLightMaterialSource;
    procedure FormCreate(Sender: TObject);
    procedure Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    { private 宣言 }
    _MouseS :TShiftState;
    _MouseP :TPointF;
  public
    { public 宣言 }
    _Blocks :TBlocks;
    ///// メソッド
    procedure MakeBlocks;
  end;

var
  Form1: TForm1;

implementation //############################################################### ■

{$R *.fmx}

uses System.Math;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

function Pãodering( const P_:TPoint3D ) :Single;
var
   X2, Y2, Z2, A :Single;
begin
     X2 := Sqr( P_.X );
     Y2 := Sqr( P_.Y );
     Z2 := Sqr( P_.Z );

     A := Abs( Sqr( ( X2 - Y2 ) / ( X2 + Y2 ) ) - 0.5 );

     Result := Sqr( Sqrt( X2 + Y2 ) - 8 - A ) + Z2 - Sqr( 2 + 3 * A );
end;

//------------------------------------------------------------------------------

procedure TForm1.MakeBlocks;
var
   X, Y, Z :Integer;
   P :TPoint3D;
begin
     with _Blocks do
     begin
          BeginUpdate;

          for Z := 0 to BricsZ-1 do
          begin
               P.Z := 24 * ( ( Z + 0.5 ) / BricsZ - 0.5 );

               for Y := 0 to BricsY-1 do
               begin
                    P.Y := 24 * ( ( Y + 0.5 ) / BricsY - 0.5 );

                    for X := 0 to BricsX-1 do
                    begin
                         P.X := 24 * ( ( X + 0.5 ) / BricsX - 0.5 );

                         Brics[ X, Y, Z ] := ( Pãodering( P ) < 0 );
                    end;
               end;
          end;

          EndUpdate;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     _Blocks := TBlocks.Create( Viewport3D1 );

     with _Blocks do
     begin
          Parent   := Viewport3D1;
          HitTest  := False;
          Material := LightMaterialSource1;
          Width    := 10;
          Height   := 10;
          Depth    := 10;
          BricsX   := 100;
          BricsY   := 100;
          BricsZ   := 100;
     end;

     MakeBlocks;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     _MouseS := Shift;
     _MouseP := TPointF.Create( X, Y );
end;

procedure TForm1.Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
   P :TPointF;
begin
     if ssLeft in _MouseS then
     begin
          P := TPointF.Create( X, Y );

          with Dummy1.RotationAngle do Y := Y + ( P.X - _MouseP.X );
          with Dummy2.RotationAngle do X := X - ( P.Y - _MouseP.Y );

          _MouseP := P;
     end;
end;

procedure TForm1.Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     Viewport3D1MouseMove( Sender, Shift, X, Y );

     _MouseS := [];
end;

end. //######################################################################### ■
