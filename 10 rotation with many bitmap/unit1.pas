unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, StdCtrls,
  ExtCtrls, EpikTimer, BGRABitmap,BGRABitmapTypes, Math, LCLIntf;

  type
  Animation = record
    Life:Boolean;
    Index:Integer;
    AnimatType:Integer;
    Frame_Speed: Integer;
    Remain_Speed:Integer;
    TotalFrame: Integer;
    Actual_Frame: Integer;
    MovingSpeed:Tpoint;
    Angle:Extended;
    Position:Tpoint;
    Bitmap_: array of Integer;
  end;
  type
  Inform = record
    Previous: Float;
    TimePerFrame: Float;
    LinePerFrame: Integer;
    FramePerSec: Integer;
    ActualElapsed: Float;
    LineLeftover: Integer;
    Speed_frame:Extended;
  end;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label3: TLabel;
    PaintBox2: TPaintBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure Main_Loop();
    Function TransparentBMP_ToBuffer(filename: string): TBGRABitmap;
    Function ManualTransparentBMP_ToBuffer(filename: string; Transparent:TBGRAPixel): TBGRABitmap;
    procedure SetUpValue();
  end;

var
  Form1: TForm1;
  timer_: TEpikTimer;
  Run_:Boolean;
  Background_, bmp, bmp2: TBGRABitmap;
  Grid_:Tpoint;
  c: TBGRAPixel;
  Trect_:Trect;
  Positioning:integer;
  RotageObject: array of Animation;
  BitmapAnimation: array of TBGRABitmap;
  Information:Inform;
  TotalRotageObject, TotalBitmapAnimation:integer;

implementation

{$R *.lfm}

{ TForm1 }
Procedure TForm1.SetUpValue();
var
  i, i2:integer;
begin
  Information.Speed_frame:=0.02;
  timer_ := TEpikTimer.Create(nil);
  Run_:=False;
  TotalBitmapAnimation:=7;
  setlength(BitmapAnimation,TotalBitmapAnimation);
  c := ColorToBGRA(rgb(255,255,255));

  //Load your bitmap here
  for i:=0 to 4 do
    BitmapAnimation[i] := ManualTransparentBMP_ToBuffer('Arrow'+IntToStr(i+1)+'.png',c);
  BitmapAnimation[5] := ManualTransparentBMP_ToBuffer('Arrow.png',c);
  BitmapAnimation[6] := ManualTransparentBMP_ToBuffer('SpaceShip1.png',c);
  BitmapAnimation[7] := ManualTransparentBMP_ToBuffer('SpaceShip2.png',c);

  TotalRotageObject:=22;

  setlength(RotageObject,TotalRotageObject);
  Randomize;
  for i := 0 to 19 do  //20 object
  begin
    RotageObject[i].Life:=True;
    RotageObject[i].Index:=i;
    RotageObject[i].Actual_Frame:=0;
    RotageObject[i].AnimatType:=0;
    RotageObject[i].Frame_Speed:=3;
    RotageObject[i].Remain_Speed:=RotageObject[i].Frame_Speed;
    RotageObject[i].MovingSpeed:=Point(0,0);
    RotageObject[i].Position:=Point((i*30)+10,50);
    RotageObject[i].Angle:=0;
    RotageObject[i].TotalFrame:=5;
    setlength(RotageObject[i].Bitmap_,RotageObject[i].TotalFrame);
    for i2:=0 to RotageObject[i].TotalFrame-1 do
      RotageObject[i].Bitmap_[i2] := i2;
    //RotageObject[i].Position.x:=Random(PaintBox2.Width-(BitmapAnimation[RotageObject[i].Bitmap_[0]].Width div 2));
    //RotageObject[i].Position.y:=Random(PaintBox2.Height-BitmapAnimation[RotageObject[i].Bitmap_[0]].Height);
  end;

  RotageObject[20].Life:=True;
  RotageObject[20].Index:=1;
  RotageObject[20].Actual_Frame:=0;
  RotageObject[20].AnimatType:=1;
  RotageObject[20].Frame_Speed:=0;
  RotageObject[20].Remain_Speed:=RotageObject[20].Frame_Speed;
  RotageObject[20].MovingSpeed:=Point(0,0);
  RotageObject[20].Position:=Point(100,100);
  RotageObject[20].Angle:=0;
  RotageObject[20].TotalFrame:=1;
  setlength(RotageObject[20].Bitmap_,RotageObject[20].TotalFrame);
  for i2:=0 to RotageObject[20].TotalFrame-1 do
    RotageObject[20].Bitmap_[i2] := i2+5;

  RotageObject[21].Life:=True;
  RotageObject[21].Index:=1;
  RotageObject[21].Actual_Frame:=0;
  RotageObject[21].AnimatType:=2;
  RotageObject[21].Frame_Speed:=12;
  RotageObject[21].Remain_Speed:=RotageObject[21].Frame_Speed;
  RotageObject[21].MovingSpeed:=Point(0,0);
  RotageObject[21].Position:=Point(200,200);
  RotageObject[21].Angle:=0;
  RotageObject[21].TotalFrame:=2;
  setlength(RotageObject[21].Bitmap_,RotageObject[21].TotalFrame);
  for i2:=0 to RotageObject[21].TotalFrame-1 do
    RotageObject[21].Bitmap_[i2] := i2+6;

  //for i:=0 to Random(Round(TotalBomb/3)) do
  //  if Random(2) = 1 then begin Bomb[i].Life:=True; Bomb[i].Actual_Frame:=Random(Bomb[i].TotalFrame); end;
