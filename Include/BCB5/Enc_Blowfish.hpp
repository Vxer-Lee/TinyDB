// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Enc_Blowfish.pas' rev: 5.00

#ifndef Enc_BlowfishHPP
#define Enc_BlowfishHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <EncryptBase.hpp>	// Pascal unit
#include <TinyDB.hpp>	// Pascal unit
#include <SysUtils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Enc_blowfish
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TEnc_Blowfish;
class PASCALIMPLEMENTATION TEnc_Blowfish : public Encryptbase::TEncrypt 
{
	typedef Encryptbase::TEncrypt inherited;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void __fastcall GetContext(int &ABufSize, int &AKeySize, int &AUserSize
		) { GetContext(__classid(TEnc_Blowfish), ABufSize, AKeySize, AUserSize); }
	#pragma option pop
	/*         class method */ static void __fastcall GetContext(TMetaClass* vmt, int &ABufSize, int &AKeySize
		, int &AUserSize);
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(TEnc_Blowfish)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	virtual void __fastcall Encode(void * Data);
	virtual void __fastcall Decode(void * Data);
	
public:
	virtual void __fastcall Init(const void *Key, int Size, void * IVector);
public:
	#pragma option push -w-inl
	/* TEncrypt.Create */ inline __fastcall virtual TEnc_Blowfish(void) : Encryptbase::TEncrypt() { }
	#pragma option pop
	#pragma option push -w-inl
	/* TEncrypt.Destroy */ inline __fastcall virtual ~TEnc_Blowfish(void) { }
	#pragma option pop
	
};


class DELPHICLASS TEncAlgo_Blowfish;
class PASCALIMPLEMENTATION TEncAlgo_Blowfish : public Encryptbase::TEncAlgo_Base 
{
	typedef Encryptbase::TEncAlgo_Base inherited;
	
protected:
	virtual TMetaClass* __fastcall GetEncryptObjectClass(void);
public:
	#pragma option push -w-inl
	/* TEncAlgo_Base.Create */ inline __fastcall virtual TEncAlgo_Blowfish(System::TObject* AOwner) : Encryptbase::TEncAlgo_Base(
		AOwner) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TEncAlgo_Base.Destroy */ inline __fastcall virtual ~TEncAlgo_Blowfish(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Enc_blowfish */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Enc_blowfish;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Enc_Blowfish
