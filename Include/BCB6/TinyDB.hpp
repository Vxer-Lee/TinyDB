// Borland C++ Builder
// Copyright (c) 1995, 2002 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'TinyDB.pas' rev: 6.00

#ifndef TinyDBHPP
#define TinyDBHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <bdeconst.hpp>	// Pascal unit
#include <Consts.hpp>	// Pascal unit
#include <DBConsts.hpp>	// Pascal unit
#include <RTLConsts.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Math.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <ExtCtrls.hpp>	// Pascal unit
#include <StdCtrls.hpp>	// Pascal unit
#include <DB.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysUtils.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Tinydb
{
//-- type declarations -------------------------------------------------------
typedef Classes::TMemoryStream* *PMemoryStream;

typedef bool *PBoolean;

typedef Word *PWordBool;

typedef __int64 *PLargeInt;

typedef DynamicArray<int >  TIntegerAry;

#pragma option push -b-
enum TTinyDBMediumType { mtDisk, mtMemory };
#pragma option pop

#pragma option push -b-
enum TTDIndexOption { tiPrimary, tiUnique, tiDescending, tiCaseInsensitive };
#pragma option pop

typedef Set<TTDIndexOption, tiPrimary, tiCaseInsensitive>  TTDIndexOptions;

#pragma option push -b-
enum TTDKeyIndex { tkLookup, tkRangeStart, tkRangeEnd, tkSave };
#pragma option pop

#pragma option push -b-
enum TCompressLevel { clMaximum, clNormal, clFast, clSuperFast };
#pragma option pop

#pragma option push -b-
enum TEncryptMode { emCTS, emCBC, emCFB, emOFB, emECB };
#pragma option pop

#pragma option push -b-
enum TFieldDataProcessMode { fdDefault, fdOriginal };
#pragma option pop

typedef DynamicArray<TFieldDataProcessMode >  TFieldDPModeAry;

typedef void __fastcall (__closure *TOnProgressEvent)(System::TObject* Sender, int Percent);

#pragma pack(push, 1)
struct TFileHeader
{
	char SoftName[7];
	char FileFmtVer[5];
} ;
#pragma pack(pop)

typedef Byte TExtData[2048];

#pragma pack(push, 1)
struct TExtDataBlock
{
	char Comments[257];
	Byte Data[2048];
} ;
#pragma pack(pop)

typedef char TAlgoNameString[33];

#pragma pack(push, 1)
struct TDBOptions
{
	bool CompressBlob;
	TCompressLevel CompressLevel;
	char CompressAlgoName[33];
	bool Encrypt;
	TEncryptMode EncryptMode;
	char EncryptAlgoName[33];
	bool CRC32;
	char RandomBuffer[256];
	char HashPassword[129];
	Byte Reserved[16];
} ;
#pragma pack(pop)

#pragma pack(push, 1)
struct TTableTab
{
	int TableCount;
	int Reserved;
	int TableHeaderOffset[256];
} ;
#pragma pack(pop)

#pragma pack(push, 1)
struct TFieldTabItem
{
	char FieldName[33];
	Db::TFieldType FieldType;
	int FieldSize;
	TFieldDataProcessMode DPMode;
	int Reserved;
} ;
#pragma pack(pop)

#pragma pack(push, 1)
struct TIndexHeader
{
	char IndexName[33];
	TTDIndexOptions IndexOptions;
	int FieldIdx[8];
	int IndexOffset;
	int StartIndex;
	int Reserved;
} ;
#pragma pack(pop)

typedef char TTableNameString[33];

#pragma pack(push, 1)
struct TTableHeader
{
	char TableName[33];
	int RecTabOffset;
	int RecordTotal;
	int AutoIncCounter;
	int FieldCount;
	TFieldTabItem FieldTab[96];
	int IndexCount;
	TIndexHeader IndexHeader[8];
	Byte Reserved[16];
} ;
#pragma pack(pop)

#pragma pack(push, 1)
struct TRecordTabItem
{
	int DataOffset;
	bool DeleteFlag;
} ;
#pragma pack(pop)

typedef DynamicArray<TRecordTabItem >  TRecordTabItems;

typedef TRecordTabItems *PRecordTabItems;

#pragma pack(push, 1)
struct TIndexTabItem
{
	int RecIndex;
	int Next;
} ;
#pragma pack(pop)

typedef DynamicArray<TIndexTabItem >  TIndexTabItems;

#pragma pack(push, 1)
struct TBlobFieldHeader
{
	int DataOffset;
	int DataSize;
	int AreaSize;
	int Reserved1;
	int Reserved2;
} ;
#pragma pack(pop)

typedef TBlobFieldHeader *PBlobFieldHeader;

#pragma pack(push, 4)
struct TMemRecTabItem
{
	int DataOffset;
	int RecIndex;
} ;
#pragma pack(pop)

typedef TMemRecTabItem *PMemRecTabItem;

typedef DynamicArray<int >  TinyDB__1;

#pragma pack(push, 4)
struct TMemQryRecItem
{
	DynamicArray<int >  DataOffsets;
} ;
#pragma pack(pop)

struct TRecInfo;
typedef TRecInfo *PRecInfo;

#pragma pack(push, 1)
struct TRecInfo
{
	int Bookmark;
	Db::TBookmarkFlag BookmarkFlag;
} ;
#pragma pack(pop)

#pragma pack(push, 4)
struct TFieldItem
{
	System::SmallString<33>  FieldName;
	Db::TFieldType FieldType;
	int DataSize;
	TFieldDataProcessMode DPMode;
} ;
#pragma pack(pop)

class DELPHICLASS TTinyDefCollection;
class PASCALIMPLEMENTATION TTinyDefCollection : public Classes::TOwnedCollection 
{
	typedef Classes::TOwnedCollection inherited;
	
protected:
	virtual void __fastcall SetItemName(Classes::TCollectionItem* AItem);
	
public:
	__fastcall TTinyDefCollection(Classes::TPersistent* AOwner, TMetaClass* AClass);
	Db::TNamedItem* __fastcall Find(const AnsiString AName);
	void __fastcall GetItemNames(Classes::TStrings* List);
	int __fastcall IndexOf(const AnsiString AName);
public:
	#pragma option push -w-inl
	/* TCollection.Destroy */ inline __fastcall virtual ~TTinyDefCollection(void) { }
	#pragma option pop
	
};


class DELPHICLASS TTinyTableDef;
class PASCALIMPLEMENTATION TTinyTableDef : public Db::TNamedItem 
{
	typedef Db::TNamedItem inherited;
	
private:
	int FTableIdx;
	
public:
	__fastcall virtual TTinyTableDef(Classes::TCollection* Collection);
	__fastcall virtual ~TTinyTableDef(void);
	__property int TableIdx = {read=FTableIdx, write=FTableIdx, nodefault};
};


class DELPHICLASS TTinyTableDefs;
class PASCALIMPLEMENTATION TTinyTableDefs : public Classes::TOwnedCollection 
{
	typedef Classes::TOwnedCollection inherited;
	
public:
	TTinyTableDef* operator[](int Index) { return Items[Index]; }
	
private:
	HIDESBASE TTinyTableDef* __fastcall GetItem(int Index);
	
public:
	__fastcall TTinyTableDefs(Classes::TPersistent* AOwner);
	int __fastcall IndexOf(const AnsiString Name);
	TTinyTableDef* __fastcall Find(const AnsiString Name);
	__property TTinyTableDef* Items[int Index] = {read=GetItem/*, default*/};
public:
	#pragma option push -w-inl
	/* TCollection.Destroy */ inline __fastcall virtual ~TTinyTableDefs(void) { }
	#pragma option pop
	
};


class DELPHICLASS TTinyFieldDef;
class PASCALIMPLEMENTATION TTinyFieldDef : public Db::TNamedItem 
{
	typedef Db::TNamedItem inherited;
	
private:
	Db::TFieldType FFieldType;
	int FFieldSize;
	TFieldDataProcessMode FDPMode;
	
public:
	__fastcall virtual TTinyFieldDef(Classes::TCollection* Collection);
	__fastcall virtual ~TTinyFieldDef(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property Db::TFieldType FieldType = {read=FFieldType, write=FFieldType, nodefault};
	__property int FieldSize = {read=FFieldSize, write=FFieldSize, nodefault};
	__property TFieldDataProcessMode DPMode = {read=FDPMode, write=FDPMode, nodefault};
};


class DELPHICLASS TTinyFieldDefs;
class PASCALIMPLEMENTATION TTinyFieldDefs : public TTinyDefCollection 
{
	typedef TTinyDefCollection inherited;
	
public:
	TTinyFieldDef* operator[](int Index) { return Items[Index]; }
	
private:
	TTinyFieldDef* __fastcall GetFieldDef(int Index);
	void __fastcall SetFieldDef(int Index, TTinyFieldDef* Value);
	
protected:
	virtual void __fastcall SetItemName(Classes::TCollectionItem* AItem);
	
public:
	__fastcall TTinyFieldDefs(Classes::TPersistent* AOwner);
	TTinyFieldDef* __fastcall AddIndexDef(void);
	HIDESBASE TTinyFieldDef* __fastcall Find(const AnsiString Name);
	__property TTinyFieldDef* Items[int Index] = {read=GetFieldDef, write=SetFieldDef/*, default*/};
public:
	#pragma option push -w-inl
	/* TCollection.Destroy */ inline __fastcall virtual ~TTinyFieldDefs(void) { }
	#pragma option pop
	
};


class DELPHICLASS TTinyIndexDef;
class PASCALIMPLEMENTATION TTinyIndexDef : public Db::TNamedItem 
{
	typedef Db::TNamedItem inherited;
	
private:
	TTDIndexOptions FOptions;
	DynamicArray<int >  FFieldIdxes;
	void __fastcall SetOptions(TTDIndexOptions Value);
	
public:
	__fastcall virtual TTinyIndexDef(Classes::TCollection* Collection);
	__fastcall virtual ~TTinyIndexDef(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TIntegerAry FieldIdxes = {read=FFieldIdxes, write=FFieldIdxes};
	
__published:
	__property TTDIndexOptions Options = {read=FOptions, write=SetOptions, default=0};
};


class DELPHICLASS TTinyIndexDefs;
class PASCALIMPLEMENTATION TTinyIndexDefs : public TTinyDefCollection 
{
	typedef TTinyDefCollection inherited;
	
public:
	TTinyIndexDef* operator[](int Index) { return Items[Index]; }
	
private:
	TTinyIndexDef* __fastcall GetIndexDef(int Index);
	void __fastcall SetIndexDef(int Index, TTinyIndexDef* Value);
	
protected:
	virtual void __fastcall SetItemName(Classes::TCollectionItem* AItem);
	
public:
	__fastcall TTinyIndexDefs(Classes::TPersistent* AOwner);
	TTinyIndexDef* __fastcall AddIndexDef(void);
	HIDESBASE TTinyIndexDef* __fastcall Find(const AnsiString Name);
	__property TTinyIndexDef* Items[int Index] = {read=GetIndexDef, write=SetIndexDef/*, default*/};
public:
	#pragma option push -w-inl
	/* TCollection.Destroy */ inline __fastcall virtual ~TTinyIndexDefs(void) { }
	#pragma option pop
	
};


class DELPHICLASS TTinyBlobStream;
class DELPHICLASS TTinyTable;
class DELPHICLASS TTDEDataSet;
class DELPHICLASS TTDBDataSet;
class DELPHICLASS TTinyDatabase;
class DELPHICLASS TTinyAboutBox;
class PASCALIMPLEMENTATION TTinyAboutBox : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall TTinyAboutBox(void) : System::TObject() { }
	#pragma option pop
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~TTinyAboutBox(void) { }
	#pragma option pop
	
};


class DELPHICLASS TTinyDBFileIO;
class DELPHICLASS TCompressMgr;
class DELPHICLASS TDataProcessMgr;
class DELPHICLASS TDataProcessAlgo;
class PASCALIMPLEMENTATION TDataProcessAlgo : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	System::TObject* FOwner;
	TOnProgressEvent FOnEncodeProgress;
	TOnProgressEvent FOnDecodeProgress;
	
protected:
	void __fastcall DoEncodeProgress(int Percent);
	void __fastcall DoDecodeProgress(int Percent);
	
public:
	__fastcall virtual TDataProcessAlgo(System::TObject* AOwner);
	__fastcall virtual ~TDataProcessAlgo(void);
	virtual void __fastcall EncodeStream(Classes::TMemoryStream* Source, Classes::TMemoryStream* Dest, int DataSize) = 0 ;
	virtual void __fastcall DecodeStream(Classes::TMemoryStream* Source, Classes::TMemoryStream* Dest, int DataSize) = 0 ;
	__property TOnProgressEvent OnEncodeProgress = {read=FOnEncodeProgress, write=FOnEncodeProgress};
	__property TOnProgressEvent OnDecodeProgress = {read=FOnDecodeProgress, write=FOnDecodeProgress};
};


class PASCALIMPLEMENTATION TDataProcessMgr : public System::TObject 
{
	typedef System::TObject inherited;
	
protected:
	TTinyDBFileIO* FTinyDBFile;
	TDataProcessAlgo* FDPObject;
	
public:
	__fastcall TDataProcessMgr(TTinyDBFileIO* AOwner);
	__fastcall virtual ~TDataProcessMgr(void);
	/* virtual class method */ virtual int __fastcall CheckAlgoRegistered(TMetaClass* vmt, const AnsiString AlgoName);
	virtual void __fastcall SetAlgoName(const AnsiString Value) = 0 ;
	virtual void __fastcall EncodeStream(Classes::TMemoryStream* Source, Classes::TMemoryStream* Dest, int DataSize);
	virtual void __fastcall DecodeStream(Classes::TMemoryStream* Source, Classes::TMemoryStream* Dest, int DataSize);
};


class PASCALIMPLEMENTATION TCompressMgr : public TDataProcessMgr 
{
	typedef TDataProcessMgr inherited;
	
private:
	TCompressLevel __fastcall GetLevel(void);
	void __fastcall SetLevel(const TCompressLevel Value);
	
public:
	/* virtual class method */ virtual int __fastcall CheckAlgoRegistered(TMetaClass* vmt, const AnsiString AlgoName);
	virtual void __fastcall SetAlgoName(const AnsiString Value);
	__property TCompressLevel Level = {read=GetLevel, write=SetLevel, nodefault};
public:
	#pragma option push -w-inl
	/* TDataProcessMgr.Create */ inline __fastcall TCompressMgr(TTinyDBFileIO* AOwner) : TDataProcessMgr(AOwner) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TDataProcessMgr.Destroy */ inline __fastcall virtual ~TCompressMgr(void) { }
	#pragma option pop
	
};


class DELPHICLASS TEncryptMgr;
class PASCALIMPLEMENTATION TEncryptMgr : public TDataProcessMgr 
{
	typedef TDataProcessMgr inherited;
	
protected:
	TEncryptMode __fastcall GetMode(void);
	void __fastcall SetMode(const TEncryptMode Value);
	
public:
	void __fastcall InitKey(const AnsiString Key);
	void __fastcall Done(void);
	/* virtual class method */ virtual int __fastcall CheckAlgoRegistered(TMetaClass* vmt, const AnsiString AlgoName);
	virtual void __fastcall SetAlgoName(const AnsiString Value);
	virtual void __fastcall EncodeStream(Classes::TMemoryStream* Source, Classes::TMemoryStream* Dest, int DataSize);
	virtual void __fastcall DecodeStream(Classes::TMemoryStream* Source, Classes::TMemoryStream* Dest, int DataSize);
	virtual void __fastcall EncodeBuffer(const void *Source, void *Dest, int DataSize);
	virtual void __fastcall DecodeBuffer(const void *Source, void *Dest, int DataSize);
	__property TEncryptMode Mode = {read=GetMode, write=SetMode, nodefault};
public:
	#pragma option push -w-inl
	/* TDataProcessMgr.Create */ inline __fastcall TEncryptMgr(TTinyDBFileIO* AOwner) : TDataProcessMgr(AOwner) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TDataProcessMgr.Destroy */ inline __fastcall virtual ~TEncryptMgr(void) { }
	#pragma option pop
	
};


class PASCALIMPLEMENTATION TTinyDBFileIO : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	TTinyDatabase* FDatabase;
	AnsiString FDatabaseName;
	TTinyDBMediumType FMediumType;
	bool FExclusive;
	Classes::TStream* FDBStream;
	bool FFileIsReadOnly;
	TCompressMgr* FCompressMgr;
	TEncryptMgr* FEncryptMgr;
	#pragma pack(push, 1)
	TDBOptions FDBOptions;
	#pragma pack(pop)
	
	#pragma pack(push, 1)
	TTableTab FTableTab;
	#pragma pack(pop)
	
	_RTL_CRITICAL_SECTION FDPCSect;
	bool __fastcall GetIsOpen(void);
	bool __fastcall GetFlushed(void);
	void __fastcall InitDBOptions(void);
	void __fastcall InitTableTab(void);
	void __fastcall DoOperationProgressEvent(TTinyDatabase* ADatabase, int Pos, int Max);
	
protected:
	void __fastcall DecodeMemoryStream(Classes::TMemoryStream* SrcStream, Classes::TMemoryStream* DstStream, bool Encrypt, bool Compress);
	void __fastcall DecodeMemoryBuffer(char * SrcBuffer, char * DstBuffer, int DataSize, bool Encrypt);
	void __fastcall EncodeMemoryStream(Classes::TMemoryStream* SrcStream, Classes::TMemoryStream* DstStream, bool Encrypt, bool Compress);
	void __fastcall EncodeMemoryBuffer(char * SrcBuffer, char * DstBuffer, int DataSize, bool Encrypt);
	void __fastcall OnCompressProgressEvent(System::TObject* Sender, int Percent);
	void __fastcall OnUncompressProgressEvent(System::TObject* Sender, int Percent);
	void __fastcall OnEncryptProgressEvent(System::TObject* Sender, int Percent);
	void __fastcall OnDecryptProgressEvent(System::TObject* Sender, int Percent);
	bool __fastcall CheckDupTableName(const AnsiString TableName);
	bool __fastcall CheckDupIndexName(TTableHeader &TableHeader, const AnsiString IndexName);
	bool __fastcall CheckDupPrimaryIndex(TTableHeader &TableHeader, TTDIndexOptions IndexOptions);
	void __fastcall CheckValidFields(const TFieldItem * Fields, const int Fields_Size);
	void __fastcall CheckValidIndexFields(const AnsiString * FieldNames, const int FieldNames_Size, TTDIndexOptions IndexOptions, TTableHeader &TableHeader);
	int __fastcall GetFieldIdxByName(const TTableHeader &TableHeader, const AnsiString FieldName);
	int __fastcall GetIndexIdxByName(const TTableHeader &TableHeader, const AnsiString IndexName);
	int __fastcall GetTableIdxByName(const AnsiString TableName);
	AnsiString __fastcall GetTempFileName();
	bool __fastcall ReCreate(bool NewCompressBlob, TCompressLevel NewCompressLevel, const AnsiString NewCompressAlgoName, bool NewEncrypt, const AnsiString NewEncAlgoName, const AnsiString OldPassword, const AnsiString NewPassword, bool NewCRC32);
	
public:
	__fastcall TTinyDBFileIO(TTinyDatabase* AOwner);
	__fastcall virtual ~TTinyDBFileIO(void);
	void __fastcall Open(const AnsiString ADatabaseName, TTinyDBMediumType AMediumType, bool AExclusive);
	void __fastcall Close(void);
	void __fastcall Flush(void);
	bool __fastcall SetPassword(const AnsiString Value);
	void __fastcall Lock(void);
	void __fastcall Unlock(void);
	void __fastcall ReadBuffer(void *Buffer, int Position, int Count);
	void __fastcall ReadDBVersion(AnsiString &Dest);
	void __fastcall ReadExtDataBlock(TExtDataBlock &Dest);
	void __fastcall WriteExtDataBlock(TExtDataBlock &Dest);
	void __fastcall ReadDBOptions(TDBOptions &Dest);
	void __fastcall WriteDBOptions(TDBOptions &Dest);
	void __fastcall ReadTableTab(TTableTab &Dest);
	void __fastcall WriteTableTab(TTableTab &Dest);
	void __fastcall ReadTableHeader(int TableIdx, TTableHeader &Dest);
	void __fastcall WriteTableHeader(int TableIdx, TTableHeader &Dest);
	/*         class method */ static bool __fastcall CheckValidTinyDB(TMetaClass* vmt, Classes::TStream* ADBStream)/* overload */;
	/*         class method */ static bool __fastcall CheckValidTinyDB(TMetaClass* vmt, const AnsiString FileName)/* overload */;
	/*         class method */ static bool __fastcall CheckTinyDBVersion(TMetaClass* vmt, Classes::TStream* ADBStream)/* overload */;
	/*         class method */ static bool __fastcall CheckTinyDBVersion(TMetaClass* vmt, const AnsiString FileName)/* overload */;
	void __fastcall GetTableNames(Classes::TStrings* List);
	void __fastcall GetFieldNames(const AnsiString TableName, Classes::TStrings* List);
	void __fastcall GetIndexNames(const AnsiString TableName, Classes::TStrings* List);
	void __fastcall ReadFieldData(Classes::TMemoryStream* DstStream, int RecTabItemOffset, int DiskFieldOffset, int FieldSize, bool IsBlob, bool ShouldEncrypt, bool ShouldCompress)/* overload */;
	void __fastcall ReadFieldData(Classes::TMemoryStream* DstStream, int FieldDataOffset, int FieldSize, bool IsBlob, bool ShouldEncrypt, bool ShouldCompress)/* overload */;
	void __fastcall ReadAllRecordTabItems(const TTableHeader &TableHeader, TRecordTabItems &Items, TIntegerAry &BlockOffsets);
	void __fastcall ReadAllIndexTabItems(const TTableHeader &TableHeader, int IndexIdx, TIndexTabItems &Items, TIntegerAry &BlockOffsets);
	void __fastcall WriteDeleteFlag(int RecTabItemOffset);
	bool __fastcall CreateDatabase(const AnsiString DBFileName, bool CompressBlob, TCompressLevel CompressLevel, const AnsiString CompressAlgoName, bool Encrypt, const AnsiString EncryptAlgoName, const AnsiString Password, bool CRC32 = false)/* overload */;
	bool __fastcall CreateTable(const AnsiString TableName, const TFieldItem * Fields, const int Fields_Size);
	bool __fastcall DeleteTable(const AnsiString TableName);
	bool __fastcall CreateIndex(const AnsiString TableName, const AnsiString IndexName, TTDIndexOptions IndexOptions, const AnsiString * FieldNames, const int FieldNames_Size);
	bool __fastcall DeleteIndex(const AnsiString TableName, const AnsiString IndexName);
	bool __fastcall RenameTable(const AnsiString OldTableName, const AnsiString NewTableName);
	bool __fastcall RenameField(const AnsiString TableName, const AnsiString OldFieldName, const AnsiString NewFieldName);
	bool __fastcall RenameIndex(const AnsiString TableName, const AnsiString OldIndexName, const AnsiString NewIndexName);
	bool __fastcall Compact(const AnsiString Password);
	bool __fastcall Repair(const AnsiString Password);
	bool __fastcall ChangePassword(const AnsiString OldPassword, const AnsiString NewPassword, bool Check = true);
	bool __fastcall ChangeEncrypt(bool NewEncrypt, const AnsiString NewEncAlgo, const AnsiString OldPassword, const AnsiString NewPassword);
	bool __fastcall SetComments(const AnsiString Value, const AnsiString Password);
	bool __fastcall GetComments(AnsiString &Value, const AnsiString Password);
	bool __fastcall SetExtData(char * Buffer, int Size);
	bool __fastcall GetExtData(char * Buffer);
	__property Classes::TStream* DBStream = {read=FDBStream};
	__property TDBOptions DBOptions = {read=FDBOptions};
	__property TTableTab TableTab = {read=FTableTab};
	__property bool IsOpen = {read=GetIsOpen, nodefault};
	__property bool FileIsReadOnly = {read=FFileIsReadOnly, nodefault};
	__property bool Flushed = {read=GetFlushed, nodefault};
};


