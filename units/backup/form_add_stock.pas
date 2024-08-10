unit form_add_stock;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, Stocks_Data, Stock_Observer, Stock, Stock_list;

type

  { TForm2 }
  add_stock_proc = procedure ( sender : tObject; Stock : IStock) of object;
  tStockMode = ( _SMNone,
                 _SMAdd,  //Режим добавления акции
                 _SMEdit  //Режим редактирования акции
                );

  TForm2 = class(TForm, IObserver)
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
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
   private
    fStockMode          : tStockMode;
    procedure FillCombos;
  public
    property StockMode : tStockMode read fStockMode write fStockMode;
    procedure UpdateStock(stock : IStock);
    procedure UpdateFilteredStockList(StockFilteredList : TStockFilteredList);
  end;

var
  Form2: TForm2;

implementation

const btn_text : array [boolean] of string = ('Добавить','Сохранить изменения');
      form_height_default = 170;
      form_width_default  = 650;
{$R *.lfm}

{ TForm2 }
procedure TForm2.FormCreate(Sender: TObject);
begin
  fStockMode:=_SMNone;
  StocksData.registerObserver(self);
end;

procedure TForm2.FormShow(Sender: TObject);
    function getIndex(combo : tcombobox; item_txt : string):integer;
    begin
      Result:=0;
      if combo.Items.IndexOf(item_txt)<>-1
      then Result:=combo.Items.IndexOf(item_txt)
    end;
begin
  FillCombos;
  Button1.Caption:=btn_text[fStockMode=_SMEdit];
  Panel1.Visible:=fStockMode in [_SMAdd,_SMEdit];
  ComboCountry.Visible:=fStockMode in [_SMAdd,_SMEdit];
  ComboIndustry.Visible:=fStockMode in [_SMAdd,_SMEdit];
  Form2.Height:=form_height_default;
  Form2.Width :=form_width_default;
  case fStockMode of
      _SMAdd       : begin
                       Edit1.Text:='Новая акция';
                       ComboCountry.ItemIndex:=0;
                       ComboIndustry.ItemIndex:=getIndex(ComboIndustry,'Не определено');
                     end;
      _SMEdit      : begin
                       Edit1.Text:=StocksData.ChosenStock.Name;
                       ComboCountry.ItemIndex :=getIndex(ComboCountry,StocksData.ChosenStock.Country);
                       ComboIndustry.ItemIndex:=getIndex(ComboIndustry,StocksData.ChosenStock.Industry);
                     end;
  end;
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

procedure TForm2.UpdateStock(stock: IStock);
    function getIndex(combo : tcombobox; item_txt : string):integer;
    begin
      Result:=0;
      if combo.Items.IndexOf(item_txt)<>-1
      then Result:=combo.Items.IndexOf(item_txt)
    end;
begin
  case fStockMode of
      _SMEdit : begin
                  if Assigned(StocksData.ChosenStock) then
                   begin
                     Edit1.Text:=StocksData.ChosenStock.Name;
                     ComboCountry.ItemIndex :=getIndex(ComboCountry,StocksData.ChosenStock.Country);
                     ComboIndustry.ItemIndex:=getIndex(ComboIndustry,StocksData.ChosenStock.Industry);
                   end
                  else
                   begin
                     self.Hide;
                     //ComboIndustry.ItemIndex:=-1;
                     //ShowMessage('CHOSEN STOCK = NIL !!!');
                   end;
                end;
  end;
end;

procedure TForm2.UpdateFilteredStockList(StockFilteredList: TStockFilteredList);
begin

end;

{Сохранит изменения/ добавить}
procedure TForm2.Button1Click(Sender: TObject);
var newStock : IStock;
begin
  case fStockMode of
      _SMAdd : StocksData.AddStock(tStock.Create(edit1.Text,ComboCountry.Text,ComboIndustry.Text));
      _SMEdit: StocksData.EditStock(ComboCountry.Text,Edit1.Text,ComboIndustry.Text);
  end;
  Self.Close;
end;




end.

