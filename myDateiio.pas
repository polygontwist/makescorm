unit myDateiio;

interface

uses SysUtils
  ,DateUtils
  ,Windows
  //,FileCtrl
  //,Dialogs
  , ActiveX
  , ShellApi
  ,classes
  ,myString
  ,ShlObj
  ;

  function dateida(pfad:string):boolean;
  function deldatei(pfad:string):boolean;
  function copydatei(qpfad,zpfad:string):boolean;
  function movedatei(qpfad,zpfad:string):boolean;
  function makeDir(newdir:string):boolean;
  function showDir(hand:thandle;dir:string):boolean;
  function ifDir(Directory:string):boolean;
  function delDir(Directory:string;hWindow: HWND):boolean;


  function istdateigleich(datei1,datei2:string;maxbyteanzahl:cardinal):boolean;
  function nofilepfad(url:string):string;        //Rückgabe nur Datei

  function dateigross(AFileName:string):cardinal;// max 2GB

  //sucht ordner und unterordner nach Datei
  function gibtesDatei(pfad,suchstr:string):boolean; //true wenn es eine Datei mit im suchstr enhaltenen string gibt

  //rückgabe aller Dateien (wie im Filder definiert)+evt. Unterverzeichnisse
  procedure GetFiles(const Directory: string; var Files: TStrings;const FileMask: string;const SubFolders: Boolean);
  function SlashSep(const Path, S: string): string;

  function WindowsDirectory:string;  //WindowsDirectory
  function getCSIDLPfad(Folder:integer;hWindow: HWND):string;//spezielle Windowsordner
                                               


  procedure lesedateienein(pfad,thefilter:string;var dateiliste:TStringList;inversfilter:Boolean); //liest Dateinamen im 'Ordner' in TStringList (dateiliste) ein
  //function CompareDates(List: TStringList; Index1, Index2: Integer): Integer;
  //procedure SortByDateTime(List: TStringList);

  //Gibt Inhalt eines Verzechnisses, inkl Ordner und moveupBacklink
  function GetFileDir(Directory: string; var Files: TStringList):integer;

  function mdio_getPfad(s:string):string;  //gibt Filpfad zurück
  function mdio_getDatei(s:string):string; //gibt datei im Pfad zurück



const  //nicht in ShellApi definierte Constannten
{
CSIDL_COOKIES             Cookies
CSIDL_DESKTOPDIRECTORY    Desktop
CSIDL_FAVORITES           Favoriten
CSIDL_HISTORY             Internet-Verlauf
CSIDL_INTERNET_CACHE      "Temporary Internet Files"
CSIDL_PERSONAL            Eigene Dateien
CSIDL_PROGRAMS            "Programme" im Startmenü
CSIDL_RECENT              "Dokumente" im Startmenü
CSIDL_SENDTO              "Senden an" im Kontextmenü
CSIDL_STARTMENU           Startmenü
CSIDL_STARTUP             Autostart
                                               }
 CSIDL_DESKTOP = 0;
 CSIDL_INTERNET = 1;
 CSIDL_PROGRAMS = 2;
 CSIDL_CONTROLS = 3;
 CSIDL_PRINTERS = 4;
 CSIDL_PERSONAL = 5;
 CSIDL_FAVORITES = 6;
 CSIDL_STARTUP = 7;
 CSIDL_RECENT = 8;
 CSIDL_SENDTO = 9;
 CSIDL_BITBUCKET = 10;  // Recycle bin
 CSIDL_STARTMENU = 11;
 CSIDL_DESKTOPDIRECTORY = 16;
 CSIDL_DRIVES    = 17;
 CSIDL_NETWORK = 18;
 CSIDL_NETHOOD = 19;
 CSIDL_FONTS = 20;
 CSIDL_TEMPLATES = 21;
 CSIDL_COMMON_STARTMENU = 22;
 CSIDL_COMMON_PROGRAMS = 23;   //AllUserProgramms
 CSIDL_COMMON_STARTUP = 24;
 CSIDL_COMMON_DESKTOPDIRECTORY = 25;
 CSIDL_APPDATA = 26;
 CSIDL_PRINTHOOD = 27;

 CSIDL_LOCAL_APPDATA = 28;
 CSIDL_ALTSTARTUP = 29;
 CSIDL_COMMON_ALTSTARTUP = 30;
 CSIDL_COMMON_FAVORITES = 31;
 CSIDL_INTERNET_CACHE = 32;
 CSIDL_COOKIES = 33;
 CSIDL_HISTORY = 34;
 CSIDL_COMMON_APPDATA = 35;
 CSIDL_WINDOWS = 36;
 CSIDL_SYSTEM = 37;
 CSIDL_PROGRAM_FILES = 38;
 CSIDL_MYPICTURES = 39;
 CSIDL_PROFILE = 40;
 CSIDL_SYSTEMX86 = 41;
 CSIDL_PROGRAM_FILESX86 = 42;
 CSIDL_PROGRAM_FILES_COMMON = 43;
 CSIDL_PROGRAM_FILES_COMMONX86 = 44;
 CSIDL_COMMON_TEMPLATES = 45;
 CSIDL_COMMON_DOCUMENTS = 46;
 CSIDL_COMMON_ADMINTOOLS = 47;
 CSIDL_ADMINTOOLS = 48;
 CSIDL_CONNECTIONS = 49;

 CSIDL_AllMusik = 53;    //E:\Dokumente und Einstellungen\All Users\Dokumente\Eigene Musik
 CSIDL_AllPictures = 54; //E:\Dokumente und Einstellungen\All Users\Dokumente\Eigene Bilder
 CSIDL_AllVideos = 55;   //E:\Dokumente und Einstellungen\All Users\Dokumente\Eigene Videos
 CSIDL_WinRes = 56;      // C:\WINDOWS\Resources
 CSIDL_UserAWCD = 59;    // E:\Dokumente und Einstellungen\andreas\Lokale Einstellungen\Anwendungsdaten\Microsoft\CD Burning