class DELPHICLASS TTinySession;
#pragma option push -b-
enum TTinyDatabaseEvent { dbOpen, dbClose, dbAdd, dbRemove, dbAddAlias, dbDeleteAlias, dbAddDriver, dbDeleteDriver };
#pragma option pop

typedef void __fastcall (__closure *TTinyDatabaseNotifyEvent)(TTinyDatabaseEvent DBEvent, const void *Param);

class PASCALIMPLEMENTATION TTinySession : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	TTinyAboutBox* FAboutBox;
	bool FActive;
	Classes::TList* FDatabases;
	bool FKeepConnections;
	bool FDefault;
	AnsiString FSessionName;
	int FSessionNumber;
	bool FAutoSessionName;
	bool FSQLHourGlass;
	int FLockCount;
	bool FStreamedActive;
	bool FUpdatingAutoSessionName;
	int FLockRetryCount;
	int FLockWaitTime;
	Classes::TStrings* FPasswords;
	Classes::TNotifyEvent FOnStartup;
	TTinyDatabaseNotifyEvent FOnDBNotify;
	void __fastcall CheckInactive(void);
	bool __fastcall GetActive(void);
	TTinyDatabase* __fastcall GetDatabase(int Index);
	int __fastcall GetDatabaseCount(void);
	void __fastcall SetActive(bool Value);
	void __fastcall SetAutoSessionName(bool Value);
	void __fastcall SetSessionName(const AnsiString Value);
	void __fastcall SetSessionNames(void);
	void __fastcall SetLockRetryCount(int Value);
	void __fastcall SetLockWaitTime(int Value);
	bool __fastcall SessionNameStored(void);
	void __fastcall ValidateAutoSession(Classes::TComponent* AOwner, bool AllSessions);
	TTinyDatabase* __fastcall DoFindDatabase(const AnsiString DatabaseName, Classes::TComponent* AOwner);
	TTinyDatabase* __fastcall DoOpenDatabase(const AnsiString DatabaseName, Classes::TComponent* AOwner, TTDBDataSet* ADataSet, bool IncRef);
	void __fastcall AddDatabase(TTinyDatabase* Value);
	void __fastcall RemoveDatabase(TTinyDatabase* Value);
	void __fastcall DBNotification(TTinyDatabaseEvent DBEvent, const void *Param);
	void __fastcall LockSession(void);
	void __fastcall UnlockSession(void);
	void __fastcall StartSession(bool Value);
	void __fastcall UpdateAutoSessionName(void);
	int __fastcall GetPasswordIndex(const AnsiString Password);
	
