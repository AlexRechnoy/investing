unit Tab_Portfolio;
{Вкладка "Портфель". Граф элементы панели , относящиесли к портфелю            }

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ComCtrls, StdCtrls, ExtCtrls, Forms, Buttons, ActnList,
  Dialogs, Controls, Stocks_Data, Portfolio_Data, Stock, add_portfolio_unit,
  Portfolio_Grid;

type
    pTTabSheet = ^TTabSheet;
  { tPortfolioPanel }

  tPortfolioTab = class
    private
      FForm               : TForm;    //Ссылка на главную форму
      FPrtfListBox        : TListBox; //Листбокс акций портфеля
      FOutPrtfListBox     : TListBox; //Листбокс акций вне портфеля
      FAddStockBtn        : TBitBtn;  //Кнопка "добавить выбранную акцию в портфель"
      FDelStockBtn        : TBitBtn;  //Кнопка "удалить выбранную акцию в портфель"
      FToolBar            : TToolBar; //Панель инструментов
      FPrtfCombo          : TComboBox;//Комбобокс портфелей
      FPrtfGridPanel      : TPanel;   //Панель таблицы портфелей
      FAddPortfolioAction : TAction;
      FPortfolioGrid      : tPortfolioGrid; //Панель портфелей
    private
      procedure OnPrtfListBoxClick(Sender : TObject);
      procedure OnOutPrtfListBoxClick(Sender : TObject);
      procedure OnAddStockBtnClick(Sender : TObject);
      procedure OnDelStockBtnClick(Sender : TObject);
      procedure OnPortfolioComboChange(Sender : TObject);

      procedure OnAddPortfolioClick(Sender : TObject);
      procedure OnDelPortfolioClick(Sender : TObject);
    private
      procedure fillPortfolioCombo; //Заполнить комбо портфелей}
      procedure fillPortfolioListBoxes;
      procedure AddPortfolio(Sender : TObject ; Name : string);
    public
      constructor Create(AForm : TForm);
  end;


implementation

{ tPortfolioPanel }

constructor tPortfolioTab.Create(AForm: TForm);
begin
  FForm                  :=AForm;
  FPrtfListBox           :=FForm.FindComponent('PortfolioListBox') as TListBox ;
  FPrtfListBox.OnClick   :=@OnPrtfListBoxClick;

  FOutPrtfListBox        :=FForm.FindComponent('OutsidePortfolioListBox') as TListBox ;
  FOutPrtfListBox.OnClick:=@OnOutPrtfListBoxClick;

  FAddStockBtn           :=FForm.FindComponent('AddStockToPortfolioBtn') as TBitBtn;
  FAddStockBtn.OnClick   :=@OnAddStockBtnClick;
  FDelStockBtn           :=FForm.FindComponent('DelStockFromPortfolioBtn') as TBitBtn;
  FDelStockBtn.OnClick   :=@OnDelStockBtnClick;

  FPrtfCombo             :=FForm.FindComponent('PortfolioCombo') as TComboBox;
  FPrtfCombo.OnChange    :=@OnPortfolioComboChange;

  FPrtfGridPanel         :=FForm.FindComponent('PortfolioGridPanel') as TPanel;
  FPortfolioGrid         :=tPortfolioGrid.Create(FPrtfGridPanel);

  FToolBar               :=FForm.FindComponent('ToolBar3') as TToolBar;
  FToolBar.Buttons[0].OnClick:=@OnAddPortfolioClick;
  FToolBar.Buttons[1].OnClick:=@OnDelPortfolioClick;

  fillPortfolioCombo;
  PortfolioData.OnAddPortfolio:=@AddPortfolio;
  PortfolioData.notifyObservers();
end;

procedure tPortfolioTab.OnPrtfListBoxClick(Sender: TObject);
begin
  if FPrtfListBox.ItemIndex>-1
  then PortfolioData.ChosenStock:=PortfolioData.Get_Stock_In_Portfolio(FPrtfListBox.Items[FPrtfListBox.ItemIndex])
  else PortfolioData.ChosenStock:=nil;
