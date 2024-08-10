unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls,   ActnList,
  Dialogs,EditBtn, ComCtrls, Buttons, Menus, Grids,

  stock,
  stocks_data,
  TAGraph, TASeries,Panel_Choose_Stock, Tab_Portfolio,Tab_Statistics,
  Stocks_Grid, stockPanel , Stock_Price_Panel;

type

  { TForm1 }

  TForm1 = class(TForm)
    Action_Settings: TAction;
    Action_BackUp: TAction;
    Action_Save: TAction;
    Action_edit_stock: TAction;
    Action_add_stock: TAction;
    ActionList1: TActionList;
    AddStockToPortfolioBtn: TBitBtn;
    StatsPortfolioCombo: TComboBox;
    Label7: TLabel;
    Label8: TLabel;
    Panel3: TPanel;
    PortfolioChb: TCheckBox;
    StockPriceSaveBtn: TBitBtn;
    DelStockFromPortfolioBtn: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    ColorDialog1: TColorDialog;
    StockPriceEdit: TEdit;
    IndustryCombo: TComboBox;
    CountryCombo: TComboBox;
    ImageList1: TImageList;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    PanelPriceStock: TPanel;
    PortfolioGridLabel: TLabel;
    Label9: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    StatsCountryPanel: TPanel;
    PortfolioGridPanel: TPanel;
    PanelCenter: TPanel;
    PanelDelStock: TPanel;
    PanelAddStock: TPanel;
    PanelCountry: TPanel;
    PanelIndustry: TPanel;
    PanelStockName: TPanel;
    StatsPortfolioPanel: TPanel;
    PortfolioCombo: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    PortfolioNameLabel: TLabel;
    PortfolioListBox: TListBox;
    OutsidePortfolioListBox: TListBox;
    PageControl1: TPageControl;
    BottomPortfolioPanel: TPanel;
    Panel12: TPanel;
    PanelTop: TPanel;
    PanelBottom: TPanel;
    Panel7: TPanel;
    ToolBar3: TToolBar;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton9: TToolButton;
    TopPortfolioPanel: TPanel;
    Separator1: TMenuItem;
    StockCombo: TComboBox;
    DateEdit1: TDateEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    PanelStatsStock: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    PanelChooseStock: TPanel;
    StringGrid1: TStringGrid;
    TabSheet1: TTabSheet;
    PortfolioSheet: TTabSheet;
    TabSheet3: TTabSheet;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    procedure Action_BackUpExecute(Sender: TObject);
    procedure Action_editExecute(Sender: TObject);
    procedure Action_add_stockExecute(Sender: TObject);
    procedure Action_edit_stockExecute(Sender: TObject);
    procedure Action_SaveExecute(Sender: TObject);
    procedure Action_SettingsExecute(Sender: TObject);
    procedure StockPriceSaveBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    fPortfolioTab     : tPortfolioTab;
    fStatisticsTab    : tStatisticsTab;
    fstocksGrid       : tStocksGrid;
    fchooseStockPanel : tPanelChooseStock;

    fstockPricePanel  : tStockPricePanel;

    fstockPanel       : tStockPanel;
    procedure OnEditStock(sender : tObject;Stock : IStock);
    procedure OnAddStock(sender : tObject; Stock : IStock);
    procedure OnExchangeCoutry(sender : tObject);
    procedure OnExchangeIndustry(sender : tObject);
    procedure OnSortFilteredStocks(sender : tObject);
    procedure OnSaved(Sender : TObject);
  public

  end;

var
  Form1: TForm1;

implementation

uses Stock_Operation, form_add_stock, form_edit_props;

{$R *.lfm}

