unit Panel_Choose_Stock;
{На данной панели располагаются три комбобокса и чекбокс, исходя из которых формируется  }
{список акций для отображения}

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, ExtCtrls, ComCtrls, StdCtrls, Stock, Stocks_Data,
  Portfolio_Data;

type
  ptPanel = ^TPanel;
  { tPanelChooseStock }

  tPanelChooseStock = class
   private
    fPanelChooseStock : TPanel;
    fPortfolioChb : TCheckBox;
    fComboCountry : TComboBox;
    fComboIndustry: TComboBox;
    fComboStock   : TComboBox;
    fToolBar      : TToolBar;
    fPanelIndustry: TPanel;
    fCountryLabel : TLabel;
    FForm         : TForm;
    procedure OnComboCountryChanged(Sender: TObject);
    procedure OnComboIndustryChanged(Sender: TObject);
    procedure OnComboStockChanged(Sender: TObject);
    procedure OnChbClick(Sender: TObject);

    procedure Fill_Stock_Combo();

    procedure SetStockCombo(const Astock: IStock);
    procedure SetCountryCombo(const ACountryName: string);
    procedure SetIndustryCombo(const AIndustryName: string);

    procedure Fill_Country_Combo(const countryName: string='');
    procedure Fill_Industry_Combo(const industryName: string='');
    procedure Fill_Portfolio_Combo(const portfolioName : string = '');
   public
    constructor Create(MainForm : TForm);
    procedure UpdateStockCombos( Stock : IStock);
    procedure UpdateStockCombo();
  end;

implementation

{ tPanelChooseStock }
constructor tPanelChooseStock.Create(MainForm : TForm);
begin
  FForm         :=MainForm;
  fPortfolioChb :=FForm.FindComponent('PortfolioChb') as TCheckBox;
  fComboCountry :=FForm.FindComponent('CountryCombo') as  TComboBox;
  fComboIndustry:=FForm.FindComponent('IndustryCombo') as  TComboBox;
  fComboStock   :=FForm.FindComponent('StockCombo') as  TComboBox;
  fToolBar      :=FForm.FindComponent('ToolBar2') as  TToolBar;
  fCountryLabel :=FForm.FindComponent('Label9') as  TLabel;
  fPanelIndustry:=FForm.FindComponent('PanelIndustry') as  TPanel;
  fPanelChooseStock:=FForm.FindComponent('PanelChooseStock') as  TPanel;

  fComboCountry.OnChange :=@OnComboCountryChanged;
  fComboIndustry.OnChange:=@OnComboIndustryChanged;
  fComboStock.OnChange   :=@OnComboStockChanged;
  fPortfolioChb.OnClick  :=@OnChbClick;
  Fill_Country_Combo;
  Fill_Industry_Combo;

  SetCountryCombo(StocksData.ChosenCountry);
  SetIndustryCombo(StocksData.ChosenIndustry);

  StocksData.setCountry(fComboCountry.Text);
  StocksData.setIndustry(fComboIndustry.Text);
  Fill_Stock_Combo;
end;

procedure tPanelChooseStock.UpdateStockCombos( Stock : IStock);
begin
  Fill_Country_Combo(Stock.Country);
  StocksData.setCountry(Stock.Country);

  Fill_Industry_Combo(Stock.Industry);
  StocksData.setIndustry(Stock.Industry);

  Fill_Stock_Combo();
  SetStockCombo(Stock);
end;

procedure tPanelChooseStock.UpdateStockCombo;
begin
  Fill_Stock_Combo();
  fComboStock.ItemIndex:=0;
  StocksData.setStock(fComboStock.ItemIndex);
end;

procedure tPanelChooseStock.Fill_Country_Combo(const countryName: string);
var i: integer;
begin
  fComboCountry.Clear;
  fComboCountry.Items.Add('Все');
  fComboCountry.Items.AddStrings(StocksData.CountryList);
  SetCountryCombo(countryName);
  //if StocksData.ChosenIndustry=''
  //then StocksData.setIndustry('Все');
end;

