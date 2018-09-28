unit myString;

interface

uses
  SysUtils,classes; //,Dialogs
type
  TNumbBase = 1..36;

   function noimg(zeile:string):string;
   function noahref(zeile:string):string;

   function string_ersetzen(zeile,zeichenq,zeichenz:string):string; //Quellzeole, zu ersetzendes Zeichen, neues Zeichen, Rückgabe=konvertierte Zeile
   function tag_ersetzen(zeile,zeichenq,zeichenz:string):string; //quellzeile, zu ersetzender Tag, neues Zeichen

   function TextConvertTo(wert:string;zu:string):string;     //Quellzeile, 'HTML','QHTML', 'XML' oder 'ASCII', rückgabe=neue Zeile
   function HTMLtoString(s:string):string; //konvertiert html in ascii
   function NumbToStr(Numb: LongInt; Base: TNumbBase): String;  //z.B. NumbToStr(888,16)->$378

   function StrHextoInt(wert:string):Int64;    //wandelt Hex-String zu Integer
   function InttoHexStr(wert:Longint):string;    //wandelt integer zu Hex-String
   function Hextoint(wert:string):byte;
   function strtonum(wert:string;istfloat:boolean):double;//string zu Zahl, istfloat=mit Kommastelle

   function encode(s:string):string;  // %20-> ' ' (Space)
   function decode(s:string):string;  // ' '-> %20

   function istint(s:string):boolean; //prüft ob string nur aus int-Zahlen besteht
   function istzahl(s:string):boolean; //prüft ob string nur aus float-Zahlen besteht

   function anzahlzeichen(s,zeichen:string):integer;

   function lastpos(s,zeichen:string):integer; //letzte Postition des übergebenen zeichen ind s

   function mjdtostring(mjd:word):string;  //konvertiert mjd-Datum zu einem String, für EPG

   function czeichenin(stri,welche:string):integer; //zähle die zeichen die mit welche vorgegeben sind


//für zeichenconvertierung
               //Zeichen, HTML,   XML,   beschreibung

type
 pSonderz= ^TSonderz;   //Objekt
 TSonderz=
  record
    char:string;
    html:string;
    unicode:string;
    comment:string;
  end;
  {
type
  //pSonderz= ^TSonderz;
  TSonderz=class(TObject)
    char:string;
    html:string;
    unicode:string;
    comment:string;
  end;
 }
var LsonderzL:TList;

implementation

function czeichenin(stri,welche:string):integer;
var t1,t2,z:integer;
begin
 z:=0;
 for t1:=1 to length(welche) do
  for t2:=1 to length(stri) do
    if( welche[t1]=stri[t2]  ) then inc(z);
 result:=z;
end;

{   ------------ASCII--------------
    $00 Ende des Strings
    $01 start of header
    $02 start of text
    $03 end of text
    $04 end of transmission
    $05 enquiry
    $06 acknowledge
    $07 bell
    $08 backspace
    $09 horizontal tab
    $0a line feed - Zeilenvorschub
    $0b vertical tab
    $0c form feed
    $0d carriage return
    $0e shift out
    $0f shift in
    $10 data link escape
    $11 device control #1
    $12 device control #2
    $13 device control #3
    $14 device control #4
    $15 negative acknowledgement
    $16 synchronous idle
    $17 end of transmission block
    $18 cancel
    $19 end of medium
    $1a substitute
    $1b escape
    $1c file separator
    $1d group separator
    $1e record separator
    $1f unit separator

  }


function mjdtostring(mjd:word):string;
var  d,m,m2,j,j2,k:word;
begin
 //mjd:=$c079;// = 13.10.1993
 j2:=trunc((mjd-15078.2)/365.25);
 m2:=trunc((mjd-14956-trunc(j2*365.25))/30.6001);
 d:=trunc(mjd-14956- trunc(j2*365.25)-trunc(m2*30.6001));
 if((m2=14)or(m2=15))then k:=1 else k:=0;
 j:=j2+k;
 m:=m2-1-k*12;
 if j>100 then j:=j+1900; //0=1900

 result:=inttostr(d)+'.'+inttostr(m)+'.'+inttostr(j); 
end;


function istint(s:string):boolean;
var t:integer;
begin
 result:=true;
 for t:=1 to length(s) do
  if (ord(s[t])<48)or(ord(s[t])>57)then result:=false;
end;