protected:
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall SetName(const AnsiString NewName);
	__property TTinyDatabaseNotifyEvent OnDBNotify = {read=FOnDBNotify, write=FOnDBNotify};
	
public:
	__fastcall virtual TTinySession(Classes::TComponent* AOwner);
	__fastcall virtual ~TTinySession(void);
	void __fastcall Open(void);
	void __fastcall Close(void);
	TTinyDatabase* __fastcall OpenDatabase(const AnsiString DatabaseName);
	void __fastcall CloseDatabase(TTinyDatabase* Database);
	TTinyDatabase* __fastcall FindDatabase(const AnsiString DatabaseName);
	void __fastcall DropConnections(void);
	void __fastcall GetDatabaseNames(Classes::TStrings* List);
	void __fastcall GetTableNames(const AnsiString DatabaseName, Classes::TStrings* List);
	void __fastcall GetFieldNames(const AnsiString DatabaseName, const AnsiString TableName, Classes::TStrings* List);
	void __fastcall GetIndexNames(const AnsiString DatabaseName, const AnsiString TableName, Classes::TStrings* List);
	void __fastcall AddPassword(const AnsiString Password);
	void __fastcall RemovePassword(const AnsiString Password);
	void __fastcall RemoveAllPasswords(void);
	__property int DatabaseCount = {read=GetDatabaseCount, nodefault};
	__property TTinyDatabase* Databases[int Index] = {read=GetDatabase};
	
__published:
	__property TTinyAboutBox* About = {read=FAboutBox, write=FAboutBox};
	__property bool Active = {read=GetActive, write=SetActive, default=0};
	__property bool AutoSessionName = {read=FAutoSessionName, write=SetAutoSessionName, default=0};
	__property bool KeepConnections = {read=FKeepConnections, write=FKeepConnections, default=0};
	__property AnsiString SessionName = {read=FSessionName, write=SetSessionName, stored=SessionNameStored};
	__property bool SQLHourGlass = {read=FSQLHourGlass, write=FSQLHourGlass, default=1};
	__property int LockRetryCount = {read=FLockRetryCount, write=SetLockRetryCount, default=20};
	__property int LockWaitTime = {read=FLockWaitTime, write=SetLockWaitTime, default=100};
	__property Classes::TNotifyEvent OnStartup = {read=FOnStartup, write=FOnStartup};
};


class DELPHICLASS TTinyTableIO;
class PASCALIMPLEMENTATION TTinyDatabase : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	TTinyAboutBox* FAboutBox;
	TTinyDBFileIO* FDBFileIO;
	Classes::TList* FDataSets;
	bool FKeepConnection;
	bool FTemporary;
	bool FHandleShared;
	bool FExclusive;
	int FRefCount;
	bool FStreamedConnected;
	TTinySession* FSession;
	AnsiString FSessionName;
	AnsiString FDatabaseName;
	AnsiString FFileName;
	TTinyDBMediumType FMediumType;
	bool FCanAccess;
	AnsiString FPassword;
	bool FPasswordModified;
	TTinyTableDefs* FTableDefs;
	Classes::TList* FTableIOs;
	bool FFlushCacheAlways;
	bool FAutoFlush;
	int FAutoFlushInterval;
	Extctrls::TTimer* FAutoFlushTimer;
	Classes::TNotifyEvent FBeforeConnect;
	Classes::TNotifyEvent FBeforeDisconnect;
	Classes::TNotifyEvent FAfterConnect;
	Classes::TNotifyEvent FAfterDisconnect;
	TOnProgressEvent FOnCompressProgress;
	TOnProgressEvent FOnUncompressProgress;
	TOnProgressEvent FOnEncryptProgress;
	TOnProgressEvent FOnDecryptProgress;
	TOnProgressEvent FOnOperationProgress;
	bool __fastcall GetConnected(void);
	bool __fastcall GetEncrypted(void);
	AnsiString __fastcall GetEncryptAlgoName();
	bool __fastcall GetCompressed(void);
	TCompressLevel __fastcall GetCompressLevel(void);
	AnsiString __fastcall GetCompressAlgoName();
	bool __fastcall GetCRC32(void);
	TTinyTableIO* __fastcall GetTableIOs(int Index);
	int __fastcall GetFileSize(void);
	System::TDateTime __fastcall GetFileDate(void);
	bool __fastcall GetFileIsReadOnly(void);
	void __fastcall SetDatabaseName(const AnsiString Value);
	void __fastcall SetFileName(const AnsiString Value);
	void __fastcall SetMediumType(const TTinyDBMediumType Value);
	void __fastcall SetExclusive(const bool Value);
	void __fastcall SetKeepConnection(const bool Value);
	void __fastcall SetSessionName(const AnsiString Value);
	void __fastcall SetConnected(const bool Value);
	void __fastcall SetPassword(AnsiString Value);
	void __fastcall SetCRC32(bool Value);
	void __fastcall SetAutoFlush(bool Value);
	void __fastcall SetAutoFlushInterval(int Value);
	Forms::TForm* __fastcall CreateLoginDialog(const AnsiString ADatabaseName);
	bool __fastcall ShowLoginDialog(const AnsiString ADatabaseName, AnsiString &APassword);
	TTinyTableIO* __fastcall TableIOByName(const AnsiString Name);
	AnsiString __fastcall GetDBFileName();
	void __fastcall CheckSessionName(bool Required);
	void __fastcall CheckInactive(void);
	void __fastcall CheckDatabaseName(void);
	void __fastcall InitTableIOs(void);
	void __fastcall FreeTableIOs(void);
	void __fastcall AddTableIO(const AnsiString TableName);
	void __fastcall DeleteTableIO(const AnsiString TableName);
	void __fastcall RenameTableIO(const AnsiString OldTableName, const AnsiString NewTableName);
	void __fastcall RefreshAllTableIOs(void);
	void __fastcall RefreshAllDataSets(void);
	void __fastcall InitTableDefs(void);
	void __fastcall AutoFlushTimer(System::TObject* Sender);
	
protected:
	virtual void __fastcall DoConnect(void);
	virtual void __fastcall DoDisconnect(void);
	virtual void __fastcall CheckCanAccess(void);
	virtual TTDEDataSet* __fastcall GetDataSet(int Index);
	virtual int __fastcall GetDataSetCount(void);
	virtual void __fastcall RegisterClient(System::TObject* Client, Db::TConnectChangeEvent Event = 0x0);
	virtual void __fastcall UnRegisterClient(System::TObject* Client);
	void __fastcall SendConnectEvent(bool Connecting);
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	__property bool StreamedConnected = {read=FStreamedConnected, write=FStreamedConnected, nodefault};
	__property bool HandleShared = {read=FHandleShared, nodefault};
	