//SHFileOpStruct
{ type SHFILEOPSTRUCT=record
     hwnd:HWND;
     wFunc:integer;
     pFrom:LPCSTR;
     pTo:LPCSTR;
     fFlags:FILEOP_FLAGS;
     fAnyOperationsAborted:BOOL;
     hNameMappings:LPVOID;
     lpszProgressTitle:LPCSTR;
    end;
// SHFILEOPSTRUCT, FAR *LPSHFILEOPSTRUCT;
   }


implementation



//http://www.delphipraxis.net/421-pfad-der-special-folders-ermitteln.html
function GetSpecialFolder(hWindow: HWND; Folder: Integer): String;
var
  pMalloc: IMalloc;
  pidl: PItemIDList;
  Path: PChar;
begin
  // get IMalloc interface pointer
  if (SHGetMalloc(pMalloc) <> S_OK) then
  begin
    MessageBox(hWindow, 'Couldn''t get pointer to IMalloc interface.',
               'SHGetMalloc(pMalloc)', 16);
    Result := '';
    Exit;
  end;

  // retrieve path
  SHGetSpecialFolderLocation(hWindow, Folder, pidl);
  GetMem(Path, MAX_PATH);
  SHGetPathFromIDList(pidl, Path);
  Result := Path;
  FreeMem(Path);

  // free memory allocated by SHGetSpecialFolderLocation
  pMalloc.Free(pidl);
end;

 //------------------------------------------------------------------------------

//Hilfsfunktion, um Schrägstriche hinzuzfügen, wenn nötig
function SlashSep(const Path, S: string): string;
begin
 if AnsiLastChar(Path)^ <> '\' then  Result := Path + '\' + S
    else Result := Path + S;
end;

procedure GetFiles(const Directory: string; var Files: TStrings;const FileMask: string;const SubFolders: Boolean);
var SearchRec: TSearchRec;
    temp1,temp2:string;
    merken:boolean;
