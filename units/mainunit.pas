unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls, stock,
  stocks_data, Portfolio_Data, Grids, EditBtn, ComCtrls, Buttons, Menus,
  ActnList, Dialogs, stockFullGrid, stockPanel , Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    Action_Save: TAction;
    Action_edit_stock: TAction;
    Action_add_stock: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button8: TButton;
    ColorDialog1: TColorDialog;
    CountryCombo: TComboBox;
    GroupBox3: TGroupBox;
    ImageList1: TImageList;
    Label9: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    Panel11: TPanel;
    Panel16: TPanel;
    PortfolioCombo: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label7: TLabel;
    Portfolio_ListBox: TListBox;
    OutPortfolio_ListBox: TListBox;
    PageControl1: TPageControl;
    Panel10: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel7: TPanel;
    Panel9: TPanel;
    Separator1: TMenuItem;
    Stock_Combo: TComboBox;
    DateEdit1: TDateEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure Action_editExecute(Sender: TObject);
    procedure Action_add_stockExecute(Sender: TObject);
    procedure Action_edit_stockExecute(Sender: TObject);
    procedure Action_SaveExecute(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure CountryComboChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure OutPortfolio_ListBoxClick(Sender: TObject);
    procedure PortfolioComboChange(Sender: TObject);
    procedure Portfolio_ListBoxClick(Sender: TObject);
    procedure Stock_ComboChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fstockGrid  : tGrid_Stocks;
    fstockPanel : tStockPanel;
    procedure Fill_Stock_Combo(const countryName :string='');
    procedure SetComboIndex(const stock : IStock);
    procedure Fill_Country_Combo(const countryName :string='');
    procedure Fill_Portfolio_Combo;
    procedure Fill_Portfolio_ListBoxes;
    procedure Add_Portfolio(Sender : TObject ; AName : string);
    procedure OnEditStock(sender : tObject;Stock : IStock);
    procedure OnAddStock(sender : tObject; Stock : IStock);
    procedure OnSaved(Sender : TObject);
  public

  end;

var
  Form1: TForm1;

implementation

uses Stock_Operation, form_add_stock, add_portfolio_unit;

{$R *.lfm}

{ TForm1 }
procedure TForm1.FormCreate(Sender: TObject);
begin
  StocksData.OnSaved:=@OnSaved;
  StocksData.OnAddStock:=@OnAddStock;
  StocksData.OnEditStock:=@OnEditStock;
  fstockPanel   :=tStockPanel.create(Panel7);
  fstockGrid    :=tGrid_Stocks.Create(Panel4);
  DateEdit1.Date:=Date;
  Fill_Stock_Combo;
  PortfolioData :=tPortfolio_Data.Create;
  Fill_Portfolio_Combo;
  Fill_Country_Combo;
  StocksData.CheckStockProps;

end;



procedure TForm1.FormActivate(Sender: TObject);
begin
 PortfolioData.OnAddPortfolio:=@Add_Portfolio;
end;

{Обработка события. Добавление акции}
procedure TForm1.OnAddStock(sender: tObject; Stock: IStock);
begin
  Fill_Stock_Combo(Stock.Country);
  Fill_Portfolio_ListBoxes;
  SetComboIndex(Stock);
  Fill_Country_Combo(Stock.Country);
end;

{Обработка события. Редактирование акции}
procedure TForm1.OnEditStock(sender : tObject;Stock : IStock);
begin
  Fill_Country_Combo(Stock.Country);
  Stock_Combo.Clear;
  Stock_Combo.Items.AddStrings(StocksData.getStockStrList(Stock.Country));
  SetComboIndex(Stock);
end;

{Обработка события. Изменен признак сохранения}
procedure TForm1.OnSaved(Sender: TObject);
begin
  ToolButton2.Enabled:=not StocksData.IsSaved;
end;

procedure TForm1.Fill_Stock_Combo(const countryName :string);
begin
  Stock_Combo.Clear;
  StocksData.setCountry(countryName);
  StocksData.SetFirstStockFromCountry(countryName);
  Stock_Combo.Items.AddStrings(StocksData.getStockStrList(countryName));
  Stock_Combo.ItemIndex:=0;
end;

procedure TForm1.SetComboIndex(const stock: IStock);
var i : integer;
begin
  for i:=0 to Stock_Combo.Items.Count-1 do
    if AnsiLowerCase(Stock_Combo.Items[i])=AnsiLowerCase(stock.Name) then
     begin
       Stock_Combo.ItemIndex:=i;
       break;
     end;
  StocksData.setStock(Stock_Combo.ItemIndex);
end;

procedure TForm1.Fill_Country_Combo(const countryName: string);
var i: integer;
begin
  CountryCombo.Clear;
  CountryCombo.Items.Add('Все');
  CountryCombo.Items.AddStrings(StocksData.CountryList);
  CountryCombo.ItemIndex:=0;
  if countryName<>'' then
   begin
     for i:=0 to CountryCombo.Items.Count-1 do
       if AnsiLowerCase(CountryCombo.Items[i])=AnsiLowerCase(countryName) then
        begin
          CountryCombo.ItemIndex:=i;
          exit;
        end;
   end;
end;

procedure TForm1.Fill_Portfolio_Combo; {Заполнить комбо портфелей}
begin
  PortfolioCombo.Clear;
  PortfolioCombo.Items.AddStrings(PortfolioData.PortfolioNames);
  if PortfolioCombo.Items.Count>0 then
   begin
     PortfolioCombo.ItemIndex:=0;
     PortfolioData.Set_Active_Portfolio(0);
   end;
  BitBtn1.Enabled:=PortfolioData.HasActivePortfolio;
  BitBtn2.Enabled:=PortfolioData.HasActivePortfolio;
  Fill_Portfolio_ListBoxes;
end;

procedure TForm1.Fill_Portfolio_ListBoxes;
var tekStock : IStock;
begin
  Portfolio_ListBox.Clear;
  OutPortfolio_ListBox.Clear;
  for tekStock in PortfolioData.StockList do
    Portfolio_ListBox.Items.Add(tekStock.Name);
  for tekStock in PortfolioData.OutsideStockList do
    OutPortfolio_ListBox.Items.Add(tekStock.Name);
end;

procedure TForm1.Add_Portfolio(Sender: TObject; AName: string);
begin
   Fill_Portfolio_Combo;
end;

procedure TForm1.Stock_ComboChange(Sender: TObject);
begin
  StocksData.setStock(Stock_Combo.ItemIndex);
end;

procedure TForm1.Button1Click(Sender: TObject);{"Купил"}
begin
  StocksData.AddOperationToChosenStock(DateEdit1.Date,_Operation_Buy,strtoint(Edit1.Text),StrToFloat(Edit2.Text));
end;

procedure TForm1.Button2Click(Sender: TObject);{"Продал"}
begin
  StocksData.AddOperationToChosenStock(DateEdit1.Date,_Operation_Sell,strtoint(Edit1.Text),StrToFloat(Edit2.Text));
end;

procedure TForm1.OutPortfolio_ListBoxClick(Sender: TObject);{Выбрать акцию вне портфеля}
begin
  if OutPortfolio_ListBox.ItemIndex>-1
  then PortfolioData.OutSideStock:=PortfolioData.Get_Outside_Stock(OutPortfolio_ListBox.Items[OutPortfolio_ListBox.ItemIndex])
  else PortfolioData.OutSideStock:=nil;
end;

procedure TForm1.Portfolio_ListBoxClick(Sender: TObject);  {Выбрать акцию в портфеле}
begin
  if Portfolio_ListBox.ItemIndex>-1
  then PortfolioData.ChosenStock:=PortfolioData.Get_Stock_In_Portfolio(Portfolio_ListBox.Items[Portfolio_ListBox.ItemIndex])
  else PortfolioData.ChosenStock:=nil;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);{Перенести акцию в портфель}
