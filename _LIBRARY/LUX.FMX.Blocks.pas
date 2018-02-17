unit LUX.FMX.Blocks;

interface //#################################################################### ■

uses System.Classes, System.Math.Vectors,
     FMX.Types3D, FMX.Controls3D, FMX.MaterialSources,
     LUX, LUX.D3;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TVert

     TVert = record
       Pos :TPoint3D;
       Nor :TPoint3D;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TQuad

     TQuad = record
       N  :TShortint3D;
       P1 :TByte3D;
       P2 :TByte3D;
       P3 :TByte3D;
       P4 :TByte3D;
     end;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TBlocks

     TBlocks = class( TControl3D )
     private
       procedure MakeBrics;
     protected
       _Geometry :TMeshData;
       _Material :TMaterialSource;
       _Brics    :TArray3<Boolean>;
       _BricsX   :Integer;
       _BricsY   :Integer;
       _BricsZ   :Integer;
       ///// アクセス
       function GetBrics( const X_,Y_,Z_:Integer ) :Boolean;
       procedure SetBrics( const X_,Y_,Z_:Integer; const Bric_:Boolean );
       function GetBricsX :Integer;
       procedure SetBricsX( const BricsX_:Integer );
       function GetBricsY :Integer;
       procedure SetBricsY( const BricsY_:Integer );
       function GetBricsZ :Integer;
       procedure SetBricsZ( const BricsZ_:Integer );
       ///// メソッド
       procedure Render; override;
     public
       constructor Create( AOwner_:TComponent ); override;
       destructor Destroy; override;
       ///// プロパティ
       property Material                        :TMaterialSource read   _Material write   _Material;
       property Brics[ const X_,Y_,Z_:Integer ] :Boolean         read GetBrics    write SetBrics   ;
       property BricsX                          :Integer         read GetBricsX   write SetBricsX  ;
       property BricsY                          :Integer         read GetBricsY   write SetBricsY  ;
       property BricsZ                          :Integer         read GetBricsZ   write SetBricsZ  ;
       ///// メソッド
       procedure EndUpdate; override;
       procedure MakeModel;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.SysUtils, System.RTLConsts;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TBlocks

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

procedure TBlocks.MakeBrics;
begin
     SetLength( _Brics, _BricsZ, _BricsY, _BricsX );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TBlocks.GetBrics( const X_,Y_,Z_:Integer ) :Boolean;
begin
     if ( 0 <= Z_ ) and ( Z_ < _BricsZ ) and
        ( 0 <= Y_ ) and ( Y_ < _BricsY ) and
        ( 0 <= X_ ) and ( X_ < _BricsX ) then Result := _Brics[ Z_, Y_, X_ ]
                                         else Result := False;
end;

procedure TBlocks.SetBrics( const X_,Y_,Z_:Integer; const Bric_:Boolean );
begin
     _Brics[ Z_, Y_, X_ ] := Bric_;

     if FUpdating = 0 then MakeModel;
end;

//------------------------------------------------------------------------------

function TBlocks.GetBricsX :Integer;
begin
     Result := _BricsX;
end;

procedure TBlocks.SetBricsX( const BricsX_:Integer );
begin
     _BricsX := BricsX_;  MakeBrics;
end;

function TBlocks.GetBricsY :Integer;
begin
     Result := _BricsY;
end;

procedure TBlocks.SetBricsY( const BricsY_:Integer );
begin
     _BricsY := BricsY_;  MakeBrics;
end;

function TBlocks.GetBricsZ :Integer;
begin
     Result := _BricsZ;
end;

procedure TBlocks.SetBricsZ( const BricsZ_:Integer );
begin
     _BricsZ := BricsZ_;  MakeBrics;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TBlocks.Render;
begin
     Context.SetMatrix( TMatrix3D.CreateTranslation( TPoint3D.Create( -_BricsX / 2,
                                                                      -_BricsY / 2,
                                                                      -_BricsZ / 2 ) )
                      * TMatrix3D.CreateScaling( TPoint3D.Create( Width  / _BricsX,
                                                                  Height / _BricsY,
                                                                  Depth  / _BricsZ ) )
                      * AbsoluteMatrix );

     Context.DrawTriangles( _Geometry.VertexBuffer,
                            _Geometry.IndexBuffer,
                            TMaterialSource.ValidMaterial( _Material ),
                            AbsoluteOpacity );
end;

//------------------------------------------------------------------------------

