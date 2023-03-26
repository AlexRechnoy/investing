unit form_add_stock;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, Stocks_Data, Stock;

type

  { TForm2 }
  add_stock_proc = procedure ( sender : tObject; Stock : IStock) of object;
  tStockRegim = (_SRNone,_SRAdd,_SREdit);

  TForm2 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Button1: TButton;
    ComboIndustry: TComboBox;
    ComboCountry: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
   private
    fRegim          : tStockRegim;
    procedure UpdateCombo(Sender : TObject);
    procedure FillCombos;
  public
    property regim : tStockRegim read fRegim write fRegim;
  end;

var
  Form2: TForm2;

implementation

uses form_edit_props;

const btn_text : array [boolean] of string = ('Добавить','Сохранить изменения');

{$R *.lfm}

{ TForm2 }
procedure TForm2.FormCreate(Sender: TObject);
begin
  FillCombos;
  fRegim:=_SRNone;
end;

procedure TForm2.FormActivate(Sender: TObject);
begin
  Form4.OnUpdate:=@UpdateCombo;
end;

procedure TForm2.FormShow(Sender: TObject);
    function getIndex(combo : tcombobox; item_txt : string):integer;
    begin
      Result:=0;
      if combo.Items.IndexOf(item_txt)<>-1
      then Result:=combo.Items.IndexOf(item_txt)
    end;

begin
  Button1.Caption:=btn_text[fRegim=_SREdit];
  if fRegim=_SREdit then
   begin
     Edit1.Text:=StocksData.ChosenStock.Name;
     ComboCountry.ItemIndex :=getIndex(ComboCountry,StocksData.ChosenStock.Country);
     ComboIndustry.ItemIndex:=getIndex(ComboIndustry,StocksData.ChosenStock.Industry);
   end;
end;

procedure TForm2.UpdateCombo(Sender: TObject);
begin
  FillCombos;
end;

procedure TForm2.FillCombos;
    procedure fillCombo(Combo : TComboBox; List : TStringList; const oldIndex : integer);
    begin
      Combo.Items.Assign(List);
      if Combo.Items.Count=0
      then Combo.Items.Insert(0,'Нет');
      if oldIndex>-1
      then Combo.ItemIndex:=oldIndex
      else Combo.ItemIndex:=0;
    end;
begin
  fillCombo(ComboCountry,StocksData.CountryList,ComboCountry.ItemIndex);
  fillCombo(ComboIndustry,StocksData.IndustryList,ComboIndustry.ItemIndex);
end;

procedure TForm2.BitBtn1Click(Sender: TObject);
begin
  Form4.Visible:=true;
  Form4.loadList(StocksData.CountryList,true);
end;

procedure TForm2.BitBtn2Click(Sender: TObject);
begin
  Form4.Visible:=true;
  Form4.loadList(StocksData.IndustryList,false);
end;

{Сохранит изменения/ добавить}
procedure TForm2.Button1Click(Sender: TObject);
var newStock : IStock;
begin
  case fRegim of
      _SRAdd : StocksData.AddStock(tStock.Create(edit1.Text,ComboCountry.Text,ComboIndustry.Text));
      _SREdit: if Assigned(fOnEditStock) then
                begin
                  StocksData.EditStock(StocksData.ChosenStock,ComboCountry.Text,Edit1.Text,ComboIndustry.Text);
                  fOnEditStock(self);
                end;
  end;
  Self.Close;
end;




end.