end;

Function TForm1.ManualTransparentBMP_ToBuffer(filename: string; Transparent:TBGRAPixel): TBGRABitmap;
var
  OriginalBMP: TBGRABitmap;
begin
  OriginalBMP := TBGRABitmap.Create(filename);
  OriginalBMP.ReplaceColor(Transparent,BGRAPixelTransparent);
  ManualTransparentBMP_ToBuffer := TBGRABitmap.Create(OriginalBMP.Width,OriginalBMP.Height);       //result
  ManualTransparentBMP_ToBuffer.PutImage(0,0,OriginalBMP,dmSet,255);
  OriginalBMP.Free;
end;

Function TForm1.TransparentBMP_ToBuffer(filename: string): TBGRABitmap;
var
  OriginalBMP: TBGRABitmap;
  //Trect_:Trect;
begin
  OriginalBMP := TBGRABitmap.Create(filename);
  OriginalBMP.ReplaceColor(OriginalBMP.GetPixel(0,0),BGRAPixelTransparent);
  TransparentBMP_ToBuffer := TBGRABitmap.Create(OriginalBMP.Width,OriginalBMP.Height);       //result
  TransparentBMP_ToBuffer.PutImage(0,0,OriginalBMP,dmSet,255);

  //Trect_.TopLeft.x:=0;
  //Trect_.TopLeft.y:=0;
  //Trect_.BottomRight.x:=round(OriginalBMP.Width/2);
  //Trect_.BottomRight.y:=round(OriginalBMP.Height/2);
  //TransparentBMP_ToBuffer.PutImagePart(0,0,OriginalBMP,IT,dmSet,255); //TransparentBMP_ToBuffer.PutImagePart(0,0,OriginalBMP,IT,dmDrawWithTransparency);
  OriginalBMP.Free;
end;

procedure TForm1.Main_Loop();
var
  i:Integer;
  Frame_:integer;
  Line_:integer;
  Line_Frame:integer;
