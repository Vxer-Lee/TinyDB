// Borland C++ Builder
// Copyright (c) 1995, 2002 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Hash_SHA.pas' rev: 6.00

#ifndef Hash_SHAHPP
#define Hash_SHAHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <Hash_MD.hpp>	// Pascal unit
#include <Hash_RipeMD.hpp>	// Pascal unit
#include <HashBase.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hash_sha
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS THash_SHA;
class PASCALIMPLEMENTATION THash_SHA : public Hash_ripemd::THash_RipeMD160 
{
	typedef Hash_ripemd::THash_RipeMD160 inherited;
	
private:
	bool FRotate;
	
protected:
	/* virtual class method */ virtual void * __fastcall TestVector(TMetaClass* vmt);
	virtual void __fastcall Transform(Hashbase::PIntArray Buffer);
	
public:
	virtual void __fastcall Done(void);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_SHA(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_SHA(void) : Hash_ripemd::THash_RipeMD160() { }
	#pragma option pop
	
};


class DELPHICLASS THash_SHA1;
class PASCALIMPLEMENTATION THash_SHA1 : public THash_SHA 
{
	typedef THash_SHA inherited;
	
protected:
	/* virtual class method */ virtual void * __fastcall TestVector(TMetaClass* vmt);
	
public:
	virtual void __fastcall Init(void);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_SHA1(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_SHA1(void) : THash_SHA() { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Hash_sha */
using namespace Hash_sha;
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Hash_SHA
