
{*******************************************************}
{                                                       }
{     TinyDB Include File                               }
{     Copyright (c) 2000-2003 DayDream Software         }
{                                                       }
{*******************************************************}

{ TinyDB.INC is included in all TinyDB units so you can specify
  global compiler options here. TinyDB.INC is included before
  each units required compiler options and the options specified
  here can be overridden by hardcode options in the source files. }

// The Version of Delphi/BCB
{$I Compilers.inc}

// Show Nag-Screen or not
{.$DEFINE TDB_SHOW_NAGSCREEN}