public:
	__fastcall virtual TTinyDatabase(Classes::TComponent* AOwner);
	__fastcall virtual ~TTinyDatabase(void);
	void __fastcall Open(void);
	void __fastcall Close(void);
	void __fastcall CloseDataSets(void);
	void __fastcall FlushCache(void);
	void __fastcall ValidateName(const AnsiString Name);
	void __fastcall GetTableNames(Classes::TStrings* List);
	void __fastcall GetFieldNames(const AnsiString TableName, Classes::TStrings* List);
	void __fastcall GetIndexNames(const AnsiString TableName, Classes::TStrings* List);
	bool __fastcall TableExists(const AnsiString TableName);
	/*         class method */ static int __fastcall GetCompressAlgoNames(TMetaClass* vmt, Classes::TStrings* List);
	/*         class method */ static int __fastcall GetEncryptAlgoNames(TMetaClass* vmt, Classes::TStrings* List);
	/*         class method */ static bool __fastcall IsTinyDBFile(TMetaClass* vmt, const AnsiString FileName);
	bool __fastcall CreateDatabase(const AnsiString DBFileName)/* overload */;
	bool __fastcall CreateDatabase(const AnsiString DBFileName, bool CompressBlob, TCompressLevel CompressLevel, const AnsiString CompressAlgoName, bool Encrypt, const AnsiString EncryptAlgoName, const AnsiString Password, bool CRC32 = false)/* overload */;
	bool __fastcall CreateTable(const AnsiString TableName, const TFieldItem * Fields, const int Fields_Size);
	bool __fastcall DeleteTable(const AnsiString TableName);
	bool __fastcall CreateIndex(const AnsiString TableName, const AnsiString IndexName, TTDIndexOptions IndexOptions, const AnsiString * FieldNames, const int FieldNames_Size);
	bool __fastcall DeleteIndex(const AnsiString TableName, const AnsiString IndexName);
	bool __fastcall RenameTable(const AnsiString OldTableName, const AnsiString NewTableName);
	bool __fastcall RenameField(const AnsiString TableName, const AnsiString OldFieldName, const AnsiString NewFieldName);
	bool __fastcall RenameIndex(const AnsiString TableName, const AnsiString OldIndexName, const AnsiString NewIndexName);
	bool __fastcall Compact(void);
	bool __fastcall Repair(void);
	bool __fastcall ChangePassword(const AnsiString NewPassword, bool Check = true);
	bool __fastcall ChangeEncrypt(bool NewEncrypt, const AnsiString NewEncAlgo, const AnsiString NewPassword);
	bool __fastcall SetComments(const AnsiString Value);
	bool __fastcall GetComments(AnsiString &Value);
	bool __fastcall SetExtData(char * Buffer, int Size);
	bool __fastcall GetExtData(char * Buffer);
	__property TTinyDBFileIO* DBFileIO = {read=FDBFileIO};
	__property TTinyTableIO* TableIOs[int Index] = {read=GetTableIOs};
	__property TTDEDataSet* DataSets[int Index] = {read=GetDataSet};
	__property int DataSetCount = {read=GetDataSetCount, nodefault};
	__property TTinySession* Session = {read=FSession};
	__property TTinyTableDefs* TableDefs = {read=FTableDefs};
	__property bool Temporary = {read=FTemporary, write=FTemporary, nodefault};
	__property AnsiString Password = {read=FPassword, write=SetPassword};
	__property bool CanAccess = {read=FCanAccess, nodefault};
	__property bool Encrypted = {read=GetEncrypted, nodefault};
	__property AnsiString EncryptAlgoName = {read=GetEncryptAlgoName};
	__property bool Compressed = {read=GetCompressed, nodefault};
	__property TCompressLevel CompressLevel = {read=GetCompressLevel, nodefault};
	__property AnsiString CompressAlgoName = {read=GetCompressAlgoName};
	__property bool CRC32 = {read=GetCRC32, write=SetCRC32, nodefault};
	__property bool FlushCacheAlways = {read=FFlushCacheAlways, write=FFlushCacheAlways, nodefault};
	__property int FileSize = {read=GetFileSize, nodefault};
	__property System::TDateTime FileDate = {read=GetFileDate};
	__property bool FileIsReadOnly = {read=GetFileIsReadOnly, nodefault};
	
__published:
	__property TTinyAboutBox* About = {read=FAboutBox, write=FAboutBox};
	__property AnsiString FileName = {read=FFileName, write=SetFileName};
	__property AnsiString DatabaseName = {read=FDatabaseName, write=SetDatabaseName};
	__property TTinyDBMediumType MediumType = {read=FMediumType, write=SetMediumType, default=0};
	__property bool Connected = {read=GetConnected, write=SetConnected, default=0};
	__property bool Exclusive = {read=FExclusive, write=SetExclusive, default=0};
	__property bool KeepConnection = {read=FKeepConnection, write=SetKeepConnection, default=0};
	__property AnsiString SessionName = {read=FSessionName, write=SetSessionName};
	__property bool AutoFlush = {read=FAutoFlush, write=SetAutoFlush, default=0};
	__property int AutoFlushInterval = {read=FAutoFlushInterval, write=SetAutoFlushInterval, default=60000};
	__property Classes::TNotifyEvent BeforeConnect = {read=FBeforeConnect, write=FBeforeConnect};
	__property Classes::TNotifyEvent BeforeDisconnect = {read=FBeforeDisconnect, write=FBeforeDisconnect};
	__property Classes::TNotifyEvent AfterConnect = {read=FAfterConnect, write=FAfterConnect};
	__property Classes::TNotifyEvent AfterDisconnect = {read=FAfterDisconnect, write=FAfterDisconnect};
	__property TOnProgressEvent OnCompressProgress = {read=FOnCompressProgress, write=FOnCompressProgress};
	__property TOnProgressEvent OnUncompressProgress = {read=FOnUncompressProgress, write=FOnUncompressProgress};
	__property TOnProgressEvent OnEncryptProgress = {read=FOnEncryptProgress, write=FOnEncryptProgress};
	__property TOnProgressEvent OnDecryptProgress = {read=FOnDecryptProgress, write=FOnDecryptProgress};
	__property TOnProgressEvent OnOperationProgress = {read=FOnOperationProgress, write=FOnOperationProgress};
};


class PASCALIMPLEMENTATION TTDBDataSet : public Db::TDataSet 
{
	typedef Db::TDataSet inherited;
	
private:
	AnsiString FDatabaseName;
	TTinyDatabase* FDatabase;
	AnsiString FSessionName;
	void __fastcall CheckDBSessionName(void);
	TTinySession* __fastcall GetDBSession(void);
	void __fastcall SetSessionName(const AnsiString Value);
	
protected:
	virtual void __fastcall SetDatabaseName(const AnsiString Value);
	virtual void __fastcall Disconnect(void);
	virtual void __fastcall OpenCursor(bool InfoQuery);
	virtual void __fastcall CloseCursor(void);
	
public:
	__fastcall virtual TTDBDataSet(Classes::TComponent* AOwner);
	void __fastcall CloseDatabase(TTinyDatabase* Database);
	TTinyDatabase* __fastcall OpenDatabase(bool IncRef);
	__property TTinyDatabase* Database = {read=FDatabase};
	__property TTinySession* DBSession = {read=GetDBSession};
	
__published:
	__property AnsiString DatabaseName = {read=FDatabaseName, write=SetDatabaseName};
	__property AnsiString SessionName = {read=FSessionName, write=SetSessionName};
public:
	#pragma option push -w-inl
	/* TDataSet.Destroy */ inline __fastcall virtual ~TTDBDataSet(void) { }
	#pragma option pop
	
};


class DELPHICLASS TExprParserBase;
class DELPHICLASS TSyntaxParserBase;
#pragma option push -b-
enum TExprToken { etEnd, etSymbol, etName, etNumLiteral, etCharLiteral, etLParen, etRParen, etEQ, etNE, etGE, etLE, etGT, etLT, etADD, etSUB, etMUL, etDIV, etComma, etAsterisk, etLIKE, etISNULL, etISNOTNULL, etIN };
#pragma option pop

typedef Set<char, 0, 255>  TChrSet;

class PASCALIMPLEMENTATION TSyntaxParserBase : public System::TObject 
{
	typedef System::TObject inherited;
	
protected:
	AnsiString FText;
	AnsiString FTokenString;
	TExprToken FToken;
	TExprToken FPrevToken;
	char *FSourcePtr;
	char *FTokenPtr;
	void __fastcall SetText(const AnsiString Value);
	bool __fastcall IsKatakana(const Byte Chr);
	void __fastcall Skip(char * &P, const TChrSet &TheSet);
	AnsiString __fastcall TokenName();
	bool __fastcall TokenSymbolIs(const AnsiString S);
	void __fastcall Rewind(void);
	void __fastcall GetNextToken(void);
	virtual char * __fastcall SkipBeforeGetToken(char * Pos);
	virtual char * __fastcall InternalGetNextToken(char * Pos) = 0 ;
	
public:
	__fastcall TSyntaxParserBase(void);
	__fastcall virtual ~TSyntaxParserBase(void);
	__property AnsiString Text = {read=FText, write=SetText};
	__property AnsiString TokenString = {read=FTokenString};
	__property TExprToken Token = {read=FToken, nodefault};
};


class DELPHICLASS TExprNodes;
class DELPHICLASS TExprNode;
#pragma option push -b-
enum TExprNodeKind { enField, enConst, enFunc, enOperator };
#pragma option pop

#pragma option push -b-
enum TTinyOperator { toNOTDEFINED, toISBLANK, toNOTBLANK, toEQ, toNE, toGT, toLT, toGE, toLE, toNOT, toAND, toOR, toADD, toSUB, toMUL, toDIV, toMOD, toLIKE, toIN, toASSIGN };
#pragma option pop

#pragma option push -b-
enum TTinyFunction { tfUnknown, tfUpper, tfLower, tfSubString, tfTrim, tfTrimLeft, tfTrimRight, tfYear, tfMonth, tfDay, tfHour, tfMinute, tfSecond, tfGetDate };
#pragma option pop

#pragma option push -b-
enum TStrCompOption { scCaseInsensitive, scNoPartialCompare };
#pragma option pop

typedef Set<TStrCompOption, scCaseInsensitive, scNoPartialCompare>  TStrCompOptions;

class PASCALIMPLEMENTATION TExprNode : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	TExprNodes* FExprNodes;
	TExprNode* FNext;
	TExprNodeKind FKind;
	TTinyOperator FOperator;
	TTinyFunction FFunction;
	AnsiString FSymbol;
	char *FData;
	int FDataSize;
	TExprNode* FLeft;
	TExprNode* FRight;
	Db::TFieldType FDataType;
	Classes::TList* FArgs;
	bool FIsBlobField;
	int FFieldIdx;
	AnsiString FBlobData;
	int FPartialLength;
	__fastcall TExprNode(TExprNodes* ExprNodes);
	__fastcall virtual ~TExprNode(void);
	void __fastcall Calculate(TStrCompOptions Options);
	void __fastcall EvaluateOperator(TExprNode* ResultNode, TTinyOperator Operator, TExprNode* LeftNode, TExprNode* RightNode, Classes::TList* Args, TStrCompOptions Options);
	void __fastcall EvaluateFunction(TExprNode* ResultNode, TTinyFunction AFunction, Classes::TList* Args);
	bool __fastcall IsIntegerType(void);
	bool __fastcall IsLargeIntType(void);
	bool __fastcall IsFloatType(void);
	bool __fastcall IsTemporalType(void);
	bool __fastcall IsStringType(void);
	bool __fastcall IsBooleanType(void);
	bool __fastcall IsNumericType(void);
	bool __fastcall IsTemporalStringType(void);
	void __fastcall SetDataSize(int Size);
	TTDEDataSet* __fastcall GetDataSet(void);
	bool __fastcall AsBoolean(void);
	void __fastcall ConvertStringToDateTime(void);
	/*         class method */ static TTinyFunction __fastcall FuncNameToEnum(TMetaClass* vmt, const AnsiString FuncName);
	__property int DataSize = {read=FDataSize, write=SetDataSize, nodefault};
};


