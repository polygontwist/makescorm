{Version myini 23.8.2005}
unit myIni;

interface

uses
   Windows,IniFiles;

  //ini-Files
  function  readINIstring (filepfad,bereich,tag:string):string;
  procedure writeINIstring(filepfad,bereich,tag,wert:string);
  function  readINIint    (filepfad,bereich,tag:string):integer;
  procedure writeINIint   (filepfad,bereich,tag:string;wert:integer);
  function  readINIbool   (filepfad,bereich,tag:string):bool;
  procedure writeINIbool  (filepfad,bereich,tag:string;wert:bool);

  procedure clearINIsec(filepfad,section:string);
  //ini-Files-end


              
implementation

//********************************** ini-files *********************************

function  readINIstring(filepfad,bereich,tag:string):string;
var  DateiIni: TIniFile;
begin
 DateiIni := TIniFile.Create(filepfad);
 result:='';
 with DateiIni do
  begin
   result:=ReadString(bereich, tag,''); //bereich,tag,default
   Free;
  end;
end;

procedure writeINIstring(filepfad,bereich,tag,wert:string);
var  DateiIni: TIniFile;
begin
 DateiIni := TIniFile.Create(filepfad);
 with DateiIni do
  begin
   WriteString(bereich, tag, wert);
   Free;
  end;
end;

function  readINIint(filepfad,bereich,tag:string):integer;
var  DateiIni: TIniFile;
begin
 DateiIni := TIniFile.Create(filepfad);
 with DateiIni do
  begin
   result:=ReadInteger(bereich, tag,0); //bereich,tag,default
   Free;
  end;
end;

procedure writeINIint(filepfad,bereich,tag:string;wert:integer);
var  DateiIni: TIniFile;
begin
 DateiIni := TIniFile.Create(filepfad);
 with DateiIni do
  begin
   WriteInteger(bereich, tag, wert);
   Free;
  end;
end;

function  readINIbool(filepfad,bereich,tag:string):bool;
var  DateiIni: TIniFile;
begin
 DateiIni := TIniFile.Create(filepfad);
 with DateiIni do
  begin
   result:=Readbool(bereich, tag,false); //bereich,tag,default
   Free;
  end;
end;

procedure writeINIbool(filepfad,bereich,tag:string;wert:bool);
var  DateiIni: TIniFile;
begin
 DateiIni := TIniFile.Create(filepfad);
 with DateiIni do
  begin
   Writebool(bereich, tag, wert);
   Free;
  end;
end;

procedure clearINIsec(filepfad,section:string);
var  DateiIni: TIniFile;
begin
 DateiIni := TIniFile.Create(filepfad);
 with DateiIni do
  begin
   EraseSection(section);
   Free;
  end;
end;

end.