{ TForm1 }
procedure TForm1.FormCreate(Sender: TObject);      var s : string;
begin
  //Вкладка "Акции"
  DateEdit1.Date               :=Date;
  fstockPanel                  :=tStockPanel.create(Panel7,ImageList1);
  fstocksGrid                  :=tStocksGrid.Create(Panel4);
  fstockPricePanel             :=tStockPricePanel.Create(Form1);
  fchooseStockPanel            :=tPanelChooseStock.Create(Form1);
  //Вкладка "Редактор портфелей"
  fPortfolioTab               :=tPortfolioTab.Create(Form1);
  //Вкладка "Статистика"
  s:=StocksData.ChosenIndustry;
  fStatisticsTab              :=tStatisticsTab.Create(Form1);

  StocksData.OnSaved           :=@OnSaved;
  StocksData.OnAddStock        :=@OnAddStock;
  StocksData.OnEditStock       :=@OnEditStock;
  StocksData.OnExchangeCountry :=@OnExchangeCoutry;
  StocksData.OnExchangeIndustry:=@OnExchangeIndustry;
  StocksData.OnSortFilteredStocks:=@OnSortFilteredStocks;
  StocksData.CheckStockProps;
  StocksData.calcAndNotifyStatsObservers();
end;


{Обработка события. Добавление акции}
procedure TForm1.OnAddStock(sender: tObject; Stock: IStock);
begin
  fchooseStockPanel.UpdateStockCombos(Stock);
end;

{Обработка события. Редактирование акции}
procedure TForm1.OnEditStock(sender : tObject;Stock : IStock);
begin
  fchooseStockPanel.UpdateStockCombos(Stock);
end;

procedure TForm1.OnExchangeCoutry(sender: tObject);
begin
 // fchooseStockPanel.Fill_Country_Combo(StocksData.ChosenStock.Country);
end;

procedure TForm1.OnExchangeIndustry(sender: tObject);
begin
 // fchooseStockPanel.Fill_Industry_Combo(StocksData.ChosenStock.Industry);
end;

procedure TForm1.OnSortFilteredStocks(sender: tObject);
begin
  fchooseStockPanel.UpdateStockCombo;
end;



{Обработка события. Изменен признак сохранения}
procedure TForm1.OnSaved(Sender: TObject);
begin
  ToolButton2.Enabled:=not StocksData.IsSaved;
end;


procedure TForm1.Button1Click(Sender: TObject);{"Купил"}
begin
  StocksData.AddOperationToChosenStock(DateEdit1.Date,_Operation_Buy,strtoint(Edit1.Text),StrToFloat(Edit2.Text));
end;

procedure TForm1.Button2Click(Sender: TObject);{"Продал"}
begin
  StocksData.AddOperationToChosenStock(DateEdit1.Date,_Operation_Sell,strtoint(Edit1.Text),StrToFloat(Edit2.Text));
end;


procedure TForm1.Action_BackUpExecute(Sender: TObject);
var backUpTime : double=0;
begin
  StocksData.BackUP(backUpTime);
end;

{Действие "добавить акцию"}
procedure TForm1.Action_add_stockExecute(Sender: TObject);
begin
  Form2.StockMode:=_SMAdd;
  Form2.Visible:=true;
end;

procedure TForm1.Action_editExecute(Sender: TObject);
begin

end;

{Действие "Редактировать акцию"}
procedure TForm1.Action_edit_stockExecute(Sender: TObject);
begin
  Form2.StockMode:=_SMEdit;
  Form2.Visible:=true;
end;

procedure TForm1.Action_SaveExecute(Sender: TObject);
begin
  StocksData.WriteToXML;
end;

procedure TForm1.Action_SettingsExecute(Sender: TObject);{Настройки свойств}
begin
  Form4.Show;
end;

procedure TForm1.StockPriceSaveBtnClick(Sender: TObject);
begin

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

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  StocksData.WriteToSettingsXML();
  if (not StocksData.IsSaved) and (MessageDlg('Сохранение в XML ','Cохранить параметры акций в XML', mtConfirmation,[mbYes,mbNo,mbAbort],0)=mrYes)
  then StocksData.WriteToXML;
end;


end.