function istzahl(s:string):boolean;
var t:integer;
begin
 result:=true;
 for t:=1 to length(s) do
  if ((ord(s[t])<48)or(ord(s[t])>57))and(ord(s[t])<>46) then result:=false;
end;


//************************* konvertfunktionen **********************************
function NumbToStr(Numb: LongInt; Base: TNumbBase): String;
const NumbDigits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
begin
  Result:=EmptyStr;
  while Numb>0 do begin
    Result:=NumbDigits[(Numb mod Base)+1]+Result;
    Numb:=Numb div Base;
  end;
  if Result=EmptyStr then
    Result:='0';
end; {Christian "NineBerry" Schwarz}

function InttoHexStr(wert:Longint):string; //Longint zu Hexstring
begin
 result:=NumbToStr(wert,16);
 if length(result)<2 then result:='0'+result;
end;

function Hextoint(wert:string):byte;    //wandelt integer zu Hex-String  '$ff'-> 255
var hi,lo:byte;
const NumbDigits = '0123456789abcdef';
begin
 wert:=AnsiLowerCase(wert);
 hi:=pos(wert[2],NumbDigits)-1;if(hi>15)then hi:=15;
 lo:=pos(wert[3],NumbDigits)-1;if(lo>15)then lo:=15;
 result:=hi*16+lo;
end;


function StrHextoInt(wert:string):Int64;
var t:integer;
    c:char;
    r:byte;
begin
result:=0;
 for t:=1 to length(wert) do
 begin
  r:=0;
  c:=wert[length(wert)-t+1];   //lo zuerst
   case c of
    '1':r:=1;
    '2':r:=2;
    '3':r:=3;
    '4':r:=4;
    '5':r:=5;
    '6':r:=6;
    '7':r:=7;
    '8':r:=8;
    '9':r:=9;
    'a','A':r:=10;
    'b','B':r:=11;
    'c','C':r:=12;
    'd','D':r:=13;
    'e','E':r:=14;
    'f','F':r:=15;
   end;
   result:=result+ (r shl(4*(t-1)));
 end;
end;
// **********************Stringoperationen********************************************

function noahref(zeile:string):string;
var ta:integer;
    s1:string;
begin
 while pos('<a',zeile)>0 do
 begin
   ta:=pos('<a',zeile);
   s1:=copy(zeile,1,ta-1);  //vor a

   zeile:=copy(zeile,ta+2,length(zeile));
   ta:=pos('>',zeile);
   if ta=0 then ta:=length(zeile);
   zeile:=s1+copy(zeile,ta+1,length(zeile));

 end;
 zeile:=string_ersetzen(zeile,'</a>','');
 result:=zeile;
end;

function noimg(zeile:string):string;
var ta:integer;
    s1:string;
begin
 while pos('<img',zeile)>0 do
 begin
   ta:=pos('<img',zeile);
   s1:=copy(zeile,1,ta-1);  //vor img

   zeile:=copy(zeile,ta+4,length(zeile));
   ta:=pos('>',zeile);
   zeile:=s1+copy(zeile,ta+1,length(zeile));
 end;
 result:=zeile;
end;

function string_ersetzen(zeile,zeichenq,zeichenz:string):string;
var neustring:string;
    p1:integer;
begin
  result:=zeile;
  if pos(zeichenq,zeile)=0 then exit;
  neustring:='';
  repeat
   p1:=pos(zeichenq,zeile);
   neustring:=neustring+copy(zeile,1,p1-1); //davor
   if p1>0 then
    begin
     neustring:=neustring+zeichenz;  //neues Zeichen
     zeile:=copy(zeile,pos(zeichenq,zeile)+length(zeichenq),length(zeile));
    end
    else
    begin
     neustring:=neustring+zeile;           //rest
     zeile:='';
    end;
  until length(zeile)=0;
  result:=neustring;
end;

function tag_ersetzen(zeile,zeichenq,zeichenz:string):string;
 var s1,s2,s3,s4,s4b,sh:string;
     ta,te:integer;
 begin
  //<script ....>  </script


  s4:='<'+zeichenq;

  while pos(s4,zeile)>0 do //anfangstag
  begin
    ta:=pos(s4,zeile);
   s1:=copy(zeile,1,ta-1); //alle Zeichen vor dem zu filterndem Zeichen
   s2:=zeichenz;
    sh:=copy(zeile,ta+1,length(zeile)); //tag +rest
    te:=pos('>',sh);
   s3:=copy(sh,te+1,length(zeile)); //rest
   zeile:=s1+s2+s3;

   //suche endtag
   s4b:='</'+zeichenq;
   ta:=pos(s4b,zeile);
   if ta>0 then            //endtag
   begin
    s1:=copy(zeile,1,ta-1); //alle Zeichen vor dem zu filterndem Zeichen
    s2:=zeichenz;
     sh:=copy(zeile,ta+1,length(zeile)); //tag +rest
     te:=pos('>',sh);
    s3:=copy(sh,te+1,length(zeile)); //rest
    zeile:=s1+s2+s3;
   end;
  end;

 result:=zeile;
