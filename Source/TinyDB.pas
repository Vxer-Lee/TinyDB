
{**********************************************************}
{                                                          }
{  TinyDB Database Engine                                  }
{  Version 2.94                                            }
{                                                          }
{  Author: DayDream Software                               }
{  Email: haoxg@21cn.com                                   }
{  URL: http://www.tinydb.com                              }
{  Last Modified Date: 2005-10-31                          }
{                                                          }
{**********************************************************}

unit TinyDB;

{$I TinyDB.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,
  Dialogs, Db, {DbTables,} StdCtrls, ExtCtrls, Graphics, Math,
  {$IFDEF COMPILER_6_UP}{ QConsts,} Variants, RTLConsts, {$ENDIF}
  DbConsts, Consts, BdeConst;

const
  tdbWebsite = 'http://www.tinydb.com';         // TinyDB网站
  tdbSupportEmail = 'haoxg@21cn.com';           // TinyDB的Support Email

  tdbSoftName = 'TinyDB';
  tdbSoftVer = '2.94';                 // 数据库引擎版本号
  tdbFileFmtVer = '2.0';               // 数据库文件格式版本号
  tdbDBFileExt = '.tdb';               // 默认扩展名
  tdbMaxTable = 256;                   // 最大表数
  tdbMaxField = 96;                    // 最大字段数
  tdbMaxIndex = 8;                     // 一个表中允许定义的最多索引数
  tdbMaxFieldNameChar = 32;            // 字段名最大字符数
  tdbMaxTableNameChar = 32;            // 表名最大字符数
  tdbMaxIndexNameChar = 32;            // 索引名最大字符数
  tdbMaxAlgoNameChar = 32;             // 算法名称最大字符数
  tdbMaxCommentsChar = 256;            // 数据库注释最大字节数
  tdbMaxExtDataSize = 1024*2;          // 附加数据块的字节数
  tdbMaxHashPwdSize = 128;             // Hash后数据库密码最长字节数
  tdbRndBufferSize = 256;              // 随机填充区大小
  tdbRecTabUnitNum = 1024;             // 记录表块元素个数为多少的整数倍
  tdbIdxTabUnitNum = 1024;             // 索引表块元素个数为多少的整数倍
  tdbMaxTextFieldSize = 8192;          // Text字段的最大长度
  tdbBlobSizeUnitNum = 64;             // 不定长度(Blob)型字段存储长度为多少的整数倍
  tdbMaxMultiIndexFields = 8;          // 复合索引的最多字段数
  tdbDefaultLockRetryCount = 20;       // 等待锁定资源的重试次数缺省值
  tdbDefaultLockWaitTime = 100;        // 两次重试之间的时间间隔缺省值（毫秒）
  tdbDefAutoFlushInterval = 60*1000;   // 自动Flush的时间间隔缺省值（毫秒）

  SGeneralError = 'General error';
  SAccessDenied = 'Access denied';
  STableNotFound = 'Table ''%s'' not found';
  SBookmarkNotFound = 'Bookmark not found';
  SFieldCountMismatch = 'Field count mismatch';
  STooManyTables = 'Too many tables';
  STooManyFields = 'Too many fields';
  STooManyIndexes = 'Too many indexes';
  SDuplicateTableName = 'Duplicate table name ''%s''';
  SDuplicateIndexName = 'Duplicate index name ''%s''';
  SDuplicatePrimaryIndex = 'Duplicate primary index';
  SDuplicateAutoIncField = 'Duplicate AutoInc field';
  SInvalidDatabaseName = 'Invalid database name ''%s''';
  SInvalidTableName = 'Invalid table name ''%s''';
  SInvalidFieldName = 'Invalid field name ''%s''';
  SInvalidIndexName = 'Invalid index name ''%s''';
  SInvalidDatabase = 'Database file ''%s'' is a invalid TinyDB';
  SInvalidVersion100 = 'Version 1.00 is not compatible';
  SInvalidVersionTooHigh = 'Version of database file is too High';
  SFieldNameExpected = 'Field name expected';
  SFailToCreateIndex = 'Fail to create index';
  SInvalidUniqueFieldValue = 'Invalid unique field value ''%s''';
  SInvalidMultiIndex = 'Invalid complex index';
  SSQLInvalid = 'Invalid SQL statement: ''%s''';
  SSQLInvalidChar = 'Invalid SQL character: ''%s''';
  SCompressAlgNotFound = 'Compression algorithm module ''%s'' not found';
  SEncryptAlgNotFound = 'Encryption algorithm module ''%s'' not found';
  SDatabaseReadOnly = 'Cannot modify a read-only database';
  SNoRecords = 'No records';
  SWaitForUnlockTimeOut = 'Wait for unlock time out';

type

  PMemoryStream = ^TMemoryStream;
  PBoolean = ^Boolean;
  PWordBool = ^WordBool;
  PLargeInt = ^LargeInt;
  TIntegerAry = array of Integer;

  TTinyDBMediumType = (mtDisk, mtMemory);
  TTDIndexOption = (tiPrimary, tiUnique, tiDescending, tiCaseInsensitive);
  TTDIndexOptions = set of TTDIndexOption;
  TTDKeyIndex = (tkLookup, tkRangeStart, tkRangeEnd, tkSave);

  TCompressLevel = (clMaximum, clNormal, clFast, clSuperFast);
  TEncryptMode = (emCTS, emCBC, emCFB, emOFB, emECB);

  TFieldDataProcessMode = (fdDefault, fdOriginal);
  TFieldDPModeAry = array of TFieldDataProcessMode;

  TOnProgressEvent = procedure (Sender: TObject; Percent: Integer) of object;

  //---用于定义数据库文件格式的记录类型------------------------

  // 数据库文件头
  TFileHeader = packed record
    SoftName: array[0..6] of Char;
    FileFmtVer: array[0..4] of Char;
  end;

  // 附加数据块
  TExtData = array[0..tdbMaxExtDataSize-1] of Byte;
  TExtDataBlock = packed record
    Comments: array[0..tdbMaxCommentsChar] of Char;    // 数据库注释
    Data: TExtData;                                    // 存放用户自定义数据
  end;

  TAlgoNameString = array[0..tdbMaxAlgoNameChar] of Char;
  // 数据库选项设置
  TDBOptions = packed record
    CompressBlob: Boolean;                 // 是否压缩Blob字段（只对以后的数据库操作产生作用）
    CompressLevel: TCompressLevel;         // 压缩级别
    CompressAlgoName: TAlgoNameString;     // 压缩算法名称
    Encrypt: Boolean;                      // 数据库是否加密（决定整个数据库是否加密）
    EncryptMode: TEncryptMode;             // 加密模式
    EncryptAlgoName: TAlgoNameString;      // 加密算法名称
    CRC32: Boolean;                        // 写BLOB字段时是否进行CRC32校检     
    RandomBuffer: array[0..tdbRndBufferSize-1] of Char;  // 随机填充
    HashPassword: array[0..tdbMaxHashPwdSize] of Char;   // 经过Hash算法后的数据库访问口令
    Reserved: array[0..15] of Byte;
  end;

  // 数据库中所有表
  TTableTab = packed record
    TableCount: Integer;      // 表数目
    Reserved: Integer;
    TableHeaderOffset: array[0..tdbMaxTable-1] of Integer;   // 表头偏移
  end;

  // 字段项目
  TFieldTabItem = packed record
    FieldName: array[0..tdbMaxFieldNameChar] of Char;  // 字段名
    FieldType: TFieldType;                             // 字段类型
    FieldSize: Integer;                                // 字段大小
    DPMode: TFieldDataProcessMode;                     // 该字段的数据处理方式
    Reserved: Integer;
  end;

  // 索引头
  TIndexHeader = packed record
    IndexName: array[0..tdbMaxIndexNameChar] of Char;         // 索引名
    IndexOptions: TTDIndexOptions;                            // 索引类型
    FieldIdx: array[0..tdbMaxMultiIndexFields-1] of Integer;  // 索引字段
    IndexOffset: Integer;                                     // 索引项目表偏移
    StartIndex: Integer;                                      // 第一个索引项目的下标
    Reserved: Integer;
  end;

  TTableNameString = array[0..tdbMaxTableNameChar] of Char;
  // 表头
  TTableHeader = packed record
    // 下面四个成员不能乱动
    TableName: TTableNameString;  // 表名
    RecTabOffset: Integer;        // 记录项目表的偏移
    RecordTotal: Integer;         // 记录总数，包括有删除标记的记录
    AutoIncCounter: Integer;      // 自动增长计数器

    FieldCount: Integer;          // 字段总数
    FieldTab: array[0..tdbMaxField-1] of TFieldTabItem;     // 字段表
    IndexCount: Integer;                                    // 索引总数
    IndexHeader: array[0..tdbMaxIndex-1] of TIndexHeader;   // 索引头部信息
    Reserved: array[0..15] of Byte;
  end;

  // 记录项目
  TRecordTabItem = packed record
    DataOffset: Integer;          // 记录数据偏移
    DeleteFlag: Boolean;          // 删除标记，为True时表示删除
  end;
  TRecordTabItems = array of TRecordTabItem;
  PRecordTabItems = ^TRecordTabItems;

  // 索引项目
  TIndexTabItem = packed record
    RecIndex: Integer;            // 指向文件中RecordTable的某个元素(0-based)
    Next: Integer;                // 下一个索引项目的Index (0-based)
  end;
  TIndexTabItems = array of TIndexTabItem;

  // 不定长度字段头
  TBlobFieldHeader = packed record
    DataOffset: Integer;                 // 实际数据的偏移
    DataSize: Integer;                   // 实际数据的有效长度
    AreaSize: Integer;                   // 为Blob预留的总长度
    Reserved1: Integer;
    Reserved2: Integer;
  end;
  PBlobFieldHeader = ^TBlobFieldHeader;

  //---用于在内存中管理数据库的记录类型------------------------

  TMemRecTabItem = record
    DataOffset: Integer;      // 指向记录数据在文件中的偏移位置
    RecIndex: Integer;        // 这条记录在文件中RecordTab中的下标号(0-based)
  end;
  PMemRecTabItem = ^TMemRecTabItem;

  TMemQryRecItem = record
    DataOffsets: array of Integer;
  end;

  // TDataSet中要用到的类型

  PRecInfo = ^TRecInfo;
  TRecInfo = packed record
    Bookmark: Integer;
    BookmarkFlag: TBookmarkFlag;
  end;

  // 字段项目，CreateTable中的参数类型
  TFieldItem = record
    FieldName: string[tdbMaxFieldNameChar+1];   // 字段名
    FieldType: TFieldType;                      // 字段类型
    DataSize: Integer;                          // 字段大小
    DPMode: TFieldDataProcessMode;              // 字段数据处理方式
  end;

//-------------------------------------------------------------------

{ classes }

  TTinyAboutBox = class;
  TTinyIndexDef = class;
  TTinyIndexDefs = class;
  TTinyTableDef = class;
  TTinyTableDefs = class;
  TTinyDBFileIO = class;
  TTinyTableIO = class;
  TTDEDataSet = class;
  TTinyTable = class;
  TTinyQuery = class;
  TTinyDatabase = class;
  TTinySession = class;
  TTinySessionList = class;
  TTinyBlobStream = class;
  TExprNodes = class;
  TExprParserBase = class;

//-------------------------------------------------------------------

{ TTinyDefCollection }

  TTinyDefCollection = class(TOwnedCollection)
  private
  protected
    procedure SetItemName(AItem: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent; AClass: TCollectionItemClass);
    function Find(const AName: string): TNamedItem;
    procedure GetItemNames(List: TStrings);
    function IndexOf(const AName: string): Integer;
  end;

{ TTinyTableDef }

  TTinyTableDef = class(TNamedItem)
  private
    FTableIdx: Integer;
  protected
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property TableIdx: Integer read FTableIdx write FTableIdx;
  published
  end;

{ TTinyTableDefs }

  TTinyTableDefs = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TTinyTableDef;
  protected
  public
    constructor Create(AOwner: TPersistent);
    function IndexOf(const Name: string): Integer;
    function Find(const Name: string): TTinyTableDef;
    property Items[Index: Integer]: TTinyTableDef read GetItem; default;
  end;

{ TTinyFieldDef }

  TTinyFieldDef = class(TNamedItem)
  private
    FFieldType: TFieldType;
    FFieldSize: Integer;
    FDPMode: TFieldDataProcessMode;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    property FieldType: TFieldType read FFieldType write FFieldType;
    property FieldSize: Integer read FFieldSize write FFieldSize;
    property DPMode: TFieldDataProcessMode read FDPMode write FDPMode;
  end;

{ TTinyFieldDefs }

  TTinyFieldDefs = class(TTinyDefCollection)
  private
    function GetFieldDef(Index: Integer): TTinyFieldDef;
    procedure SetFieldDef(Index: Integer; Value: TTinyFieldDef);
  protected
    procedure SetItemName(AItem: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function AddIndexDef: TTinyFieldDef;
    function Find(const Name: string): TTinyFieldDef;
    property Items[Index: Integer]: TTinyFieldDef read GetFieldDef write SetFieldDef; default;
  end;

{ TTinyIndexDef }

  TTinyIndexDef = class(TNamedItem)
  private
    FOptions: TTDIndexOptions;
    FFieldIdxes: TIntegerAry;    // 物理字段号

    procedure SetOptions(Value: TTDIndexOptions);
  protected
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property FieldIdxes: TIntegerAry read FFieldIdxes write FFieldIdxes;
  published
    property Options: TTDIndexOptions read FOptions write SetOptions default [];
  end;

{ TTinyIndexDefs }

  TTinyIndexDefs = class(TTinyDefCollection)
  private
    function GetIndexDef(Index: Integer): TTinyIndexDef;
    procedure SetIndexDef(Index: Integer; Value: TTinyIndexDef);
  protected
    procedure SetItemName(AItem: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function AddIndexDef: TTinyIndexDef;
    function Find(const Name: string): TTinyIndexDef;
    property Items[Index: Integer]: TTinyIndexDef read GetIndexDef write SetIndexDef; default;
  end;

{ TTinyBlobStream }

  TTinyBlobStream = class(TMemoryStream)
  private
    FField: TBlobField;
    FDataSet: TTinyTable;
    FMode: TBlobStreamMode;
    FFieldNo: Integer;
    FOpened: Boolean;
    FModified: Boolean;
    procedure LoadBlobData;
    procedure SaveBlobData;
  public
    constructor Create(Field: TBlobField; Mode: TBlobStreamMode);
    destructor Destroy; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure Truncate;
  end;

{ TOptimBlobStream }

  TOptimBlobStream = class(TMemoryStream)
  private
    FDataSet: TTDEDataSet;
    FFldDataOffset: Integer;
    FShouldEncrypt: Boolean;
    FShouldCompress: Boolean;
    FDataLoaded: Boolean;

    procedure LoadBlobData;
  protected
    function Realloc(var NewCapacity: Longint): Pointer; override;
  public
    constructor Create(ADataSet: TTDEDataSet);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure SetSize(NewSize: Longint); override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure Init(FldDataOffset: Integer; ShouldEncrypt, ShouldCompress: Boolean);

    property DataLoaded: Boolean read FDataLoaded;
  end;

{ TCachedFileStream }

  TCachedFileStream = class(TStream)
  private
    FCacheStream: TMemoryStream;
  public
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    constructor Create(const FileName: string; Mode: Word);
    destructor Destroy; override;
  end;

{ TExprNode }

  TTinyOperator = (
    toNOTDEFINED, toISBLANK, toNOTBLANK,
    toEQ, toNE, toGT, toLT, toGE, toLE,
    toNOT, toAND, toOR,
    toADD, toSUB, toMUL, toDIV, toMOD,
    toLIKE, toIN, toASSIGN
    );
  TTinyFunction = (
    tfUnknown, tfUpper, tfLower, tfSubString, tfTrim, tfTrimLeft, tfTrimRight,
    tfYear, tfMonth, tfDay, tfHour, tfMinute, tfSecond, tfGetDate
    );

  TStrCompOption = (scCaseInsensitive, scNoPartialCompare);
  TStrCompOptions = set of TStrCompOption;

  TExprNodeKind = (enField, enConst, enFunc, enOperator);
  TExprToken = (
    etEnd, etSymbol, etName, etNumLiteral, etCharLiteral, etLParen, etRParen,
    etEQ, etNE, etGE, etLE, etGT, etLT, etADD, etSUB, etMUL, etDIV,
    etComma, etAsterisk, etLIKE, etISNULL, etISNOTNULL, etIN );
  TChrSet = set of Char;

  TExprNode = class(TObject)
  public
    FExprNodes: TExprNodes;
    FNext: TExprNode;
    FKind: TExprNodeKind;
    FOperator: TTinyOperator;
    FFunction: TTinyFunction;
    FSymbol: string;
    FData: PChar;
    FDataSize: Integer;
    FLeft: TExprNode;
    FRight: TExprNode;
    FDataType: TFieldType;
    FArgs: TList;
    FIsBlobField: Boolean;
    FFieldIdx: Integer;
    FBlobData: string;
    FPartialLength: Integer;

    constructor Create(ExprNodes: TExprNodes);
    destructor Destroy; override;

    procedure Calculate(Options: TStrCompOptions);
    procedure EvaluateOperator(ResultNode: TExprNode; Operator: TTinyOperator;
      LeftNode, RightNode: TExprNode; Args: TList; Options: TStrCompOptions);
    procedure EvaluateFunction(ResultNode: TExprNode; AFunction: TTinyFunction; Args: TList);

    function IsIntegerType: Boolean;
    function IsLargeIntType: Boolean;
    function IsFloatType: Boolean;
    function IsTemporalType: Boolean;
    function IsStringType: Boolean;
    function IsBooleanType: Boolean;

    function IsNumericType: Boolean;
    function IsTemporalStringType: Boolean;

    procedure SetDataSize(Size: Integer);
    function GetDataSet: TTDEDataSet;
    function AsBoolean: Boolean;
    procedure ConvertStringToDateTime;
    class function FuncNameToEnum(const FuncName: string): TTinyFunction;

    property DataSize: Integer read FDataSize write SetDataSize;

  end;

{ TExprNodes }

  TExprNodes = class(TObject)
  private
    FExprParser: TExprParserBase;
    FNodes: TExprNode;
    FRoot: TExprNode;
  public
    constructor Create(AExprParser: TExprParserBase);
    destructor Destroy; override;
    procedure Clear;
    function NewNode(NodeKind: TExprNodeKind;
                     DataType: TFieldType;
                     ADataSize: Integer;
                     Operator: TTinyOperator;
                     Left, Right: TExprNode): TExprNode;
    function NewFuncNode(const FuncName: string): TExprNode;
    function NewFieldNode(const FieldName: string): TExprNode;

    property Root: TExprNode read FRoot write FRoot;
  end;

{ TSyntaxParserBase }

  TSyntaxParserBase = class(TObject)
  protected
    FText: string;
    FTokenString: string;
    FToken: TExprToken;
    FPrevToken: TExprToken;
    FSourcePtr: PChar;
    FTokenPtr: PChar;

    procedure SetText(const Value: string);
    function IsKatakana(const Chr: Byte): Boolean;
    procedure Skip(var P: PChar; TheSet: TChrSet);
    function TokenName: string;
    function TokenSymbolIs(const S: string): Boolean;
    procedure Rewind;

    procedure GetNextToken;
    function SkipBeforeGetToken(Pos: PChar): PChar; virtual;
    function InternalGetNextToken(Pos: PChar): PChar; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;

    property Text: string read FText write SetText;
    property TokenString: string read FTokenString;
    property Token: TExprToken read FToken;
  end;

{ TExprParserBase }

  TExprParserBase = class(TSyntaxParserBase)
  protected
    FExprNodes: TExprNodes;
    FStrCompOpts: TStrCompOptions;

    function ParseExpr: TExprNode; virtual; abstract;
    function GetFieldDataType(const Name: string): TFieldType; virtual; abstract;
    function GetFieldValue(const Name: string): Variant; virtual; abstract;
    function GetFuncDataType(const Name: string): TFieldType; virtual; abstract;
    function TokenSymbolIsFunc(const S: string) : Boolean; virtual;
    procedure ParseFinished; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(const AText: string); virtual;
    function Calculate(Options: TStrCompOptions = []): Variant; virtual;
  end;

{ TFilterParser }

  TFilterParser = class(TExprParserBase)
  protected
    FDataSet: TTDEDataSet;

    function NextTokenIsLParen: Boolean;
    procedure TypeCheckArithOp(Node: TExprNode);
    procedure TypeCheckLogicOp(Node: TExprNode);
    procedure TypeCheckInOp(Node: TExprNode);
    procedure TypeCheckRelationOp(Node: TExprNode);
    procedure TypeCheckLikeOp(Node: TExprNode);
    procedure TypeCheckFunction(Node: TExprNode);
    function ParseExpr2: TExprNode;
    function ParseExpr3: TExprNode;
    function ParseExpr4: TExprNode;
    function ParseExpr5: TExprNode;
    function ParseExpr6: TExprNode;
    function ParseExpr7: TExprNode;

    function InternalGetNextToken(Pos: PChar): PChar; override;
    function ParseExpr: TExprNode; override;
    function GetFieldDataType(const Name: string): TFieldType; override;
    function GetFieldValue(const Name: string): Variant; override;
    function GetFuncDataType(const Name: string): TFieldType; override;
    function TokenSymbolIsFunc(const S: string): Boolean; override;
  public
    constructor Create(ADataSet: TTDEDataSet);
  end;

{ TSQLWhereExprParser }

  TSQLWhereExprParser = class(TFilterParser)
  protected
    function GetFieldValue(const Name: string): Variant; override;
  public
    constructor Create(ADataSet: TTDEDataSet);
  end;

{ TSQLParserBase }

  TSQLParserBase = class(TSyntaxParserBase)
  protected
    FQuery: TTinyQuery;
    FRowsAffected: Integer;

    function SkipBeforeGetToken(Pos: PChar): PChar; override;
    function InternalGetNextToken(Pos: PChar): PChar; override;
  public
    constructor Create(AQuery: TTinyQuery);
    destructor Destroy; override;

    procedure Parse(const ASQL: string); virtual;
    procedure Execute; virtual; abstract;

    property RowsAffected: Integer read FRowsAffected;
  end;

{ TSQLSelectParser }

  TNameItem = record
    RealName: string;
    AliasName: string;
  end;
  TTableNameItem = TNameItem;

  TSelectFieldItem = record
    TableName: string;
    RealFldName: string;
    AliasFldName: string;
    Index: Integer;
  end;

  TOrderByType = (obAsc, obDesc);
  TOrderByFieldItem = record
    FldName: string;
    Index: Integer;
    OrderByType: TOrderByType;
  end;

  TSQLSelectParser = class(TSQLParserBase)
  private
    FTopNum: Integer;
    FFromItems: array of TTableNameItem;
    FSelectItems: array of TSelectFieldItem;
    FWhereExprParser: TSQLWhereExprParser;
    FOrderByItems: array of TOrderByFieldItem;

    // FTableTab: TTableTab;                   // 数据库中所有表
    // FTableHeaders: array of TTableHeader;   // 表头信息

    function ParseFrom: PChar;
    function ParseSelect: PChar;
    // function ParseWhere(Pos: PChar): PChar;
    // function ParseOrderBy(Pos: PChar): PChar;
  public
    constructor Create(AQuery: TTinyQuery);
    destructor Destroy; override;
    procedure Parse(const ASQL: string); override;
    procedure Execute; override;
  end;

{ TSQLParser }

  TSQLType = (stNONE, stSELECT, stINSERT, stDELETE, stUPDATE);

  TSQLParser = class(TSQLParserBase)
  private
    FSQLType: TSQLType;
  public
    constructor Create(AQuery: TTinyQuery);
    destructor Destroy; override;

    procedure Parse(const ASQL: string); override;
    procedure Execute; override;
  end;

{ TRecordsMap }

  TRecordsMap = class(TObject)
  private
    FList: TList;
    FByIndexIdx: Integer;

    function GetCount: Integer;
    function GetItem(Index: Integer): Integer;
    procedure SetItem(Index, Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(Value: Integer);
    procedure Delete(Index: Integer);
    procedure Clear;
    procedure DoAnd(Right, Result: TRecordsMap);
    procedure DoOr(Right, Result: TRecordsMap);
    procedure DoNot(Right, Result: TRecordsMap);

    property ByIndexIdx: Integer read FByIndexIdx write FByIndexIdx;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: Integer read GetItem write SetItem;
  end;

{ TDataProcessAlgo }

  TDataProcessAlgoClass = class of TDataProcessAlgo;

  TDataProcessAlgo = class(TObject)
  private
    FOwner: TObject;
    FOnEncodeProgress: TOnProgressEvent;
    FOnDecodeProgress: TOnProgressEvent;
  protected
    procedure DoEncodeProgress(Percent: Integer);
    procedure DoDecodeProgress(Percent: Integer);
  public
    constructor Create(AOwner: TObject); virtual;
    destructor Destroy; override;

    procedure EncodeStream(Source, Dest: TMemoryStream; DataSize: Integer); virtual; abstract;
    procedure DecodeStream(Source, Dest: TMemoryStream; DataSize: Integer); virtual; abstract;

    property OnEncodeProgress: TOnProgressEvent read FOnEncodeProgress write FOnEncodeProgress;
    property OnDecodeProgress: TOnProgressEvent read FOnDecodeProgress write FOnDecodeProgress;
  end;

{ TCompressAlgo }

  TCompressAlgoClass = class of TCompressAlgo;

  TCompressAlgo = class(TDataProcessAlgo)
  protected
    procedure SetLevel(Value: TCompressLevel); virtual;
    function GetLevel: TCompressLevel; virtual;
  public
    property Level: TCompressLevel read GetLevel write SetLevel;
  end;

{ TEncryptAlgo }

  TEncryptAlgoClass = class of TEncryptAlgo;

  TEncryptAlgo = class(TDataProcessAlgo)
  protected
    procedure DoProgress(Current, Maximal: Integer; Encode: Boolean);
    procedure InternalCodeStream(Source, Dest: TMemoryStream; DataSize: Integer; Encode: Boolean);

    procedure SetMode(Value: TEncryptMode); virtual;
    function GetMode: TEncryptMode; virtual;
  public
    procedure InitKey(const Key: string); virtual; abstract;
    procedure Done; virtual;

    procedure EncodeStream(Source, Dest: TMemoryStream; DataSize: Integer); override;
    procedure DecodeStream(Source, Dest: TMemoryStream; DataSize: Integer); override;

    procedure EncodeBuffer(const Source; var Dest; DataSize: Integer); virtual; abstract;
    procedure DecodeBuffer(const Source; var Dest; DataSize: Integer); virtual; abstract;

    property Mode: TEncryptMode read GetMode write SetMode;
  end;

{ TDataProcessMgr }

  TDataProcessMgr = class(TObject)
  protected
    FTinyDBFile: TTinyDBFileIO;
    FDPObject: TDataProcessAlgo;
  public
    constructor Create(AOwner: TTinyDBFileIO);
    destructor Destroy; override;
    class function CheckAlgoRegistered(const AlgoName: string): Integer; virtual;
    procedure SetAlgoName(const Value: string); virtual; abstract;
    procedure EncodeStream(Source, Dest: TMemoryStream; DataSize: Integer); virtual;
    procedure DecodeStream(Source, Dest: TMemoryStream; DataSize: Integer); virtual;
  end;

{ TCompressMgr }

  TCompressMgr = class(TDataProcessMgr)
  private
    function GetLevel: TCompressLevel;
    procedure SetLevel(const Value: TCompressLevel);
  public
    class function CheckAlgoRegistered(const AlgoName: string): Integer; override;
    procedure SetAlgoName(const Value: string); override;
    property Level: TCompressLevel read GetLevel write SetLevel;
  end;

{ TEncryptMgr }

  TEncryptMgr = class(TDataProcessMgr)
  protected
    function GetMode: TEncryptMode;
    procedure SetMode(const Value: TEncryptMode);
  public
    procedure InitKey(const Key: string);
    procedure Done;
    class function CheckAlgoRegistered(const AlgoName: string): Integer; override;
    procedure SetAlgoName(const Value: string); override;
    procedure EncodeStream(Source, Dest: TMemoryStream; DataSize: Integer); override;
    procedure DecodeStream(Source, Dest: TMemoryStream; DataSize: Integer); override;
    procedure EncodeBuffer(const Source; var Dest; DataSize: Integer); virtual;
    procedure DecodeBuffer(const Source; var Dest; DataSize: Integer); virtual;

    property Mode: TEncryptMode read GetMode write SetMode;
  end;

{ TFieldBufferItem }

  TFieldBufferItem = class(TObject)
  private
    FBuffer: Pointer;            // 字段数据
    FFieldType: TFieldType;      // 字段类型
    FFieldSize: Integer;         // 字段数据大小（类型为字符串时：大小为Field.DataSize； 类型为BLOB时：大小为Stream.Size）
    FMemAlloc: Boolean;          // 是否分配内存
    FActive: Boolean;            // 这个字段是否有效

    function GetAsString: string;
    function GetDataBuf: Pointer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AllocBuffer;
    procedure FreeBuffer;
    function IsBlob: Boolean;

    property FieldType: TFieldType read FFieldType write FFieldType;
    property FieldSize: Integer read FFieldSize write FFieldSize;
    property Buffer: Pointer read FBuffer;
    property DataBuf: Pointer read GetDataBuf;
    property Active: Boolean read FActive write FActive;
    property AsString: string read GetAsString;
  end;

{ TFieldBuffers }

  TFieldBuffers = class(TObject)
  private
    FItems: TList;

    function GetCount: Integer;
    function GetItem(Index: Integer): TFieldBufferItem;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(FieldType: TFieldType; FieldSize: Integer); overload;
    procedure Add(Buffer: Pointer; FieldType: TFieldType; FieldSize: Integer); overload;
    procedure Delete(Index: Integer);
    procedure Clear;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TFieldBufferItem read GetItem;
  end;

{ TTinyDBFileStream }

  TTinyDBFileStream = class(TFileStream)
  private
    FFlushed: Boolean;                // 文件缓冲区内容是否写入到介质中
  public
    constructor Create(const FileName: string; Mode: Word); overload;
    {$IFDEF COMPILER_6_UP}
    constructor Create(const FileName: string; Mode: Word; Rights: Cardinal); overload;
    {$ENDIF}
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure Flush;

    property Flushed: Boolean read FFlushed write FFlushed;
  end;

{ TTinyDBFileIO }

  TTinyDBFileIO = class(TObject)
  private
    FDatabase: TTinyDatabase;
    FDatabaseName: string;             // 文件名或内存地址名
    FMediumType: TTinyDBMediumType;
    FExclusive: Boolean;
    FDBStream: TStream;
    FFileIsReadOnly: Boolean;          // 数据库文件是否为只读
    FCompressMgr: TCompressMgr;        // 压缩对象
    FEncryptMgr: TEncryptMgr;          // 加密对象
    FDBOptions: TDBOptions;            // 数据库选项
    FTableTab: TTableTab;              // 数据库中所有表
    FDPCSect: TRTLCriticalSection;     // 数据处理(加密压缩)临界区变量

    function GetIsOpen: Boolean;
    function GetFlushed: Boolean;
    procedure InitDBOptions;
    procedure InitTableTab;
    procedure DoOperationProgressEvent(ADatabase: TTinyDatabase; Pos, Max: Integer);

  protected
    procedure DecodeMemoryStream(SrcStream, DstStream: TMemoryStream; Encrypt, Compress: Boolean);
    procedure DecodeMemoryBuffer(SrcBuffer, DstBuffer: PChar; DataSize: Integer; Encrypt: Boolean);
    procedure EncodeMemoryStream(SrcStream, DstStream: TMemoryStream; Encrypt, Compress: Boolean);
    procedure EncodeMemoryBuffer(SrcBuffer, DstBuffer: PChar; DataSize: Integer; Encrypt: Boolean);

    procedure OnCompressProgressEvent(Sender: TObject; Percent: Integer);
    procedure OnUncompressProgressEvent(Sender: TObject; Percent: Integer);
    procedure OnEncryptProgressEvent(Sender: TObject; Percent: Integer);
    procedure OnDecryptProgressEvent(Sender: TObject; Percent: Integer);

    function CheckDupTableName(const TableName: string): Boolean;
    function CheckDupIndexName(var TableHeader: TTableHeader; const IndexName: string): Boolean;
    function CheckDupPrimaryIndex(var TableHeader: TTableHeader; IndexOptions: TTDIndexOptions): Boolean;
    procedure CheckValidFields(Fields: array of TFieldItem);
    procedure CheckValidIndexFields(FieldNames: array of string; IndexOptions: TTDIndexOptions; var TableHeader: TTableHeader);

    function GetFieldIdxByName(const TableHeader: TTableHeader; const FieldName: string): Integer;
    function GetIndexIdxByName(const TableHeader: TTableHeader; const IndexName: string): Integer;
    function GetTableIdxByName(const TableName: string): Integer;

    function GetTempFileName: string;
    function ReCreate(NewCompressBlob: Boolean; NewCompressLevel: TCompressLevel; const NewCompressAlgoName: string;
      NewEncrypt: Boolean; const NewEncAlgoName, OldPassword, NewPassword: string; NewCRC32: Boolean): Boolean;
  public
    constructor Create(AOwner: TTinyDatabase);
    destructor Destroy; override;

    procedure Open(const ADatabaseName: string; AMediumType: TTinyDBMediumType; AExclusive: Boolean);
    procedure Close;
    procedure Flush;
    function SetPassword(const Value: string): Boolean;

    procedure Lock;
    procedure Unlock;

    procedure ReadBuffer(var Buffer; Position, Count: Longint);
    procedure ReadDBVersion(var Dest: string);
    procedure ReadExtDataBlock(var Dest: TExtDataBlock);
    procedure WriteExtDataBlock(var Dest: TExtDataBlock);
    procedure ReadDBOptions(var Dest: TDBOptions);
    procedure WriteDBOptions(var Dest: TDBOptions);
    procedure ReadTableTab(var Dest: TTableTab);
    procedure WriteTableTab(var Dest: TTableTab);
    procedure ReadTableHeader(TableIdx: Integer; var Dest: TTableHeader);
    procedure WriteTableHeader(TableIdx: Integer; var Dest: TTableHeader);
    class function CheckValidTinyDB(ADBStream: TStream): Boolean; overload;
    class function CheckValidTinyDB(const FileName: string): Boolean; overload;
    class function CheckTinyDBVersion(ADBStream: TStream): Boolean; overload;
    class function CheckTinyDBVersion(const FileName: string): Boolean; overload;
    procedure GetTableNames(List: TStrings);
    procedure GetFieldNames(const TableName: string; List: TStrings);
    procedure GetIndexNames(const TableName: string; List: TStrings);

    procedure ReadFieldData(DstStream: TMemoryStream; RecTabItemOffset, DiskFieldOffset, FieldSize: Integer;
      IsBlob: Boolean; ShouldEncrypt, ShouldCompress: Boolean); overload;
    procedure ReadFieldData(DstStream: TMemoryStream; FieldDataOffset, FieldSize: Integer;
      IsBlob: Boolean; ShouldEncrypt, ShouldCompress: Boolean); overload;
    procedure ReadAllRecordTabItems(const TableHeader: TTableHeader;
      var Items: TRecordTabItems; var BlockOffsets: TIntegerAry);
    procedure ReadAllIndexTabItems(const TableHeader: TTableHeader; IndexIdx: Integer;
      var Items: TIndexTabItems; var BlockOffsets: TIntegerAry);
    procedure WriteDeleteFlag(RecTabItemOffset: Integer);

    function CreateDatabase(const DBFileName: string;
      CompressBlob: Boolean; CompressLevel: TCompressLevel; const CompressAlgoName: string;
      Encrypt: Boolean; const EncryptAlgoName, Password: string; CRC32: Boolean = False): Boolean; overload;
    function CreateTable(const TableName: string; Fields: array of TFieldItem): Boolean;
    function DeleteTable(const TableName: string): Boolean;
    function CreateIndex(const TableName, IndexName: string; IndexOptions: TTDIndexOptions; FieldNames: array of string): Boolean;
    function DeleteIndex(const TableName, IndexName: string): Boolean;
    function RenameTable(const OldTableName, NewTableName: string): Boolean;
    function RenameField(const TableName, OldFieldName, NewFieldName: string): Boolean;
    function RenameIndex(const TableName, OldIndexName, NewIndexName: string): Boolean;
    function Compact(const Password: string): Boolean;
    function Repair(const Password: string): Boolean;
    function ChangePassword(const OldPassword, NewPassword: string; Check: Boolean = True): Boolean;
    function ChangeEncrypt(NewEncrypt: Boolean; const NewEncAlgo, OldPassword, NewPassword: string): Boolean;
    function SetComments(const Value: string; const Password: string): Boolean;
    function GetComments(var Value: string; const Password: string): Boolean;
    function SetExtData(Buffer: PChar; Size: Integer): Boolean;
    function GetExtData(Buffer: PChar): Boolean;

    property DBStream: TStream read FDBStream;
    property DBOptions: TDBOptions read FDBOptions;
    property TableTab: TTableTab read FTableTab;
    property IsOpen: Boolean read GetIsOpen;
    property FileIsReadOnly: Boolean read FFileIsReadOnly;
    property Flushed: Boolean read GetFlushed;
  end;

{ TTinyTableIO }

  TOnAdjustIndexForAppendEvent = procedure(IndexIdx, InsertPos: Integer; MemRecTabItem: TMemRecTabItem) of object;
  TOnAdjustIndexForModifyEvent = procedure(IndexIdx, FromRecIdx, ToRecIdx: Integer) of object;

  TTinyTableIO = class(TObject)
  private
    FDatabase: TTinyDatabase;
    FRefCount: Integer;                 // 引用计数，初始为0
    FTableName: string;                 // 此表的表名
    FTableIdx: Integer;                 // 此表的表号 (0-based)
    FFieldDefs: TTinyFieldDefs;         // 字段定义（内部使用，不允许用户修改）
    FIndexDefs: TTinyIndexDefs;         // 索引定义（内部使用，不允许用户修改）
    FDiskRecSize: Integer;              // 数据库中记录数据的长度
    FDiskFieldOffsets: TIntegerAry;     // 数据库中各字段在数据行中的偏移
    FAutoIncFieldIdx: Integer;          // 自动增长字段的物理字段号(0-based)，无则为-1
    FTableHeader: TTableHeader;         // 表头信息
    FInitRecordTab: TRecordTabItems;    // 初始化时要用到的RecordTab
    FRecTabBlockOffsets: TIntegerAry;   // 每个记录表块的偏移
    FIdxTabBlockOffsets: array of TIntegerAry;  // 所有索引表块的偏移
    FRecTabLists: array of TList;       // 所有记录集（FRecTabLists[0]为物理顺序记录集，[1]为第0个索引的记录集... ）

    procedure SetActive(Value: Boolean);
    procedure SetTableName(const Value: string);

    function GetActive: Boolean;
    function GetRecTabList(Index: Integer): TList;
    function GetTableIdxByName(const TableName: string): Integer;

    procedure InitFieldDefs;
    procedure InitIndexDefs;
    procedure InitRecTabList(ListIdx: Integer; ReadRecTabItems: Boolean = True);
    procedure InitAllRecTabLists;
    procedure InitDiskRecInfo;
    procedure InitAutoInc;

    procedure ClearMemRecTab(AList: TList);
    procedure AddMemRecTabItem(AList: TList; Value: TMemRecTabItem);
    procedure InsertMemRecTabItem(AList: TList; Index: Integer; Value: TMemRecTabItem);
    procedure DeleteMemRecTabItem(AList: TList; Index: Integer);
    function GetMemRecTabItem(AList: TList; Index: Integer): TMemRecTabItem;

    function ShouldEncrypt(FieldIdx: Integer): Boolean;
    function ShouldCompress(FieldIdx: Integer): Boolean;

    function GetRecTabItemOffset(ItemIdx: Integer): Integer;
    function GetIdxTabItemOffset(IndexIdx: Integer; ItemIdx: Integer): Integer;

    procedure AdjustIndexesForAppend(FieldBuffers: TFieldBuffers; RecDataOffset, RecTotal: Integer; OnAdjustIndex: TOnAdjustIndexForAppendEvent);
    procedure AdjustIndexesForModify(FieldBuffers: TFieldBuffers; EditPhyRecordIdx: Integer; OnAdjustIndex: TOnAdjustIndexForModifyEvent);
    procedure AdjustIndexesForDelete(DeletePhyRecordIdx: Integer);
    procedure WriteDeleteFlag(PhyRecordIdx: Integer);

    procedure AdjustStrFldInBuffer(FieldBuffers: TFieldBuffers);
    procedure ClearAllRecTabLists;

  protected
    procedure Initialize;
    procedure Finalize;

  public
    constructor Create(AOwner: TTinyDatabase);
    destructor Destroy; override;

    procedure Open;
    procedure Close;
    procedure Refresh;

    procedure AppendRecordData(FieldBuffers: TFieldBuffers; Flush: Boolean;
      OnAdjustIndex: TOnAdjustIndexForAppendEvent);
    procedure ModifyRecordData(FieldBuffers: TFieldBuffers;
      PhyRecordIdx: Integer; Flush: Boolean;
      OnAdjustIndex: TOnAdjustIndexForModifyEvent);
    procedure DeleteRecordData(PhyRecordIdx: Integer; Flush: Boolean);
    procedure DeleteAllRecords;

    procedure ReadFieldData(DstStream: TMemoryStream; DiskRecIndex, FieldIdx: Integer);
    procedure ReadRecordData(FieldBuffers: TFieldBuffers; RecTabList: TList; RecordIdx: Integer);

    function CompFieldData(FieldBuffer1, FieldBuffer2: Pointer; FieldType: TFieldType;
      CaseInsensitive, PartialCompare: Boolean): Integer;

    function SearchIndexedField(FieldBuffers: TFieldBuffers; RecTabList: TList; IndexIdx: Integer; var ResultState: Integer; EffFieldCount: Integer = 0; PartialCompare: Boolean = False): Integer;
    function SearchIndexedFieldBound(FieldBuffers: TFieldBuffers; RecTabList: TList; IndexIdx: Integer; LowBound: Boolean; var ResultState: Integer; EffFieldCount: Integer = 0; PartialCompare: Boolean = False): Integer;
    function SearchRangeStart(FieldBuffers: TFieldBuffers; RecTabList: TList; IndexIdx: Integer; var ResultState: Integer; EffFieldCount: Integer = 0): Integer;
    function SearchRangeEnd(FieldBuffers: TFieldBuffers; RecTabList: TList; IndexIdx: Integer; var ResultState: Integer; EffFieldCount: Integer = 0): Integer;
    function SearchInsertPos(FieldBuffers: TFieldBuffers; IndexIdx: Integer; var ResultState: Integer): Integer;

    function CheckPrimaryFieldExists: Integer;
    function CheckUniqueFieldForAppend(FieldBuffers: TFieldBuffers): Boolean;
    function CheckUniqueFieldForModify(FieldBuffers: TFieldBuffers; PhyRecordIdx: Integer): Boolean;
    procedure ConvertRecordIdx(SrcIndexIdx, SrcRecordIdx, DstIndexIdx: Integer; var DstRecordIdx: Integer); overload;
    procedure ConvertRecordIdx(SrcRecTabList: TList; SrcRecordIdx: Integer; DstRecTabList: TList; var DstRecordIdx: Integer); overload;
    procedure ConvertRecIdxForPhy(SrcIndexIdx, SrcRecordIdx: Integer; var DstRecordIdx: Integer); overload;
    procedure ConvertRecIdxForPhy(SrcRecTabList: TList; SrcRecordIdx: Integer; var DstRecordIdx: Integer); overload;
    procedure ConvertRecIdxForCur(SrcIndexIdx, SrcRecordIdx: Integer; RecTabList: TList; var DstRecordIdx: Integer);

    property Active: Boolean read GetActive write SetActive;
    property TableName: string read FTableName write SetTableName;
    property TableIdx: Integer read FTableIdx;
    property FieldDefs: TTinyFieldDefs read FFieldDefs;
    property IndexDefs: TTinyIndexDefs read FIndexDefs;
    property RecTabLists[Index: Integer]: TList read GetRecTabList;
  end;

{ TTDBDataSet }

  TTDBDataSet = class(TDataSet)
  private
    FDatabaseName: string;        
    FDatabase: TTinyDatabase;
    FSessionName: string;
    
    procedure CheckDBSessionName;
    function GetDBSession: TTinySession;
    procedure SetSessionName(const Value: string);
  protected
    procedure SetDatabaseName(const Value: string); virtual;
    procedure Disconnect; virtual;
    procedure OpenCursor(InfoQuery: Boolean); override;
    procedure CloseCursor; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CloseDatabase(Database: TTinyDatabase);
    function OpenDatabase(IncRef: Boolean): TTinyDatabase;
    property Database: TTinyDatabase read FDatabase;
    property DBSession: TTinySession read GetDBSession;
  published
    property DatabaseName: string read FDatabaseName write SetDatabaseName;
    property SessionName: string read FSessionName write SetSessionName;
  end;

{ TTDEDataSet }

  TTDEDataSet = class(TTDBDataSet)
  private
    FAboutBox: TTinyAboutBox;
    FMediumType: TTinyDBMediumType; // 数据库存储介质类型
    FFilterParser: TExprParserBase; // Filter句法分析器
    FCurRec: Integer;               // 当前记录号 (0-based)
    FRecordSize: Integer;           // 内存中记录数据的长度
    FRecBufSize: Integer;           // FRecordSize + SizeOf(TRecInfo);
    FFieldOffsets: TIntegerAry;     // 每个字段数据在ActiveBuffer中的偏移，不包括计算字段和查找字段。数组下标意义为FieldNo-1.
    FKeyBuffers: array[TTDKeyIndex] of PChar;  // 存放Key数据，比如SetKey或SetRangeStart后
    FKeyBuffer: PChar;              // 指向FKeyBuffers中的某个元素
    FFilterBuffer: PChar;           // Filter用的Record Buffer
    FFilterMapsToIndex: Boolean;    // Filter是否可以根据Index优化
    FCanModify: Boolean;            // 是否允许修改数据库

    procedure SetMediumType(Value: TTinyDBMediumType);
    procedure SetPassword(const Value: string);
    procedure SetCRC32(Value: Boolean);
    function GetCRC32: Boolean;
    function GetCanAccess: Boolean;

    procedure InitRecordSize;
    procedure InitFieldOffsets;

    function FiltersAccept: Boolean;
    procedure SetFilterData(const Text: string; Options: TFilterOptions);
    procedure AllocKeyBuffers;
    procedure FreeKeyBuffers;
    procedure InitKeyBuffer(KeyIndex: TTDKeyIndex);
  protected
    { Overriden abstract methods (required) }
    function AllocRecordBuffer: PChar; override;
    procedure FreeRecordBuffer(var Buffer: PChar); override;
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
    function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
    function GetRecordSize: Word; override;
    procedure InternalInitRecord(Buffer: PChar); override;
    procedure InternalFirst; override;
    procedure InternalLast; override;
    procedure InternalHandleException; override;
    procedure InternalSetToRecord(Buffer: PChar); override;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
    function IsCursorOpen: Boolean; override;
    procedure DataConvert(Field: TField; Source, Dest: Pointer; ToNative: Boolean); override;

    { Additional overrides (optional) }
    function GetRecordCount: Integer; override;
    function GetRecNo: Integer; override;
    procedure SetRecNo(Value: Integer); override;
    function GetCanModify: Boolean; override;
    procedure SetFiltered(Value: Boolean); override;
    procedure SetFilterOptions(Value: TFilterOptions); override;
    procedure SetFilterText(const Value: string); override;
    procedure DoAfterOpen; override;
    function FindRecord(Restart, GoForward: Boolean): Boolean; override;

    { Virtual functions }
    function GetActiveRecBuf(var RecBuf: PChar): Boolean; virtual;
    procedure ActivateFilters; virtual;
    procedure DeactivateFilters; virtual;

    procedure ReadRecordData(Buffer: PChar; RecordIdx: Integer); virtual;

  protected
    function GetFieldOffsetByFieldNo(FieldNo: Integer): Integer;
    procedure ReadFieldData(DstStream: TMemoryStream; FieldDataOffset, FieldSize: Integer;
      IsBlob: Boolean; ShouldEncrypt, ShouldCompress: Boolean);

  public
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Password: string write SetPassword;
    property CanAccess: Boolean read GetCanAccess;
    property CRC32: Boolean read GetCRC32 write SetCRC32;
  published
    property About: TTinyAboutBox read FAboutBox write FAboutBox;
    property MediumType: TTinyDBMediumType read FMediumType write SetMediumType default mtDisk;

    property Active;
    property AutoCalcFields;
    property Filter;
    property Filtered;
    property FilterOptions;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeScroll;
    property AfterScroll;
    property BeforeRefresh;
    property AfterRefresh;
    property OnCalcFields;
    property OnFilterRecord;
  end;

{ TTinyTable }

  TTinyTable = class(TTDEDataSet)
  private
    FTableName: string;                 // 此表的表名
    FIndexDefs: TIndexDefs;             // 可让用户修改的IndexDefs
    FIndexName: string;                 // 当前激活的索引的名称
    FIndexIdx: Integer;                 // 当前激活的索引号，即在FIndexDefs中的下标
    FRecTabList: TList;                 // 当前正使用的记录集 (TMemRecTabItem)
    FUpdateCount: Integer;              // BeginUpdate调用计数
    FSetRanged: Boolean;                // 是否SetRange
    FEffFieldCount: Integer;            // 对复合索引进行查找等操作时，指定有效字段的个数，缺省为0时表示按复合索引实际字段数计
    FReadOnly: Boolean;                 // 此表是否ReadOnly
    FMasterLink: TMasterDataLink;       // 处理Master-detail
    FTableIO: TTinyTableIO;             // 指向TinyDatabase中的某个TableIO

    FOnFilterProgress: TOnProgressEvent;

    procedure SetTableName(const Value: string);
    procedure SetIndexName(const Value: string);
    procedure SetReadOnly(Value: Boolean);
    procedure SetMasterFields(const Value: string);
    procedure SetDataSource(Value: TDataSource);

    function GetTableIdx: Integer;
    function GetMasterFields: string;

    procedure InitIndexDefs;
    procedure InitCurRecordTab;

    procedure ClearMemRecTab(AList: TList);
    procedure AddMemRecTabItem(AList: TList; Value: TMemRecTabItem);
    procedure InsertMemRecTabItem(AList: TList; Index: Integer; Value: TMemRecTabItem);
    procedure DeleteMemRecTabItem(AList: TList; Index: Integer);
    function GetMemRecTabItem(AList: TList; Index: Integer): TMemRecTabItem;

    procedure SwitchToIndex(IndexIdx: Integer);

    procedure AppendRecordData(Buffer: PChar);
    procedure ModifyRecordData(Buffer: PChar; RecordIdx: Integer);
    procedure DeleteRecordData(RecordIdx: Integer);
    procedure DeleteAllRecords;

    procedure OnAdjustIndexForAppend(IndexIdx, InsertPos: Integer; MemRecTabItem: TMemRecTabItem);
    procedure OnAdjustIndexForModify(IndexIdx, FromRecIdx, ToRecIdx: Integer);

    function SearchIndexedField(RecTabList: TList; IndexIdx: Integer; var ResultState: Integer; EffFieldCount: Integer = 0; PartialCompare: Boolean = False): Integer;
    function SearchIndexedFieldBound(RecTabList: TList; IndexIdx: Integer; LowBound: Boolean; var ResultState: Integer; EffFieldCount: Integer = 0; PartialCompare: Boolean = False): Integer;
    function SearchRangeStart(RecTabList: TList; IndexIdx: Integer; var ResultState: Integer; EffFieldCount: Integer = 0): Integer;
    function SearchRangeEnd(RecTabList: TList; IndexIdx: Integer; var ResultState: Integer; EffFieldCount: Integer = 0): Integer;
    function SearchKey(RecTabList: TList; IndexIdx: Integer; EffFieldCount: Integer = 0; Nearest: Boolean = False): Boolean;
    function SearchInsertPos(IndexIdx: Integer; var ResultState: Integer): Integer;

    procedure SetKeyFields(KeyIndex: TTDKeyIndex; const Values: array of const); overload;
    procedure SetKeyFields(IndexIdx: Integer; KeyIndex: TTDKeyIndex; const Values: array of const); overload;
    procedure SetKeyBuffer(KeyIndex: TTDKeyIndex; Clear: Boolean);
    function LocateRecord(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions; SyncCursor: Boolean): Boolean;
    function MapsToIndexForSearch(Fields: TList; CaseInsensitive: Boolean): Integer;
    function CheckFilterMapsToIndex: Boolean;
    procedure MasterChanged(Sender: TObject);
    procedure MasterDisabled(Sender: TObject);
    procedure SetLinkRange(MasterFields: TList);
    procedure CheckMasterRange;
    procedure RecordBufferToFieldBuffers(RecordBuffer: PChar; FieldBuffers: TFieldBuffers);
    function FieldDefsStored: Boolean;
    function IndexDefsStored: Boolean;

  protected
    { Overriden abstract methods (required) }
    function GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    procedure InternalOpen; override;
    procedure InternalClose; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalDelete; override;
    procedure InternalPost; override;
    procedure InternalRefresh; override;
    procedure InternalGotoBookmark(Bookmark: Pointer); override;
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;
    function IsCursorOpen: Boolean; override;
    { Other overrides }
    function GetRecordCount: Integer; override;
    function GetCanModify: Boolean; override;
    function GetDataSource: TDataSource; override;
    procedure SetDatabaseName(const Value: string); override;
    procedure DoAfterOpen; override;
    procedure ActivateFilters; override;
    procedure DeactivateFilters; override;
    procedure ReadRecordData(Buffer: PChar; RecordIdx: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Post; override;
    function BookmarkValid(Bookmark: TBookmark): Boolean; override;

    procedure SetKey;
    procedure EditKey;
    function GotoKey: Boolean; overload;
    function GotoKey(const IndexName: string): Boolean; overload;
    procedure GotoNearest; overload;
    procedure GotoNearest(const IndexName: string); overload;
    function FindKey(const KeyValues: array of const): Boolean; overload;
    function FindKey(const IndexName: string; const KeyValues: array of const): Boolean; overload;
    procedure FindNearest(const KeyValues: array of const); overload;
    procedure FindNearest(const IndexName: string; const KeyValues: array of const); overload;

    procedure SetRangeStart;
    procedure SetRangeEnd;
    procedure EditRangeStart;
    procedure EditRangeEnd;
    procedure ApplyRange; overload;
    procedure ApplyRange(const IndexName: string); overload;
    procedure SetRange(const StartValues, EndValues: array of const); overload;
    procedure SetRange(const IndexName: string; const StartValues, EndValues: array of const); overload;
    procedure CancelRange;

    function Locate(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; override;
    function Lookup(const KeyFields: string; const KeyValues: Variant;
      const ResultFields: string): Variant; override;

    procedure EmptyTable;
    procedure CreateTable;

    property TableIO: TTinyTableIO read FTableIO;
    property TableIdx: Integer read GetTableIdx;
    property IndexIdx: Integer read FIndexIdx;

  published
    property TableName: string read FTableName write SetTableName;
    property IndexName: string read FIndexName write SetIndexName;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property MasterFields: string read GetMasterFields write SetMasterFields;
    property MasterSource: TDataSource read GetDataSource write SetDataSource;
    property IndexDefs: TIndexDefs read FIndexDefs write FIndexDefs stored IndexDefsStored;
    property FieldDefs stored FieldDefsStored;

    property OnFilterProgress: TOnProgressEvent read FOnFilterProgress write FOnFilterProgress;

    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property OnDeleteError;
    property OnEditError;
    property OnNewRecord;
    property OnPostError;
  end;

{ TTinyQuery }

  TTinyQuery = class(TTDEDataSet)
  private
    FSQL: TStrings;
    FSQLParser: TSQLParser;

    procedure SetQuery(Value: TStrings);
    function GetRowsAffected: Integer;

  protected
    procedure InternalOpen; override;
    procedure InternalClose; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExecSQL;
    property RowsAffected: Integer read GetRowsAffected;

  published
    property SQL: TStrings read FSQL write SetQuery;

  end;

{ TTinyDatabase }

  TTinyDatabase = class(TComponent)
  private
    FAboutBox: TTinyAboutBox;
    FDBFileIO: TTinyDBFileIO;
    FDataSets: TList;
    FKeepConnection: Boolean;
    FTemporary: Boolean;
    FHandleShared: Boolean;
    FExclusive: Boolean;
    FRefCount: Integer;
    FStreamedConnected: Boolean;
    FSession: TTinySession;
    FSessionName: string;
    FDatabaseName: string;
    FFileName: string;
    FMediumType: TTinyDBMediumType;    // 数据库存储介质类型
    FCanAccess: Boolean;               // 是否允许访问数据库
    FPassword: string;                 // 数据库密码（原文）
    FPasswordModified: Boolean;        // 密码是否被用户修改
    FTableDefs: TTinyTableDefs;        // 表定义（内部不使用）
    FTableIOs: TList;
    FFlushCacheAlways: Boolean;
    FAutoFlush: Boolean;
    FAutoFlushInterval: Integer;
    FAutoFlushTimer: TTimer;

    FBeforeConnect: TNotifyEvent;
    FBeforeDisconnect: TNotifyEvent;
    FAfterConnect: TNotifyEvent;
    FAfterDisconnect: TNotifyEvent;
    FOnCompressProgress: TOnProgressEvent;
    FOnUncompressProgress: TOnProgressEvent;
    FOnEncryptProgress: TOnProgressEvent;
    FOnDecryptProgress: TOnProgressEvent;
    FOnOperationProgress: TOnProgressEvent;

    function GetConnected: Boolean;
    function GetEncrypted: Boolean;
    function GetEncryptAlgoName: string;
    function GetCompressed: Boolean;
    function GetCompressLevel: TCompressLevel;
    function GetCompressAlgoName: string;
    function GetCRC32: Boolean;
    function GetTableIOs(Index: Integer): TTinyTableIO;
    function GetFileSize: Integer;
    function GetFileDate: TDateTime;
    function GetFileIsReadOnly: Boolean;
    procedure SetDatabaseName(const Value: string);
    procedure SetFileName(const Value: string);
    procedure SetMediumType(const Value: TTinyDBMediumType);
    procedure SetExclusive(const Value: Boolean);
    procedure SetKeepConnection(const Value: Boolean);
    procedure SetSessionName(const Value: string);
    procedure SetConnected(const Value: Boolean);
    procedure SetPassword(Value: string);
    procedure SetCRC32(Value: Boolean);
    procedure SetAutoFlush(Value: Boolean);
    procedure SetAutoFlushInterval(Value: Integer);

    function CreateLoginDialog(const ADatabaseName: string): TForm;
    function ShowLoginDialog(const ADatabaseName: string; var APassword: string): Boolean;

    function TableIOByName(const Name: string): TTinyTableIO;
    function GetDBFileName: string;
    procedure CheckSessionName(Required: Boolean);
    procedure CheckInactive;
    procedure CheckDatabaseName;
    procedure InitTableIOs;
    procedure FreeTableIOs;
    procedure AddTableIO(const TableName: string);
    procedure DeleteTableIO(const TableName: string);
    procedure RenameTableIO(const OldTableName, NewTableName: string);
    procedure RefreshAllTableIOs;
    procedure RefreshAllDataSets;
    procedure InitTableDefs;

    procedure AutoFlushTimer(Sender: TObject);
  protected
    procedure DoConnect; virtual;
    procedure DoDisconnect; virtual;
    procedure CheckCanAccess; virtual;
    function GetDataSet(Index: Integer): TTDEDataSet; virtual;
    function GetDataSetCount: Integer; virtual;
    procedure RegisterClient(Client: TObject; Event: TConnectChangeEvent = nil); virtual;
    procedure UnRegisterClient(Client: TObject); virtual;
    procedure SendConnectEvent(Connecting: Boolean);
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    
    property StreamedConnected: Boolean read FStreamedConnected write FStreamedConnected;
    property HandleShared: Boolean read FHandleShared;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    procedure CloseDataSets;
    procedure FlushCache;
    //procedure ApplyUpdates(const DataSets: array of TDBDataSet);
    //procedure StartTransaction;
    //procedure Commit;
    //procedure Rollback;
    procedure ValidateName(const Name: string);
    procedure GetTableNames(List: TStrings);
    procedure GetFieldNames(const TableName: string; List: TStrings);
    procedure GetIndexNames(const TableName: string; List: TStrings);
    function TableExists(const TableName: string): Boolean;
    class function GetCompressAlgoNames(List: TStrings): Integer;
    class function GetEncryptAlgoNames(List: TStrings): Integer;
    class function IsTinyDBFile(const FileName: string): Boolean;

    function CreateDatabase(const DBFileName: string): Boolean; overload;
    function CreateDatabase(const DBFileName: string;
      CompressBlob: Boolean; CompressLevel: TCompressLevel; const CompressAlgoName: string;
      Encrypt: Boolean; const EncryptAlgoName, Password: string; CRC32: Boolean = False): Boolean; overload;

    function CreateTable(const TableName: string; Fields: array of TFieldItem): Boolean;
    function DeleteTable(const TableName: string): Boolean;
    function CreateIndex(const TableName, IndexName: string; IndexOptions: TTDIndexOptions; FieldNames: array of string): Boolean;
    function DeleteIndex(const TableName, IndexName: string): Boolean;

    function RenameTable(const OldTableName, NewTableName: string): Boolean;
    function RenameField(const TableName, OldFieldName, NewFieldName: string): Boolean;
    function RenameIndex(const TableName, OldIndexName, NewIndexName: string): Boolean;

    function Compact: Boolean;
    function Repair: Boolean;
    function ChangePassword(const NewPassword: string; Check: Boolean = True): Boolean;
    function ChangeEncrypt(NewEncrypt: Boolean; const NewEncAlgo, NewPassword: string): Boolean;

    function SetComments(const Value: string): Boolean;
    function GetComments(var Value: string): Boolean;
    function SetExtData(Buffer: PChar; Size: Integer): Boolean;
    function GetExtData(Buffer: PChar): Boolean;

    property DBFileIO: TTinyDBFileIO read FDBFileIO;
    property TableIOs[Index: Integer]: TTinyTableIO read GetTableIOs;
    property DataSets[Index: Integer]: TTDEDataSet read GetDataSet;
    property DataSetCount: Integer read GetDataSetCount;
    property Session: TTinySession read FSession;
    property TableDefs: TTinyTableDefs read FTableDefs;
    property Temporary: Boolean read FTemporary write FTemporary;
    property Password: string read FPassword write SetPassword;
    property CanAccess: Boolean read FCanAccess;
    property Encrypted: Boolean read GetEncrypted;
    property EncryptAlgoName: string read GetEncryptAlgoName;
    property Compressed: Boolean read GetCompressed;
    property CompressLevel: TCompressLevel read GetCompressLevel;
    property CompressAlgoName: string read GetCompressAlgoName;
    property CRC32: Boolean read GetCRC32 write SetCRC32;
    property FlushCacheAlways: Boolean read FFlushCacheAlways write FFlushCacheAlways;
    property FileSize: Integer read GetFileSize;
    property FileDate: TDateTime read GetFileDate;
    property FileIsReadOnly: Boolean read GetFileIsReadOnly;
  published
    property About: TTinyAboutBox read FAboutBox write FAboutBox;
    property FileName: string read FFileName write SetFileName;
    property DatabaseName: string read FDatabaseName write SetDatabaseName;
    property MediumType: TTinyDBMediumType read FMediumType write SetMediumType default mtDisk;
    property Connected: Boolean read GetConnected write SetConnected default False;
    property Exclusive: Boolean read FExclusive write SetExclusive default False;
    property KeepConnection: Boolean read FKeepConnection write SetKeepConnection default False;
    property SessionName: string read FSessionName write SetSessionName;
    property AutoFlush: Boolean read FAutoFlush write SetAutoFlush default False;
    property AutoFlushInterval: Integer read FAutoFlushInterval write SetAutoFlushInterval default tdbDefAutoFlushInterval;

    property BeforeConnect: TNotifyEvent read FBeforeConnect write FBeforeConnect;
    property BeforeDisconnect: TNotifyEvent read FBeforeDisconnect write FBeforeDisconnect;
    property AfterConnect: TNotifyEvent read FAfterConnect write FAfterConnect;
    property AfterDisconnect: TNotifyEvent read FAfterDisconnect write FAfterDisconnect;
    property OnCompressProgress: TOnProgressEvent read FOnCompressProgress write FOnCompressProgress;
    property OnUncompressProgress: TOnProgressEvent read FOnUncompressProgress write FOnUnCompressProgress;
    property OnEncryptProgress: TOnProgressEvent read FOnEncryptProgress write FOnEncryptProgress;
    property OnDecryptProgress: TOnProgressEvent read FOnDecryptProgress write FOnDecryptProgress;
    property OnOperationProgress: TOnProgressEvent read FOnOperationProgress write FOnOperationProgress;
  end;

{ TTinySession }

  TTinyDatabaseEvent = (dbOpen, dbClose, dbAdd, dbRemove, dbAddAlias, dbDeleteAlias,
    dbAddDriver, dbDeleteDriver);

  TTinyDatabaseNotifyEvent = procedure(DBEvent: TTinyDatabaseEvent; const Param) of object;

  TTinySession = class(TComponent)
  private
    FAboutBox: TTinyAboutBox;
    FActive: Boolean;
    FDatabases: TList;
    FKeepConnections: Boolean;
    FDefault: Boolean;
    FSessionName: string;
    FSessionNumber: Integer;
    FAutoSessionName: Boolean;
    FSQLHourGlass: Boolean;
    FLockCount: Integer;
    FStreamedActive: Boolean;
    FUpdatingAutoSessionName: Boolean;
    FLockRetryCount: Integer;                   // 等待锁定资源的重试次数
    FLockWaitTime: Integer;                     // 两次重试之间的时间间隔（毫秒）
    FPasswords: TStrings;
    FOnStartup: TNotifyEvent;
    FOnDBNotify: TTinyDatabaseNotifyEvent;

    procedure CheckInactive;
    function GetActive: Boolean;
    function GetDatabase(Index: Integer): TTinyDatabase;
    function GetDatabaseCount: Integer;
    procedure SetActive(Value: Boolean);
    procedure SetAutoSessionName(Value: Boolean);
    procedure SetSessionName(const Value: string);
    procedure SetSessionNames;
    procedure SetLockRetryCount(Value: Integer);
    procedure SetLockWaitTime(Value: Integer);
    function SessionNameStored: Boolean;
    procedure ValidateAutoSession(AOwner: TComponent; AllSessions: Boolean);
    function DoFindDatabase(const DatabaseName: string; AOwner: TComponent): TTinyDatabase;
    function DoOpenDatabase(const DatabaseName: string; AOwner: TComponent;
      ADataSet: TTDBDataSet; IncRef: Boolean): TTinyDatabase;
    procedure AddDatabase(Value: TTinyDatabase);
    procedure RemoveDatabase(Value: TTinyDatabase);
    procedure DBNotification(DBEvent: TTinyDatabaseEvent; const Param);
    procedure LockSession;
    procedure UnlockSession;
    procedure StartSession(Value: Boolean);
    procedure UpdateAutoSessionName;
    function GetPasswordIndex(const Password: string): Integer;

  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetName(const NewName: TComponentName); override;
    property OnDBNotify: TTinyDatabaseNotifyEvent read FOnDBNotify write FOnDBNotify;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    function OpenDatabase(const DatabaseName: string): TTinyDatabase;
    procedure CloseDatabase(Database: TTinyDatabase);
    function FindDatabase(const DatabaseName: string): TTinyDatabase;
    procedure DropConnections;
    procedure GetDatabaseNames(List: TStrings);
    procedure GetTableNames(const DatabaseName: string; List: TStrings);
    procedure GetFieldNames(const DatabaseName, TableName: string; List: TStrings);
    procedure GetIndexNames(const DatabaseName, TableName: string; List: TStrings);

    procedure AddPassword(const Password: string);
    procedure RemovePassword(const Password: string);
    procedure RemoveAllPasswords;

    property DatabaseCount: Integer read GetDatabaseCount;
    property Databases[Index: Integer]: TTinyDatabase read GetDatabase;

  published
    property About: TTinyAboutBox read FAboutBox write FAboutBox;
    property Active: Boolean read GetActive write SetActive default False;
    property AutoSessionName: Boolean read FAutoSessionName write SetAutoSessionName default False;
    property KeepConnections: Boolean read FKeepConnections write FKeepConnections default False;
    property SessionName: string read FSessionName write SetSessionName stored SessionNameStored;
    property SQLHourGlass: Boolean read FSQLHourGlass write FSQLHourGlass default True;
    property LockRetryCount: Integer read FLockRetryCount write SetLockRetryCount default tdbDefaultLockRetryCount;
    property LockWaitTime: Integer read FLockWaitTime write SetLockWaitTime default tdbDefaultLockWaitTime;
    property OnStartup: TNotifyEvent read FOnStartup write FOnStartup;
  end;

{ TTinySessionList }

  TTinySessionList = class(TObject)
    FSessions: TThreadList;
    FSessionNumbers: TBits;
    procedure AddSession(ASession: TTinySession);
    procedure CloseAll;
    function GetCount: Integer;
    function GetSession(Index: Integer): TTinySession;
    function GetSessionByName(const SessionName: string): TTinySession;
  public
    constructor Create;
    destructor Destroy; override;
    function FindSession(const SessionName: string): TTinySession;
    procedure GetSessionNames(List: TStrings);
    function OpenSession(const SessionName: string): TTinySession;
    property Count: Integer read GetCount;
    property Sessions[Index: Integer]: TTinySession read GetSession; default;
    property List[const SessionName: string]: TTinySession read GetSessionByName;
  end;
  
{ TTinyAboutBox }

  TTinyAboutBox = class(TObject)
  end;

// Register Algorithm Routines
procedure RegisterCompressClass(AClass: TCompressAlgoClass; AlgoName: string);
procedure RegisterEncryptClass(AClass: TEncryptAlgoClass; AlgoName: string);

// Hashing & Encryption Routines
function HashMD5(const Source: string; Digest: Pointer = nil): string;
function HashSHA(const Source: string; Digest: Pointer = nil): string;
function HashSHA1(const Source: string; Digest: Pointer = nil): string;
function CheckSumCRC32(const Data; DataSize: Integer): Longword;
procedure EncryptBuffer(Buffer: PChar; DataSize: Integer;
  EncAlgo: string; EncMode: TEncryptMode; Password: string);
procedure DecryptBuffer(Buffer: PChar; DataSize: Integer;
  EncAlgo: string; EncMode: TEncryptMode; Password: string);
procedure EncryptBufferBlowfish(Buffer: PChar; DataSize: Integer; Password: string);
procedure DecryptBufferBlowfish(Buffer: PChar; DataSize: Integer; Password: string);

// Misc Routines
function FieldItem(FieldName: string; FieldType: TFieldType; DataSize: Integer = 0; DPMode: TFieldDataProcessMode = fdDefault): TFieldItem;
function PointerToStr(P: Pointer): string;

var
  Session: TTinySession;
  Sessions: TTinySessionList;

implementation

{$WRITEABLECONST ON}

uses
  Compress_Zlib,
  EncryptBase, Enc_Blowfish, Enc_Twofish, Enc_Gost,
  HashBase, Hash_MD, Hash_SHA, Hash_CheckSum;

const
  TinyDBFieldTypes = [ftAutoInc, ftString, ftFixedChar,
    ftSmallint, ftInteger, ftWord, ftLargeint, ftBoolean, ftFloat, ftCurrency,
    ftDate, ftTime, ftDateTime, ftBlob, ftMemo, ftFmtMemo, ftGraphic];

  StringFieldTypes = [ftString, ftFixedChar, ftWideString, ftGuid];
  BlobFieldTypes = [ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle, ftDBaseOle,
    ftTypedBinary, ftOraBlob, ftOraClob];

const
  // 保存已注册的压缩类
  FCompressClassList: TStringList = nil;
  // 保存已注册的加密类
  FEncryptClassList: TStringList = nil;

  // TinyDB的缺省Hash算法类
  FTinyDBDefaultHashClass: THashClass = THash_SHA;
  // Hash之后保存在数据库中的用来做密码验证的Hash算法类
  FTinyDBCheckPwdHashClass: THashClass = THash_SHA;
  // TinyDB的缺省加密算法
  FTinyDBDefaultEncAlgo = 'Blowfish';
  // TinyDB的缺省加密模式
  FTinyDBDefaultEncMode = emCTS;

var
  FSessionCSect: TRTLCriticalSection;

type

{ TTinyDBLoginForm }

  TTinyDBLoginForm = class(TForm)
  public
    constructor CreateNew(AOwner: TComponent); reintroduce;
  end;

{ Misc proc }

{$WRITEABLECONST ON}
procedure ShowNagScreen(AComponent: TComponent);
const
  FirstShow: Boolean = True;
begin
{$IFDEF TDB_SHOW_NAGSCREEN}
  if not (csDesigning in AComponent.ComponentState) then
  begin
    if FirstShow then
    begin
      MessageBox(0, PChar(
        'You use UNREGISTERED version of TinyDB.' + #13 +
        'Please register at ' + tdbWebsite + #13 +
        '(Registered users will get full source code of TinyDB!)' + #13 +
        #13 +
        'Thanks!'),
        'TinyDB Engine',
        MB_OK + MB_ICONINFORMATION);
      FirstShow := False;
    end;
  end;
{$ENDIF}
end;
{$WRITEABLECONST OFF}

procedure RegisterCompressClass(AClass: TCompressAlgoClass; AlgoName: string);
var
  I: Integer;
begin
  if FCompressClassList = nil then
    FCompressClassList := TStringList.Create;

  I := FCompressClassList.IndexOfObject(Pointer(AClass));
  if I < 0 then FCompressClassList.AddObject(AlgoName, Pointer(AClass))
  else FCompressClassList[I] := AlgoName;
end;

procedure RegisterEncryptClass(AClass: TEncryptAlgoClass; AlgoName: string);
var
  I: Integer;
begin
  if FEncryptClassList = nil then
    FEncryptClassList := TStringList.Create;

  I := FEncryptClassList.IndexOfObject(Pointer(AClass));
  if I < 0 then FEncryptClassList.AddObject(AlgoName, Pointer(AClass))
  else FEncryptClassList[I] := AlgoName;
end;

function DefaultSession: TTinySession;
begin
  Result := TinyDB.Session;
end;

function FieldItem(FieldName: string; FieldType: TFieldType; DataSize: Integer = 0; DPMode: TFieldDataProcessMode = fdDefault): TFieldItem;
begin
  Result.FieldName := FieldName;
  Result.FieldType := FieldType;
  Result.DataSize := DataSize;
  Result.DPMode := DPMode;
end;

function GetFieldSize(FieldType: TFieldType; StringLength: Integer = 0): Integer;
begin
  if not (FieldType in TinyDBFieldTypes) then
    DatabaseError(SGeneralError);

  Result := 0;
  if FieldType in StringFieldTypes then
    Result := StringLength + 1
  else if FieldType in BlobFieldTypes then
    Result := 0
  else
  begin
    case FieldType of
      ftBoolean: Result := SizeOf(WordBool);
      ftDateTime,
      ftCurrency,
      ftFloat: Result := SizeOf(Double);
      ftTime,
      ftDate,
      ftAutoInc,
      ftInteger: Result := SizeOf(Integer);
      ftSmallint: Result := SizeOf(SmallInt);
      ftWord: Result := SizeOf(Word);
      ftLargeint: Result := SizeOf(Largeint);
    else
      DatabaseError(SGeneralError);
    end;
  end;
end;

function PointerToStr(P: Pointer): string;
var
  V: Longword;
begin
  V := Longword(P);
  Result := ':' + IntToHex(V, 8);
end;

function StrToPointer(S: string): Pointer;
var
  P: Longword;
  I, J: Integer;
  C: Char;
begin
  Result := nil;
  if S[1] <> ':' then Exit;
  Delete(S, 1, 1);
  S := UpperCase(S);
  P := 0;
  for I := 1 to Length(S) do
  begin
    C := S[I];
    if (C >= '0') and (C <= '9') then J := Ord(C) - Ord('0')
    else J := Ord(C) - Ord('A') + 10;
    P := (P shl 4) + Longword(J);
  end;
  Result := Pointer(P);
end;

function IsPointerStr(S: string): Boolean;

  function IsHexChar(C: Char): Boolean;
  begin
    Result := (C >= '0') and (C <= '9') or
              (C >= 'A') and (C <= 'F') or
              (C >= 'a') and (C <= 'f');
  end;

  function IsHexStr(S: string): Boolean;
  var
    I: Integer;
  begin
    for I := 1 to Length(S) do
    begin
      if not IsHexChar(S[I]) then
      begin
        Result := False;
        Exit;
      end;
    end;
    Result := True;
  end;

begin
  Result := False;
  if S[1] <> ':' then Exit;
  Delete(S, 1, 1);
  if not IsHexStr(S) then Exit;
  Result := True;
end;

//-----------------------------------------------------------------------------
// 计算LIKE表达式，支持通配符'%' 和 '_'
// Value: 母串
// Pattern: 子串
// CaseSensitive: 区分大小写
// 例： LikeString('abcdefg', 'abc%', True);
//-----------------------------------------------------------------------------
{
function LikeString(Value, Pattern: WideString; CaseSensitive: Boolean): Boolean;
const
  MultiWildChar = '%';
  SingleWildChar = '_';

  function MatchPattern(ValueStart, PatternStart: Integer): Boolean;
  begin
    if (Pattern[PatternStart] = MultiWildChar) and (Pattern[PatternStart + 1] = #0) then
      Result := True
    else if (Value[ValueStart] = #0) and (Pattern[PatternStart] <> #0) then
      Result := False
    else if (Value[ValueStart] = #0) then
      Result := True
    else
    begin
      case Pattern[PatternStart] of
        MultiWildChar:
          begin
            if MatchPattern(ValueStart, PatternStart + 1) then
              Result := True
            else
              Result := MatchPattern(ValueStart + 1, PatternStart);
          end;
        SingleWildChar:
          Result := MatchPattern(ValueStart + 1, PatternStart + 1);
        else
          begin
            if CaseSensitive and (Value[ValueStart] = Pattern[PatternStart]) or
              not CaseSensitive and (UpperCase(Value[ValueStart]) = UpperCase(Pattern[PatternStart])) then
              Result := MatchPattern(ValueStart + 1, PatternStart + 1)
            else
              Result := False;
          end;
        end;
    end;
  end;

begin
  if Value = '' then Value := #0;
  if Pattern = '' then Pattern := #0;
  Result := MatchPattern(1, 1);
end;
}
function LikeString(Value, Pattern: WideString; CaseSensitive: Boolean): Boolean;
const
  MultiWildChar = '%';
  SingleWildChar = '_';
var
  ValuePtr, PatternPtr: PWideChar;
  I: Integer;
  B: Boolean;
begin
  ValuePtr := PWideChar(Value);
  PatternPtr := PWideChar(Pattern);

  while True do
  begin
    if (CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE + SORT_STRINGSORT,
      PatternPtr, Length(PatternPtr), WideChar(MultiWildChar), 1) - 2 = 0) then
    begin
      Result := True;
      Exit;
    end
    else if (ValuePtr^ = #0) and (PatternPtr^ <> #0) then
    begin
      Result := False;
      Exit;
    end
    else if (ValuePtr^ = #0) then
    begin
      Result := True;
      Exit;
    end else
    begin
      case PatternPtr^ of
        MultiWildChar:
          begin
            for I := 0 to Length(ValuePtr) - 1 do
            begin
              if LikeString(ValuePtr + I, PatternPtr + 1, CaseSensitive) then
              begin
                Result := True;
                Exit;
              end;
            end;
            Result := False;
            Exit;
          end;
        SingleWildChar:
          begin
            Inc(ValuePtr);
            Inc(PatternPtr);
          end;
      else
        begin
          B := False;
          if CaseSensitive then
          begin
            if (CompareStringW(LOCALE_USER_DEFAULT, SORT_STRINGSORT,
              PatternPtr, 1, ValuePtr, 1) - 2 = 0) then
              B := True;
          end else
          begin
            if (CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE + SORT_STRINGSORT,
              PatternPtr, 1, ValuePtr, 1) - 2 = 0) then
              B := True;
          end;

          if B then
          begin
            Inc(ValuePtr);
            Inc(PatternPtr);
          end else
          begin
            Result := False;
            Exit;
          end;
        end;
      end; // case
    end;
  end;
end;     

function TinyDBCompareString(const S1, S2: string; PartialCompare: Boolean;
  PartialLength: Integer; CaseInsensitive: Boolean): Integer;
begin
  if not PartialCompare then
    PartialLength := -1;
  if CaseInsensitive then
  begin
    Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1),
      PartialLength, PChar(S2), PartialLength) - 2;
  end else
  begin
    Result := CompareString(LOCALE_USER_DEFAULT, 0, PChar(S1),
      PartialLength, PChar(S2), PartialLength) - 2;
  end;
end;

function IsValidDBName(S: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  if S = '' then Exit;
  for I := 1 to Length(S) do
    if S[I] < ' ' then Exit;
  Result := True;
end;

function IsInt(const S: string): Boolean;
var
  E, R: Integer;
begin
  Val(S, R, E);
  Result := E = 0;
  E := R; // avoid hints
end;

procedure RandomFillBuffer(Buffer: PChar; Size: Integer; FromVal, ToVal: Integer);
var
  I: Integer;
begin
  Randomize;
  for I := 0 to Size - 1 do
  begin
    Buffer^ := Chr(Random(ToVal-FromVal+1)+FromVal);
    Inc(Buffer);
  end;
end;

procedure ScanBlanks(const S: string; var Pos: Integer);
var
  I: Integer;
begin
  I := Pos;
  while (I <= Length(S)) and (S[I] = ' ') do Inc(I);
  Pos := I;
end;

function ScanNumber(const S: string; var Pos: Integer;
  var Number: Word; var CharCount: Byte): Boolean;
var
  I: Integer;
  N: Word;
begin
  Result := False;
  CharCount := 0;
  ScanBlanks(S, Pos);
  I := Pos;
  N := 0;
  while (I <= Length(S)) and (S[I] in ['0'..'9']) and (N < 1000) do
  begin
    N := N * 10 + (Ord(S[I]) - Ord('0'));
    Inc(I);
  end;
  if I > Pos then
  begin
    CharCount := I - Pos;
    Pos := I;
    Number := N;
    Result := True;
  end;
end;

function ScanString(const S: string; var Pos: Integer;
  const Symbol: string): Boolean;
begin
  Result := False;
  if Symbol <> '' then
  begin
    ScanBlanks(S, Pos);
    if AnsiCompareText(Symbol, Copy(S, Pos, Length(Symbol))) = 0 then
    begin
      Inc(Pos, Length(Symbol));
      Result := True;
    end;
  end;
end;

function ScanChar(const S: string; var Pos: Integer; Ch: Char): Boolean;
begin
  Result := False;
  ScanBlanks(S, Pos);
  if (Pos <= Length(S)) and (S[Pos] = Ch) then
  begin
    Inc(Pos);
    Result := True;
  end;
end;

function ScanDate(const S: string; var Pos: Integer; var Date: TDateTime): Boolean;

  function CurrentYear: Word;
  var
    SystemTime: TSystemTime;
  begin
    GetLocalTime(SystemTime);
    Result := SystemTime.wYear;
  end;

const
  SDateSeparator = '/';
var
  N1, N2, N3, Y, M, D: Word;
  L1, L2, L3, YearLen: Byte;
  CenturyBase: Integer;
begin
  Result := False;

  if not (ScanNumber(S, Pos, N1, L1) and ScanChar(S, Pos, SDateSeparator) and
    ScanNumber(S, Pos, N2, L2) and ScanChar(S, Pos, SDateSeparator) and
    ScanNumber(S, Pos, N3, L3)) then Exit;

  M := N1;
  D := N2;
  Y := N3;
  YearLen := L3;

  if YearLen <= 2 then
  begin
    CenturyBase := CurrentYear - TwoDigitYearCenturyWindow;
    Inc(Y, CenturyBase div 100 * 100);
    if (TwoDigitYearCenturyWindow > 0) and (Y < CenturyBase) then
      Inc(Y, 100);
  end;

  Result := True;
  try
    Date := EncodeDate(Y, M, D);
  except
    Result := False;
  end;
end;

function ScanTime(const S: string; var Pos: Integer; var Time: TDateTime): Boolean;
const
  STimeSeparator = ':';
var
  BaseHour: Integer;
  Hour, Min, Sec, MSec: Word;
  Junk: Byte;
begin
  Result := False;
  BaseHour := -1;
  if ScanString(S, Pos, TimeAMString) or ScanString(S, Pos, 'AM') then
    BaseHour := 0
  else if ScanString(S, Pos, TimePMString) or ScanString(S, Pos, 'PM') then
    BaseHour := 12;
  if BaseHour >= 0 then ScanBlanks(S, Pos);
  if not ScanNumber(S, Pos, Hour, Junk) then Exit;
  Min := 0;
  if ScanChar(S, Pos, STimeSeparator) then
    if not ScanNumber(S, Pos, Min, Junk) then Exit;
  Sec := 0;
  if ScanChar(S, Pos, STimeSeparator) then
    if not ScanNumber(S, Pos, Sec, Junk) then Exit;
  MSec := 0;
  if ScanChar(S, Pos, DecimalSeparator) then
    if not ScanNumber(S, Pos, MSec, Junk) then Exit;
  if BaseHour < 0 then
    if ScanString(S, Pos, TimeAMString) or ScanString(S, Pos, 'AM') then
      BaseHour := 0
    else
      if ScanString(S, Pos, TimePMString) or ScanString(S, Pos, 'PM') then
        BaseHour := 12;
  if BaseHour >= 0 then
  begin
    if (Hour = 0) or (Hour > 12) then Exit;
    if Hour = 12 then Hour := 0;
    Inc(Hour, BaseHour);
  end;
  ScanBlanks(S, Pos);

  Result := True;
  try
    Time := EncodeTime(Hour, Min, Sec, MSec);
  except
    Result := False;
  end;
end;

function DbStrToDate(const S: string; var Date: TDateTime): Boolean;
var
  Pos: Integer;
begin
  Result := True;
  Pos := 1;
  if not ScanDate(S, Pos, Date) or (Pos <= Length(S)) then
    Result := False;
end;

function DbStrToTime(const S: string; var Date: TDateTime): Boolean;
var
  Pos: Integer;
begin
  Result := True;
  Pos := 1;
  if not ScanTime(S, Pos, Date) or (Pos <= Length(S)) then
    Result := False;
end;

function DbStrToDateTime(const S: string; var DateTime: TDateTime): Boolean;
var
  Pos: Integer;
  Date, Time: TDateTime;
begin
  Result := True;
  Pos := 1;
  Time := 0;
  if not ScanDate(S, Pos, Date) or not ((Pos > Length(S)) or
    ScanTime(S, Pos, Time)) then
  begin   //  Try time only
    Pos := 1;
    if not ScanTime(S, Pos, DateTime) or (Pos <= Length(S)) then
      Result := False;
  end else
    if Date >= 0 then
      DateTime := Date + Time else
      DateTime := Date - Time;
end;

function CompareDbDateTime(const MSecsA, MSecsB: Double): Integer;
begin
  if Abs(MSecsA - MSecsB) < 1000 then
    Result := 0
  else if MSecsA < MSecsB then
    Result := -1
  else
    Result := 1;
end;

function Hash(HashClass: THashClass; const Source: string; Digest: Pointer = nil): string;
begin
  Result := HashClass.CalcString(Digest, Source);
end;

function HashMD5(const Source: string; Digest: Pointer = nil): string;
begin
  Result := Hash(THash_MD5, Source, Digest);
end;

function HashSHA(const Source: string; Digest: Pointer = nil): string;
begin
  Result := Hash(THash_SHA, Source, Digest);
end;

function HashSHA1(const Source: string; Digest: Pointer = nil): string;
begin
  Result := Hash(THash_SHA1, Source, Digest);
end;

function CheckSumCRC32(const Data; DataSize: Integer): Longword;
begin
  THash_CRC32.CalcBuffer(@Result, Data, DataSize);
end;

procedure EncryptBuffer(Buffer: PChar; DataSize: Integer;
  EncAlgo: string; EncMode: TEncryptMode; Password: string);
var
  EncObj: TEncryptMgr;
begin
  EncObj := TEncryptMgr.Create(nil);
  try
    EncObj.SetAlgoName(EncAlgo);
    EncObj.Mode := EncMode;
    EncObj.InitKey(Password);
    EncObj.EncodeBuffer(Buffer^, Buffer^, DataSize);
  finally
    EncObj.Free;
  end;
end;

procedure DecryptBuffer(Buffer: PChar; DataSize: Integer;
  EncAlgo: string; EncMode: TEncryptMode; Password: string);
var
  EncObj: TEncryptMgr;
begin
  EncObj := TEncryptMgr.Create(nil);
  try
    EncObj.SetAlgoName(EncAlgo);
    EncObj.Mode := EncMode;
    EncObj.InitKey(Password);
    EncObj.DecodeBuffer(Buffer^, Buffer^, DataSize);
  finally
    EncObj.Free;
  end;
end;

procedure EncryptBufferBlowfish(Buffer: PChar; DataSize: Integer; Password: string);
begin
  EncryptBuffer(Buffer, DataSize, 'Blowfish', FTinyDBDefaultEncMode, Password);
end;

procedure DecryptBufferBlowfish(Buffer: PChar; DataSize: Integer; Password: string);
begin
  DecryptBuffer(Buffer, DataSize, 'Blowfish', FTinyDBDefaultEncMode, Password);
end;

{ TTinyDefCollection }

constructor TTinyDefCollection.Create(AOwner: TPersistent; AClass: TCollectionItemClass);
begin
  inherited Create(AOwner, AClass);
end;

procedure TTinyDefCollection.SetItemName(AItem: TCollectionItem);
begin
  with TNamedItem(AItem) do
    if (Name = '') then
      Name := Copy(ClassName, 2, 5) + IntToStr(ID+1);
end;

function TTinyDefCollection.IndexOf(const AName: string): Integer;
begin
  for Result := 0 to Count - 1 do
    if AnsiCompareText(TNamedItem(Items[Result]).Name, AName) = 0 then Exit;
  Result := -1;
end;

function TTinyDefCollection.Find(const AName: string): TNamedItem;
var
  I: Integer;
begin
  I := IndexOf(AName);
  if I < 0 then Result := nil else Result := TNamedItem(Items[I]);
end;

procedure TTinyDefCollection.GetItemNames(List: TStrings);
var
  I: Integer;
begin
  List.BeginUpdate;
  try
    List.Clear;
    for I := 0 to Count - 1 do
      with TNamedItem(Items[I]) do
        if Name <> '' then List.Add(Name);
  finally
    List.EndUpdate;
  end;
end;

{ TTinyTableDef }

constructor TTinyTableDef.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

destructor TTinyTableDef.Destroy;
begin
  inherited Destroy;
end;

{ TTinyTableDefs }

constructor TTinyTableDefs.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TTinyTableDef);
end;

function TTinyTableDefs.GetItem(Index: Integer): TTinyTableDef;
begin
  Result := TTinyTableDef(inherited Items[Index]);
end;

function TTinyTableDefs.IndexOf(const Name: string): Integer;
var
  Item: TTinyTableDef;
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Item := GetItem(I);
    if AnsiCompareText(Item.Name, Name) = 0 then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

function TTinyTableDefs.Find(const Name: string): TTinyTableDef;
var
  I: Integer;
begin
  I := IndexOf(Name);
  if I = -1 then
    DatabaseErrorFmt(STableNotFound, [Name]);
  Result := Items[I];
end;

{ TTinyFieldDef }

constructor TTinyFieldDef.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FFieldType := ftUnknown;
  FFieldSize := 0;
  FDPMode := fdDefault;
end;

destructor TTinyFieldDef.Destroy;
begin
  inherited;
end;

procedure TTinyFieldDef.Assign(Source: TPersistent);
var
  S: TTinyFieldDef;
begin
  if Source is TTinyFieldDef then
  begin
    if Collection <> nil then Collection.BeginUpdate;
    try
      S := TTinyFieldDef(Source);
      Name := S.Name;
      FFieldType := S.FFieldType;
      FFieldSize := S.FFieldSize;
      FDPMode := S.FDPMode;
    finally
      if Collection <> nil then Collection.EndUpdate;
    end;
  end else
    inherited;
end;

{ TTinyFieldDefs }

constructor TTinyFieldDefs.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TTinyFieldDef);
end;

function TTinyFieldDefs.AddIndexDef: TTinyFieldDef;
begin
  Result := TTinyFieldDef(inherited Add);
end;

function TTinyFieldDefs.Find(const Name: string): TTinyFieldDef;
begin
  Result := TTinyFieldDef(inherited Find(Name));
  if Result = nil then DatabaseErrorFmt(SFieldNotFound, [Name]);
end;

function TTinyFieldDefs.GetFieldDef(Index: Integer): TTinyFieldDef;
begin
  Result := TTinyFieldDef(inherited Items[Index]);
end;

procedure TTinyFieldDefs.SetFieldDef(Index: Integer; Value: TTinyFieldDef);
begin
  inherited Items[Index] := Value;
end;

procedure TTinyFieldDefs.SetItemName(AItem: TCollectionItem);
begin
  with TNamedItem(AItem) do
    if Name = '' then
      Name := Copy(ClassName, 2, 5) + IntToStr(ID+1);
end;

{ TTinyIndexDef }

constructor TTinyIndexDef.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FOptions := [];
end;

destructor TTinyIndexDef.Destroy;
begin
  inherited Destroy;
end;

procedure TTinyIndexDef.Assign(Source: TPersistent);
var
  S: TTinyIndexDef;
begin
  if Source is TTinyIndexDef then
  begin
    if Collection <> nil then Collection.BeginUpdate;
    try
      S := TTinyIndexDef(Source);
      Name := S.Name;
      Options := S.Options;
      FieldIdxes := S.FieldIdxes;
    finally
      if Collection <> nil then Collection.EndUpdate;
    end;
  end else
    inherited;
end;

procedure TTinyIndexDef.SetOptions(Value: TTDIndexOptions);
begin
  FOptions := Value;
end;

{ TTinyIndexDefs }

function TTinyIndexDefs.GetIndexDef(Index: Integer): TTinyIndexDef;
begin
  Result := TTinyIndexDef(inherited Items[Index]);
end;

procedure TTinyIndexDefs.SetIndexDef(Index: Integer; Value: TTinyIndexDef);
begin
  inherited Items[Index] := Value;
end;

procedure TTinyIndexDefs.SetItemName(AItem: TCollectionItem);
begin
  with TNamedItem(AItem) do
    if Name = '' then
      Name := Copy(ClassName, 2, 5) + IntToStr(ID+1);
end;

constructor TTinyIndexDefs.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TTinyIndexDef);
end;

function TTinyIndexDefs.AddIndexDef: TTinyIndexDef;
begin
  Result := TTinyIndexDef(inherited Add);
end;

function TTinyIndexDefs.Find(const Name: string): TTinyIndexDef;
begin
  Result := TTinyIndexDef(inherited Find(Name));
  if Result = nil then DatabaseErrorFmt(SIndexNotFound, [Name]);
end;

{ TTinyBlobStream }

constructor TTinyBlobStream.Create(Field: TBlobField; Mode: TBlobStreamMode);
begin
  FMode := Mode;
  FField := Field;
  FDataSet := FField.DataSet as TTinyTable;
  FFieldNo := FField.FieldNo;

  if Mode in [bmRead, bmReadWrite] then
  begin
    LoadBlobData;
  end;

  FOpened := True;
  if Mode = bmWrite then Truncate;
end;

destructor TTinyBlobStream.Destroy;
begin
  inherited Destroy;
end;

function TTinyBlobStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result := inherited Write(Buffer, Count);
  if FMode in [bmWrite, bmReadWrite] then
  begin
    FModified := True;
    SaveBlobData;
    FField.Modified := True;
    FDataSet.DataEvent(deFieldChange, Longint(FField));
  end;
end;

procedure TTinyBlobStream.LoadBlobData;
var
  RecBuf: PChar;
  BlobStream: TMemoryStream;
begin
  if FDataSet.GetActiveRecBuf(RecBuf) then
  begin
    Inc(RecBuf, FDataSet.GetFieldOffsetByFieldNo(FFieldNo));
    BlobStream := PMemoryStream(RecBuf)^;
    if Assigned(BlobStream) then
    begin
      Clear;
      CopyFrom(BlobStream, 0);
      Position := 0;
    end;
  end;
end;

procedure TTinyBlobStream.SaveBlobData;
var
  RecBuf: PChar;
  BlobStream: TMemoryStream;
  SavePos: Integer;
begin
  if FDataSet.GetActiveRecBuf(RecBuf) then
  begin
    SavePos := Position;
    try
      Inc(RecBuf, FDataSet.GetFieldOffsetByFieldNo(FFieldNo));
      BlobStream := PMemoryStream(RecBuf)^;
      if Assigned(BlobStream) then
      begin
        BlobStream.Clear;
        BlobStream.CopyFrom(Self, 0);
      end;
    finally
      Position := SavePos;
    end;
  end;
end;

procedure TTinyBlobStream.Truncate;
begin
  if FOpened then
  begin
    Clear;
    SaveBlobData;
    FField.Modified := True;
    FModified := True;
  end;
end;

{ TOptimBlobStream }

constructor TOptimBlobStream.Create(ADataSet: TTDEDataSet);
begin
  FDataSet := ADataSet;
  FFldDataOffset := 0;
  FDataLoaded := False;
end;

destructor TOptimBlobStream.Destroy;
begin
  inherited;
end;

procedure TOptimBlobStream.Init(FldDataOffset: Integer; ShouldEncrypt, ShouldCompress: Boolean);
begin
  FFldDataOffset := FldDataOffset;
  FShouldEncrypt := ShouldEncrypt;
  FShouldCompress := ShouldCompress;
  FDataLoaded := False;
end;

procedure TOptimBlobStream.LoadBlobData;
begin
  if FFldDataOffset = 0 then Exit;
  if FDataLoaded then Exit;
  FDataLoaded := True;
  // 从数据库读入BLOB数据到内存中
  FDataSet.ReadFieldData(Self, FFldDataOffset, SizeOf(TBlobFieldHeader),
    True, FShouldEncrypt, FShouldCompress);
end;

function TOptimBlobStream.Realloc(var NewCapacity: Integer): Pointer;
begin
  FDataLoaded := True;
  Result := inherited Realloc(NewCapacity);
end;

function TOptimBlobStream.Read(var Buffer; Count: Integer): Longint;
begin
  LoadBlobData;
  Result := inherited Read(Buffer, Count);
end;

function TOptimBlobStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  LoadBlobData;
  Result := inherited Seek(Offset, Origin);
end;

procedure TOptimBlobStream.SetSize(NewSize: Integer);
begin
  FDataLoaded := True;
  inherited;
end;

function TOptimBlobStream.Write(const Buffer; Count: Integer): Longint;
begin
  FDataLoaded := True;
  Result := inherited Write(Buffer, Count);
end;

{ TCachedFileStream }

constructor TCachedFileStream.Create(const FileName: string; Mode: Word);
begin
  // inherited;
  FCacheStream := TMemoryStream.Create;
  FCacheStream.LoadFromFile(FileName);
end;

destructor TCachedFileStream.Destroy;
begin
  FCacheStream.Free;
  // inherited;
end;

function TCachedFileStream.Read(var Buffer; Count: Integer): Longint;
begin
  Result := FCacheStream.Read(Buffer, Count);
end;

function TCachedFileStream.Write(const Buffer; Count: Integer): Longint;
begin
  Result := FCacheStream.Write(Buffer, Count);
end;

function TCachedFileStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  Result := FCacheStream.Seek(Offset, Origin);
end;

{ TExprNode }

constructor TExprNode.Create(ExprNodes: TExprNodes);
begin
  FExprNodes := ExprNodes;
  FArgs := nil;
  FPartialLength := -1;
end;

destructor TExprNode.Destroy;
begin
  if FArgs <> nil then FArgs.Free;
  SetDataSize(0);
  inherited;
end;

procedure TExprNode.Calculate(Options: TStrCompOptions);
var
  I: Integer;
  RecBuf: PChar;
begin
  case FKind of
    enField:
      begin
        if FIsBlobField then
        begin
          with GetDataSet do
          begin
            FBlobData := Fields[FFieldIdx].AsString;
            FData := @FBlobData[1];
          end;
        end else
        begin
          if FData = nil then
            with GetDataSet do
            begin
              GetActiveRecBuf(RecBuf);
              FData := RecBuf + GetFieldOffsetByFieldNo(Fields[FFieldIdx].FieldNo);
            end;
        end;
      end;
    enFunc:
      begin
        for I := 0 to FArgs.Count - 1 do
          TExprNode(FArgs[I]).Calculate(Options);
        EvaluateFunction(Self, FFunction, FArgs);
      end;
    enOperator:
      begin
        case FOperator of
          toOR:
            begin
              FLeft.Calculate(Options);
              if not PBoolean(FLeft.FData)^ then FRight.Calculate(Options);
              EvaluateOperator(Self, FOperator, FLeft, FRight, nil, Options);
            end;
          toAND:
            begin
              FLeft.Calculate(Options);
              if PBoolean(FLeft.FData)^ then FRight.Calculate(Options);
              EvaluateOperator(Self, FOperator, FLeft, FRight, nil, Options);
            end;
          toNOT:
            begin
              FLeft.Calculate(Options);
              EvaluateOperator(Self, FOperator, FLeft, FRight, nil, Options);
            end;
          toEQ, toNE, toGT, toLT, toGE, toLE,
          toADD, toSUB, toMUL, toDIV,
          toLIKE:
            begin
              FLeft.Calculate(Options);
              FRight.Calculate(Options);
              EvaluateOperator(Self, FOperator, FLeft, FRight, nil, Options);
            end;
          toIN:
            begin
              FLeft.Calculate(Options);
              for I := 0 to FArgs.Count - 1 do
                TExprNode(FArgs[I]).Calculate(Options);
              EvaluateOperator(Self, FOperator, FLeft, nil, FArgs, Options);
            end;
        end;
      end;
  end;
end;

procedure TExprNode.EvaluateOperator(ResultNode: TExprNode; Operator: TTinyOperator;
  LeftNode, RightNode: TExprNode; Args: TList; Options: TStrCompOptions);
var
  TempTimeStamp: TTimeStamp;
  W1, W2: WideString;
  I: Integer;
begin
  case Operator of
    toOR:
      begin
        if PBoolean(LeftNode.FData)^ then
          PBoolean(ResultNode.FData)^ := True
        else
          PBoolean(ResultNode.FData)^ := PBoolean(RightNode.FData)^;
      end;
    toAND:
      begin
        if PBoolean(LeftNode.FData)^ then
          PBoolean(ResultNode.FData)^ := PBoolean(RightNode.FData)^
        else
          PBoolean(ResultNode.FData)^ := False;
      end;
    toNOT:
      begin
        PBoolean(ResultNode.FData)^ := not PBoolean(LeftNode.FData)^;
      end;
    toEQ:   //-----------------------------------------------------------------
      begin
        case LeftNode.FDataType of
          ftBoolean:
              PBoolean(ResultNode.FData)^ := PBoolean(LeftNode.FData)^ = PBoolean(RightNode.FData)^;
          ftSmallInt:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ = PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ = PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := Integer(PSmallInt(LeftNode.FData)^) = Integer(PWord(RightNode.FData)^);
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ = PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ = PDouble(RightNode.FData)^;
            end;
          ftInteger, ftAutoInc:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ = PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ = PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ = PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ = PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ = PDouble(RightNode.FData)^;
            end;
          ftWord:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := Integer(PWord(LeftNode.FData)^) = Integer(PSmallInt(RightNode.FData)^);
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ = PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ = PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ = PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ = PDouble(RightNode.FData)^;
            end;
          ftLargeInt:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ = PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ = PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ = PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ = PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ = PDouble(RightNode.FData)^;
            end;
          ftFloat, ftCurrency:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ = PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ = PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ = PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ = PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ = PDouble(RightNode.FData)^;
            end;
          ftDate:
            case RightNode.FDataType of
              ftDate:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ = PInteger(RightNode.FData)^;
              ftDateTime:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(RightNode.FData)^);
                  PBoolean(ResultNode.FData)^ := TempTimeStamp.Date = PInteger(LeftNode.FData)^;
                end;
            end;
          ftTime:
            case RightNode.FDataType of
              ftTime:
                PBoolean(ResultNode.FData)^ := CompareDbDateTime(PInteger(LeftNode.FData)^, PInteger(RightNode.FData)^) = 0;
            end;
          ftDateTime:
            case RightNode.FDataType of
              ftDate:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  PBoolean(ResultNode.FData)^ := TempTimeStamp.Date = PInteger(RightNode.FData)^;
                end;
              ftDateTime:
                PBoolean(ResultNode.FData)^ := CompareDbDateTime(PDouble(LeftNode.FData)^, PDouble(RightNode.FData)^) = 0;
            end;
          ftString, ftFixedChar, ftBlob, ftMemo, ftFmtMemo, ftGraphic:
            case RightNode.FDataType of
              ftString, ftFixedChar, ftBlob, ftMemo, ftFmtMemo, ftGraphic:
                PBoolean(ResultNode.FData)^ := TinyDBCompareString(LeftNode.FData, RightNode.FData,
                  not (scNoPartialCompare in Options), RightNode.FPartialLength, scCaseInsensitive in Options) = 0;
            end;
        end;
      end;
    toNE:   //-----------------------------------------------------------------
      begin
        EvaluateOperator(ResultNode, toEQ, LeftNode, RightNode, nil, Options);
        PBoolean(ResultNode.FData)^ := not PBoolean(ResultNode.FData)^;
      end;
    toGT:   //-----------------------------------------------------------------
      begin
        case LeftNode.FDataType of
          ftBoolean:
              PBoolean(ResultNode.FData)^ := PBoolean(LeftNode.FData)^ > PBoolean(RightNode.FData)^;
          ftSmallInt:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ > PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ > PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := Integer(PSmallInt(LeftNode.FData)^) > Integer(PWord(RightNode.FData)^);
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ > PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ > PDouble(RightNode.FData)^;
            end;
          ftInteger, ftAutoInc:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ > PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ > PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ > PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ > PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ > PDouble(RightNode.FData)^;
            end;
          ftWord:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := Integer(PWord(LeftNode.FData)^) > Integer(PSmallInt(RightNode.FData)^);
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ > PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ > PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ > PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ > PDouble(RightNode.FData)^;
            end;
          ftLargeInt:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ > PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ > PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ > PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ > PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ > PDouble(RightNode.FData)^;
            end;
          ftFloat, ftCurrency:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ > PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ > PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ > PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ > PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ > PDouble(RightNode.FData)^;
            end;
          ftDate:
            case RightNode.FDataType of
              ftDate:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ > PInteger(RightNode.FData)^;
              ftDateTime:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(RightNode.FData)^);
                  PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ > TempTimeStamp.Date;
                end;
            end;
          ftTime:
            case RightNode.FDataType of
              ftTime:
                PBoolean(ResultNode.FData)^ := CompareDbDateTime(PInteger(LeftNode.FData)^, PInteger(RightNode.FData)^) > 0;
            end;
          ftDateTime:
            case RightNode.FDataType of
              ftDate:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  PBoolean(ResultNode.FData)^ := TempTimeStamp.Date > PInteger(RightNode.FData)^;
                end;
              ftDateTime:
                PBoolean(ResultNode.FData)^ := CompareDbDateTime(PDouble(LeftNode.FData)^, PDouble(RightNode.FData)^) > 0;
            end;
          ftString, ftFixedChar, ftBlob, ftMemo, ftFmtMemo, ftGraphic:
            case RightNode.FDataType of
              ftString, ftFixedChar, ftBlob, ftMemo, ftFmtMemo, ftGraphic:
                PBoolean(ResultNode.FData)^ := TinyDBCompareString(LeftNode.FData, RightNode.FData,
                  not (scNoPartialCompare in Options), RightNode.FPartialLength, scCaseInsensitive in Options) > 0;
            end;
        end;
      end;
    toLT:   //-----------------------------------------------------------------
      begin
        case LeftNode.FDataType of
          ftBoolean:
              PBoolean(ResultNode.FData)^ := PBoolean(LeftNode.FData)^ < PBoolean(RightNode.FData)^;
          ftSmallInt:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ < PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ < PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := Integer(PSmallInt(LeftNode.FData)^) < Integer(PWord(RightNode.FData)^);
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ < PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ < PDouble(RightNode.FData)^;
            end;
          ftInteger, ftAutoInc:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ < PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ < PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ < PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ < PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ < PDouble(RightNode.FData)^;
            end;
          ftWord:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := Integer(PWord(LeftNode.FData)^) < Integer(PSmallInt(RightNode.FData)^);
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ < PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ < PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ < PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PWord(LeftNode.FData)^ < PDouble(RightNode.FData)^;
            end;
          ftLargeInt:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ < PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ < PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ < PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ < PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ < PDouble(RightNode.FData)^;
            end;
          ftFloat, ftCurrency:
            case RightNode.FDataType of
              ftSmallInt:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ < PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ < PInteger(RightNode.FData)^;
              ftWord:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ < PWord(RightNode.FData)^;
              ftLargeInt:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ < PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PBoolean(ResultNode.FData)^ := PDouble(LeftNode.FData)^ < PDouble(RightNode.FData)^;
            end;
          ftDate:
            case RightNode.FDataType of
              ftDate:
                PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ < PInteger(RightNode.FData)^;
              ftDateTime:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(RightNode.FData)^);
                  PBoolean(ResultNode.FData)^ := PInteger(LeftNode.FData)^ < TempTimeStamp.Date;
                end;
            end;
          ftTime:
            case RightNode.FDataType of
              ftTime:
                PBoolean(ResultNode.FData)^ := CompareDbDateTime(PInteger(LeftNode.FData)^, PInteger(RightNode.FData)^) < 0;
            end;
          ftDateTime:
            case RightNode.FDataType of
              ftDate:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  PBoolean(ResultNode.FData)^ := TempTimeStamp.Date < PInteger(RightNode.FData)^;
                end;
              ftDateTime:
                PBoolean(ResultNode.FData)^ := CompareDbDateTime(PDouble(LeftNode.FData)^, PDouble(RightNode.FData)^) < 0;
            end;
          ftString, ftFixedChar, ftBlob, ftMemo, ftFmtMemo, ftGraphic:
            case RightNode.FDataType of
              ftString, ftFixedChar, ftBlob, ftMemo, ftFmtMemo, ftGraphic:
                PBoolean(ResultNode.FData)^ := TinyDBCompareString(LeftNode.FData, RightNode.FData,
                  not (scNoPartialCompare in Options), RightNode.FPartialLength, scCaseInsensitive in Options) < 0;
            end;
        end;
      end;
    toGE:   //-----------------------------------------------------------------
      begin
        EvaluateOperator(ResultNode, toLT, LeftNode, RightNode, nil, Options);
        PBoolean(ResultNode.FData)^ := not PBoolean(ResultNode.FData)^;
      end;
    toLE:   //-----------------------------------------------------------------
      begin
        EvaluateOperator(ResultNode, toGT, LeftNode, RightNode, nil, Options);
        PBoolean(ResultNode.FData)^ := not PBoolean(ResultNode.FData)^;
      end;
    toADD:  //-----------------------------------------------------------------
      begin
        case LeftNode.FDataType of
          ftSmallInt:
            case RightNode.FDataType of
              ftSmallInt:
                PInteger(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ + PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PInteger(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ + PInteger(RightNode.FData)^;
              ftWord:
                PInteger(ResultNode.FData)^ := Integer(PSmallInt(LeftNode.FData)^) + Integer(PWord(RightNode.FData)^);
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ + PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ + PDouble(RightNode.FData)^;
            end;
          ftInteger, ftAutoInc:
            case RightNode.FDataType of
              ftSmallInt:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PInteger(RightNode.FData)^;
              ftWord:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PWord(RightNode.FData)^;
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PDouble(RightNode.FData)^;
            end;
          ftWord:
            case RightNode.FDataType of
              ftSmallInt:
                PInteger(ResultNode.FData)^ := Integer(PWord(LeftNode.FData)^) + Integer(PSmallInt(RightNode.FData)^);
              ftInteger, ftAutoInc:
                PInteger(ResultNode.FData)^ := PWord(LeftNode.FData)^ + PInteger(RightNode.FData)^;
              ftWord:
                PInteger(ResultNode.FData)^ := PWord(LeftNode.FData)^ + PWord(RightNode.FData)^;
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PWord(LeftNode.FData)^ + PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PWord(LeftNode.FData)^ + PDouble(RightNode.FData)^;
            end;
          ftLargeInt:
            case RightNode.FDataType of
              ftSmallInt:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ + PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ + PInteger(RightNode.FData)^;
              ftWord:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ + PWord(RightNode.FData)^;
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ + PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ + PDouble(RightNode.FData)^;
            end;
          ftFloat, ftCurrency:
            case RightNode.FDataType of
              ftSmallInt:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ + PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ + PInteger(RightNode.FData)^;
              ftWord:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ + PWord(RightNode.FData)^;
              ftLargeInt:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ + PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ + PDouble(RightNode.FData)^;
            end;
          ftDate:
            case RightNode.FDataType of
              ftSmallInt:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PInteger(RightNode.FData)^;
              ftWord:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PWord(RightNode.FData)^;
              ftLargeInt:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PDouble(RightNode.FData)^;
            end;
          ftTime:
            case RightNode.FDataType of
              ftSmallInt:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PInteger(RightNode.FData)^;
              ftWord:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PWord(RightNode.FData)^;
              ftLargeInt:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ + PDouble(RightNode.FData)^;
            end;
          ftDateTime:
            case RightNode.FDataType of
              ftSmallInt:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  Inc(TempTimeStamp.Date, PSmallInt(RightNode.FData)^);
                  PDouble(ResultNode.FData)^ := TimeStampToMSecs(TempTimeStamp);
                end;
              ftInteger, ftAutoInc:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  Inc(TempTimeStamp.Date, PInteger(RightNode.FData)^);
                  PDouble(ResultNode.FData)^ := TimeStampToMSecs(TempTimeStamp);
                end;
              ftWord:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  Inc(TempTimeStamp.Date, PWord(RightNode.FData)^);
                  PDouble(ResultNode.FData)^ := TimeStampToMSecs(TempTimeStamp);
                end;
              ftLargeInt:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  Inc(TempTimeStamp.Date, PLargeInt(RightNode.FData)^);
                  PDouble(ResultNode.FData)^ := TimeStampToMSecs(TempTimeStamp);
                end;
              ftFloat, ftCurrency:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  Inc(TempTimeStamp.Date, Trunc(PDouble(RightNode.FData)^));
                  PDouble(ResultNode.FData)^ := TimeStampToMSecs(TempTimeStamp);
                end;
            end;
          ftString, ftFixedChar, ftBlob, ftMemo, ftFmtMemo, ftGraphic:
            case RightNode.FDataType of
              ftString, ftFixedChar, ftBlob, ftMemo, ftFmtMemo, ftGraphic:
                begin
                  ResultNode.DataSize := StrLen(LeftNode.FData) + StrLen(RightNode.FData) + 1;
                  StrCopy(ResultNode.FData, LeftNode.FData);
                  StrCat(ResultNode.FData, RightNode.FData);
                end;
            end;
        end;
      end;
    toSUB:  //-----------------------------------------------------------------
      begin
        case LeftNode.FDataType of
          ftSmallInt:
            case RightNode.FDataType of
              ftSmallInt:
                PInteger(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ - PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PInteger(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ - PInteger(RightNode.FData)^;
              ftWord:
                PInteger(ResultNode.FData)^ := Integer(PSmallInt(LeftNode.FData)^) - Integer(PWord(RightNode.FData)^);
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ - PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ - PDouble(RightNode.FData)^;
            end;
          ftInteger, ftAutoInc:
            case RightNode.FDataType of
              ftSmallInt:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PInteger(RightNode.FData)^;
              ftWord:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PWord(RightNode.FData)^;
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PDouble(RightNode.FData)^;
            end;
          ftWord:
            case RightNode.FDataType of
              ftSmallInt:
                PInteger(ResultNode.FData)^ := Integer(PWord(LeftNode.FData)^) - Integer(PSmallInt(RightNode.FData)^);
              ftInteger, ftAutoInc:
                PInteger(ResultNode.FData)^ := PWord(LeftNode.FData)^ - PInteger(RightNode.FData)^;
              ftWord:
                PInteger(ResultNode.FData)^ := PWord(LeftNode.FData)^ - PWord(RightNode.FData)^;
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PWord(LeftNode.FData)^ - PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PWord(LeftNode.FData)^ - PDouble(RightNode.FData)^;
            end;
          ftLargeInt:
            case RightNode.FDataType of
              ftSmallInt:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ - PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ - PInteger(RightNode.FData)^;
              ftWord:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ - PWord(RightNode.FData)^;
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ - PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ - PDouble(RightNode.FData)^;
            end;
          ftFloat, ftCurrency:
            case RightNode.FDataType of
              ftSmallInt:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ - PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ - PInteger(RightNode.FData)^;
              ftWord:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ - PWord(RightNode.FData)^;
              ftLargeInt:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ - PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ - PDouble(RightNode.FData)^;
            end;
          ftDate:
            case RightNode.FDataType of
              ftSmallInt:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc, ftDate:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PInteger(RightNode.FData)^;
              ftWord:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PWord(RightNode.FData)^;
              ftLargeInt:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - Trunc(PDouble(RightNode.FData)^);
            end;
          ftTime:
            case RightNode.FDataType of
              ftSmallInt:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc, ftTime:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PInteger(RightNode.FData)^;
              ftWord:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PWord(RightNode.FData)^;
              ftLargeInt:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ - Trunc(PDouble(RightNode.FData)^);
            end;
          ftDateTime:
            case RightNode.FDataType of
              ftSmallInt:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  Dec(TempTimeStamp.Date, PSmallInt(RightNode.FData)^);
                  PDouble(ResultNode.FData)^ := TimeStampToMSecs(TempTimeStamp);
                end;
              ftInteger, ftAutoInc:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  Dec(TempTimeStamp.Date, PInteger(RightNode.FData)^);
                  PDouble(ResultNode.FData)^ := TimeStampToMSecs(TempTimeStamp);
                end;
              ftWord:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  Dec(TempTimeStamp.Date, PWord(RightNode.FData)^);
                  PDouble(ResultNode.FData)^ := TimeStampToMSecs(TempTimeStamp);
                end;
              ftLargeInt:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  Dec(TempTimeStamp.Date, PLargeInt(RightNode.FData)^);
                  PDouble(ResultNode.FData)^ := TimeStampToMSecs(TempTimeStamp);
                end;
              ftFloat, ftCurrency:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  Dec(TempTimeStamp.Date, Trunc(PDouble(RightNode.FData)^));
                  PDouble(ResultNode.FData)^ := TimeStampToMSecs(TempTimeStamp);
                end;
              ftDate, ftTime:
                begin
                  TempTimeStamp := MSecsToTimeStamp(PDouble(LeftNode.FData)^);
                  PDouble(ResultNode.FData)^ := TimeStampToMSecs(TempTimeStamp) - PInteger(RightNode.FData)^;
                end;
              ftDateTime:
                begin
                  PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ - PDouble(RightNode.FData)^;
                end;
            end;
        end;
      end;
    toMUL:  //-----------------------------------------------------------------
      begin
        case LeftNode.FDataType of
          ftSmallInt:
            case RightNode.FDataType of
              ftSmallInt:
                PInteger(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ * PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PInteger(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ * PInteger(RightNode.FData)^;
              ftWord:
                PInteger(ResultNode.FData)^ := Integer(PSmallInt(LeftNode.FData)^) * Integer(PWord(RightNode.FData)^);
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ * PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ * PDouble(RightNode.FData)^;
            end;
          ftInteger, ftAutoInc:
            case RightNode.FDataType of
              ftSmallInt:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ * PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ * PInteger(RightNode.FData)^;
              ftWord:
                PInteger(ResultNode.FData)^ := PInteger(LeftNode.FData)^ * PWord(RightNode.FData)^;
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PInteger(LeftNode.FData)^ * PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ * PDouble(RightNode.FData)^;
            end;
          ftWord:
            case RightNode.FDataType of
              ftSmallInt:
                PInteger(ResultNode.FData)^ := Integer(PWord(LeftNode.FData)^) * Integer(PSmallInt(RightNode.FData)^);
              ftInteger, ftAutoInc:
                PInteger(ResultNode.FData)^ := PWord(LeftNode.FData)^ * PInteger(RightNode.FData)^;
              ftWord:
                PInteger(ResultNode.FData)^ := PWord(LeftNode.FData)^ * PWord(RightNode.FData)^;
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PWord(LeftNode.FData)^ * PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PWord(LeftNode.FData)^ * PDouble(RightNode.FData)^;
            end;
          ftLargeInt:
            case RightNode.FDataType of
              ftSmallInt:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ * PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ * PInteger(RightNode.FData)^;
              ftWord:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ * PWord(RightNode.FData)^;
              ftLargeInt:
                PLargeInt(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ * PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ * PDouble(RightNode.FData)^;
            end;
          ftFloat, ftCurrency:
            case RightNode.FDataType of
              ftSmallInt:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ * PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ * PInteger(RightNode.FData)^;
              ftWord:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ * PWord(RightNode.FData)^;
              ftLargeInt:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ * PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ * PDouble(RightNode.FData)^;
            end;
        end;
      end;
    toDIV:  //-----------------------------------------------------------------
      begin
        case LeftNode.FDataType of
          ftSmallInt:
            case RightNode.FDataType of
              ftSmallInt:
                PDouble(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ / PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PDouble(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ / PInteger(RightNode.FData)^;
              ftWord:
                PDouble(ResultNode.FData)^ := Integer(PSmallInt(LeftNode.FData)^) / Integer(PWord(RightNode.FData)^);
              ftLargeInt:
                PDouble(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ / PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PSmallInt(LeftNode.FData)^ / PDouble(RightNode.FData)^;
            end;
          ftInteger, ftAutoInc:
            case RightNode.FDataType of
              ftSmallInt:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ / PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ / PInteger(RightNode.FData)^;
              ftWord:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ / PWord(RightNode.FData)^;
              ftLargeInt:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ / PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PInteger(LeftNode.FData)^ / PDouble(RightNode.FData)^;
            end;
          ftWord:
            case RightNode.FDataType of
              ftSmallInt:
                PDouble(ResultNode.FData)^ := Integer(PWord(LeftNode.FData)^) / Integer(PSmallInt(RightNode.FData)^);
              ftInteger, ftAutoInc:
                PDouble(ResultNode.FData)^ := PWord(LeftNode.FData)^ / PInteger(RightNode.FData)^;
              ftWord:
                PDouble(ResultNode.FData)^ := PWord(LeftNode.FData)^ / PWord(RightNode.FData)^;
              ftLargeInt:
                PDouble(ResultNode.FData)^ := PWord(LeftNode.FData)^ / PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PWord(LeftNode.FData)^ / PDouble(RightNode.FData)^;
            end;
          ftLargeInt:
            case RightNode.FDataType of
              ftSmallInt:
                PDouble(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ / PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PDouble(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ / PInteger(RightNode.FData)^;
              ftWord:
                PDouble(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ / PWord(RightNode.FData)^;
              ftLargeInt:
                PDouble(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ / PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PLargeInt(LeftNode.FData)^ / PDouble(RightNode.FData)^;
            end;
          ftFloat, ftCurrency:
            case RightNode.FDataType of
              ftSmallInt:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ / PSmallInt(RightNode.FData)^;
              ftInteger, ftAutoInc:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ / PInteger(RightNode.FData)^;
              ftWord:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ / PWord(RightNode.FData)^;
              ftLargeInt:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ / PLargeInt(RightNode.FData)^;
              ftFloat, ftCurrency:
                PDouble(ResultNode.FData)^ := PDouble(LeftNode.FData)^ / PDouble(RightNode.FData)^;
            end;
        end;
      end;
    toLIKE: //-----------------------------------------------------------------
      begin
        W1 := LeftNode.FData;
        W2 := RightNode.FData;
        PBoolean(ResultNode.FData)^ := LikeString(W1, W2, not (scCaseInsensitive in Options));
      end;
    toIN:   //-----------------------------------------------------------------
      begin
        for I := 0 to Args.Count - 1 do
        begin
          EvaluateOperator(ResultNode, toEQ, LeftNode, TExprNode(Args[I]), nil, Options);
          if PBoolean(ResultNode.FData)^ then Break;
        end;
      end;
  end;
end;

procedure TExprNode.EvaluateFunction(ResultNode: TExprNode; AFunction: TTinyFunction; Args: TList);
var
  TempNode: TExprNode;
  TempTimeStamp: TTimeStamp;
  Year, Month, Day, Hour, Minute, Second, MSec: Word;
begin
  case AFunction of
    tfUpper:
      begin
        TempNode := TExprNode(Args[0]);
        ResultNode.DataSize := StrLen(TempNode.FData) + 1;
        StrCopy(ResultNode.FData, StrUpper(TempNode.FData));
      end;
    tfLower:
      begin
        TempNode := TExprNode(Args[0]);
        ResultNode.DataSize := StrLen(TempNode.FData) + 1;
        StrCopy(ResultNode.FData, StrLower(TempNode.FData));
      end;
    tfSubString:
      begin
        ResultNode.DataSize := PInteger(TExprNode(Args[2]).FData)^ + 1;  //Sub Length
        StrLCopy(ResultNode.FData,
          TExprNode(Args[0]).FData + PInteger(TExprNode(Args[1]).FData)^ - 1,
          PInteger(TExprNode(Args[2]).FData)^);
      end;
    tfTrim:
      begin
        TempNode := TExprNode(Args[0]);
        ResultNode.DataSize := StrLen(TempNode.FData) + 1;
        StrCopy(ResultNode.FData, PChar(Trim(string(TempNode.FData))));
      end;
    tfTrimLeft:
      begin
        TempNode := TExprNode(Args[0]);
        ResultNode.DataSize := StrLen(TempNode.FData) + 1;
        StrCopy(ResultNode.FData, PChar(TrimLeft(string(TempNode.FData))));
      end;
    tfTrimRight:
      begin
        TempNode := TExprNode(Args[0]);
        ResultNode.DataSize := StrLen(TempNode.FData) + 1;
        StrCopy(ResultNode.FData, PChar(TrimRight(string(TempNode.FData))));
      end;
    tfYear, tfMonth, tfDay:
      begin
        TempNode := TExprNode(Args[0]);
        case TempNode.FDataType of
          ftDate:
            begin
              TempTimeStamp.Date := PInteger(TempNode.FData)^;
              TempTimeStamp.Time := 0;
              DecodeDate(TimeStampToDateTime(TempTimeStamp), Year, Month, Day);
            end;
          ftDateTime:
            begin
              TempTimeStamp := MSecsToTimeStamp(PDouble(TempNode.FData)^);
              DecodeDate(TimeStampToDateTime(TempTimeStamp), Year, Month, Day);
            end;
        end;
        case AFunction of
          tfYear:  PInteger(ResultNode.FData)^ := Year;
          tfMonth: PInteger(ResultNode.FData)^ := Month;
          tfDay:   PInteger(ResultNode.FData)^ := Day;
        end;
      end;
    tfHour, tfMinute, tfSecond:
      begin
        TempNode := TExprNode(Args[0]);
        case TempNode.FDataType of
          ftTime:
            begin
              TempTimeStamp.Date := Trunc(Date);
              TempTimeStamp.Time := PInteger(TempNode.FData)^;
              DecodeTime(TimeStampToDateTime(TempTimeStamp), Hour, Minute, Second, MSec);
            end;
          ftDateTime:
            begin
              TempTimeStamp := MSecsToTimeStamp(PDouble(TempNode.FData)^);
              DecodeTime(TimeStampToDateTime(TempTimeStamp), Hour, Minute, Second, MSec);
            end;
        end;
        case AFunction of
          tfHour:   PInteger(ResultNode.FData)^ := Hour;
          tfMinute: PInteger(ResultNode.FData)^ := Minute;
          tfSecond: PInteger(ResultNode.FData)^ := Second;
        end;
      end;
  end;
end;

function TExprNode.IsIntegerType: Boolean;
begin
  Result := FDataType in [ftSmallint, ftInteger, ftWord, ftAutoInc];
end;

function TExprNode.IsLargeIntType: Boolean;
begin
  Result := FDataType in [ftLargeInt];
end;

function TExprNode.IsFloatType: Boolean;
begin
  Result := FDataType in [ftFloat, ftCurrency];
end;

function TExprNode.IsTemporalType: Boolean;
begin
  Result := FDataType in [ftDate, ftTime, ftDateTime];
end;

function TExprNode.IsStringType: Boolean;
begin
  Result := (FDataType in StringFieldTypes) or (FDataType in BlobFieldTypes);
end;

function TExprNode.IsBooleanType: Boolean;
begin
  Result := (FDataType = ftBoolean);
end;

function TExprNode.IsNumericType: Boolean;
begin
  Result := IsIntegerType or IsLargeIntType or IsFloatType;
end;

function TExprNode.IsTemporalStringType: Boolean;
var
  TempStr: string;
  TempDateTime: TDateTime;
begin
  TempStr := FData;
  Result := IsStringType and (FKind = enConst);
  if Result then
  begin
    Result := DbStrToDateTime(TempStr, TempDateTime);
    if not Result then
    begin
      Result := True;
      try
        StrToDateTime(TempStr);
      except
        Result := False;
      end;
    end;
  end;
end;

procedure TExprNode.SetDataSize(Size: Integer);
begin
  if FDataSize <> Size then
  begin
    if Size > 0 then
    begin
      if FDataSize = 0 then
        FData := AllocMem(Size)
      else
        ReallocMem(FData, Size);
    end else
    begin
      FreeMem(FData);
    end;
    FDataSize := Size;
  end;
end;

function TExprNode.GetDataSet: TTDEDataSet;
begin
  Result := (FExprNodes.FExprParser as TFilterParser).FDataSet;
end;

function TExprNode.AsBoolean: Boolean;
begin
  Result := PBoolean(FData)^;
end;

procedure TExprNode.ConvertStringToDateTime;
var
  DateTimeString: string;
  DateTime: TDateTime;
  DstType: TFieldType;
begin
  DateTimeString := Trim(FData);

  if Pos(#32, DateTimeString) > 0 then
    DstType := ftDateTime
  else if Pos(':', DateTimeString) > 0 then
    DstType := ftTime
  else
    DstType := ftDate;

  case DstType of
    ftDate:
      begin
        if not DbStrToDate(DateTimeString, DateTime) then
          DateTime := StrToDate(DateTimeString);
        DataSize := SizeOf(Integer);
        FDataType := ftDate;
        PInteger(FData)^ := DateTimeToTimeStamp(DateTime).Date;
      end;
    ftTime:
      begin
        if not DbStrToTime(DateTimeString, DateTime) then
          DateTime := StrToTime(DateTimeString);
        DataSize := SizeOf(Integer);
        FDataType := ftTime;
        PInteger(FData)^ := DateTimeToTimeStamp(DateTime).Time;
      end;
    ftDateTime:
      begin
        if not DbStrToDateTime(DateTimeString, DateTime) then
          DateTime := StrToDateTime(DateTimeString);
        DataSize := SizeOf(Double);
        FDataType := ftDateTime;
        PDouble(FData)^ := TimeStampToMSecs(DateTimeToTimeStamp(DateTime));
      end;
  end;
end;

class function TExprNode.FuncNameToEnum(const FuncName: string): TTinyFunction;
var
  FuncNames: array[TTinyFunction] of string;
  I: TTinyFunction;
begin
  FuncNames[tfUpper] := 'UPPER';
  FuncNames[tfLower] := 'LOWER';
  FuncNames[tfSubString] := 'SUBSTRING';
  FuncNames[tfTrim] := 'TRIM';
  FuncNames[tfTrimLeft] := 'TRIMLEFT';
  FuncNames[tfTrimRight] := 'TRIMRIGHT';
  FuncNames[tfYear] := 'YEAR';
  FuncNames[tfMonth] := 'MONTH';
  FuncNames[tfDay] := 'DAY';
  FuncNames[tfHour] := 'HOUR';
  FuncNames[tfMinute] := 'MINUTE';
  FuncNames[tfSecond] := 'SECOND';
  FuncNames[tfGetDate] := 'GETDATE';

  for I := Low(FuncNames) to High(FuncNames) do
  begin
    if CompareText(FuncName, FuncNames[I]) = 0 then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := tfUnknown;
end;

{ TExprNodes }

constructor TExprNodes.Create(AExprParser: TExprParserBase);
begin
  FExprParser := AExprParser;
  FNodes := nil;
  FRoot := nil;
end;

destructor TExprNodes.Destroy;
begin
  Clear;
  inherited;
end;

procedure TExprNodes.Clear;
var
  Node: TExprNode;
begin
  while FNodes <> nil do
  begin
    Node := FNodes;
    FNodes := Node.FNext;
    Node.Free;
  end;
  FNodes := nil;
end;

function TExprNodes.NewNode(NodeKind: TExprNodeKind; DataType: TFieldType;
  ADataSize: Integer; Operator: TTinyOperator; Left, Right: TExprNode): TExprNode;
begin
  Result := TExprNode.Create(Self);
  with Result do
  begin
    FNext := FNodes;

    FKind := NodeKind;
    FDataType := DataType;
    DataSize := ADataSize;
    FOperator := Operator;
    FLeft := Left;
    FRight := Right;
  end;
  FNodes := Result;
end;

function TExprNodes.NewFuncNode(const FuncName: string): TExprNode;
begin
  Result := TExprNode.Create(Self);
  with Result do
  begin
    FNext := FNodes;

    FKind := enFunc;
    FDataType := FExprParser.GetFuncDataType(FuncName);
    DataSize := 0;
    FSymbol := FuncName;
    FOperator := toNOTDEFINED;
    FFunction := FuncNameToEnum(FuncName);
    FLeft := nil;
    FRight := nil;
  end;
  FNodes := Result;
end;

function TExprNodes.NewFieldNode(const FieldName: string): TExprNode;
begin
  Result := TExprNode.Create(Self);
  with Result do
  begin
    FNext := FNodes;

    FKind := enField;
    FDataType := FExprParser.GetFieldDataType(FieldName);
    DataSize := 0;
    FData := nil;
    FSymbol := FieldName;
    FOperator := toNOTDEFINED;
    FLeft := nil;
    FRight := nil;
    FIsBlobField := GetDataSet.FieldByName(FieldName).IsBlob;
    FFieldIdx := GetDataSet.FieldByName(FieldName).Index;
  end;
  FNodes := Result;
end;

{ TSyntaxParserBase }

constructor TSyntaxParserBase.Create;
begin
end;

destructor TSyntaxParserBase.Destroy;
begin
  inherited;
end;

procedure TSyntaxParserBase.SetText(const Value: string);
begin
  FText := Value;
  FSourcePtr := PChar(FText);
end;

function TSyntaxParserBase.IsKatakana(const Chr: Byte): Boolean;
begin
  Result := (SysLocale.PriLangID = LANG_JAPANESE) and (Chr in [$A1..$DF]);
end;

procedure TSyntaxParserBase.Skip(var P: PChar; TheSet: TChrSet);
begin
  while True do
  begin
    if P^ in LeadBytes then
      Inc(P, 2)
    else if (P^ in TheSet) or IsKatakana(Byte(P^)) then
      Inc(P)
    else
      Exit;
  end;
end;

function TSyntaxParserBase.TokenName: string;
begin
  if FSourcePtr = FTokenPtr then Result := SExprNothing else
  begin
    SetString(Result, FTokenPtr, FSourcePtr - FTokenPtr);
    Result := '''' + Result + '''';
  end;
end;

function TSyntaxParserBase.TokenSymbolIs(const S: string): Boolean;
begin
  Result := (FToken = etSymbol) and (CompareText(FTokenString, S) = 0);
end;

procedure TSyntaxParserBase.Rewind;
begin
  FSourcePtr := PChar(FText);
  FTokenPtr := FSourcePtr;
  FTokenString := '';
end;

function TSyntaxParserBase.SkipBeforeGetToken(Pos: PChar): PChar;
var
  P: PChar;
begin
  P := Pos;
  while (P^ <> #0) and (P^ <= ' ') do Inc(P);
  // 处理通用注释标志“/**/”
  if (P^ <> #0) and (P^ = '/') and (P[1] <> #0) and (P[1] = '*')then
  begin
    P := P + 2;
    while (P^ <> #0) and (P^ <> '*') do Inc(P);
    if (P^ = '*') and (P[1] <> #0) and (P[1] =  '/')  then
      P := P + 2
    else
      DatabaseErrorFmt(SExprInvalidChar, [P^]);
  end;
  while (P^ <> #0) and (P^ <= ' ') do Inc(P);
  Result := P;
end;

procedure TSyntaxParserBase.GetNextToken;
begin
  FPrevToken := FToken;
  FTokenString := '';
  FTokenPtr := SkipBeforeGetToken(FSourcePtr);
  FSourcePtr := InternalGetNextToken(FTokenPtr);
end;

{ TExprParserBase }

constructor TExprParserBase.Create;
begin
  FExprNodes := TExprNodes.Create(Self);
end;

destructor TExprParserBase.Destroy;
begin
  FExprNodes.Free;
  inherited;
end;

procedure  TExprParserBase.Parse(const AText: string);
begin
  FExprNodes.Clear;
  Text := AText;
  GetNextToken;
  FExprNodes.Root := ParseExpr;
  ParseFinished;
end;

procedure TExprParserBase.ParseFinished;
begin
  if FToken <> etEnd then DatabaseError(SExprTermination);
end;

function TExprParserBase.Calculate(Options: TStrCompOptions = []): Variant;
begin
  FStrCompOpts := Options;
  FExprNodes.Root.Calculate(Options);
  Result := FExprNodes.Root.AsBoolean;
end;

function TExprParserBase.TokenSymbolIsFunc(const S: string) : Boolean;
begin
  Result := False;
end;

{ TFilterParser }

constructor TFilterParser.Create(ADataSet: TTDEDataSet);
begin
  inherited Create;
  FDataSet := ADataSet;
end;

function TFilterParser.GetFieldDataType(const Name: string): TFieldType;
begin
  Result := FDataSet.FieldByName(Name).DataType;
end;

function TFilterParser.GetFieldValue(const Name: string): Variant;
begin
  Result := FDataSet.FieldByName(Name).Value;
end;

function TFilterParser.GetFuncDataType(const Name: string): TFieldType;
begin
  Result := ftUnknown;

  if (CompareText(Name, 'YEAR') = 0) or
     (CompareText(Name, 'MONTH') = 0) or
     (CompareText(Name, 'DAY') = 0) or
     (CompareText(Name, 'HOUR') = 0) or
     (CompareText(Name, 'MINUTE') = 0) or
     (CompareText(Name, 'SECOND') = 0 ) then
  begin
    Result := ftInteger;
  end else
  if CompareText(Name, 'GETDATE') = 0  then
  begin
    Result := ftDateTime;
  end;
end;

function TFilterParser.TokenSymbolIsFunc(const S: string): Boolean;
begin
  Result := TExprNode.FuncNameToEnum(S) <> tfUnknown;
end;

function TFilterParser.InternalGetNextToken(Pos: PChar): PChar;
var
  P, TokenStart: PChar;
  L: Integer;
  StrBuf: array[0..255] of Char;
begin
  P := Pos;
  case P^ of
    'A'..'Z', 'a'..'z', '_', #$81..#$fe:
      begin
        TokenStart := P;
        if not SysLocale.FarEast then
        begin
          Inc(P);
          while P^ in ['A'..'Z', 'a'..'z', '0'..'9', '_', '.', '[', ']'] do Inc(P);
        end
        else
          Skip(P, ['A'..'Z', 'a'..'z', '0'..'9', '_', '.', '[', ']']);
        SetString(FTokenString, TokenStart, P - TokenStart);
        FToken := etSymbol;
        if CompareText(FTokenString, 'LIKE') = 0 then
          FToken := etLIKE
        else if CompareText(FTokenString, 'IN') = 0 then
          FToken := etIN
        {
        else if CompareText(FTokenString, 'IS') = 0 then
        begin
          while (P^ <> #0) and (P^ <= ' ') do Inc(P);
          TokenStart := P;
          Skip(P, ['A'..'Z', 'a'..'z']);
          SetString(FTokenString, TokenStart, P - TokenStart);
          if CompareText(FTokenString, 'NOT')= 0 then
          begin
            while (P^ <> #0) and (P^ <= ' ') do Inc(P);
            TokenStart := P;
            Skip(P, ['A'..'Z', 'a'..'z']);
            SetString(FTokenString, TokenStart, P - TokenStart);
            if CompareText(FTokenString, 'NULL') = 0 then
              FToken := etISNOTNULL
            else
              DatabaseError(SInvalidKeywordUse);
          end
          else if CompareText (FTokenString, 'NULL') = 0  then
          begin
            FToken := etISNULL;
          end
          else
            DatabaseError(SInvalidKeywordUse);
        end;
        }
      end;
    '[':
      begin
        Inc(P);
        TokenStart := P;
        P := AnsiStrScan(P, ']');
        if P = nil then DatabaseError(SExprNameError);
        SetString(FTokenString, TokenStart, P - TokenStart);
        FToken := etName;
        Inc(P);
      end;
    '''':
      begin
        Inc(P);
        L := 0;
        while True do
        begin
          if P^ = #0 then DatabaseError(SExprStringError);
          if P^ = '''' then
          begin
            Inc(P);
            if P^ <> '''' then Break;
          end;
          if L < SizeOf(StrBuf) then
          begin
            StrBuf[L] := P^;
            Inc(L);
          end;
          Inc(P);
        end;
        SetString(FTokenString, StrBuf, L);
        FToken := etCharLiteral;
      end;
    '-', '0'..'9':
      begin
        if (P^ = '-') and
           ((FPrevToken = etCharLiteral) or (FPrevToken = etNumLiteral) or (FPrevToken = etName) or
           (FPrevToken = etSymbol) or (FPrevToken = etRParen)) then
        begin
          FToken := etSUB;
          Inc(P);
        end else
        begin
          TokenStart := P;
          Inc(P);
          while (P^ in ['0'..'9', DecimalSeparator, 'e', 'E', '+', '-']) do
          begin
            if (P^ in ['+', '-']) and not ((P-1)^ in ['e', 'E']) and (P <> TokenStart) then Break;
            Inc(P);
          end;
          if ((P-1)^ = ',') and (DecimalSeparator = ',') and (P^ = ' ') then Dec(P);
          SetString(FTokenString, TokenStart, P - TokenStart);
          FToken := etNumLiteral;
        end;
      end;
    '(':
      begin
        Inc(P);
        FToken := etLParen;
      end;
    ')':
      begin
        Inc(P);
        FToken := etRParen;
      end;
    '<':
      begin
        Inc(P);
        case P^ of
          '=':
            begin
              Inc(P);
              FToken := etLE;
            end;
          '>':
            begin
              Inc(P);
              FToken := etNE;
            end;
        else
          FToken := etLT;
        end;
      end;
    '=':
      begin
        Inc(P);
        FToken := etEQ;
      end;
    '>':
      begin
        Inc(P);
        if P^ = '=' then
        begin
          Inc(P);
          FToken := etGE;
        end else
          FToken := etGT;
      end;
    '+':
      begin
        Inc(P);
        FToken := etADD;
      end;
    '*':
      begin
        Inc(P);
        FToken := etMUL;
      end;
    '/':
      begin
        Inc(P);
        FToken := etDIV;
      end;
    ',':
      begin
        Inc(P);
        FToken := etComma;
      end;
    #0:
      FToken := etEnd;
    else
      DatabaseErrorFmt(SExprInvalidChar, [P^]);
  end;
  Result := P;
end;

function TFilterParser.NextTokenIsLParen: Boolean;
var
  P : PChar;
begin
  P := FSourcePtr;
  while (P^ <> #0) and (P^ <= ' ') do Inc(P);
  Result := P^ = '(';
end;

function TFilterParser.ParseExpr: TExprNode;
begin
  Result := ParseExpr2;
  while TokenSymbolIs('OR') do
  begin
    GetNextToken;
    Result := FExprNodes.NewNode(enOperator, ftBoolean, SizeOf(Boolean), toOR, Result, ParseExpr2);
    TypeCheckLogicOp(Result);
  end;
end;

function TFilterParser.ParseExpr2: TExprNode;
begin
  Result := ParseExpr3;
  while TokenSymbolIs('AND') do
  begin
    GetNextToken;
    Result := FExprNodes.NewNode(enOperator, ftBoolean, SizeOf(Boolean), toAND, Result, ParseExpr3);
    TypeCheckLogicOp(Result);
  end;
end;

function TFilterParser.ParseExpr3: TExprNode;
begin
  if TokenSymbolIs('NOT') then
  begin
    GetNextToken;
    Result := FExprNodes.NewNode(enOperator, ftBoolean, SizeOf(Boolean), toNOT, ParseExpr4, nil);
    TypeCheckLogicOp(Result);
  end else
    Result := ParseExpr4;
end;

function TFilterParser.ParseExpr4: TExprNode;
const
  Operators: array[etEQ..etLT] of TTinyOperator = (
    toEQ, toNE, toGE, toLE, toGT, toLT);
var
  Operator: TTinyOperator;
  Left, Right: TExprNode;
begin
  Result := ParseExpr5;
  if (FToken in [etEQ..etLT]) or (FToken = etLIKE) or (FToken = etIN) then
  begin
    case FToken of
      etEQ..etLT:
        Operator := Operators[FToken];
      etLIKE:
        Operator := toLIKE;
      etIN:
        Operator := toIN;
      else
        Operator := toNOTDEFINED;
    end;
    GetNextToken;
    Left := Result;
    if Operator = toIN then
    begin
      if FToken <> etLParen then
        DatabaseErrorFmt(SExprNoLParen, [TokenName]);
      GetNextToken;
      Result := FExprNodes.NewNode(enOperator, ftBoolean, SizeOf(Boolean), toIN, Left, nil);
      if FToken <> etRParen then
      begin
        Result.FArgs := TList.Create;
        repeat
          Right := ParseExpr;
          Result.FArgs.Add(Right);
          if (FToken <> etComma) and (FToken <> etRParen) then
            DatabaseErrorFmt(SExprNoRParenOrComma, [TokenName]);
          if FToken = etComma then GetNextToken;
        until (FToken = etRParen) or (FToken = etEnd);
        if FToken <> etRParen then
          DatabaseErrorFmt(SExprNoRParen, [TokenName]);
        TypeCheckInOp(Result);
        GetNextToken;
      end else
        DatabaseError(SExprEmptyInList);
    end else
    begin
      Right := ParseExpr5;
      Result := FExprNodes.NewNode(enOperator, ftBoolean, SizeOf(Boolean), Operator, Left, Right);
      case Operator of
        toEQ, toNE, toGE, toLE, toGT, toLT:
          TypeCheckRelationOp(Result);
        toLIKE:
          TypeCheckLikeOp(Result);
      end;
    end;
  end;
end;

function TFilterParser.ParseExpr5: TExprNode;
const
  Operators: array[etADD..etDIV] of TTinyOperator = (
    toADD, toSUB, toMUL, toDIV);
var
  Operator: TTinyOperator;
  Left, Right: TExprNode;
begin
  Result := ParseExpr6;
  while FToken in [etADD, etSUB] do
  begin
    Operator := Operators[FToken];
    Left := Result;
    GetNextToken;
    Right := ParseExpr6;
    Result := FExprNodes.NewNode(enOperator, ftUnknown, 0, Operator, Left, Right);
    TypeCheckArithOp(Result);
  end;
end;

function TFilterParser.ParseExpr6: TExprNode;
const
  Operators: array[etADD..etDIV] of TTinyOperator = (
    toADD, toSUB, toMUL, toDIV);
var
  Operator: TTinyOperator;
  Left, Right: TExprNode;
begin
  Result := ParseExpr7;
  while FToken in [etMUL, etDIV] do
  begin
    Operator := Operators[FToken];
    Left := Result;
    GetNextToken;
    Right := ParseExpr7;
    Result := FExprNodes.NewNode(enOperator, ftUnknown, 0, Operator, Left, Right);
    TypeCheckArithOp(Result);
  end;
end;

function TFilterParser.ParseExpr7: TExprNode;
var
  FuncName: string;
begin
  case FToken of
    etSymbol:
      if NextTokenIsLParen and TokenSymbolIsFunc(FTokenString) then
      begin
        FuncName := FTokenString;
        GetNextToken;
        if FToken <> etLParen then
          DatabaseErrorFmt(SExprNoLParen, [TokenName]);
        GetNextToken;
        if (CompareText(FuncName,'COUNT') = 0) and (FToken = etMUL) then
        begin
          FuncName := 'COUNT(*)';
          GetNextToken;
        end;
        Result := FExprNodes.NewFuncNode(FuncName);
        if FToken <> etRParen then
        begin
          Result.FArgs := TList.Create;
          repeat
            Result.FArgs.Add(ParseExpr);
            if (FToken <> etComma) and (FToken <> etRParen) then
              DatabaseErrorFmt(SExprNoRParenOrComma, [TokenName]);
            if FToken = etComma then GetNextToken;
          until (FToken = etRParen) or (FToken = etEnd);
        end else
          Result.FArgs := nil;
        TypeCheckFunction(Result);
      end
      else if TokenSymbolIs(STextTrue) then
      begin
        Result := FExprNodes.NewNode(enConst, ftBoolean, SizeOf(Boolean), toNOTDEFINED, nil, nil);
        PBoolean(Result.FData)^ := True;
      end
      else if TokenSymbolIs(STextFalse) then
      begin
        Result := FExprNodes.NewNode(enConst, ftBoolean, SizeOf(Boolean), toNOTDEFINED, nil, nil);
        PBoolean(Result.FData)^ := False;
      end
      else
      begin
        Result := FExprNodes.NewFieldNode(FTokenString);
      end;
    etName:
      begin
        Result := FExprNodes.NewFieldNode(FTokenString);
      end;
    etNumLiteral:
      begin
        if IsInt(FTokenString) then
        begin
          Result := FExprNodes.NewNode(enConst, ftInteger, SizeOf(Integer), toNOTDEFINED, nil, nil);
          PInteger(Result.FData)^ := StrToInt(FTokenString);
        end else
        begin
          Result := FExprNodes.NewNode(enConst, ftFloat, SizeOf(Double), toNOTDEFINED, nil, nil);
          PDouble(Result.FData)^ := StrToFloat(FTokenString);
        end;
      end;
    etCharLiteral:
      begin
        Result := FExprNodes.NewNode(enConst, ftString, Length(FTokenString) + 1, toNOTDEFINED, nil, nil);
        StrPCopy(Result.FData, FTokenString);
        Result.FPartialLength := Pos('*', Result.FData) - 1;
      end;
    etLParen:
      begin
        GetNextToken;
        Result := ParseExpr;
        if FToken <> etRParen then DatabaseErrorFmt(SExprNoRParen, [TokenName]);
      end;
  else
    DatabaseErrorFmt(SExprExpected, [TokenName]);
    Result := nil;
  end;
  GetNextToken;
end;

procedure TFilterParser.TypeCheckArithOp(Node: TExprNode);

  function CompareNumTypePRI(DataType1, DataType2: TFieldType): Integer;
  var
    Value: array[TFieldType] of Integer;
  begin
    Value[ftSmallInt] := 1;
    Value[ftWord] := 2;
    Value[ftInteger] := 3;
    Value[ftAutoInc] := 3;
    Value[ftLargeInt] := 4;
    Value[ftFloat] := 5;
    Value[ftCurrency] := 6;

    if Value[DataType1] > Value[DataType2] then
      Result := 1
    else if Value[DataType1] < Value[DataType2] then
      Result := -1
    else
      Result := 0;
  end;

var
  Match: Boolean;
  CompResult: Integer;
begin
  Match := True;
  with Node do
  begin
    if FLeft.IsNumericType then
    begin
      if FRight.IsNumericType then
      begin
        CompResult := CompareNumTypePRI(FLeft.FDataType, FRight.FDataType);
        if CompResult >= 0 then
        begin
          FDataType := FLeft.FDataType;
          DataSize := GetFieldSize(FLeft.FDataType);
        end else
        begin
          FDataType := FRight.FDataType;
          DataSize := GetFieldSize(FRight.FDataType);
        end;
        if FDataType in [ftSmallInt, ftWord] then
        begin
          FDataType := ftInteger;
          DataSize := SizeOf(Integer);
        end;

        if FOperator = toDIV then
        begin
          FDataType := ftFloat;
          DataSize := SizeOf(Double);
        end;
      end else
        Match := False;
    end
    else if FLeft.IsTemporalType then
    begin
      if FOperator = toSUB then
      begin
        if FRight.IsTemporalStringType then
          FRight.ConvertStringToDateTime;

        if (FLeft.FDataType = ftDate) and
           ((FRight.FDataType = ftDate) or FRight.IsNumericType) then
        begin
          FDataType := ftInteger;
          DataSize := SizeOf(Integer);
        end
        else if (FLeft.FDataType = ftTime) and
           ((FRight.FDataType = ftTime) or FRight.IsNumericType) then
        begin
          FDataType := ftInteger;
          DataSize := SizeOf(Integer);
        end
        else if FRight.IsTemporalType or FRight.IsNumericType then
        begin
          FDataType := ftFloat;
          DataSize := SizeOf(Double);
        end else
          Match := False;
      end
      else if FRight.IsNumericType and (FOperator = toADD) then
      begin
        FDataType := FLeft.FDataType;
        DataSize := GetFieldSize(FLeft.FDataType);
      end
      else
        Match := False;
    end
    else if FLeft.IsStringType then
    begin
      if FRight.IsStringType and (FOperator = toADD) then
        FDataType := ftString
      else if FLeft.IsTemporalStringType and FRight.IsTemporalType and (FOperator = toSUB) then
      begin
        FLeft.ConvertStringToDateTime;
        FDataType := ftFloat;
        DataSize := SizeOf(Double);
      end else
        Match := False;
    end
    else
      Match := False;
  end;
  if not Match then
    DatabaseError(SExprTypeMis);
end;

procedure TFilterParser.TypeCheckLogicOp(Node: TExprNode);
begin
  with Node do
  begin
    if FLeft <> nil then
      if not FLeft.IsBooleanType then
        DatabaseError(SExprTypeMis);
    if FRight <> nil then
      if not FRight.IsBooleanType then
        DatabaseError(SExprTypeMis);
  end;
end;

procedure TFilterParser.TypeCheckInOp(Node: TExprNode);
var
  I: Integer;
  TempNode: TExprNode;
  Match: Boolean;
begin
  Match := True;
  with Node do
  begin
    for I := 0 to FArgs.Count - 1 do
    begin
      TempNode := TExprNode(FArgs[I]);
      if FLeft.IsNumericType then
      begin
        if not TempNode.IsNumericType then
          Match := False;
      end
      else if FLeft.IsStringType then
      begin
        if not TempNode.IsStringType then
          Match := False;
      end
      else if FLeft.IsTemporalType then
      begin
        if TempNode.IsTemporalStringType then
          TempNode.ConvertStringToDateTime
        else
          if not TempNode.IsTemporalType then
            Match := False;
      end
      else if FLeft.IsBooleanType then
      begin
        if not TempNode.IsBooleanType then
          Match := False;
      end;
      if not Match then Break;
    end;
  end;
  if not Match then
    DatabaseError(SExprTypeMis);
end;

procedure TFilterParser.TypeCheckRelationOp(Node: TExprNode);
var
  Match: Boolean;
begin
  Match := True;
  with Node do
  begin
    if FLeft.IsNumericType then
    begin
      if not FRight.IsNumericType then
        Match := False; 
    end
    else if FLeft.IsTemporalType then
    begin
      if FRight.IsTemporalStringType then
        FRight.ConvertStringToDateTime
      else
        if not FRight.IsTemporalType then
          Match := False;
    end
    else if FLeft.IsStringType then
    begin
      if FRight.IsTemporalType and FLeft.IsTemporalStringType then
        FLeft.ConvertStringToDateTime
      else
        if not FRight.IsStringType then
          Match := False;
    end
    else if FLeft.IsBooleanType then
    begin
      if not FRight.IsBooleanType then
        Match := False;
      if (FOperator <> toEQ) or (FOperator <> toNE) then
        Match := False;
    end
    else
      Match := False;
  end;
  if not Match then
    DatabaseError(SExprTypeMis);
end;

procedure TFilterParser.TypeCheckLikeOp(Node: TExprNode);
begin
  with Node do
  begin
    if not FLeft.IsStringType or not FRight.IsStringType then
      DatabaseError(SExprTypeMis);
  end;
end;

procedure TFilterParser.TypeCheckFunction(Node: TExprNode);
begin
  with Node do
  begin
    case FFunction of
      tfUpper, tfLower,
      tfTrim, tfTrimLeft, tfTrimRight:
        begin
          if (FArgs = nil) or (FArgs.Count <> 1) then
            DatabaseError(SExprTypeMis);
          if not TExprNode(FArgs[0]).IsStringType then
            DatabaseError(SExprTypeMis);
          FDataType := ftString;
        end;
      tfSubString:
        begin
          if (FArgs = nil) or (FArgs.Count <> 3) then
            DatabaseError(SExprTypeMis);
          if not (TExprNode(FArgs[0]).IsStringType and
                  TExprNode(FArgs[1]).IsIntegerType and
                  (TExprNode(FArgs[1]).FKind = enConst) and
                  TExprNode(FArgs[2]).IsIntegerType and
                  (TExprNode(FArgs[2]).FKind = enConst) ) then
            DatabaseError(SExprTypeMis);
          FDataType := ftString;
        end;
      tfYear, tfMonth, tfDay:
        begin
          if (FArgs = nil) or (FArgs.Count <> 1) then
            DatabaseError(SExprTypeMis);
          if not ((TExprNode(FArgs[0]).FDataType = ftDate) or
                  (TExprNode(FArgs[0]).FDataType = ftDateTime)) then
            DatabaseError(SExprTypeMis);
          FDataType := ftInteger;
          DataSize := SizeOf(Integer);
        end;
      tfHour, tfMinute, tfSecond:
        begin
          if (FArgs = nil) or (FArgs.Count <> 1) then
            DatabaseError(SExprTypeMis);
          if not ((TExprNode(FArgs[0]).FDataType = ftTime) or
                  (TExprNode(FArgs[0]).FDataType = ftDateTime)) then
            DatabaseError(SExprTypeMis);
          FDataType := ftInteger;
          DataSize := SizeOf(Integer);
        end;
      tfGetDate:
        begin
          if (FArgs <> nil) and (FArgs.Count <> 0) then
            DatabaseError(SExprTypeMis);
          FDataType := ftDateTime;
          DataSize := SizeOf(Double);
          FKind := enConst;
          PDouble(FData)^ := TimeStampToMSecs(DateTimeToTimeStamp(Now));
        end;
    end;
  end;
end;

{ TSQLWhereExprParser }

constructor TSQLWhereExprParser.Create(ADataSet: TTDEDataSet);
begin
  inherited;
end;

function TSQLWhereExprParser.GetFieldValue(const Name: string): Variant;
begin

end;

{ TSQLParserBase }

constructor TSQLParserBase.Create(AQuery: TTinyQuery);
begin
  inherited Create;
  FQuery := AQuery;
  FRowsAffected := 0;
end;

destructor TSQLParserBase.Destroy;
begin
  inherited;
end;

function TSQLParserBase.SkipBeforeGetToken(Pos: PChar): PChar;
var
  P: PChar;
begin
  P := inherited SkipBeforeGetToken(Pos);

  // 处理SQL注释标志“--”
  if (P^ <> #0) and (P^ = '-') and (P[1] <> #0) and (P[1] = '-')then
  begin
    P := P + 2;
    while (P^ <> #0) and (P^ <> #13) and (P^ <> #10) do Inc(P);
  end;
  while (P^ <> #0) and (P^ <= ' ') do Inc(P);
  Result := P;
end;

function TSQLParserBase.InternalGetNextToken(Pos: PChar): PChar;
var
  P, TokenStart: PChar;
  L: Integer;
  StrBuf: array[0..255] of Char;
begin
  P := Pos;
  case P^ of
    'A'..'Z', 'a'..'z', '_', #$81..#$fe:
      begin
        TokenStart := P;
        if not SysLocale.FarEast then
        begin
          Inc(P);
          while P^ in ['A'..'Z', 'a'..'z', '0'..'9', '_', '.', '[', ']'] do Inc(P);
        end
        else
          Skip(P, ['A'..'Z', 'a'..'z', '0'..'9', '_', '.', '[', ']']);
        SetString(FTokenString, TokenStart, P - TokenStart);
        FToken := etSymbol;
      end;
    '[':
      begin
        Inc(P);
        TokenStart := P;
        P := AnsiStrScan(P, ']');
        if P = nil then DatabaseError(SExprNameError);
        SetString(FTokenString, TokenStart, P - TokenStart);
        FToken := etName;
        Inc(P);
      end;
    '''':
      begin
        Inc(P);
        L := 0;
        while True do
        begin
          if P^ = #0 then DatabaseError(SExprStringError);
          if P^ = '''' then
          begin
            Inc(P);
            if P^ <> '''' then Break;
          end;
          if L < SizeOf(StrBuf) then
          begin
            StrBuf[L] := P^;
            Inc(L);
          end;
          Inc(P);
        end;
        SetString(FTokenString, StrBuf, L);
        FToken := etCharLiteral;
      end;
    '-', '0'..'9':
      begin
        if (P^ = '-') and
           ((FPrevToken = etCharLiteral) or (FPrevToken = etNumLiteral) or (FPrevToken = etName) or
           (FPrevToken = etSymbol) or (FPrevToken = etRParen)) then
        begin
          FToken := etSUB;
          Inc(P);
        end else
        begin
          TokenStart := P;
          Inc(P);
          while (P^ in ['0'..'9', DecimalSeparator, 'e', 'E', '+', '-']) do
          begin
            if (P^ in ['+', '-']) and not ((P-1)^ in ['e', 'E']) and (P <> TokenStart) then Break;
            Inc(P);
          end;
          if ((P-1)^ = ',') and (DecimalSeparator = ',') and (P^ = ' ') then Dec(P);
          SetString(FTokenString, TokenStart, P - TokenStart);
          FToken := etNumLiteral;
        end;
      end;
    '(':
      begin
        Inc(P);
        FToken := etLParen;
      end;
    ')':
      begin
        Inc(P);
        FToken := etRParen;
      end;
    '*':
      begin
        Inc(P);
        FToken := etAsterisk;
      end;
    ',':
      begin
        Inc(P);
        FToken := etComma;
      end;
    #0:
      FToken := etEnd;
    else
      DatabaseErrorFmt(SSQLInvalidChar, [P^]);
  end;
  Result := P;
end;

procedure TSQLParserBase.Parse(const ASQL: string);
begin
  Text := ASQL;
end;

{ TSQLSelectParser }

constructor TSQLSelectParser.Create(AQuery: TTinyQuery);
begin
  inherited;
  FWhereExprParser := TSQLWhereExprParser.Create(AQuery);
end;

destructor TSQLSelectParser.Destroy;
begin
  FWhereExprParser.Free;
  inherited;
end;

function TSQLSelectParser.ParseFrom: PChar;

  function CheckOutOfSection: Boolean;
  begin
    Result := TokenSymbolIs('WHERE') or TokenSymbolIs('ORDER') or (FToken = etEnd);
  end;

var
  TableName, AliasTableName: string;
begin
  Rewind;
  while not TokenSymbolIs('FROM') and (FToken <> etEnd) do GetNextToken;

  if TokenSymbolIs('FROM') then
  begin
    GetNextToken;
    while True do
    begin
      TableName := '';
      AliasTableName := '';

      if CheckOutOfSection then
      begin
        if Length(FFromItems) = 0 then
          DatabaseErrorFmt(SSQLInvalid, [Text]);
        Break;
      end;

      if (FToken = etSymbol) or (FToken = etName) then
        TableName := FTokenString
      else
        DatabaseErrorFmt(SSQLInvalid, [Text]);

      GetNextToken;
      if not CheckOutOfSection then
      begin
        if TokenSymbolIs('AS') then
        begin
          GetNextToken;
          if CheckOutOfSection then
            DatabaseErrorFmt(SSQLInvalid, [Text]);
          if (FToken = etSymbol) or (FToken = etName) then
          begin
            AliasTableName := FTokenString;
            GetNextToken;
          end else
            DatabaseErrorFmt(SSQLInvalid, [Text]);
        end
        else if (FToken = etSymbol) or (FToken = etName) then
        begin
          AliasTableName := FTokenString;
          GetNextToken;
        end;
      end;

      if FToken = etComma then
      begin
        GetNextToken;
        if CheckOutOfSection then
          DatabaseErrorFmt(SSQLInvalid, [Text]);
      end else
      begin
        if not CheckOutOfSection then
          DatabaseErrorFmt(SSQLInvalid, [Text]);
      end;

      if AliasTableName = '' then AliasTableName := TableName;
      SetLength(FFromItems, Length(FFromItems) + 1);
      with FFromItems[High(FFromItems)] do
      begin
        RealName := TableName;
        AliasName := AliasTableName;
      end;
    end;

    //for I := 0 to High(FFromItems) do
    //  Showmessage(FFromItems[i].Realname + ',' + FFromItems[i].Aliasname);
  end else
  begin
    DatabaseErrorFmt(SSQLInvalid, [Text]);
  end;
  Result := FSourcePtr;
end;

function TSQLSelectParser.ParseSelect: PChar;
begin
  Rewind;
  GetNextToken; // 'SELECT'
  GetNextToken;
  // 含"TOP"子句
  if TokenSymbolIs('TOP') then
  begin
    GetNextToken;
    if FToken = etNumLiteral then
    begin
      FTopNum := StrToInt(FTokenString);
      if FTopNum <= 0 then
        DatabaseErrorFmt(SSQLInvalid, [Text]);
    end else
      DatabaseErrorFmt(SSQLInvalid, [Text]);
    GetNextToken;
  end;
  { TODO :  未完成 }
  Result := FSourcePtr;
end;

procedure TSQLSelectParser.Parse(const ASQL: string);
begin
  inherited;
  SetLength(FSelectItems, 0);
  SetLength(FFromItems, 0);
  SetLength(FOrderByItems, 0);
  FTopNum := -1;

  GetNextToken;
  ParseFrom;
  ParseSelect;
end;

procedure TSQLSelectParser.Execute;
begin
  // showmessage('test');
end;

{ TSQLParser }

constructor TSQLParser.Create(AQuery: TTinyQuery);
begin
  inherited;
  FSQLType := stNONE;
end;

destructor TSQLParser.Destroy;
begin
  inherited;
end;

procedure TSQLParser.Parse(const ASQL: string);
begin
  inherited;
  GetNextToken;
  if TokenSymbolIs('SELECT') then
    FSQLType := stSELECT
  else if TokenSymbolIs('INSERT') then
    FSQLType := stINSERT
  else if TokenSymbolIs('DELETE') then
    FSQLType := stDELETE
  else if TokenSymbolIs('UPDATE') then
    FSQLType := stUPDATE
  else begin
    FSQLType := stNONE;
    DatabaseErrorFmt(SSQLInvalid, [ASQL]);
  end;
end;

procedure TSQLParser.Execute;
var
  SQLParser: TSQLParserBase;
begin
  case FSQLType of
    stSELECT:  SQLParser := TSQLSelectParser.Create(FQuery);
    //stINSERT:  SQLParser := TSQLInsertParser.Create(FQuery);
    //stDELETE:  SQLParser := TSQLDeleteParser.Create(FQuery);
    //stUPDATE:  SQLParser := TSQLUpdateParser.Create(FQuery);
    else SQLParser := nil;
  end;
  try
    if SQLParser <> nil then
    begin
      SQLParser.Parse(Text);
      SQLParser.Execute;
      FRowsAffected := SQLParser.RowsAffected;
    end;
  finally
    SQLParser.Free;
  end;
end;

{ TRecordsMap }

constructor TRecordsMap.Create;
begin
  FList := TList.Create;
  FByIndexIdx := -1;
end;

destructor TRecordsMap.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TRecordsMap.Add(Value: Integer);
begin
  FList.Add(Pointer(Value));
end;

procedure TRecordsMap.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

procedure TRecordsMap.Clear;
begin
  FList.Clear;
end;

procedure TRecordsMap.DoAnd(Right, Result: TRecordsMap);
begin

end;

procedure TRecordsMap.DoOr(Right, Result: TRecordsMap);
begin

end;

procedure TRecordsMap.DoNot(Right, Result: TRecordsMap);
begin

end;

function TRecordsMap.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TRecordsMap.GetItem(Index: Integer): Integer;
begin
  Result := Integer(FList.Items[Index]);
end;

procedure TRecordsMap.SetItem(Index, Value: Integer);
begin
  FList.Items[Index] := Pointer(Value);
end;

{ TDataProcessAlgo }

constructor TDataProcessAlgo.Create(AOwner: TObject);
begin
  FOwner := AOwner;
end;

destructor TDataProcessAlgo.Destroy;
begin
  inherited;
end;

procedure TDataProcessAlgo.DoEncodeProgress(Percent: Integer);
begin
  if Assigned(FOnEncodeProgress) then
    FOnEncodeProgress(FOwner, Percent);
end;

procedure TDataProcessAlgo.DoDecodeProgress(Percent: Integer);
begin
  if Assigned(FOnDecodeProgress) then
    FOnDecodeProgress(FOwner, Percent);
end;

{ TCompressAlgo }

procedure TCompressAlgo.SetLevel(Value: TCompressLevel);
begin
end;

function TCompressAlgo.GetLevel: TCompressLevel;
begin
  Result := clNormal;
end;

{ TEncryptAlgo }

procedure TEncryptAlgo.DoProgress(Current, Maximal: Integer; Encode: Boolean);
begin
  if Encode then
  begin
    if Maximal = 0 then
      DoEncodeProgress(0)
    else
      DoEncodeProgress(Round(Current / Maximal * 100));
  end else
  begin
    if Maximal = 0 then
      DoDecodeProgress(0)
    else
      DoDecodeProgress(Round(Current / Maximal * 100));
  end;
end;

procedure TEncryptAlgo.InternalCodeStream(Source, Dest: TMemoryStream;
  DataSize: Integer; Encode: Boolean);
const
  EncMaxBufSize = 1024 * 4; 
type
  TCodeProc = procedure(const Source; var Dest; DataSize: Integer) of object;
var
  Buf: PChar;
  SPos: Integer;
  DPos: Integer;
  Len: Integer;
  Proc: TCodeProc;
  Size: Integer;
begin
  if Source = nil then Exit;
  if Encode then Proc := EncodeBuffer else Proc := DecodeBuffer;
  if Dest = nil then Dest := Source;
  if DataSize < 0 then
  begin
    DataSize := Source.Size;
    Source.Position := 0;
  end;
  Buf := nil;
  Size := DataSize;
  DoProgress(0, Size, Encode);
  try
    Buf    := AllocMem(EncMaxBufSize);
    DPos   := Dest.Position;
    SPos   := Source.Position;
    while DataSize > 0 do
    begin
      Source.Position := SPos;
      Len := DataSize;
      if Len > EncMaxBufSize then Len := EncMaxBufSize;
      Len := Source.Read(Buf^, Len);
      SPos := Source.Position;
      if Len <= 0 then Break;
      Proc(Buf^, Buf^, Len);
      Dest.Position := DPos;
      Dest.Write(Buf^, Len);
      DPos := Dest.Position;
      Dec(DataSize, Len);
      DoProgress(Size - DataSize, Size, Encode);
    end;
  finally
    DoProgress(0, 0, Encode);
    ReallocMem(Buf, 0);
  end;
end;

procedure TEncryptAlgo.SetMode(Value: TEncryptMode);
begin
end;

function TEncryptAlgo.GetMode: TEncryptMode;
begin
  Result := FTinyDBDefaultEncMode;
end;

procedure TEncryptAlgo.Done;
begin
end;

procedure TEncryptAlgo.EncodeStream(Source, Dest: TMemoryStream; DataSize: Integer);
begin
  InternalCodeStream(Source, Dest, DataSize, True);
end;

procedure TEncryptAlgo.DecodeStream(Source, Dest: TMemoryStream; DataSize: Integer);
begin
  InternalCodeStream(Source, Dest, DataSize, False);
end;

{ TDataProcessMgr }

constructor TDataProcessMgr.Create(AOwner: TTinyDBFileIO);
begin
  FTinyDBFile := AOwner;
end;

destructor TDataProcessMgr.Destroy;
begin
  FDPObject.Free;
  inherited;
end;

class function TDataProcessMgr.CheckAlgoRegistered(const AlgoName: string): Integer;
begin
  Result := -1;
end;

procedure TDataProcessMgr.EncodeStream(Source, Dest: TMemoryStream; DataSize: Integer);
begin
  if not Assigned(FDPObject) then DatabaseError(SGeneralError);
  FDPObject.EncodeStream(Source, Dest, DataSize);
end;

procedure TDataProcessMgr.DecodeStream(Source, Dest: TMemoryStream; DataSize: Integer);
begin
  if not Assigned(FDPObject) then DatabaseError(SGeneralError);
  FDPObject.DecodeStream(Source, Dest, DataSize);
end;

{ TCompressMgr }

function TCompressMgr.GetLevel: TCompressLevel;
begin
  if not Assigned(FDPObject) then DatabaseError(SGeneralError);
  Result := (FDPObject as TCompressAlgo).GetLevel;
end;

procedure TCompressMgr.SetLevel(const Value: TCompressLevel);
begin
  if not Assigned(FDPObject) then DatabaseError(SGeneralError);
  (FDPObject as TCompressAlgo).SetLevel(Value);
end;

class function TCompressMgr.CheckAlgoRegistered(const AlgoName: string): Integer;
begin
  Result := FCompressClassList.IndexOf(AlgoName);
  if Result = -1 then
    DatabaseErrorFmt(SCompressAlgNotFound, [AlgoName]);
end;

procedure TCompressMgr.SetAlgoName(const Value: string);
var
  I: Integer;
  CmpClass: TCompressAlgoClass;
  NewObj: Boolean;
begin
  I := CheckAlgoRegistered(Value);
  if I >= 0 then
  begin
    CmpClass := Pointer(FCompressClassList.Objects[I]);
    if FDPObject = nil then NewObj := True
    else if FDPObject.ClassType <> CmpClass then NewObj := True
    else NewObj := False;
    if NewObj then
    begin
      FDPObject.Free;
      FDPObject := CmpClass.Create(FTinyDBFile);
      if FTinyDBFile <> nil then
      begin
        FDPObject.OnEncodeProgress := FTinyDBFile.OnCompressProgressEvent;
        FDPObject.OnDecodeProgress := FTinyDBFile.OnUncompressProgressEvent;
      end;
    end;
  end;
end;

{ TEncryptMgr }

function TEncryptMgr.GetMode: TEncryptMode;
begin
  if not Assigned(FDPObject) then DatabaseError(SGeneralError);
  Result := (FDPObject as TEncryptAlgo).GetMode;
end;

procedure TEncryptMgr.SetMode(const Value: TEncryptMode);
begin
  if not Assigned(FDPObject) then DatabaseError(SGeneralError);
  (FDPObject as TEncryptAlgo).SetMode(Value);
end;

procedure TEncryptMgr.InitKey(const Key: string);
begin
  if not Assigned(FDPObject) then DatabaseError(SGeneralError);
  (FDPObject as TEncryptAlgo).InitKey(Key);
end;

procedure TEncryptMgr.Done;
begin
  if not Assigned(FDPObject) then DatabaseError(SGeneralError);
  (FDPObject as TEncryptAlgo).Done;
end;

class function TEncryptMgr.CheckAlgoRegistered(const AlgoName: string): Integer;
begin
  Result := FEncryptClassList.IndexOf(AlgoName);
  if Result = -1 then
    DatabaseErrorFmt(SEncryptAlgNotFound, [AlgoName]);
end;

procedure TEncryptMgr.SetAlgoName(const Value: string);
var
  I: Integer;
  EncClass: TEncryptAlgoClass;
  NewObj: Boolean;
begin
  I := CheckAlgoRegistered(Value);
  if I >= 0 then
  begin
    EncClass := Pointer(FEncryptClassList.Objects[I]);
    if FDPObject = nil then NewObj := True
    else if FDPObject.ClassType <> EncClass then NewObj := True
    else NewObj := False;
    if NewObj then
    begin
      FDPObject.Free;
      FDPObject := EncClass.Create(FTinyDBFile);
      if FTinyDBFile <> nil then
      begin
        FDPObject.OnEncodeProgress := FTinyDBFile.OnEncryptProgressEvent;
        FDPObject.OnDecodeProgress := FTinyDBFile.OnDecryptProgressEvent;
      end;
    end;
  end;
end;

procedure TEncryptMgr.DecodeStream(Source, Dest: TMemoryStream;
  DataSize: Integer);
begin
  inherited;
  Done;
end;

procedure TEncryptMgr.EncodeStream(Source, Dest: TMemoryStream;
  DataSize: Integer);
begin
  inherited;
  Done;
end;

procedure TEncryptMgr.EncodeBuffer(const Source; var Dest;
  DataSize: Integer);
begin
  if not Assigned(FDPObject) then DatabaseError(SGeneralError);
  (FDPObject as TEncryptAlgo).EncodeBuffer(Source, Dest, DataSize);
  Done;
end;

procedure TEncryptMgr.DecodeBuffer(const Source; var Dest;
  DataSize: Integer);
begin
  if not Assigned(FDPObject) then DatabaseError(SGeneralError);
  (FDPObject as TEncryptAlgo).DecodeBuffer(Source, Dest, DataSize);
  Done;
end;

{ TFieldBufferItem }

constructor TFieldBufferItem.Create;
begin
  inherited;
  FActive := True;
end;

destructor TFieldBufferItem.Destroy;
begin
  FreeBuffer;
  inherited;
end;

function TFieldBufferItem.GetAsString: string;
var
  TempTimeStamp: TTimeStamp;
begin
  try
    if FFieldType in StringFieldTypes then
      Result := PChar(FBuffer)
    else if FFieldType in BlobFieldTypes then
      Result := PChar(TMemoryStream(FBuffer).Memory)
    else if FFieldType in [ftInteger, ftAutoInc] then
      Result := IntToStr(PInteger(FBuffer)^)
    else if FFieldType in [ftWord] then
      Result := IntToStr(PWord(FBuffer)^)
    else if FFieldType in [ftLargeint] then
      Result := IntToStr(PLargeInt(FBuffer)^)
    else if FFieldType in [ftSmallint] then
      Result := IntToStr(PSmallInt(FBuffer)^)
    else if FFieldType in [ftFloat, ftCurrency] then
      Result := FloatToStr(PDouble(FBuffer)^)
    else if FFieldType in [ftBoolean] then
      if PWordBool(FBuffer)^ then Result := STextTrue
      else Result := STextFalse
    else if FFieldType in [ftDateTime] then
      Result := DateTimeToStr(TimeStampToDateTime(MSecsToTimeStamp(PDouble(FBuffer)^)))
    else if FFieldType in [ftDate] then
    begin
      TempTimeStamp.Date := PInteger(FBuffer)^;
      TempTimeStamp.Time := 0;
      Result := DateToStr(TimeStampToDateTime(TempTimeStamp));
    end
    else if FFieldType in [ftTime] then
    begin
      TempTimeStamp.Date := Trunc(Date);
      TempTimeStamp.Time := PInteger(FBuffer)^;
      Result := TimeToStr(TimeStampToDateTime(TempTimeStamp));
    end
    else
      Result := '';
  except
    Result := '';
  end;
end;

function TFieldBufferItem.GetDataBuf: Pointer;
begin
  if FFieldType in BlobFieldTypes then
    Result := TMemoryStream(FBuffer).Memory
  else
    Result := FBuffer;
end;

procedure TFieldBufferItem.AllocBuffer;
begin
  FreeBuffer;
  if FFieldType in BlobFieldTypes then
    FBuffer := TMemoryStream.Create
  else
    FBuffer := AllocMem(FFieldSize);
  FMemAlloc := True;
end;

procedure TFieldBufferItem.FreeBuffer;
begin
  if FMemAlloc then
  begin
    if FFieldType in BlobFieldTypes then
      TMemoryStream(FBuffer).Free
    else
      FreeMem(FBuffer);
    FMemAlloc := False;
  end;
end;

function TFieldBufferItem.IsBlob: Boolean;
begin
  Result := FFieldType in BlobFieldTypes;
end;

{ TFieldBuffers }

constructor TFieldBuffers.Create;
begin
  FItems := TList.Create;
end;

destructor TFieldBuffers.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

function TFieldBuffers.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TFieldBuffers.GetItem(Index: Integer): TFieldBufferItem;
begin
  Result := TFieldBufferItem(FItems[Index]);
end;

procedure TFieldBuffers.Add(FieldType: TFieldType; FieldSize: Integer);
var
  FieldBufferItem: TFieldBufferItem;
begin
  FieldBufferItem := TFieldBufferItem.Create;
  FieldBufferItem.FieldType := FieldType;
  FieldBufferItem.FieldSize := FieldSize;
  FieldBufferItem.AllocBuffer;
  FItems.Add(FieldBufferItem);
end;

procedure TFieldBuffers.Add(Buffer: Pointer; FieldType: TFieldType; FieldSize: Integer);
var
  FieldBufferItem: TFieldBufferItem;
begin
  FieldBufferItem := TFieldBufferItem.Create;
  if FieldType in BlobFieldTypes then
    FieldBufferItem.FBuffer := PMemoryStream(Buffer)^
  else
    FieldBufferItem.FBuffer := Buffer;
  FieldBufferItem.FieldType := FieldType;
  FieldBufferItem.FieldSize := FieldSize;
  FItems.Add(FieldBufferItem);
end;

procedure TFieldBuffers.Delete(Index: Integer);
begin
  TFieldBufferItem(FItems[Index]).Free;
  FItems.Delete(Index);
end;

procedure TFieldBuffers.Clear;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    TFieldBufferItem(FItems[I]).Free;
  FItems.Clear;
end;

{ TTinyDBFileStream }

constructor TTinyDBFileStream.Create(const FileName: string; Mode: Word);
begin
  inherited;
  FFlushed := True;
end;

{$IFDEF COMPILER_6_UP}
constructor TTinyDBFileStream.Create(const FileName: string; Mode: Word; Rights: Cardinal);
begin
  inherited;
  FFlushed := True;
end;
{$ENDIF}

function TTinyDBFileStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result := inherited Write(Buffer, Count);
  FFlushed := False;
end;

procedure TTinyDBFileStream.Flush;
begin
  FlushFileBuffers(Handle);
  FFlushed := True;
end;

{ TTinyDBFileIO }

constructor TTinyDBFileIO.Create(AOwner: TTinyDatabase);
begin
  FDatabase := AOwner;
  if FDatabase <> nil then
  begin
    FMediumType := FDatabase.MediumType;
    FExclusive := FDatabase.Exclusive;
  end;
  FCompressMgr := TCompressMgr.Create(Self);
  FEncryptMgr := TEncryptMgr.Create(Self);
  InitializeCriticalSection(FDPCSect);
end;

destructor TTinyDBFileIO.Destroy;
begin
  Close;
  FCompressMgr.Free;
  FEncryptMgr.Free;
  DeleteCriticalSection(FDPCSect);
  inherited;
end;

function TTinyDBFileIO.GetIsOpen: Boolean;
begin
  Result := FDBStream <> nil;
end;

function TTinyDBFileIO.GetFlushed: Boolean;
begin
  if FDBStream is TTinyDBFileStream then
    Result := (FDBStream as TTinyDBFileStream).Flushed
  else
    Result := True;
end;

//-----------------------------------------------------------------------------
// 对Stream中的数据进行解码（解密和解压）
// Encrypt:  是否解密
// Compress: 是否解压
//-----------------------------------------------------------------------------
procedure TTinyDBFileIO.DecodeMemoryStream(SrcStream, DstStream: TMemoryStream; Encrypt, Compress: Boolean);
var
  TempStream: TMemoryStream;
begin
  EnterCriticalSection(FDPCSect);
  try
    SrcStream.Position := 0;
    if SrcStream <> DstStream then DstStream.Clear;
    
    // 如果不用任何处理
    if not Encrypt and not Compress then
    begin
      if SrcStream <> DstStream then DstStream.CopyFrom(SrcStream, 0);
    end;

    // 解密
    if Encrypt then
    begin
      FEncryptMgr.DecodeStream(SrcStream, DstStream, SrcStream.Size);
    end;
    
    // 解压
    if Compress then
    begin
      if Encrypt then
      begin
        TempStream := TMemoryStream.Create;
        TempStream.LoadFromStream(DstStream);
        DstStream.Clear;
      end else
        TempStream := SrcStream;
      TempStream.Position := 0;
      try
        FCompressMgr.DecodeStream(TempStream, DstStream, TempStream.Size);
      finally
        if TempStream <> SrcStream then
          TempStream.Free;
      end;
    end;
  finally
    LeaveCriticalSection(FDPCSect);
  end;
end;

//-----------------------------------------------------------------------------
// 对Buffer中的数据进行解码（解密）
// Encrypt:  是否解密
// 注: SrcBuffer,DstBuffer中不存在格式，只是普通的内存块
//-----------------------------------------------------------------------------
procedure TTinyDBFileIO.DecodeMemoryBuffer(SrcBuffer, DstBuffer: PChar; DataSize: Integer; Encrypt: Boolean);
begin
  EnterCriticalSection(FDPCSect);
  try
    if Encrypt then
    begin
      FEncryptMgr.DecodeBuffer(SrcBuffer^, DstBuffer^, DataSize);
    end else
    begin
      Move(SrcBuffer^, DstBuffer^, DataSize);
    end;
  finally
    LeaveCriticalSection(FDPCSect);
  end;
end;

//-----------------------------------------------------------------------------
// 对Stream中的数据进行编码（压缩和加密）
// Encrypt:  是否加密
// Compress: 是否压缩
//-----------------------------------------------------------------------------
procedure TTinyDBFileIO.EncodeMemoryStream(SrcStream, DstStream: TMemoryStream; Encrypt, Compress: Boolean);
var
  TempStream: TMemoryStream;
begin
  EnterCriticalSection(FDPCSect);
  try
    SrcStream.Position := 0;
    if SrcStream <> DstStream then DstStream.Clear;

    // 如果不用任何处理
    if not Encrypt and not Compress then
    begin
      if SrcStream <> DstStream then DstStream.CopyFrom(SrcStream, 0);
    end;

    // 压缩
    if Compress then
    begin
      FCompressMgr.EncodeStream(SrcStream, DstStream, SrcStream.Size)
    end;

    // 加密
    if Encrypt then
    begin
      if Compress then
      begin
        TempStream := TMemoryStream.Create;
        TempStream.LoadFromStream(DstStream);
        DstStream.Clear;
      end else
        TempStream := SrcStream;
      TempStream.Position := 0;
      try
        FEncryptMgr.EncodeStream(TempStream, DstStream, TempStream.Size);
      finally
        if TempStream <> SrcStream then
          TempStream.Free;
      end;
    end;
  finally
    LeaveCriticalSection(FDPCSect);
  end;
end;

//-----------------------------------------------------------------------------
// 对Buffer中的数据进行编码（加密）
// Encrypt:  是否加密
// 注: SrcBuffer,DstBuffer中不存在格式，只是普通的内存块
//-----------------------------------------------------------------------------
procedure TTinyDBFileIO.EncodeMemoryBuffer(SrcBuffer, DstBuffer: PChar; DataSize: Integer; Encrypt: Boolean);
begin
  EnterCriticalSection(FDPCSect);
  try
    if Encrypt then
    begin
      FEncryptMgr.EncodeBuffer(SrcBuffer^, DstBuffer^, DataSize);
    end else
    begin
      Move(SrcBuffer^, DstBuffer^, DataSize);
    end;
  finally
    LeaveCriticalSection(FDPCSect);
  end;
end;

procedure TTinyDBFileIO.OnCompressProgressEvent(Sender: TObject; Percent: Integer);
begin
  if Assigned(FDatabase.FOnCompressProgress) then
    FDatabase.FOnCompressProgress(FDatabase, Percent);
end;

procedure TTinyDBFileIO.OnUncompressProgressEvent(Sender: TObject; Percent: Integer);
begin
  if Assigned(FDatabase.FOnUncompressProgress) then
    FDatabase.FOnUncompressProgress(FDatabase, Percent);
end;

procedure TTinyDBFileIO.OnEncryptProgressEvent(Sender: TObject; Percent: Integer);
begin
  if Assigned(FDatabase.FOnEncryptProgress) then
    FDatabase.FOnEncryptProgress(FDatabase, Percent);
end;

procedure TTinyDBFileIO.OnDecryptProgressEvent(Sender: TObject; Percent: Integer);
begin
  if Assigned(FDatabase.FOnDecryptProgress) then
    FDatabase.FOnDecryptProgress(FDatabase, Percent);
end;

function TTinyDBFileIO.CheckDupTableName(const TableName: string): Boolean;
var
  TableTab: TTableTab;
  TableHeader: TTableHeader;
  I: Integer;
begin
  Result := False;
  ReadTableTab(TableTab);
  for I := 0 to TableTab.TableCount - 1 do
  begin
    ReadTableHeader(I, TableHeader);
    if StrIComp(TableHeader.TableName, PChar(TableName)) = 0 then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TTinyDBFileIO.CheckDupIndexName(var TableHeader: TTableHeader; const IndexName: string): Boolean;
var
  I: Integer;
begin
  for I := 0 to TableHeader.IndexCount - 1 do
  begin
    if StrIComp(TableHeader.IndexHeader[I].IndexName, PChar(IndexName)) = 0 then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

//-----------------------------------------------------------------------------
// 检查是否有多个Primary索引
// 返回值：有多个则返回True
//-----------------------------------------------------------------------------
function TTinyDBFileIO.CheckDupPrimaryIndex(var TableHeader: TTableHeader; IndexOptions: TTDIndexOptions): Boolean;
var
  I: Integer;
  PriExists: Boolean;
begin
  Result := False;
  if (tiPrimary in IndexOptions) then
  begin
    PriExists := False;
    for I := 0 to TableHeader.IndexCount - 1 do
    begin
      if tiPrimary in TableHeader.IndexHeader[I].IndexOptions then
      begin
        PriExists := True;
        Break;
      end;
    end;
    if PriExists then Result := True;
  end;
end;

procedure TTinyDBFileIO.CheckValidFields(Fields: array of TFieldItem);
var
  I, J: Integer;
  AutoIncFieldCount: Integer; 
begin
  if Length(Fields) >= tdbMaxField then
    DatabaseError(STooManyFields);
  if Length(Fields) = 0 then
    DatabaseError(SFieldNameExpected);

  for I := 0 to High(Fields) do
  begin
    if not (Fields[I].FieldType in TinyDBFieldTypes) then
      DatabaseErrorFmt(SBadFieldType, [Fields[I].FieldName]);
    if not IsValidDBName(Fields[I].FieldName) then
      DatabaseErrorFmt(SInvalidFieldName, [Fields[I].FieldName]);
    if (Fields[I].FieldType in BlobFieldTypes) then
    begin
      if Fields[I].DataSize <> 0 then DatabaseError(SInvalidFieldSize);
    end else if (Fields[I].FieldType in StringFieldTypes) then
    begin
      if (Fields[I].DataSize <= 0) or (Fields[I].DataSize > tdbMaxTextFieldSize) then
        DatabaseError(SInvalidFieldSize);
    end;
  end;
  for I := 0 to High(Fields)-1 do
    for J := I+1 to High(Fields) do
    begin
      if CompareText(Fields[I].FieldName, Fields[J].FieldName) = 0 then
        DatabaseErrorFmt(SDuplicateFieldName, [Fields[I].FieldName]);
    end;

  // 检查是否含有多个AutoInc字段
  AutoIncFieldCount := 0;
  for I := 0 to High(Fields)-1 do
    if Fields[I].FieldType = ftAutoInc then Inc(AutoIncFieldCount);
  if AutoIncFieldCount > 1 then
    DatabaseError(SDuplicateAutoIncField);
end;

procedure TTinyDBFileIO.CheckValidIndexFields(FieldNames: array of string; IndexOptions: TTDIndexOptions; var TableHeader: TTableHeader);
var
  I, J: Integer;
begin
  if Length(FieldNames) = 0 then
    DatabaseError(SFieldNameExpected);
  for I := 0 to High(FieldNames)-1 do
    for J := I+1 to High(FieldNames) do
    begin
      if StrIComp(PChar(FieldNames[I]), PChar(FieldNames[J])) = 0 then
        DatabaseErrorFmt(SDuplicateFieldName, [FieldNames[I]]);
    end;
  for I := 0 to High(FieldNames) do
  begin
    if GetFieldIdxByName(TableHeader, FieldNames[I]) = -1 then
      DatabaseErrorFmt(SFieldNotFound, [FieldNames[I]]);
  end;
end;

function TTinyDBFileIO.GetFieldIdxByName(const TableHeader: TTableHeader; const FieldName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to TableHeader.FieldCount - 1 do
  begin
    if StrIComp(TableHeader.FieldTab[I].FieldName, PChar(FieldName)) = 0 then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TTinyDBFileIO.GetIndexIdxByName(const TableHeader: TTableHeader; const IndexName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to TableHeader.IndexCount - 1 do
  begin
    if StrIComp(TableHeader.IndexHeader[I].IndexName, PChar(IndexName)) = 0 then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TTinyDBFileIO.GetTableIdxByName(const TableName: string): Integer;
var
  TableHeader: TTableHeader;
  I: Integer;
begin
  Result := -1;
  for I := 0 to FTableTab.TableCount - 1 do
  begin
    ReadTableHeader(I, TableHeader);
    if StrIComp(TableHeader.TableName, PChar(TableName)) = 0 then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TTinyDBFileIO.GetTempFileName: string;
var
  Buf: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, Buf);
  Windows.GetTempFileName(Buf, 'TDB', 0, Buf);
  Result := Buf;
end;

function TTinyDBFileIO.ReCreate(NewCompressBlob: Boolean; NewCompressLevel: TCompressLevel; const NewCompressAlgoName: string;
  NewEncrypt: Boolean; const NewEncAlgoName, OldPassword, NewPassword: string; NewCRC32: Boolean): Boolean;
var
  DstTinyDatabase: TTinyDataBase;
  SrcTinyTable, DstTinyTable: TTinyTable;
  DstFileName: string;
  RealNewEncAlgoName: string;
  Comments: string;
  ExtData: TExtData;
  TableHeader: TTableHeader;
  TableIdx, FieldIdx, IndexIdx, RecIdx: Integer;
  I: Integer;
  FieldNames: array of string;
  FieldItems: array of TFieldItem;
  SaveKeepConn: Boolean;
begin
  SaveKeepConn := FDatabase.KeepConnection;
  FDatabase.KeepConnection := True;
  try
    DstTinyDatabase := TTinyDatabase.Create(nil);
    SrcTinyTable := TTinyTable.Create(nil);
    DstTinyTable := TTinyTable.Create(nil);
    try
      DstFileName := GetTempFileName;
      // 调整加密算法
      RealNewEncAlgoName := NewEncAlgoName;
      if NewEncrypt then
        if FEncryptClassList.IndexOf(NewEncAlgoName) = -1 then
          RealNewEncAlgoName := FTinyDBDefaultEncAlgo;
      // 建数据库
      DstTinyDatabase.CreateDatabase(DstFileName, NewCompressBlob, NewCompressLevel, NewCompressAlgoName,
        NewEncrypt, RealNewEncAlgoName, NewPassword, NewCRC32);
      DstTinyDatabase.DatabaseName := DstFileName;
      DstTinyDatabase.Password := NewPassword;
      DstTinyDatabase.Open;
      GetComments(Comments, OldPassword);
      GetExtData(@ExtData);
      DstTinyDatabase.SetComments(Comments);
      DstTinyDatabase.SetExtData(@ExtData, SizeOf(ExtData));

      SrcTinyTable.DatabaseName := FDatabase.DatabaseName;
      for TableIdx := 0 to FTableTab.TableCount - 1 do
      begin
        ReadTableHeader(TableIdx, TableHeader);
        SrcTinyTable.TableName := TableHeader.TableName;
        SrcTinyTable.Password := OldPassword;
        SrcTinyTable.Open;
        // 建表
        SetLength(FieldItems, SrcTinyTable.FieldDefs.Count);
        for I := 0 to SrcTinyTable.FieldDefs.Count - 1 do
        begin
          FieldItems[I].FieldName := SrcTinyTable.FieldDefs[I].Name;
          FieldItems[I].FieldType := SrcTinyTable.FieldDefs[I].DataType;
          FieldItems[I].DataSize := SrcTinyTable.FieldDefs[I].Size;
        end;
        DstTinyDatabase.CreateTable(SrcTinyTable.TableName, FieldItems);
        // 建立索引
        for IndexIdx := 0 to SrcTinyTable.FTableIO.IndexDefs.Count - 1 do
        begin
          if SrcTinyTable.FieldDefs[SrcTinyTable.FTableIO.IndexDefs[IndexIdx].FieldIdxes[0]].DataType = ftAutoInc then Continue;
          SetLength(FieldNames, Length(SrcTinyTable.FTableIO.IndexDefs[IndexIdx].FieldIdxes));
          for FieldIdx := 0 to High(SrcTinyTable.FTableIO.IndexDefs[IndexIdx].FieldIdxes) do
          begin
            I := SrcTinyTable.FTableIO.IndexDefs[IndexIdx].FieldIdxes[FieldIdx];
            FieldNames[FieldIdx] := SrcTinyTable.FieldDefs[I].Name;
          end;
          DstTinyDatabase.CreateIndex(SrcTinyTable.TableName, SrcTinyTable.FTableIO.IndexDefs[IndexIdx].Name,
            SrcTinyTable.FTableIO.IndexDefs[IndexIdx].Options, FieldNames);
        end;
        SrcTinyTable.Close;
      end;

      // 拷贝记录
      DstTinyTable.DatabaseName := DstFileName;
      for TableIdx := 0 to FTableTab.TableCount - 1 do
      begin
        ReadTableHeader(TableIdx, TableHeader);
        SrcTinyTable.TableName := TableHeader.TableName;
        SrcTinyTable.Password := OldPassword;
        SrcTinyTable.Open;
        DstTinyTable.TableName := TableHeader.TableName;
        DstTinyTable.Password := NewPassword;
        DstTinyTable.Open;
        DstTinyTable.BeginUpdate;
        for RecIdx := 0 to SrcTinyTable.RecordCount - 1 do
        begin
          DoOperationProgressEvent(FDatabase, RecIdx + 1, SrcTinyTable.RecordCount);
          DstTinyTable.Append;
          for I := 0 to SrcTinyTable.Fields.Count - 1 do
            DstTinyTable.Fields[I].Value := SrcTinyTable.Fields[I].Value;
          DstTinyTable.Post;
          SrcTinyTable.Next;
        end;
        SrcTinyTable.Close;
        DstTinyTable.EndUpdate;
        DstTinyTable.Close;
      end;
    finally
      DstTinyTable.Free;
      SrcTinyTable.Free;
      DstTinyDatabase.Free;
    end;

    Lock;
    try
      Close;
      try
        Result := CopyFile(PChar(DstFileName), PChar(FDatabaseName), False);
        DeleteFile(DstFileName);
      finally
        Open(FDatabaseName, FMediumType, FExclusive);
      end;
    finally
      Unlock;
    end;
  finally
    FDatabase.KeepConnection := SaveKeepConn;
  end;
end;

procedure TTinyDBFileIO.Open(const ADatabaseName: string; AMediumType: TTinyDBMediumType; AExclusive: Boolean);
var
  DBStream: TStream;
  OpenMode: Word;
begin
  if FDBStream = nil then
  begin
    FMediumType := AMediumType;
    FExclusive := AExclusive;
    case AMediumType of
      mtDisk:
        begin
          if not FileExists(ADatabaseName) then
            DatabaseErrorFmt(SFOpenError, [ADatabaseName]);
          if not CheckValidTinyDB(ADatabaseName) then
            DatabaseErrorFmt(SInvalidDatabase, [ADatabaseName]);
          CheckTinyDBVersion(ADatabaseName);

          FFileIsReadOnly := GetFileAttributes(PChar(ADatabaseName)) and FILE_ATTRIBUTE_READONLY > 0;
          if FFileIsReadOnly then OpenMode := fmOpenRead
          else OpenMode := fmOpenReadWrite;
          if AExclusive then OpenMode := OpenMode or fmShareExclusive
          else OpenMode := OpenMode or fmShareDenyNone;
          FDBStream := TTinyDBFileStream.Create(ADatabaseName, OpenMode);
        end;
      mtMemory:
        begin
          if not IsPointerStr(ADatabaseName) then
            DatabaseErrorFmt(SInvalidDatabaseName, [ADatabaseName]);
          DBStream := StrToPointer(ADatabaseName);
          if not CheckValidTinyDB(DBStream) then
            DatabaseErrorFmt(SInvalidDatabase, [ADatabaseName]);
          CheckTinyDBVersion(DBStream);

          FDBStream := DBStream;
        end;
    end;
    FDatabaseName := ADatabaseName;
    InitDBOptions;
    InitTableTab;
  end;
end;

procedure TTinyDBFileIO.Close;
begin
  if FMediumType = mtDisk then
    FDBStream.Free;
  FDBStream := nil;
  // FDatabaseName := '';
end;

procedure TTinyDBFileIO.Flush;
begin
  if FDBStream is TTinyDBFileStream then
    (FDBStream as TTinyDBFileStream).Flush;
end;

procedure TTinyDBFileIO.InitDBOptions;
begin
  ReadDBOptions(FDBOptions);
  if FDBOptions.CompressBlob then
    FCompressMgr.SetAlgoName(FDBOptions.CompressAlgoName);
  if FDBOptions.Encrypt then
  begin
    FEncryptMgr.SetAlgoName(FDBOptions.EncryptAlgoName);
    FEncryptMgr.Mode := FDBOptions.EncryptMode;
  end;
end;

procedure TTinyDBFileIO.InitTableTab;
begin
  ReadTableTab(FTableTab);
end;

procedure TTinyDBFileIO.DoOperationProgressEvent(ADatabase: TTinyDatabase; Pos, Max: Integer);
begin
  if Assigned(ADatabase.FOnOperationProgress) then
  begin
    if Max = 0 then
      ADatabase.FOnOperationProgress(ADatabase, 0)
    else
      ADatabase.FOnOperationProgress(ADatabase, Round(Pos / Max * 100));
  end;
end;

function TTinyDBFileIO.SetPassword(const Value: string): Boolean;
begin
  Result := False;
  if not IsOpen then Exit;

  if FDBOptions.Encrypt then
  begin
    if Hash(FTinyDBCheckPwdHashClass, Value) =
      AnsiString(FDBOptions.HashPassword) then
    begin
      FEncryptMgr.InitKey(Value);
      Result := True;
    end else
    begin
      Result := False;
    end;
  end else
    Result := True;
end;

procedure TTinyDBFileIO.Lock;
var
  LockWaitTime, LockRetryCount: Integer;
  RetryCount: Integer;
begin
  if not IsOpen then Exit;

  LockRetryCount := FDatabase.Session.LockRetryCount;
  LockWaitTime := FDatabase.Session.LockWaitTime;

  case FMediumType of
    mtMemory:
      begin
      end;
    mtDisk:
      begin
        RetryCount := 0;
        while not LockFile((FDBStream as TFileStream).Handle, 1, 0, 1, 0) do
        begin
          Inc(RetryCount);
          if (LockRetryCount <> 0) and (RetryCount > LockRetryCount) then
          begin
            DatabaseError(SWaitForUnlockTimeOut);
          end;
          Sleep(LockWaitTime);
        end;
      end;
  end;
end;

procedure TTinyDBFileIO.Unlock;
begin
  if not IsOpen then Exit;

  case FMediumType of
    mtMemory:
      begin
      end;
    mtDisk:
      begin
        UnlockFile((FDBStream as TFileStream).Handle, 1, 0, 1, 0);
      end;
  end;
end;

procedure TTinyDBFileIO.ReadBuffer(var Buffer; Position, Count: Longint);
begin
  FDBStream.Position := Position;
  FDBStream.Read(Buffer, Count);
end;

procedure TTinyDBFileIO.ReadDBVersion(var Dest: string);
var
  FileHeader: TFileHeader;
begin
  FDBStream.Position := 0;
  FDBStream.Read(FileHeader, SizeOf(FileHeader));
  Dest := FileHeader.FileFmtVer;
end;

procedure TTinyDBFileIO.ReadExtDataBlock(var Dest: TExtDataBlock);
begin
  FDBStream.Position := SizeOf(TFileHeader);
  FDBStream.Read(Dest, SizeOf(Dest));
end;

procedure TTinyDBFileIO.WriteExtDataBlock(var Dest: TExtDataBlock);
begin
  FDBStream.Position := SizeOf(TFileHeader);
  FDBStream.Write(Dest, SizeOf(Dest));
end;

procedure TTinyDBFileIO.ReadDBOptions(var Dest: TDBOptions);
begin
  FDBStream.Position := SizeOf(TFileHeader) + SizeOf(TExtDataBlock);
  FDBStream.Read(Dest, SizeOf(Dest));
end;

procedure TTinyDBFileIO.WriteDBOptions(var Dest: TDBOptions);
begin
  FDBStream.Position := SizeOf(TFileHeader) + SizeOf(TExtDataBlock);
  FDBStream.Write(Dest, SizeOf(Dest));
end;

procedure TTinyDBFileIO.ReadTableTab(var Dest: TTableTab);
begin
  FDBStream.Position := SizeOf(TFileHeader) + SizeOf(TExtDataBlock) + SizeOf(TDBOptions);
  FDBStream.Read(Dest, SizeOf(Dest));
end;

procedure TTinyDBFileIO.WriteTableTab(var Dest: TTableTab);
begin
  FDBStream.Position := SizeOf(TFileHeader) + SizeOf(TExtDataBlock) + SizeOf(TDBOptions);
  FDBStream.Write(Dest, SizeOf(Dest));
end;

procedure TTinyDBFileIO.ReadTableHeader(TableIdx: Integer; var Dest: TTableHeader);
begin
  FDBStream.Position := FTableTab.TableHeaderOffset[TableIdx];
  FDBStream.Read(Dest, SizeOf(Dest));
end;

procedure TTinyDBFileIO.WriteTableHeader(TableIdx: Integer; var Dest: TTableHeader);
begin
  FDBStream.Position := FTableTab.TableHeaderOffset[TableIdx];
  FDBStream.Write(Dest, SizeOf(Dest));
end;

class function TTinyDBFileIO.CheckValidTinyDB(ADBStream: TStream): Boolean;
var
  FileHeader: TFileHeader;
begin
  ADBStream.Position := 0;
  ADBStream.Read(FileHeader, SizeOf(FileHeader));
  if FileHeader.SoftName = tdbSoftName then Result := True
  else Result := False;
end;

class function TTinyDBFileIO.CheckValidTinyDB(const FileName: string): Boolean;
var
  DBStream: TStream;
begin
  DBStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := CheckValidTinyDB(DBStream);
  finally
    DBStream.Free;
  end;
end;

class function TTinyDBFileIO.CheckTinyDBVersion(ADBStream: TStream): Boolean;
const
  tdbFileFmtVer100 = '1.00';
var
  FileHeader: TFileHeader;
begin
  ADBStream.Position := 0;
  ADBStream.Read(FileHeader, SizeOf(FileHeader));

  if FileHeader.FileFmtVer = tdbFileFmtVer100 then
    DatabaseError(SInvalidVersion100);

  if FileHeader.FileFmtVer > tdbFileFmtVer then
    DatabaseError(SInvalidVersionTooHigh);

  Result := True;
end;

class function TTinyDBFileIO.CheckTinyDBVersion(const FileName: string): Boolean;
var
  DBStream: TStream;
begin
  DBStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := CheckTinyDBVersion(DBStream);
  finally
    DBStream.Free;
  end;
end;

procedure TTinyDBFileIO.GetTableNames(List: TStrings);
var
  I: Integer;
  TableHeader: TTableHeader;
begin
  List.BeginUpdate;
  List.Clear;
  for I := 0 to FTableTab.TableCount - 1 do
  begin
    ReadTableHeader(I, TableHeader);
    List.Add(TableHeader.TableName);
  end;
  List.EndUpdate;
end;

procedure TTinyDBFileIO.GetFieldNames(const TableName: string; List: TStrings);
var
  I, J: Integer;
  TableHeader: TTableHeader;
begin
  List.BeginUpdate;
  List.Clear;
  for I := 0 to FTableTab.TableCount - 1 do
  begin
    ReadTableHeader(I, TableHeader);
    if CompareText(TableName, TableHeader.TableName) = 0 then
    begin
      for J := 0 to TableHeader.FieldCount - 1 do
        List.Add(TableHeader.FieldTab[J].FieldName);
    end;
  end;
  List.EndUpdate;
end;

procedure TTinyDBFileIO.GetIndexNames(const TableName: string; List: TStrings);
var
  I, J: Integer;
  TableHeader: TTableHeader;
begin
  List.BeginUpdate;
  List.Clear;
  for I := 0 to FTableTab.TableCount - 1 do
  begin
    ReadTableHeader(I, TableHeader);
    if CompareText(TableName, TableHeader.TableName) = 0 then
    begin
      for J := 0 to TableHeader.IndexCount - 1 do
        List.Add(TableHeader.IndexHeader[J].IndexName);
    end;
  end;
  List.EndUpdate;
end;

procedure TTinyDBFileIO.ReadFieldData(DstStream: TMemoryStream; RecTabItemOffset, DiskFieldOffset, FieldSize: Integer;
  IsBlob: Boolean; ShouldEncrypt, ShouldCompress: Boolean);
var
  RecTabItem: TRecordTabItem;
  FieldDataOffset: Integer;
begin
  FDBStream.Position := RecTabItemOffset;
  FDBStream.Read(RecTabItem, SizeOf(RecTabItem));
  FieldDataOffset := RecTabItem.DataOffset + DiskFieldOffset;
  ReadFieldData(DstStream, FieldDataOffset, FieldSize, IsBlob, ShouldEncrypt, ShouldCompress);
end;

procedure TTinyDBFileIO.ReadFieldData(DstStream: TMemoryStream; FieldDataOffset, FieldSize: Integer;
  IsBlob: Boolean; ShouldEncrypt, ShouldCompress: Boolean);
var
  RecBuf: array of Char;
  BlobOffset, BlobSize: Integer;
  TmpStream: TMemoryStream;
begin
  TmpStream := TMemoryStream.Create;
  try
    // 读取字段数据
    FDBStream.Position := FieldDataOffset;
    // 如果是BLOB字段
    if IsBlob then
    begin
      SetLength(RecBuf, FieldSize);
      FDBStream.Read(RecBuf[0], FieldSize);
      BlobOffset := PBlobFieldHeader(@RecBuf[0])^.DataOffset;
      BlobSize := PBlobFieldHeader(@RecBuf[0])^.DataSize;
      FDBStream.Position := BlobOffset;
      TmpStream.SetSize(BlobSize);
      FDBStream.Read(TmpStream.Memory^, BlobSize);
      SetLength(RecBuf, 0);
    end else
    // 如果不是BLOB字段
    begin
      TmpStream.SetSize(FieldSize);
      FDBStream.Read(TmpStream.Memory^, FieldSize);
    end;

    // 解码
    DecodeMemoryStream(TmpStream, DstStream, ShouldEncrypt, ShouldCompress);
  finally
    TmpStream.Free;
  end;
end;

//-----------------------------------------------------------------------------
// 读入所有的RecTab到Items中，并把每块的偏移存入BlockOffsets中
//-----------------------------------------------------------------------------
procedure TTinyDBFileIO.ReadAllRecordTabItems(const TableHeader: TTableHeader;
  var Items: TRecordTabItems; var BlockOffsets: TIntegerAry);
var
  ReadCount, Count: Integer;
  NextOffset: Integer;
  BlockCount, BlockIdx: Integer;
begin
  FDBStream.Position := TableHeader.RecTabOffset;
  BlockCount := TableHeader.RecordTotal div tdbRecTabUnitNum;
  if TableHeader.RecordTotal mod tdbRecTabUnitNum > 0 then Inc(BlockCount);
  SetLength(BlockOffsets, BlockCount);
  SetLength(Items, TableHeader.RecordTotal);
  ReadCount := 0;
  BlockIdx := 0;
  while ReadCount < TableHeader.RecordTotal do
  begin
    BlockOffsets[BlockIdx] := FDBStream.Position;
    Inc(BlockIdx);
    Count := TableHeader.RecordTotal - ReadCount;
    if Count > tdbRecTabUnitNum then Count := tdbRecTabUnitNum;
    FDBStream.Read(NextOffset, SizeOf(Integer));
    FDBStream.Read(Items[ReadCount], SizeOf(TRecordTabItem)*Count);
    FDBStream.Position := NextOffset;
    Inc(ReadCount, Count);
  end;
end;

//-----------------------------------------------------------------------------
// 读入索引号为IndexIdx的索引的所有IndexTab到Items中，并把每块的偏移存入BlockOffsets中
//-----------------------------------------------------------------------------
procedure TTinyDBFileIO.ReadAllIndexTabItems(const TableHeader: TTableHeader; IndexIdx: Integer;
  var Items: TIndexTabItems; var BlockOffsets: TIntegerAry);
var
  ReadCount, Count: Integer;
  NextOffset: Integer;
  BlockCount, BlockIdx: Integer;
begin
  FDBStream.Position := TableHeader.IndexHeader[IndexIdx].IndexOffset;
  BlockCount := TableHeader.RecordTotal div tdbIdxTabUnitNum;
  if TableHeader.RecordTotal mod tdbIdxTabUnitNum > 0 then Inc(BlockCount);
  SetLength(BlockOffsets, BlockCount);
  SetLength(Items, TableHeader.RecordTotal);
  ReadCount := 0;
  BlockIdx := 0;
  while ReadCount < TableHeader.RecordTotal do
  begin
    BlockOffsets[BlockIdx] := FDBStream.Position;
    Inc(BlockIdx);
    Count := TableHeader.RecordTotal - ReadCount;
    if Count > tdbIdxTabUnitNum then Count := tdbIdxTabUnitNum;
    FDBStream.Read(NextOffset, SizeOf(Integer));
    FDBStream.Read(Items[ReadCount], SizeOf(TIndexTabItem)*Count);
    FDBStream.Position := NextOffset;
    Inc(ReadCount, Count);
  end;
end;

//-----------------------------------------------------------------------------
// 在数据库中做删除标记
// RecordIdx: 记录号 0-based
//-----------------------------------------------------------------------------
procedure TTinyDBFileIO.WriteDeleteFlag(RecTabItemOffset: Integer);
var
  RecTabItem: TRecordTabItem;
  BakFilePos: Integer;
begin
  // 移至要做标记的位置
  FDBStream.Position := RecTabItemOffset;
  BakFilePos := FDBStream.Position;
  FDBStream.Read(RecTabItem, SizeOf(RecTabItem));
  RecTabItem.DeleteFlag := True;
  FDBStream.Position := BakFilePos;
  FDBStream.Write(RecTabItem, SizeOf(RecTabItem));
end;

function TTinyDBFileIO.CreateDatabase(const DBFileName: string;
  CompressBlob: Boolean; CompressLevel: TCompressLevel; const CompressAlgoName: string;
  Encrypt: Boolean; const EncryptAlgoName, Password: string; CRC32: Boolean = False): Boolean;
var
  DBStream: TStream;
  FileHeader: TFileHeader;
  ExtDataBlock: TExtDataBlock;
  DBOptions: TDBOptions;
  TableTab: TTableTab;
begin
  Result := True;
  FillChar(FileHeader, SizeOf(FileHeader), 0);
  StrCopy(PChar(@FileHeader.SoftName), tdbSoftName);
  StrCopy(PChar(@FileHeader.FileFmtVer), tdbFileFmtVer);
  FillChar(ExtDataBlock, SizeOf(ExtDataBlock), 0);
  if Encrypt then
    EncryptBuffer(ExtDataBlock.Comments, SizeOf(ExtDataBlock.Comments), EncryptAlgoName, FTinyDBDefaultEncMode, Password);
  FillChar(DBOptions, SizeOf(DBOptions), 0);
  RandomFillBuffer(DBOptions.RandomBuffer, SizeOf(DBOptions.RandomBuffer), 20, 122);

  DBOptions.CompressBlob := CompressBlob;
  DBOptions.CompressLevel := CompressLevel;
  StrLCopy(DBOptions.CompressAlgoName, PChar(CompressAlgoName), tdbMaxAlgoNameChar);
  DBOptions.Encrypt := Encrypt;
  StrLCopy(DBOptions.EncryptAlgoName, PChar(EncryptAlgoName), tdbMaxAlgoNameChar);
  DBOptions.EncryptMode := FTinyDBDefaultEncMode;
  StrLCopy(DBOptions.HashPassword, PChar(Hash(FTinyDBCheckPwdHashClass, Password)), tdbMaxHashPwdSize);
  DBOptions.CRC32 := CRC32;

  FillChar(TableTab, SizeOf(TableTab), 0);
  TableTab.TableCount := 0;

  try
    case FMediumType of
      mtDisk:
        DBStream := TFileStream.Create(DBFileName, fmCreate or fmShareDenyNone);
      mtMemory:
        DBStream := StrToPointer(DBFileName);
      else
        DBStream := nil;
    end;
    try
      DBStream.Write(FileHeader, SizeOf(FileHeader));
      DBStream.Write(ExtDataBlock, SizeOf(ExtDataBlock));
      DBStream.Write(DBOptions, SizeOf(DBOptions));
      DBStream.Write(TableTab, SizeOf(TableTab));
    finally
      if FMediumType = mtDisk then
        DBStream.Free;
    end;
  except
    Result := False;
  end;
end;

function TTinyDBFileIO.CreateTable(const TableName: string; Fields: array of TFieldItem): Boolean;
var
  TableHeader: TTableHeader;
  I, AutoIncFieldIdx: Integer;
  AutoIncFieldName: string;
begin
  if not IsValidDBName(TableName) then
    DatabaseErrorFmt(SInvalidTableName, [TableName]);

  Lock;
  try
    CheckValidFields(Fields);

    AutoIncFieldIdx := -1;
    ReadTableTab(FTableTab);
    if FTableTab.TableCount >= tdbMaxTable then
      DatabaseError(STooManyTables);
    if CheckDupTableName(TableName) then
      DatabaseErrorFmt(SDuplicateTableName, [TableName]);
    Inc(FTableTab.TableCount);
    FTableTab.TableHeaderOffset[FTableTab.TableCount-1] := FDBStream.Size;
    WriteTableTab(FTableTab);

    FillChar(TableHeader, SizeOf(TableHeader), 0);
    StrLCopy(TableHeader.TableName, PChar(TableName), tdbMaxTableNameChar);
    TableHeader.RecTabOffset := 0;
    TableHeader.RecordTotal := 0;
    TableHeader.AutoIncCounter := 0;
    TableHeader.FieldCount := Length(Fields);
    for I := 0 to High(Fields) do
    begin
      if Fields[I].FieldType = ftAutoInc then AutoIncFieldIdx := I;
      StrLCopy(TableHeader.FieldTab[I].FieldName, PChar(string(Fields[I].FieldName)), tdbMaxFieldNameChar);
      TableHeader.FieldTab[I].FieldType := Fields[I].FieldType;
      if Fields[I].FieldType in StringFieldTypes then
        TableHeader.FieldTab[I].FieldSize := Fields[I].DataSize
      else
        TableHeader.FieldTab[I].FieldSize := 0;
      TableHeader.FieldTab[I].DPMode := Fields[I].DPMode;
    end;
    TableHeader.IndexCount := 0;
    FDBStream.Seek(0, soFromEnd);
    FDBStream.Write(TableHeader, SizeOf(TableHeader));
    Result := True;
  finally
    Unlock;
  end;

  if AutoIncFieldIdx <> -1 then
  begin
    AutoIncFieldName := Fields[AutoIncFieldIdx].FieldName;
    Result := CreateIndex(TableName, AutoIncFieldName, [tiPrimary], [AutoIncFieldName]);
    if not Result then DeleteTable(TableName);
  end;
end;

function TTinyDBFileIO.DeleteTable(const TableName: string): Boolean;
var
  TableHeader: TTableHeader;
  I, TableIdx: Integer;
begin
  if not IsValidDBName(TableName) then
    DatabaseErrorFmt(SInvalidTableName, [TableName]);

  Lock;
  try
    ReadTableTab(FTableTab);
    // 查找要删除的表号
    TableIdx := GetTableIdxByName(TableName);
    if TableIdx <> -1 then
      ReadTableHeader(TableIdx, TableHeader);
    if TableIdx = -1 then
      DatabaseErrorFmt(STableNotFound, [TableName]);
    // 删除表偏移信息
    for I := TableIdx to FTableTab.TableCount - 2 do
      FTableTab.TableHeaderOffset[I] := FTableTab.TableHeaderOffset[I + 1];
    // 表总数减一
    Dec(FTableTab.TableCount);
    // 写回数据库
    WriteTableTab(FTableTab);
    Result := True;
  finally
    Unlock;
  end;
end;

function TTinyDBFileIO.CreateIndex(const TableName, IndexName: string; IndexOptions: TTDIndexOptions; FieldNames: array of string): Boolean;
var
  TableHeader: TTableHeader;
  I: Integer;
  TableIdx, IndexIdx, FieldIdx: Integer;
begin
  if not IsValidDBName(TableName) then
    DatabaseErrorFmt(SInvalidTableName, [TableName]);
  if not IsValidDBName(IndexName) then
    DatabaseErrorFmt(SInvalidIndexName, [IndexName]);

  Lock;
  try
    ReadTableTab(FTableTab);
    // 取得TableName对应的TableIdx
    TableIdx := GetTableIdxByName(TableName);
    if TableIdx <> -1 then
      ReadTableHeader(TableIdx, TableHeader);
    // 合法检查
    if TableIdx = -1 then
      DatabaseErrorFmt(STableNotFound, [TableName]);
    if TableHeader.IndexCount >= tdbMaxIndex then
      DatabaseError(STooManyIndexes);
    if CheckDupIndexName(TableHeader, IndexName) then
      DatabaseErrorFmt(SDuplicateIndexName, [IndexName]);
    if CheckDupPrimaryIndex(TableHeader, IndexOptions) then
      DatabaseError(SDuplicatePrimaryIndex);
    if TableHeader.RecordTotal > 0 then
      DatabaseError(SFailToCreateIndex);
    CheckValidIndexFields(FieldNames, IndexOptions, TableHeader);

    // 修改TableHeader
    IndexIdx := TableHeader.IndexCount;
    Inc(TableHeader.IndexCount);
    StrLCopy(TableHeader.IndexHeader[IndexIdx].IndexName, PChar(IndexName), tdbMaxIndexNameChar);
    TableHeader.IndexHeader[IndexIdx].IndexOptions := IndexOptions;
    for I := 0 to tdbMaxMultiIndexFields - 1 do
    begin
      if I <= High(FieldNames) then
        FieldIdx := GetFieldIdxByName(TableHeader, FieldNames[I])
      else
        FieldIdx := -1;
      TableHeader.IndexHeader[IndexIdx].FieldIdx[I] := FieldIdx;
    end;
    TableHeader.IndexHeader[IndexIdx].IndexOffset := DBStream.Size;
    TableHeader.IndexHeader[IndexIdx].StartIndex := 0;
    // 回写TableHeader
    WriteTableHeader(TableIdx, TableHeader);
    Result := True;
  finally
    Unlock;
  end;
end;

function TTinyDBFileIO.DeleteIndex(const TableName, IndexName: string): Boolean;
var
  TableHeader: TTableHeader;
  I: Integer;
  TableIdx, IndexIdx: Integer;
begin
  if not IsValidDBName(TableName) then
    DatabaseErrorFmt(SInvalidTableName, [TableName]);
  if not IsValidDBName(IndexName) then
    DatabaseErrorFmt(SInvalidIndexName, [IndexName]);

  Lock;
  try
    ReadTableTab(FTableTab);
    // 取得TableName对应的TableIdx
    TableIdx := GetTableIdxByName(TableName);
    if TableIdx <> -1 then
      ReadTableHeader(TableIdx, TableHeader);
    // 合法检查
    if TableIdx = -1 then
      DatabaseErrorFmt(STableNotFound, [TableName]);

    // 取得IndexName对应的IndexIdx
    IndexIdx := GetIndexIdxByName(TableHeader, IndexName);
    // 合法检查
    if IndexIdx = -1 then
      DatabaseErrorFmt(SIndexNotFound, [IndexName]);
    // 删除索引信息
    for I := IndexIdx to TableHeader.IndexCount - 2 do
      TableHeader.IndexHeader[I] := TableHeader.IndexHeader[I + 1];
    // 索引数目减一
    Dec(TableHeader.IndexCount);
    // 回写TableHeader
    WriteTableHeader(TableIdx, TableHeader);
    Result := True;
  finally
    Unlock;
  end;
end;

function TTinyDBFileIO.RenameTable(const OldTableName, NewTableName: string): Boolean;
var
  TableHeader: TTableHeader;
  I, TableIdx: Integer;
begin
  if not IsValidDBName(NewTableName) then
    DatabaseErrorFmt(SInvalidTableName, [NewTableName]);

  Lock;
  try
    ReadTableTab(FTableTab);
    // 查找要改名的表号
    TableIdx := GetTableIdxByName(OldTableName);
    if TableIdx <> -1 then
      ReadTableHeader(TableIdx, TableHeader);
    if TableIdx = -1 then
      DatabaseErrorFmt(STableNotFound, [OldTableName]);
    I := GetTableIdxByName(NewTableName);
    if (I <> -1) and (I <> TableIdx) then
      DatabaseErrorFmt(SDuplicateTableName, [NewTableName]);
    // 写回数据库
    StrLCopy(TableHeader.TableName, PChar(NewTableName), tdbMaxTableNameChar);
    WriteTableHeader(TableIdx, TableHeader);
    Result := True;
  finally
    Unlock;
  end;
end;

function TTinyDBFileIO.RenameField(const TableName, OldFieldName, NewFieldName: string): Boolean;
var
  TableHeader: TTableHeader;
  I, TableIdx, FieldIdx: Integer;
begin
  if not IsValidDBName(NewFieldName) then
    DatabaseErrorFmt(SInvalidFieldName, [NewFieldName]);

  Lock;
  try
    ReadTableTab(FTableTab);
    // 查找要改字段名的表号
    TableIdx := GetTableIdxByName(TableName);
    if TableIdx = -1 then
      DatabaseErrorFmt(STableNotFound, [TableName]);
    ReadTableHeader(TableIdx, TableHeader);
    // 取得要修改的字段号
    FieldIdx := GetFieldIdxByName(TableHeader, OldFieldName);
    if FieldIdx = -1 then
      DatabaseErrorFmt(SFieldNotFound, [OldFieldName]);
    I := GetFieldIdxByName(TableHeader, NewFieldName);
    if (I <> -1) and (I <> FieldIdx) then
      DatabaseErrorFmt(SDuplicateFieldName, [NewFieldName]);
    // 写回数据库
    StrLCopy(TableHeader.FieldTab[FieldIdx].FieldName, PChar(NewFieldName), tdbMaxFieldNameChar);
    WriteTableHeader(TableIdx, TableHeader);
    Result := True;
  finally
    Unlock;
  end;
end;

function TTinyDBFileIO.RenameIndex(const TableName, OldIndexName, NewIndexName: string): Boolean;
var
  TableHeader: TTableHeader;
  I, TableIdx, IndexIdx: Integer;
begin
  if not IsValidDBName(NewIndexName) then
    DatabaseErrorFmt(SInvalidIndexName, [NewIndexName]);

  Lock;
  try
    ReadTableTab(FTableTab);
    // 查找要改索引名的表号
    TableIdx := GetTableIdxByName(TableName);
    if TableIdx = -1 then
      DatabaseErrorFmt(STableNotFound, [TableName]);
    ReadTableHeader(TableIdx, TableHeader);
    // 取得要修改的索引号
    IndexIdx := GetIndexIdxByName(TableHeader, OldIndexName);
    if IndexIdx = -1 then
      DatabaseErrorFmt(SIndexNotFound, [OldIndexName]);
    I := GetIndexIdxByName(TableHeader, NewIndexName);
    if (I <> -1) and (I <> IndexIdx) then
      DatabaseErrorFmt(SDuplicateIndexName, [NewIndexName]);
    // 写回数据库
    StrLCopy(TableHeader.IndexHeader[IndexIdx].IndexName, PChar(NewIndexName), tdbMaxIndexNameChar);
    WriteTableHeader(TableIdx, TableHeader);
    Result := True;
  finally
    Unlock;
  end;
end;

function TTinyDBFileIO.Compact(const Password: string): Boolean;
begin
  Result := ReCreate(FDBOptions.CompressBlob, FDBOptions.CompressLevel, FDBOptions.CompressAlgoName,
    FDBOptions.Encrypt, FDBOptions.EncryptAlgoName, Password, Password, FDBOptions.CRC32);
end;

function TTinyDBFileIO.Repair(const Password: string): Boolean;
begin
  Result := ReCreate(FDBOptions.CompressBlob, FDBOptions.CompressLevel, FDBOptions.CompressAlgoName,
    FDBOptions.Encrypt, FDBOptions.EncryptAlgoName, Password, Password, FDBOptions.CRC32);
end;

function TTinyDBFileIO.ChangePassword(const OldPassword, NewPassword: string; Check: Boolean = True): Boolean;
begin
  Result := ReCreate(FDBOptions.CompressBlob, FDBOptions.CompressLevel, FDBOptions.CompressAlgoName,
    Check, FDBOptions.EncryptAlgoName, OldPassword, NewPassword, FDBOptions.CRC32);
end;

function TTinyDBFileIO.ChangeEncrypt(NewEncrypt: Boolean; const NewEncAlgo, OldPassword, NewPassword: string): Boolean;
begin
  Result := ReCreate(FDBOptions.CompressBlob, FDBOptions.CompressLevel, FDBOptions.CompressAlgoName,
    NewEncrypt, NewEncAlgo, OldPassword, NewPassword, FDBOptions.CRC32);
end;

function TTinyDBFileIO.SetComments(const Value: string; const Password: string): Boolean;
var
  ExtDataBlock: TExtDataBlock;
begin
  Lock;
  try
    Result := True;
    try
      ReadExtDataBlock(ExtDataBlock);
      if FDBOptions.Encrypt then
        DecryptBuffer(ExtDataBlock.Comments, SizeOf(ExtDataBlock.Comments), FDBOptions.EncryptAlgoName, FTinyDBDefaultEncMode, Password);
      StrLCopy(ExtDataBlock.Comments, PChar(Value), tdbMaxCommentsChar);
      if FDBOptions.Encrypt then
        EncryptBuffer(ExtDataBlock.Comments, SizeOf(ExtDataBlock.Comments), FDBOptions.EncryptAlgoName, FTinyDBDefaultEncMode, Password);
      WriteExtDataBlock(ExtDataBlock);
    except
      Result := False;
    end;
  finally
    Unlock;
  end;
end;

function TTinyDBFileIO.GetComments(var Value: string; const Password: string): Boolean;
var
  ExtDataBlock: TExtDataBlock;
begin
  Lock;
  try
    Result := True;
    try
      ReadExtDataBlock(ExtDataBlock);
      if FDBOptions.Encrypt then
        DecryptBuffer(ExtDataBlock.Comments, SizeOf(ExtDataBlock.Comments), FDBOptions.EncryptAlgoName, FTinyDBDefaultEncMode, Password);
      Value := AnsiString(ExtDataBlock.Comments);
    except
      Result := False;
    end;
  finally
    Unlock;
  end;
end;

function TTinyDBFileIO.SetExtData(Buffer: PChar; Size: Integer): Boolean;
var
  ExtDataBlock: TExtDataBlock;
begin
  Lock;
  try
    Result := True;
    try
      ReadExtDataBlock(ExtDataBlock);
      FillChar(ExtDataBlock.Data[0], SizeOf(ExtDataBlock.Data), 0);
      if Size > SizeOf(ExtDataBlock.Data) then
        Size := SizeOf(ExtDataBlock.Data);
      Move(Buffer^, ExtDataBlock.Data[0], Size);
      WriteExtDataBlock(ExtDataBlock);
    except
      Result := False;
    end;
  finally
    Unlock;
  end;
end;

function TTinyDBFileIO.GetExtData(Buffer: PChar): Boolean;
var
  ExtDataBlock: TExtDataBlock;
begin
  Lock;
  try
    Result := True;
    try
      ReadExtDataBlock(ExtDataBlock);
      Move(ExtDataBlock.Data[0], Buffer^, SizeOf(ExtDataBlock.Data));
    except
      Result := False;
    end;
  finally
    Unlock;
  end;
end;

{ TTinyTableIO }

constructor TTinyTableIO.Create(AOwner: TTinyDatabase);
begin
  FDatabase := AOwner;
  FTableIdx := -1;
  FIndexDefs := TTinyIndexDefs.Create(AOwner);
  FFieldDefs := TTinyFieldDefs.Create(AOwner);
end;

destructor TTinyTableIO.Destroy;
begin
  Finalize;
  FIndexDefs.Free;
  FFieldDefs.Free;
  inherited;
end;

procedure TTinyTableIO.SetActive(Value: Boolean);
begin
  if Value <> Active then
  begin
    if Value then Open
    else Close;
  end;
end;

procedure TTinyTableIO.SetTableName(const Value: string);
begin
  FTableName := Value;
end;

function TTinyTableIO.GetActive: Boolean;
begin
  Result := FRefCount > 0;
end;

function TTinyTableIO.GetRecTabList(Index: Integer): TList;
begin
  Result := FRecTabLists[Index];
end;

function TTinyTableIO.GetTableIdxByName(const TableName: string): Integer;
var
  List: TStrings;
begin
  List := TStringList.Create;
  try
    FDatabase.GetTableNames(List);
    Result := List.IndexOf(TableName);
  finally
    List.Free;
  end;
end;

procedure TTinyTableIO.InitFieldDefs;
var
  I: Integer;
  FieldDefItem: TTinyFieldDef;
begin
  FFieldDefs.Clear;
  for I := 0 to FTableHeader.FieldCount - 1 do
  begin
    FieldDefItem := TTinyFieldDef(FFieldDefs.Add);
    FieldDefItem.Name := FTableHeader.FieldTab[I].FieldName;
    FieldDefItem.FFieldType := FTableHeader.FieldTab[I].FieldType;
    FieldDefItem.FFieldSize := FTableHeader.FieldTab[I].FieldSize;
    FieldDefItem.FDPMode := FTableHeader.FieldTab[I].DPMode;
  end;
end;

procedure TTinyTableIO.InitIndexDefs;
var
  I, K: Integer;
  IdxFieldCount: Integer;
  IndexDefItem: TTinyIndexDef;
begin
  FIndexDefs.Clear;
  for I := 0 to FTableHeader.IndexCount - 1 do
  begin
    IndexDefItem := TTinyIndexDef(FIndexDefs.Add);
    IndexDefItem.Name := FTableHeader.IndexHeader[I].IndexName;
    IndexDefItem.Options := FTableHeader.IndexHeader[I].IndexOptions;
    IdxFieldCount := 0;
    for K := 0 to tdbMaxMultiIndexFields - 1 do
    begin
      if FTableHeader.IndexHeader[I].FieldIdx[K] = -1 then Break;
      Inc(IdxFieldCount);
    end;
    SetLength(IndexDefItem.FFieldIdxes, IdxFieldCount);
    for K := 0 to tdbMaxMultiIndexFields - 1 do
    begin
      if FTableHeader.IndexHeader[I].FieldIdx[K] = -1 then Break;
      IndexDefItem.FFieldIdxes[K] := FTableHeader.IndexHeader[I].FieldIdx[K];
    end;
  end;
end;

procedure TTinyTableIO.InitRecTabList(ListIdx: Integer; ReadRecTabItems: Boolean);
var
  IndexTab: TIndexTabItems;
  MemRecTabItem: TMemRecTabItem;
  IndexOffset, RecordTotal: Integer;
  IndexIdx, Count, I: Integer;
begin
  if FRecTabLists[ListIdx] <> nil then Exit;

  if ReadRecTabItems then
    FDatabase.DBFileIO.ReadAllRecordTabItems(FTableHeader, FInitRecordTab, FRecTabBlockOffsets);

  RecordTotal := FTableHeader.RecordTotal;
  FRecTabLists[ListIdx] := TList.Create;
  IndexIdx := ListIdx - 1;
  // 初始化物理顺序的记录集指针
  if IndexIdx = -1 then
  begin
    for I := 0 to High(FInitRecordTab) do
    begin
      if not FInitRecordTab[I].DeleteFlag then
      begin
        MemRecTabItem.DataOffset := FInitRecordTab[I].DataOffset;
        MemRecTabItem.RecIndex := I;
        AddMemRecTabItem(FRecTabLists[ListIdx], MemRecTabItem);
      end;
    end;
  end else
  // 初始化索引
  begin
    IndexOffset := FTableHeader.IndexHeader[IndexIdx].IndexOffset;
    if IndexOffset <> 0 then
    begin
      // 将索引数据读入
      FDatabase.DBFileIO.ReadAllIndexTabItems(FTableHeader, IndexIdx, IndexTab, FIdxTabBlockOffsets[IndexIdx]);
      // 按链表顺序依此整理到FRecTabLists[ListIdx]中
      Count := 0;
      I := FTableHeader.IndexHeader[IndexIdx].StartIndex;
      while (I <> -1) and (Count < RecordTotal) do
      begin
        // 标有删除标记的记录不读进FIdxTabLists
        if not FInitRecordTab[I].DeleteFlag then
        begin
          MemRecTabItem.DataOffset := FInitRecordTab[I].DataOffset;
          MemRecTabItem.RecIndex := I;
          AddMemRecTabItem(FRecTabLists[ListIdx], MemRecTabItem);
        end;
        Inc(Count);
        I := IndexTab[I].Next;
      end;
    end;
  end;
end;

procedure TTinyTableIO.InitAllRecTabLists;
var
  ListIdx, IndexCount: Integer;
begin
  FDatabase.DBFileIO.ReadAllRecordTabItems(FTableHeader, FInitRecordTab, FRecTabBlockOffsets);

  IndexCount := FTableHeader.IndexCount;
  SetLength(FRecTabLists, IndexCount + 1);

  for ListIdx := 0 to High(FRecTabLists) do
  begin
    InitRecTabList(ListIdx, False);
  end;
end;

procedure TTinyTableIO.InitDiskRecInfo;
var
  I: Integer;
  FieldType: TFieldType;
begin
  // 初始化FDiskRecSize
  FDiskRecSize := 0;
  SetLength(FDiskFieldOffsets, FTableHeader.FieldCount);
  for I := 0 to FTableHeader.FieldCount - 1 do
  begin
    FDiskFieldOffsets[I] := FDiskRecSize;
    FieldType := FTableHeader.FieldTab[I].FieldType;
    if FieldType in BlobFieldTypes then
      Inc(FDiskRecSize, SizeOf(TBlobFieldHeader))
    else
      Inc(FDiskRecSize, GetFieldSize(FieldType, FTableHeader.FieldTab[I].FieldSize));
  end;
end;

procedure TTinyTableIO.InitAutoInc;
var
  I: Integer;
  FieldType: TFieldType;
begin
  FAutoIncFieldIdx := -1;
  for I := 0 to FTableHeader.FieldCount - 1 do
  begin
    FieldType := FTableHeader.FieldTab[I].FieldType;
    if FieldType = ftAutoInc then
    begin
      FAutoIncFieldIdx := I;
      Break;
    end;
  end;
end;

procedure TTinyTableIO.ClearMemRecTab(AList: TList);
var
  I: Integer;
begin
  if not Assigned(AList) then Exit;
  for I := 0 to AList.Count - 1 do
    Dispose(PMemRecTabItem(AList.Items[I]));
  AList.Clear;
end;

procedure TTinyTableIO.AddMemRecTabItem(AList: TList; Value: TMemRecTabItem);
var
  MemRecTabItemPtr: PMemRecTabItem;
begin
  New(MemRecTabItemPtr);
  MemRecTabItemPtr^ := Value;
  AList.Add(MemRecTabItemPtr);
end;

procedure TTinyTableIO.InsertMemRecTabItem(AList: TList; Index: Integer; Value: TMemRecTabItem);
var
  MemRecTabItemPtr: PMemRecTabItem;
begin
  New(MemRecTabItemPtr);
  MemRecTabItemPtr^ := Value;
  AList.Insert(Index, MemRecTabItemPtr);
end;

procedure TTinyTableIO.DeleteMemRecTabItem(AList: TList; Index: Integer);
var
  F: PMemRecTabItem;
begin
  F := AList.Items[Index];
  Dispose(F);
  AList.Delete(Index);
end;

function TTinyTableIO.GetMemRecTabItem(AList: TList; Index: Integer): TMemRecTabItem;
begin
  Result := PMemRecTabItem(AList.Items[Index])^;
end;

function TTinyTableIO.ShouldEncrypt(FieldIdx: Integer): Boolean;
begin
  Result := FDatabase.Encrypted and (FFieldDefs[FieldIdx].DPMode = fdDefault);
end;

function TTinyTableIO.ShouldCompress(FieldIdx: Integer): Boolean;
begin
  Result := FDatabase.Compressed and
    (FTableHeader.FieldTab[FieldIdx].FieldType in BlobFieldTypes) and
    (FFieldDefs[FieldIdx].DPMode = fdDefault);
end;

//-----------------------------------------------------------------------------
// 取得第ItemIdx个记录表项目的偏移
//-----------------------------------------------------------------------------
function TTinyTableIO.GetRecTabItemOffset(ItemIdx: Integer): Integer;
var
  BlockIdx: Integer;
begin
  BlockIdx := ItemIdx div tdbRecTabUnitNum;
  Result := FRecTabBlockOffsets[BlockIdx] + SizeOf(Integer) +
    SizeOf(TRecordTabItem)*(ItemIdx mod tdbRecTabUnitNum);
end;

//-----------------------------------------------------------------------------
// 取得索引号为IndexIdx的索引的所有IndexTab中第ItemIdx个项目的偏移
//-----------------------------------------------------------------------------
function TTinyTableIO.GetIdxTabItemOffset(IndexIdx: Integer; ItemIdx: Integer): Integer;
var
  BlockIdx: Integer;
begin
  BlockIdx := ItemIdx div tdbIdxTabUnitNum;
  Result := FIdxTabBlockOffsets[IndexIdx][BlockIdx] + SizeOf(Integer) +
    SizeOf(TIndexTabItem)*(ItemIdx mod tdbIdxTabUnitNum);
end;

//-----------------------------------------------------------------------------
// 比较两个字段数据的大小
// 字段一的数据放在FieldBuffer1中，字段二的数据放在FieldBuffer2中
// FieldType: 字段类型
// CaseInsensitive: 不区分大小写
// PartialCompare: 是否只比较部分字符串
// 返回值：
//   若 Field1 等于或匹配 Field2 则返回值 = 0
//   若 Field1 > Field2 则返回值 > 0
//   若 Field1 < Field2 则返回值 < 0
//-----------------------------------------------------------------------------
function TTinyTableIO.CompFieldData(FieldBuffer1, FieldBuffer2: Pointer; FieldType: TFieldType;
  CaseInsensitive, PartialCompare: Boolean): Integer;
var
  ExprNodes: TExprNodes;
  LeftNode, RightNode, ResultNode: TExprNode;
  Options: TStrCompOptions;
begin
  ExprNodes := TExprNodes.Create(nil);
  try
    LeftNode := ExprNodes.NewNode(enConst, FieldType, 0, toNOTDEFINED, nil, nil);
    LeftNode.FData := FieldBuffer1;
    if PartialCompare and (FieldType in StringFieldTypes) then
      LeftNode.FPartialLength := Length(LeftNode.FData); // Pos('*', LeftNode.FData);   //modified 2003.3.22
    RightNode := ExprNodes.NewNode(enConst, FieldType, 0, toNOTDEFINED, nil, nil);
    RightNode.FData := FieldBuffer2;
    if PartialCompare and (FieldType in StringFieldTypes) then
      RightNode.FPartialLength := LeftNode.FPartialLength; //Pos('*', RightNode.FData);
    ResultNode := ExprNodes.NewNode(enOperator, ftBoolean, SizeOf(Boolean), toLT, LeftNode, RightNode);

    Options := [];
    if not PartialCompare then Include(Options, scNoPartialCompare);
    if CaseInsensitive then Include(Options, scCaseInsensitive);
    
    // 如果Field1 = Field2
    ResultNode.FOperator := toEQ;
    ResultNode.Calculate(Options);
    if ResultNode.AsBoolean then
    begin
      Result := 0;
      Exit;
    end;
    // 如果Field1 < Field2
    ResultNode.FOperator := toLT;
    ResultNode.Calculate(Options);
    if ResultNode.AsBoolean then
    begin
      Result := -1;
      Exit;
    end;
    // 否则Field1 > Field2
    Result := 1;
  finally
    ExprNodes.Free;
  end;
end;

//-----------------------------------------------------------------------------
// 根据索引查找离指定数据最近的位置（二分法）
// FieldBuffers: 待查找数据应事先存放于FieldBuffers中
// RecTabList: 要查找的记录集，注意：必须是已排序的记录集
// IndexIdx: 索引号（0-based），应对应于RecTabList的排序索引
// ResultState: 存放搜索结果状态
//     0:  待查找的值 = 查找结果位置的值
//     1:  待查找的值 > 查找结果位置的值
//    -1:  待查找的值 < 查找结果位置的值
//    -2:  无记录
// EffFieldCount: Fields中有效字段个数。缺省为0时表示按复合索引中实际字段数计算
// PartialCompare: 字符串的部分匹配
// 返回值：在RecTabList中的记录号(0-based)，如果无记录则返回-1
//-----------------------------------------------------------------------------
function TTinyTableIO.SearchIndexedField(FieldBuffers: TFieldBuffers;
  RecTabList: TList; IndexIdx: Integer; var ResultState: Integer;
  EffFieldCount: Integer = 0; PartialCompare: Boolean = False): Integer;
var
  I, Hi, Lo, Mid, Pos: Integer;
  FieldIdx, CompRes: Integer;
  IndexOptions: TTDIndexOptions;
  MemRecTabItem: TMemRecTabItem;
  DataStream: TMemoryStream;
begin
  DataStream := TMemoryStream.Create;
  IndexOptions := FIndexDefs[IndexIdx].Options;
  Lo := 0;
  Hi := RecTabList.Count - 1;
  Pos := -1;
  ResultState := -2;
  while Lo <= Hi do
  begin
    Mid := (Lo + Hi) div 2;
    MemRecTabItem := GetMemRecTabItem(RecTabList, Mid);
    CompRes := 0;
    for I := 0 to High(FIndexDefs[IndexIdx].FieldIdxes) do
    begin
      if (EffFieldCount <> 0) and (I >= EffFieldCount) then Break;
      FieldIdx := FIndexDefs[IndexIdx].FieldIdxes[I]; // 物理字段号
      ReadFieldData(DataStream, MemRecTabItem.RecIndex, FieldIdx);
      CompRes := CompFieldData(FieldBuffers.Items[FieldIdx].DataBuf, DataStream.Memory,
        FieldBuffers.Items[FieldIdx].FieldType, tiCaseInsensitive in IndexOptions, PartialCompare);
      if CompRes <> 0 then Break;
    end;

    if tiDescending in IndexOptions then CompRes := - CompRes;

    Pos := Mid;
    if CompRes > 0 then
    begin
      Lo := Mid + 1;
      ResultState := 1;
    end else if CompRes < 0 then
    begin
      Hi := Mid - 1;
      ResultState := -1;
    end else
    begin
      ResultState := 0;
      Break;
    end;
  end;
  DataStream.Free;
  Result := Pos;
end;

//-----------------------------------------------------------------------------
// 根据索引查找离指定数据的边界位置（二分法）
// FieldBuffers: 待查找数据应事先存放于FieldBuffers中
// RecTabList: 要查找的记录集，注意：必须是已排序的记录集
// IndexIdx: 索引号（0-based），应对应于RecTabList的排序索引
// LowBound: 为True时查找低边界，为False时查找高边界
// ResultState: 存放搜索结果状态，定义同SearchIndexedField
// EffFieldCount: Fields中有效字段个数。缺省为0时表示按复合索引中实际字段数计算
// PartialCompare: 字符串的部分匹配
// 返回值：在RecTabList中的记录号(0-based)，如果无记录则返回-1
//-----------------------------------------------------------------------------
function TTinyTableIO.SearchIndexedFieldBound(FieldBuffers: TFieldBuffers;
  RecTabList: TList; IndexIdx: Integer; LowBound: Boolean; var ResultState: Integer;
  EffFieldCount: Integer = 0; PartialCompare: Boolean = False): Integer;
var
  I, Hi, Lo, Mid, Pos: Integer;
  MemRecTabItem: TMemRecTabItem;
  FieldIdx, CompRes: Integer;
  IndexOptions: TTDIndexOptions;
  DataStream: TMemoryStream;
begin
  DataStream := TMemoryStream.Create;
  IndexOptions := FIndexDefs[IndexIdx].Options;
  Lo := 0;
  Hi := RecTabList.Count - 1;
  Pos := -1;
  ResultState := -2;
  while Lo <= Hi do
  begin
    Mid := (Lo + Hi) div 2;
    MemRecTabItem := GetMemRecTabItem(RecTabList, Mid);
    CompRes := 0;
    for I := 0 to High(FIndexDefs[IndexIdx].FieldIdxes) do
    begin
      if (EffFieldCount <> 0) and (I >= EffFieldCount) then Break;
      FieldIdx := FIndexDefs[IndexIdx].FieldIdxes[I];
      ReadFieldData(DataStream, MemRecTabItem.RecIndex, FieldIdx);
      CompRes := CompFieldData(FieldBuffers.Items[FieldIdx].DataBuf, DataStream.Memory,
        FieldBuffers.Items[FieldIdx].FieldType, tiCaseInsensitive in IndexOptions, PartialCompare);
      if CompRes <> 0 then Break;
    end;

    if tiDescending in IndexOptions then CompRes := - CompRes;

    if ResultState <> 0 then Pos := Mid;
    if CompRes > 0 then
    begin
      Lo := Mid + 1;
      if ResultState <> 0 then ResultState := 1;
    end else if CompRes < 0 then
    begin
      Hi := Mid - 1;
      if ResultState <> 0 then ResultState := -1;
    end else
    begin
      if LowBound then Hi := Mid - 1
      else Lo := Mid + 1;
      Pos := Mid;
      ResultState := 0;
    end;
  end;
  DataStream.Free;
  Result := Pos;
end;

//-----------------------------------------------------------------------------
// 根据索引求取SubRangeStart的位置
// FieldBuffers: 待查找数据应事先存放于FieldBuffers中
// RecTabList: 要查找的记录集，注意：必须是已排序的记录集
// IndexIdx: 索引号（0-based），应对应于RecTabList的排序索引
// ResultState: 存放搜索结果状态，定义同SearchIndexedField
// EffFieldCount: FieldBuffers中有效字段个数。缺省为0时表示按复合索引中实际字段数计算
// 返回值：求得结果，在RecTabList中的记录号(0-based)
//-----------------------------------------------------------------------------
function TTinyTableIO.SearchRangeStart(FieldBuffers: TFieldBuffers; RecTabList: TList;
  IndexIdx: Integer; var ResultState: Integer; EffFieldCount: Integer = 0): Integer;
begin
  Result := SearchIndexedFieldBound(FieldBuffers, RecTabList, IndexIdx, True, ResultState, EffFieldCount);
  if ResultState = 1 then Inc(Result);
end;

//-----------------------------------------------------------------------------
// 根据索引求取SubRangeEnd的位置
// FieldBuffers: 待查找数据应事先存放于FieldBuffers中
// RecTabList: 要查找的记录集，注意：必须是已排序的记录集
// IndexIdx: 索引号（0-based），应对应于RecTabList的排序索引
// ResultState: 存放搜索结果状态，定义同SearchIndexedField
// EffFieldCount: FieldBuffers中有效字段个数。缺省为0时表示按复合索引中实际字段数计算
// 返回值：求得结果，在RecTabList中的记录号(0-based)
//-----------------------------------------------------------------------------
function TTinyTableIO.SearchRangeEnd(FieldBuffers: TFieldBuffers; RecTabList: TList;
  IndexIdx: Integer; var ResultState: Integer; EffFieldCount: Integer = 0): Integer;
begin
  Result := SearchIndexedFieldBound(FieldBuffers, RecTabList, IndexIdx, False, ResultState, EffFieldCount);
  if ResultState = -1 then Dec(Result);
end;

//-----------------------------------------------------------------------------
// 根据索引求取插入点
// FieldBuffers: 待查找数据应事先存放于FieldBuffers中
// IndexIdx: 索引号 0-based
// ResultState: 存放搜索结果状态，定义同SearchIndexedField
// 返回值：插入点的位置(0-based)
//-----------------------------------------------------------------------------
function TTinyTableIO.SearchInsertPos(FieldBuffers: TFieldBuffers; IndexIdx: Integer; var ResultState: Integer): Integer;
begin
  Result := SearchIndexedField(FieldBuffers, FRecTabLists[IndexIdx+1], IndexIdx, ResultState);
  if ResultState in [0, 1] then Inc(Result)
  else if ResultState = -2 then Result := 0;
end;

//-----------------------------------------------------------------------------
// 检查是否含有Primary索引
// 返回值：
//   没有则返回 -1
//   有则返回索引号
//-----------------------------------------------------------------------------
function TTinyTableIO.CheckPrimaryFieldExists: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FIndexDefs.Count - 1 do
  begin
    if tiPrimary in FIndexDefs[I].Options then
    begin
      Result := I;
      Break;
    end;
  end;
end;

//-----------------------------------------------------------------------------
// 新增记录时检查Primary,Unique字段的唯一性
// FieldBuffers: 待检查字段值应事先存放在其中
// 返回值： 合法（符合唯一性）则返回 True
//-----------------------------------------------------------------------------
function TTinyTableIO.CheckUniqueFieldForAppend(FieldBuffers: TFieldBuffers): Boolean;
var
  I, Idx, ResultState: Integer;
  S: string;
  IndexOptions: TTDIndexOptions;
begin
  Result := True;
  for Idx := 0 to FIndexDefs.Count - 1 do
  begin
    IndexOptions := FIndexDefs[Idx].Options;
    if (tiPrimary in IndexOptions) or (tiUnique in IndexOptions) then
    begin
      SearchIndexedField(FieldBuffers, FRecTabLists[Idx+1], Idx, ResultState);
      if ResultState = 0 then
      begin
        Result := False;
        S := '';
        for I := 0 to Length(FIndexDefs[Idx].FieldIdxes) - 1 do
        begin
          if I > 0 then S := S + ',';
          S := S + FieldBuffers.Items[FIndexDefs[Idx].FieldIdxes[I]].AsString;
        end;
        DatabaseErrorFmt(SInvalidUniqueFieldValue, [S]);
      end;
    end;
  end;
end;

//-----------------------------------------------------------------------------
// 修改记录时检查Primary,Unique字段的唯一性
// FieldBuffers: 待检查字段值应事先存放在其中
// PhyRecordIdx: 正在修改的记录的物理记录号
// 返回值： 合法（符合唯一性）则返回 True
//-----------------------------------------------------------------------------
function TTinyTableIO.CheckUniqueFieldForModify(FieldBuffers: TFieldBuffers; PhyRecordIdx: Integer): Boolean;
var
  I, Idx, RecIdx, ResultState: Integer;
  S: string;
  IndexOptions: TTDIndexOptions;
begin
  Result := True;
  for Idx := 0 to FIndexDefs.Count - 1 do
  begin
    IndexOptions := FIndexDefs[Idx].Options;
    if (tiPrimary in IndexOptions) or (tiUnique in IndexOptions) then
    begin
      RecIdx := SearchIndexedField(FieldBuffers, FRecTabLists[Idx+1], Idx, ResultState);
      if ResultState = 0 then
      begin
        ConvertRecordIdx(Idx, RecIdx, -1, RecIdx);
        if PhyRecordIdx <> RecIdx then
        begin
          Result := False;
          S := '';
          for I := 0 to Length(FIndexDefs[Idx].FieldIdxes) - 1 do
          begin
            if I > 0 then S := S + ',';
            S := S + FieldBuffers.Items[FIndexDefs[Idx].FieldIdxes[I]].AsString;
          end;
          DatabaseErrorFmt(SInvalidUniqueFieldValue, [S]);
        end;
      end;
    end;
  end;
end;

//-----------------------------------------------------------------------------
// 将索引号为SrcIndexIdx的索引中的记录号SrcRecordIdx转换成
// 索引号为DstIndexIdx的索引中的记录号，结果存放于DstRecordIdx中
//-----------------------------------------------------------------------------
procedure TTinyTableIO.ConvertRecordIdx(SrcIndexIdx, SrcRecordIdx, DstIndexIdx: Integer; var DstRecordIdx: Integer);
var
  I, RecIdx: Integer;
  MemRecTabItem: TMemRecTabItem;
begin
  if (SrcRecordIdx < 0) or (SrcRecordIdx >= FRecTabLists[SrcIndexIdx+1].Count) then
  begin
    DstRecordIdx := -1;
    Exit;
  end;

  if SrcIndexIdx = DstIndexIdx then
  begin
    DstRecordIdx := SrcRecordIdx;
    Exit;
  end;

  MemRecTabItem := GetMemRecTabItem(FRecTabLists[SrcIndexIdx+1], SrcRecordIdx);
  RecIdx := MemRecTabItem.RecIndex;

  if DstIndexIdx = -1 then
  begin
    ConvertRecIdxForPhy(SrcIndexIdx, SrcRecordIdx, DstRecordIdx);
    Exit;
  end else
  begin
    for I := 0 to FRecTabLists[DstIndexIdx+1].Count - 1 do
    begin
      MemRecTabItem := GetMemRecTabItem(FRecTabLists[DstIndexIdx+1], I);
      if MemRecTabItem.RecIndex = RecIdx then
      begin
        DstRecordIdx := I;
        Exit;
      end;
    end;
  end;
  DstRecordIdx := -1;
end;

//-----------------------------------------------------------------------------
// 将SrcRecTabList中的记录号SrcRecordIdx转换成
// DstRecTabList中的记录号，结果存放于DstRecordIdx中
//-----------------------------------------------------------------------------
procedure TTinyTableIO.ConvertRecordIdx(SrcRecTabList: TList; SrcRecordIdx: Integer;
  DstRecTabList: TList; var DstRecordIdx: Integer);
var
  I, RecIdx: Integer;
  MemRecTabItem: TMemRecTabItem;
begin
  if (SrcRecordIdx < 0) or (SrcRecordIdx >= SrcRecTabList.Count) then
  begin
    DstRecordIdx := -1;
    Exit;
  end;

  if SrcRecTabList = DstRecTabList then
  begin
    DstRecordIdx := SrcRecordIdx;
    Exit;
  end;

  MemRecTabItem := GetMemRecTabItem(SrcRecTabList, SrcRecordIdx);
  RecIdx := MemRecTabItem.RecIndex;

  for I := 0 to DstRecTabList.Count - 1 do
  begin
    MemRecTabItem := GetMemRecTabItem(DstRecTabList, I);
    if MemRecTabItem.RecIndex = RecIdx then
    begin
      DstRecordIdx := I;
      Exit;
    end;
  end;
  DstRecordIdx := -1;
end;

//-----------------------------------------------------------------------------
// 将索引号为SrcIndexIdx的索引中的记录号SrcRecordIdx转换成
// FRecTabLists[0]中对应的记录号，结果存放于DstRecordIdx中
//-----------------------------------------------------------------------------
procedure TTinyTableIO.ConvertRecIdxForPhy(SrcIndexIdx, SrcRecordIdx: Integer; var DstRecordIdx: Integer);
var
  Lo, Hi, Mid, Pos, RecIdx: Integer;
  MemRecTabItem: TMemRecTabItem;
begin
  if (SrcRecordIdx < 0) or (SrcRecordIdx >= FRecTabLists[SrcIndexIdx+1].Count) then
  begin
    DstRecordIdx := -1;
    Exit;
  end;

  MemRecTabItem := GetMemRecTabItem(FRecTabLists[SrcIndexIdx+1], SrcRecordIdx);
  RecIdx := MemRecTabItem.RecIndex;

  // FRecTabLists[0] 中的RecIndex是有序的，所以可以用二分法
  Lo := 0;
  Hi := FRecTabLists[0].Count - 1;
  Pos := -1;
  while Lo <= Hi do
  begin
    Mid := (Lo + Hi) div 2;
    MemRecTabItem := GetMemRecTabItem(FRecTabLists[0], Mid);
    if RecIdx > MemRecTabItem.RecIndex then
    begin
      Lo := Mid + 1;
    end else if RecIdx < MemRecTabItem.RecIndex then
    begin
      Hi := Mid - 1;
    end else
    begin
      Pos := Mid;
      Break;
    end;
  end;
  DstRecordIdx := Pos;
end;

//-----------------------------------------------------------------------------
// 将记录集SrcRecTabList中的记录号SrcRecordIdx转换成
// FRecTabLists[0]中对应的记录号，结果存放于DstRecordIdx中
//-----------------------------------------------------------------------------
procedure TTinyTableIO.ConvertRecIdxForPhy(SrcRecTabList: TList; SrcRecordIdx: Integer; var DstRecordIdx: Integer);
var
  Lo, Hi, Mid, Pos, RecIdx: Integer;
  MemRecTabItem: TMemRecTabItem;
begin
  if (SrcRecordIdx < 0) or (SrcRecordIdx >= SrcRecTabList.Count) then
  begin
    DstRecordIdx := -1;
    Exit;
  end;

  MemRecTabItem := GetMemRecTabItem(SrcRecTabList, SrcRecordIdx);
  RecIdx := MemRecTabItem.RecIndex;

  // FRecTabLists[0] 中的RecIndex是有序的，所以可以用二分法
  Lo := 0;
  Hi := FRecTabLists[0].Count - 1;
  Pos := -1;
  while Lo <= Hi do
  begin
    Mid := (Lo + Hi) div 2;
    MemRecTabItem := GetMemRecTabItem(FRecTabLists[0], Mid);
    if RecIdx > MemRecTabItem.RecIndex then
    begin
      Lo := Mid + 1;
    end else if RecIdx < MemRecTabItem.RecIndex then
    begin
      Hi := Mid - 1;
    end else
    begin
      Pos := Mid;
      Break;
    end;
  end;
  DstRecordIdx := Pos;
end;

//-----------------------------------------------------------------------------
// 将索引号为SrcIndexIdx的索引中的记录号SrcRecordIdx转换成
// RecTabList中对应的记录号，结果存放于DstRecordIdx中
//-----------------------------------------------------------------------------
procedure TTinyTableIO.ConvertRecIdxForCur(SrcIndexIdx, SrcRecordIdx: Integer;
  RecTabList: TList; var DstRecordIdx: Integer);
var
  I, RecIdx: Integer;
  MemRecTabItem: TMemRecTabItem;
begin
  if (SrcRecordIdx < 0) or (SrcRecordIdx >= FRecTabLists[SrcIndexIdx+1].Count) then
  begin
    DstRecordIdx := -1;
    Exit;
  end;

  if RecTabList = FRecTabLists[SrcIndexIdx + 1] then
  begin
    DstRecordIdx := SrcRecordIdx;
    Exit;
  end;

  MemRecTabItem := GetMemRecTabItem(FRecTabLists[SrcIndexIdx+1], SrcRecordIdx);
  RecIdx := MemRecTabItem.RecIndex;

  for I := 0 to RecTabList.Count - 1 do
  begin
    MemRecTabItem := GetMemRecTabItem(RecTabList, I);
    if MemRecTabItem.RecIndex = RecIdx then
    begin
      DstRecordIdx := I;
      Exit;
    end;
  end;
  DstRecordIdx := -1;
end;

//-----------------------------------------------------------------------------
// 新增记录时调整数据库索引
// RecDataOffset: 新增记录的数据区偏移
// RecTotal: 新增前的记录总数，包括有删除标记的记录
//-----------------------------------------------------------------------------
procedure TTinyTableIO.AdjustIndexesForAppend(FieldBuffers: TFieldBuffers;
  RecDataOffset, RecTotal: Integer; OnAdjustIndex: TOnAdjustIndexForAppendEvent);
var
  Idx, Pos, ResultState: Integer;
  IdxTabOffset, StartIndex: Integer;
  BakFilePos: Integer;
  IdxTabItem, IdxTabItemA: TIndexTabItem;
  MemRecTabItem: TMemRecTabItem;
  IndexTabAry: array of TIndexTabItem;
  NextBlockOffset: Integer;
  DBStream: TStream;
begin
  DBStream := FDatabase.DBFileIO.DBStream;

  MemRecTabItem.DataOffset := RecDataOffset;
  MemRecTabItem.RecIndex := RecTotal;
  OnAdjustIndex(-1, -1, MemRecTabItem);

  for Idx := 0 to High(FRecTabLists) - 1 do
  begin
    // 求取插入点
    Pos := SearchInsertPos(FieldBuffers, Idx, ResultState);

    if Assigned(OnAdjustIndex) then
    begin
      MemRecTabItem.DataOffset := RecDataOffset;
      MemRecTabItem.RecIndex := RecTotal;
      OnAdjustIndex(Idx, Pos, MemRecTabItem);
    end;

    // 调整FRecTabLists
    MemRecTabItem.DataOffset := RecDataOffset;
    MemRecTabItem.RecIndex := RecTotal;
    InsertMemRecTabItem(FRecTabLists[Idx+1], Pos, MemRecTabItem);

    // 将索引写入磁盘数据库文件中 ----------------------------
    IdxTabOffset := FTableHeader.IndexHeader[Idx].IndexOffset;

    // 如果已有记录数已经是调整步长的整数倍，则..
    if RecTotal mod tdbIdxTabUnitNum = 0 then
    begin
      // 构造一个新的索引表块
      SetLength(IndexTabAry, tdbIdxTabUnitNum);
      FillChar(IndexTabAry[0], SizeOf(TIndexTabItem)*Length(IndexTabAry), 0);
      // 调整上一索引表块首的Next指针
      NextBlockOffset := DBStream.Size;
      if Length(FIdxTabBlockOffsets[Idx]) > 0 then
      begin
        DBStream.Position := FIdxTabBlockOffsets[Idx][High(FIdxTabBlockOffsets[Idx])];
        DBStream.Write(NextBlockOffset, SizeOf(Integer));
      end;
      // 如果原本没有记录，则调整TableHeader
      if RecTotal = 0 then
      begin
        IdxTabOffset := DBStream.Size;
        FTableHeader.IndexHeader[Idx].IndexOffset := IdxTabOffset;
        FDatabase.DBFileIO.WriteTableHeader(TableIdx, FTableHeader);
      end;
      // 调整FIdxTabBlockOffsets[Idx]
      SetLength(FIdxTabBlockOffsets[Idx], Length(FIdxTabBlockOffsets[Idx]) + 1);
      FIdxTabBlockOffsets[Idx][High(FIdxTabBlockOffsets[Idx])] := NextBlockOffset;
      // 把新的索引表块写入数据库
      DBStream.Seek(0, soFromEnd);
      NextBlockOffset := 0;
      DBStream.Write(NextBlockOffset, SizeOf(Integer));
      DBStream.Write(IndexTabAry[0], SizeOf(TIndexTabItem)*Length(IndexTabAry));
    end;

    // 如果是第一条记录
    if RecTotal = 0 then
    begin
      IdxTabItem.RecIndex := 0;
      IdxTabItem.Next := -1;
      DBStream.Position := IdxTabOffset + SizeOf(Integer);
      DBStream.Write(IdxTabItem, SizeOf(IdxTabItem));
    end else
    // 如果不是第一条记录
    begin
      // 如果插入在链表头
      if Pos = 0 then
      begin
        // 构造一个新的IdxTabItem
        StartIndex := FTableHeader.IndexHeader[Idx].StartIndex;
        IdxTabItem.RecIndex := RecTotal;
        IdxTabItem.Next := StartIndex;
        // 把新的IdxTabItem写入数据库
        DBStream.Position := GetIdxTabItemOffset(Idx, RecTotal);
        DBStream.Write(IdxTabItem, SizeOf(IdxTabItem));
        // 调整TableHeader
        FTableHeader.IndexHeader[Idx].StartIndex := RecTotal;
        FDatabase.DBFileIO.WriteTableHeader(TableIdx, FTableHeader);
      end else
      // 如果不插入在链表头
      begin
        // 读取插入点的上一个索引项目IdxTabItemA
        MemRecTabItem := GetMemRecTabItem(FRecTabLists[Idx+1], Pos - 1);
        DBStream.Position := GetIdxTabItemOffset(Idx, MemRecTabItem.RecIndex);
        BakFilePos := DBStream.Position;
        DBStream.Read(IdxTabItemA, SizeOf(IdxTabItemA));
        // 写入新的IdxTabItem
        IdxTabItem.RecIndex := RecTotal;
        IdxTabItem.Next := IdxTabItemA.Next;
        DBStream.Position := GetIdxTabItemOffset(Idx, RecTotal);
        DBStream.Write(IdxTabItem, SizeOf(IdxTabItem));
        // 将调整后的IdxTabItemA写入数据库
        IdxTabItemA.Next := RecTotal;
        DBStream.Position := BakFilePos;
        DBStream.Write(IdxTabItemA, SizeOf(IdxTabItem));
      end;
    end;
  end;
end;

//-----------------------------------------------------------------------------
// 修改记录时调整数据库索引
// EditPhyRecordIdx: 被修改记录的物理记录号（即在FRecTabLists[0]中的记录号） 0-based
//-----------------------------------------------------------------------------
procedure TTinyTableIO.AdjustIndexesForModify(FieldBuffers: TFieldBuffers;
  EditPhyRecordIdx: Integer; OnAdjustIndex: TOnAdjustIndexForModifyEvent);
var
  Idx, Pos, FromPos, ToPos, ResultState: Integer;
  BakFilePos: Integer;
  EditRecordIdx: Integer;
  MemRecTabItem, OrgMemRecTabItem: TMemRecTabItem;
  IdxTabItem, IdxTabItemA: TIndexTabItem;
  IndexOptions: TTDIndexOptions;
  EditRecordIdxes: array[0..tdbMaxIndex-1] of Integer;
  DBStream: TStream;
begin
  DBStream := FDatabase.DBFileIO.DBStream;
  for Idx := 0 to High(FRecTabLists) - 1 do
    ConvertRecordIdx(-1, EditPhyRecordIdx, Idx, EditRecordIdxes[Idx]);

  for Idx := 0 to High(FRecTabLists) - 1 do
  begin
    IndexOptions := FIndexDefs[Idx].Options;

    EditRecordIdx := EditRecordIdxes[Idx];
    OrgMemRecTabItem := GetMemRecTabItem(FRecTabLists[Idx+1], EditRecordIdx);
    DeleteMemRecTabItem(FRecTabLists[Idx+1], EditRecordIdx);
    // 求取插入点
    Pos := SearchInsertPos(FieldBuffers, Idx, ResultState);
    FromPos := EditRecordIdx;
    if Pos <= EditRecordIdx then ToPos := Pos
    else ToPos := Pos + 1;
    // 还原FRecTabLists[Idx+1]
    InsertMemRecTabItem(FRecTabLists[Idx+1], EditRecordIdx, OrgMemRecTabItem);

    if FromPos = ToPos then Continue;

    if Assigned(OnAdjustIndex) then
      OnAdjustIndex(Idx, FromPos, ToPos);

    // 调整磁盘数据库文件中的索引数据 ----------------------------
    // 先把待移动索引项目从链表中分离出来(IdxTabItem)
    // 如果待移动索引项目是链表中的第一个节点
    if FromPos = 0 then
    begin
      DBStream.Position := GetIdxTabItemOffset(Idx, OrgMemRecTabItem.RecIndex);
      DBStream.Read(IdxTabItem, SizeOf(IdxTabItem));
      FTableHeader.IndexHeader[Idx].StartIndex := IdxTabItem.Next;
      FDatabase.DBFileIO.WriteTableHeader(TableIdx, FTableHeader);
    end else
    // 如果不是链表中的第一个节点
    begin
      DBStream.Position := GetIdxTabItemOffset(Idx, OrgMemRecTabItem.RecIndex);
      DBStream.Read(IdxTabItem, SizeOf(IdxTabItem));
      MemRecTabItem := GetMemRecTabItem(FRecTabLists[Idx+1], FromPos - 1);
      DBStream.Position := GetIdxTabItemOffset(Idx, MemRecTabItem.RecIndex);
      BakFilePos := DBStream.Position;
      DBStream.Read(IdxTabItemA, SizeOf(IdxTabItemA));
      IdxTabItemA.Next := IdxTabItem.Next;
      DBStream.Position := BakFilePos;
      DBStream.Write(IdxTabItemA, SizeOf(IdxTabItemA));
    end;
    // 再把分离出来的索引项目放置到链表中的合适位置
    // 如果要放置到链表的第一个节点位置
    if ToPos = 0 then
    begin
      IdxTabItem.Next := FTableHeader.IndexHeader[Idx].StartIndex;
      FTableHeader.IndexHeader[Idx].StartIndex := OrgMemRecTabItem.RecIndex;
      DBStream.Position := GetIdxTabItemOffset(Idx, OrgMemRecTabItem.RecIndex);
      DBStream.Write(IdxTabItem, SizeOf(IdxTabItem));
      FDatabase.DBFileIO.WriteTableHeader(TableIdx, FTableHeader);
    end else
    // 如果要放置的位置不是链表的第一个节点位置
    begin
      MemRecTabItem := GetMemRecTabItem(FRecTabLists[Idx+1], ToPos - 1);
      DBStream.Position := GetIdxTabItemOffset(Idx, MemRecTabItem.RecIndex);
      BakFilePos := DBStream.Position;
      DBStream.Read(IdxTabItemA, SizeOf(IdxTabItemA));
      IdxTabItem.Next := IdxTabItemA.Next;
      IdxTabItemA.Next := OrgMemRecTabItem.RecIndex;
      DBStream.Position := BakFilePos;
      DBStream.Write(IdxTabItemA, SizeOf(IdxTabItemA));
      DBStream.Position := GetIdxTabItemOffset(Idx, OrgMemRecTabItem.RecIndex);
      DBStream.Write(IdxTabItem, SizeOf(IdxTabItem));
    end;

    // 调整FRecTabLists[Idx+1]
    DeleteMemRecTabItem(FRecTabLists[Idx+1], FromPos);
    InsertMemRecTabItem(FRecTabLists[Idx+1], Pos, OrgMemRecTabItem);
  end;
end;

//-----------------------------------------------------------------------------
// 删除记录时调整数据库索引
// DeletePhyRecordIdx: 被删除记录的物理记录号（即在FRecTabLists[0]中的记录号） 0-based
//-----------------------------------------------------------------------------
procedure TTinyTableIO.AdjustIndexesForDelete(DeletePhyRecordIdx: Integer);
var
  Idx: Integer;
  DeleteRecordIdxes: array[0..tdbMaxIndex-1] of Integer;
begin
  for Idx := 0 to High(FRecTabLists) - 1 do
    ConvertRecordIdx(-1, DeletePhyRecordIdx, Idx, DeleteRecordIdxes[Idx]);

  for Idx := 0 to High(FRecTabLists) - 1 do
    DeleteMemRecTabItem(FRecTabLists[Idx+1], DeleteRecordIdxes[Idx]);
end;

//-----------------------------------------------------------------------------
// 在数据库中做删除标记
// PhyRecordIdx: 物理记录号 0-based
//-----------------------------------------------------------------------------
procedure TTinyTableIO.WriteDeleteFlag(PhyRecordIdx: Integer);
var
  RecTabItemOffset: Integer;
begin
  RecTabItemOffset := GetRecTabItemOffset(GetMemRecTabItem(FRecTabLists[0], PhyRecordIdx).RecIndex);
  FDatabase.DBFileIO.WriteDeleteFlag(RecTabItemOffset);
end;

//-----------------------------------------------------------------------------
// 调整FieldBuffers，使其中的String字段未用区域为空字符
//-----------------------------------------------------------------------------
procedure TTinyTableIO.AdjustStrFldInBuffer(FieldBuffers: TFieldBuffers);
var
  I, DataSize, Len: Integer;
  Buffer: PChar;
begin
  for I := 0 to FieldBuffers.Count - 1 do
  begin
    if FieldBuffers.Items[I].FieldType in StringFieldTypes then
    begin
      Buffer := FieldBuffers.Items[I].Buffer;
      DataSize := FieldBuffers.Items[I].FieldSize;
      Len := Length(Buffer);
      if Len >= DataSize then Len := DataSize - 1;
      FillChar(Buffer[Len], DataSize - Len, 0);
    end;
  end;
end;

procedure TTinyTableIO.ClearAllRecTabLists;
var
  I: Integer;
begin
  for I := 0 to High(FRecTabLists) do
  begin
    ClearMemRecTab(FRecTabLists[I]);
    FRecTabLists[I].Free;
  end;
  SetLength(FRecTabLists, 0);
end;

procedure TTinyTableIO.Initialize;
var
  IndexCount: Integer;
begin
  FDatabase.DBFileIO.Lock;
  try
    FTableIdx := GetTableIdxByName(FTableName);
    if FTableIdx = -1 then
      DatabaseErrorFmt(STableNotFound, [FTableName]);

    FDatabase.DBFileIO.ReadTableHeader(FTableIdx, FTableHeader);
    IndexCount := FTableHeader.IndexCount;
    SetLength(FIdxTabBlockOffsets, IndexCount);

    InitFieldDefs;
    InitIndexDefs;
    InitAllRecTabLists;
    InitDiskRecInfo;
    InitAutoInc;
  finally
    FDatabase.DBFileIO.Unlock;
  end;
end;

procedure TTinyTableIO.Finalize;
begin
  FFieldDefs.Clear;
  FIndexDefs.Clear;
  ClearAllRecTabLists;
end;

procedure TTinyTableIO.Open;
begin
  if FRefCount = 0 then Initialize;
  Inc(FRefCount);
end;

procedure TTinyTableIO.Close;
begin
  Dec(FRefCount);
  if FRefCount = 0 then Finalize;
  if FRefCount < 0 then FRefCount := 0;
end;

procedure TTinyTableIO.Refresh;
begin
  if Active then
  begin
    Finalize;
    Initialize;
  end;
end;

//-----------------------------------------------------------------------------
// 将Buffer中的数据新增到数据库中
// FieldBuffers: 将要新增的字段数据（包含所有物理字段）
// Flush: 新增完后是否flush cache
//-----------------------------------------------------------------------------
procedure TTinyTableIO.AppendRecordData(FieldBuffers: TFieldBuffers; Flush: Boolean;
  OnAdjustIndex: TOnAdjustIndexForAppendEvent);
var
  RecordTab: TRecordTabItem;
  RecordTabAry: array of TRecordTabItem;
  TableHeaderOffset, RecTabOffset, RecTotal, DataOffset: Integer;
  BlobHeader: TBlobFieldHeader;
  BlobRestBuf: array[0..tdbBlobSizeUnitNum-1] of Char;
  BlobStream, DstBlobStream, DstBlobStream1: TMemoryStream;
  MemRecTabItem: TMemRecTabItem;
  NextRecTabBlockOffset: Integer;
  I, BlobDataPos, DstBlobSize: Integer;
  CRC32Value1, CRC32Value2: Longword;
  SrcDiskRecBuf, DstDiskRecBuf: PChar;
  FieldBuffer: Pointer;
  DBStream: TStream;
begin
  FDatabase.DBFileIO.Lock;
  try
    DBStream := FDatabase.DBFileIO.DBStream;

    // 检查Primary,Unique字段的唯一性
    CheckUniqueFieldForAppend(FieldBuffers);

    // 对AutoInc字段做调整
    if FAutoIncFieldIdx <> -1 then
    begin
      FieldBuffer := FieldBuffers.Items[FAutoIncFieldIdx].Buffer;
      if PInteger(FieldBuffer)^ = 0 then
      begin
        Inc(FTableHeader.AutoIncCounter);
        PInteger(FieldBuffer)^ := FTableHeader.AutoIncCounter;
      end else if PInteger(FieldBuffer)^ > FTableHeader.AutoIncCounter then
      begin
        FTableHeader.AutoIncCounter := PInteger(FieldBuffer)^;
      end;
    end;

    TableHeaderOffset := FDatabase.DBFileIO.TableTab.TableHeaderOffset[FTableIdx];
    RecTabOffset := FTableHeader.RecTabOffset;
    RecTotal := FTableHeader.RecordTotal;

    // 如果还没有任何记录
    if RecTotal = 0 then
    begin
      RecTabOffset := DBStream.Size;
      // 调整FRecTabBlockOffsets
      SetLength(FRecTabBlockOffsets, Length(FRecTabBlockOffsets) + 1);
      FRecTabBlockOffsets[High(FRecTabBlockOffsets)] := RecTabOffset;
      // ..
      SetLength(RecordTabAry, tdbRecTabUnitNum);
      FillChar(RecordTabAry[0], SizeOf(TRecordTabItem)*tdbRecTabUnitNum, 0);
      DataOffset := DBStream.Size + SizeOf(Integer) + SizeOf(TRecordTabItem)*tdbRecTabUnitNum;
      RecordTabAry[0].DataOffset := DataOffset;
      RecordTabAry[0].DeleteFlag := False;
      NextRecTabBlockOffset := 0;
      DBStream.Seek(0, soFromEnd);
      DBStream.Write(NextRecTabBlockOffset, SizeOf(Integer));
      DBStream.Write(RecordTabAry[0], SizeOf(TRecordTabItem)*tdbRecTabUnitNum);
    end else
    // 如果表中已经存在记录
    begin
      // 如果已有记录数已经是调整步长的整数倍，则..
      if RecTotal mod tdbRecTabUnitNum = 0 then
      begin
        // 构造一个新的记录表块
        SetLength(RecordTabAry, tdbRecTabUnitNum);
        FillChar(RecordTabAry[0], SizeOf(TRecordTabItem)*Length(RecordTabAry), 0);
        DataOffset := DBStream.Size + SizeOf(Integer) + SizeOf(TRecordTabItem)*Length(RecordTabAry);
        RecordTabAry[0].DataOffset := DataOffset;
        RecordTabAry[0].DeleteFlag := False;
        // 调整上一个记录表块首的Next指针
        NextRecTabBlockOffset := DBStream.Size;
        DBStream.Position := FRecTabBlockOffsets[High(FRecTabBlockOffsets)];
        DBStream.Write(NextRecTabBlockOffset, SizeOf(Integer));
        // 调整FRecTabBlockOffsets
        SetLength(FRecTabBlockOffsets, Length(FRecTabBlockOffsets) + 1);
        FRecTabBlockOffsets[High(FRecTabBlockOffsets)] := NextRecTabBlockOffset;
        // 在文件尾增加一个记录表块
        DBStream.Seek(0, soFromEnd);
        NextRecTabBlockOffset := 0;
        DBStream.Write(NextRecTabBlockOffset, SizeOf(Integer));
        DBStream.Write(RecordTabAry[0], SizeOf(TRecordTabItem)*Length(RecordTabAry));
      end else
      // 否则，只需直接修改
      begin
        DBStream.Position := GetRecTabItemOffset(RecTotal);
        DataOffset := DBStream.Size;
        RecordTab.DataOffset := DataOffset;
        RecordTab.DeleteFlag := False;
        DBStream.Write(RecordTab, SizeOf(RecordTab));
      end;
    end;
    // 将调整后的RecTabOffset, RecordTotal写回数据库
    Inc(RecTotal);
    DBStream.Position := TableHeaderOffset + SizeOf(TTableNameString);
    DBStream.Write(RecTabOffset, SizeOf(Integer));
    DBStream.Write(RecTotal, SizeOf(Integer));
    if FAutoIncFieldIdx <> -1 then DBStream.Write(FTableHeader.AutoIncCounter, SizeOf(Integer));
    // 调整FTableHeader
    FTableHeader.RecTabOffset := RecTabOffset;
    FTableHeader.RecordTotal := RecTotal;

    // 写入真正数据
    DstBlobStream := TMemoryStream.Create;
    DstBlobStream1 := TMemoryStream.Create;
    SrcDiskRecBuf := AllocMem(FDiskRecSize);
    DstDiskRecBuf := AllocMem(FDiskRecSize);
    try
      FillChar(BlobHeader, SizeOf(BlobHeader), 0);
      // 调整字符串字段
      AdjustStrFldInBuffer(FieldBuffers);
      // 先写入数据库以占据位置
      DBStream.Position := DataOffset;
      DBStream.Write(DstDiskRecBuf^, FDiskRecSize);
      for I := 0 to FTableHeader.FieldCount - 1 do
      begin
        FieldBuffer := FieldBuffers.Items[I].Buffer;
        // 如果是不定长度数据
        if FieldBuffers.Items[I].IsBlob then
        begin
          BlobStream := TMemoryStream(FieldBuffer);
          // 数据编码（压缩、加密）
          FDatabase.DBFileIO.EncodeMemoryStream(BlobStream, DstBlobStream, ShouldEncrypt(I), ShouldCompress(I));
          DstBlobSize := DstBlobStream.Size;
          // 计算BlobHeader
          BlobDataPos := DBStream.Position;
          BlobHeader.DataOffset := BlobDataPos;
          BlobHeader.DataSize := DstBlobSize;
          BlobHeader.AreaSize := DstBlobSize + (tdbBlobSizeUnitNum - DstBlobSize mod tdbBlobSizeUnitNum);
          // 将BlobHeader写入数据库
          Move(BlobHeader, DstDiskRecBuf[FDiskFieldOffsets[I]], SizeOf(BlobHeader));

          // 写BLOB数据：
          // 如果起用CRC32校检
          if FDatabase.CRC32 then
          begin
            CRC32Value1 := 0;
            CRC32Value2 := 0;
            repeat
              if CRC32Value1 <> CRC32Value2 then
                FDatabase.DBFileIO.EncodeMemoryStream(BlobStream, DstBlobStream, ShouldEncrypt(I), ShouldCompress(I));
              DstBlobSize := DstBlobStream.Size;
              // 计算原始数据的Checksum Value
              CRC32Value1 := CheckSumCRC32(BlobStream.Memory^, BlobStream.Size);
              // 写入Blob数据
              DBStream.Position := BlobDataPos;
              DBStream.Write(DstBlobStream.Memory^, DstBlobStream.Size);
              // 读入Blob数据
              DBStream.Position := BlobDataPos;
              DBStream.Read(DstBlobStream.Memory^, DstBlobStream.Size);
              // 解码
              try
                FDatabase.DBFileIO.DecodeMemoryStream(DstBlobStream, DstBlobStream1, ShouldEncrypt(I), ShouldCompress(I));
              except
              end;
              // 计算解码后数据的Checksum Value
              CRC32Value2 := CheckSumCRC32(DstBlobStream1.Memory^, DstBlobStream1.Size);
            // 如果两次的Checksum Value相等，则说明校检正确，跳出循环
            until CRC32Value1 = CRC32Value2;
          end else
          // 如果不起用CRC32校检
          begin
            // 直接写入Blob数据
            DBStream.Write(DstBlobStream.Memory^, DstBlobStream.Size);
          end;
          // 填充Blob区域，使得Blob长度为tdbBlobSizeUnitNum的整数倍
          DBStream.Write(BlobRestbuf[0], tdbBlobSizeUnitNum - DstBlobSize mod tdbBlobSizeUnitNum);
        end else
        // 固定长度数据
        begin
          // 数据编码（加密）
          FDatabase.DBFileIO.EncodeMemoryBuffer(FieldBuffer, DstDiskRecBuf + FDiskFieldOffsets[I],
            FieldBuffers.Items[I].FieldSize, ShouldEncrypt(I));
        end;
      end;
      // 再次写入数据库
      DBStream.Position := DataOffset;
      DBStream.Write(DstDiskRecBuf^, FDiskRecSize);
    finally
      // 释放内存
      FreeMem(DstDiskRecBuf, FDiskRecSize);
      FreeMem(SrcDiskRecBuf, FDiskRecSize);
      DstBlobStream.Free;
      DstBlobStream1.Free;
    end;
    // 调整RecTabLists[0]
    MemRecTabItem.DataOffset := DataOffset;
    MemRecTabItem.RecIndex := RecTotal - 1;
    AddMemRecTabItem(FRecTabLists[0], MemRecTabItem);
    // 调整索引
    AdjustIndexesForAppend(FieldBuffers, DataOffset, RecTotal - 1, OnAdjustIndex);
    if Flush then FDatabase.DBFileIO.Flush;
  finally
    FDatabase.DBFileIO.Unlock;
  end;
end;

//-----------------------------------------------------------------------------
// 将FieldBuffers中的数据写入到数据库的第PhyRecordIdx条记录中
// FieldBuffers: 将要修改的字段数据（包含所有物理字段）
// PhyRecordIdx: 物理记录号（即在FRecTabLists[0]中的记录号） 0-based
// Flush: 修改完后是否flush cache
//-----------------------------------------------------------------------------
procedure TTinyTableIO.ModifyRecordData(FieldBuffers: TFieldBuffers;
  PhyRecordIdx: Integer;  Flush: Boolean;
  OnAdjustIndex: TOnAdjustIndexForModifyEvent);
var
  I, DataOffset: Integer;
  BakPos, BlobDataPos: Integer;
  DstBlobSize: Integer;
  BlobHeader, NewBlobHeader: TBlobFieldHeader;
  BlobRestBuf: array[0..tdbBlobSizeUnitNum-1] of Char;
  BlobStream, DstBlobStream, DstBlobStream1: TMemoryStream;
  CRC32Value1, CRC32Value2: Longword;
  DiskRecBuf: PChar;
  DBStream: TStream;
  FieldBuffer: Pointer;
begin
  FDatabase.DBFileIO.Lock;
  try
    DBStream := FDatabase.DBFileIO.DBStream;
    DstBlobStream := TMemoryStream.Create;
    DstBlobStream1 := TMemoryStream.Create;
    DiskRecBuf := AllocMem(FDiskRecSize);
    try
      // 检查Primary,Unique字段的唯一性
      CheckUniqueFieldForModify(FieldBuffers, PhyRecordIdx);

      FillChar(BlobRestBuf, SizeOf(BlobRestBuf), 0);
      FillChar(BlobHeader, SizeOf(BlobHeader), 0);
      DataOffset := GetMemRecTabItem(FRecTabLists[0], PhyRecordIdx).DataOffset;
      DBStream.Position := DataOffset;
      DBStream.Read(DiskRecBuf^, FDiskRecSize);

      for I := 0 to FieldBuffers.Count - 1 do
      begin
        if not FieldBuffers.Items[I].Active then Continue;

        FieldBuffer := FieldBuffers.Items[I].Buffer;
        // ----------如果是不定长度数据------------
        if FieldBuffers.Items[I].IsBlob then
        begin
          BlobStream := TMemoryStream(FieldBuffer);
          // 数据编码（压缩、加密）
          FDatabase.DBFileIO.EncodeMemoryStream(BlobStream, DstBlobStream, ShouldEncrypt(I), ShouldCompress(I));
          DstBlobSize := DstBlobStream.Size;
          // 读取原来的BlobHeader数据
          BlobHeader := PBlobFieldHeader(DiskRecBuf + FDiskFieldOffsets[I])^;
          NewBlobHeader := BlobHeader;
          // if DstBlobSize <= BlobHeader.AreaSize then
          if DstBlobSize < BlobHeader.AreaSize then     //  modified by haoxg 2004.11.14
          begin
            BlobDataPos := BlobHeader.DataOffset;
            NewBlobHeader.DataOffset := BlobDataPos;
            NewBlobHeader.DataSize := DstBlobSize;
            NewBlobHeader.AreaSize := BlobHeader.AreaSize;
          end else
          begin
            // 如果Blob数据在文件末尾
            if BlobHeader.DataOffset + BlobHeader.AreaSize = DBStream.Size then
            begin
              BlobDataPos := BlobHeader.DataOffset;
              NewBlobHeader.DataOffset := BlobDataPos;
            end else
            // 如果Blob数据不在文件末尾
            begin
              BlobDataPos := DBStream.Size;
              NewBlobHeader.DataOffset := BlobDataPos;
            end;
            NewBlobHeader.DataSize := DstBlobSize;
            NewBlobHeader.AreaSize := DstBlobSize + (tdbBlobSizeUnitNum - DstBlobSize mod tdbBlobSizeUnitNum);
          end;
          // 如果起用CRC32校检
          if FDatabase.CRC32 then
          begin
            CRC32Value1 := 0;
            CRC32Value2 := 0;
            repeat
              if CRC32Value1 <> CRC32Value2 then
                FDatabase.DBFileIO.EncodeMemoryStream(BlobStream, DstBlobStream, ShouldEncrypt(I), ShouldCompress(I));
              DstBlobSize := DstBlobStream.Size;
              // 计算原始数据的Checksum Value
              CRC32Value1 := CheckSumCRC32(BlobStream.Memory^, BlobStream.Size);
              // 写入Blob数据
              DBStream.Position := BlobDataPos;
              DBStream.Write(DstBlobStream.Memory^, DstBlobStream.Size);
              // 读入Blob数据
              DBStream.Position := BlobDataPos;
              DBStream.Read(DstBlobStream.Memory^, DstBlobStream.Size);
              // 解码
              try
                FDatabase.DBFileIO.DecodeMemoryStream(DstBlobStream, DstBlobStream1, ShouldEncrypt(I), ShouldCompress(I));
              except
              end;
              // 计算解码后数据的Checksum Value
              CRC32Value2 := CheckSumCRC32(DstBlobStream1.Memory^, DstBlobStream1.Size);
            // 如果两次的Checksum Value相等，则说明校检正确，跳出循环
            until CRC32Value1 = CRC32Value2;
          end else
          // 如果不起用CRC32校检
          begin
            // 直接写入Blob数据
            DBStream.Position := BlobDataPos;
            DBStream.Write(DstBlobStream.Memory^, DstBlobStream.Size);
          end;
          // 填充Blob区域，使得Blob长度为TDBlobSizeUnitNum的整数倍
          DBStream.Write(BlobRestBuf[0], tdbBlobSizeUnitNum - DstBlobSize mod tdbBlobSizeUnitNum);
          // 写入调整后的BlobHeader
          PBlobFieldHeader(DiskRecBuf + FDiskFieldOffsets[I])^ := NewBlobHeader;
        // -------------如果是AutoInc字段-----------------------
        end else if FieldBuffers.Items[I].FieldType = ftAutoInc then
        begin
          // 作改变
          if PInteger(FieldBuffer)^ <> 0 then
          begin
            // 数据编码（加密）
            FDatabase.DBFileIO.EncodeMemoryBuffer(FieldBuffer, DiskRecBuf + FDiskFieldOffsets[I],
              FieldBuffers.Items[I].FieldSize, ShouldEncrypt(I));
            // 调整AutoIncCounter
            if PInteger(FieldBuffer)^ > FTableHeader.AutoIncCounter then
            begin
              FTableHeader.AutoIncCounter := PInteger(FieldBuffer)^;
              BakPos := DBStream.Position;
              DBStream.Position := FDatabase.DBFileIO.TableTab.TableHeaderOffset[FTableIdx] + SizeOf(TTableNameString) + SizeOf(Integer) * 2;
              DBStream.Write(FTableHeader.AutoIncCounter, SizeOf(Integer));
              DBStream.Position := BakPos;
            end;
          end;
        end else
        // -------------其他固定长度数据-------------------------
        begin
          // 数据编码（加密）
          FDatabase.DBFileIO.EncodeMemoryBuffer(FieldBuffer, DiskRecBuf + FDiskFieldOffsets[I],
            FieldBuffers.Items[I].FieldSize, ShouldEncrypt(I));
        end;
      end;
      // 写入数据库
      DBStream.Position := DataOffset;
      DBStream.Write(DiskRecBuf^, FDiskRecSize);
    finally
      // 释放内存
      FreeMem(DiskRecBuf, FDiskRecSize);
      DstBlobStream.Free;
      DstBlobStream1.Free;
    end;
    // 调整索引
    AdjustIndexesForModify(FieldBuffers, PhyRecordIdx, OnAdjustIndex);
    if Flush then FDatabase.DBFileIO.Flush;
  finally
    FDatabase.DBFileIO.Unlock;
  end;
end;

//-----------------------------------------------------------------------------
// 删除记录
// PhyRecordIdx: 物理记录号（即在FRecTabLists[0]中的记录号） 0-based
// Flush: 修改完后是否flush cache
//-----------------------------------------------------------------------------
procedure TTinyTableIO.DeleteRecordData(PhyRecordIdx: Integer; Flush: Boolean);
begin
  FDatabase.DBFileIO.Lock;
  try
    // 在数据库中做删除标记
    WriteDeleteFlag(PhyRecordIdx);
    // 调整索引
    AdjustIndexesForDelete(PhyRecordIdx);
    // 删除FRecTabLists[0]中的对应项目
    DeleteMemRecTabItem(FRecTabLists[0], PhyRecordIdx);
    if Flush then FDatabase.DBFileIO.Flush;
  finally
    FDatabase.DBFileIO.Unlock;
  end;
end;

//-----------------------------------------------------------------------------
// 删除所有记录
//-----------------------------------------------------------------------------
procedure TTinyTableIO.DeleteAllRecords;
var
  I: Integer;
begin
  FDatabase.DBFileIO.Lock;
  try
    // 调整FTableHeader
    FTableHeader.RecTabOffset := 0;
    FTableHeader.RecordTotal := 0;
    FTableHeader.AutoIncCounter := 0;
    for I := 0 to tdbMaxIndex - 1 do
    begin
      FTableHeader.IndexHeader[I].StartIndex := 0;
      FTableHeader.IndexHeader[I].IndexOffset := 0;
    end;
    FDatabase.DBFileIO.WriteTableHeader(TableIdx, FTableHeader);
    FDatabase.DBFileIO.Flush;

    // 清空FRecTabLists
    for I := 0 to High(FRecTabLists) do
      ClearMemRecTab(FRecTabLists[I]);

    // 清空FRecTabBlockOffsets和FIdxTabBlockOffsets
    SetLength(FRecTabBlockOffsets, 0);
    for I := 0 to High(FIdxTabBlockOffsets) do
      SetLength(FIdxTabBlockOffsets[I], 0);
  finally
    FDatabase.DBFileIO.Unlock;
  end;
end;

//-----------------------------------------------------------------------------
// 读取一条记录中某个字段的数据
// DstStream: 结果数据
// DiskRecIndex: 这条记录在文件中RecordTab中的下标号(0-based)
// FieldIdx: 物理字段号(0-based)
//-----------------------------------------------------------------------------
procedure TTinyTableIO.ReadFieldData(DstStream: TMemoryStream; DiskRecIndex, FieldIdx: Integer);
var
  FieldOffset, FieldSize: Integer;
  RecTabItemOffset: Integer;
  FieldType: TFieldType;
begin
  // 取记录表中的第RecIndex个RecTabItem的偏移
  RecTabItemOffset := GetRecTabItemOffset(DiskRecIndex);
  FieldOffset := FDiskFieldOffsets[FieldIdx];
  FieldType := FTableHeader.FieldTab[FieldIdx].FieldType;
  if FieldType in BlobFieldTypes then
    FieldSize := SizeOf(TBlobFieldHeader)
  else
    FieldSize := GetFieldSize(FieldType, FTableHeader.FieldTab[FieldIdx].FieldSize);

  FDatabase.DBFileIO.ReadFieldData(DstStream, RecTabItemOffset, FieldOffset, FieldSize,
    FieldType in BlobFieldTypes, ShouldEncrypt(FieldIdx), ShouldCompress(FieldIdx));
end;

//-----------------------------------------------------------------------------
// 读取记录数据到FieldBuffers中
// RecTabList: 记录集,用于限定RecIndex
// RecIndex: 这条记录在参数RecTabList中的下标号(0-based)
// 注意:
//   FieldBuffer必须事先指定好FieldType, FieldSize, Buffer等信息.
//   如果某些字段不用读取, 可以把对应FieldBufferItem中的Active设为False.
//-----------------------------------------------------------------------------
procedure TTinyTableIO.ReadRecordData(FieldBuffers: TFieldBuffers; RecTabList: TList; RecordIdx: Integer);
var
  SrcDiskRecBuf: PChar;
  RecDataOffset: Integer;
  I, FldSize, DiskOfs: Integer;
  BlobStream: TMemoryStream;
begin
  FDatabase.DBFileIO.Lock;
  SrcDiskRecBuf := AllocMem(FDiskRecSize);
  try
    RecDataOffset := GetMemRecTabItem(RecTabList, RecordIdx).DataOffset;
    FDatabase.DBFileIO.ReadBuffer(SrcDiskRecBuf[0], RecDataOffset, FDiskRecSize);
    for I := 0 to FieldBuffers.Count - 1 do
    begin
      if FieldBuffers.Items[I].Active then
      begin
        DiskOfs := FDiskFieldOffsets[I];
        if not FieldBuffers.Items[I].IsBlob then
        begin
          FldSize := FieldBuffers.Items[I].FFieldSize;
          FDatabase.DBFileIO.DecodeMemoryBuffer(SrcDiskRecBuf + DiskOfs, FieldBuffers.Items[I].Buffer,
            FldSize, ShouldEncrypt(I) );
        end else
        begin
          // 从Buffer中取出BlobStream
          BlobStream := TMemoryStream(FieldBuffers.Items[I].Buffer);
          // 初始化BlobStream
          (BlobStream as TOptimBlobStream).Init(RecDataOffset + DiskOfs, ShouldEncrypt(I), ShouldCompress(I));
        end;
      end;
    end;
  finally
    FreeMem(SrcDiskRecBuf);
    FDatabase.DBFileIO.Unlock;
  end;
end;

{ TTDEDataSet }

constructor TTDEDataSet.Create(AOwner: TComponent);
begin
  inherited;
  ShowNagScreen(Self);           // Show nag-screen.
  FDatabaseName := '';
  FMediumType := mtDisk;
  FCurRec := -1;
  FRecordSize := 0;
  FFilterParser := TFilterParser.Create(Self);
end;

destructor TTDEDataSet.Destroy;
begin
  FFilterParser.Free;
  inherited;
end;

function TTDEDataSet.GetActiveRecBuf(var RecBuf: PChar): Boolean;
begin
  case State of
    dsBrowse: if IsEmpty then RecBuf := nil else RecBuf := ActiveBuffer;
    dsEdit, dsInsert: RecBuf := ActiveBuffer;
    dsSetKey: RecBuf := FKeyBuffer;
    dsCalcFields: RecBuf := CalcBuffer;
    dsFilter: RecBuf := FFilterBuffer;
    dsNewValue: RecBuf := ActiveBuffer;
  else
    RecBuf := nil;
  end;
  Result := RecBuf <> nil;
end;

procedure TTDEDataSet.ActivateFilters;
begin
end;

procedure TTDEDataSet.DeactivateFilters;
begin
end;

procedure TTDEDataSet.ReadRecordData(Buffer: PChar; RecordIdx: Integer);
begin
end;

function TTDEDataSet.GetFieldOffsetByFieldNo(FieldNo: Integer): Integer;
begin
  Result := FFieldOffsets[FieldNo - 1];
end;

procedure TTDEDataSet.ReadFieldData(DstStream: TMemoryStream; FieldDataOffset, FieldSize: Integer;
  IsBlob: Boolean; ShouldEncrypt, ShouldCompress: Boolean);
begin
  Database.DBFileIO.ReadFieldData(DstStream, FieldDataOffset, FieldSize, IsBlob, ShouldEncrypt, ShouldCompress);
end;

function TTDEDataSet.GetRecordCount: Longint;
begin
  Result := 0;
end;

procedure TTDEDataSet.SetMediumType(Value: TTinyDBMediumType);
var
  ADatabase: TTinyDatabase;
begin
  if FMediumType <> Value then
  begin
    CheckInactive;
    FMediumType := Value;
    ADatabase := DBSession.FindDatabase(FDatabaseName);
    if ADatabase <> nil then
      ADatabase.MediumType := FMediumType;
  end;
end;

procedure TTDEDataSet.SetPassword(const Value: string);
var
  ADatabase: TTinyDatabase;
begin
  ADatabase := OpenDatabase(False);
  if ADatabase <> nil then
    ADatabase.SetPassword(Value);
end;

procedure TTDEDataSet.SetCRC32(Value: Boolean);
var
  ADatabase: TTinyDatabase;
begin
  ADatabase := OpenDatabase(False);
  if ADatabase <> nil then
    ADatabase.CRC32 := Value;
end;

function TTDEDataSet.GetCRC32: Boolean;
begin
  Result := (Database <> nil) and Database.CRC32;
end;

function TTDEDataSet.GetCanAccess: Boolean;
begin
  Result := (Database <> nil) and Database.CanAccess;
end;

procedure TTDEDataSet.InitRecordSize;
var
  I: Integer;
begin
  // 初始化FRecordSize
  FRecordSize := 0;
  for I := 0 to Fields.Count - 1 do
  begin
    if Fields[I].FieldNo > 0 then
    begin
      if Fields[I].IsBlob then
        Inc(FRecordSize, SizeOf(PMemoryStream))
      else
        Inc(FRecordSize, Fields[I].DataSize);
    end;
  end;

  // 初始化FRecBufSize
  FRecBufSize := FRecordSize + CalcFieldsSize + SizeOf(TRecInfo);
end;

procedure TTDEDataSet.InitFieldOffsets;
var
  I, Offset, MaxNo: Integer;
begin
  Offset := 0;
  MaxNo := 0;
  for I := 0 to Fields.Count - 1 do
    if MaxNo < Fields[I].FieldNo then
      MaxNo := Fields[I].FieldNo;

  SetLength(FFieldOffsets, MaxNo);
  for I := 0 to Fields.Count - 1 do
  begin
    if Fields[I].FieldNo > 0 then
    begin
      FFieldOffsets[Fields[I].FieldNo - 1] := Offset;
      if Fields[I].IsBlob then
        Inc(Offset, SizeOf(PMemoryStream))
      else
        Inc(Offset, Fields[I].DataSize);
    end;
  end;
end;

function TTDEDataSet.FiltersAccept: Boolean;

  function FuncFilter: Boolean;
  begin
    Result := True;
    if Assigned(OnFilterRecord) then
      OnFilterRecord(Self, Result);
  end;

  function ExprFilter: Boolean;
  begin
    Result := True;
    if Filter <> '' then
      Result := FFilterParser.Calculate(TStrCompOptions(FilterOptions)) <> 0;
  end;

begin
  Result := FuncFilter;
  if Result then Result := ExprFilter;
end;

procedure TTDEDataSet.SetFilterData(const Text: string; Options: TFilterOptions);
var
  Changed: Boolean;
  SaveText: string;
begin
  Changed := False;
  SaveText := Filter;
  if Active then
  begin
    CheckBrowseMode;
    if Text <> '' then FFilterParser.Parse(Text);
    if (Filter <> Text) or (FilterOptions <> Options) then Changed := True;
  end;

  inherited SetFilterText(Text);
  inherited SetFilterOptions(Options);
  try
    if Changed then
      if Filtered then
      begin
        DeactivateFilters;
        ActivateFilters;
      end;
  except
    inherited SetFilterText(SaveText);
    raise;
  end;
end;

procedure TTDEDataSet.AllocKeyBuffers;
var
  KeyIndex: TTDKeyIndex;
begin
  try
    for KeyIndex := Low(TTDKeyIndex) to High(TTDKeyIndex) do
    begin
      FKeyBuffers[KeyIndex] := AllocRecordBuffer;
      InitKeyBuffer(KeyIndex);
    end;
  except
    FreeKeyBuffers;
    raise;
  end;
end;

procedure TTDEDataSet.FreeKeyBuffers;
var
  KeyIndex: TTDKeyIndex;
begin
  for KeyIndex := Low(TTDKeyIndex) to High(TTDKeyIndex) do
    FreeRecordBuffer(FKeyBuffers[KeyIndex]);
end;

procedure TTDEDataSet.InitKeyBuffer(KeyIndex: TTDKeyIndex);
begin
  InternalInitRecord(FKeyBuffers[KeyIndex]);
end;

//-----------------------------------------------------------------------------
// TDataSet calls this method to allocate the record buffer.  Here we use
// FRecBufSize which is equal to the size of the data plus the size of the
// TRecInfo structure.
//-----------------------------------------------------------------------------
function TTDEDataSet.AllocRecordBuffer: PChar;
var
  I, FieldOffset: Integer;
  BlobStream: TMemoryStream;
begin
  Result := AllocMem(FRecBufSize);
  for I := 0 to Fields.Count - 1 do
  begin
    if Fields[I].IsBlob then
    begin
      FieldOffset := GetFieldOffsetByFieldNo(Fields[I].FieldNo);
      BlobStream := TOptimBlobStream.Create(Self);
      PMemoryStream(@Result[FieldOffset])^ := BlobStream;
    end;
  end;
end;

//-----------------------------------------------------------------------------
// Again, TDataSet calls this method to free the record buffer.
// Note: Make sure the value of FRecBufSize does not change before all
// allocated buffers are freed.
//-----------------------------------------------------------------------------
procedure TTDEDataSet.FreeRecordBuffer(var Buffer: PChar);
var
  I, FieldOffset: Integer;
  BlobStream: TMemoryStream;
begin
  if Buffer = nil then Exit;
  for I := 0 to Fields.Count - 1 do
  begin
    if Fields[I].IsBlob then
    begin
      FieldOffset := GetFieldOffsetByFieldNo(Fields[I].FieldNo);
      BlobStream := PMemoryStream(@Buffer[FieldOffset])^;
      if Assigned(BlobStream) then
      begin
        BlobStream.Free;
      end;
    end;
  end;
  FreeMem(Buffer, FRecBufSize);
  Buffer := nil;
end;

procedure TTDEDataSet.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  PInteger(Data)^ := PRecInfo(Buffer + FRecordSize + CalcFieldsSize).Bookmark;
end;

//-----------------------------------------------------------------------------
// Bookmark flags are used to indicate if a particular record is the first
// or last record in the dataset.  This is necessary for "crack" handling.
// If the bookmark flag is bfBOF or bfEOF then the bookmark is not actually
// used; InternalFirst, or InternalLast are called instead by TDataSet.
//-----------------------------------------------------------------------------
function TTDEDataSet.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
  Result := PRecInfo(Buffer + FRecordSize + CalcFieldsSize).BookmarkFlag;
end;

//-----------------------------------------------------------------------------
// This method returns the size of just the data in the record buffer.
// Do not confuse this with RecBufSize which also includes any additonal
// structures stored in the record buffer (such as TRecInfo).
//-----------------------------------------------------------------------------
function TTDEDataSet.GetRecordSize: Word;
begin
  Result := FRecordSize;
end;

//-----------------------------------------------------------------------------
// This routine is called to initialize a record buffer.  In this sample,
// we fill the buffer with zero values, but we might have code to initialize
// default values or do other things as well.
//-----------------------------------------------------------------------------
procedure TTDEDataSet.InternalInitRecord(Buffer: PChar);
var
  I, FieldOffset: Integer;
  BlobStream: TMemoryStream;
  TempDateTime: TDateTime;
  TempTimeStamp: TTimeStamp;
  TempDouble: Double;
  TempInteger: Integer;
begin
  for I := 0 to Fields.Count - 1 do
  begin
    if Fields[I].FieldNo > 0 then
    begin
      FieldOffset := GetFieldOffsetByFieldNo(Fields[I].FieldNo);
      if Fields[I].IsBlob then
      begin
        BlobStream := PMemoryStream(@Buffer[FieldOffset])^;
        BlobStream.Clear;
      end else
      if Fields[I].DataType = ftDateTime then
      begin
        TempDateTime := 0; //Now;
        TempTimeStamp := DateTimeToTimeStamp(TempDateTime);
        TempDouble := TimeStampToMSecs(TempTimeStamp);
        Move(TempDouble, Buffer[FieldOffset], Fields[I].DataSize);
      end else
      if Fields[I].DataType = ftDate then
      begin
        TempInteger := DateTimeToTimeStamp(SysUtils.Date).Date;
        Move(TempInteger, Buffer[FieldOffset], Fields[I].DataSize);
      end else
      if Fields[I].DataType = ftTime then
      begin
        TempInteger := DateTimeToTimeStamp(SysUtils.Time).Time;
        Move(TempInteger, Buffer[FieldOffset], Fields[I].DataSize);
      end else
      begin
        FillChar(Buffer[FieldOffset], Fields[I].DataSize, 0);
      end;
    end else {fkCalculated, fkLookup}
    begin
      FieldOffset := FRecordSize + Fields[I].Offset;
      FillChar(Buffer[FieldOffset], 1, 0);
      if Fields[I].IsBlob then
      begin
        BlobStream := PMemoryStream(@Buffer[FieldOffset + 1])^;
        BlobStream.Clear;
      end else
      begin
        FillChar(Buffer[FieldOffset + 1], Fields[I].DataSize, 0);
      end;
    end;
  end;
end;

//-----------------------------------------------------------------------------
// This method is called by TDataSet.First.  Crack behavior is required.
// That is we must position to a special place *before* the first record.
// Otherwise, we will actually end up on the second record after Resync
// is called.
//-----------------------------------------------------------------------------
procedure TTDEDataSet.InternalFirst;
begin
  FCurRec := -1;
end;

//-----------------------------------------------------------------------------
// Again, we position to the crack *after* the last record here.
//-----------------------------------------------------------------------------
procedure TTDEDataSet.InternalLast;
begin
  FCurRec := RecordCount;
end;

//-----------------------------------------------------------------------------
// This is the exception handler which is called if an exception is raised
// while the component is being stream in or streamed out.  In most cases this
// should be implemented useing the application exception handler as follows. }
//-----------------------------------------------------------------------------
procedure TTDEDataSet.InternalHandleException;
begin
  Application.HandleException(Self);
end;

//-----------------------------------------------------------------------------
// This function does the same thing as InternalGotoBookmark, but it takes
// a record buffer as a parameter instead
//-----------------------------------------------------------------------------
procedure TTDEDataSet.InternalSetToRecord(Buffer: PChar);
begin
  InternalGotoBookmark(@PRecInfo(Buffer + FRecordSize + CalcFieldsSize).Bookmark);
end;

procedure TTDEDataSet.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
  PRecInfo(Buffer + FRecordSize + CalcFieldsSize).BookmarkFlag := Value;
end;

procedure TTDEDataSet.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  PRecInfo(Buffer + FRecordSize + CalcFieldsSize).Bookmark := PInteger(Data)^;
end;

procedure TTDEDataSet.SetFieldData(Field: TField; Buffer: Pointer);
var
  RecBuf: PChar;
  FieldOffset: Integer;
begin
  if not GetActiveRecBuf(RecBuf) then Exit;

  if Field.FieldNo > 0 then
  begin
    if Buffer <> nil then
    begin
      FieldOffset := GetFieldOffsetByFieldNo(Field.FieldNo);
      if Field.IsBlob then
      begin
        DatabaseError(SGeneralError);
      end else
      begin
        Move(Buffer^, RecBuf[FieldOffset], Field.DataSize);
      end;
      DataEvent(deFieldChange, Longint(Field));
    end;
  end else {fkCalculated, fkLookup}
  begin
    Inc(RecBuf, FRecordSize + Field.Offset);
    Boolean(RecBuf[0]) := LongBool(Buffer);
    if Boolean(RecBuf[0]) then Move(Buffer^, RecBuf[1], Field.DataSize);
  end;
  if (State <> dsCalcFields) and (State <> dsFilter) then
    DataEvent(deFieldChange, Longint(Field));
end;

//-----------------------------------------------------------------------------
// This property is used while opening the dataset.
// It indicates if data is available even though the
// current state is still dsInActive.
//-----------------------------------------------------------------------------
function TTDEDataSet.IsCursorOpen: Boolean;
begin
  Result := False;
end;

procedure TTDEDataSet.DataConvert(Field: TField; Source, Dest: Pointer; ToNative: Boolean);

  { DateTime Conversions }

  function NativeToDateTime(DataType: TFieldType; Data: TDateTimeRec): TDateTime;
  var
    TimeStamp: TTimeStamp;
  begin
    case DataType of
      ftDate:
        begin
          TimeStamp.Time := 0;
          TimeStamp.Date := Data.Date;
        end;
      ftTime:
        begin
          TimeStamp.Time := Data.Time;
          TimeStamp.Date := DateDelta;
        end;
    else
      try
        TimeStamp := MSecsToTimeStamp(Data.DateTime);
      except
        TimeStamp.Time := 0;
        TimeStamp.Date := 0;
      end;
    end;
    try
      Result := TimeStampToDateTime(TimeStamp);
    except
      Result := 0;
    end;
  end;

  function DateTimeToNative(DataType: TFieldType; Data: TDateTime): TDateTimeRec;
  var
    TimeStamp: TTimeStamp;
  begin
    TimeStamp := DateTimeToTimeStamp(Data);
    case DataType of
      ftDate: Result.Date := TimeStamp.Date;
      ftTime: Result.Time := TimeStamp.Time;
    else
      Result.DateTime := TimeStampToMSecs(TimeStamp);
    end;
  end;

begin
  case Field.DataType of
    ftDate, ftTime, ftDateTime:
      if ToNative then
        TDateTimeRec(Dest^) := DateTimeToNative(Field.DataType, TDateTime(Source^)) else
        TDateTime(Dest^) := NativeToDateTime(Field.DataType, TDateTimeRec(Source^));
  else
    inherited;
  end;
end;

function TTDEDataSet.GetRecNo: Longint;
begin
  UpdateCursorPos;
  if (FCurRec = -1) and (RecordCount > 0) then
    Result := 1
  else
    Result := FCurRec + 1;
end;

procedure TTDEDataSet.SetRecNo(Value: Integer);
begin
  CheckBrowseMode;
  if (Value >= 0) and (Value <= RecordCount) and (Value <> RecNo) then
  begin
    DoBeforeScroll;
    FCurRec := Value - 1;
    Resync([]);
    DoAfterScroll;
  end;
end;

function TTDEDataSet.GetCanModify: Boolean;
begin
  Result := FCanModify;
end;

procedure TTDEDataSet.SetFiltered(Value: Boolean);
begin
  if Active then
  begin
    CheckBrowseMode;
    if Filtered <> Value then
    begin
      if Value then ActivateFilters
      else DeactivateFilters;
      inherited SetFiltered(Value);
    end;
    First;
  end else
    inherited SetFiltered(Value);
end;

procedure TTDEDataSet.SetFilterOptions(Value: TFilterOptions);
begin
  SetFilterData(Filter, Value);
end;

procedure TTDEDataSet.SetFilterText(const Value: string);
begin
  SetFilterData(Value, FilterOptions);
end;

procedure TTDEDataSet.DoAfterOpen;
begin
  if Filtered then ActivateFilters;
  inherited;
end;

function TTDEDataSet.FindRecord(Restart, GoForward: Boolean): Boolean;
var
  RecIdx, Step, StartIdx, EndIdx: Integer;
  SaveCurRec: Integer;
  Accept: Boolean;
begin
  CheckBrowseMode;
  DoBeforeScroll;
  SetFound(False);
  UpdateCursorPos;
  CursorPosChanged;

  if GoForward then
  begin
    Step := 1;
    if Restart then StartIdx := 0
    else StartIdx := FCurRec + 1;
    EndIdx := RecordCount - 1;
  end else
  begin
    Step := -1;
    if Restart then StartIdx := RecordCount - 1
    else StartIdx := FCurRec - 1;
    EndIdx := 0;
  end;

  if Filter <> '' then FFilterParser.Parse(Filter);
  SaveCurRec := FCurRec;
  SetTempState(dsFilter);
  try
    Accept := False;
    RecIdx := StartIdx;
    while (GoForward and (RecIdx <= EndIdx)) or
      (not GoForward and (RecIdx >= EndIdx)) do
    begin
      FCurRec := RecIdx;
      FFilterBuffer := ActiveBuffer;
      ReadRecordData(FFilterBuffer, FCurRec);
      Accept := FiltersAccept;
      if Accept then Break;
      Inc(RecIdx, Step);
    end;
  finally
    RestoreState(dsBrowse);
  end;

  if Accept then
  begin
    SetFound(True);
  end else
  begin
    FCurRec := SaveCurRec;
  end;
  Resync([rmExact, rmCenter]);
  Result := Found;
  if Result then DoAfterScroll;
end;

function TTDEDataSet.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
  Result := TTinyBlobStream.Create(Field as TBlobField, Mode);
end;

//-----------------------------------------------------------------------------
// 从RecordBuffer中取出字段值
// 返回:
//   True:       成功,且值不为空
//   False:      失败,或者值为空
//-----------------------------------------------------------------------------
function TTDEDataSet.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
var
  RecBuf: PChar;
  FieldOffset: Integer;
begin
  Result := GetActiveRecBuf(RecBuf);
  if not Result then Exit;

  if Field.FieldNo > 0 then
  begin
    if Buffer <> nil then
    begin
      FieldOffset := GetFieldOffsetByFieldNo(Field.FieldNo);
      if Field.IsBlob then
      begin
        DatabaseError(SGeneralError);
      end else
      begin
        Move(RecBuf[FieldOffset], Buffer^, Field.DataSize);
      end;
      Result := True;
    end;
  end else {fkCalculated, fkLookup}
  begin
    FieldOffset := FRecordSize + Field.Offset;
    Result := Boolean(RecBuf[FieldOffset]);
    if Result and (Buffer <> nil) then
      Move((RecBuf + FieldOffset + 1)^, Buffer^, Field.DataSize);
  end;
end;

{ TTDBDataSet }

constructor TTDBDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if AOwner is TTinyDatabase then
  begin
    DatabaseName := TTinyDatabase(AOwner).DatabaseName;
    SessionName := TTinyDatabase(AOwner).SessionName;
  end;
end;

procedure TTDBDataSet.CheckDBSessionName;
var
  S: TTinySession;
  Database: TTinyDatabase;
begin
  if (SessionName <> '') and (DatabaseName <> '') then
  begin
    S := Sessions.FindSession(SessionName);
    if Assigned(S) and not Assigned(S.DoFindDatabase(DatabaseName, Self)) then
    begin
      Database := DefaultSession.DoFindDatabase(DatabaseName, Self);
      if Assigned(Database) then Database.CheckSessionName(True);
    end;
  end;
end;

procedure TTDBDataSet.OpenCursor(InfoQuery: Boolean);
begin
  CheckDBSessionName;
  FDatabase := OpenDatabase(True);
  FDatabase.RegisterClient(Self);
  FDatabase.CheckCanAccess;
  inherited;
end;

procedure TTDBDataSet.CloseCursor;
begin
  inherited;
  if FDatabase <> nil then
  begin
    FDatabase.UnregisterClient(Self);
    FDatabase.Session.CloseDatabase(FDatabase);
    FDatabase := nil;
  end;
end;

function TTDBDataSet.OpenDatabase(IncRef: Boolean): TTinyDatabase;
begin
  with Sessions.List[FSessionName] do
    Result := DoOpenDatabase(FDatabasename, Self.Owner, Self, IncRef);
end;

procedure TTDBDataSet.CloseDatabase(Database: TTinyDatabase);
begin
  if Assigned(Database) then
    Database.Session.CloseDatabase(Database);
end;

procedure TTDBDataSet.Disconnect;
begin
  Close;
end;

function TTDBDataSet.GetDBSession: TTinySession;
begin
  if (FDatabase <> nil) then
    Result := FDatabase.Session
  else
    Result := Sessions.FindSession(SessionName);
  if Result = nil then Result := DefaultSession;
end;

procedure TTDBDataSet.SetDatabaseName(const Value: string);
begin
  if csReading in ComponentState then
    FDatabaseName := Value
  else if FDatabaseName <> Value then
  begin
    CheckInactive;
    if FDatabase <> nil then DatabaseError(SDatabaseOpen, Self);
    FDatabaseName := Value;
    DataEvent(dePropertyChange, 0);
  end;
end;

procedure TTDBDataSet.SetSessionName(const Value: string);
begin
  CheckInactive;
  FSessionName := Value;
  DataEvent(dePropertyChange, 0);
end;

{ TTinyTable }

constructor TTinyTable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTableName := '';
  FIndexName := '';
  FIndexIdx := -1;
  FUpdateCount := 0;
  FIndexDefs := TIndexDefs.Create(Self);
  FMasterLink := TMasterDataLink.Create(Self);
  FMasterLink.OnMasterChange := MasterChanged;
  FMasterLink.OnMasterDisable := MasterDisabled;
end;

destructor TTinyTable.Destroy;
begin
  FIndexDefs.Free;
  FMasterLink.Free;
  inherited Destroy;
end;

function TTinyTable.GetRecordCount: Integer;
begin
  if FRecTabList = nil then
    Result := 0
  else
    Result := FRecTabList.Count;
end;

function TTinyTable.GetCanModify: Boolean;
begin
  Result := inherited GetCanModify and not ReadOnly and not Database.DBFileIO.FileIsReadOnly;
end;

function TTinyTable.GetDataSource: TDataSource;
begin
  Result := FMasterLink.DataSource;
end;

procedure TTinyTable.SetDatabaseName(const Value: string);
begin
  inherited;
  FTableName := '';
  FIndexName := '';
end;

procedure TTinyTable.DoAfterOpen;
begin
  CheckMasterRange;
  inherited;
end;

procedure TTinyTable.SetTableName(const Value: string);
begin
  if FTableName <> Value then
  begin
    CheckInactive;
    FTableName := Value;
  end;
end;

procedure TTinyTable.SetIndexName(const Value: string);
begin
  if Value = '' then
  begin
    FIndexName := Value;
    FIndexIdx := -1;
  end else
  begin
    FIndexName := Value;
  end;
  if Active then
  begin
    CheckBrowseMode;
    FIndexIdx := FTableIO.IndexDefs.IndexOf(FIndexName);
    if FIndexIdx = -1 then
      FIndexIdx := FTableIO.CheckPrimaryFieldExists;
    SwitchToIndex(FIndexIdx);
    CheckMasterRange;
    First;
  end;
end;

procedure TTinyTable.SetReadOnly(Value: Boolean);
begin
  FReadOnly := Value;
end;

procedure TTinyTable.SetMasterFields(const Value: string);
var
  SaveValue: string;
begin
  SaveValue := FMasterLink.FieldNames;
  try
    FMasterLink.FieldNames := Value;
  except
    FMasterLink.FieldNames := SaveValue;
    raise;
  end;
end;

procedure TTinyTable.SetDataSource(Value: TDataSource);
begin
  if IsLinkedTo(Value) then DatabaseError(SCircularDataLink, Self);
  FMasterLink.DataSource := Value;
end;

function TTinyTable.GetTableIdx: Integer;
begin
  if FTableIO <> nil then
    Result := FTableIO.TableIdx
  else
    Result := -1;
end;

function TTinyTable.GetMasterFields: string;
begin
  Result := FMasterLink.FieldNames;
end;

procedure TTinyTable.InitIndexDefs;
var
  I, J: Integer;
  IndexName, Fields: string;
  Options: TIndexOptions;
  List: TStrings;
begin
  List := TStringList.Create;
  FIndexDefs.Clear;
  for I := 0 to FTableIO.IndexDefs.Count - 1 do
  begin
    IndexName := FTableIO.IndexDefs[I].Name;
    List.Clear;
    for J := 0 to High(FTableIO.IndexDefs[I].FieldIdxes) do
      List.Add(FTableIO.FieldDefs[FTableIO.IndexDefs[I].FieldIdxes[J]].Name);
    Fields := List.CommaText;
    Options := [];
    if tiPrimary in FTableIO.IndexDefs[I].Options then Include(Options, ixPrimary);
    if tiUnique in FTableIO.IndexDefs[I].Options then Include(Options, ixUnique);
    if tiDescending in FTableIO.IndexDefs[I].Options then Include(Options, ixDescending);
    if tiCaseInsensitive in FTableIO.IndexDefs[I].Options then Include(Options, ixCaseInsensitive);

    FIndexDefs.Add(IndexName, Fields, Options);
  end;
  List.Free;
end;

procedure TTinyTable.InitCurRecordTab;
begin
  FIndexIdx := FTableIO.IndexDefs.IndexOf(FIndexName);
  if FIndexIdx = -1 then
    FIndexIdx := FTableIO.CheckPrimaryFieldExists;
  SwitchToIndex(FIndexIdx);
end;

procedure TTinyTable.ClearMemRecTab(AList: TList);
var
  I: Integer;
begin
  if not Assigned(AList) then Exit;
  for I := 0 to AList.Count - 1 do
    Dispose(PMemRecTabItem(AList.Items[I]));
  AList.Clear;
end;

procedure TTinyTable.AddMemRecTabItem(AList: TList; Value: TMemRecTabItem);
var
  MemRecTabItemPtr: PMemRecTabItem;
begin
  New(MemRecTabItemPtr);
  MemRecTabItemPtr^ := Value;
  AList.Add(MemRecTabItemPtr);
end;

procedure TTinyTable.InsertMemRecTabItem(AList: TList; Index: Integer; Value: TMemRecTabItem);
var
  MemRecTabItemPtr: PMemRecTabItem;
begin
  New(MemRecTabItemPtr);
  MemRecTabItemPtr^ := Value;
  AList.Insert(Index, MemRecTabItemPtr);
end;

procedure TTinyTable.DeleteMemRecTabItem(AList: TList; Index: Integer);
var
  F: PMemRecTabItem;
begin
  F := AList.Items[Index];
  Dispose(F);
  AList.Delete(Index);
end;

function TTinyTable.GetMemRecTabItem(AList: TList; Index: Integer): TMemRecTabItem;
begin
  Result := PMemRecTabItem(AList.Items[Index])^;
end;

//-----------------------------------------------------------------------------
// 切换索引
// IndexIdx: 索引号 0-based
//-----------------------------------------------------------------------------
procedure TTinyTable.SwitchToIndex(IndexIdx: Integer);
var
  I: Integer;
  MemRecTabItemPtr: PMemRecTabItem;
begin
  FTableIO.InitRecTabList(IndexIdx + 1);

  ClearMemRecTab(FRecTabList);
  for I := 0 to FTableIO.RecTabLists[IndexIdx + 1].Count - 1 do
  begin
    New(MemRecTabItemPtr);
    MemRecTabItemPtr^ := PMemRecTabItem(FTableIO.RecTabLists[IndexIdx + 1].Items[I])^;
    FRecTabList.Add(MemRecTabItemPtr);
  end;

  FCanModify := True;
end;

//-----------------------------------------------------------------------------
// 读取记录数据到Buffer中
// RecordIdx: 在当前记录集中的记录号 0-based
// 注：Buffer中数据存放格式按照TDataSet.ActiveBuffer定义
//     非Blob字段按顺序排列，Blob字段用PMemoryStream代替
//-----------------------------------------------------------------------------
procedure TTinyTable.ReadRecordData(Buffer: PChar; RecordIdx: Integer);
var
  FieldBuffers: TFieldBuffers;
begin
  if (RecordIdx < 0) or (RecordIdx >= RecordCount) then Exit;

  FieldBuffers := TFieldBuffers.Create;
  RecordBufferToFieldBuffers(Buffer, FieldBuffers);
  FTableIO.ReadRecordData(FieldBuffers, FRecTabList, RecordIdx);
  FieldBuffers.Free;
end;

//-----------------------------------------------------------------------------
// AppendRecordData的回调函数
//-----------------------------------------------------------------------------
procedure TTinyTable.OnAdjustIndexForAppend(IndexIdx, InsertPos: Integer; MemRecTabItem: TMemRecTabItem);
var
  Pos, ResultState: Integer;
begin
  if not Filtered and not FSetRanged then
  begin
    if FIndexIdx = IndexIdx then
    begin
      if FIndexIdx = -1 then
      begin
        AddMemRecTabItem(FRecTabList, MemRecTabItem);
      end else
      begin
        // 调整FRecTabList
        InsertMemRecTabItem(FRecTabList, InsertPos, MemRecTabItem);
        // 调整FCurRec
        FCurRec := InsertPos;
      end;
    end;
  end else
  begin
    if FIndexIdx = IndexIdx then
    begin
      if FIndexIdx = -1 then
      begin
        AddMemRecTabItem(FRecTabList, MemRecTabItem);
      end else
      begin
        // 查找应插入的位置
        Pos := SearchInsertPos(IndexIdx, ResultState);
        // 调整FRecTabList
        InsertMemRecTabItem(FRecTabList, Pos, MemRecTabItem);
        // 调整FCurRec
        FCurRec := Pos;
      end;
    end;
  end;
end;

//-----------------------------------------------------------------------------
// 将Buffer中的数据新增到数据库中
// 注：Buffer 中数据格式的定义同ReadRecordData
//-----------------------------------------------------------------------------
procedure TTinyTable.AppendRecordData(Buffer: PChar);
var
  FieldBuffers: TFieldBuffers;
begin
  FieldBuffers := TFieldBuffers.Create;
  try
    RecordBufferToFieldBuffers(Buffer, FieldBuffers);
    FTableIO.AppendRecordData(FieldBuffers, (FUpdateCount = 0) and Database.FlushCacheAlways, OnAdjustIndexForAppend);
  finally
    FieldBuffers.Free;
  end;
end;

//-----------------------------------------------------------------------------
// ModifyRecordData的回调函数
//-----------------------------------------------------------------------------
procedure TTinyTable.OnAdjustIndexForModify(IndexIdx, FromRecIdx, ToRecIdx: Integer);
var
  MemRecTabItem: TMemRecTabItem;
  Pos, ResultState: Integer;
begin
  if not Filtered and not FSetRanged then
  begin
    // 如果是当前索引
    if FIndexIdx = IndexIdx then
    begin
      // 因为在对FRecTabList Insert之前先要做Delete，故ToRecIdx需要调整。
      if ToRecIdx > FromRecIdx then Dec(ToRecIdx);
      // 调整FRecTabList
      MemRecTabItem := GetMemRecTabItem(FRecTabList, FromRecIdx);
      DeleteMemRecTabItem(FRecTabList, FromRecIdx);
      InsertMemRecTabItem(FRecTabList, ToRecIdx, MemRecTabItem);
      // 调整FCurRec
      FCurRec := ToRecIdx;
    end;
  end else
  begin
    // 如果是当前索引
    if FIndexIdx = IndexIdx then
    begin
      // 调整FRecTabList
      MemRecTabItem := GetMemRecTabItem(FRecTabList, FCurRec);
      DeleteMemRecTabItem(FRecTabList, FCurRec);
      // 查找应插入的位置
      Pos := SearchInsertPos(IndexIdx, ResultState);
      InsertMemRecTabItem(FRecTabList, Pos, MemRecTabItem);
      // 调整FCurRec
      FCurRec := Pos;
    end;
  end;
end;

//-----------------------------------------------------------------------------
// 将Buffer中的数据写入到数据库的第RecordIdx条记录中
// RecordIdx: 当前记录集中的记录号 0-based
// 注：Buffer 中数据格式的定义同ReadRecordData
//-----------------------------------------------------------------------------
procedure TTinyTable.ModifyRecordData(Buffer: PChar; RecordIdx: Integer);
var
  FieldBuffers: TFieldBuffers;
  PhyRecordIdx: Integer;
begin
  if (RecordIdx < 0) or (RecordIdx >= RecordCount) then Exit;
  FTableIO.ConvertRecIdxForPhy(FRecTabList, RecordIdx, PhyRecordIdx);

  FieldBuffers := TFieldBuffers.Create;
  try
    RecordBufferToFieldBuffers(Buffer, FieldBuffers);
    FTableIO.ModifyRecordData(FieldBuffers, PhyRecordIdx, (FUpdateCount = 0) and Database.FlushCacheAlways, OnAdjustIndexForModify);
  finally
    FieldBuffers.Free;
  end;
end;

//-----------------------------------------------------------------------------
// 删除记录
// RecordIdx: 当前记录集中的记录号 0-based
//-----------------------------------------------------------------------------
procedure TTinyTable.DeleteRecordData(RecordIdx: Integer);
var
  PhyRecordIdx: Integer;
begin
  if (RecordIdx < 0) or (RecordIdx >= RecordCount) then Exit;

  FTableIO.ConvertRecIdxForPhy(FRecTabList, RecordIdx, PhyRecordIdx);
  FTableIO.DeleteRecordData(PhyRecordIdx, (FUpdateCount = 0) and Database.FlushCacheAlways);
  // 删除FRecTabList中的对应项目
  DeleteMemRecTabItem(FRecTabList, RecordIdx);
end;

//-----------------------------------------------------------------------------
// 删除所有记录
//-----------------------------------------------------------------------------
procedure TTinyTable.DeleteAllRecords;
begin
  FTableIO.DeleteAllRecords;
  ClearMemRecTab(FRecTabList);
  FCurRec := -1;
end;

//-----------------------------------------------------------------------------
// 根据索引查找离指定数据最近的位置（二分法）
// RecTabList: 要查找的记录集，注意：必须是已排序的记录集
// IndexIdx: 索引号 0-based
// ResultState: 存放搜索结果状态
//     0:  待查找的值 = 查找结果位置的值
//     1:  待查找的值 > 查找结果位置的值
//    -1:  待查找的值 < 查找结果位置的值
//    -2:  无记录
// EffFieldCount: Fields中有效字段个数。缺省为0时表示按复合索引中实际字段数计算
// PartialCompare: 字符串的部分匹配
// 返回值：在RecTabList中的记录号(0-based)，如果无记录则返回-1
// 注：待查找数据应事先存放于Fields中
//-----------------------------------------------------------------------------
function TTinyTable.SearchIndexedField(RecTabList: TList; IndexIdx: Integer;
  var ResultState: Integer; EffFieldCount: Integer; PartialCompare: Boolean): Integer;
var
  FieldBuffers: TFieldBuffers;
  RecBuf: PChar;
begin
  FieldBuffers := TFieldBuffers.Create;
  GetActiveRecBuf(RecBuf);
  RecordBufferToFieldBuffers(RecBuf, FieldBuffers);
  Result := FTableIO.SearchIndexedField(FieldBuffers, RecTabList, IndexIdx, ResultState, EffFieldCount, PartialCompare);
  FieldBuffers.Free;
end;

//-----------------------------------------------------------------------------
// 根据索引查找离指定数据的边界位置（二分法）
// RecTabList: 要查找的记录集，注意：必须是已排序的记录集
// IndexIdx: 索引号 0-based
// LowBound: 为True时查找低边界，为False时查找高边界
// ResultState: 存放搜索结果状态，定义同SearchIndexedField
// EffFieldCount: Fields中有效字段个数。缺省为0时表示按复合索引中实际字段数计算
// PartialCompare: 字符串的部分匹配
// 返回值：在RecTabList中的记录号(0-based)，如果无记录则返回-1
// 注：
// 1.待查找数据应事先存放于Fields中
//-----------------------------------------------------------------------------
function TTinyTable.SearchIndexedFieldBound(RecTabList: TList; IndexIdx: Integer;
  LowBound: Boolean; var ResultState: Integer; EffFieldCount: Integer; PartialCompare: Boolean): Integer;
var
  FieldBuffers: TFieldBuffers;
  RecBuf: PChar;
begin
  FieldBuffers := TFieldBuffers.Create;
  GetActiveRecBuf(RecBuf);
  RecordBufferToFieldBuffers(RecBuf, FieldBuffers);
  Result := FTableIO.SearchIndexedFieldBound(FieldBuffers, RecTabList, IndexIdx, LowBound, ResultState, EffFieldCount, PartialCompare);
  FieldBuffers.Free;
end;

//-----------------------------------------------------------------------------
// 根据索引求取SubRangeStart的位置
// RecTabList: 要查找的记录集，注意：必须是已排序的记录集
// IndexIdx: 索引号（0-based），应对应于RecTabList的排序索引
// ResultState: 存放搜索结果状态，定义同SearchIndexedField
// EffFieldCount: Fields中有效字段个数。缺省为0时表示按复合索引中实际字段数计算
// 返回值：求得结果，在RecTabList中的记录号(0-based)
// 注：1.待查找的记录数据应事先存放于Fields中
//-----------------------------------------------------------------------------
function TTinyTable.SearchRangeStart(RecTabList: TList; IndexIdx: Integer;
  var ResultState: Integer; EffFieldCount: Integer): Integer;
var
  SaveState: TDataSetState;
  SaveKeyBuffer: PChar;
begin
  SaveState := SetTempState(dsSetKey);
  SaveKeyBuffer := FKeyBuffer;
  FKeyBuffer := FKeyBuffers[tkRangeStart];
  try
    Result := SearchIndexedFieldBound(RecTabList, IndexIdx, True, ResultState, EffFieldCount);
    if ResultState = 1 then Inc(Result);
  finally
    RestoreState(SaveState);
    FKeyBuffer := SaveKeyBuffer;
  end;
end;

//-----------------------------------------------------------------------------
// 根据索引求取RangeEnd的位置
// RecTabList: 要查找的记录集，注意：必须是已排序的记录集
// IndexIdx: 索引号（0-based），应对应于RecTabList的排序索引
// ResultState: 存放搜索结果状态，定义同SearchIndexedField
// EffFieldCount: Fields中有效字段个数。缺省为0时表示按复合索引中实际字段数计算
// 返回值：求得结果，在RecTabList中的记录号(0-based)
// 注：1.待查找的记录数据应事先存放于Fields中
//-----------------------------------------------------------------------------
function TTinyTable.SearchRangeEnd(RecTabList: TList; IndexIdx: Integer;
  var ResultState: Integer; EffFieldCount: Integer): Integer;
var
  SaveState: TDataSetState;
  SaveKeyBuffer: PChar;
begin
  SaveState := SetTempState(dsSetKey);
  SaveKeyBuffer := FKeyBuffer;
  FKeyBuffer := FKeyBuffers[tkRangeEnd];
  try
    Result := SearchIndexedFieldBound(RecTabList, IndexIdx, False, ResultState, EffFieldCount);
    if ResultState = -1 then Dec(Result);
  finally
    RestoreState(SaveState);
    FKeyBuffer := SaveKeyBuffer;
  end;
end;

//-----------------------------------------------------------------------------
// 根据索引查找记录
// RecTabList: 要查找的记录集，注意：必须是已排序的记录集
// IndexIdx: 索引号（0-based），应对应于RecTabList的排序索引
// EffFieldCount: Fields中有效字段个数。缺省为0时表示按复合索引中实际字段数计算
// GotoKey和GotoNearest要用到此函数
//-----------------------------------------------------------------------------
function TTinyTable.SearchKey(RecTabList: TList; IndexIdx: Integer;
  EffFieldCount: Integer; Nearest: Boolean): Boolean;
var
  Pos, ResultState, CurRec: Integer;
  SaveState: TDataSetState;
begin
  Result := False;
  if IndexIdx = -1 then Exit;

  SaveState := SetTempState(dsSetKey);
  try
    Pos := SearchIndexedField(RecTabList, IndexIdx, ResultState, EffFieldCount, True);
    FTableIO.ConvertRecordIdx(RecTabList, Pos, FRecTabList, CurRec);

    if ResultState = -2 then          // 无记录，返回False
    begin
      Result := False;
    end else if (ResultState = 0) and (CurRec <> -1) then  // 找到
    begin
      FCurRec := CurRec;
      Result := True;
    end else                          // 找到相似记录
    begin
      if Nearest then
        if CurRec <> -1 then
          FCurRec := CurRec;
      Result := Nearest;
    end;
  finally
    RestoreState(SaveState);
  end;
end;

function TTinyTable.SearchInsertPos(IndexIdx: Integer; var ResultState: Integer): Integer;
begin
  Result := SearchIndexedField(FRecTabList, IndexIdx, ResultState);
  if ResultState in [0, 1] then Inc(Result)
  else if ResultState = -2 then Result := 0;
end;

//-----------------------------------------------------------------------------
// FindKey, SetRange要用到此过程
//-----------------------------------------------------------------------------
procedure TTinyTable.SetKeyFields(KeyIndex: TTDKeyIndex; const Values: array of const);
begin
  if FIndexIdx = -1 then DatabaseError(SNoFieldIndexes, Self);
  SetKeyFields(FIndexIdx, KeyIndex, Values);
end;

procedure TTinyTable.SetKeyFields(IndexIdx: Integer; KeyIndex: TTDKeyIndex; const Values: array of const);
var
  I, FieldIdx: Integer;
  SaveState: TDataSetState;
begin
  SaveState := SetTempState(dsSetKey);
  try
    InitKeyBuffer(KeyIndex);
    FKeyBuffer := FKeyBuffers[KeyIndex];
    for I := 0 to High(FTableIO.IndexDefs[IndexIdx].FieldIdxes) do
    begin
      FieldIdx := FTableIO.IndexDefs[IndexIdx].FieldIdxes[I];
      if I <= High(Values) then
      begin
        Fields[FieldIdx].AssignValue(Values[I]);
      end else
        Fields[FieldIdx].Clear;
    end;
  finally
    RestoreState(SaveState);
  end;
end;

function TTinyTable.LocateRecord(const KeyFields: string; const KeyValues: Variant;
  Options: TLocateOptions; SyncCursor: Boolean): Boolean;

  function SearchOrderly(AFields: TList): Integer;
  var
    DataStream: TMemoryStream;
    RecIdx, FieldIdx, CompRes, I: Integer;
    MemRecTabItem: TMemRecTabItem;
    FieldType: TFieldType;
    RecBuf: PChar;
  begin
    Result := -1;
    DataStream := TMemoryStream.Create;
    try
      GetActiveRecBuf(RecBuf);
      for RecIdx := 0 to RecordCount - 1 do
      begin
        MemRecTabItem := GetMemRecTabItem(FRecTabList, RecIdx);
        CompRes := 0;
        for I := 0 to AFields.Count - 1 do
        begin
          FieldIdx := TField(AFields[I]).FieldNo - 1;
          FieldType := TField(AFields[I]).DataType;
          FTableIO.ReadFieldData(DataStream, MemRecTabItem.RecIndex, FieldIdx);
          CompRes := FTableIO.CompFieldData(RecBuf + FFieldOffsets[FieldIdx],
            DataStream.Memory, FieldType, loCaseInsensitive in Options, loPartialKey in Options);
          if CompRes <> 0 then Break;
        end;
        if CompRes = 0 then
        begin
          Result := RecIdx;
          Break;
        end;
      end;
    finally
      DataStream.Free;
    end;
  end;

  function SearchByIndex(AFields: TList; IndexIdx: Integer): Integer;
  var
    ResultState: Integer;
    RecIdx, DstRecIdx: Integer;
  begin
    Result := -1;
    RecIdx := SearchIndexedField(FTableIO.RecTabLists[IndexIdx+1], IndexIdx, ResultState, 0, loPartialKey in Options);
    if (RecIdx <> -1) and (ResultState = 0) then
    begin
      FTableIO.ConvertRecIdxForCur(IndexIdx, RecIdx, FRecTabList, DstRecIdx);
      if (DstRecIdx >= 0) and (DstRecIdx < RecordCount) then
        Result := DstRecIdx;
    end;
  end;

var
  I, FieldCount, RecIdx, IndexIdx: Integer;
  Buffer: PChar;
  Fields: TList;
begin
  CheckBrowseMode;
  CursorPosChanged;

  Buffer := TempBuffer;
  Fields := TList.Create;
  SetTempState(dsFilter);
  FFilterBuffer := Buffer;
  try
    GetFieldList(Fields, KeyFields);

    FieldCount := Fields.Count;
    if FieldCount = 1 then
    begin
      if VarIsArray(KeyValues) then
        TField(Fields.First).Value := KeyValues[0] else
        TField(Fields.First).Value := KeyValues;
    end else
      for I := 0 to FieldCount - 1 do
        TField(Fields[I]).Value := KeyValues[I];

    IndexIdx := MapsToIndexForSearch(Fields, loCaseInsensitive in Options);
    if IndexIdx = -1 then
      RecIdx := SearchOrderly(Fields)
    else
      RecIdx := SearchByIndex(Fields, IndexIdx);
    Result := RecIdx <> -1;
    if Result then
    begin
      ReadRecordData(Buffer, RecIdx);
      if SyncCursor then FCurRec := RecIdx;
    end;

  finally
    RestoreState(dsBrowse);
    Fields.Free;
  end;
end;

//-----------------------------------------------------------------------------
// 检查即将要查找的Fields是否和某个索引匹配
// 返回：如果找到匹配则返回索引号(0-based)，没有则返回-1
//-----------------------------------------------------------------------------
function TTinyTable.MapsToIndexForSearch(Fields: TList; CaseInsensitive: Boolean): Integer;
var
  I, J: Integer;
  HasStr, Ok: Boolean;
begin
  Result := -1;
  HasStr := False;
  for I := 0 to Fields.Count - 1 do
  begin
    HasStr := TField(Fields[I]).DataType in [ftString, ftFixedChar, ftWideString];
    if HasStr then Break;
  end;
  for I := 0 to FTableIO.IndexDefs.Count - 1 do
  begin
    Ok := True;
    if not HasStr or (CaseInsensitive = (tiCaseInsensitive in FTableIO.IndexDefs[I].Options)) then
    begin
      if Fields.Count = Length(FTableIO.IndexDefs[I].FieldIdxes) then
      begin
        for J := 0 to High(FTableIO.IndexDefs[I].FieldIdxes) do
        begin
          if TField(Fields[J]).FieldNo - 1 <> FTableIO.IndexDefs[I].FieldIdxes[J] then
          begin
            Ok := False;
            Break;
          end;
        end;
      end else
        Ok := False;
    end else
      Ok := False;
    if Ok then
    begin
      Result := I;
      Break;
    end;
  end;
end;

//-----------------------------------------------------------------------------
// 检查Filter是否可以匹配索引，以便作优化处理
//-----------------------------------------------------------------------------
function TTinyTable.CheckFilterMapsToIndex: Boolean;
var
  Node: TExprNode;
  I, FieldIdx: Integer;
  Exists: Boolean;
begin
  Result := True;

  if Assigned(OnFilterRecord) then
  begin
    Result := False;
    Exit;
  end;
  
  Node := FFilterParser.FExprNodes.FNodes;
  while Node <> nil do
  begin
    if Node.FKind = enField then
    begin
      FieldIdx := FTableIO.FieldDefs.IndexOf(Node.FData);
      if FieldIdx = -1 then
      begin
        Result := False;
        Break;
      end else
      begin
        Exists := False;
        for I := 0 to FTableIO.IndexDefs.Count - 1 do
          if (Length(FTableIO.IndexDefs[I].FFieldIdxes) = 1) and
            (FTableIO.IndexDefs[I].FFieldIdxes[0] = FieldIdx) then
          begin
            Exists := True;
            Break;
          end;
        if Exists = False then
        begin
          Result := False;
          Break;
        end;
      end;
    end;
    if Node.FOperator in [toLIKE] then
    begin
      Result := False;
      Break;
    end;
    Node := Node.FNext;
  end;
end;

procedure TTinyTable.MasterChanged(Sender: TObject);
begin
  SetLinkRange(FMasterLink.Fields);
end;

procedure TTinyTable.MasterDisabled(Sender: TObject);
begin
  CancelRange;
end;

procedure TTinyTable.SetLinkRange(MasterFields: TList);

  function GetIndexField(Index: Integer): TField;
  var
    I: Integer;
  begin
    I := FTableIO.IndexDefs[FIndexIdx].FieldIdxes[Index];
    Result := Fields[I];
  end;

var
  SaveState: TDataSetState;
  StartIdx, EndIdx: Integer;
  I, ResultState: Integer;
  RecTabList: TList;
begin
  if FIndexIdx = -1 then Exit;
  if Filtered then Filtered := False;
  // if FSetRanged then CancelRange;

  // 设置范围前初始化Fields中的值
  CheckBrowseMode;
  SaveState := SetTempState(dsSetKey);
  try
    FKeyBuffer := FKeyBuffers[tkRangeStart];
    InitKeyBuffer(tkRangeStart);
    for I := 0 to MasterFields.Count - 1 do
      GetIndexField(I).Assign(TField(MasterFields[I]));

    FKeyBuffer := FKeyBuffers[tkRangeEnd];
    InitKeyBuffer(tkRangeEnd);
    for I := 0 to MasterFields.Count - 1 do
      GetIndexField(I).Assign(TField(MasterFields[I]));
  finally
    RestoreState(SaveState);
  end;

  // 设置范围
  CheckBrowseMode;
  FEffFieldCount := MasterFields.Count;
  StartIdx := SearchRangeStart(FTableIO.RecTabLists[FIndexIdx+1], FIndexIdx, ResultState, FEffFieldCount);
  if ResultState = -2 then Exit;
  EndIdx := SearchRangeEnd(FTableIO.RecTabLists[FIndexIdx+1], FIndexIdx, ResultState, FEffFieldCount);
  if ResultState = -2 then Exit;

  RecTabList := TList.Create;
  for I := StartIdx to EndIdx do
    AddMemRecTabItem(RecTabList, GetMemRecTabItem(FTableIO.RecTabLists[FIndexIdx+1], I));

  ClearMemRecTab(FRecTabList);
  for I := 0 to RecTabList.Count - 1 do
    AddMemRecTabItem(FRecTabList, GetMemRecTabItem(RecTabList, I));
  ClearMemRecTab(RecTabList);
  RecTabList.Free;

  FSetRanged := True;
  //FCanModify := False;
  First;
end;

procedure TTinyTable.CheckMasterRange;
begin
  if FMasterLink.Active and (FMasterLink.Fields.Count > 0) then
  begin
    SetLinkRange(FMasterLink.Fields);
  end;
end;

//-----------------------------------------------------------------------------
// RecordBuffer格式到FieldBuffers的转换
// 只是让FieldBuffers中的指针指向RecordBuffer中的各个字段偏移处,而没有复制数据.
//-----------------------------------------------------------------------------
procedure TTinyTable.RecordBufferToFieldBuffers(RecordBuffer: PChar; FieldBuffers: TFieldBuffers);
var
  I: Integer;
  Field: TField;
begin
  FieldBuffers.Clear;
  for I := 0 to FTableIO.FieldDefs.Count - 1 do
  begin
    Field := FieldByNumber(I + 1);
    if Field = nil then
    begin
      FieldBuffers.Add(nil, ftUnknown, 0);
      FieldBuffers.Items[FieldBuffers.Count - 1].Active := False;
    end else
    begin
      FieldBuffers.Add(RecordBuffer + FFieldOffsets[I], Field.DataType, Field.DataSize);
    end;
  end;
end;

function TTinyTable.FieldDefsStored: Boolean;
begin
  Result := FieldDefs.Count > 0;
end;

function TTinyTable.IndexDefsStored: Boolean;
begin
  Result := IndexDefs.Count > 0;
end;

procedure TTinyTable.ActivateFilters;
var
  I: Integer;
  Accept: Boolean;
  RecTabList: TList;
begin
  RecTabList := TList.Create;
  SetTempState(dsFilter);
  if DBSession.SQLHourGlass then Screen.Cursor := crSQLWait;
  try
    if Filter <> '' then FFilterParser.Parse(Filter);

    FFilterMapsToIndex := CheckFilterMapsToIndex;
    //if FFilterMapsToIndex then
    //begin
      //showmessage('yes, maps to index.');
    //  FiltersAccept;
    //end else
    //begin
      FFilterBuffer := ActiveBuffer;
      for I := 0 to RecordCount - 1 do
      begin
        FCurRec := I;
        ReadRecordData(FFilterBuffer, FCurRec);
        Accept := FiltersAccept;
        if Accept then
          AddMemRecTabItem(RecTabList, GetMemRecTabItem(FRecTabList, I));
        if Assigned(FOnFilterProgress) then
          FOnFilterProgress(Self, Trunc(I/RecordCount*100));
      end;
      if FRecTabList.Count <> RecTabList.Count then
      begin
        ClearMemRecTab(FRecTabList);
        for I := 0 to RecTabList.Count - 1 do
          AddMemRecTabItem(FRecTabList, GetMemRecTabItem(RecTabList, I));
      end;
    //end;
  finally
    Screen.Cursor := crDefault;
    RestoreState(dsBrowse);
    ClearMemRecTab(RecTabList);
    RecTabList.Free;
    FCurRec := -1;
    First;
    //FCanModify := False;
  end;
end;

procedure TTinyTable.DeactivateFilters;
begin
  InitCurRecordTab;
  FCurRec := -1;
  First;
  FCanModify := True;
end;

procedure TTinyTable.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TTinyTable.EndUpdate;
begin
  Dec(FUpdateCount);
end;

//-----------------------------------------------------------------------------
// This method is called by TDataSet.Open and also when FieldDefs need to
// be updated (usually by the DataSet designer).  Everything which is
// allocated or initialized in this method should also be freed or
// uninitialized in the InternalClose method.
//-----------------------------------------------------------------------------
procedure TTinyTable.InternalOpen;
begin
  FTableIO := Database.TableIOByName(FTableName);
  if FTableIO = nil then
    DatabaseErrorFmt(STableNotFound, [FTableName], Self);
  FTableIO.Open;

  FRecTabList := TList.Create;
  FUpdateCount := 0;
  FCurRec := -1;

  BookmarkSize := SizeOf(Integer);
  FCanModify := True;
  InternalInitFieldDefs;
  if DefaultFields then CreateFields;
  BindFields(True);

  InitIndexDefs;
  InitCurRecordTab;
  InitRecordSize;
  InitFieldOffsets;
  AllocKeyBuffers;
end;

procedure TTinyTable.InternalClose;
begin
  if FTableIO <> nil then FTableIO.Close;
  ClearMemRecTab(FRecTabList);
  FRecTabList.Free;
  FRecTabList := nil;
  FreeKeyBuffers;

  { Destroy the TField components if no persistent fields }
  if DefaultFields then DestroyFields;
  { Reset these internal flags }
  FCurRec := -1;
  FCanModify := False;
end;

//-----------------------------------------------------------------------------
// For this simple example we just create one FieldDef, but a more complete
// TDataSet implementation would create multiple FieldDefs based on the
// actual data.
//-----------------------------------------------------------------------------
procedure TTinyTable.InternalInitFieldDefs;
var
  I: Integer;
  FieldType: TFieldType;
  FieldSize: Integer;
begin
  FieldDefs.Clear;

  for I := 0 to FTableIO.FieldDefs.Count -1  do
  begin
    FieldType := FTableIO.FieldDefs[I].FieldType;
    if FieldType in StringFieldTypes then
      FieldSize := FTableIO.FieldDefs[I].FieldSize
    else
      FieldSize := 0;
    FieldDefs.Add(FTableIO.FieldDefs[I].Name,
                  FieldType,
                  FieldSize,
                  False);
  end;
end;

// Bookmarks

//-----------------------------------------------------------------------------
// In this sample the bookmarks are stored in the Object property of the
// TStringList holding the data.  Positioning to a bookmark just requires
// finding the offset of the bookmark in the TStrings.Objects and using that
// value as the new current record pointer.
//-----------------------------------------------------------------------------
procedure TTinyTable.InternalGotoBookmark(Bookmark: Pointer);
var
  I, Index: Integer;
begin
  Index := -1;
  for I := 0 to FRecTabList.Count - 1 do
  begin
    if PInteger(Bookmark)^ = GetMemRecTabItem(FRecTabList, I).RecIndex then
    begin
      Index := I;
      Break;
    end;
  end;
  if Index <> -1 then
    FCurRec := Index
  else
    DatabaseError(SBookmarkNotFound);
end;

//-----------------------------------------------------------------------------
// This multi-purpose function does 3 jobs.  It retrieves data for either
// the current, the prior, or the next record.  It must return the status
// (TGetResult), and raise an exception if DoCheck is True.
//-----------------------------------------------------------------------------
function TTinyTable.GetRecord(Buffer: PChar; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
begin
  if RecordCount < 1 then
    Result := grEOF else
  begin
    Result := grOK;
    case GetMode of
      gmNext:
        if FCurRec >= RecordCount - 1  then
          Result := grEOF else
          Inc(FCurRec);
      gmPrior:
        if FCurRec <= 0 then
          Result := grBOF else
          Dec(FCurRec);
      gmCurrent:
        if (FCurRec < 0) or (FCurRec >= RecordCount) then
          Result := grError;
    end;
    if Result = grOK then
    begin
      ReadRecordData(Buffer, FCurRec);
      with PRecInfo(Buffer + FRecordSize + CalcFieldsSize)^ do
      begin
        BookmarkFlag := bfCurrent;
        Bookmark := GetMemRecTabItem(FRecTabList, FCurRec).RecIndex;
      end;
      GetCalcFields(Buffer);
    end else
      if (Result = grError) and DoCheck then DatabaseError(SNoRecords);
  end;
end;

procedure TTinyTable.SetKeyBuffer(KeyIndex: TTDKeyIndex; Clear: Boolean);
begin
  CheckBrowseMode;
  FKeyBuffer := FKeyBuffers[KeyIndex];
  if Clear then InitKeyBuffer(KeyIndex);
  SetState(dsSetKey);
  DataEvent(deDataSetChange, 0);
end;

procedure TTinyTable.InternalRefresh;
begin
  InitCurRecordTab;
  if FSetRanged then ApplyRange;
  if Filtered then ActivateFilters; 
end;

//-----------------------------------------------------------------------------
// This method is called by TDataSet.Post.  Most implmentations would write
// the changes directly to the associated datasource, but here we simply set
// a flag to write the changes when we close the dateset.
//-----------------------------------------------------------------------------
procedure TTinyTable.InternalPost;
var
  RecBuf: PChar;
begin
  if GetActiveRecBuf(RecBuf) then
  begin
    //if FUpdateCount = 0 then InitCurRecordTab;
    if State = dsEdit then
    begin //edit
      ModifyRecordData(RecBuf, FCurRec);
    end else
    begin //insert or append
      AppendRecordData(RecBuf);
    end;
  end;
end;

//-----------------------------------------------------------------------------
// This method is similar to InternalPost above, but the operation is always
// an insert or append and takes a pointer to a record buffer as well.
//-----------------------------------------------------------------------------
procedure TTinyTable.InternalAddRecord(Buffer: Pointer; Append: Boolean);
begin
  if Append then InternalLast;
  AppendRecordData(Buffer);
end;

//-----------------------------------------------------------------------------
// This method is called by TDataSet.Delete to delete the current record
//-----------------------------------------------------------------------------
procedure TTinyTable.InternalDelete;
begin
  DeleteRecordData(FCurRec);
  if FCurRec >= RecordCount then
    Dec(FCurRec);
end;

//-----------------------------------------------------------------------------
// This property is used while opening the dataset.
// It indicates if data is available even though the
// current state is still dsInActive.
//-----------------------------------------------------------------------------
function TTinyTable.IsCursorOpen: Boolean;
begin
  Result := Assigned(FRecTabList);
end;

procedure TTinyTable.Post;
begin
  inherited Post;
  //When state is dsSetKey, calling CheckBrowseMode will run to here:
  if State = dsSetKey then
  begin
    DataEvent(deCheckBrowseMode, 0);
    SetState(dsBrowse);
    DataEvent(deDataSetChange, 0);
  end;
end;

function TTinyTable.BookmarkValid(Bookmark: TBookmark): Boolean;
var
  I, Index: Integer;
begin
  Result := IsCursorOpen;
  if not Result then Exit;

  Index := -1;
  for I := 0 to FRecTabList.Count - 1 do
    if PInteger(Bookmark)^ = GetMemRecTabItem(FRecTabList, I).RecIndex then
    begin
      Index := I;
      Break;
    end;
  Result := (Index <> -1);
end;

procedure TTinyTable.SetKey;
begin
  SetKeyBuffer(tkLookup, True);
  FEffFieldCount := 0;
end;

procedure TTinyTable.EditKey;
begin
  SetKeyBuffer(tkLookup, False);
  FEffFieldCount := 0;
end;

function TTinyTable.GotoKey: Boolean;
begin
  CheckBrowseMode;
  DoBeforeScroll;
  CursorPosChanged;

  Result := SearchKey(FRecTabList, FIndexIdx, FEffFieldCount, False);

  if Result then Resync([rmExact, rmCenter]);
  if Result then DoAfterScroll;
end;

function TTinyTable.GotoKey(const IndexName: string): Boolean;
var
  IndexIdx: Integer;
begin
  IndexIdx := FTableIO.IndexDefs.IndexOf(IndexName);
  if IndexIdx = -1 then
    DatabaseErrorFmt(SInvalidIndexName, [IndexName]);

  CheckBrowseMode;
  DoBeforeScroll;
  CursorPosChanged;

  Result := SearchKey(FTableIO.RecTabLists[IndexIdx+1], IndexIdx, FEffFieldCount, False);

  if Result then Resync([rmExact, rmCenter]);
  if Result then DoAfterScroll;
end;

procedure TTinyTable.GotoNearest;
var
  Result: Boolean;
begin
  CheckBrowseMode;
  DoBeforeScroll;
  CursorPosChanged;

  Result := SearchKey(FRecTabList, FIndexIdx, FEffFieldCount, True);

  Resync([rmExact, rmCenter]);
  if Result then DoAfterScroll;
end;

procedure TTinyTable.GotoNearest(const IndexName: string);
var
  IndexIdx: Integer;
  Result: Boolean;
begin
  IndexIdx := FTableIO.IndexDefs.IndexOf(IndexName);
  if IndexIdx = -1 then
    DatabaseErrorFmt(SInvalidIndexName, [IndexName]);

  CheckBrowseMode;
  DoBeforeScroll;
  CursorPosChanged;

  Result := SearchKey(FTableIO.RecTabLists[IndexIdx+1], IndexIdx, FEffFieldCount, True);

  Resync([rmExact, rmCenter]);
  if Result then DoAfterScroll;
end;

function TTinyTable.FindKey(const KeyValues: array of const): Boolean;
begin
  CheckBrowseMode;
  FEffFieldCount := Length(KeyValues);
  SetKeyFields(tkLookup, KeyValues);
  Result := GotoKey;
end;

function TTinyTable.FindKey(const IndexName: string; const KeyValues: array of const): Boolean;
var
  IndexIdx: Integer;
begin
  IndexIdx := FTableIO.IndexDefs.IndexOf(IndexName);
  if IndexIdx = -1 then
    DatabaseErrorFmt(SInvalidIndexName, [IndexName]);

  CheckBrowseMode;
  FEffFieldCount := Length(KeyValues);
  SetKeyFields(IndexIdx, tkLookup, KeyValues);
  Result := GotoKey(IndexName);
end;

procedure TTinyTable.FindNearest(const KeyValues: array of const);
begin
  CheckBrowseMode;
  FEffFieldCount := Length(KeyValues);
  SetKeyFields(tkLookup, KeyValues);
  GotoNearest;
end;

procedure TTinyTable.FindNearest(const IndexName: string; const KeyValues: array of const);
var
  IndexIdx: Integer;
begin
  IndexIdx := FTableIO.IndexDefs.IndexOf(IndexName);
  if IndexIdx = -1 then
    DatabaseErrorFmt(SInvalidIndexName, [IndexName]);

  CheckBrowseMode;
  FEffFieldCount := Length(KeyValues);
  SetKeyFields(IndexIdx, tkLookup, KeyValues);
  GotoNearest(IndexName);
end;

procedure TTinyTable.SetRangeStart;
begin
  SetKeyBuffer(tkRangeStart, True);
  FEffFieldCount := 0;
end;

procedure TTinyTable.SetRangeEnd;
begin
  SetKeyBuffer(tkRangeEnd, True);
  FEffFieldCount := 0;
end;

procedure TTinyTable.EditRangeStart;
begin
  SetKeyBuffer(tkRangeStart, False);
  FEffFieldCount := 0;
end;

procedure TTinyTable.EditRangeEnd;
begin
  SetKeyBuffer(tkRangeEnd, False);
  FEffFieldCount := 0;
end;

procedure TTinyTable.ApplyRange;
var
  StartIdx, EndIdx: Integer;
  I, ResultState: Integer;
  RecTabList: TList;
begin
  CheckBrowseMode;
  if FIndexIdx = -1 then DatabaseError(SNoFieldIndexes, Self);
  if RecordCount = 0 then Exit;

  StartIdx := SearchRangeStart(FRecTabList, FIndexIdx, ResultState, FEffFieldCount);
  if ResultState = -2 then Exit;
  EndIdx := SearchRangeEnd(FRecTabList, FIndexIdx, ResultState, FEffFieldCount);
  if ResultState = -2 then Exit;

  RecTabList := TList.Create;
  for I := StartIdx to EndIdx do
    AddMemRecTabItem(RecTabList, GetMemRecTabItem(FRecTabList, I));
  ClearMemRecTab(FRecTabList);
  for I := 0 to RecTabList.Count - 1 do
    AddMemRecTabItem(FRecTabList, GetMemRecTabItem(RecTabList, I));
  ClearMemRecTab(RecTabList);
  RecTabList.Free;

  //FCanModify := False;
  First;
  FSetRanged := True;
end;

procedure TTinyTable.ApplyRange(const IndexName: string);
var
  IndexIdx: Integer;
  StartIdx, EndIdx: Integer;
  I, J, RecIndex, ResultState: Integer;
  RecTabList: TList;
begin
  IndexIdx := FTableIO.IndexDefs.IndexOf(IndexName);
  if IndexIdx = -1 then
    DatabaseErrorFmt(SInvalidIndexName, [IndexName]);

  CheckBrowseMode;
  if RecordCount = 0 then Exit;

  StartIdx := SearchRangeStart(FTableIO.RecTabLists[IndexIdx+1], IndexIdx, ResultState, FEffFieldCount);
  if ResultState = -2 then Exit;
  EndIdx := SearchRangeEnd(FTableIO.RecTabLists[IndexIdx+1], IndexIdx, ResultState, FEffFieldCount);
  if ResultState = -2 then Exit;

  RecTabList := TList.Create;
  for I := 0 to FRecTabList.Count - 1 do
  begin
    RecIndex := GetMemRecTabItem(FRecTabList, I).RecIndex;
    for J := StartIdx to EndIdx do
      if RecIndex = GetMemRecTabItem(FTableIO.RecTabLists[IndexIdx+1], J).RecIndex then
      begin
        AddMemRecTabItem(RecTabList, GetMemRecTabItem(FRecTabList, I));
        Break;
      end;
  end;

  ClearMemRecTab(FRecTabList);
  for I := 0 to RecTabList.Count - 1 do
    AddMemRecTabItem(FRecTabList, GetMemRecTabItem(RecTabList, I));
  ClearMemRecTab(RecTabList);
  RecTabList.Free;

  //FCanModify := False;
  First;
end;

procedure TTinyTable.SetRange(const StartValues, EndValues: array of const);
begin
  CheckBrowseMode;
  FEffFieldCount := Min(Length(StartValues), Length(EndValues));
  SetKeyFields(tkRangeStart, StartValues);
  SetKeyFields(tkRangeEnd, EndValues);
  ApplyRange;
end;

procedure TTinyTable.SetRange(const IndexName: string; const StartValues, EndValues: array of const);
var
  IndexIdx: Integer;
begin
  IndexIdx := FTableIO.IndexDefs.IndexOf(IndexName);
  if IndexIdx = -1 then
    DatabaseErrorFmt(SInvalidIndexName, [IndexName]);

  CheckBrowseMode;
  FEffFieldCount := Min(Length(StartValues), Length(EndValues));
  SetKeyFields(IndexIdx, tkRangeStart, StartValues);
  SetKeyFields(IndexIdx, tkRangeEnd, EndValues);
  ApplyRange(IndexName);
end;

procedure TTinyTable.CancelRange;
begin
  CheckBrowseMode;
  UpdateCursorPos;
  InitCurRecordTab;
  Resync([]);
  First;
  FCanModify := True;
  if Filtered then ActivateFilters;
  FSetRanged := False;
  FEffFieldCount := 0;
end;

function TTinyTable.Locate(const KeyFields: string; const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
begin
  DoBeforeScroll;
  Result := LocateRecord(KeyFields, KeyValues, Options, True);
  if Result then
  begin
    Resync([rmExact, rmCenter]);
    DoAfterScroll;
  end;
end;

function TTinyTable.Lookup(const KeyFields: string; const KeyValues: Variant;
  const ResultFields: string): Variant; 
begin
  Result := Null;
  if LocateRecord(KeyFields, KeyValues, [], False) then
  begin
    SetTempState(dsCalcFields);
    try
      CalculateFields(TempBuffer);
      Result := FieldValues[ResultFields];
    finally
      RestoreState(dsBrowse);
    end;
  end;
end;

procedure TTinyTable.EmptyTable;
begin
  if Active then
  begin
    CheckBrowseMode;
    DeleteAllRecords;
    ClearBuffers;
    DataEvent(deDataSetChange, 0);
  end else
  begin
    DeleteAllRecords;
  end;
end;

procedure TTinyTable.CreateTable;
var
  ADatabase: TTinyDatabase;
  FieldItems: array of TFieldItem;
  IndexFieldNames: array of string;
  TempList: TStrings;
  IndexName: string;
  IndexOptions: TTDIndexOptions;
  I, J: Integer;
  IndexExists: Boolean;
begin
  ADatabase := OpenDatabase(False);
  if ADatabase <> nil then
  begin
    SetLength(FieldItems, FieldDefs.Count);
    for I := 0 to FieldDefs.Count - 1 do
    begin
      FieldItems[I].FieldName := FieldDefs[I].Name;
      FieldItems[I].FieldType := FieldDefs[I].DataType;
      FieldItems[I].DataSize := FieldDefs[I].Size;
      FieldItems[I].DPMode := fdDefault;
    end;
    ADatabase.CreateTable(TableName, FieldItems);

    for I := 0 to IndexDefs.Count - 1 do
    begin
      IndexName := IndexDefs[I].Name;
      IndexOptions := [];
      if ixPrimary in IndexDefs[I].Options then Include(IndexOptions, tiPrimary);
      if ixUnique in IndexDefs[I].Options then Include(IndexOptions, tiUnique);
      if ixDescending in IndexDefs[I].Options then Include(IndexOptions, tiDescending);
      if ixCaseInsensitive in IndexDefs[I].Options then Include(IndexOptions, tiCaseInsensitive);

      TempList := TStringList.Create;
      TempList.CommaText := IndexDefs[I].Fields;
      SetLength(IndexFieldNames, TempList.Count);
      for J := 0 to TempList.Count - 1 do
        IndexFieldNames[J] := TempList[J];
      TempList.Free;

      IndexExists := tiPrimary in IndexOptions;
      if not IndexExists then
        ADatabase.CreateIndex(TableName, IndexName, IndexOptions, IndexFieldNames);
    end;
  end;
end;

{ TTinyQuery }

constructor TTinyQuery.Create(AOwner: TComponent);
begin
  inherited;
  FSQL := TStringList.Create;
  FSQLParser := TSQLParser.Create(Self);
end;

destructor TTinyQuery.Destroy;
begin
  SQL.Free;
  FSQLParser.Free;
  inherited;
end;

procedure TTinyQuery.ExecSQL;
begin
  FSQLParser.Parse(SQL.Text);
  FSQLParser.Execute;
end;

procedure TTinyQuery.SetQuery(Value: TStrings);
begin
  if SQL.Text <> Value.Text then
  begin
    SQL.BeginUpdate;
    try
      SQL.Assign(Value);
    finally
      SQL.EndUpdate;
    end;
  end;
end;

function TTinyQuery.GetRowsAffected: Integer;
begin
  Result := FSQLParser.RowsAffected;
end;

procedure TTinyQuery.InternalOpen;
begin

end;

procedure TTinyQuery.InternalClose;
begin

end;

{ TTinyDatabase }

constructor TTinyDatabase.Create(AOwner: TComponent);
begin
  inherited;
  FDataSets := TList.Create;
  if FSession = nil then
    if AOwner is TTinySession then
      FSession := TTinySession(AOwner) else
      FSession := DefaultSession;
  SessionName := FSession.SessionName;
  FSession.AddDatabase(Self);
  FTableDefs := TTinyTableDefs.Create(Self);
  FKeepConnection := False;
  FAutoFlushInterval := tdbDefAutoFlushInterval;  // 60秒
  FAutoFlushTimer := TTimer.Create(nil);
  FAutoFlushTimer.OnTimer := AutoFlushTimer;
end;

destructor TTinyDatabase.Destroy;
begin
  Destroying;
  if FSession <> nil then
    FSession.RemoveDatabase(Self);
  SetConnected(False);
  FreeAndNil(FDataSets);
  FTableDefs.Free;
  FAutoFlushTimer.Free;
  inherited;
end;

procedure TTinyDatabase.Open;
begin
  SetConnected(True);
end;

procedure TTinyDatabase.Close;
begin
  SetConnected(False);
end;

procedure TTinyDatabase.CloseDataSets;
begin
  while DataSetCount <> 0 do TTDBDataSet(DataSets[DataSetCount-1]).Disconnect;
end;

procedure TTinyDatabase.FlushCache;
begin
  if FDBFileIO <> nil then FDBFileIO.Flush;
end;

procedure TTinyDatabase.DoConnect;
begin
  CheckDatabaseName;
  CheckSessionName(True);
  if FDBFileIO = nil then
    FDBFileIO := TTinyDBFileIO.Create(Self);
  try
    FDBFileIO.Open(GetDBFileName, FMediumType, FExclusive);
  except
    FDBFileIO.Close;
    FDBFileIO.Free;
    FDBFileIO := nil;
    raise;
  end;
  FCanAccess := not FDBFileIO.FDBOptions.Encrypt;
  if not FCanAccess and FPasswordModified then
    FCanAccess := FDBFileIO.SetPassword(FPassword);
  InitTableDefs;
  InitTableIOs;
end;

procedure TTinyDatabase.DoDisconnect;
begin
  if FDBFileIO <> nil then
  begin
    FDBFileIO.Close;
    FDBFileIO.Free;
    FDBFileIO := nil;
    Session.DBNotification(dbClose, Self);
    CloseDataSets;
    FRefCount := 0;
    FCanAccess := False;
    FPassword := '';
    FPasswordModified := False;
    FreeTableIOs;
    FTableDefs.Clear;
  end;
  FCanAccess := False;
end;

procedure TTinyDatabase.CheckCanAccess;
var
  TempPassword: string;
  I: Integer;
begin
  if not FCanAccess then
  begin
    // check passwords from session
    if Session.FPasswords.Count > 0 then
    begin
      for I := 0 to Session.FPasswords.Count - 1 do
      begin
        Password := Session.FPasswords[I];
        if FCanAccess then Break;
      end;
    end;

    if not FCanAccess then
    begin
      if not FPasswordModified then
      begin
        if ShowLoginDialog(GetDBFileName, TempPassword) then
        begin
          Password := TempPassword;
          if not FCanAccess then DatabaseError(SAccessDenied);
        end else
          Abort;
      end else
      begin
        Password := FPassword;
        if not FCanAccess then DatabaseError(SAccessDenied);
      end;
    end;
  end;
end;

function TTinyDatabase.GetDataSet(Index: Integer): TTDEDataSet;
begin
  Result := FDataSets[Index];
end;

function TTinyDatabase.GetDataSetCount: Integer;
begin
  Result := FDataSets.Count;
end;

procedure TTinyDatabase.RegisterClient(Client: TObject; Event: TConnectChangeEvent = nil);
begin
  if Client is TTDBDataSet then
    FDataSets.Add(Client);
end;

procedure TTinyDatabase.UnRegisterClient(Client: TObject);
begin
  if Client is TTDBDataSet then
    FDataSets.Remove(Client);
end;

procedure TTinyDatabase.SendConnectEvent(Connecting: Boolean);
var
  I: Integer;
begin
  for I := 0 to FDataSets.Count - 1 do
    TTDBDataSet(FDataSets[I]).DataEvent(deConnectChange, Integer(Connecting));
end;

function TTinyDatabase.GetConnected: Boolean;
begin
  Result := (FDBFileIO <> nil) and (FDBFileIO.IsOpen);
end;

function TTinyDatabase.GetEncrypted: Boolean;
begin
  if FDBFileIO = nil then DatabaseError(SDatabaseClosed, Self);
  Result := FDBFileIO.FDBOptions.Encrypt;
end;

function TTinyDatabase.GetEncryptAlgoName: string;
begin
  if FDBFileIO = nil then DatabaseError(SDatabaseClosed, Self);
  Result := FDBFileIO.FDBOptions.EncryptAlgoName;
end;

function TTinyDatabase.GetCompressed: Boolean;
begin
  if FDBFileIO = nil then DatabaseError(SDatabaseClosed, Self);
  Result := FDBFileIO.FDBOptions.CompressBlob;
end;

function TTinyDatabase.GetCompressLevel: TCompressLevel;
begin
  if FDBFileIO = nil then DatabaseError(SDatabaseClosed, Self);
  Result := FDBFileIO.FDBOptions.CompressLevel;
end;

function TTinyDatabase.GetCompressAlgoName: string;
begin
  if FDBFileIO = nil then DatabaseError(SDatabaseClosed, Self);
  Result := FDBFileIO.FDBOptions.CompressAlgoName;
end;

function TTinyDatabase.GetCRC32: Boolean;
begin
  if FDBFileIO = nil then DatabaseError(SDatabaseClosed, Self);
  Result := FDBFileIO.FDBOptions.CRC32;
end;

function TTinyDatabase.GetTableIOs(Index: Integer): TTinyTableIO;
begin
  Result := TTinyTableIO(FTableIOs[Index]);
end;

function TTinyDatabase.GetFileSize: Integer;
begin
  if FDBFileIO = nil then DatabaseError(SDatabaseClosed, Self);
  Result := FDBFileIO.DBStream.Size;
end;

function TTinyDatabase.GetFileDate: TDateTime;
var
  FileDate: Integer;
begin
  if FDBFileIO = nil then DatabaseError(SDatabaseClosed, Self);
  if FMediumType = mtDisk then
  begin
    FileDate := FileGetDate((FDBFileIO.FDBStream as TFileStream).Handle);
    Result := FileDateToDateTime(FileDate);
  end else
    Result := Now;
end;

function TTinyDatabase.GetFileIsReadOnly: Boolean;
begin
  Result := DBFileIO.FileIsReadOnly;
end;

function TTinyDatabase.TableIOByName(const Name: string): TTinyTableIO;
var
  I: Integer;
begin
  for I := 0 to FTableIOs.Count - 1 do
    if AnsiCompareText(Name, TTinyTableIO(FTableIOs[I]).TableName) = 0 then
    begin
      Result := TTinyTableIO(FTableIOs[I]);
      Exit;
    end;
  Result := nil;
end;

procedure TTinyDatabase.SetDatabaseName(const Value: string);
begin
  if FDatabaseName <> Value then
  begin
    CheckInactive;
    ValidateName(Value);
    FDatabaseName := Value;
  end;
end;

procedure TTinyDatabase.SetFileName(const Value: string);
begin
  if FFileName <> Value then
  begin
    CheckInactive;
    FFileName := Value;
  end;
end;

procedure TTinyDatabase.SetMediumType(const Value: TTinyDBMediumType);
var
  I: Integer;
begin
  if FMediumType <> Value then
  begin
    CheckInactive;
    FMediumType := Value;
    for I := 0 to FDataSets.Count - 1 do
      if TObject(FDataSets[I]) is TTDEDataSet then
        TTDEDataSet(FDataSets[I]).MediumType := FMediumType;
  end;
end;

procedure TTinyDatabase.SetExclusive(const Value: Boolean);
begin
  CheckInactive;
  FExclusive := Value;
end;

procedure TTinyDatabase.SetKeepConnection(const Value: Boolean);
begin
  if FKeepConnection <> Value then
  begin
    FKeepConnection := Value;
    if not Value and (FRefCount = 0) then Close;
  end;
end;

procedure TTinyDatabase.SetSessionName(const Value: string);
begin
  if csReading in ComponentState then
    FSessionName := Value
  else
  begin
    CheckInactive;
    if FSessionName <> Value then
    begin
      FSessionName := Value;
      CheckSessionName(False);
    end;
  end;
end;

procedure TTinyDatabase.SetConnected(const Value: Boolean);
begin
  if (csReading in ComponentState) and Value then
    FStreamedConnected := True
  else
  begin
    if Value = GetConnected then Exit;
    if Value then
    begin
      if Assigned(BeforeConnect) then BeforeConnect(Self);
      DoConnect;
      SendConnectEvent(True);
      if Assigned(AfterConnect) then AfterConnect(Self);
    end else
    begin
      if Assigned(BeforeDisconnect) then BeforeDisconnect(Self);
      SendConnectEvent(False);
      DoDisconnect;
      if Assigned(AfterDisconnect) then AfterDisconnect(Self);
    end;
  end;
end;

procedure TTinyDatabase.SetPassword(Value: string);
begin
  FPasswordModified := True;
  FPassword := Value;
  if Connected then
    FCanAccess := FDBFileIO.SetPassword(Value);
end;

procedure TTinyDatabase.SetCRC32(Value: Boolean);
begin
  if FDBFileIO = nil then DatabaseError(SDatabaseClosed, Self);
  FDBFileIO.FDBOptions.CRC32 := Value;
end;

procedure TTinyDatabase.SetAutoFlush(Value: Boolean);
begin
  if FAutoFlush <> Value then
  begin
    FAutoFlush := Value;
    if Value then
      FAutoFlushTimer.Interval := FAutoFlushInterval;
    FAutoFlushTimer.Enabled := Value;
  end;
end;

procedure TTinyDatabase.SetAutoFlushInterval(Value: Integer);
begin
  if FAutoFlushInterval <> Value then
  begin
    FAutoFlushInterval := Value;
    if FAutoFlushTimer.Enabled then
      FAutoFlushTimer.Interval := FAutoFlushInterval;
  end;
end;

function TTinyDatabase.CreateLoginDialog(const ADatabaseName: string): TForm;
var
  BackPanel: TPanel;
begin
  Result := TTinyDBLoginForm.CreateNew(Application);
  with Result do
  begin
    BiDiMode := Application.BiDiMode;
    BorderStyle := bsDialog;
    Canvas.Font := Font;
    Width := 281;
    Height := 154;
    Position := poScreenCenter;
    Scaled := False;
    Caption := 'Database Login';
    BackPanel := TPanel.Create(Result);
    with BackPanel do
    begin
      Name := 'BackPanel';
      Parent := Result;
      Caption := '';
      BevelInner := bvRaised;
      BevelOuter := bvLowered;
      SetBounds(8, 8, Result.ClientWidth - 16, 75);
    end;
    with TLabel.Create(Result) do
    begin
      Name := 'DatabaseLabel';
      Parent := BackPanel;
      Caption := 'Database:';
      BiDiMode := Result.BiDiMode;
      Left := 12;
      Top := 15;
    end;
    with TLabel.Create(Result) do
    begin
      Name := 'PasswordLabel';
      Parent := BackPanel;
      Caption := 'Password:';
      BiDiMode := Result.BiDiMode;
      Left := 12;
      Top := 45;
    end;
    with TEdit.Create(Result) do
    begin
      Name := 'DatabaseEdit';
      Parent := BackPanel;
      BiDiMode := Result.BiDiMode;
      SetBounds(86, 12, BackPanel.ClientWidth - 86 - 12, 21);
      ReadOnly := True;
      Color := clBtnFace;
      TabStop := False;
      Text := ADatabaseName;
    end;
    with TEdit.Create(Result) do
    begin
      Name := 'PasswordEdit';
      Parent := BackPanel;
      BiDiMode := Result.BiDiMode;
      SetBounds(86, 42, BackPanel.ClientWidth - 86 - 12, 21);
      PasswordChar := '*';
      TabOrder := 0;
      Text := '';
    end;
    with TButton.Create(Result) do
    begin
      Name := 'OkButton';
      Parent := Result;
      Caption := '&OK';
      Default := True;
      ModalResult := mrOk;
      Left := 109;
      Top := 94;
    end;
    with TButton.Create(Result) do
    begin
      Name := 'CancelButton';
      Parent := Result;
      Caption := '&Cancel';
      Cancel := True;
      ModalResult := mrCancel;
      Left := 191;
      Top := 94;
    end;
  end;
end;

function TTinyDatabase.ShowLoginDialog(const ADatabaseName: string; var APassword: string): Boolean;
begin
  with CreateLoginDialog(ADatabaseName) as TTinyDBLoginForm do
  begin
    Result := ShowModal = mrOk;
    if Result then
      APassword := (FindComponent('PasswordEdit') as TEdit).Text;
    Free;
  end;
end;

function TTinyDatabase.GetDBFileName: string;
begin
  if FFileName <> '' then
    Result := FFileName
  else
    Result := FDatabaseName;
end;

procedure TTinyDatabase.CheckSessionName(Required: Boolean);
var
  NewSession: TTinySession;
begin
  if Required then
    NewSession := Sessions.List[FSessionName]
  else
    NewSession := Sessions.FindSession(FSessionName);
  if (NewSession <> nil) and (NewSession <> FSession) then
  begin
    if (FSession <> nil) then FSession.RemoveDatabase(Self);
    FSession := NewSession;
    FSession.FreeNotification(Self);
    FSession.AddDatabase(Self);
    try
      ValidateName(FDatabaseName);
    except
      FDatabaseName := '';
      raise;
    end;
  end;
  if Required then FSession.Active := True;
end;

procedure TTinyDatabase.CheckInactive;
begin
  if FDBFileIO <> nil then
    if csDesigning in ComponentState then
      Close
    else
      DatabaseError(SDatabaseOpen, Self);
end;

procedure TTinyDatabase.CheckDatabaseName;
begin
  if (FDatabaseName = '') and not Temporary then
    DatabaseError(SDatabaseNameMissing, Self);
end;

procedure TTinyDatabase.InitTableIOs;
var
  I: Integer;
  TableIO: TTinyTableIO;
  TableNames: TStringList;
begin
  FreeTableIOs;
  FTableIOs := TList.Create;
  TableNames := TStringList.Create;
  try
    GetTableNames(TableNames);
    for I := 0 to TableNames.Count - 1 do
    begin
      TableIO := TTinyTableIO.Create(Self);
      TableIO.TableName := TableNames[I];
      FTableIOs.Add(TableIO);
    end;
  finally
    TableNames.Free;
  end;
end;

procedure TTinyDatabase.FreeTableIOs;
var
  I: Integer;
begin
  if FTableIOs <> nil then
  begin
    for I := 0 to FTableIOs.Count - 1 do
      TTinyTableIO(FTableIOs[I]).Free;
    FTableIOs.Clear;
    FTableIOs.Free;
    FTableIOs := nil;
  end;
end;

procedure TTinyDatabase.AddTableIO(const TableName: string);
var
  TableIO: TTinyTableIO;
begin
  TableIO := TTinyTableIO.Create(Self);
  TableIO.TableName := TableName;
  FTableIOs.Add(TableIO);
end;

procedure TTinyDatabase.DeleteTableIO(const TableName: string);
var
  I: Integer;
begin
  for I := 0 to FTableIOs.Count - 1 do
    if AnsiCompareText(TTinyTableIO(FTableIOs[I]).TableName, TableName) = 0 then
    begin
      TTinyTableIO(FTableIOs[I]).Free;
      FTableIOs.Delete(I);
      Break;
    end;
end;

procedure TTinyDatabase.RenameTableIO(const OldTableName, NewTableName: string);
var
  I: Integer;
begin
  for I := 0 to FTableIOs.Count - 1 do
    if AnsiCompareText(TTinyTableIO(FTableIOs[I]).TableName, OldTableName) = 0 then
    begin
      TTinyTableIO(FTableIOs[I]).TableName := NewTableName;
      Break;
    end;
end;

procedure TTinyDatabase.RefreshAllTableIOs;
var
  I: Integer;
begin
  if FTableIOs <> nil then
  begin
    for I := 0 to FTableIOs.Count - 1 do
      TTinyTableIO(FTableIOs[I]).Refresh;
  end;
end;

procedure TTinyDatabase.RefreshAllDataSets;
var
  I: Integer;
begin
  for I := 0 to DataSetCount - 1 do
    DataSets[I].Refresh;
end;

procedure TTinyDatabase.InitTableDefs;
var
  I: Integer;
  List: TStrings;
begin
  List := TStringList.Create;
  try
    FTableDefs.Clear;
    GetTableNames(List);
    for I := 0 to List.Count - 1 do
      with TTinyTableDef(FTableDefs.Add) do
      begin
        Name := List[I];
        TableIdx := I;
      end;
  finally
    List.Free;
  end;
end;

procedure TTinyDatabase.AutoFlushTimer(Sender: TObject);
begin
  if FDBFileIO <> nil then
  begin
    if not FDBFileIO.Flushed then
      FlushCache;
  end;
end;

procedure TTinyDatabase.Loaded;
begin
  inherited Loaded;
  try
    if FStreamedConnected then SetConnected(True);
  except
    on E: Exception do
      if csDesigning in ComponentState then
        ShowException(E, ExceptAddr) else
        raise;
  end;
  if not StreamedConnected then CheckSessionName(False);
end;

procedure TTinyDatabase.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FSession) and
    (FSession <> DefaultSession) then
  begin
    Close;
    SessionName := '';
  end;
end;

procedure TTinyDatabase.ValidateName(const Name: string);
var
  Database: TTinyDatabase;
begin
  if (Name <> '') and (FSession <> nil) then
  begin
    Database := FSession.FindDatabase(Name);
    if (Database <> nil) and (Database <> Self) and
      not (Database.HandleShared and HandleShared) then
    begin
      if not Database.Temporary or (Database.FRefCount <> 0) then
        DatabaseErrorFmt(SDuplicateDatabaseName, [Name]);
      Database.Free;
    end;
  end;
end;

procedure TTinyDatabase.GetTableNames(List: TStrings);
begin
  if Connected then
    DBFileIO.GetTableNames(List);
end;

procedure TTinyDatabase.GetFieldNames(const TableName: string; List: TStrings);
begin
  if Connected then
    DBFileIO.GetFieldNames(TableName, List);
end;

procedure TTinyDatabase.GetIndexNames(const TableName: string; List: TStrings);
begin
  if Connected then
    DBFileIO.GetIndexNames(TableName, List);
end;

function TTinyDatabase.TableExists(const TableName: string): Boolean;
var
  Tables: TStrings;
begin
  Tables := TStringList.Create;
  try
    try
      GetTableNames(Tables);
    except
    end;
    Result := (Tables.IndexOf(TableName) <> -1);
  finally
    Tables.Free;
  end;
end;

class function TTinyDatabase.GetCompressAlgoNames(List: TStrings): Integer;
begin
  List.Assign(FCompressClassList);
  Result := List.Count;
end;

class function TTinyDatabase.GetEncryptAlgoNames(List: TStrings): Integer;
begin
  List.Assign(FEncryptClassList);
  Result := List.Count;
end;

class function TTinyDatabase.IsTinyDBFile(const FileName: string): Boolean;
begin
  try
    Result := TTinyDBFileIO.CheckValidTinyDB(FileName);
  except
    Result := False;
  end;
end;

function TTinyDatabase.CreateDatabase(const DBFileName: string): Boolean;
begin
  Result := CreateDatabase(DBFileName, False, clNormal, '', False, '', '', False);
end;

function TTinyDatabase.CreateDatabase(const DBFileName: string;
  CompressBlob: Boolean; CompressLevel: TCompressLevel; const CompressAlgoName: string;
  Encrypt: Boolean; const EncryptAlgoName, Password: string; CRC32: Boolean = False): Boolean;
var
  TempDBFile: TTinyDBFileIO;
begin
  TempDBFile := TTinyDBFileIO.Create(Self);
  try
    Result := TempDBFile.CreateDatabase(DBFileName, CompressBlob, CompressLevel,
      CompressAlgoName, Encrypt, EncryptAlgoName, Password, CRC32);
  finally
    TempDBFile.Free;
  end;
end;

function TTinyDatabase.CreateTable(const TableName: string; Fields: array of TFieldItem): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.CreateTable(TableName, Fields);
  if Result then
  begin
    InitTableDefs;
    AddTableIO(TableName);
  end;
end;

function TTinyDatabase.DeleteTable(const TableName: string): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.DeleteTable(TableName);
  if Result then
  begin
    InitTableDefs;
    DeleteTableIO(TableName);
  end;
end;

function TTinyDatabase.CreateIndex(const TableName, IndexName: string; IndexOptions: TTDIndexOptions; FieldNames: array of string): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.CreateIndex(TableName, IndexName, IndexOptions, FieldNames);
end;

function TTinyDatabase.DeleteIndex(const TableName, IndexName: string): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.DeleteIndex(TableName, IndexName);
end;

function TTinyDatabase.RenameTable(const OldTableName, NewTableName: string): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.RenameTable(OldTableName, NewTableName);
  if Result then
  begin
    InitTableDefs;
    RenameTableIO(OldTableName, NewTableName);
  end;
end;

function TTinyDatabase.RenameField(const TableName, OldFieldName, NewFieldName: string): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.RenameField(TableName, OldFieldName, NewFieldName);
end;

function TTinyDatabase.RenameIndex(const TableName, OldIndexName, NewIndexName: string): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.RenameIndex(TableName, OldIndexName, NewIndexName);
end;

function TTinyDatabase.Compact: Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.Compact(FPassword);
  if Result then
  begin
    RefreshAllTableIOs;
    RefreshAllDataSets;
  end;
end;

function TTinyDatabase.Repair: Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.Repair(FPassword);
  if Result then
  begin
    RefreshAllTableIOs;
    RefreshAllDataSets;
  end;
end;

function TTinyDatabase.ChangePassword(const NewPassword: string; Check: Boolean = True): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.ChangePassword(FPassword, NewPassword, Check);
  if Result then
  begin
    Password := NewPassword;
    RefreshAllTableIOs;
    RefreshAllDataSets;
  end;
end;

function TTinyDatabase.ChangeEncrypt(NewEncrypt: Boolean; const NewEncAlgo, NewPassword: string): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.ChangeEncrypt(NewEncrypt, NewEncAlgo, FPassword, NewPassword);
  if Result then
  begin
    Password := NewPassword;
    RefreshAllTableIOs;
    RefreshAllDataSets;
  end;
end;

function TTinyDatabase.SetComments(const Value: string): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.SetComments(Value, FPassword);
end;

function TTinyDatabase.GetComments(var Value: string): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.GetComments(Value, FPassword);
end;

function TTinyDatabase.SetExtData(Buffer: PChar; Size: Integer): Boolean;
begin
  if not Connected then Open;
  CheckCanAccess;
  Result := FDBFileIO.SetExtData(Buffer, Size);
end;

function TTinyDatabase.GetExtData(Buffer: PChar): Boolean;
begin
  if not Connected then Open;
  // Here, CheckCanAccess is not needed.
  Result := FDBFileIO.GetExtData(Buffer);
end;

{ TTinySession }

constructor TTinySession.Create(AOwner: TComponent);
begin
  ValidateAutoSession(AOwner, False);
  inherited Create(AOwner);
  FDatabases := TList.Create;
  FKeepConnections := False;
  FSQLHourGlass := True;
  FLockRetryCount := tdbDefaultLockRetryCount;
  FLockWaitTime := tdbDefaultLockWaitTime;
  FPasswords := TStringList.Create;
  Sessions.AddSession(Self);
end;

destructor TTinySession.Destroy;
begin
  SetActive(False);
  Sessions.FSessions.Remove(Self);
  FPasswords.Free;
  inherited Destroy;
  FDatabases.Free;
end;

procedure TTinySession.Open;
begin
  SetActive(True);
end;

procedure TTinySession.Close;
begin
  SetActive(False);
end;

procedure TTinySession.Loaded;
begin
  inherited Loaded;
  try
    if AutoSessionName then SetSessionNames;
    if FStreamedActive then SetActive(True);
  except
    if csDesigning in ComponentState then
      Application.HandleException(Self)
    else
      raise;
  end;
end;

procedure TTinySession.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if AutoSessionName and (Operation = opInsert) then
    if AComponent is TTDBDataSet then
      TTDBDataSet(AComponent).FSessionName := Self.SessionName
    else if AComponent is TTinyDatabase then
      TTinyDatabase(AComponent).FSession := Self;
end;

procedure TTinySession.SetName(const NewName: TComponentName);
begin
  inherited SetName(NewName);
  if FAutoSessionName then UpdateAutoSessionName;
end;

function TTinySession.OpenDatabase(const DatabaseName: string): TTinyDatabase;
begin
  Result := DoOpenDatabase(DatabaseName, nil, nil, True);
end;

procedure TTinySession.CloseDatabase(Database: TTinyDatabase);
begin
  with Database do
  begin
    if FRefCount <> 0 then Dec(FRefCount);
    if (FRefCount = 0) and not KeepConnection then
      if not Temporary then Close else
         if not (csDestroying in ComponentState) then Free;
  end;
end;

function TTinySession.FindDatabase(const DatabaseName: string): TTinyDatabase;
var
  I: Integer;
begin
  for I := 0 to FDatabases.Count - 1 do
  begin
    Result := FDatabases[I];
    if ((Result.DatabaseName <> '') or Result.Temporary) and
      (AnsiCompareText(Result.DatabaseName, DatabaseName) = 0) then Exit;
  end;
  Result := nil;
end;

procedure TTinySession.DropConnections;
var
  I: Integer;
begin
  for I := FDatabases.Count - 1 downto 0 do
    with TTinyDatabase(FDatabases[I]) do
      if Temporary and (FRefCount = 0) then Free;
end;

procedure TTinySession.GetDatabaseNames(List: TStrings);
var
  I: Integer;
begin
  for I := 0 to FDatabases.Count - 1 do
    with TTinyDatabase(FDatabases[I]) do
      List.Add(DatabaseName);
end;

procedure TTinySession.GetTableNames(const DatabaseName: string; List: TStrings);
var
  Database: TTinyDatabase;
begin
  List.BeginUpdate;
  try
    List.Clear;
    Database := OpenDatabase(DatabaseName);
    try
      Database.GetTableNames(List);
    finally
      CloseDatabase(Database);
    end;
  finally
    List.EndUpdate;
  end;
end;

procedure TTinySession.GetFieldNames(const DatabaseName, TableName: string; List: TStrings);
var
  Database: TTinyDatabase;
begin
  List.BeginUpdate;
  try
    List.Clear;
    Database := OpenDatabase(DatabaseName);
    try
      Database.GetFieldNames(TableName, List);
    finally
      CloseDatabase(Database);
    end;
  finally
    List.EndUpdate;
  end;
end;

procedure TTinySession.GetIndexNames(const DatabaseName, TableName: string; List: TStrings);
var
  Database: TTinyDatabase;
begin
  List.BeginUpdate;
  try
    List.Clear;
    Database := OpenDatabase(DatabaseName);
    try
      Database.GetIndexNames(TableName, List);
    finally
      CloseDatabase(Database);
    end;
  finally
    List.EndUpdate;
  end;
end;

procedure TTinySession.AddPassword(const Password: string);
begin
  LockSession;
  try
    if GetPasswordIndex(Password) = -1 then
      FPasswords.Add(Password);
  finally
    UnlockSession;
  end;
end;

procedure TTinySession.RemovePassword(const Password: string);
var
  I: Integer;
begin
  LockSession;
  try
    I := GetPasswordIndex(Password);
    if I <> -1 then FPasswords.Delete(I);
  finally
    UnlockSession;
  end;
end;

procedure TTinySession.RemoveAllPasswords;
begin
  LockSession;
  try
    FPasswords.Clear;
  finally
    UnlockSession;
  end;
end;

procedure TTinySession.CheckInactive;
begin
  if Active then
    DatabaseError(SSessionActive, Self);
end;

function TTinySession.GetActive: Boolean;
begin
  Result := FActive;
end;

function TTinySession.GetDatabase(Index: Integer): TTinyDatabase;
begin
  Result := FDatabases[Index];
end;

function TTinySession.GetDatabaseCount: Integer;
begin
  Result := FDatabases.Count;
end;

procedure TTinySession.SetActive(Value: Boolean);
begin
  if csReading in ComponentState then
    FStreamedActive := Value
  else
    if Active <> Value then
      StartSession(Value);
end;

procedure TTinySession.SetAutoSessionName(Value: Boolean);
begin
  if Value <> FAutoSessionName then
  begin
    if Value then
    begin
      CheckInActive;
      ValidateAutoSession(Owner, True);
      FSessionNumber := -1;
      EnterCriticalSection(FSessionCSect);
      try
        with Sessions do
        begin
          FSessionNumber := FSessionNumbers.OpenBit;
          FSessionNumbers[FSessionNumber] := True;
        end;
      finally
        LeaveCriticalSection(FSessionCSect);
      end;
      UpdateAutoSessionName;
    end
    else
    begin
      if FSessionNumber > -1 then
      begin
        EnterCriticalSection(FSessionCSect);
        try
          Sessions.FSessionNumbers[FSessionNumber] := False;
        finally
          LeaveCriticalSection(FSessionCSect);
        end;
      end;
    end;
    FAutoSessionName := Value;
  end;
end;

procedure TTinySession.SetSessionName(const Value: string);
var
  Ses: TTinySession;
begin
  if FAutoSessionName and not FUpdatingAutoSessionName then
    DatabaseError(SAutoSessionActive, Self);
  CheckInActive;
  if Value <> '' then
  begin
    Ses := Sessions.FindSession(Value);
    if not ((Ses = nil) or (Ses = Self)) then
      DatabaseErrorFmt(SDuplicateSessionName, [Value], Self);
  end;
  FSessionName := Value
end;

procedure TTinySession.SetSessionNames;
var
  I: Integer;
  Component: TComponent;
begin
  if Owner <> nil then
    for I := 0 to Owner.ComponentCount - 1 do
    begin
      Component := Owner.Components[I];
      if (Component is TTDBDataSet) and
        (AnsiCompareText(TTDBDataSet(Component).SessionName, Self.SessionName) <> 0) then
        TTDBDataSet(Component).SessionName := Self.SessionName
      else if (Component is TTinyDataBase) and
        (AnsiCompareText(TTinyDataBase(Component).SessionName, Self.SessionName) <> 0) then
        TTinyDataBase(Component).SessionName := Self.SessionName
    end;
end;

procedure TTinySession.SetLockRetryCount(Value: Integer);
begin
  if Value < 0 then Value := 0;
  if Value <> FLockRetryCount then
    FLockRetryCount := Value;
end;

procedure TTinySession.SetLockWaitTime(Value: Integer);
begin
  if Value < 0 then Value := 0;
  if Value <> FLockWaitTime then
    FLockWaitTime := Value;
end;

function TTinySession.SessionNameStored: Boolean;
begin
  Result := not FAutoSessionName;
end;

procedure TTinySession.ValidateAutoSession(AOwner: TComponent; AllSessions: Boolean);
var
  I: Integer;
  Component: TComponent;
begin
  if AOwner <> nil then
    for I := 0 to AOwner.ComponentCount - 1 do
    begin
      Component := AOwner.Components[I];
      if (Component <> Self) and (Component is TTinySession) then
        if AllSessions then DatabaseError(SAutoSessionExclusive, Self)
        else if TTinySession(Component).AutoSessionName then
          DatabaseErrorFmt(SAutoSessionExists, [Component.Name]);
    end;
end;

function TTinySession.DoFindDatabase(const DatabaseName: string; AOwner: TComponent): TTinyDatabase;
var
  I: Integer;
begin
  if AOwner <> nil then
    for I := 0 to FDatabases.Count - 1 do
    begin
      Result := FDatabases[I];
      if (Result.Owner = AOwner) and (Result.HandleShared) and
        (AnsiCompareText(Result.DatabaseName, DatabaseName) = 0) then Exit;
    end;
  Result := FindDatabase(DatabaseName);
end;

function TTinySession.DoOpenDatabase(const DatabaseName: string;
  AOwner: TComponent; ADataSet: TTDBDataSet; IncRef: Boolean): TTinyDatabase;
var
  TempDatabase: TTinyDatabase;
begin
  Result := nil;
  LockSession;
  try
    TempDatabase := nil;
    try
      Result := DoFindDatabase(DatabaseName, AOwner);
      if Result = nil then
      begin
        TempDatabase := TTinyDatabase.Create(Self);
        if ADataSet <> nil then
          TempDatabase.MediumType := (ADataSet as TTDEDataSet).MediumType;
        TempDatabase.DatabaseName := DatabaseName;
        TempDatabase.KeepConnection := FKeepConnections;
        TempDatabase.Temporary := True;
        Result := TempDatabase;
      end;
      Result.Open;
      if IncRef then Inc(Result.FRefCount);
    except
      TempDatabase.Free;
      raise;
    end;
  finally
    UnLockSession;
  end;
end;

procedure TTinySession.AddDatabase(Value: TTinyDatabase);
begin
  FDatabases.Add(Value);
  DBNotification(dbAdd, Value);
end;

procedure TTinySession.RemoveDatabase(Value: TTinyDatabase);
begin
  FDatabases.Remove(Value);
  DBNotification(dbRemove, Value);
end;

procedure TTinySession.DBNotification(DBEvent: TTinyDatabaseEvent; const Param);
begin
  if Assigned(FOnDBNotify) then FOnDBNotify(DBEvent, Param);
end;

procedure TTinySession.LockSession;
begin
  if FLockCount = 0 then
  begin
    EnterCriticalSection(FSessionCSect);
    Inc(FLockCount);
    if not Active then SetActive(True);
  end
  else
    Inc(FLockCount);
end;

procedure TTinySession.UnlockSession;
begin
  Dec(FLockCount);
  if FLockCount = 0 then
    LeaveCriticalSection(FSessionCSect);
end;

procedure TTinySession.StartSession(Value: Boolean);
var
  I: Integer;
begin
  EnterCriticalSection(FSessionCSect);
  try
    if Value then
    begin
      if Assigned(FOnStartup) then FOnStartup(Self);
      if FSessionName = '' then DatabaseError(SSessionNameMissing, Self);
      if (DefaultSession <> Self) then DefaultSession.Active := True;
    end else
    begin
      for I := FDatabases.Count - 1 downto 0 do
        with TTinyDatabase(FDatabases[I]) do
          if Temporary then Free else Close;
    end;
    FActive := Value;
  finally
    LeaveCriticalSection(FSessionCSect);
  end;
end;

procedure TTinySession.UpdateAutoSessionName;
begin
  FUpdatingAutoSessionName := True;
  try
    SessionName := Format('%s_%d', [Name, FSessionNumber + 1]);
  finally
    FUpdatingAutoSessionName := False;
  end;
  SetSessionNames;
end;

function TTinySession.GetPasswordIndex(const Password: string): Integer;
var
  I: Integer;
begin
  for I := 0 to FPasswords.Count - 1 do
    if FPasswords[I] = Password then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

{ TTinySessionList }

constructor TTinySessionList.Create;
begin
  inherited Create;
  FSessions := TThreadList.Create;
  FSessionNumbers := TBits.Create;
  InitializeCriticalSection(FSessionCSect);
end;

destructor TTinySessionList.Destroy;
begin
  CloseAll;
  DeleteCriticalSection(FSessionCSect);
  FSessionNumbers.Free;
  FSessions.Free;
  inherited Destroy;
end;

procedure TTinySessionList.AddSession(ASession: TTinySession);
var
  List: TList;
begin
  List := FSessions.LockList;
  try
    if List.Count = 0 then ASession.FDefault := True;
    List.Add(ASession);
  finally
    FSessions.UnlockList;
  end;
end;

procedure TTinySessionList.CloseAll;
var
  I: Integer;
  List: TList;
begin
  List := FSessions.LockList;
  try
    for I := List.Count-1 downto 0 do
      TTinySession(List[I]).Free;
  finally
    FSessions.UnlockList;
  end;
end;

function TTinySessionList.GetCount: Integer;
var
  List: TList;
begin
  List := FSessions.LockList;
  try
    Result := List.Count;
  finally
    FSessions.UnlockList;
  end;
end;

function TTinySessionList.GetSession(Index: Integer): TTinySession;
var
  List: TList;
begin
  List := FSessions.LockList;
  try
    Result := TTinySession(List[Index]);
  finally
    FSessions.UnlockList;
  end;
end;

function TTinySessionList.GetSessionByName(const SessionName: string): TTinySession;
begin
  if SessionName = '' then
    Result := Session
  else
    Result := FindSession(SessionName);
  if Result = nil then
    DatabaseErrorFmt(SInvalidSessionName, [SessionName]);
end;

function TTinySessionList.FindSession(const SessionName: string): TTinySession;
var
  I: Integer;
  List: TList;
begin
  if SessionName = '' then
    Result := Session
  else
  begin
    List := FSessions.LockList;
    try
      for I := 0 to List.Count - 1 do
      begin
        Result := List[I];
        if AnsiCompareText(Result.SessionName, SessionName) = 0 then Exit;
      end;
      Result := nil;
    finally
      FSessions.UnlockList;
    end;
  end;
end;

procedure TTinySessionList.GetSessionNames(List: TStrings);
var
  I: Integer;
  SList: TList;
begin
  List.BeginUpdate;
  try
    List.Clear;
    SList := FSessions.LockList;
    try
      for I := 0 to SList.Count - 1 do
        with TTinySession(SList[I]) do
          List.Add(SessionName);
    finally
      FSessions.UnlockList;
    end;
  finally
    List.EndUpdate;
  end;
end;

function TTinySessionList.OpenSession(const SessionName: string): TTinySession;
begin
  Result := FindSession(SessionName);
  if Result = nil then
  begin
    Result := TTinySession.Create(nil);
    Result.SessionName := SessionName;
  end;
  Result.SetActive(True);
end;

{ TTinyDBLoginForm }

constructor TTinyDBLoginForm.CreateNew(AOwner: TComponent);
var
  NonClientMetrics: TNonClientMetrics;
begin
  inherited CreateNew(AOwner);
  NonClientMetrics.cbSize := sizeof(NonClientMetrics);
  if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
    Font.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont);
end;

initialization
  Sessions := TTinySessionList.Create;
  Session := TTinySession.Create(nil);
  Session.SessionName := 'Default'; { Do not localize }

finalization
  FCompressClassList.Free;
  FEncryptClassList.Free;
  Sessions.Free;
  Sessions := nil;

end.