begin
  if (PortfolioData.OutsideStock<>nil) then
   begin
     PortfolioData.Add_Stock_To_Portfolio;
     Fill_Portfolio_ListBoxes;
   end;
end;

{Действие "добавить акцию"}
procedure TForm1.Action_add_stockExecute(Sender: TObject);
begin
  Form2.regim:=_SRAdd;
  Form2.Visible:=true;
end;

procedure TForm1.Action_editExecute(Sender: TObject);
begin

end;

{Действие "Редактировать акцию"}
procedure TForm1.Action_edit_stockExecute(Sender: TObject);
begin
  Form2.regim:=_SREdit;
  Form2.Visible:=true;
end;

procedure TForm1.Action_SaveExecute(Sender: TObject);
begin
  StocksData.WriteToXML;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);{Удалить акцию из портфеля}
begin
  if (PortfolioData.ChosenStock<>nil) then
   begin
     PortfolioData.Delete_Stock_From_Portfolio;
     Fill_Portfolio_ListBoxes;
   end;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);{Форма добавления портфеля}
begin
  Form3.Visible:=true;
end;



procedure TForm1.Button3Click(Sender: TObject);{Удалить все операции}
begin
  StocksData.DeleteAllStockOperations;
end;

procedure TForm1.Button4Click(Sender: TObject);{Удалить последнюю операцию}
begin
  StocksData.DeleteLastStockOperation;
end;

procedure TForm1.Button6Click(Sender: TObject); {Добавить новую акцию}
begin
  Form2.Visible:=true;
end;

procedure TForm1.Button8Click(Sender: TObject);{Удалить портфель}
begin
  PortfolioData.Delete_Portfolio;
  Fill_Portfolio_Combo;
end;

procedure TForm1.CountryComboChange(Sender: TObject);
begin
  if TComboBox(Sender).Text='Все'
  then Fill_Stock_Combo
  else Fill_Stock_Combo(TComboBox(Sender).Text);
  //fstockGrid.Update(TComboBox(Sender).Text);
end;


procedure TForm1.PortfolioComboChange(Sender: TObject);{Сменить выбранный портфель}
begin
  PortfolioData.Set_Active_Portfolio(PortfolioCombo.ItemIndex);
  Fill_Portfolio_ListBoxes;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if (not StocksData.IsSaved) and (MessageDlg('Сохранение в XML ','Cохранить параметры акций в XML', mtConfirmation,[mbYes,mbNo,mbAbort],0)=mrYes)
  then StocksData.WriteToXML;
end;


end.

{
procedure TForm1.country_editChange(Sender: TObject);
begin
//  fTekStock.Country:=TEdit(Sender).Text;
end; }

{
procedure TForm1.Fill_Stock_Combo(const stock: IStock);
var counter:integer=0;
i      :integer;
begin
{
Stock_Combo.Clear;
for i:=0 to StocksData.StockList.Count-1 do
if (stock.Country='') or (AnsiLowerCase(stock.Country)=AnsiLowerCase(StocksData.StockList[i].Country))then
begin
if stock.Name=StocksData.StockList[i].Name
then Stock_Combo.ItemIndex:=counter;
Stock_Combo.Items.Add(StocksData.StockList[i].Name);
inc(counter);
end;
Memo1.Lines.Clear;
Memo1.Lines.AddStrings(fTekStock.OperationListStr);
UpdateGrid;
}
end;   }

