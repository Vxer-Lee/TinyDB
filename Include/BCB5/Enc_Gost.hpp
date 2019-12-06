// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Enc_Gost.pas' rev: 5.00

#ifndef Enc_GostHPP
#define Enc_GostHPP

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

namespace Enc_gost
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TEnc_Gost;
class PASCALIMPLEMENTATION TEnc_Gost : public Encryptbase::TEncrypt 
{
	typedef Encryptbase::TEncrypt inherited;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void __fastcall GetContext(int &ABufSize, int &AKeySize, int &AUserSize
		) { GetContext(__classid(TEnc_Gost), ABufSize, AKeySize, AUserSize); }
	#pragma option pop
	/*         class method */ static void __fastcall GetContext(TMetaClass* vmt, int &ABufSize, int &AKeySize
		, int &AUserSize);
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(TEnc_Gost)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	virtual void __fastcall Encode(void * Data);
	virtual void __fastcall Decode(void * Data);
	
public:
	virtual void __fastcall Init(const void *Key, int Size, void * IVector);
public:
	#pragma option push -w-inl
	/* TEncrypt.Create */ inline __fastcall virtual TEnc_Gost(void) : Encryptbase::TEncrypt() { }
	#pragma option pop
	#pragma option push -w-inl
	/* TEncrypt.Destroy */ inline __fastcall virtual ~TEnc_Gost(void) { }
	#pragma option pop
	
};


class DELPHICLASS TEncAlgo_Gost;
class PASCALIMPLEMENTATION TEncAlgo_Gost : public Encryptbase::TEncAlgo_Base 
{
	typedef Encryptbase::TEncAlgo_Base inherited;
	
protected:
	virtual TMetaClass* __fastcall GetEncryptObjectClass(void);
public:
	#pragma option push -w-inl
	/* TEncAlgo_Base.Create */ inline __fastcall virtual TEncAlgo_Gost(System::TObject* AOwner) : Encryptbase::TEncAlgo_Base(
		AOwner) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TEncAlgo_Base.Destroy */ inline __fastcall virtual ~TEncAlgo_Gost(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Enc_gost */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Enc_gost;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Enc_Gost
