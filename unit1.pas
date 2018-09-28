unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids, Buttons, ComCtrls, Menus
  ,myini
  ,myDateiio
  ,myString
  ;

 {
  Compileroptimierung für kleine.exe:

  Projekt->Projekteinstellungen:
     ->Compilereinstellungern
       ->Debuggen
           []Debugger-Informationen für GDB erzeugen: ausschalten
 }



type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonAddMemo: TButton;
    ButtonQuellen: TBitBtn;
    Buttongetstartdatei: TBitBtn;
    ButtonInfoNeu: TButton;
    ButtonInfoLaden: TButton;
    ButtonInfoSpeichern: TButton;
    ButtonMake: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    LabelQuellpfad: TLabel;
    LabelFisrtdatei: TLabel;
    LStatus: TLabel;
    EditFilter: TLabeledEdit;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    laden2: TMenuItem;
    f2: TMenuItem;
    f3: TMenuItem;
    f4: TMenuItem;
    f5: TMenuItem;
    Quellordner1: TMenuItem;
    neu2: TMenuItem;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    speichern2: TMenuItem;
    Projekt: TMenuItem;
    f1: TMenuItem;
    zielundquellen1: TMenuItem;
    Infodaten1: TMenuItem;
    neu1: TMenuItem;
    laden1: TMenuItem;
    speichern1: TMenuItem;
    MenuItem7: TMenuItem;
    beenden1: TMenuItem;
    N2: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel5: TPanel;
    ProgressBar1: TProgressBar;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    StaticText1: TStaticText;
    StringGridInfo: TStringGrid;
    procedure beenden1Click(Sender: TObject);
    procedure ButtonAddMemoClick(Sender: TObject);
    procedure ButtongetstartdateiClick(Sender: TObject);
    procedure ButtonInfoLadenClick(Sender: TObject);
    procedure ButtonInfoNeuClick(Sender: TObject);
    procedure ButtonInfoSpeichernClick(Sender: TObject);
    procedure ButtonMakeClick(Sender: TObject);
    procedure ButtonQuellenClick(Sender: TObject);
    procedure EditFilterChange(Sender: TObject);
    procedure f1Click(Sender: TObject);
    procedure f2Click(Sender: TObject);
    procedure f3Click(Sender: TObject);
    procedure f4Click(Sender: TObject);
    procedure f5Click(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure laden1Click(Sender: TObject);
    procedure laden2Click(Sender: TObject);
    procedure neu2Click(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure speichern1Click(Sender: TObject);
    procedure speichern2Click(Sender: TObject);
    procedure zielundquellen1Click(Sender: TObject);
    procedure neu1Click(Sender: TObject);
  private
    { private declarations }
    procedure setmakebutt;
    procedure newInfodata;
    procedure loadInfodaten(quelle:string);
    procedure saveInfodaten;
    procedure newProjekt;
    procedure loadProjekt(datei:string);
    procedure saveProjekt;
    procedure create_scormdata;
    procedure create_ImsManifest;
    procedure create_adlcp_rootv1p2;
    procedure create_ims_xml;
    procedure create_imscp_rootv1p1p2;
    procedure create_imsmd_rootv1p2p1;
    procedure create_sco_data;
    procedure create_projekt;


  public
    { public declarations }
  end;

var
  Form1: TForm1;
  quellPfad:string;   //wo sind die Quelldaten
  erstedatei:string;  //welche Datei ist die erste die gestartet werden soll?
  istQuellPfad :boolean=false;
  isterstedatei:boolean=false;

  infodateipfad:string;
  projektdateipfad:string;
  filter:string;

  vorlagenpfad:string;

  dateiliste:TStringList;

  ProgammINI:String;

implementation

{$R *.lfm}
var merkeprojekteDateien:array[1..5]of string;

{ TForm1 }



procedure TForm1.FormShow(Sender: TObject);
var temp,temp2:string;
    t,anz,p:integer;
begin
  //ini



  //letzten Projekte auflisten
   dateiliste.Clear;
   temp:=ExtractFilePath(Application.ExeName);
   //quellPfad:=ExtractFilePath(Application.ExeName);

   lesedateienein(temp,'',dateiliste,true);
   anz:=0;
  if dateiliste.Count>-1 then
   begin
    for t:=0 to dateiliste.count-1 do
           begin
             temp2:=dateiliste.Strings[t];
             if pos('.prj',temp2)>0 then
             begin
              inc(anz);
              if (anz>0)and(anz<6) then merkeprojekteDateien[anz]:=temp+temp2;

               p:=lastpos(temp2,'\');
               temp2:=copy(temp2,p+1,length(temp2));


              case anz of
               1: begin f1.Caption:=temp2; f1.Visible:=true; end;
               2: begin f2.Caption:=temp2; f2.Visible:=true; end;
               3: begin f3.Caption:=temp2; f3.Visible:=true; end;
               4: begin f4.Caption:=temp2; f4.Visible:=true; end;
               5: begin f5.Caption:=temp2; f5.Visible:=true; end;
              end;

             end;
             if anz>0 then N2.Visible:=true;

           end;

   end;
   dateiliste.Clear;
   LabelFisrtdatei.Caption:='Es wurde noch keine start-Datei ausgewählt.';
   newProjekt;
 end;






procedure TForm1.laden1Click(Sender: TObject);
begin
  loadProjekt('');
end;

procedure TForm1.f1Click(Sender: TObject);
begin
  loadProjekt(merkeprojekteDateien[1]);
end;

procedure TForm1.beenden1Click(Sender: TObject);
begin
  form1.Close;
end;

procedure TForm1.ButtonAddMemoClick(Sender: TObject);
var t:integer;
    kw:String;
begin
  Memo1.Clear;
  lesedateienein(quellPfad,filter,dateiliste,true);    //liest Dateinamen in TStringList (dateiliste) ein
  if dateiliste.Count>-1 then
   begin
    for t:=0 to dateiliste.count-1 do
            begin
              kw:=string_ersetzen(dateiliste.Strings[t],'\','/');
              Memo1.Lines.Add('            <file href="'+kw+'"/>');
            end;
   end;
end;



procedure TForm1.ButtongetstartdateiClick(Sender: TObject);
begin
 OpenDialog1.FileName:='';
 OpenDialog1.Filter:='';
 OpenDialog1.InitialDir:=quellPfad;
 if OpenDialog1.Execute then  //im ini-format
  begin
   erstedatei:=OpenDialog1.Files[0];//ExtractFileName(OpenDialog1.FileName);
   //relativ im Datenpfad!
   erstedatei:=copy(erstedatei,length(quellPfad)+1,length(erstedatei));

   if dateida(quellPfad+erstedatei)then
   begin
    LabelFisrtdatei.Caption:=erstedatei;
    isterstedatei:=true;
    setmakebutt;
   end
   else
   begin
    isterstedatei:=false;
    setmakebutt;
    showmessage('Datei nicht erreichbar,'+chr(13)+'die Datei muß im Ordner mit den Daten liegen');
   end;
  end;

end;

procedure TForm1.ButtonInfoLadenClick(Sender: TObject);
begin
 OpenDialog1.FileName:='infodata.info';
 OpenDialog1.Filter:='Infodatendatei (*.info)|*.info|Alle Dateien (*.*)|*.*';
 OpenDialog1.FileName:='';
 OpenDialog1.InitialDir:=infodateipfad;
 if OpenDialog1.Execute then  //im ini-format
  begin
   loadInfodaten(OpenDialog1.FileName);
  end;

end;

procedure TForm1.ButtonInfoNeuClick(Sender: TObject);
begin
 newInfodata;
end;

procedure TForm1.ButtonInfoSpeichernClick(Sender: TObject);
begin
 saveInfodaten;
end;

procedure TForm1.ButtonMakeClick(Sender: TObject);
begin
 ProgressBar1.Position:=5;
 lesedateienein(quellPfad,filter,dateiliste,true);    //liest Dateinamen in TStringList (dateiliste) ein
 ProgressBar1.Position:=10;
 create_scormdata;
 showmessage('Dateien wurden erzeugt.');
 ProgressBar1.Position:=0;
end;

procedure TForm1.ButtonQuellenClick(Sender: TObject);
begin
LStatus.Caption:='Quellordner wählen.';
LStatus.Refresh;

SelectDirectoryDialog1.InitialDir:=quellPfad;
if(SelectDirectoryDialog1.Execute)then
 begin
    quellPfad:=SelectDirectoryDialog1.FileName+'\';
    LabelQuellpfad.Caption:=quellPfad;
    istQuellPfad:=true;
    setmakebutt;

    LStatus.Caption:='Wählen Sie die Startdatei.';

    ButtonAddMemo.Enabled:=true;
 end;
end;

procedure TForm1.EditFilterChange(Sender: TObject);
begin
  filter:=EditFilter.Text;
end;

procedure TForm1.f2Click(Sender: TObject);
begin
  loadProjekt(merkeprojekteDateien[2]);
end;

procedure TForm1.f3Click(Sender: TObject);
begin
  loadProjekt(merkeprojekteDateien[3]);
end;

procedure TForm1.f4Click(Sender: TObject);
begin
  loadProjekt(merkeprojekteDateien[4]);
end;

procedure TForm1.f5Click(Sender: TObject);
begin
  loadProjekt(merkeprojekteDateien[5]);
end;

procedure TForm1.FormClose(Sender: TObject);
begin

 writeINIstring(ProgammINI,'prg','lastQuelle',quellPfad);
 writeINIstring(ProgammINI,'prg','Vorlagen',vorlagenpfad);
 writeINIstring(ProgammINI,'prg','Infodaten',infodateipfad);
 writeINIstring(ProgammINI,'prg','Filter',filter);

 writeINIint(ProgammINI,'prg','width',Form1.Width);
 writeINIint(ProgammINI,'prg','height',Form1.Height);
 {writeINIint(ProgammINI,'prg','left',Form1.Left);
 writeINIint(ProgammINI,'prg','top',Form1.Top);
  }
end;

procedure TForm1.FormCreate(Sender: TObject);
var tempi:integer;
begin
  //ProgammINI
 if dateida(ProgammINI) then
 begin
  quellPfad:=readINIstring(ProgammINI,'prg','lastQuelle');
  vorlagenpfad:=readINIstring(ProgammINI,'prg','Vorlagen');
  infodateipfad:=readINIstring(ProgammINI,'prg','Infodaten');
  filter:=readINIstring(ProgammINI,'prg','Filter');

  EditFilter.Text:=filter;
  LabelQuellpfad.Caption:=quellPfad;

  tempi:=readINIint(ProgammINI,'prg','width');
  if tempi>0 then Form1.Width:=tempi;
  tempi:=readINIint(ProgammINI,'prg','height');
  if tempi>0 then Form1.Height:=tempi;
  {tempi:=readINIint(ProgammINI,'prg','left');
  if tempi>0 then Form1.Left:=tempi;
  tempi:=readINIint(ProgammINI,'prg','top');
  if tempi>0 then Form1.Top:=tempi;
        }
  Memo1.Clear();
  EditFilter.EditLabel.Caption:='';
  end;
end;

procedure TForm1.laden2Click(Sender: TObject);
begin
 OpenDialog1.FileName:='infodata.info';
 OpenDialog1.Filter:='Infodatendatei (*.info)|*.info|Alle Dateien (*.*)|*.*';
 OpenDialog1.FileName:=infodateipfad;
 if OpenDialog1.Execute then  //im ini-format
  begin
   loadInfodaten(OpenDialog1.FileName);
  end;
end;

procedure TForm1.loadInfodaten(quelle:string);
begin
  infodateipfad:=quelle;
  GroupBox1.Caption:='Infodaten ('+infodateipfad+')';
  newInfodata;//inhalt löschen
  StringGridInfo.Cells[1,1]:=readINIstring(infodateipfad,'Daten','Sprache');     //Sprache
  StringGridInfo.Cells[1,2]:=readINIstring(infodateipfad,'Daten','Titel');       //Titel
  StringGridInfo.Cells[1,3]:=readINIstring(infodateipfad,'Daten','Beschreibung');//Beschreibung
  StringGridInfo.Cells[1,4]:=readINIstring(infodateipfad,'Daten','Keyword');     //Keyword

  LStatus.Caption:='Infodaten geladen';
end;



procedure TForm1.speichern1Click(Sender: TObject);
begin
 saveProjekt;
end;

procedure TForm1.speichern2Click(Sender: TObject);
begin
  saveInfodaten;
end;
procedure TForm1.saveInfodaten;
begin
 SaveDialog1.FileName:='infodata.info';
 SaveDialog1.Filter:='Infodatendatei (*.info)|*.info|Alle Dateien (*.*)|*.*';
 SaveDialog1.FileName:=infodateipfad;
if SaveDialog1.Execute then
 begin
  infodateipfad:=SaveDialog1.FileName;
  if pos('.info',infodateipfad)=0 then infodateipfad:=infodateipfad+'.info';

  GroupBox1.Caption:='Infodaten ('+infodateipfad+')';
  writeINIstring(infodateipfad,'Daten','Sprache',StringGridInfo.Cells[1,1]);     //Sprache
  writeINIstring(infodateipfad,'Daten','Titel',StringGridInfo.Cells[1,2]);       //Titel
  writeINIstring(infodateipfad,'Daten','Beschreibung',StringGridInfo.Cells[1,3]);//Beschreibung
  writeINIstring(infodateipfad,'Daten','Keyword',StringGridInfo.Cells[1,4]);     //Keyword

   LStatus.Caption:='Infodaten gespeichert.';
 end;
end;


procedure TForm1.zielundquellen1Click(Sender: TObject);
begin

end;

procedure TForm1.neu1Click(Sender: TObject);
begin
  newProjekt;
end;

procedure TForm1.newProjekt;
begin
 LabelQuellpfad.Caption:='Es wurde noch kein Ordner ausgewählt.';
 istQuellPfad:=false;
 isterstedatei :=false;
 //quellPfad   :=ExtractFilePath(Application.ExeName);

 setmakebutt;

 StringGridInfo.ColWidths[0]:=100;
 StringGridInfo.ColWidths[1]:=StringGridInfo.Width-100-10;
 StringGridInfo.RowHeights[0]:=20;
 StringGridInfo.Cells[0,0]:='Typ';
 StringGridInfo.Cells[1,0]:='Daten';
 newInfodata;

 OpenDialog1.InitialDir:=ExtractFilePath(Application.ExeName);
 SaveDialog1.InitialDir:=ExtractFilePath(Application.ExeName);

 //filter:='.psd, .scc';

 projektdateipfad:='';
 infodateipfad:='';

 infodateipfad:=ExtractFilePath(Application.ExeName);

 LStatus.Caption:='Wählen Sie Ordner mit den Daten.';
end;

procedure TForm1.loadProjekt(datei:string);
var istladen:boolean;
    projektdatei:string;
begin
 istladen:=false;
 if length(datei)=0 then
 begin
  OpenDialog1.Filter:='Projekt (*.prj)|*.prj|Alle Dateien (*.*)|*.*';
  OpenDialog1.InitialDir:=projektdateipfad;
  if OpenDialog1.Execute then istladen:=true; //im ini-format
  projektdatei:=OpenDialog1.FileName;
 end
 else
  if dateida(datei)then
  begin
   projektdatei:=datei;
   istladen:=true;
  end;


 if istladen then  //im ini-format
  begin
   projektdateipfad:=projektdatei;

   quellPfad:=readINIstring(projektdateipfad,'data','quellOrdner');
   if length(quellPfad)=0 then
    begin
     LabelQuellpfad.Caption:='Es wurde noch kein Ordner ausgewählt.';
     istQuellPfad:=false;
    end
    else
    begin
     LabelQuellpfad.Caption:=quellPfad;
     istQuellPfad:=true;
     ButtonAddMemo.Enabled:=true;
    end;

   erstedatei:=readINIstring(projektdateipfad,'data','erstedatei');
   if length(erstedatei)=0 then
    begin
     LabelFisrtdatei.Caption:='Es wurde noch keine start-Datei ausgewählt.';
     isterstedatei:=false;
    end
    else
    begin
     LabelFisrtdatei.Caption:=erstedatei;
     isterstedatei:=true;
    end;


    filter:=readINIstring(projektdateipfad,'data','Filter');
    EditFilter.Text:=filter;
    infodateipfad:=  readINIstring(projektdateipfad,'data','infodateipfad');

    //---------------
    loadInfodaten(infodateipfad);

    setmakebutt;

    LStatus.Caption:='Projekt geladen.';
  end;
end;


procedure TForm1.saveProjekt;
begin
 SaveDialog1.FileName:=projektdateipfad;
 SaveDialog1.Filter:='Infodatendatei (*.prj)|*.prj|Alle Dateien (*.*)|*.*';
 SaveDialog1.FileName:=projektdateipfad;
 if SaveDialog1.Execute then
  begin
   projektdateipfad:=SaveDialog1.FileName;
   if pos('.prj',projektdateipfad)=0 then projektdateipfad:=projektdateipfad+'.prj';

   writeINIstring(projektdateipfad,'data','quellOrdner',quellPfad);
   writeINIstring(projektdateipfad,'data','erstedatei',erstedatei);
   writeINIstring(projektdateipfad,'data','Filter'     ,filter);
   writeINIstring(projektdateipfad,'data','infodateipfad',infodateipfad);


   LStatus.Caption:='Projekt gespeichert.';
  end;
end;

procedure TForm1.setmakebutt;
begin
 ButtonMake.Enabled:=istQuellPfad and isterstedatei;

 Buttongetstartdatei.Enabled:=istQuellPfad;

 if ButtonMake.Enabled then
  Panel5.Color:=clGreen
  else
  Panel5.Color:=clBtnFace;

end;

procedure TForm1.neu2Click(Sender: TObject);
begin
  newInfodata;
end;

procedure TForm1.Panel1Click(Sender: TObject);
begin

end;

procedure TForm1.Panel1Resize(Sender: TObject);
begin

end;

procedure TForm1.newInfodata;  //leerer Datensatz
begin
 StringGridInfo.RowCount:=2;
 StringGridInfo.Cells[0,StringGridInfo.RowCount-1]:='Sprache';
 StringGridInfo.Cells[1,StringGridInfo.RowCount-1]:='de';

 StringGridInfo.RowCount:=StringGridInfo.RowCount+1;
 StringGridInfo.Cells[0,StringGridInfo.RowCount-1]:='Titel';
 StringGridInfo.Cells[1,StringGridInfo.RowCount-1]:='';

 StringGridInfo.RowCount:=StringGridInfo.RowCount+1;
 StringGridInfo.Cells[0,StringGridInfo.RowCount-1]:='Beschreibung';
 StringGridInfo.Cells[1,StringGridInfo.RowCount-1]:='';

 StringGridInfo.RowCount:=StringGridInfo.RowCount+1;
 StringGridInfo.Cells[0,StringGridInfo.RowCount-1]:='Keyword(s)';
 StringGridInfo.Cells[1,StringGridInfo.RowCount-1]:='';
end;



procedure TForm1.create_scormdata;
begin
 //erzeuge:
   ProgressBar1.Position:=30;ProgressBar1.Refresh;
   if CheckBox1.Checked then begin
    LStatus.Caption:='erzeuge imsmanifest.xml';
    Panel1.Refresh;
    create_ImsManifest;
   end;
   ProgressBar1.Position:=40;ProgressBar1.Refresh;


   if CheckBox2.Checked then begin
    create_imscp_rootv1p1p2;
    LStatus.Caption:='erzeuge imscp_rootv1p1p2.xsd';
    Panel1.Refresh;
   end;
   ProgressBar1.Position:=50;ProgressBar1.Refresh;

   if CheckBox3.Checked then begin
    create_imsmd_rootv1p2p1;
    LStatus.Caption:='erzeuge imsmd_rootv1p2p1.xsd';
    Panel1.Refresh;
   end;
   ProgressBar1.Position:=60;ProgressBar1.Refresh;


   if CheckBox4.Checked then begin
    create_adlcp_rootv1p2;
    LStatus.Caption:='erzeuge adlcp_rootv1p2.xsd';
    Panel1.Refresh;
   end;
   ProgressBar1.Position:=70;ProgressBar1.Refresh;

   if CheckBox5.Checked then begin
    create_ims_xml;
    LStatus.Caption:='erzeuge ims_xml.xsd';
    Panel1.Refresh;
   end;
   ProgressBar1.Position:=80;ProgressBar1.Refresh;
{
   LStatus.Caption:='erzeuge sco_meta.xml';Panel1.Refresh;  // +StringGridInfo.Cells[1,2]+

   if CheckBox6.Checked then create_sco_data;
   ProgressBar1.Position:=90;ProgressBar1.Refresh;
    LStatus.Caption:='erzeuge kurs.xml';Panel1.Refresh;    //+StringGridInfo.Cells[1,2]+
   if CheckBox7.Checked then create_projekt;  }

   ProgressBar1.Position:=100;ProgressBar1.Refresh;
   LStatus.Caption:='ready.';
end;

procedure TForm1.create_ImsManifest;
var vorlagedatei,F:TextFile;
      vlink,zeile:string;
      keywords,kw:string;
      t:integer;
begin
    vlink:=vorlagenpfad+'imsmanifest.xml';
    if dateida(vlink)then
    begin

      AssignFile(vorlagedatei, vlink);
      Reset(vorlagedatei);

      AssignFile(F, quellPfad+'imsmanifest.xml');
      rewrite(F);

      while not Eof(vorlagedatei) do
       begin
        Readln(vorlagedatei, zeile);

        if pos('[datum]',zeile)>0 then
             zeile:=string_ersetzen(zeile,'[datum]',DateToStr(Date));

       { if pos('[metadata.xml]',zeile)>0 then
           if CheckBox7.Checked then
              zeile:=string_ersetzen(zeile,'[metadata.xml]','<adlcp:location>kurs.xml</adlcp:location>')
             else
              zeile:=string_ersetzen(zeile,'[metadata.xml]','');
        }
        if pos('[sprache]',zeile)>0 then
             zeile:=string_ersetzen(zeile,'[sprache]',TextConvertTo(StringGridInfo.Cells[1,1],'XML'));

        if pos('[keyword]',zeile)>0 then
             zeile:=string_ersetzen(zeile,'[keyword]',TextConvertTo(StringGridInfo.Cells[1,4],'XML'));


        if pos('[titel]',zeile)>0 then
             zeile:=string_ersetzen(zeile,'[titel]',TextConvertTo(StringGridInfo.Cells[1,2],'XML'));

        if pos('[Beschreibung]',zeile)>0 then            //<imsmd:langstring xml:lang="de">[Beschreibung]</imsmd:langstring>
             zeile:=string_ersetzen(zeile,'[Beschreibung]',TextConvertTo(StringGridInfo.Cells[1,3],'XML'));


        if pos('[imsmd:keyword]',zeile)>0 then
           begin
            keywords:=StringGridInfo.Cells[1,4];
            while pos(',',keywords)>0 do
            begin

             kw:=copy(keywords,1,pos(',',keywords)-1);
             writeln(f,'            <imsmd:keyword>');
             writeln(f,'                <imsmd:langstring xml:lang="de">'+TextConvertTo(kw,'XML')+'</imsmd:langstring>');
             writeln(f,'            </imsmd:keyword>');
             keywords:=copy(keywords,pos(',',keywords)+1,length(keywords));
            end;
            if length(keywords)>0 then
            begin
             writeln(f,'            <imsmd:keyword>');
             writeln(f,'                <imsmd:langstring xml:lang="de">'+TextConvertTo(keywords,'XML')+'</imsmd:langstring>');
             writeln(f,'            </imsmd:keyword>');
            end;
            zeile:='';
           end;

        if pos('[startdatei]',zeile)>0 then
          begin
             zeile:=string_ersetzen(zeile,'[startdatei]',string_ersetzen(erstedatei,'\','/'));
          end;

        if pos('[dateien]',zeile)>0 then
           begin
            for t:=0 to dateiliste.count-1 do
            begin
              kw:=string_ersetzen(dateiliste.Strings[t],'\','/');
              writeln(f,'            <file href="'+kw+'"/>');
            end;
             if CheckBox1.Checked then  writeln(f,'           <file href="imsmanifest.xml"/>');
             if CheckBox2.Checked then  writeln(f,'           <file href="adlcp_rootv1p2.xsd"/>');
             if CheckBox3.Checked then  writeln(f,'           <file href="ims_xml.xsd"/>');
             if CheckBox4.Checked then  writeln(f,'           <file href="imscp_rootv1p1p2.xsd"/>');
             if CheckBox5.Checked then  writeln(f,'           <file href="imsmd_rootv1p2p1.xsd"/>');
             //if CheckBox6.Checked then  writeln(f,'           <file href="kurs.xml"/>');
             //if CheckBox7.Checked then  writeln(f,'           <file href="sco.xml"/>');
            zeile:='';
           end;

        //write zeile
        if length(zeile)>0 then writeln(f,zeile);
       end;
      CloseFile(F);
      CloseFile(vorlagedatei);
    end
    else
     showmessage('Die Vorlagen "imsmanifest.xml" konnten nicht gefunden werden.');
end;

procedure TForm1.create_adlcp_rootv1p2;
begin

end;

procedure TForm1.create_ims_xml;
var vorlagedatei,F:TextFile;
    vlink,zeile:string;
begin
 vlink:=vorlagenpfad+'ims_xml.xsd';
 if dateida(vlink)then
 begin
   AssignFile(vorlagedatei, vlink);
   Reset(vorlagedatei);

   AssignFile(F, quellPfad+'ims_xml.xsd');
   rewrite(F);
   while not Eof(vorlagedatei) do
    begin
     Readln(vorlagedatei, zeile);
     //if length(zeile)>0 then
     writeln(f,zeile);
    end;
   CloseFile(F);
   CloseFile(vorlagedatei);
 end
 else
  showmessage('Die Vorlagen "ims_xml.xsd" konnten nicht gefunden werden.');
end;

procedure TForm1.create_imscp_rootv1p1p2;
var vorlagedatei,F:TextFile;
    vlink,zeile:string;
begin
 vlink:=vorlagenpfad+'imscp_rootv1p1p2.xsd';
 if dateida(vlink)then
 begin
   AssignFile(vorlagedatei, vlink);
   Reset(vorlagedatei);

   AssignFile(F, quellPfad+'imscp_rootv1p1p2.xsd');
   rewrite(F);
   while not Eof(vorlagedatei) do
    begin
     Readln(vorlagedatei, zeile);
     //if length(zeile)>0 then
     writeln(f,zeile);
    end;
   CloseFile(F);
   CloseFile(vorlagedatei);
 end
 else
  showmessage('Die Vorlagen "imscp_rootv1p1p2.xsd" konnten nicht gefunden werden.');
end;

procedure TForm1.create_imsmd_rootv1p2p1;
var vorlagedatei,F:TextFile;
    vlink,zeile:string;
begin
 vlink:=vorlagenpfad+'imsmd_rootv1p2p1.xsd';
 if dateida(vlink)then
 begin
   AssignFile(vorlagedatei, vlink);
   Reset(vorlagedatei);

   AssignFile(F, quellPfad+'imsmd_rootv1p2p1.xsd');
   rewrite(F);
   while not Eof(vorlagedatei) do
    begin
     Readln(vorlagedatei, zeile);
     //if length(zeile)>0 then
     writeln(f,zeile);
    end;
   CloseFile(F);
   CloseFile(vorlagedatei);

 end
 else
  showmessage('Die Vorlagen "imsmd_rootv1p2p1.xsd" konnten nicht gefunden werden.');
end;

procedure TForm1.create_sco_data;
var vorlagedatei,F:TextFile;
    vlink,zeile:string;
begin
 vlink:=vorlagenpfad+'sco_.xml';
 if dateida(vlink)then
 begin
   AssignFile(vorlagedatei, vlink);
   Reset(vorlagedatei);

   AssignFile(F, quellPfad+'sco.xml'); //StringGridInfo.Cells[1,2]
   rewrite(F);

   while not Eof(vorlagedatei) do
    begin
      Readln(vorlagedatei, zeile);
     if pos('[datum]',zeile)>0 then zeile:=string_ersetzen(zeile,'[datum]',DateToStr(Date));

     if pos('[sprache]',zeile)>0 then
          zeile:=string_ersetzen(zeile,'[sprache]',TextConvertTo(StringGridInfo.Cells[1,1],'XML'));

     if pos('[keyword]',zeile)>0 then
          zeile:=string_ersetzen(zeile,'[keyword]',TextConvertTo(StringGridInfo.Cells[1,4],'XML'));


     if pos('[titel]',zeile)>0 then
          zeile:=string_ersetzen(zeile,'[titel]',TextConvertTo(StringGridInfo.Cells[1,2],'XML'));

     if pos('[Beschreibung]',zeile)>0 then
          zeile:=string_ersetzen(zeile,'[Beschreibung]',TextConvertTo(StringGridInfo.Cells[1,3],'XML'));


     if pos('[startdatei]',zeile)>0 then
          zeile:=string_ersetzen(zeile,'[startdatei]',string_ersetzen(erstedatei,'\','/'));


     //write zeile
     if length(zeile)>0 then writeln(f,zeile);
    end;
   CloseFile(F);
   CloseFile(vorlagedatei);
 end
 else
  showmessage('Die Vorlagen "sco.xml" konnten nicht gefunden werden.');
end;

procedure TForm1.create_projekt;
var vorlagedatei,F:TextFile;
    vlink,zeile:string;
begin
 vlink:=vorlagenpfad+'projekt.xml';
 if dateida(vlink)then
 begin
   AssignFile(vorlagedatei, vlink);
   Reset(vorlagedatei);

   AssignFile(F, quellPfad+'kurs.xml');     //StringGridInfo.Cells[1,2]
   rewrite(F);

   while not Eof(vorlagedatei) do
    begin
     Readln(vorlagedatei, zeile);
     if pos('[datum]',zeile)>0 then
          zeile:=string_ersetzen(zeile,'[datum]',DateToStr(Date));


     if pos('[sprache]',zeile)>0 then
          zeile:=string_ersetzen(zeile,'[sprache]',TextConvertTo(StringGridInfo.Cells[1,1],'XML'));

     if pos('[keyword]',zeile)>0 then
          zeile:=string_ersetzen(zeile,'[keyword]',TextConvertTo(StringGridInfo.Cells[1,4],'XML'));


     if pos('[titel]',zeile)>0 then
          zeile:=string_ersetzen(zeile,'[titel]',TextConvertTo(StringGridInfo.Cells[1,2],'XML'));

     if pos('[Beschreibung]',zeile)>0 then
          zeile:=string_ersetzen(zeile,'[Beschreibung]',TextConvertTo(StringGridInfo.Cells[1,3],'XML'));


     if pos('[startdatei]',zeile)>0 then
          zeile:=string_ersetzen(zeile,'[startdatei]',string_ersetzen(erstedatei,'\','/'));


     //write zeile
     if length(zeile)>0 then writeln(f,zeile);
    end;
   CloseFile(F);
   CloseFile(vorlagedatei);
 end
 else
  showmessage('Die Vorlagen "projekt.xml" konnten nicht gefunden werden.');
end;

initialization
quellPfad:=ExtractFilePath(Application.ExeName);
ProgammINI:=ExtractFilePath(Application.ExeName)+'makeSCORM.ini';
vorlagenpfad:=ExtractFilePath(Application.ExeName)+'vorlagen\';
infodateipfad:=ExtractFilePath(Application.ExeName);
dateiliste:= TStringList.Create;


finalization

dateiliste.Free;

end.

