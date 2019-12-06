// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'EncryptBase.pas' rev: 5.00

#ifndef EncryptBaseHPP
#define EncryptBaseHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <Hash_SHA.hpp>	// Pascal unit
#include <HashBase.hpp>	// Pascal unit
#include <TinyDB.hpp>	// Pascal unit
#include <SysUtils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Encryptbase
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EEncryptException;
class PASCALIMPLEMENTATION EEncryptException : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	int ErrorCode;
public:
	#pragma option push -w-inl
	/* Exception.Create */ inline __fastcall EEncryptException(const AnsiString Msg) : Sysutils::Exception(
		Msg) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmt */ inline __fastcall EEncryptException(const AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateRes */ inline __fastcall EEncryptException(int Ident)/* overload */ : Sysutils::Exception(
		Ident) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmt */ inline __fastcall EEncryptException(int Ident, const System::TVarRec * 
		Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateHelp */ inline __fastcall EEncryptException(const AnsiString Msg, int AHelpContext
		) : Sysutils::Exception(Msg, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmtHelp */ inline __fastcall EEncryptException(const AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext
		) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResHelp */ inline __fastcall EEncryptException(int Ident, int AHelpContext)/* overload */
		 : Sysutils::Exception(Ident, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmtHelp */ inline __fastcall EEncryptException(System::PResStringRec ResStringRec
		, const System::TVarRec * Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(
		ResStringRec, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~EEncryptException(void) { }
	#pragma option pop
	
};


typedef TMetaClass*TEncryptClass;

struct TEncryptRec;
typedef TEncryptRec *PEncryptRec;

#pragma pack(push, 1)
struct TEncryptRec
{
	
	union
	{
		struct 
		{
			unsigned A;
			unsigned B;
			
		};
		struct 
		{
			Byte X[8];
			
		};
		
	};
} ;
#pragma pack(pop)

typedef void __fastcall (__closure *TEncProgressEvent)(int Percent);

class DELPHICLASS TEncrypt;
class PASCALIMPLEMENTATION TEncrypt : public Classes::TPersistent 
{
	typedef Classes::TPersistent inherited;
	
private:
	Tinydb::TEncryptMode FMode;
	Hashbase::THash* FHash;
	TMetaClass*FHashClass;
	int FKeySize;
	int FBufSize;
	int FUserSize;
	void *FBuffer;
	void *FVector;
	void *FFeedback;
	void *FUser;
	int FFlags;
	Hashbase::THash* __fastcall GetHash(void);
	void __fastcall SetHashClass(TMetaClass* Value);
	void __fastcall InternalCodeStream(Classes::TStream* Source, Classes::TStream* Dest, int DataSize, 
		bool Encode);
	void __fastcall InternalCodeFile(const AnsiString Source, const AnsiString Dest, bool Encode);
	
protected:
	bool __fastcall GetFlag(int Index);
	virtual void __fastcall SetFlag(int Index, bool Value);
	void __fastcall InitBegin(int &Size);
	void __fastcall InitEnd(void * IVector);
	#pragma option push -w-inl
	/* virtual class method */ virtual void __fastcall GetContext(int &ABufSize, int &AKeySize, int &AUserSize
		) { GetContext(__classid(TEncrypt), ABufSize, AKeySize, AUserSize); }
	#pragma option pop
	/*         class method */ static void __fastcall GetContext(TMetaClass* vmt, int &ABufSize, int &AKeySize
		, int &AUserSize);
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(TEncrypt)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	virtual void __fastcall Encode(void * Data);
	virtual void __fastcall Decode(void * Data);
	__property void * User = {read=FUser};
	__property int UserSize = {read=FUserSize, nodefault};
	__property bool HasHashKey = {read=GetFlag, write=SetFlag, index=0, nodefault};
	
public:
	__fastcall virtual TEncrypt(void);
	__fastcall virtual ~TEncrypt(void);
	/*         class method */ static int __fastcall MaxKeySize(TMetaClass* vmt);
	/*         class method */ static bool __fastcall SelfTest(TMetaClass* vmt);
	virtual void __fastcall Init(const void *Key, int Size, void * IVector);
	void __fastcall InitKey(const AnsiString Key, void * IVector);
	virtual void __fastcall Done(void);
	virtual void __fastcall Protect(void);
	void __fastcall EncodeStream(const Classes::TStream* Source, const Classes::TStream* Dest, int DataSize
		);
	void __fastcall DecodeStream(const Classes::TStream* Source, const Classes::TStream* Dest, int DataSize
		);
	void __fastcall EncodeFile(const AnsiString Source, const AnsiString Dest);
	void __fastcall DecodeFile(const AnsiString Source, const AnsiString Dest);
	void __fastcall EncodeBuffer(const void *Source, void *Dest, int DataSize);
	void __fastcall DecodeBuffer(const void *Source, void *Dest, int DataSize);
	AnsiString __fastcall EncodeString(const AnsiString Source);
	AnsiString __fastcall DecodeString(const AnsiString Source);
	__property Tinydb::TEncryptMode Mode = {read=FMode, write=FMode, nodefault};
	__property Hashbase::THash* Hash = {read=GetHash};
	__property TMetaClass* HashClass = {read=FHashClass, write=SetHashClass};
	__property int KeySize = {read=FKeySize, nodefault};
	__property int BufSize = {read=FBufSize, nodefault};
	__property bool IncludeHashKey = {read=GetFlag, write=SetFlag, index=8, nodefault};
	__property bool Initialized = {read=GetFlag, write=SetFlag, index=9, nodefault};
	__property void * Vector = {read=FVector};
	__property void * Feedback = {read=FFeedback};
};


class DELPHICLASS TEncAlgo_Base;
class PASCALIMPLEMENTATION TEncAlgo_Base : public Tinydb::TEncryptAlgo 
{
	typedef Tinydb::TEncryptAlgo inherited;
	
private:
	TEncrypt* FEncObject;
	
protected:
	virtual void __fastcall SetMode(Tinydb::TEncryptMode Value);
	virtual Tinydb::TEncryptMode __fastcall GetMode(void);
	virtual TMetaClass* __fastcall GetEncryptObjectClass(void) = 0 ;
	
public:
	__fastcall virtual TEncAlgo_Base(System::TObject* AOwner);
	__fastcall virtual ~TEncAlgo_Base(void);
	virtual void __fastcall InitKey(const AnsiString Key);
	virtual void __fastcall Done(void);
	virtual void __fastcall EncodeBuffer(const void *Source, void *Dest, int DataSize);
	virtual void __fastcall DecodeBuffer(const void *Source, void *Dest, int DataSize);
};


//-- var, const, procedure ---------------------------------------------------
static const Shortint EncErrGeneric = 0x0;
static const Shortint EncErrInvalidKey = 0x1;
static const Shortint EncErrInvalidKeySize = 0x2;
static const Shortint EncErrNotInitialized = 0x3;
extern PACKAGE bool CheckEncryptKeySize;
extern PACKAGE TMetaClass*FDefaultHashClass;
extern PACKAGE TEncProgressEvent FProgress;
extern PACKAGE void __fastcall RaiseEncryptException(const int ErrorCode, const AnsiString Msg);
extern PACKAGE TMetaClass* __fastcall DefaultHashClass(TMetaClass* NewHashClass);
extern PACKAGE void __fastcall XORBuffers(void * I1, void * I2, int Size, void * Dest);
extern PACKAGE void __fastcall SHIFTBuffers(Sysutils::PByteArray P, Sysutils::PByteArray N, int Size
	, int Shift);
extern PACKAGE void __fastcall INCBuffer(Sysutils::PByteArray P, int Size);
extern PACKAGE void __fastcall DoProgress(int Current, int Maximal);

}	/* namespace Encryptbase */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Encryptbase;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// EncryptBase
