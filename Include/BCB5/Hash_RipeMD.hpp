// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Hash_RipeMD.pas' rev: 5.00

#ifndef Hash_RipeMDHPP
#define Hash_RipeMDHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <Hash_MD.hpp>	// Pascal unit
#include <HashBase.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hash_ripemd
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS THash_RipeMD128;
class PASCALIMPLEMENTATION THash_RipeMD128 : public Hash_md::THash_MD4 
{
	typedef Hash_md::THash_MD4 inherited;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(THash_RipeMD128)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	virtual void __fastcall Transform(Hashbase::PIntArray Buffer);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_RipeMD128(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_RipeMD128(void) : Hash_md::THash_MD4() { }
	#pragma option pop
	
};


class DELPHICLASS THash_RipeMD160;
class PASCALIMPLEMENTATION THash_RipeMD160 : public Hash_md::THash_MD4 
{
	typedef Hash_md::THash_MD4 inherited;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(THash_RipeMD160)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	virtual void __fastcall Transform(Hashbase::PIntArray Buffer);
	
public:
	#pragma option push -w-inl
	/* virtual class method */ virtual int __fastcall DigestKeySize() { return DigestKeySize(__classid(THash_RipeMD160)
		); }
	#pragma option pop
	/*         class method */ static int __fastcall DigestKeySize(TMetaClass* vmt);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_RipeMD160(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_RipeMD160(void) : Hash_md::THash_MD4() { }
	#pragma option pop
	
};


class DELPHICLASS THash_RipeMD256;
class PASCALIMPLEMENTATION THash_RipeMD256 : public Hash_md::THash_MD4 
{
	typedef Hash_md::THash_MD4 inherited;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(THash_RipeMD256)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	virtual void __fastcall Transform(Hashbase::PIntArray Buffer);
	
public:
	#pragma option push -w-inl
	/* virtual class method */ virtual int __fastcall DigestKeySize() { return DigestKeySize(__classid(THash_RipeMD256)
		); }
	#pragma option pop
	/*         class method */ static int __fastcall DigestKeySize(TMetaClass* vmt);
	virtual void __fastcall Init(void);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_RipeMD256(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_RipeMD256(void) : Hash_md::THash_MD4() { }
	#pragma option pop
	
};


class DELPHICLASS THash_RipeMD320;
class PASCALIMPLEMENTATION THash_RipeMD320 : public Hash_md::THash_MD4 
{
	typedef Hash_md::THash_MD4 inherited;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(THash_RipeMD320)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	virtual void __fastcall Transform(Hashbase::PIntArray Buffer);
	
public:
	#pragma option push -w-inl
	/* virtual class method */ virtual int __fastcall DigestKeySize() { return DigestKeySize(__classid(THash_RipeMD320)
		); }
	#pragma option pop
	/*         class method */ static int __fastcall DigestKeySize(TMetaClass* vmt);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_RipeMD320(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_RipeMD320(void) : Hash_md::THash_MD4() { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Hash_ripemd */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Hash_ripemd;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Hash_RipeMD