end;


function TextConvertTo(wert:string;zu:string):string; //zu='HTML' oder 'XML', 'qhtml', 'ASCII'
var t:integer;
    theRec:pSonderz;
    sonderzRec:TSonderz;
    wa,wm,we:string;
    re:string;
    z:string;
    goconvert:boolean;
begin
zu:=LowerCase(zu);

if ((zu='html'))then
 for t:=0 to LsonderzL.Count-1 do //alle Zeichen der Tabelle durchgehen
 begin
   // new(sonderzRec);
    theRec:=LsonderzL.Items[t];
    sonderzRec:=theRec^;

   // sonderzRec:=p as TSonderz;

   // showmessage(inttostr(t)+' '+sonderzRec.html);
   // if  sonderzRec.char<>'&' then         // , ohne & da Steuerzeichen im HTML-Code
   // begin
     //if(zu='xml')then h1:=(Pos(sonderzRec.html,wert)>0)else h1:=false;  //auf XML prüfen?

     if(Pos(sonderzRec.char, wert)>0)then // or(h1)
      begin
       if(zu='html')then
           wert:=string_ersetzen(wert,sonderzRec.char,sonderzRec.html);

      { if(zu='xml')then
        begin
         if(Pos(sonderzRec.char, wert)>0)then
           wert:=string_ersetzen(wert,sonderzRec.char,sonderzRec.unicode);//normale zeichen (äöü...)
         if(Pos(sonderzRec.html, wert)>0)then
           wert:=string_ersetzen(wert,sonderzRec.html,sonderzRec.unicode);//normale zeichen (äöü...)
        end; }
      end;
    //end;
 end;

if(zu='xml')then //string xml konform zurückgeben (chars konvertiren)
begin
 re:='';
 for t:=1 to length(wert) do  //string durchgehen
 begin
  z:=wert[t];//ein char
  goconvert:=false;
  {if Ord(z[1])<48 then goconvert:=true;
  if (Ord(z[1])>57) and (Ord(z[1])<56) then goconvert:=true;
  if (Ord(z[1])>90) and (Ord(z[1])<97) then goconvert:=true;  }
  if Ord(z[1])>128 then goconvert:=true;
  if goconvert then z:='%'+InttoHexStr(Ord(z[1]));
  re:=re+z;
 end;
 wert:=re;
end;

if(zu='qhtml')then //HTML Quelltext
 begin
    if(Pos('<', wert)>0) then wert:=string_ersetzen(wert,'<','&lt;');
    if(Pos('>', wert)>0) then wert:=string_ersetzen(wert,'>','&gt;');  //+'<br>'
    if(Pos('&nbsp;', wert)>0) then wert:=string_ersetzen(wert,'&nbsp;','&amp;nbsp;');
  end;

if(zu='ascii')then //ASCII
 begin
   wert:=string_ersetzen(wert,'+',' ');   //keine + , ist Füller für Spaceverkopplung
   {
   wert:=string_ersetzen(wert,'%20',' '); //leerzeichen
   wert:=string_ersetzen(wert,'%2B','+'); //+
   wert:=string_ersetzen(wert,'%3F','?');
   wert:=string_ersetzen(wert,'%2F','/');
   wert:=string_ersetzen(wert,'%3D','=');
   wert:=string_ersetzen(wert,'%26','&');
   wert:=string_ersetzen(wert,'%3A',':');
   }
   //info: %0D=cr /enter %0A=line Feed      /
   while pos('%',wert)>0 do
   begin
    wa:=copy(wert,1,pos('%',wert)-1);
    we:=copy(wert,pos('%',wert)+3,length(wert));
    wm:=copy(wert,pos('%',wert)+1,2);
    wert:=wa+chr(StrHextoInt(wm))+we;
   end;
                                               //The Killers: &#x0022;Bones&#x0022;
     while pos('&#x',wert)>0 do
   begin
    t:=pos('&#x',wert);                                   //The Killers: &#x0022;Bones&#x0022;
    wa:=copy(wert,1,t-1); //erster Teil
    we:=copy(wert,length(wa)+4,length(wert));            //0022;Bones&#x0022;
    t:=pos(';',we);
    wm:=copy(we,1,t-1);
    we:=copy(we,t+1,length(we));
    wert:=wa+chr(StrHextoInt(wm))+we;
   end;

 end;


 result:=wert;