end;

procedure tPortfolioTab.OnOutPrtfListBoxClick(Sender: TObject);
begin
  if FOutPrtfListBox.ItemIndex>-1
  then PortfolioData.OutSideStock:=PortfolioData.Get_Outside_Stock(FOutPrtfListBox.Items[FOutPrtfListBox.ItemIndex])
  else PortfolioData.OutSideStock:=nil;
end;

procedure tPortfolioTab.OnAddStockBtnClick(Sender: TObject);
begin
  if (PortfolioData.OutsideStock<>nil) then
   begin
     PortfolioData.Add_Stock_To_Portfolio;
     fillPortfolioListBoxes;
     StocksData.IsSaved:=false;
   end;
end;

procedure tPortfolioTab.OnDelStockBtnClick(Sender: TObject);
begin
  if (PortfolioData.ChosenStock<>nil) then
   begin
     PortfolioData.Delete_Stock_From_Portfolio;
     fillPortfolioListBoxes;
     StocksData.IsSaved:=false;
   end;
end;

procedure tPortfolioTab.OnPortfolioComboChange(Sender: TObject);
begin
  PortfolioData.SetPortfolio(FPrtfCombo.ItemIndex);
  fillPortfolioListBoxes;
end;

procedure tPortfolioTab.OnAddPortfolioClick(Sender: TObject);
begin
  Form3.Visible:=true;
end;

procedure tPortfolioTab.OnDelPortfolioClick(Sender: TObject);
begin
  if MessageDlg('Удаление портфеля', Format('Удалить портфель "%s"?',[PortfolioData.PortfolioName]), mtConfirmation,[mbYes,mbNo,mbAbort],0)=mrYes then
   begin
     PortfolioData.Delete_Portfolio;
     fillPortfolioCombo;
   end;
end;

procedure tPortfolioTab.fillPortfolioCombo; {Заполнить комбо портфелей}
var PortfolioCombo           : TComboBox;
    AddStockToPortfolioBtn   : TBitBtn;
    DelStockFromPortfolioBtn : TBitBtn;  s:string;
begin
  PortfolioCombo           :=FForm.FindComponent('PortfolioCombo') as TComboBox;
  AddStockToPortfolioBtn   :=FForm.FindComponent('AddStockToPortfolioBtn') as TBitBtn;
  DelStockFromPortfolioBtn :=FForm.FindComponent('DelStockFromPortfolioBtn') as TBitBtn;
  PortfolioCombo.Clear;
  PortfolioCombo.Items.AddStrings(PortfolioData.PortfolioNames);
  if PortfolioCombo.Items.Count>0 then
   begin
     PortfolioCombo.ItemIndex:=0;
     PortfolioData.SetPortfolio(0);
   end
  else
   begin
     PortfolioData.SetPortfolio(-1);
   end;
  AddStockToPortfolioBtn.Enabled:=PortfolioData.HasActivePortfolio;
  DelStockFromPortfolioBtn.Enabled:=PortfolioData.HasActivePortfolio;
  fillPortfolioListBoxes;

  s:=PortfolioData.PortFolioList.Last.PortfolioName;
end;

procedure tPortfolioTab.fillPortfolioListBoxes;
var tekStock                : IStock;
    PortfolioListBox        : TListBox;
    OutsidePortfolioListBox : TListBox;
begin
  PortfolioListBox       :=FForm.FindComponent('PortfolioListBox') as TListBox;
  OutsidePortfolioListBox:=FForm.FindComponent('OutsidePortfolioListBox') as TListBox;
  PortfolioListBox.Clear;
  OutsidePortfolioListBox.Clear;
  for tekStock in PortfolioData.StockList do
    PortfolioListBox.Items.Add(tekStock.Name);
  for tekStock in PortfolioData.OutsideStockList do
    OutsidePortfolioListBox.Items.Add(tekStock.Name);
end;

procedure tPortfolioTab.AddPortfolio(Sender: TObject; Name: string);
begin
  fillPortfolioCombo;
end;

end.