class PASCALIMPLEMENTATION TExprNodes : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	TExprParserBase* FExprParser;
	TExprNode* FNodes;
	TExprNode* FRoot;
	
public:
	__fastcall TExprNodes(TExprParserBase* AExprParser);
	__fastcall virtual ~TExprNodes(void);
	void __fastcall Clear(void);
	TExprNode* __fastcall NewNode(TExprNodeKind NodeKind, Db::TFieldType DataType, int ADataSize, TTinyOperator Operator, TExprNode* Left, TExprNode* Right);
	TExprNode* __fastcall NewFuncNode(const AnsiString FuncName);
	TExprNode* __fastcall NewFieldNode(const AnsiString FieldName);
	__property TExprNode* Root = {read=FRoot, write=FRoot};
};


class PASCALIMPLEMENTATION TExprParserBase : public TSyntaxParserBase 
{
	typedef TSyntaxParserBase inherited;
	
protected:
	TExprNodes* FExprNodes;
	TStrCompOptions FStrCompOpts;
	virtual TExprNode* __fastcall ParseExpr(void) = 0 ;
	virtual Db::TFieldType __fastcall GetFieldDataType(const AnsiString Name) = 0 ;
	virtual Variant __fastcall GetFieldValue(const AnsiString Name) = 0 ;
	virtual Db::TFieldType __fastcall GetFuncDataType(const AnsiString Name) = 0 ;
	virtual bool __fastcall TokenSymbolIsFunc(const AnsiString S);
	virtual void __fastcall ParseFinished(void);
	
public:
	__fastcall TExprParserBase(void);
	__fastcall virtual ~TExprParserBase(void);
	virtual void __fastcall Parse(const AnsiString AText);
	virtual Variant __fastcall Calculate(TStrCompOptions Options = System::Set<TStrCompOption, scCaseInsensitive, scNoPartialCompare> () );
};


class PASCALIMPLEMENTATION TTDEDataSet : public TTDBDataSet 
{
	typedef TTDBDataSet inherited;
	
private:
	TTinyAboutBox* FAboutBox;
	TTinyDBMediumType FMediumType;
	TExprParserBase* FFilterParser;
	int FCurRec;
	int FRecordSize;
	int FRecBufSize;
	DynamicArray<int >  FFieldOffsets;
	char *FKeyBuffers[4];
	char *FKeyBuffer;
	char *FFilterBuffer;
	bool FFilterMapsToIndex;
	bool FCanModify;
	void __fastcall SetMediumType(TTinyDBMediumType Value);
	void __fastcall SetPassword(const AnsiString Value);
	void __fastcall SetCRC32(bool Value);
	bool __fastcall GetCRC32(void);
	bool __fastcall GetCanAccess(void);
	void __fastcall InitRecordSize(void);
	void __fastcall InitFieldOffsets(void);
	bool __fastcall FiltersAccept(void);
	void __fastcall SetFilterData(const AnsiString Text, Db::TFilterOptions Options);
	void __fastcall AllocKeyBuffers(void);
	void __fastcall FreeKeyBuffers(void);
	void __fastcall InitKeyBuffer(TTDKeyIndex KeyIndex);
	
protected:
	virtual char * __fastcall AllocRecordBuffer(void);
	virtual void __fastcall FreeRecordBuffer(char * &Buffer);
	virtual void __fastcall GetBookmarkData(char * Buffer, void * Data);
	virtual Db::TBookmarkFlag __fastcall GetBookmarkFlag(char * Buffer);
	virtual Word __fastcall GetRecordSize(void);
	virtual void __fastcall InternalInitRecord(char * Buffer);
	virtual void __fastcall InternalFirst(void);
	virtual void __fastcall InternalLast(void);
	virtual void __fastcall InternalHandleException(void);
	virtual void __fastcall InternalSetToRecord(char * Buffer);
	virtual void __fastcall SetBookmarkFlag(char * Buffer, Db::TBookmarkFlag Value);
	virtual void __fastcall SetBookmarkData(char * Buffer, void * Data);
	virtual void __fastcall SetFieldData(Db::TField* Field, void * Buffer)/* overload */;
	virtual bool __fastcall IsCursorOpen(void);
	virtual void __fastcall DataConvert(Db::TField* Field, void * Source, void * Dest, bool ToNative);
	virtual int __fastcall GetRecordCount(void);
	virtual int __fastcall GetRecNo(void);
	virtual void __fastcall SetRecNo(int Value);
	virtual bool __fastcall GetCanModify(void);
	virtual void __fastcall SetFiltered(bool Value);
	virtual void __fastcall SetFilterOptions(Db::TFilterOptions Value);
	virtual void __fastcall SetFilterText(const AnsiString Value);
	virtual void __fastcall DoAfterOpen(void);
	virtual bool __fastcall FindRecord(bool Restart, bool GoForward);
	virtual bool __fastcall GetActiveRecBuf(char * &RecBuf);
	virtual void __fastcall ActivateFilters(void);
	virtual void __fastcall DeactivateFilters(void);
	virtual void __fastcall ReadRecordData(char * Buffer, int RecordIdx);
	int __fastcall GetFieldOffsetByFieldNo(int FieldNo);
	void __fastcall ReadFieldData(Classes::TMemoryStream* DstStream, int FieldDataOffset, int FieldSize, bool IsBlob, bool ShouldEncrypt, bool ShouldCompress);
	
public:
	virtual Classes::TStream* __fastcall CreateBlobStream(Db::TField* Field, Db::TBlobStreamMode Mode);
	virtual bool __fastcall GetFieldData(Db::TField* Field, void * Buffer)/* overload */;
	__fastcall virtual TTDEDataSet(Classes::TComponent* AOwner);
	__fastcall virtual ~TTDEDataSet(void);
	__property AnsiString Password = {write=SetPassword};
	__property bool CanAccess = {read=GetCanAccess, nodefault};
	__property bool CRC32 = {read=GetCRC32, write=SetCRC32, nodefault};
	
__published:
	__property TTinyAboutBox* About = {read=FAboutBox, write=FAboutBox};
	__property TTinyDBMediumType MediumType = {read=FMediumType, write=SetMediumType, default=0};
	__property Active  = {default=0};
	__property AutoCalcFields  = {default=1};
	__property Filter ;
	__property Filtered  = {default=0};
	__property FilterOptions  = {default=0};
	__property BeforeOpen ;
	__property AfterOpen ;
	__property BeforeClose ;
	__property AfterClose ;
	__property BeforeScroll ;
	__property AfterScroll ;
	__property BeforeRefresh ;
	__property AfterRefresh ;
	__property OnCalcFields ;
	__property OnFilterRecord ;
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetFieldData(Db::TField* Field, void * Buffer, bool NativeFormat){ TDataSet::SetFieldData(Field, Buffer, NativeFormat); }
	
public:
	inline bool __fastcall  GetFieldData(int FieldNo, void * Buffer){ return TDataSet::GetFieldData(FieldNo, Buffer); }
	inline bool __fastcall  GetFieldData(Db::TField* Field, void * Buffer, bool NativeFormat){ return TDataSet::GetFieldData(Field, Buffer, NativeFormat); }
	
};


