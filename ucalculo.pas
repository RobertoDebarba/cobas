{ <description>

  Copyright (C) <2013> <Jonathan Eli Suptitz, Roberto Luiz Debarba> <jonny.suptitz@gmail.com, roberto.debarba@gmail.com>

  Este arquivo é parte do programa COBAS.

  COBAS é um software livre; você pode redistribuir e/ou modificá-los
  sob os termos da GNU Library General Public License como publicada pela Free
  Software Foundation; ou a versão 3 da Licença, ou (a sua escolha) qualquer
  versão posterior.

  Este código é distribuído na esperança de que seja útil, mas SEM
  QUALQUER GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE ou
  ADEQUAÇÃO A UMA FINALIDADE PARTICULAR. Veja a licença GNU General Public
  License para maiores detalhes.

  Você deve ter recebido uma cópia da licença GNU Library General Public
  License juntamente com esta biblioteca; senão, escreva a Free Software
  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

unit UCalculo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Ipfilebroker, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, Buttons, Math;

type

  { TfrmCalculo }

  TfrmCalculo = class(TForm)
    bttBase: TBitBtn;
    bttConverter: TButton;
    bttSobre: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Image1: TImage;
    Image2: TImage;
    IpFileDataProvider1: TIpFileDataProvider;
    IpHtmlPanel1: TIpHtmlPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Panel2: TPanel;
    panelCorpo: TPanel;
    panelTop: TPanel;
    procedure bttBaseClick(Sender: TObject);
    procedure bttConverterClick(Sender: TObject);
    procedure bttSobreClick(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: char);
    procedure EscreverHTMLdivisao(valor : integer; base: integer);
    procedure EscreverHTMLtabela(valor : string; base : integer);
    procedure EscreverHTMLseparacao(valor : string; grupo : integer);
    procedure EscreverHTMLdecomposisao(valor : string; base : integer);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    function OSVersion: string;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmCalculo: TfrmCalculo;
  reescrever : boolean;
  charset : string;

implementation

uses
  UTabela, USobre;

{$R *.lfm}

{ TfrmCalculo }

// INICIO ------------------------------------------------------------------------------------------------------------

procedure TfrmCalculo.FormCreate(Sender: TObject);        // Defire restrições de O.S.
begin
  if OSVersion = 'Linux Kernel' then
  begin
    CopyFile('imagens/div2.jpg', '/tmp/div2.jpg');      // Copia imagens para Temp
    CopyFile('imagens/div8.jpg', '/tmp/div8.jpg');
    CopyFile('imagens/div16.jpg', '/tmp/div16.jpg');
    CopyFile('imagens/v.jpg', '/tmp/v.jpg');
    CopyFile('imagens/traco.jpg', '/tmp/traco.jpg');
    SetCurrentDir('/tmp/');                             // Seta diretorio atual no Temp
    charset := 'ANSI';
  end
  else if OSVersion = 'Windows' then
  begin
    CopyFile('imagens/div2.jpg', 'C:/Windows/Temp/div2.jpg');   // Copia imagens para Temp
    CopyFile('imagens/div8.jpg', 'C:/Windows/Temp/div8.jpg');
    CopyFile('imagens/div16.jpg', 'C:/Windows/Temp/div16.jpg');
    CopyFile('imagens/v.jpg', 'C:/Windows/Temp/v.jpg');
    CopyFile('imagens/traco.jpg', 'C:/Windows/Temp/traco.jpg');
    SetCurrentDir('C:/Windows/Temp/');                  // Seta diretorio atual no Temp
    charset := 'UTF-8';
  end;
end;

// Botões ------------------------------------------------------------------------------------------------------------

procedure TfrmCalculo.bttSobreClick(Sender: TObject);  // Sobre
begin
  frmSobre.ShowModal;
end;

// Previsão de erros e outros ----------------------------------------------------------------------------------------

function TfrmCalculo.OSVersion: string;                // Verifica O.S.
begin
  {$IFDEF LCLcarbon}
  OSVersion := 'Mac OS X 10';
  {$ELSE}
  {$IFDEF Linux}
  OSVersion := 'Linux Kernel';
  {$ELSE}
  {$IFDEF UNIX}
  OSVersion := 'Unix';
  {$ELSE}
  {$IFDEF WINDOWS}
  OSVersion:= 'Windows';
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}
end;

