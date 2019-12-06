// Borland C++ Builder
// Copyright (c) 1995, 2002 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'HashBase.pas' rev: 6.00

#ifndef HashBaseHPP
#define HashBaseHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hashbase
{
//-- type declarations -------------------------------------------------------
typedef unsigned TIntArray[1024];

typedef unsigned *PIntArray;

typedef TMetaClass*THashClass;

class DELPHICLASS THash;
class PASCALIMPLEMENTATION THash : public Classes::TPersistent 
{
	typedef Classes::TPersistent inherited;
	
private:
	AnsiString __fastcall GetDigestStr(int Index);
	
protected:
	/* virtual class method */ virtual void * __fastcall TestVector(TMetaClass* vmt);
	
public:
	__fastcall virtual ~THash(void);
	virtual void __fastcall Init(void);
	virtual void __fastcall Calc(const void *Data, int DataSize);
	virtual void __fastcall Done(void);
	virtual void * __fastcall DigestKey(void);
	/* virtual class method */ virtual int __fastcall DigestKeySize(TMetaClass* vmt);
	/*         class method */ static AnsiString __fastcall CalcBuffer(TMetaClass* vmt, void * Digest, const void *Buffer, int BufferSize);
	/*         class method */ static AnsiString __fastcall CalcStream(TMetaClass* vmt, void * Digest, const Classes::TStream* Stream, int StreamSize);
	/*         class method */ static AnsiString __fastcall CalcString(TMetaClass* vmt, void * Digest, const AnsiString Data);
	/*         class method */ static AnsiString __fastcall CalcFile(TMetaClass* vmt, void * Digest, const AnsiString FileName);
	/*         class method */ static bool __fastcall SelfTest(TMetaClass* vmt);
	__property AnsiString DigestKeyStr = {read=GetDigestStr, index=-1};
	__property AnsiString DigestString = {read=GetDigestStr, index=0};
	__property AnsiString DigestBase16 = {read=GetDigestStr, index=16};
	__property AnsiString DigestBase64 = {read=GetDigestStr, index=64};
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THash(void) : Classes::TPersistent() { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE int DefaultDigestStringFormat;
extern PACKAGE bool InitTestIsOk;
extern PACKAGE unsigned __fastcall (*SwapInteger)(unsigned Value);
extern PACKAGE void __fastcall (*SwapIntegerBuffer)(void * Source, void * Dest, int Count);
extern PACKAGE int FCPUType;
extern PACKAGE int __fastcall CPUType(void);
extern PACKAGE unsigned __fastcall ROL(unsigned Value, int Shift);
extern PACKAGE unsigned __fastcall ROLADD(unsigned Value, unsigned Add, int Shift);
extern PACKAGE unsigned __fastcall ROLSUB(unsigned Value, unsigned Sub, int Shift);
extern PACKAGE unsigned __fastcall ROR(unsigned Value, int Shift);
extern PACKAGE unsigned __fastcall RORADD(unsigned Value, unsigned Add, int Shift);
extern PACKAGE unsigned __fastcall RORSUB(unsigned Value, unsigned Sub, int Shift);
extern PACKAGE unsigned __fastcall SwapBits(unsigned Value);
extern PACKAGE AnsiString __fastcall StrToBase64(char * Value, int Len);
extern PACKAGE AnsiString __fastcall Base64ToStr(char * Value, int Len);
extern PACKAGE AnsiString __fastcall StrToBase16(char * Value, int Len);
extern PACKAGE AnsiString __fastcall Base16ToStr(char * Value, int Len);
extern PACKAGE unsigned __fastcall CRC32(unsigned CRC, void * Data, unsigned DataSize);
extern PACKAGE char * __fastcall GetTestVector(void);

}	/* namespace Hashbase */
using namespace Hashbase;
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// HashBase
