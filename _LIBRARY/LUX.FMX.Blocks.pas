unit LUX.FMX.Blocks;

interface //#################################################################### ■

uses System.Types, System.Classes, System.Math.Vectors,
     FMX.Objects3D, FMX.Types3D, FMX.Controls3D, FMX.MaterialSources,
     LUX, LUX.D3;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     TGridPoin = record
       IsInside :Boolean;
       PoinX    :Integer;
       PoinY    :Integer;
       PoinZ    :Integer;
     end;

     TVert = record
       Pos :TPoint3D;
       Nor :TPoint3D;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TPoly

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
       procedure MakeVoxels;
     protected
       _Geometry :TMeshData;
       _Material :TMaterialSource;
       _Voxels   :TArray3<Boolean>;
       _BricX    :Integer;
       _BricY    :Integer;
       _BricZ    :Integer;
       ///// アクセス
       function GetVoxels( const X_,Y_,Z_:Integer ) :Boolean;
       procedure SetVoxels( const X_,Y_,Z_:Integer; const Voxel_:Boolean );
       function GetBricX :Integer;
       procedure SetBricX( const BricX_:Integer );
       function GetBricY :Integer;
       procedure SetBricY( const BricY_:Integer );
       function GetBricZ :Integer;
       procedure SetBricZ( const BricZ_:Integer );
       ///// メソッド
       procedure Render; override;
     public
       constructor Create( AOwner_:TComponent ); override;
       destructor Destroy; override;
       ///// プロパティ
       property Material                         :TMaterialSource read   _Material write   _Material;
       property Voxels[ const X_,Y_,Z_:Integer ] :Boolean         read GetVoxels   write SetVoxels  ;
       property BricX                            :Integer         read GetBricX    write SetBricX   ;
       property BricY                            :Integer         read GetBricY    write SetBricY   ;
       property BricZ                            :Integer         read GetBricZ    write SetBricZ   ;
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

procedure TBlocks.MakeVoxels;
begin
     SetLength( _Voxels, _BricZ, _BricY, _BricX );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TBlocks.GetVoxels( const X_,Y_,Z_:Integer ) :Boolean;
begin
     if ( 0 <= Z_ ) and ( Z_ < _BricZ ) and
        ( 0 <= Y_ ) and ( Y_ < _BricY ) and
        ( 0 <= X_ ) and ( X_ < _BricX ) then Result := _Voxels[ Z_, Y_, X_ ]
                                        else Result := False;
end;

procedure TBlocks.SetVoxels( const X_,Y_,Z_:Integer; const Voxel_:Boolean );
begin
     _Voxels[ Z_, Y_, X_ ] := Voxel_;

     if FUpdating = 0 then MakeModel;
end;

//------------------------------------------------------------------------------

function TBlocks.GetBricX :Integer;
begin
     Result := _BricX;
end;

procedure TBlocks.SetBricX( const BricX_:Integer );
begin
     _BricX := BricX_;  MakeVoxels;
end;

function TBlocks.GetBricY :Integer;
begin
     Result := _BricY;
end;

procedure TBlocks.SetBricY( const BricY_:Integer );
begin
     _BricY := BricY_;  MakeVoxels;
end;

function TBlocks.GetBricZ :Integer;
begin
     Result := _BricZ;
end;

procedure TBlocks.SetBricZ( const BricZ_:Integer );
begin
     _BricZ := BricZ_;  MakeVoxels;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TBlocks.Render;
begin
     Context.SetMatrix( TMatrix3D.CreateTranslation( TPoint3D.Create( -_BricX / 2,
                                                                      -_BricY / 2,
                                                                      -_BricZ / 2 ) )
                      * TMatrix3D.CreateScaling( TPoint3D.Create( Width  / _BricX,
                                                                  Height / _BricY,
                                                                  Depth  / _BricZ ) )
                      * AbsoluteMatrix );

     Context.DrawTriangles( _Geometry.VertexBuffer,
                            _Geometry.IndexBuffer,
                            TMaterialSource.ValidMaterial( _Material ),
                            AbsoluteOpacity );
end;

//------------------------------------------------------------------------------

procedure TBlocks.MakeModel;
const
     Faces :array [ 1..6 ] of TQuad = (
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

     for Z := 0 to _BricZ-1 do
     for Y := 0 to _BricY-1 do
     for X := 0 to _BricX-1 do
     begin
          if Voxels[ X, Y ,Z ] then
          begin
               for N := 1 to 6 do
               begin
                    with Faces[ N ] do
                    begin
                         if not Voxels[ X+N.X, Y+N.Y, Z+N.Z ] then
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

     _BricX := 10;
     _BricY := 10;
     _BricZ := 10;

     MakeVoxels;
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