procedure TfrmCalculo.Edit1Click(Sender: TObject);
begin
  if Edit1.Text = 'Digite o valor' then
    Edit1.Text := '';
end;

procedure TfrmCalculo.Edit1KeyPress(Sender: TObject; var Key: char);
begin
  Key := UpCase(Key);

  if Edit1.Text = 'Digite o valor' then
    Edit1.Text := '';
  if not (Key in ['0'..'9', 'A'..'F', #8]) then
    Key := #0;

  //Edit1.Text := UpperCase(Edit1.Text);
end;

// Escrever HTML Divisão ---------------------------------------------------------------------------------------------

procedure TfrmCalculo.EscreverHTMLdivisao(valor : integer; base : integer);
var
  arq : TextFile;
  x, y, i, resto : integer;
  valorSTR, resultado, target : string;
  SLresto, SLvalor: TStringList;

const
  NovaCelula = '<td align="center" width="40">';

begin
  SLvalor := TStringList.Create;
  SLresto := TStringList.Create;
  SLvalor.Clear;
  SLresto.Clear;

  while valor > 0 do
  begin
    resto := valor mod base;
    valor := valor div base;
    SLvalor.add(IntToStr(valor));
    if (base = 16) then
    begin
      case resto of
        10: SLresto.add('A');
        11: SLresto.add('B');
        12: SLresto.add('C');
        13: SLresto.add('D');
        14: SLresto.add('E');
        15: SLresto.add('F');
      else
        SLresto.add(IntToStr(resto));
      end;
    end
    else
      SLresto.add(IntToStr(resto));
  end;
  // -----
  resultado := '';
  for x := 0 to (SLresto.Count -1) do
  begin
    resultado := resultado + SLresto[SLresto.Count - Succ(x)];
  end;

  valorSTR := Edit2.Text; // QG - Salva resultado do primeiro passo para escrita

  Edit2.Text := resultado;

  // -------------------------------------


  AssignFile(arq, 'index.html');

  if not reescrever then                //Hexadecimal --> octal // Passo 2
  begin
    Append(arq);
    WriteLn(arq, '<br>');
    WriteLn(arq, '<br>');
    WriteLn(arq, '<br>');
    WriteLn(arq, '<b><font color="blue">Decimal --> Octal</font></b>');
    WriteLn(arq, '<br>');
  end
  else
  begin
    ReWrite(arq);
    valorSTR := Edit1.text; //QG

    WriteLn(arq, '<html>');                       // Abre HTML
    WriteLn(arq, '<head><meta http-equiv="content-type" content="text/html; charset='+charset+'"></head>');
    WriteLn(arq, '<body>');
  end;

  case base of                                    // Altera var para escrita
    2 : target := 'binário';
    8 : target := 'octal';
    16 : target := 'hexadecimal';
  end;
                                                  // Escreve explicação
  WriteLn(arq, '<center>');
  //WriteLn(arq, '<br>');
  WriteLn(arq, 'Para encontrar o número ' + target + ' correspondente a um número decimal,'+
                ' são realizadas sucessivas divisões do número decimal por '+ IntToStr(base) +'.'+
                ' Em seguida, o resto da divisão de cada operação é coletado de forma'+
                ' invertida, da última para a primeira operação de divisão.');
  WriteLn(arq, '<br>');

  // Pronto para escrita -----------              // Inicia Divisões


  if StrToInt(valorSTR) > (base - 1) then
  begin
    // Inicio ---
    Writeln(arq, '<center>');
    Writeln(arq, '<br>');
    Writeln(arq, '<table cellpadding="2" border="0">');      // Inicia tabela
    WriteLn(arq, '<tr>');
    WriteLn(arq, NovaCelula + valorSTR);                                                      // Valor inicial       // Linha 1
    WriteLn(arq, NovaCelula + '<img src="div' + IntToStr(base) +'.jpg">');                    // Desenho
    WriteLn(arq, '</tr>');
    WriteLn(arq, '<tr>');
    WriteLn(arq, NovaCelula + IntToStr(StrToInt(SLvalor[0])*base) + '<img src="traco.jpg">'); // numero + traço      // Linha 2
    if not (StrToInt(SLvalor[0]) >= base) then
    begin
      case SLvalor[0] of
        '10': SLvalor[0] := 'A';
        '11': SLvalor[0] := 'B';             // Se nao tiver mais de 3 linha, resultado
        '12': SLvalor[0] := 'C';             // da div é escrito em letras (se possivel)
        '13': SLvalor[0] := 'D';
        '14': SLvalor[0] := 'E';
        '15': SLvalor[0] := 'F';
      end;
    end;
    WriteLn(arq, NovaCelula + SLvalor[0]);                 // resultado da div

    case SLvalor[0] of
        'A': SLvalor[0] := '10';
        'B': SLvalor[0] := '11';             // Volta SLvalor[0] para numero, pois
        'D': SLvalor[0] := '13';             // será necessario na proxima linha
        'E': SLvalor[0] := '14';
        'F': SLvalor[0] := '15';
    end;


    if StrToInt(SLvalor[0]) >= base then          // Se resultado visual for maior que 3 linhas
    begin
      WriteLn(arq, NovaCelula + '<img src="div' + IntToStr(base) +'.jpg">');                  // Desenho             // Linha 2
      WriteLn(arq, '</tr>');

      // Meio -----
      y := 0;
      for x := 1 to (SLvalor.Count - 2) do
      begin
        WriteLn(arq, '<tr>');
        for i := 1 to y do            // Posiciona celulas invisiveis para escrever proximo valor
        begin
          WriteLn(arq, NovaCelula);
        end;
        inc(y);
        WriteLn(arq, NovaCelula + SLresto[x-1]);           // Resto da div anterior
        WriteLn(arq, NovaCelula + IntToStr(StrToInt(SLvalor[x])*base) + '<img src="traco.jpg">'); // Valor da mult.

        if (x = SLvalor.Count -2) then               // Se for ultima vez que resultado da div aparece
        begin                                        // converte para letra se possivel
          case SLvalor[x] of
            '10': SLvalor[x] := 'A';
            '11': SLvalor[x] := 'B';
            '12': SLvalor[x] := 'C';
            '13': SLvalor[x] := 'D';
            '14': SLvalor[x] := 'E';
            '15': SLvalor[x] := 'F';
          end;
        end;
        WriteLn(arq, NovaCelula + SLvalor[x]);        // Escreve resultado da div

        if x <> (SLvalor.Count - 2) then
          WriteLn(arq, NovaCelula + '<img src="div' + IntToStr(base) +'.jpg">');
        WriteLn(arq, '</tr>');
      end;

      // Fim ------
      WriteLn(arq, '<tr>');
      for i := 1 to y do      // Posiciona celulas invisiveis para por valor da linha final
      begin
        WriteLn(arq, NovaCelula);
      end;
    end
    else                      // Se resultado visual for menor que 3 linhas, abre nova linha para res final
    begin
      WriteLn(arq, '<tr>');
    end;

    if not (StrToInt(SLvalor[0]) >= base) then         // Se resultado visual for menor que 3 linhas
      Writeln(arq, NovaCelula + SLresto[x-1])                                                              // Linha final
    else                                               // Se resultado visual for maior que 3 linhas
      Writeln(arq, NovaCelula + SLresto[x]);

    WriteLn(arq, '</tr>');
    WriteLn(arq, '</table>');
  // FIM das divisões ---------------------------------
  end
  else                          // Se o resultado final for igual ao valor inserido
  begin                         // ou seja, não precisa ser convertido, pula para cá.
    Writeln(arq, '<br>');
    Writeln(arq, '<center>');

    case StrToInt(valorSTR) of
      10: valorSTR := 'A';
      11: valorSTR := 'B';
      12: valorSTR := 'C';           // Verifica se presisa converter para letra
      13: valorSTR := 'D';
      14: valorSTR := 'E';
      15: valorSTR := 'F';
    end;
    WriteLn(arq, valorSTR);     // Escreve o valor final e unico

  end;

  if base = 16 then             // Se trabalharmos com Hexa, escreve tabela com conversões basicas
  begin
    WriteLn(arq, '<br><br>');
    WriteLn(arq, '<table cellpadding="8" border="2"><tr>');
    WriteLn(arq, '<td>A = 10</td><td>B = 11</td><td>C = 12</td></tr>');
    WriteLn(arq, '<tr><td>D = 13</td><td>E = 14</td><td>F = 15</td></tr></table>');
  end;

  WriteLn(arq, '</body>');
  WriteLn(arq, '</html>');

  CloseFile(arq);

  SLvalor.Free;
  SLresto.Free;

  //IpHtmlPanel1.OpenURL(ExpandLocalHtmlFileName('bin/index.html'));
  IpHtmlPanel1.OpenURL(expandLocalHtmlFileName('index.html'));
end;

// Escrever HTML Tabela ----------------------------------------------------------------------------------------------

procedure TfrmCalculo.EscreverHTMLtabela(valor : string; base : integer);
var
  arq : TextFile;
  x, y : integer;
  numero, source : string;
  soma: extended;

begin
  soma := 0;
  y := 0;

  for x := LengTh(valor) downto 1 do
  begin
    case valor[x] of
      'A': numero := '10';
      'B': numero := '11';
      'C': numero := '12';
      'D': numero := '13';
      'E': numero := '14';
      'F': numero := '15';
    else
      numero := Valor[x];
    end;
    soma := soma + (StrToInt(numero) * Power(base, y));
    Inc(y);
  end;

  Edit2.Text := FloatToStr(soma);  // Passa resultado para campo

  // --------------------------------------

  AssignFile(arq, 'index.html');
  ReWrite(arq);

  WriteLn(arq, '<html>');
  WriteLn(arq, '<head><meta http-equiv="content-type" content="text/html; charset='+charset+'"></head>');
  WriteLn(arq, '<body>');

  if not reescrever then      // Hexadecimal --> octal // Passo 1
  begin
    WriteLn(arq, '<center>');
    WriteLn(arq, '<b><font color="red">Hexadecimal --> Decimal --> Octal</font></b>');
    WriteLn(arq, '<br>');
    WriteLn(arq, '<br>');
    WriteLn(arq, '<b><font color="blue">Hexadecimal --> Decimal</font></b>');
    WriteLn(arq, '<br>');
  end;

    case base of
      2 : source := 'binário';
      8 : source := 'octal';
      16 : source := 'hexadecimal';
    end;

    WriteLn(arq, '<center>');
    WriteLn(arq, 'Para descobrir o número decimal correspondente a um número '+ source +','+
                 ' basta calcular a soma de cada um dos dígitos do número '+ source +''+
                 ' multiplicado por '+ IntToStr(base) +' (que é a sua base) elevado à posição colunar'+
                 ' do número, que, da direita para a esquerda começa em 0.');

  // Pronto para edição ----

  WriteLn(arq, '<br>');
  WriteLn(arq, '<table border="0">');    // Table global
  WriteLn(arq, '<tr>');
  WriteLn(arq, '<td>');

  WriteLn(arq, '<div align="left">');   // Alinha tudo a esquerda
  WriteLn(arq, '<table border="0" cellspacing="0" cellpadding="0">');    // Table multiplicadores
  WriteLn(arq, '<tr>');
  // Bloco 1 ---------
  for x := 0 to (LengTh(Edit1.Text)-1) do
  begin
    WriteLn(arq, '<td width="40" align="center"><b>' + FloatToStr(Power(base, (LengTh(Edit1.Text) - Succ(x)))) + '</td>');
  end;
  // -----------------
  WriteLn(arq, '</tr>');
  WriteLn(arq, '</table>');
  WriteLn(arq, '<br>');
  WriteLn(arq, '<table border="0">');         // Table linha preta
  WriteLn(arq, '<tr>');
  WriteLn(arq, '<td height="1" width="' + IntToStr((LengTh(Edit1.Text)) * 40) + '" bgcolor="black"></td>');
  WriteLn(arq, '</tr>');
  WriteLn(arq, '</table>');
  WriteLn(arq, '<br>');
  WriteLn(arq, '<table border="0">');         // Table X vermelho
  WriteLn(arq, '<tr>');
  WriteLn(arq, '<td width="' + IntToStr((LengTh(Edit1.Text)) * 40) + '" align="center"><font color="red" size="5">x</font></td>');   //  X vermelho
  WriteLn(arq, '</tr>');
  WriteLn(arq, '<tr>');
  WriteLn(arq, '<td height="5"></td>');
  WriteLn(arq, '</tr>');
  WriteLn(arq, '</table>');
  WriteLn(arq, '<br>');
  WriteLn(arq, '<table border="0" cellspacing="0" cellpadding="0">');    // Table binarios
  WriteLn(arq, '<tr>');
  // Bloco 2 -------------
  for x := 0 to (LengTh(Edit1.Text)-1) do
  begin
    WriteLn(arq, '<td width="40" align="center">' + Edit1.Text[x+1] + '</td>');
  end;
  // ---------------------
  WriteLn(arq, '</tr>');
  WriteLn(arq, '</table>');
  WriteLn(arq, '<br>');
  WriteLn(arq, '<table border="0">');             // Table Linha vermelha
  WriteLn(arq, '<tr>');
  WriteLn(arq, '<td width="' + IntToStr((LengTh(Edit1.Text)) * 40) + '" align="center"><font color="red" size="6">=</font></td>');
  WriteLn(arq, '</tr>');
  WriteLn(arq, '</table>');
  WriteLn(arq, '<br>');
  WriteLn(arq, '<table border="0" cellspacing="0" cellpadding="0">');     // Table números multiplicados
  WriteLn(arq, '<tr>');
  // Bloco 3 -------
  for x := 0 to (LengTh(Edit1.Text)-1) do
  begin
    // ----------------------
    case Edit1.Text[x+1] of
      'A': numero := '10';
      'B': numero := '11';
      'C': numero := '12';
      'D': numero := '13';
      'E': numero := '14';
      'F': numero := '15';
    else
      numero := Edit1.Text[x+1];
    end;
    // ----------------------
    WriteLn(arq, '<td width="40" align="center">' + IntToStr(StrToInt(FloatToStr(Power(base, (LengTh(Edit1.Text) - Succ(x))))) * StrToInt(numero)) + '</td>');
  end;
  // ---------------
  WriteLn(arq, '<td width="40" align="center"><b>=</td>');
  WriteLn(arq, '<td width="40" align="center" bgcolor="lightblue"><b>' + FloatToStr(soma) + '</td>');
  WriteLn(arq, '</tr>');
  WriteLn(arq, '</table>');
  WriteLn(arq, '</td>');
  WriteLn(arq, '</tr>');
  WriteLn(arq, '</table>');

  if reescrever then            // Se houver mais um passo, o HTML não fecha
  begin
    WriteLn(arq, '</body>');
    WriteLn(arq, '</html>');
  end;

  CloseFile(arq);

  //HTMLViewer1.LoadfromFile('bin/index.html');
  IpHtmlPanel1.OpenURL(ExpandLocalHtmlFileName('index.html'));
end;

// Escrever HTML Regra de separação ----------------------------------------------------------------------------------

procedure TfrmCalculo.EscreverHTMLseparacao(valor : string; grupo : integer);
var
  arq : TextFile;
  SLbinarios, SLoctais : TStringList;
  x, y, w : integer;
  trio, res, target : string;
  soma : real;

begin
  SLbinarios := TStringList.Create;
  SLoctais := TStringList.Create;
  SLbinarios.clear;
  SLoctais.Clear;

  // Divisão dos binarios em grupos de 3 ---

  x := 1;
  w := 0;
  while w < LengTh(valor) do
  begin
    trio := '';
    for y := 1 to grupo do
    begin
      if w < LengTh(valor) then
        trio := valor[LengTh(valor) - w] + trio;
      inc(w);
    end;
    SLbinarios.Add(trio);
  end;

  // Conversão dos grupos para Octal ---

  for x := (SLbinarios.Count -1) downto 0 do
  begin
    valor := SLbinarios[x];
    soma := 0;
    for y := 1 to LengTh(valor) do
    begin
      if StrToInt(valor[y]) = 1 then
      begin
        soma := soma + (StrToFloat(valor[y]) * Power(2,(grupo - y)));
      end;
    end;

    case FloatToStr(soma) of
      '10' : res := 'A';
      '11' : res := 'B';
      '12' : res := 'C';
      '13' : res := 'D';
      '14' : res := 'E';
      '15' : res := 'F';
    else
      res := FloatToStr(soma);
    end;

    SLoctais.Add(res);
  end;

  // Monta e mostra resultado em Octal ---

  res := '';
  for x := 0 to (SLoctais.Count-1) do
  begin
    res := res + SLoctais[x];
  end;
  Edit2.Text := res;

  // Escreve HTML ----------

  AssignFile(arq, 'index.html');


  if not reescrever then                // Octal --> Hexa -- Passo 2
  begin
    Append(arq);
    WriteLn(arq, '<br>');
    WriteLn(arq, '<br>');
    WriteLn(arq, '<b><font color="blue">Binario --> Hexadecimal</font></b>');
    WriteLn(arq, '<br>');
  end
  else
  begin
    ReWrite(arq);

    WriteLn(arq, '<html>');
    WriteLn(arq, '<head><meta http-equiv="content-type" content="text/html; charset='+charset+'"></head>');
    WriteLn(arq, '<body>');
  end;

  case grupo of
      3 : target := 'octais';
      4 : target := 'hexadecimais';
    end;

    WriteLn(arq, '<center>');
    WriteLn(arq, 'Para converter números binários em '+ target +', separa-se os dígitos'+
                 ' do número binário em grupos de '+ IntToStr(grupo) +' bits da direita para a esquerda.'+
                 ' Em seguida transforma-se cada grupo individual de '+ IntToStr(grupo) +' bits em '+ target +'.'+
                 ' Ao final, une-se os resultados.');

  // Pronto para escrita

  WriteLn(arq, '<center>');
  WriteLn(arq, '<br>');
  WriteLn(arq, '<table cellpadding="2" cellspacing="0" border="0">');
  WriteLn(arq, '<tr>');
  // Primeira linha ----
  for x := (SLbinarios.Count - 1) downto 0 do
  begin
    WriteLn(arq, '<td align="center" width="40"><b>' + SLbinarios[x] + '</td>');
  end;
  // -----
  WriteLn(arq, '</tr>');
  WriteLn(arq, '<tr>');
  // Flechas ----
  for x := 0 to (SLoctais.Count - 1) do
  begin
    WriteLn(arq, '<td align="center" width="40" height="30"><img src="v.jpg"></td>');
  end;
  // -----
  WriteLn(arq, '</tr>');
  WriteLn(arq, '<tr>');
  // Ultima linha ----
  for x := 0 to (SLoctais.Count - 1) do
  begin
    WriteLn(arq, '<td align="center" width="40" height="40">' + SLoctais[x] + '</td>');
  end;
  // -----
  WriteLn(arq, '</tr>');
  WriteLn(arq, '</table>');

  WriteLn(arq, '</body>');
  WriteLn(arq, '</html>');

  CloseFile(arq);

  //HTMLViewer1.LoadfromFile('bin/index.html');
  IpHtmlPanel1.OpenURL(ExpandLocalHtmlFileName('index.html'));

  SLbinarios.Free;
  SLoctais.Free;
end;

// Escrever HTML Decomposisao ----------------------------------------------------------------------------------------

procedure TfrmCalculo.EscreverHTMLdecomposisao(valor : string; base : integer);
var
  baseCalculo, numero, x, contador : integer;
  SLdecomposto : TStringList;
  res, source, grupo : string;
  arq : TextFile;

begin
  SLdecomposto := TStringList.Create;
  SLdecomposto.Clear;

  // Decomposisão e conversão para binario -----------
  for x := 1 to LengTh(valor) do
  begin
    baseCalculo := base;
    // ----
    case valor[x] of
      'A': numero := 10;
      'B': numero := 11;
      'C': numero := 12;
      'D': numero := 13;
      'E': numero := 14;
      'F': numero := 15;
    else
      numero := StrToInt(valor[x]);
    end;
    // ----
    if numero = 0 then
    begin
      if base = 4 then
      begin
        SLdecomposto.add('0');
        SLdecomposto.add('0');
        SLdecomposto.add('0');
      end
      else if base = 8 then
      begin
        SLdecomposto.add('0');
        SLdecomposto.add('0');
        SLdecomposto.add('0');
        SLdecomposto.add('0');
      end;
    end
    else  // ---------------
    begin
      while baseCalculo > 0 do
      begin
        if numero >= baseCalculo then
        begin
          SLdecomposto.add('1');
          numero := numero - baseCalculo;
        end
        else
        begin
          SLdecomposto.add('0');
        end;
        baseCalculo := baseCalculo div 2;
      end;
    end;
  end;

  // Junção do resultado ------------------------

  res := '';
  for x := 0 to SLdecomposto.Count -1 do
  begin
    res := res + SLdecomposto[x];
  end;

  Edit2.Text := res;

  // Escreve HTML com decomposição ----------------

  AssignFile(arq, 'index.html');
  ReWrite(arq);

  WriteLn(arq, '<html>');
  WriteLn(arq, '<head><meta http-equiv="content-type" content="text/html; charset='+charset+'"></head>');
  WriteLn(arq, '<body>');

  if not reescrever then                // Octal --> Hexa -- Passo 1
  begin
    WriteLn(arq, '<center>');
    WriteLn(arq, '<b><font color="red">Octal --> Binario --> Hexadecimal</font></b>');
    WriteLn(arq, '<br>');
    WriteLn(arq, '<br>');
    WriteLn(arq, '<b><font color="blue">Octal --> Binario</font></b>');
    WriteLn(arq, '<br>');
  end;

    case base of
      4 : begin
            source := 'octais';
            grupo := '3';
          end;
      8 : begin
             source := 'hexadecimais';
             grupo := '4';
           end;
    end;

    WriteLn(arq, '<center>');
    WriteLn(arq, 'Para converter números '+ source +' em binários, deve-se decompor o número'+
                 ' diretamente em binários de '+ grupo +' dígitos. Os zeros mais à'+
                 ' esquerda do resultado binário podem ser omitidos.');

  // ---------

  WriteLn(arq, '<center>');
  WriteLn(arq, '<br>');
  WriteLn(arq, '<table cellpadding="10" cellspacing="2" border="2">');   // Abre tabela unica
  WriteLn(arq, '<tr>');

  // Primeiro loop - Numeros Octais/ hexadecimais
  for x := 1 to LengTh(valor) do
    WriteLn(arq, '<td width="80"><center><b>' + valor[x] + '</td>');

  WriteLn(arq, '</tr>');
  WriteLn(arq, '<tr>');
  // -------------------------------
  // Segundo loop - numeros binarios          // Tabela unica, 2 linhas
  contador := 0;
  for x := 0 to SLdecomposto.Count -1 do  // Varre todos os caracteres do binario
  begin
    if contador = 0 then
    begin
      WriteLn(arq, '</td>');              // quando contador = 0: fecha celula
      WriteLn(arq, '<td>');               // quando contador = 0: abre celula
      case base of
        4 : contador := 3;  // Source Octal         // Define qauntidade de caracteres binarios
        8 : contador := 4;  // Source Hexadecimal      conforme source
      end;
    end;

    WriteLn(arq, SLdecomposto[x]);        // Preenche celula
    Dec(contador);                        // Decrementa contador
  end;
  // -------------------------------

  WriteLn(arq, '</tr>');
  WriteLn(arq, '</table>');

  {for x := 1 to LengTh(valor) do         // Metodo anterior. Foi substituido devido
  begin                                      incompatibilidade com IPro
    case base of
      4 : WriteLn(arq, '<td width="89"><center><b>' + valor[x] + '</td>');
      8 : WriteLn(arq, '<td width="126"><center><b>' + valor[x] + '</td>');
    end;
  end;
  WriteLn(arq, '</tr>');
  WriteLn(arq, '</table>');
  WriteLn(arq, '<br>');
  WriteLn(arq, '<table cellpadding="10" cellspacing="2" border="1">');   // Table Binario
  WriteLn(arq, '<tr>');
  for x := 0 to SLdecomposto.Count -1 do
  begin
    WriteLn(arq, '<td width="15"><center>' + SLdecomposto[x] + '</td>');
  end;
  WriteLn(arq, '</tr>');
  WriteLn(arq, '</table>');
  }

  if reescrever then
  begin
    WriteLn(arq, '</body>');
    WriteLn(arq, '</html>');
  end;

  CloseFile(arq);

  IpHtmlPanel1.OpenURL(ExpandLocalHtmlFileName('index.html'));

  SLdecomposto.Free;
end;

// Iniciar -----------------------------------------------------------------------------------------------------------

procedure TfrmCalculo.bttConverterClick(Sender: TObject);           // Converter
var
  valor : string;
  x : integer;
  i : char;

begin
  // Previsao de erros -------------------------------------
  if Combobox1.Text = 'Binário' then
  begin
    for x := 1 to LengTh(Edit1.Text) do
    begin
      i := Edit1.Text[x];
      if not (i in ['0'..'1']) then
      begin
        ShowMessage('"'+Edit1.Text+'"' + ' não é um binario válido!');
        abort;
      end;
    end;
  end
  else if Combobox1.Text = 'Octal' then
  begin
    for x := 1 to LengTh(Edit1.Text) do
    begin
      i := Edit1.Text[x];
      if not (i in ['0'..'7']) then
      begin
        ShowMessage('"'+Edit1.Text+'"' + ' não é um octal válido!');
        abort;
      end;
    end;
  end
  else if Combobox1.Text = 'Decimal' then
  begin
    for x := 1 to LengTh(Edit1.Text) do
    begin
      i := Edit1.Text[x];
      if not (i in ['0'..'9']) then
      begin
        ShowMessage('"'+Edit1.Text+'"' + ' não é um decimal válido!');
        abort;
      end;
    end;
  end
  else if Combobox1.Text = 'Hexadecimal' then
  begin
    for x := 1 to LengTh(Edit1.Text) do
    begin
      i := Edit1.Text[x];
      if not (i in ['0'..'9', 'A'..'F']) then
      begin
        ShowMessage('"'+Edit1.Text+'"' + ' não é um hexadecimal válido!');
        abort;
      end;
    end;
  end;

  if (ComboBox1.Text = '') or (ComboBox2.Text = '') then
  begin
    ShowMessage('Selecione as bases para conversão!');
    abort;
  end;

  // ---------------------------------

  reescrever := true;    // Usado quando uma conversão exige 2 pu mais passos
  valor := Edit1.Text;

  if ComboBox1.Text = 'Binário' then
  begin
    case ComboBox2.Text of
      'Binário' : ShowMessage('Não é possivel converter para a mesma base!');
      'Octal' : EscreverHTMLseparacao(valor, 3);
      'Decimal' : EscreverHTMLtabela(valor, 2);
      'Hexadecimal' : EscreverHTMLseparacao(valor, 4);
    end;
  end
  else if ComboBox1.Text = 'Octal' then
  begin
    case ComboBox2.Text of
      'Binário' : EscreverHTMLdecomposisao(valor, 4);
      'Octal' : ShowMessage('Não é possivel converter para a mesma base!');
      'Decimal' : EscreverHTMLtabela(valor, 8);
      'Hexadecimal' : begin
                        reescrever := false;
                        EscreverHTMLdecomposisao(valor, 4);
                        EscreverHTMLseparacao(Edit2.Text, 4);
                        reescrever := true;
    end;              end;
  end
  else if ComboBox1.Text = 'Decimal' then
  begin
    case ComboBox2.Text of
      'Binário' : EscreverHTMLdivisao(StrToInt(valor), 2);
      'Octal' : EscreverHTMLdivisao(StrToInt(valor), 8);
      'Decimal' : ShowMessage('Não é possivel converter para a mesma base!');
      'Hexadecimal' : EscreverHTMLdivisao(StrToInt(valor), 16);
    end;
  end
  else if ComboBox1.Text = 'Hexadecimal' then
  begin
    case ComboBox2.Text of
      'Binário' : EscreverHTMLdecomposisao(valor, 8);
      'Octal' : begin
                  reescrever := false;
                  EscreverHTMLtabela(valor, 16);
                  EscreverHTMLdivisao(StrToInt(Edit2.Text), 8);
                  reescrever := true;
                end;
      'Decimal' : EscreverHTMLtabela(valor, 16);
      'Hexadecimal' : ShowMessage('Não é possivel converter para a mesma base!');
    end;
  end;

end;

procedure TfrmCalculo.bttBaseClick(Sender: TObject);                // Tabela
begin
  frmTabela.ShowModal;
end;

// FIM ---------------------------------------------------------------------------------------------------------------

procedure TfrmCalculo.FormClose(Sender: TObject; var CloseAction: TCloseAction);   // Limpa pasta Temp
begin
  if FileExists('div2.jpg') then
    DeleteFile('div2.jpg');
  if FileExists('div8.jpg') then
    DeleteFile('div8.jpg');
  if FileExists('div16.jpg') then
    DeleteFile('div16.jpg');
  if FileExists('v.jpg') then
    DeleteFile('v.jpg');
  if FileExists('traco.jpg') then
    DeleteFile('traco.jpg');
  if FileExists('index.html') then
    DeleteFile('index.html');
end;

end.
