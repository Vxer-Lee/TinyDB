// Borland C++ Builder
// Copyright (c) 1995, 2002 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'ZlibUnit.pas' rev: 6.00

#ifndef ZlibUnitHPP
#define ZlibUnitHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <Classes.hpp>	// Pascal unit
#include <SysUtils.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Zlibunit
{
//-- type declarations -------------------------------------------------------
typedef void * __fastcall (*TAlloc)(void * AppData, int Items, int Size);

typedef void __fastcall (*TFree)(void * AppData, void * Block);

#pragma pack(push, 1)
struct TZStreamRec
{
	char *next_in;
	int avail_in;
	int total_in;
	char *next_out;
	int avail_out;
	int total_out;
	char *msg;
	void *internal;
	TAlloc zalloc;
	TFree zfree;
	void *AppData;
	int data_type;
	int adler;
	int reserved;
} ;
#pragma pack(pop)

class DELPHICLASS TCustomZlibStream;
class PASCALIMPLEMENTATION TCustomZlibStream : public Classes::TStream 
{
	typedef Classes::TStream inherited;
	
private:
	Classes::TStream* FStrm;
	int FStrmPos;
	Classes::TNotifyEvent FOnProgress;
	#pragma pack(push, 1)
	TZStreamRec FZRec;
	#pragma pack(pop)
	
	char FBuffer[65536];
	int __fastcall GetBytesProcessed(void);
	
protected:
	DYNAMIC void __fastcall Progress(System::TObject* Sender);
	__property int BytesProcessed = {read=GetBytesProcessed, nodefault};
	__property Classes::TNotifyEvent OnProgress = {read=FOnProgress, write=FOnProgress};
	__fastcall TCustomZlibStream(Classes::TStream* Strm);
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~TCustomZlibStream(void) { }
	#pragma option pop
	
};


#pragma option push -b-
enum TCompressionLevel { clNone, clFastest, clDefault, clMax };
#pragma option pop

class DELPHICLASS TCompressionStream;
class PASCALIMPLEMENTATION TCompressionStream : public TCustomZlibStream 
{
	typedef TCustomZlibStream inherited;
	
private:
	float __fastcall GetCompressionRate(void);
	
public:
	__fastcall TCompressionStream(TCompressionLevel CompressionLevel, Classes::TStream* Dest);
	__fastcall virtual ~TCompressionStream(void);
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual int __fastcall Seek(int Offset, Word Origin)/* overload */;
	__property float CompressionRate = {read=GetCompressionRate};
	__property BytesProcessed ;
	__property OnProgress ;
	
/* Hoisted overloads: */
	
public:
	inline __int64 __fastcall  Seek(const __int64 Offset, Classes::TSeekOrigin Origin){ return TStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS TDecompressionStream;
class PASCALIMPLEMENTATION TDecompressionStream : public TCustomZlibStream 
{
	typedef TCustomZlibStream inherited;
	
public:
	__fastcall TDecompressionStream(Classes::TStream* Source);
	__fastcall virtual ~TDecompressionStream(void);
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual int __fastcall Seek(int Offset, Word Origin)/* overload */;
	__property BytesProcessed ;
	__property OnProgress ;
	
/* Hoisted overloads: */
	
public:
	inline __int64 __fastcall  Seek(const __int64 Offset, Classes::TSeekOrigin Origin){ return TStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS EZlibError;
class PASCALIMPLEMENTATION EZlibError : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	#pragma option push -w-inl
	/* Exception.Create */ inline __fastcall EZlibError(const AnsiString Msg) : Sysutils::Exception(Msg) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmt */ inline __fastcall EZlibError(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateRes */ inline __fastcall EZlibError(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmt */ inline __fastcall EZlibError(int Ident, const System::TVarRec * Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateHelp */ inline __fastcall EZlibError(const AnsiString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmtHelp */ inline __fastcall EZlibError(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResHelp */ inline __fastcall EZlibError(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmtHelp */ inline __fastcall EZlibError(System::PResStringRec ResStringRec, const System::TVarRec * Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~EZlibError(void) { }
	#pragma option pop
	
};


class DELPHICLASS ECompressionError;
class PASCALIMPLEMENTATION ECompressionError : public EZlibError 
{
	typedef EZlibError inherited;
	
public:
	#pragma option push -w-inl
	/* Exception.Create */ inline __fastcall ECompressionError(const AnsiString Msg) : EZlibError(Msg) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmt */ inline __fastcall ECompressionError(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size) : EZlibError(Msg, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateRes */ inline __fastcall ECompressionError(int Ident)/* overload */ : EZlibError(Ident) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmt */ inline __fastcall ECompressionError(int Ident, const System::TVarRec * Args, const int Args_Size)/* overload */ : EZlibError(Ident, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateHelp */ inline __fastcall ECompressionError(const AnsiString Msg, int AHelpContext) : EZlibError(Msg, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmtHelp */ inline __fastcall ECompressionError(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size, int AHelpContext) : EZlibError(Msg, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResHelp */ inline __fastcall ECompressionError(int Ident, int AHelpContext)/* overload */ : EZlibError(Ident, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmtHelp */ inline __fastcall ECompressionError(System::PResStringRec ResStringRec, const System::TVarRec * Args, const int Args_Size, int AHelpContext)/* overload */ : EZlibError(ResStringRec, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~ECompressionError(void) { }
	#pragma option pop
	
};


class DELPHICLASS EDecompressionError;
class PASCALIMPLEMENTATION EDecompressionError : public EZlibError 
{
	typedef EZlibError inherited;
	
public:
	#pragma option push -w-inl
	/* Exception.Create */ inline __fastcall EDecompressionError(const AnsiString Msg) : EZlibError(Msg) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmt */ inline __fastcall EDecompressionError(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size) : EZlibError(Msg, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateRes */ inline __fastcall EDecompressionError(int Ident)/* overload */ : EZlibError(Ident) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmt */ inline __fastcall EDecompressionError(int Ident, const System::TVarRec * Args, const int Args_Size)/* overload */ : EZlibError(Ident, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateHelp */ inline __fastcall EDecompressionError(const AnsiString Msg, int AHelpContext) : EZlibError(Msg, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmtHelp */ inline __fastcall EDecompressionError(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size, int AHelpContext) : EZlibError(Msg, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResHelp */ inline __fastcall EDecompressionError(int Ident, int AHelpContext)/* overload */ : EZlibError(Ident, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmtHelp */ inline __fastcall EDecompressionError(System::PResStringRec ResStringRec, const System::TVarRec * Args, const int Args_Size, int AHelpContext)/* overload */ : EZlibError(ResStringRec, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~EDecompressionError(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------
#define zlib_version "1.1.3"
extern PACKAGE void __fastcall CompressBuf(const void * InBuf, int InBytes, /* out */ void * &OutBuf, /* out */ int &OutBytes, TCompressionLevel CompressionLevel);
extern PACKAGE void __fastcall DecompressBuf(const void * InBuf, int InBytes, int OutEstimate, /* out */ void * &OutBuf, /* out */ int &OutBytes);
extern PACKAGE int __fastcall adler32(int adler, char * buf, int len);

}	/* namespace Zlibunit */
using namespace Zlibunit;
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// ZlibUnit