end;




function HTMLtoString(s:string):string; //konvertiert html in ascii
var t:integer;
    vors,nachs,zeichen:string;
    theRec:pSonderz;
    sonderzRec:TSonderz;
begin
     // Lsonderz.length;
for t:=0 to 99 do  //sonderzeichen in Tabelle durchgehen
 begin
  //Application.ProcessMessages;
  theRec:=LsonderzL.Items[t];
  sonderzRec:=theRec^;

  if pos(sonderzRec.html,s)>0 then
   begin
    vors:=copy(s,1, pos(sonderzRec.html,s)-1);
    nachs:=copy(s,pos(sonderzRec.html,s)+length(sonderzRec.html),length(s));
    s:=vors+sonderzRec.char+nachs;
   end;
  if pos(sonderzRec.unicode,s)>0 then
   begin
    vors:=copy(s,1, pos(sonderzRec.unicode,s) );
    nachs:=copy(s,pos(sonderzRec.unicode,s),length(s));
    s:=vors+sonderzRec.char+nachs;
   end;
 end;
 //&#123; nach ascii

 //s nach &#123 durchsuchen
 while pos('&#',s)>0 do
 begin
    vors:=copy(s,1,pos('&#',s)-1);
    nachs:=copy(s,pos(';',s)+1,length(s));
    zeichen:=copy(s ,pos('&#',s)+2, pos(';',s)-pos('&#',s)-2);
    s:=vors+chr(strtoint(zeichen))+nachs;
 end;


result:=s;
end;

function strtonum(wert:string;istfloat:boolean):double;
var sammler:string;
    t,t2,t2e:integer;
const zarr:array[0..11]of char=('0','1','2','3','4','5','6','7','8','9','-',',');
begin
 //. durch , ersetzen
 wert:=string_ersetzen(wert,'.',',');

 sammler:='';
 t2e:=length(zarr);
 for t:=1 to length(wert) do
 begin
  if (pos(',',sammler)>0) then t2e:=length(zarr)-1;
  for t2:=0 to t2e-1 do
   begin
    if wert[t]=zarr[t2] then sammler:=sammler+wert[t];
   end;
 end;
 if length(sammler)=0 then sammler:='0';

 if istfloat=false then sammler:=inttostr(round(strtofloat(sammler)));

 result:=strtofloat(sammler);
end;

// **********************Stringoperationen end
procedure addSZ(zeichen:String;html:String;unicode:String;comment:String);
var newRec:pSonderz;
begin
  New(newRec);
 // pSonderz= ^TSonderz;   //Objekt
  with newRec^ do
  begin
       char:=zeichen;
       html:=html;
       unicode:=unicode;
       comment:=comment;
  end;
// sonderzRec:=TSonderz.create;

  LsonderzL.Add(newRec);
end;