begin
  if Not Run_ then
  begin
    Run_:=True;
    Information.Previous:=0;
    Frame_:=0;
    Line_:=0;
    timer_.Clear;
    timer_.Start;

    while Run_ do
    begin
      Line_Frame:=0;
      application.ProcessMessages; //Work one program only   Case 1.

      //Run your program here  => Finish up your brackground

      Trect_.TopLeft.x:=1;
      Trect_.TopLeft.y:=0;
      Trect_.BottomRight.x:=PaintBox2.Width;
      Trect_.BottomRight.y:=PaintBox2.Height;
      Background_.PutImagePart(0,0,Background_,Trect_,dmDrawWithTransparency);

      Positioning:=Positioning+1;
      if Positioning = (bmp2.Width) then Positioning :=0;

      Trect_.TopLeft.x:=Positioning;
      Trect_.TopLeft.y:=0;
      Trect_.BottomRight.x:=Positioning+1;
      Trect_.BottomRight.y:=bmp2.Height;
      c := ColorToBGRA(rgb(255,50,0));
      Background_.PutImagePart(PaintBox2.Width-1,0,bmp2,Trect_,dmDrawWithTransparency);

      bmp.PutImage(0,0,Background_,dmDrawWithTransparency);


      //Run your program here  => Finish up your Object
      for i:=0 to TotalRotageObject-1 do
      begin
        if (RotageObject[i].Life) then
        begin
          if (RotageObject[i].AnimatType=0) or (RotageObject[i].AnimatType=1) or (RotageObject[i].AnimatType=2) then
          bmp.PutImageAngle(RotageObject[i].Position.x,RotageObject[i].Position.y,
                            BitmapAnimation[RotageObject[i].Bitmap_[RotageObject[i].Actual_Frame]],
                            RotageObject[i].Angle,
                           (BitmapAnimation[RotageObject[i].Bitmap_[RotageObject[i].Actual_Frame]].Width / 2),
                           (BitmapAnimation[RotageObject[i].Bitmap_[RotageObject[i].Actual_Frame]].Height / 2));

          RotageObject[i].Remain_Speed:=RotageObject[i].Remain_Speed-1;

          if RotageObject[i].Remain_Speed<=0 then
          begin
            RotageObject[i].Remain_Speed:=RotageObject[i].Frame_Speed;
            RotageObject[i].Actual_Frame:=RotageObject[i].Actual_Frame+1;
            if RotageObject[i].Actual_Frame>RotageObject[i].TotalFrame-1 then
            begin
              RotageObject[i].Actual_Frame:=0;
            end;
          end;
          RotageObject[i].Angle:=RotageObject[i].Angle+1;
          if RotageObject[i].Angle>360 then RotageObject[i].Angle:=0;
        end;
      end;

      //Any text information here  => Finish up your text status
      c := ColorToBGRA(rgb(0,105,208));
      bmp.FontName := 'Times New Roman';
      bmp.FontAntialias:= true;
      bmp.FontHeight:=12;
      bmp.FontStyle:=[fsBold];
      bmp.TextOut(450,(bmp.FontFullHeight*0)+5,'Angle ='+FloatToStr(RotageObject[0].Angle),c);


      //Render here   => Finish up your rander
      bmp.Draw(PaintBox2.Canvas,0,0,True);

      //Clear your hardware here

      while ((timer_.Elapsed -Information.Previous <= Information.Speed_frame) and
             (timer_.Elapsed < 1) and (Run_)) do //and (timer_.Elapsed < 1) do
      begin
        //application.ProcessMessages; //Share CUP  Case 2

        //Detect hardware here

        Line_:=Line_+1;
        Line_Frame:=Line_Frame+1;

        //Run_:=not Run_; //For run only 1 cycle
      end;

      //Other status here
      Information.TimePerFrame:=(timer_.Elapsed -Information.Previous)*1000;
      Information.Previous:=timer_.Elapsed;
      Frame_:=Frame_+1;
      if timer_.Elapsed >= 1 then
      begin
        timer_.Stop;
        Information.ActualElapsed:=timer_.Elapsed*1000;
        Information.FramePerSec:=Frame_;
        Information.LineLeftover:=Line_;
        Information.LinePerFrame:=Line_Frame;

        Information.Previous:=0;
        Frame_:=0;
        Line_:=0;
        timer_.Clear;
        timer_.Start;
      end;

      //You can move your render to here. (!It is up to you)

    end;

    If not Run_ then  timer_.Stop;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, i2, i3 : Integer;

begin
  SetUpValue();

  Grid_.X:=26;
  Grid_.y:=15;

  if Grid_.X<0 then Grid_.X:=0;
  if Grid_.Y<0 then Grid_.Y:=0;

  Background_ := TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height, ColorToBGRA($00f0f0f0));//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp := TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height, ColorToBGRA($00CCCCCC));//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp2 := TBGRABitmap.Create(Round(PaintBox2.Width/(Grid_.X+1))+1,PaintBox2.Height, ColorToBGRA($00CCCCCC));//ColorToBGRA($00CCCCCC)//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))

  c := ColorToBGRA(rgb(190,190,190));

  i2:=Round(PaintBox2.Width/(Grid_.X+1));
  i3:=0;
  for i := 0 to Grid_.X do
  begin
    i3:=i3+i2;
    Background_.DrawPolyLineAntialias([PointF(i3,0), PointF(i3,PaintBox2.Height)],c,1);
  end;

  i2:=Round(PaintBox2.Height/(Grid_.Y+1));
  i3:=0;
  for i := 0 to Grid_.Y do
  begin
    i3:=i3+i2;
    Background_.DrawPolyLineAntialias([PointF(0,i3), PointF(PaintBox2.Width,i3)],c,1);
  end;


  Trect_.TopLeft.x:=0;
  Trect_.TopLeft.y:=0;
  Trect_.BottomRight.x:=bmp2.Width;
  Trect_.BottomRight.y:=bmp2.Height;
  bmp2.PutImagePart(0,0,Background_,Trect_,dmDrawWithTransparency);

  Positioning:=(PaintBox2.Width mod (Trect_.BottomRight.x-1));

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Main_Loop();
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Information.Speed_frame:=0.02;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Information.Speed_frame:=0.029;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Run_:=False;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Information.Speed_frame:=0.1;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Run_:=False;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  i:integer;
begin
  timer_.Free;
  Background_.Free;
  bmp.Free;
  bmp2.Free;
  for i:=0 to TotalBitmapAnimation-1 do  FreeAndNil(BitmapAnimation[i]);
end;



end.

