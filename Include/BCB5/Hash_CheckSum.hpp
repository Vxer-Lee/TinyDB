// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Hash_CheckSum.pas' rev: 5.00

#ifndef Hash_CheckSumHPP
#define Hash_CheckSumHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <HashBase.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hash_checksum
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS THash_XOR16;
class PASCALIMPLEMENTATION THash_XOR16 : public Hashbase::THash 
{
	typedef Hashbase::THash inherited;
	
private:
	Word FCRC;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(THash_XOR16)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	
public:
	#pragma option push -w-inl
	/* virtual class method */ virtual int __fastcall DigestKeySize() { return DigestKeySize(__classid(THash_XOR16)
		); }
	#pragma option pop
	/*         class method */ static int __fastcall DigestKeySize(TMetaClass* vmt);
	virtual void __fastcall Init(void);
	virtual void __fastcall Calc(const void *Data, int DataSize);
	virtual void * __fastcall DigestKey(void);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_XOR16(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_XOR16(void) : Hashbase::THash() { }
	#pragma option pop
	
};


class DELPHICLASS THash_XOR32;
class PASCALIMPLEMENTATION THash_XOR32 : public Hashbase::THash 
{
	typedef Hashbase::THash inherited;
	
private:
	unsigned FCRC;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(THash_XOR32)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	
public:
	#pragma option push -w-inl
	/* virtual class method */ virtual int __fastcall DigestKeySize() { return DigestKeySize(__classid(THash_XOR32)
		); }
	#pragma option pop
	/*         class method */ static int __fastcall DigestKeySize(TMetaClass* vmt);
	virtual void __fastcall Init(void);
	virtual void __fastcall Calc(const void *Data, int DataSize);
	virtual void * __fastcall DigestKey(void);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_XOR32(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_XOR32(void) : Hashbase::THash() { }
	#pragma option pop
	
};


class DELPHICLASS THash_CRC32;
class PASCALIMPLEMENTATION THash_CRC32 : public THash_XOR32 
{
	typedef THash_XOR32 inherited;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(THash_CRC32)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	
public:
	virtual void __fastcall Init(void);
	virtual void __fastcall Calc(const void *Data, int DataSize);
	virtual void __fastcall Done(void);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_CRC32(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_CRC32(void) : THash_XOR32() { }
	#pragma option pop
	
};


class DELPHICLASS THash_CRC16_CCITT;
class PASCALIMPLEMENTATION THash_CRC16_CCITT : public THash_XOR16 
{
	typedef THash_XOR16 inherited;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(THash_CRC16_CCITT)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	
public:
	virtual void __fastcall Init(void);
	virtual void __fastcall Calc(const void *Data, int DataSize);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_CRC16_CCITT(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_CRC16_CCITT(void) : THash_XOR16() { }
	#pragma option pop
	
};


class DELPHICLASS THash_CRC16_Standard;
class PASCALIMPLEMENTATION THash_CRC16_Standard : public THash_XOR16 
{
	typedef THash_XOR16 inherited;
	
protected:
	#pragma option push -w-inl
	/* virtual class method */ virtual void * __fastcall TestVector() { return TestVector(__classid(THash_CRC16_Standard)
		); }
	#pragma option pop
	/*         class method */ static void * __fastcall TestVector(TMetaClass* vmt);
	
public:
	virtual void __fastcall Calc(const void *Data, int DataSize);
public:
	#pragma option push -w-inl
	/* THash.Destroy */ inline __fastcall virtual ~THash_CRC16_Standard(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash_CRC16_Standard(void) : THash_XOR16() { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Hash_checksum */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Hash_checksum;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Hash_CheckSum