class DELPHICLASS TFieldBuffers;
class PASCALIMPLEMENTATION TTinyTable : public TTDEDataSet 
{
	typedef TTDEDataSet inherited;
	
private:
	AnsiString FTableName;
	Db::TIndexDefs* FIndexDefs;
	AnsiString FIndexName;
	int FIndexIdx;
	Classes::TList* FRecTabList;
	int FUpdateCount;
	bool FSetRanged;
	int FEffFieldCount;
	bool FReadOnly;
	Db::TMasterDataLink* FMasterLink;
	TTinyTableIO* FTableIO;
	TOnProgressEvent FOnFilterProgress;
	void __fastcall SetTableName(const AnsiString Value);
	void __fastcall SetIndexName(const AnsiString Value);
	void __fastcall SetReadOnly(bool Value);
	void __fastcall SetMasterFields(const AnsiString Value);
	void __fastcall SetDataSource(Db::TDataSource* Value);
	int __fastcall GetTableIdx(void);
	AnsiString __fastcall GetMasterFields();
	void __fastcall InitIndexDefs(void);
	void __fastcall InitCurRecordTab(void);
	void __fastcall ClearMemRecTab(Classes::TList* AList);
	void __fastcall AddMemRecTabItem(Classes::TList* AList, const TMemRecTabItem &Value);
	void __fastcall InsertMemRecTabItem(Classes::TList* AList, int Index, const TMemRecTabItem &Value);
	void __fastcall DeleteMemRecTabItem(Classes::TList* AList, int Index);
	TMemRecTabItem __fastcall GetMemRecTabItem(Classes::TList* AList, int Index);
	void __fastcall SwitchToIndex(int IndexIdx);
	void __fastcall AppendRecordData(char * Buffer);
	void __fastcall ModifyRecordData(char * Buffer, int RecordIdx);
	void __fastcall DeleteRecordData(int RecordIdx);
	void __fastcall DeleteAllRecords(void);
	void __fastcall OnAdjustIndexForAppend(int IndexIdx, int InsertPos, const TMemRecTabItem &MemRecTabItem);
	void __fastcall OnAdjustIndexForModify(int IndexIdx, int FromRecIdx, int ToRecIdx);
	int __fastcall SearchIndexedField(Classes::TList* RecTabList, int IndexIdx, int &ResultState, int EffFieldCount = 0x0, bool PartialCompare = false);
	int __fastcall SearchIndexedFieldBound(Classes::TList* RecTabList, int IndexIdx, bool LowBound, int &ResultState, int EffFieldCount = 0x0, bool PartialCompare = false);
	int __fastcall SearchRangeStart(Classes::TList* RecTabList, int IndexIdx, int &ResultState, int EffFieldCount = 0x0);
	int __fastcall SearchRangeEnd(Classes::TList* RecTabList, int IndexIdx, int &ResultState, int EffFieldCount = 0x0);
	bool __fastcall SearchKey(Classes::TList* RecTabList, int IndexIdx, int EffFieldCount = 0x0, bool Nearest = false);
	int __fastcall SearchInsertPos(int IndexIdx, int &ResultState);
	void __fastcall SetKeyFields(TTDKeyIndex KeyIndex, const System::TVarRec * Values, const int Values_Size)/* overload */;
	void __fastcall SetKeyFields(int IndexIdx, TTDKeyIndex KeyIndex, const System::TVarRec * Values, const int Values_Size)/* overload */;
	void __fastcall SetKeyBuffer(TTDKeyIndex KeyIndex, bool Clear);
	bool __fastcall LocateRecord(const AnsiString KeyFields, const Variant &KeyValues, Db::TLocateOptions Options, bool SyncCursor);
	int __fastcall MapsToIndexForSearch(Classes::TList* Fields, bool CaseInsensitive);
	bool __fastcall CheckFilterMapsToIndex(void);
	void __fastcall MasterChanged(System::TObject* Sender);
	void __fastcall MasterDisabled(System::TObject* Sender);
	void __fastcall SetLinkRange(Classes::TList* MasterFields);
	void __fastcall CheckMasterRange(void);
	void __fastcall RecordBufferToFieldBuffers(char * RecordBuffer, TFieldBuffers* FieldBuffers);
	bool __fastcall FieldDefsStored(void);
	bool __fastcall IndexDefsStored(void);
	
protected:
	virtual Db::TGetResult __fastcall GetRecord(char * Buffer, Db::TGetMode GetMode, bool DoCheck);
	virtual void __fastcall InternalOpen(void);
	virtual void __fastcall InternalClose(void);
	virtual void __fastcall InternalInitFieldDefs(void);
	virtual void __fastcall InternalDelete(void);
	virtual void __fastcall InternalPost(void);
	virtual void __fastcall InternalRefresh(void);
	virtual void __fastcall InternalGotoBookmark(void * Bookmark);
	virtual void __fastcall InternalAddRecord(void * Buffer, bool Append);
	virtual bool __fastcall IsCursorOpen(void);
	virtual int __fastcall GetRecordCount(void);
	virtual bool __fastcall GetCanModify(void);
	virtual Db::TDataSource* __fastcall GetDataSource(void);
	virtual void __fastcall SetDatabaseName(const AnsiString Value);
	virtual void __fastcall DoAfterOpen(void);
	virtual void __fastcall ActivateFilters(void);
	virtual void __fastcall DeactivateFilters(void);
	virtual void __fastcall ReadRecordData(char * Buffer, int RecordIdx);
	
public:
	__fastcall virtual TTinyTable(Classes::TComponent* AOwner);
	__fastcall virtual ~TTinyTable(void);
	void __fastcall BeginUpdate(void);
	void __fastcall EndUpdate(void);
	virtual void __fastcall Post(void);
	virtual bool __fastcall BookmarkValid(void * Bookmark);
	void __fastcall SetKey(void);
	void __fastcall EditKey(void);
	bool __fastcall GotoKey(void)/* overload */;
	bool __fastcall GotoKey(const AnsiString IndexName)/* overload */;
	void __fastcall GotoNearest(void)/* overload */;
	void __fastcall GotoNearest(const AnsiString IndexName)/* overload */;
	bool __fastcall FindKey(const System::TVarRec * KeyValues, const int KeyValues_Size)/* overload */;
	bool __fastcall FindKey(const AnsiString IndexName, const System::TVarRec * KeyValues, const int KeyValues_Size)/* overload */;
	void __fastcall FindNearest(const System::TVarRec * KeyValues, const int KeyValues_Size)/* overload */;
	void __fastcall FindNearest(const AnsiString IndexName, const System::TVarRec * KeyValues, const int KeyValues_Size)/* overload */;
	void __fastcall SetRangeStart(void);
	void __fastcall SetRangeEnd(void);
	void __fastcall EditRangeStart(void);
	void __fastcall EditRangeEnd(void);
	void __fastcall ApplyRange(void)/* overload */;
	void __fastcall ApplyRange(const AnsiString IndexName)/* overload */;
	void __fastcall SetRange(const System::TVarRec * StartValues, const int StartValues_Size, const System::TVarRec * EndValues, const int EndValues_Size)/* overload */;
	void __fastcall SetRange(const AnsiString IndexName, const System::TVarRec * StartValues, const int StartValues_Size, const System::TVarRec * EndValues, const int EndValues_Size)/* overload */;
	void __fastcall CancelRange(void);
	virtual bool __fastcall Locate(const AnsiString KeyFields, const Variant &KeyValues, Db::TLocateOptions Options);
	virtual Variant __fastcall Lookup(const AnsiString KeyFields, const Variant &KeyValues, const AnsiString ResultFields);
	void __fastcall EmptyTable(void);
	void __fastcall CreateTable(void);
	__property TTinyTableIO* TableIO = {read=FTableIO};
	__property int TableIdx = {read=GetTableIdx, nodefault};
	__property int IndexIdx = {read=FIndexIdx, nodefault};
	
__published:
	__property AnsiString TableName = {read=FTableName, write=SetTableName};
	__property AnsiString IndexName = {read=FIndexName, write=SetIndexName};
	__property bool ReadOnly = {read=FReadOnly, write=SetReadOnly, default=0};
	__property AnsiString MasterFields = {read=GetMasterFields, write=SetMasterFields};
	__property Db::TDataSource* MasterSource = {read=GetDataSource, write=SetDataSource};
	__property Db::TIndexDefs* IndexDefs = {read=FIndexDefs, write=FIndexDefs, stored=IndexDefsStored};
	__property FieldDefs  = {stored=FieldDefsStored};
	__property TOnProgressEvent OnFilterProgress = {read=FOnFilterProgress, write=FOnFilterProgress};
	__property BeforeInsert ;
	__property AfterInsert ;
	__property BeforeEdit ;
	__property AfterEdit ;
	__property BeforePost ;
	__property AfterPost ;
	__property BeforeCancel ;
	__property AfterCancel ;
	__property BeforeDelete ;
	__property AfterDelete ;
	__property OnDeleteError ;
	__property OnEditError ;
	__property OnNewRecord ;
	__property OnPostError ;
};


class PASCALIMPLEMENTATION TTinyBlobStream : public Classes::TMemoryStream 
{
	typedef Classes::TMemoryStream inherited;
	
private:
	Db::TBlobField* FField;
	TTinyTable* FDataSet;
	Db::TBlobStreamMode FMode;
	int FFieldNo;
	bool FOpened;
	bool FModified;
	void __fastcall LoadBlobData(void);
	void __fastcall SaveBlobData(void);
	
public:
	__fastcall TTinyBlobStream(Db::TBlobField* Field, Db::TBlobStreamMode Mode);
	__fastcall virtual ~TTinyBlobStream(void);
	virtual int __fastcall Write(const void *Buffer, int Count);
	void __fastcall Truncate(void);
};


