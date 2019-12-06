// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Hash_MD.pas' rev: 5.00

#ifndef Hash_MDHPP
#define Hash_MDHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <HashBase.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hash_md
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS THash_MD4;
class PASCALIMPLEMENTATION THash_MD4 : public Hashbase::THash 
{
	typedef Hashbase::THash inherited;
	
protected:
	unsigned FCount;
	Byte FBuffer[64];
	unsigned FDigest[10];
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(THash_MD4)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	virtual void __fastcall Transform(Hashbase::PIntArray Buffer);
	
public:
	#pragma option push -w-inl
	/* virtual class method */ virtual int __fastcall DigestKeySize() { return DigestKeySize(__classid(THash_MD4)
		); }
	#pragma option pop
	/*         class method */ static int __fastcall DigestKeySize(TMetaClass* vmt);
	virtual void __fastcall Init(void);
	virtual void __fastcall Done(void);
	virtual void __fastcall Calc(const void *Data, int DataSize);
	virtual void * __fastcall DigestKey(void);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_MD4(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_MD4(void) : Hashbase::THash() { }
	#pragma option pop
	
};


class DELPHICLASS THash_MD5;
class PASCALIMPLEMENTATION THash_MD5 : public THash_MD4 
{
	typedef THash_MD4 inherited;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(THash_MD5)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	virtual void __fastcall Transform(Hashbase::PIntArray Buffer);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_MD5(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_MD5(void) : THash_MD4() { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Hash_md */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Hash_md;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Hash_MD