procedure TBlocks.MakeModel;
const
     Quads :array [ 1..6 ] of TQuad = (
          ( N:( X:-1; Y: 0; Z: 0 ); P1:( X:0; Y:0; Z:0 ); P2:( X:0; Y:1; Z:0 ); P3:( X:0; Y:1; Z:1 ); P4:( X:0; Y:0; Z:1 ) ),
          ( N:( X: 0; Y:-1; Z: 0 ); P1:( X:0; Y:0; Z:0 ); P2:( X:0; Y:0; Z:1 ); P3:( X:1; Y:0; Z:1 ); P4:( X:1; Y:0; Z:0 ) ),
          ( N:( X: 0; Y: 0; Z:-1 ); P1:( X:0; Y:0; Z:0 ); P2:( X:1; Y:0; Z:0 ); P3:( X:1; Y:1; Z:0 ); P4:( X:0; Y:1; Z:0 ) ),
          ( N:( X:+1; Y: 0; Z: 0 ); P1:( X:1; Y:1; Z:1 ); P2:( X:1; Y:1; Z:0 ); P3:( X:1; Y:0; Z:0 ); P4:( X:1; Y:0; Z:1 ) ),
          ( N:( X: 0; Y:+1; Z: 0 ); P1:( X:1; Y:1; Z:1 ); P2:( X:0; Y:1; Z:1 ); P3:( X:0; Y:1; Z:0 ); P4:( X:1; Y:1; Z:0 ) ),
          ( N:( X: 0; Y: 0; Z:+1 ); P1:( X:1; Y:1; Z:1 ); P2:( X:1; Y:0; Z:1 ); P3:( X:0; Y:0; Z:1 ); P4:( X:0; Y:1; Z:1 ) ) );
          //      |/       |/
          //     011------111--
          //     /|       /|
          //   |/ |     |/ |
          //  010------110--
          //   |  |/    |  |/
          //   | 001----|-101--
          //   | /      | /
          //   |/       |/
          //  000------100--
var
   Vs :TArray<TVert>;
   X, Y, Z :Integer;
//······································
     procedure AddVert( const P_:TByte3D; const N_:TShortint3D );
     var
        V :TVert;
     begin
          V.Pos := TPoint3D.Create( X+P_.X, Y+P_.Y, Z+P_.Z );
          V.Nor := TPoint3D.Create(   N_.X,   N_.Y,   N_.Z );

          Vs := Vs + [ V ];
     end;
//······································
var
   VsN, QsN, N, I, J, I00, I01, I10, I11 :Integer;
begin
     Vs := [];

     //         +----+
     //        /| +-/|-+
     //       +----+ |/|
     //    +--|-+--|-+----+
     //   /|  |/|  |/| + /|
     //  +----+----+----+ |
     //  | +-/|-+-/|-+--|-+
     //  |/ +----+ |/|  |/
     //  +--|-+--|-+----+
     //     |/| +|/|-+
     //     +----+ |/
     //       +----+

     for Z := 0 to _BricsZ-1 do
     for Y := 0 to _BricsY-1 do
     for X := 0 to _BricsX-1 do
     begin
          if Brics[ X, Y ,Z ] then
          begin
               for N := 1 to 6 do
               begin
                    with Quads[ N ] do
                    begin
                         if not Brics[ X+N.X, Y+N.Y, Z+N.Z ] then
                         begin
                              AddVert( P1, N );
                              AddVert( P2, N );
                              AddVert( P3, N );
                              AddVert( P4, N );
                         end;
                    end;
               end;
          end;
     end;

     VsN := Length( Vs );
     QsN := VsN{Vert} div 4{Vert/Quad};

     with _Geometry do
     begin
          with VertexBuffer do
          begin
               Length := VsN{Vert};

               for I := 0 to VsN-1 do
               begin
                    with Vs[ I ] do
                    begin
                         Vertices[ I ] := Pos;
                         Normals [ I ] := Nor;
                    end;
               end;
          end;

          with IndexBuffer do
          begin
               Length := QsN{Quad} * 2{Tria/Quad} * 3{Poin/Tria};

               I := 0;  J := 0;
               for N := 1 to QsN do
               begin
                    //  10--11
                    //   | /|
                    //   |/ |
                    //  00--01

                    I00 := I;  Inc( I );
                    I01 := I;  Inc( I );
                    I11 := I;  Inc( I );
                    I10 := I;  Inc( I );

                    Indices[ J ] := I00;  Inc( J );
                    Indices[ J ] := I01;  Inc( J );
                    Indices[ J ] := I11;  Inc( J );

                    Indices[ J ] := I11;  Inc( J );
                    Indices[ J ] := I10;  Inc( J );
                    Indices[ J ] := I00;  Inc( J );
               end;
          end;
     end;

     Repaint;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TBlocks.Create( AOwner_:TComponent );
begin
     inherited;

     _Geometry := TMeshData.Create;
     _Material := nil;

     _BricsX := 10;
     _BricsY := 10;
     _BricsZ := 10;

     MakeBrics;
end;

destructor TBlocks.Destroy;
begin
     _Geometry.DisposeOf;

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TBlocks.EndUpdate;
begin
     inherited;

     if FUpdating = 0 then MakeModel;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