class DELPHICLASS TOptimBlobStream;
class PASCALIMPLEMENTATION TOptimBlobStream : public Classes::TMemoryStream 
{
	typedef Classes::TMemoryStream inherited;
	
private:
	TTDEDataSet* FDataSet;
	int FFldDataOffset;
	bool FShouldEncrypt;
	bool FShouldCompress;
	bool FDataLoaded;
	void __fastcall LoadBlobData(void);
	
protected:
	virtual void * __fastcall Realloc(int &NewCapacity);
	
public:
	__fastcall TOptimBlobStream(TTDEDataSet* ADataSet);
	__fastcall virtual ~TOptimBlobStream(void);
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual void __fastcall SetSize(int NewSize)/* overload */;
	virtual int __fastcall Seek(int Offset, Word Origin)/* overload */;
	void __fastcall Init(int FldDataOffset, bool ShouldEncrypt, bool ShouldCompress);
	__property bool DataLoaded = {read=FDataLoaded, nodefault};
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(const __int64 NewSize){ TStream::SetSize(NewSize); }
	
public:
	inline __int64 __fastcall  Seek(const __int64 Offset, Classes::TSeekOrigin Origin){ return TStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS TCachedFileStream;
class PASCALIMPLEMENTATION TCachedFileStream : public Classes::TStream 
{
	typedef Classes::TStream inherited;
	
private:
	Classes::TMemoryStream* FCacheStream;
	
public:
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual int __fastcall Seek(int Offset, Word Origin)/* overload */;
	__fastcall TCachedFileStream(const AnsiString FileName, Word Mode);
	__fastcall virtual ~TCachedFileStream(void);
	
/* Hoisted overloads: */
	
public:
	inline __int64 __fastcall  Seek(const __int64 Offset, Classes::TSeekOrigin Origin){ return TStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS TFilterParser;
class PASCALIMPLEMENTATION TFilterParser : public TExprParserBase 
{
	typedef TExprParserBase inherited;
	
protected:
	TTDEDataSet* FDataSet;
	bool __fastcall NextTokenIsLParen(void);
	void __fastcall TypeCheckArithOp(TExprNode* Node);
	void __fastcall TypeCheckLogicOp(TExprNode* Node);
	void __fastcall TypeCheckInOp(TExprNode* Node);
	void __fastcall TypeCheckRelationOp(TExprNode* Node);
	void __fastcall TypeCheckLikeOp(TExprNode* Node);
	void __fastcall TypeCheckFunction(TExprNode* Node);
	TExprNode* __fastcall ParseExpr2(void);
	TExprNode* __fastcall ParseExpr3(void);
	TExprNode* __fastcall ParseExpr4(void);
	TExprNode* __fastcall ParseExpr5(void);
	TExprNode* __fastcall ParseExpr6(void);
	TExprNode* __fastcall ParseExpr7(void);
	virtual char * __fastcall InternalGetNextToken(char * Pos);
	virtual TExprNode* __fastcall ParseExpr(void);
	virtual Db::TFieldType __fastcall GetFieldDataType(const AnsiString Name);
	virtual Variant __fastcall GetFieldValue(const AnsiString Name);
	virtual Db::TFieldType __fastcall GetFuncDataType(const AnsiString Name);
	virtual bool __fastcall TokenSymbolIsFunc(const AnsiString S);
	
public:
	__fastcall TFilterParser(TTDEDataSet* ADataSet);
public:
	#pragma option push -w-inl
	/* TExprParserBase.Destroy */ inline __fastcall virtual ~TFilterParser(void) { }
	#pragma option pop
	
};


class DELPHICLASS TSQLWhereExprParser;
class PASCALIMPLEMENTATION TSQLWhereExprParser : public TFilterParser 
{
	typedef TFilterParser inherited;
	
protected:
	virtual Variant __fastcall GetFieldValue(const AnsiString Name);
	
public:
	__fastcall TSQLWhereExprParser(TTDEDataSet* ADataSet);
public:
	#pragma option push -w-inl
	/* TExprParserBase.Destroy */ inline __fastcall virtual ~TSQLWhereExprParser(void) { }
	#pragma option pop
	
};


class DELPHICLASS TSQLParserBase;
class DELPHICLASS TTinyQuery;
class DELPHICLASS TSQLParser;
class PASCALIMPLEMENTATION TSQLParserBase : public TSyntaxParserBase 
{
	typedef TSyntaxParserBase inherited;
	
protected:
	TTinyQuery* FQuery;
	int FRowsAffected;
	virtual char * __fastcall SkipBeforeGetToken(char * Pos);
	virtual char * __fastcall InternalGetNextToken(char * Pos);
	
public:
	__fastcall TSQLParserBase(TTinyQuery* AQuery);
	__fastcall virtual ~TSQLParserBase(void);
	virtual void __fastcall Parse(const AnsiString ASQL);
	virtual void __fastcall Execute(void) = 0 ;
	__property int RowsAffected = {read=FRowsAffected, nodefault};
};


#pragma option push -b-
enum TSQLType { stNONE, stSELECT, stINSERT, stDELETE, stUPDATE };
#pragma option pop

class PASCALIMPLEMENTATION TSQLParser : public TSQLParserBase 
{
	typedef TSQLParserBase inherited;
	
private:
	TSQLType FSQLType;
	
public:
	__fastcall TSQLParser(TTinyQuery* AQuery);
	__fastcall virtual ~TSQLParser(void);
	virtual void __fastcall Parse(const AnsiString ASQL);
	virtual void __fastcall Execute(void);
};


class PASCALIMPLEMENTATION TTinyQuery : public TTDEDataSet 
{
	typedef TTDEDataSet inherited;
	
private:
	Classes::TStrings* FSQL;
	TSQLParser* FSQLParser;
	void __fastcall SetQuery(Classes::TStrings* Value);
	int __fastcall GetRowsAffected(void);
	
protected:
	virtual void __fastcall InternalOpen(void);
	virtual void __fastcall InternalClose(void);
	
public:
	__fastcall virtual TTinyQuery(Classes::TComponent* AOwner);
	__fastcall virtual ~TTinyQuery(void);
	void __fastcall ExecSQL(void);
	__property int RowsAffected = {read=GetRowsAffected, nodefault};
	
__published:
	__property Classes::TStrings* SQL = {read=FSQL, write=SetQuery};
};



#pragma pack(push, 4)
struct TNameItem
{
	AnsiString RealName;
	AnsiString AliasName;
} ;
#pragma pack(pop)

typedef TNameItem  TTableNameItem;

#pragma pack(push, 4)
struct TSelectFieldItem
{
	AnsiString TableName;
	AnsiString RealFldName;
	AnsiString AliasFldName;
	int Index;
} ;
#pragma pack(pop)

#pragma option push -b-
enum TOrderByType { obAsc, obDesc };
#pragma option pop

#pragma pack(push, 4)
struct TOrderByFieldItem
{
	AnsiString FldName;
	int Index;
	TOrderByType OrderByType;
} ;
#pragma pack(pop)

typedef DynamicArray<TNameItem >  TinyDB__02;

typedef DynamicArray<TSelectFieldItem >  TinyDB__12;

typedef DynamicArray<TOrderByFieldItem >  TinyDB__22;

class DELPHICLASS TSQLSelectParser;
class PASCALIMPLEMENTATION TSQLSelectParser : public TSQLParserBase 
{
	typedef TSQLParserBase inherited;
	
private:
	int FTopNum;
	DynamicArray<TNameItem >  FFromItems;
	DynamicArray<TSelectFieldItem >  FSelectItems;
	TSQLWhereExprParser* FWhereExprParser;
	DynamicArray<TOrderByFieldItem >  FOrderByItems;
	char * __fastcall ParseFrom(void);
	char * __fastcall ParseSelect(void);
	
public:
	__fastcall TSQLSelectParser(TTinyQuery* AQuery);
	__fastcall virtual ~TSQLSelectParser(void);
	virtual void __fastcall Parse(const AnsiString ASQL);
	virtual void __fastcall Execute(void);
};


class DELPHICLASS TRecordsMap;
class PASCALIMPLEMENTATION TRecordsMap : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	Classes::TList* FList;
	int FByIndexIdx;
	int __fastcall GetCount(void);
	int __fastcall GetItem(int Index);
	void __fastcall SetItem(int Index, int Value);
	
public:
	__fastcall TRecordsMap(void);
	__fastcall virtual ~TRecordsMap(void);
	void __fastcall Add(int Value);
	void __fastcall Delete(int Index);
	void __fastcall Clear(void);
	void __fastcall DoAnd(TRecordsMap* Right, TRecordsMap* Result);
	void __fastcall DoOr(TRecordsMap* Right, TRecordsMap* Result);
	void __fastcall DoNot(TRecordsMap* Right, TRecordsMap* Result);
	__property int ByIndexIdx = {read=FByIndexIdx, write=FByIndexIdx, nodefault};
	__property int Count = {read=GetCount, nodefault};
	__property int Items[int Index] = {read=GetItem, write=SetItem};
};


typedef TMetaClass*TDataProcessAlgoClass;

typedef TMetaClass*TCompressAlgoClass;

class DELPHICLASS TCompressAlgo;
class PASCALIMPLEMENTATION TCompressAlgo : public TDataProcessAlgo 
{
	typedef TDataProcessAlgo inherited;
	
protected:
	virtual void __fastcall SetLevel(TCompressLevel Value);
	virtual TCompressLevel __fastcall GetLevel(void);
	
public:
	__property TCompressLevel Level = {read=GetLevel, write=SetLevel, nodefault};
public:
	#pragma option push -w-inl
	/* TDataProcessAlgo.Create */ inline __fastcall virtual TCompressAlgo(System::TObject* AOwner) : TDataProcessAlgo(AOwner) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TDataProcessAlgo.Destroy */ inline __fastcall virtual ~TCompressAlgo(void) { }
	#pragma option pop
	
};


typedef TMetaClass*TEncryptAlgoClass;

class DELPHICLASS TEncryptAlgo;
class PASCALIMPLEMENTATION TEncryptAlgo : public TDataProcessAlgo 
{
	typedef TDataProcessAlgo inherited;
	
protected:
	void __fastcall DoProgress(int Current, int Maximal, bool Encode);
	void __fastcall InternalCodeStream(Classes::TMemoryStream* Source, Classes::TMemoryStream* Dest, int DataSize, bool Encode);
	virtual void __fastcall SetMode(TEncryptMode Value);
	virtual TEncryptMode __fastcall GetMode(void);
	
public:
	virtual void __fastcall InitKey(const AnsiString Key) = 0 ;
	virtual void __fastcall Done(void);
	virtual void __fastcall EncodeStream(Classes::TMemoryStream* Source, Classes::TMemoryStream* Dest, int DataSize);
	virtual void __fastcall DecodeStream(Classes::TMemoryStream* Source, Classes::TMemoryStream* Dest, int DataSize);
	virtual void __fastcall EncodeBuffer(const void *Source, void *Dest, int DataSize) = 0 ;
	virtual void __fastcall DecodeBuffer(const void *Source, void *Dest, int DataSize) = 0 ;
	__property TEncryptMode Mode = {read=GetMode, write=SetMode, nodefault};
public:
	#pragma option push -w-inl
	/* TDataProcessAlgo.Create */ inline __fastcall virtual TEncryptAlgo(System::TObject* AOwner) : TDataProcessAlgo(AOwner) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TDataProcessAlgo.Destroy */ inline __fastcall virtual ~TEncryptAlgo(void) { }
	#pragma option pop
	
};


class DELPHICLASS TFieldBufferItem;
class PASCALIMPLEMENTATION TFieldBufferItem : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	void *FBuffer;
	Db::TFieldType FFieldType;
	int FFieldSize;
	bool FMemAlloc;
	bool FActive;
	AnsiString __fastcall GetAsString();
	void * __fastcall GetDataBuf(void);
	
public:
	__fastcall TFieldBufferItem(void);
	__fastcall virtual ~TFieldBufferItem(void);
	void __fastcall AllocBuffer(void);
	void __fastcall FreeBuffer(void);
	bool __fastcall IsBlob(void);
	__property Db::TFieldType FieldType = {read=FFieldType, write=FFieldType, nodefault};
	__property int FieldSize = {read=FFieldSize, write=FFieldSize, nodefault};
	__property void * Buffer = {read=FBuffer};
	__property void * DataBuf = {read=GetDataBuf};
	__property bool Active = {read=FActive, write=FActive, nodefault};
	__property AnsiString AsString = {read=GetAsString};
};


class PASCALIMPLEMENTATION TFieldBuffers : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	Classes::TList* FItems;
	int __fastcall GetCount(void);
	TFieldBufferItem* __fastcall GetItem(int Index);
	
public:
	__fastcall TFieldBuffers(void);
	__fastcall virtual ~TFieldBuffers(void);
	void __fastcall Add(Db::TFieldType FieldType, int FieldSize)/* overload */;
	void __fastcall Add(void * Buffer, Db::TFieldType FieldType, int FieldSize)/* overload */;
	void __fastcall Delete(int Index);
	void __fastcall Clear(void);
	__property int Count = {read=GetCount, nodefault};
	__property TFieldBufferItem* Items[int Index] = {read=GetItem};
};


class DELPHICLASS TTinyDBFileStream;
class PASCALIMPLEMENTATION TTinyDBFileStream : public Classes::TFileStream 
{
	typedef Classes::TFileStream inherited;
	
private:
	bool FFlushed;
	
public:
	__fastcall TTinyDBFileStream(const AnsiString FileName, Word Mode)/* overload */;
	__fastcall TTinyDBFileStream(const AnsiString FileName, Word Mode, unsigned Rights)/* overload */;
	virtual int __fastcall Write(const void *Buffer, int Count);
	void __fastcall Flush(void);
	__property bool Flushed = {read=FFlushed, write=FFlushed, nodefault};
public:
	#pragma option push -w-inl
	/* TFileStream.Destroy */ inline __fastcall virtual ~TTinyDBFileStream(void) { }
	#pragma option pop
	
};


typedef void __fastcall (__closure *TOnAdjustIndexForAppendEvent)(int IndexIdx, int InsertPos, const TMemRecTabItem &MemRecTabItem);

typedef void __fastcall (__closure *TOnAdjustIndexForModifyEvent)(int IndexIdx, int FromRecIdx, int ToRecIdx);

typedef DynamicArray<DynamicArray<int > >  TinyDB__63;

typedef DynamicArray<Classes::TList* >  TinyDB__73;

class PASCALIMPLEMENTATION TTinyTableIO : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	TTinyDatabase* FDatabase;
	int FRefCount;
	AnsiString FTableName;
	int FTableIdx;
	TTinyFieldDefs* FFieldDefs;
	TTinyIndexDefs* FIndexDefs;
	int FDiskRecSize;
	DynamicArray<int >  FDiskFieldOffsets;
	int FAutoIncFieldIdx;
	#pragma pack(push, 1)
	TTableHeader FTableHeader;
	#pragma pack(pop)
	