begin
  //Zuerst alle Dateien im aktuelle Verzeichnis finden
  if FindFirst(SlashSep(Directory, '*.*'), faAnyFile and not faDirectory ,
  SearchRec) = 0 then
  begin
    try
      repeat
        temp1:=FileMask;
        merken:=false;
        while pos(',',temp1)>0 do
        begin
         temp2:=copy(temp1,1,pos(',',temp1)-1);
         if pos(temp2,SearchRec.Name)>0 then begin merken:=true;break;end;
         temp1:=copy(temp1,pos(',',temp1)+1,length(temp1));
        end;
        if length(temp1)>0 then
          if pos(temp1,SearchRec.Name)>0 then merken:=true;

        if SearchRec.Size=0 then merken:=false;

        if merken then Files.Add(SlashSep(Directory, SearchRec.Name));

      until FindNext(SearchRec) <> 0;
    finally
      SysUtils.FindClose(SearchRec);
    end;
  end;
  if SubFolders then
  begin
    if FindFirst(SlashSep(Directory,'*.*'), faAnyFile,  SearchRec) = 0 then
    begin
      try
        repeat
          //Wenn es ein Verzeichnis ist, Rekursion verwenden  
          if (SearchRec.Attr and faDirectory) <> 0 then
          begin
            if((SearchRec.Name<>'.')and(SearchRec.Name<>'..'))then //backRoots
              GetFiles(SlashSep(Directory, SearchRec.Name), Files, FileMask, SubFolders);
          end;
        until FindNext(SearchRec)<>0;
      finally
        SysUtils.FindClose(SearchRec);
      end;
    end;
  end;
end;


//Ordner solange durchgehen bis suchstring in Dateiname vorkommt.
function gibtesDatei(pfad,suchstr:string):boolean;

    function sucheindir(pfad,suchstr:string):boolean;
    var SearchRec: TSearchRec;
    begin
    result:=false;

    //Zuerst alle Dateien im aktuelle Verzeichnis finden
    if SysUtils.FindFirst(SlashSep(pfad, '*.*'), faAnyFile and not faDirectory, SearchRec) = 0 then
     begin
     try
      repeat
       if(pos(suchstr,SearchRec.Name)>0) then result:=true;
       if result then break;
      until SysUtils.FindNext(SearchRec) <> 0;
     finally
      SysUtils.FindClose(SearchRec);
     end;
    end;

    if result=false then
    begin
    if FindFirst(SlashSep(pfad,'*.*'), faAnyFile,  SearchRec) = 0 then
    begin
      try
        repeat
          //Wenn es ein Verzeichnis ist, Rekursion verwenden  
          if (SearchRec.Attr and faDirectory) <> 0 then
          begin
            if ((SearchRec.Name <> '.') and (SearchRec.Name <> '..')) then
               result:=sucheindir(SlashSep(pfad, SearchRec.Name),suchstr);
          end;
          if result then break;
        until FindNext(SearchRec) <> 0;
      finally
        SysUtils.FindClose(SearchRec);
      end;
    end;

    end;
   end;

begin
 result:=sucheindir(pfad,suchstr);
end;


