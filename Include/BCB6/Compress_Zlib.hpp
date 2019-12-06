// Borland C++ Builder
// Copyright (c) 1995, 2002 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Compress_Zlib.pas' rev: 6.00

#ifndef Compress_ZlibHPP
#define Compress_ZlibHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <ZlibUnit.hpp>	// Pascal unit
#include <TinyDB.hpp>	// Pascal unit
#include <DB.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysUtils.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Compress_zlib
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TCompAlgo_Zlib;
class PASCALIMPLEMENTATION TCompAlgo_Zlib : public Tinydb::TCompressAlgo 
{
	typedef Tinydb::TCompressAlgo inherited;
	
private:
	Tinydb::TCompressLevel FLevel;
	int FSourceSize;
	Zlibunit::TCompressionLevel __fastcall ConvertCompLevel(Tinydb::TCompressLevel Value);
	void __fastcall Compress(Classes::TMemoryStream* SourceStream, Classes::TMemoryStream* DestStream, const Zlibunit::TCompressionLevel CompressionLevel);
	void __fastcall Decompress(Classes::TMemoryStream* SourceStream, Classes::TMemoryStream* DestStream);
	void __fastcall DoCompressProgress(System::TObject* Sender);
	void __fastcall DoDecompressProgress(System::TObject* Sender);
	void __fastcall InternalDoEncodeProgress(int Size, int Pos);
	void __fastcall InternalDoDecodeProgress(int Size, int Pos);
	
protected:
	virtual void __fastcall SetLevel(Tinydb::TCompressLevel Value);
	virtual Tinydb::TCompressLevel __fastcall GetLevel(void);
	
public:
	__fastcall virtual TCompAlgo_Zlib(System::TObject* AOwner);
	virtual void __fastcall EncodeStream(Classes::TMemoryStream* Source, Classes::TMemoryStream* Dest, int DataSize);
	virtual void __fastcall DecodeStream(Classes::TMemoryStream* Source, Classes::TMemoryStream* Dest, int DataSize);
public:
	#pragma option push -w-inl
	/* TDataProcessAlgo.Destroy */ inline __fastcall virtual ~TCompAlgo_Zlib(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Compress_zlib */
using namespace Compress_zlib;
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Compress_Zlib