	DynamicArray<TRecordTabItem >  FInitRecordTab;
	DynamicArray<int >  FRecTabBlockOffsets;
	DynamicArray<DynamicArray<int > >  FIdxTabBlockOffsets;
	DynamicArray<Classes::TList* >  FRecTabLists;
	void __fastcall SetActive(bool Value);
	void __fastcall SetTableName(const AnsiString Value);
	bool __fastcall GetActive(void);
	Classes::TList* __fastcall GetRecTabList(int Index);
	int __fastcall GetTableIdxByName(const AnsiString TableName);
	void __fastcall InitFieldDefs(void);
	void __fastcall InitIndexDefs(void);
	void __fastcall InitRecTabList(int ListIdx, bool ReadRecTabItems = true);
	void __fastcall InitAllRecTabLists(void);
	void __fastcall InitDiskRecInfo(void);
	void __fastcall InitAutoInc(void);
	void __fastcall ClearMemRecTab(Classes::TList* AList);
	void __fastcall AddMemRecTabItem(Classes::TList* AList, const TMemRecTabItem &Value);
	void __fastcall InsertMemRecTabItem(Classes::TList* AList, int Index, const TMemRecTabItem &Value);
	void __fastcall DeleteMemRecTabItem(Classes::TList* AList, int Index);
	TMemRecTabItem __fastcall GetMemRecTabItem(Classes::TList* AList, int Index);
	bool __fastcall ShouldEncrypt(int FieldIdx);
	bool __fastcall ShouldCompress(int FieldIdx);
	int __fastcall GetRecTabItemOffset(int ItemIdx);
	int __fastcall GetIdxTabItemOffset(int IndexIdx, int ItemIdx);
	void __fastcall AdjustIndexesForAppend(TFieldBuffers* FieldBuffers, int RecDataOffset, int RecTotal, TOnAdjustIndexForAppendEvent OnAdjustIndex);
	void __fastcall AdjustIndexesForModify(TFieldBuffers* FieldBuffers, int EditPhyRecordIdx, TOnAdjustIndexForModifyEvent OnAdjustIndex);
	void __fastcall AdjustIndexesForDelete(int DeletePhyRecordIdx);
	void __fastcall WriteDeleteFlag(int PhyRecordIdx);
	void __fastcall AdjustStrFldInBuffer(TFieldBuffers* FieldBuffers);
	void __fastcall ClearAllRecTabLists(void);
	
protected:
	void __fastcall Initialize(void);
	void __fastcall Finalize(void);
	
public:
	__fastcall TTinyTableIO(TTinyDatabase* AOwner);
	__fastcall virtual ~TTinyTableIO(void);
	void __fastcall Open(void);
	void __fastcall Close(void);
	void __fastcall Refresh(void);
	void __fastcall AppendRecordData(TFieldBuffers* FieldBuffers, bool Flush, TOnAdjustIndexForAppendEvent OnAdjustIndex);
	void __fastcall ModifyRecordData(TFieldBuffers* FieldBuffers, int PhyRecordIdx, bool Flush, TOnAdjustIndexForModifyEvent OnAdjustIndex);
	void __fastcall DeleteRecordData(int PhyRecordIdx, bool Flush);
	void __fastcall DeleteAllRecords(void);
	void __fastcall ReadFieldData(Classes::TMemoryStream* DstStream, int DiskRecIndex, int FieldIdx);
	void __fastcall ReadRecordData(TFieldBuffers* FieldBuffers, Classes::TList* RecTabList, int RecordIdx);
	int __fastcall CompFieldData(void * FieldBuffer1, void * FieldBuffer2, Db::TFieldType FieldType, bool CaseInsensitive, bool PartialCompare);
	int __fastcall SearchIndexedField(TFieldBuffers* FieldBuffers, Classes::TList* RecTabList, int IndexIdx, int &ResultState, int EffFieldCount = 0x0, bool PartialCompare = false);
	int __fastcall SearchIndexedFieldBound(TFieldBuffers* FieldBuffers, Classes::TList* RecTabList, int IndexIdx, bool LowBound, int &ResultState, int EffFieldCount = 0x0, bool PartialCompare = false);
	int __fastcall SearchRangeStart(TFieldBuffers* FieldBuffers, Classes::TList* RecTabList, int IndexIdx, int &ResultState, int EffFieldCount = 0x0);
	int __fastcall SearchRangeEnd(TFieldBuffers* FieldBuffers, Classes::TList* RecTabList, int IndexIdx, int &ResultState, int EffFieldCount = 0x0);
	int __fastcall SearchInsertPos(TFieldBuffers* FieldBuffers, int IndexIdx, int &ResultState);
	int __fastcall CheckPrimaryFieldExists(void);
	bool __fastcall CheckUniqueFieldForAppend(TFieldBuffers* FieldBuffers);
	bool __fastcall CheckUniqueFieldForModify(TFieldBuffers* FieldBuffers, int PhyRecordIdx);
	void __fastcall ConvertRecordIdx(int SrcIndexIdx, int SrcRecordIdx, int DstIndexIdx, int &DstRecordIdx)/* overload */;
	void __fastcall ConvertRecordIdx(Classes::TList* SrcRecTabList, int SrcRecordIdx, Classes::TList* DstRecTabList, int &DstRecordIdx)/* overload */;
	void __fastcall ConvertRecIdxForPhy(int SrcIndexIdx, int SrcRecordIdx, int &DstRecordIdx)/* overload */;
	void __fastcall ConvertRecIdxForPhy(Classes::TList* SrcRecTabList, int SrcRecordIdx, int &DstRecordIdx)/* overload */;
	void __fastcall ConvertRecIdxForCur(int SrcIndexIdx, int SrcRecordIdx, Classes::TList* RecTabList, int &DstRecordIdx);
	__property bool Active = {read=GetActive, write=SetActive, nodefault};
	__property AnsiString TableName = {read=FTableName, write=SetTableName};
	__property int TableIdx = {read=FTableIdx, nodefault};
	__property TTinyFieldDefs* FieldDefs = {read=FFieldDefs};
	__property TTinyIndexDefs* IndexDefs = {read=FIndexDefs};
	__property Classes::TList* RecTabLists[int Index] = {read=GetRecTabList};
};


class DELPHICLASS TTinySessionList;
class PASCALIMPLEMENTATION TTinySessionList : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	TTinySession* operator[](int Index) { return Sessions[Index]; }
	
public:
	Classes::TThreadList* FSessions;
	Classes::TBits* FSessionNumbers;
	void __fastcall AddSession(TTinySession* ASession);
	void __fastcall CloseAll(void);
	int __fastcall GetCount(void);
	TTinySession* __fastcall GetSession(int Index);
	TTinySession* __fastcall GetSessionByName(const AnsiString SessionName);
	__fastcall TTinySessionList(void);
	__fastcall virtual ~TTinySessionList(void);
	TTinySession* __fastcall FindSession(const AnsiString SessionName);
	void __fastcall GetSessionNames(Classes::TStrings* List);
	TTinySession* __fastcall OpenSession(const AnsiString SessionName);
	__property int Count = {read=GetCount, nodefault};
	__property TTinySession* Sessions[int Index] = {read=GetSession/*, default*/};
	__property TTinySession* List[AnsiString SessionName] = {read=GetSessionByName};
};


//-- var, const, procedure ---------------------------------------------------
#define tdbWebsite "http://www.tinydb.com"
#define tdbSupportEmail "haoxg@21cn.com"
#define tdbSoftName "TinyDB"
#define tdbSoftVer "2.94"
#define tdbFileFmtVer "2.0"
#define tdbDBFileExt ".tdb"
static const Word tdbMaxTable = 0x100;
static const Shortint tdbMaxField = 0x60;
static const Shortint tdbMaxIndex = 0x8;
static const Shortint tdbMaxFieldNameChar = 0x20;
static const Shortint tdbMaxTableNameChar = 0x20;
static const Shortint tdbMaxIndexNameChar = 0x20;
static const Shortint tdbMaxAlgoNameChar = 0x20;
static const Word tdbMaxCommentsChar = 0x100;
static const Word tdbMaxExtDataSize = 0x800;
static const Byte tdbMaxHashPwdSize = 0x80;
static const Word tdbRndBufferSize = 0x100;
static const Word tdbRecTabUnitNum = 0x400;
static const Word tdbIdxTabUnitNum = 0x400;
static const Word tdbMaxTextFieldSize = 0x2000;
static const Shortint tdbBlobSizeUnitNum = 0x40;
static const Shortint tdbMaxMultiIndexFields = 0x8;
static const Shortint tdbDefaultLockRetryCount = 0x14;
static const Shortint tdbDefaultLockWaitTime = 0x64;
static const Word tdbDefAutoFlushInterval = 0xea60;
#define SGeneralError "General error"
#define SAccessDenied "Access denied"
#define STableNotFound "Table '%s' not found"
#define SBookmarkNotFound "Bookmark not found"
#define SFieldCountMismatch "Field count mismatch"
#define STooManyTables "Too many tables"
#define STooManyFields "Too many fields"
#define STooManyIndexes "Too many indexes"
#define SDuplicateTableName "Duplicate table name '%s'"
#define SDuplicateIndexName "Duplicate index name '%s'"
#define SDuplicatePrimaryIndex "Duplicate primary index"
#define SDuplicateAutoIncField "Duplicate AutoInc field"
#define SInvalidDatabaseName "Invalid database name '%s'"
#define SInvalidTableName "Invalid table name '%s'"
#define SInvalidFieldName "Invalid field name '%s'"
#define SInvalidIndexName "Invalid index name '%s'"
#define SInvalidDatabase "Database file '%s' is a invalid TinyDB"
#define SInvalidVersion100 "Version 1.00 is not compatible"
#define SInvalidVersionTooHigh "Version of database file is too High"
#define SFieldNameExpected "Field name expected"
#define SFailToCreateIndex "Fail to create index"
#define SInvalidUniqueFieldValue "Invalid unique field value '%s'"
#define SInvalidMultiIndex "Invalid complex index"
#define SSQLInvalid "Invalid SQL statement: '%s'"
#define SSQLInvalidChar "Invalid SQL character: '%s'"
#define SCompressAlgNotFound "Compression algorithm module '%s' not found"
#define SEncryptAlgNotFound "Encryption algorithm module '%s' not found"
#define SDatabaseReadOnly "Cannot modify a read-only database"
#define SNoRecords "No records"
#define SWaitForUnlockTimeOut "Wait for unlock time out"
extern PACKAGE TTinySession* Session;
extern PACKAGE TTinySessionList* Sessions;
extern PACKAGE void __fastcall RegisterCompressClass(TMetaClass* AClass, AnsiString AlgoName);
extern PACKAGE void __fastcall RegisterEncryptClass(TMetaClass* AClass, AnsiString AlgoName);
extern PACKAGE TFieldItem __fastcall FieldItem(AnsiString FieldName, Db::TFieldType FieldType, int DataSize = 0x0, TFieldDataProcessMode DPMode = (TFieldDataProcessMode)(0x0));
extern PACKAGE AnsiString __fastcall PointerToStr(void * P);
extern PACKAGE AnsiString __fastcall HashMD5(const AnsiString Source, void * Digest = (void *)(0x0));
extern PACKAGE AnsiString __fastcall HashSHA(const AnsiString Source, void * Digest = (void *)(0x0));
extern PACKAGE AnsiString __fastcall HashSHA1(const AnsiString Source, void * Digest = (void *)(0x0));
extern PACKAGE unsigned __fastcall CheckSumCRC32(const void *Data, int DataSize);
extern PACKAGE void __fastcall EncryptBuffer(char * Buffer, int DataSize, AnsiString EncAlgo, TEncryptMode EncMode, AnsiString Password);
extern PACKAGE void __fastcall DecryptBuffer(char * Buffer, int DataSize, AnsiString EncAlgo, TEncryptMode EncMode, AnsiString Password);
extern PACKAGE void __fastcall EncryptBufferBlowfish(char * Buffer, int DataSize, AnsiString Password);
extern PACKAGE void __fastcall DecryptBufferBlowfish(char * Buffer, int DataSize, AnsiString Password);

}	/* namespace Tinydb */
using namespace Tinydb;
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// TinyDB