procedure ini;
begin
//sonderzRec:=new(tSonderz);
 addSZ('&','&amp;','&#38;','Ampersand-Zeichen, kaufmännisches Und');
 addSZ('¡','&iexcl;','&#161;','umgekehrtes Ausrufezeichen');
 addSZ('¢','&cent;','&#162;','Cent-Zeichen');
 addSZ('£','&pound;','&#163;','Pfund-Zeichen');
 addSZ('¤','&curren;','&#164;','Währungs-Zeichen');
 addSZ('¥','&yen;','&#165;','Yen-Zeichen');
 addSZ('¦','&brvbar;','&#166;','durchbrochener Strich');
 addSZ('§','&sect;','&#167;','Paragraph-Zeichen');
 addSZ('¨','&uml;','&#168;','Pünktchen oben');
 addSZ('©','&copy;','&#169;','Copyright-Zeichen');
 addSZ('ª','&ordf;','&#170;','Ordinal-Zeichen weiblich');
 addSZ('«','&laquo;','&#171;','angewinkelte Anführungszeichen links');
 addSZ('¬','&not;','&#172;','Verneinungs-Zeichen');
 addSZ('­','&shy;','&#173;','kurzer Trennstrich');
 addSZ('®','&reg;','&#174;','Registriermarke-Zeichen');
 addSZ('¯','&macr;','&#175;','Überstrich');
 addSZ('°','&deg;','&#176;','Grad-Zeichen');
 addSZ('±','&plusmn;','&#177;','Plusminus-Zeichen');
 addSZ('²','&sup2;','&#178;','Hoch-2-Zeichen');
 addSZ('³','&sup3;','&#179;','Hoch-3-Zeichen');
 addSZ('´','&acute;','&#180;','Acute-Zeichen');
 addSZ('µ','&micro;','&#181;','Mikro-Zeichen');
 addSZ('¶','&para;','&#182;','Absatz-Zeichen');
 addSZ('·','&middot;','&#183;','Mittelpunkt');
 addSZ('¸','&cedil;','&#184;','Häkchen unten');
 addSZ('¹','&sup1;','&#185;','Hoch-1-Zeichen');
 addSZ('º','&ordm;','&#186;','Ordinal-Zeichen männlich');
 addSZ('»','&raquo;','&#187;','angewinkelte Anführungszeichen rechts');
 addSZ('¼','&frac14;','&#188;','ein Viertel');
 addSZ('½','&frac12;','&#189;','ein Halb');
 addSZ('¾','&frac34;','&#190;','drei Viertel');
 addSZ('¿','&iquest;','&#191;','umgekehrtes Fragezeichen');
 addSZ('À','&Agrave;','&#192;','A mit Accent grave');
 addSZ('Á','&Aacute;','&#193;','A mit Accent acute');
 addSZ('Â','&Acirc;','&#194;','A mit Circumflex');
 addSZ('Ã','&Atilde;','&#195;','A mit Tilde');
 addSZ('Ä','&Auml;','&#196;','A Umlaut');
 addSZ('Å','&Aring;','&#197;','A mit Ring');
 addSZ('Æ','&AElig;','&#198;','A mit legiertem E');
 addSZ('Ç','&Ccedil;','&#199;','C mit Häkchen');
 addSZ('È','&Egrave;','&#200;','E mit Accent grave');
 addSZ('É','&Eacute;','&#201;','E mit Accent acute');
 addSZ('Ê','&Ecirc;','&#202;','E mit Circumflex');
 addSZ('Ë','&Euml;','&#203;','E Umlaut');
 addSZ('Ì','&Igrave;','&#204;','I mit Accent grave');
 addSZ('Í','&Iacute;','&#205;','I mit Accent acute');
 addSZ('Î','&Icirc;','&#206;','I mit Circumflex');
 addSZ('Ï','&Iuml;','&#207;','I Umlaut');
 addSZ('Ð','&ETH;','&#208;','Eth (isländisch)');
 addSZ('Ñ','&Ntilde;','&#209;','N mit Tilde');
 addSZ('Ò','&Ograve;','&#210;','O mit Accent grave');
 addSZ('Ó','&Oacute;','&#211;','O mit Accent acute');
 addSZ('Ô','&Ocirc;','&#212;','O mit Circumflex');
 addSZ('Õ','&Otilde;','&#213;','O mit Tilde');
 addSZ('Ö','&Ouml;','&#214;','O Umlaut');
 addSZ('×','&times;','&#215;','Mal-Zeichen');
 addSZ('Ø','&Oslash;','&#216;','O mit Schrägstrich');
 addSZ('Ù','&Ugrave;','&#217;','U mit Accent grave');
 addSZ('Ú','&Uacute;','&#218;','U mit Accent acute');
 addSZ('Û','&Ucirc;','&#219;','U mit Circumflex');
 addSZ('Ü','&Uuml;','&#220;','U Umlaut');
 addSZ('Ý','&Yacute;','&#221;','Y mit Accent acute');
 addSZ('Þ','&THORN;','&#222;','THORN (isländisch)');
 addSZ('ß','&szlig;','&#223;','scharfes S');
 addSZ('à','&agrave;','&#224;','a mit Accent grave');
 addSZ('á','&aacute;','&#225;','a mit Accent acute');
 addSZ('â','&acirc;','&#226;','a mit Circumflex');
 addSZ('ã','&atilde;','&#227;','a mit Tilde');
 addSZ('ä','&auml;','&#228;','a Umlaut');
 addSZ('å','&aring;','&#229;','a mit Ring');
 addSZ('æ','&aelig;','&#230;','a mit legiertem e');
 addSZ('ç','&ccedil;','&#231;','c mit Häkchen');
 addSZ('è','&egrave;','&#232;','e mit Accent grave');
 addSZ('é','&eacute;','&#233;','e mit Accent acute');
 addSZ('ê','&ecirc;','&#234;','e mit Circumflex');
 addSZ('ë','&euml;','&#235;','e Umlaut');
 addSZ('ì','&igrave;','&#236;','i mit Accent grave');
 addSZ('í','&iacute;','&#237;','i mit Accent acute');
 addSZ('î','&icirc;','&#238;','i mit Circumflex');
 addSZ('ï','&iuml;','&#239;','i Umlaut');
 addSZ('ð','&eth;','&#240;','eth (isländisch)');
 addSZ('ñ','&ntilde;','&#241;','n mit Tilde');
 addSZ('ò','&ograve;','&#242;','o mit Accent grave');
 addSZ('ó','&oacute;','&#243;','o mit Accent acute');
 addSZ('ô','&ocirc;','&#244;','o mit Circumflex');
 addSZ('õ','&otilde;','&#245;','o mit Tilde');
 addSZ('ö','&ouml;','&#246;','o Umlaut');
 addSZ('÷','&divide;','&#247;','Divisions-Zeichen');
 addSZ('ø','&oslash;','&#248;','o mit Schrägstrich');
 addSZ('ù','&ugrave;','&#249;','u mit Accent grave');
 addSZ('ú','&uacute;','&#250;','u mit Accent acute');
 addSZ('û','&ucirc;','&#251;','u mit Circumflex');
 addSZ('ü','&uuml;','&#252;','u Umlaut');
 addSZ('ý','&yacute;','&#253;','y mit Accent acute');
 addSZ('þ','&thorn;','&#254;','thorn (isländisch)');
 addSZ('ÿ','&yuml;','&#255;','y Umlaut');
 addSZ('"','&quot;','','quot');
 addSZ('<','&lt;','','kleiner als');
 addSZ('>','&gt;','','größer als');