function nofilepfad(url:string):string;
var s:string;
begin
 //lösche alles vor '\'
 s:=url;
 while pos('\',s)>0 do
 begin
  s:=copy(s,pos('\',s)+1,length(s));
 end;

 while pos('/',s)>0 do
 begin
  s:=copy(s,pos('/',s)+1,length(s));
 end;

 result:=s;
end;


function dateigross(AFileName:string):cardinal;// max 2GB
var
  F: TSearchRec;
begin
  Result := 0;
  if FindFirst(AFileName, faAnyFile, F) = 0 then
  begin
    try
      Result :=  F.FindData.nFileSizeLow or (F.FindData.nFileSizeHigh shl 32);
    finally
      SysUtils.FindClose(F);
    end;
  end;
end;


//maxbyteanzahl=0 komplette Datei, sonst nur die angegebenen Bytes ab Anfang vergleichen
function istdateigleich(datei1,datei2:string;maxbyteanzahl:cardinal):boolean;
var f1,f2: TFileStream;
    Buffer1 : array [1..500] of Byte;
    Buffer2 : array [1..500] of Byte;
    Size   : integer;
    buffersize:integer;
    i:integer;
begin
 result:=true;
 //erst mal größe vergleichen
 if dateigross(datei1)<>dateigross(datei2) then
 begin
  result:=false;
 end
 else
 begin //ist die Größe unterschiedlich, byte weise vergleichen
 
 f1:=TFileStream.Create(datei1, fmOpenRead or fmShareDenyWrite);
 f2:=TFileStream.Create(datei2, fmOpenRead or fmShareDenyWrite);
 try
  Repeat
   Size:=f1.Size-f1.Position; //bytes ab aktuelle position bis ende der datei

   if maxbyteanzahl>0 then
    if Size>maxbyteanzahl then size:=maxbyteanzahl;

   buffersize:=500;
   if buffersize>Size then buffersize:=Size;

   f1.ReadBuffer(Buffer1, buffersize);
   f2.ReadBuffer(Buffer2, buffersize);
   for i:=1 to buffersize do
   begin
    if Buffer1[i]<>Buffer2[i] then
     begin
      result:=false;
      break;
     end;
   end;
  until f1.Position >= f1.Size;
 finally
   f2.Free;
   f1.Free;
 end;
 end;
end;


function dateida(pfad:string):boolean;
var SearchRec : TSearchRec;
begin
 try
  result:=FindFirst(pfad,faAnyFile,SearchRec)=0;
 finally
   SysUtils.FindClose(SearchRec);
 end;

end;

function deldatei(pfad:string):boolean;
begin
  result:=DeleteFile(PChar(pfad));
end;

function copydatei(qpfad,zpfad:string):boolean;
begin
  result:=CopyFile(PChar(qpfad), PChar(zpfad), true);
end;

function movedatei(qpfad,zpfad:string):boolean;
begin
  result:=false;
  if(copydatei(qpfad,zpfad))then
   if deldatei(qpfad) then result:=true;
end;

function makeDir(newdir:string):boolean;
begin
  ForceDirectories(newdir);
  result:=DirectoryExists(newdir);
end;




function showDir(hand:thandle;dir:string):boolean;
begin
 if ShellExecute(hand, 'open', PChar('"' + Dir  + '"'),nil, nil, SW_NORMAL)=32 then
   result:=true
   else
   result:=false;
end;

function ifDir(Directory:string):boolean;   //relativ vom aktuellen Verzeichnis oder absolut
begin
 result:=DirectoryExists(Directory);        //ermittelt, ob ein bestimmtes Verzeichnis existiert
end;
        
function delDir(Directory:string;hWindow: HWND):boolean;   //'lw:\ordner'  'lw:\ordner\*.*' 'lw:\ordner\file.txt'
var sh: TSHFileOpStruct;
begin
 ZeroMemory(@sh, sizeof(sh));
 with sh do
   begin
   Wnd := hWindow;     //Application.Handle
   wFunc := fo_Delete;
   pFrom := PChar(Directory +#0);
   fFlags := fof_Silent or fof_NoConfirmation;
   end;
 result := SHFileOperation(sh) = 0; 
end;

//-------------------------------------------------------------------------------
//http://www.delphi-fundgrube.de/files/winfuncs.txt
function WindowsDirectory:string;  //WindowsDirectory
var WinDir : PChar;
begin
  WinDir:=StrAlloc(Max_Path);
  try
    GetWindowsDirectory(WinDir,Max_Path);
    Result:=String(WinDir);
  finally
    StrDispose(WinDir);
  end;
end;

//-------------------------------------------------------------------------------


function getCSIDLPfad(Folder:integer;hWindow: HWND):string;
var pidl: PItemIDList;
    sPath:PChar;
begin
  SHGetSpecialFolderLocation(hWindow,Folder,pidl);
  GetMem(sPath, MAX_PATH);
  SHGetPathFromIDList(pidl, sPath);
  Result:=sPath;
  FreeMem(sPath);
end;

//liest Dateinamen in TStringList (dateiliste) ein
//--------v2---------
function CompareFileDates(List: TStringList; Index1, Index2: Integer): Integer;
var
  FileDate1, FileDate2: TDateTime;
  FileAge1, FileAge2: Integer;
begin
 // Hole das Änderungsdatum der beiden Dateien
 FileAge1 := FileAge(List.Strings[Index1]);
 FileAge2 := FileAge(List.Strings[Index2]);

 // Überprüfen, ob die Dateiausgabe gültig ist (FileAge gibt -1 zurück, wenn ein Fehler auftritt)
   if (FileAge1 = -1) or (FileAge2 = -1) then
   begin
     Result := -1;  // Fehlerbehandlung, falls ein ungültiges Alter zurückgegeben wird
     Exit;
   end;

   // Konvertiere das Änderungsdatum in ein TDateTime-Format
   FileDate1 := FileDateToDateTime(FileAge1);
   FileDate2 := FileDateToDateTime(FileAge2);

  // Vergleiche die Änderungsdaten (neueste zuerst)
  Result := CompareDate(FileDate2, FileDate1);
end;
procedure SortFilesByDate(List: TStringList);
begin
  List.CustomSort(@CompareFileDates);
end;

procedure lesedateienein(pfad, thefilter: string; var dateiliste: TStringList; inversfilter: Boolean);

  procedure leseloop(pfad, vorpfad: string; inversfilter: Boolean);
  var
    SearchRec: TSearchRec;
    ffi: integer;
    hs: string;
    lastWriteTime: TDateTime;
  begin
    ffi := FindFirst(SlashSep(pfad, '*.*'), faAnyFile, SearchRec);
    while ffi = 0 do
    begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        if (SearchRec.Attr and faDirectory = faDirectory) then
        begin
          // Unterordner lesen
          vorpfad := vorpfad + SearchRec.Name + '\';
          leseloop(pfad + SearchRec.Name + '\', vorpfad, inversfilter);
          vorpfad := copy(vorpfad, 1, length(vorpfad) - length(SearchRec.Name) - 1);
        end
        else
        begin
          hs := copy(SearchRec.Name, length(SearchRec.Name) - 3, length(SearchRec.Name)); // Dateiendung

         //isfile(vorpfad + SearchRec.Name)
         if (FileExists(pfad + SearchRec.Name))then
            begin

              if (inversfilter) then
              begin
                if Pos(hs, thefilter) < 1 then
                begin
                  lastWriteTime := FileDateToDateTime(FileAge(pfad + SearchRec.Name));
                  dateiliste.AddObject(vorpfad + SearchRec.Name, TObject(lastWriteTime));//**
                end;
              end
              else
              begin
                if Pos(hs, thefilter) > 0 then
                begin
                  lastWriteTime := FileDateToDateTime(FileAge(pfad + SearchRec.Name));
                  dateiliste.AddObject(vorpfad + SearchRec.Name, TObject(lastWriteTime)); //**
                end;
              end;

            end;


        end;
      end;
      ffi := FindNext(SearchRec);
    end;
  end;

begin
  dateiliste.Clear;
  leseloop(pfad, '', inversfilter);
  SortFilesByDate(dateiliste);
end;





function GetFileDir(Directory: string; var Files: TStringList):integer;
var SearchRec: TSearchRec;
{    merken:boolean;
    tempdata:TStringList;}
begin
  Files.Clear;
  TStringList(Files).Sorted := True;
  result:=0;
  //Zuerst alle Dateien im aktuelle Verzeichnis finden   not faDirectory and
  if FindFirst(SlashSep(Directory, '*.*'), faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if SearchRec.Name='.' then
         //Files.Add(SlashSep(Directory, SearchRec.Name))
        else
         if SearchRec.Name='..' then
          begin
           inc(result);
           Files.Add('[back]'+Directory)
          end
         else
          if SearchRec.Attr=faAnyFile and faDirectory then
           begin
            inc(result);
            Files.Add('[Dir]'+SlashSep(Directory, SearchRec.Name));
           end
          else
           begin
            inc(result);
            Files.Add('[File]'+SlashSep(Directory, SearchRec.Name));
           end;
      until FindNext(SearchRec) <> 0;
    finally
      SysUtils.FindClose(SearchRec);
    end;
  end;
end;


function mdio_getPfad(s:string):string;
var p:integer;
begin
 p:=lastpos(s,'\');
 result:=copy(s,0,p);
end;

function mdio_getDatei(s:string):string;
var p:integer;
begin
 p:=lastpos(s,'\');
 result:=copy(s,p+1,length(s));
end;

//------------------------------------------------------------------------------



end.
