
{**********************************************************}
{                                                          }
{  Zlib Compression Algorithm for TinyDB                   }
{                                                          }
{**********************************************************}

unit Compress_Zlib;

{$I TinyDB.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, Dialogs,
  Db, TinyDB, ZLibUnit;

type
  TCompAlgo_Zlib = class(TCompressAlgo)
  private
    FLevel: TCompressLevel;
    FSourceSize: Integer;

    function ConvertCompLevel(Value: TCompressLevel): TCompressionLevel;

    procedure Compress(SourceStream, DestStream: TMemoryStream;
      const CompressionLevel: TCompressionLevel);
    procedure Decompress(SourceStream, DestStream: TMemoryStream);

    procedure DoCompressProgress(Sender: TObject);
    procedure DoDecompressProgress(Sender: TObject);
    procedure InternalDoEncodeProgress(Size, Pos: Integer);
    procedure InternalDoDecodeProgress(Size, Pos: Integer);
  protected
    procedure SetLevel(Value: TCompressLevel); override;
    function GetLevel: TCompressLevel; override;
  public
    constructor Create(AOwner: TObject); override;

    procedure EncodeStream(Source, Dest: TMemoryStream; DataSize: Integer); override;
    procedure DecodeStream(Source, Dest: TMemoryStream; DataSize: Integer); override;
  end;

implementation

{ TCompAlgo_Zlib }

constructor TCompAlgo_Zlib.Create(AOwner: TObject);
begin
  inherited;
  FLevel := clNormal;
end;

function TCompAlgo_Zlib.ConvertCompLevel(Value: TCompressLevel): TCompressionLevel;
begin
  case Value of
    clMaximum:              Result := clMax;
    clNormal:               Result := clDefault;
    clFast, clSuperFast:    Result := clFastest;
  else
    Result := clNone;
  end;
end;

//-----------------------------------------------------------------------------
// Compress data
//-----------------------------------------------------------------------------
procedure TCompAlgo_Zlib.Compress(SourceStream, DestStream: TMemoryStream;
  const CompressionLevel: TCompressionLevel);
var
  CompStream: TCompressionStream;
  Count: Integer;
begin
  // ���Դ���ݳ���Ϊ0
  FSourceSize := SourceStream.Size;
  if SourceStream.Size = 0 then
  begin
    DestStream.Clear;
    Exit;
  end;

  // ��DestStream��ͷ��д������ѹ��ǰ�Ĵ�С
  Count := SourceStream.Size;
  DestStream.Clear;
  DestStream.WriteBuffer(Count, SizeOf(Integer));

  // д�뾭��ѹ����������(SourceStream�б�����ԭʼ��������)
  CompStream := TCompressionStream.Create(CompressionLevel, DestStream);
  try
    CompStream.OnProgress := DoCompressProgress;
    SourceStream.SaveToStream(CompStream);
  finally
    CompStream.Free;
  end;
  DestStream.Position := 0;

  // ���ѹ����ĳ��ȷ�������
  if DestStream.Size - SizeOf(Integer) >= SourceStream.Size then
  begin
    Count := -Count;   // �ø�����ʾ����δ��ѹ��
    DestStream.Clear;
    DestStream.WriteBuffer(Count, SizeOf(Integer));
    DestStream.CopyFrom(SourceStream, 0);
  end;
end;

//-----------------------------------------------------------------------------
// Decompress data
//-----------------------------------------------------------------------------
procedure TCompAlgo_Zlib.Decompress(SourceStream, DestStream: TMemoryStream);
var
  DecompStream: TDecompressionStream;
  TempStream: TMemoryStream;
  Count: Integer;
begin
  // ���Դ���ݳ���Ϊ0
  FSourceSize := SourceStream.Size;
  if SourceStream.Size = 0 then
  begin
    DestStream.Clear;
    Exit;
  end;

  // ��δѹ��������ͷ�������ֽ���
  SourceStream.Position := 0;
  SourceStream.ReadBuffer(Count, SizeOf(Integer));

  // ������ݱ�ѹ��
  if Count >= 0 then
  begin
    // ���ݽ�ѹ
    DecompStream := TDecompressionStream.Create(SourceStream);
    try
      DecompStream.OnProgress := DoDecompressProgress;
      TempStream := TMemoryStream.Create;
      try
        TempStream.SetSize(Count);
        DecompStream.ReadBuffer(TempStream.Memory^, Count);
        DestStream.LoadFromStream(TempStream);
        DestStream.Position := 0;
      finally
        TempStream.Free;
      end;
    finally
      DecompStream.Free;
    end;
  end else
  // �������δ��ѹ��
  begin
    DestStream.Clear;
    DestStream.CopyFrom(SourceStream, SourceStream.Size - SizeOf(Integer));
  end;
end;

procedure TCompAlgo_Zlib.DoCompressProgress(Sender: TObject);
begin
  InternalDoEncodeProgress(FSourceSize, (Sender as TCompressionStream).BytesProcessed);
end;

procedure TCompAlgo_Zlib.DoDecompressProgress(Sender: TObject);
begin
  InternalDoDecodeProgress(FSourceSize, (Sender as TDecompressionStream).BytesProcessed);
end;

procedure TCompAlgo_Zlib.InternalDoEncodeProgress(Size, Pos: Integer);
begin
  if Size = 0 then
    DoEncodeProgress(0)
  else
    DoEncodeProgress(Round(Pos / Size * 100));
end;

procedure TCompAlgo_Zlib.InternalDoDecodeProgress(Size, Pos: Integer);
begin
  if Size = 0 then
    DoDecodeProgress(0)
  else
    DoDecodeProgress(Round(Pos / Size * 100));
end;

procedure TCompAlgo_Zlib.EncodeStream(Source, Dest: TMemoryStream;
  DataSize: Integer);
begin
  Compress(Source, Dest, ConvertCompLevel(FLevel));
end;

procedure TCompAlgo_Zlib.DecodeStream(Source, Dest: TMemoryStream;
  DataSize: Integer);
begin
  Decompress(Source, Dest);
end;

procedure TCompAlgo_Zlib.SetLevel(Value: TCompressLevel);
begin
  FLevel := Value;
end;

function TCompAlgo_Zlib.GetLevel: TCompressLevel;
begin
  Result := FLevel;
end;

initialization
  RegisterCompressClass(TCompAlgo_Zlib, 'ZLIB');
   
end.