procedure tPanelChooseStock.Fill_Portfolio_Combo(const portfolioName: string);
begin
  fComboCountry.Clear;
  fComboCountry.Items.AddStrings(PortfolioData.PortfolioNames);
  fComboCountry.ItemIndex:=0;
  StocksData.SetPortfolio(fComboCountry.Text);
end;

procedure tPanelChooseStock.Fill_Industry_Combo(const industryName: string);
    function getIndex(combo : tcombobox; item_txt : string):integer;
    begin
      Result:=0;
      if combo.Items.IndexOf(item_txt)<>-1
      then Result:=combo.Items.IndexOf(item_txt)
    end;
begin
  fComboIndustry.Clear;
  fComboIndustry.Items.Add('Все');
  fComboIndustry.Items.AddStrings(StocksData.IndustryList);
  fComboIndustry.ItemIndex:=0;
  if industryName<>''
  then fComboIndustry.ItemIndex:=getIndex(fComboIndustry,industryName);
end;

procedure tPanelChooseStock.Fill_Stock_Combo();
begin
  fComboStock.Clear;
  fComboStock.Items.AddStrings(StocksData.FilteredStocks.StockNames);
  fComboStock.ItemIndex:=0;
  fComboStock.Enabled:=StocksData.FilteredStocks.StockNames.Count>0;
end;


procedure tPanelChooseStock.OnComboCountryChanged(Sender: TObject);
begin
  if fPortfolioChb.Checked
  then StocksData.SetPortfolio(TComboBox(Sender).Text)
  else StocksData.setCountry(TComboBox(Sender).Text);
  Fill_Stock_Combo();
end;

procedure tPanelChooseStock.OnComboIndustryChanged(Sender: TObject);
begin
  StocksData.setIndustry(TComboBox(Sender).Text);
  Fill_Stock_Combo();
end;

procedure tPanelChooseStock.OnComboStockChanged(Sender: TObject);
begin
  StocksData.setStock(fComboStock.ItemIndex);
end;

procedure tPanelChooseStock.OnChbClick(Sender: TObject);
const labelText : array [boolean] of string = ('Страна','Портфель');
begin
  //fComboIndustry.Enabled:=not fPortfolioChb.Checked;
  fCountryLabel.Caption:=labelText[fPortfolioChb.Checked];
  fPanelIndustry.Visible:=not fPortfolioChb.Checked;
  if fPortfolioChb.Checked then
   begin
     Fill_Portfolio_Combo;
     Fill_Stock_Combo();
     fPanelChooseStock.Height:=fPanelChooseStock.Height-40;
   end
  else
   begin
     Fill_Country_Combo();
     Fill_Stock_Combo();
     fPanelChooseStock.Height:=fPanelChooseStock.Height+40;
   end;
end;


procedure tPanelChooseStock.SetCountryCombo(const ACountryName: string);
var i : integer;
begin
  fComboCountry.ItemIndex:=0;
  if ACountryName<>'' then
   begin
     for i:=0 to fComboCountry.Items.Count-1 do
       if AnsiLowerCase(fComboCountry.Items[i])=AnsiLowerCase(ACountryName) then
        begin
          fComboCountry.ItemIndex:=i;
          exit;
        end;
   end;
end;

procedure tPanelChooseStock.SetIndustryCombo(const AIndustryName: string);
var i : integer;
begin
  fComboIndustry.ItemIndex:=0;
  if AIndustryName<>'' then
   begin
     for i:=0 to fComboIndustry.Items.Count-1 do
       if AnsiLowerCase(fComboIndustry.Items[i])=AnsiLowerCase(AIndustryName) then
        begin
          fComboIndustry.ItemIndex:=i;
          exit;
        end;
   end;
end;

procedure tPanelChooseStock.SetStockCombo(const Astock: IStock);
var i : integer;
begin
  for i:=0 to fComboStock.Items.Count-1 do
    if AnsiLowerCase(fComboStock.Items[i])=AnsiLowerCase(Astock.Name) then
     begin
       fComboStock.ItemIndex:=i;
       break;
     end;
  StocksData.setStock(fComboStock.ItemIndex);
end;



end.