{
New(sonderzRec);
 sonderzRec.char:=chr(13);
 sonderzRec.html:='<br>';
 sonderzRec.unicode:='';
 sonderzRec.comment:='größer als';
LsonderzL.Add(sonderzRec);

  for t:=1 to length(info)-1 do
  begin
   if((ord(info[t])>$2f)and(ord(info[t])<$ff))then ci.allclientinfo:=ci.allclientinfo+info[t]
    else
     if(ord(info[t])>$1f)then ci.allclientinfo:=ci.allclientinfo+'&#'+inttostr(ord(info[t]))+';';
   if(ord(info[t])=13)then ci.allclientinfo:=ci.allclientinfo+'<br>'+chr(13)+chr(10);
  end;

}



end;


function encode(s:string):string;
var t:integer;
    tmp:string;
begin
 for t:=0 to 255 do
  begin
   tmp:= NumbToStr(t,16);
   if length(tmp)<2 then tmp:='0'+tmp;
   s:=string_ersetzen(s,'%'+tmp,chr(t));
  end;
 result:=s;
end;

function decode(s:string):string;
var t:integer;
    tmp:string;
    h:string;
begin
 tmp:='';
 for t:=1 to length(s) do
  begin
   h:=s[t];
   if(ord(s[t])<33)or(ord(s[t])>126)then
    begin
     h:=InttoHexStr(ord(s[t]));
     if length(h)<2 then h:='0'+h;
     h:='%'+h;
    end;
   tmp:=tmp+h;
  end;
 result:=tmp;
end;


function anzahlzeichen(s,zeichen:string):integer;
var temp:string;
begin
 result:=0;
 temp:=s;
 if pos(zeichen,temp)>0 then
 begin
  while pos(zeichen,temp)>0 do
  begin
   inc(result);
   temp:=copy(temp,pos(zeichen,temp)+length(zeichen),length(temp)) ;
  end;
 end;
end;

function lastpos(s,zeichen:string):integer; //letzte Postition des übergebenen zeichen ind s
var temp:string;
begin
 temp:=s;
 result:=0; //nicht gefunden
 while pos(zeichen,temp)>0 do
 begin
  result:=result+pos(zeichen,temp);
  temp:=copy(temp,pos(zeichen,temp)+1,length(temp));
 end;

end;

initialization
 LsonderzL:= TList.Create;
// LsonderzL.ownsobjects:=true;
 ini;


finalization
 LsonderzL.Free;
 
end.
