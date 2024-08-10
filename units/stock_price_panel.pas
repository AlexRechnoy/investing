unit Stock_Price_Panel;
{Панель, на которой отображается/ сохраняется цена выбранной акции             }

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Buttons, StdCtrls, Stocks_Data, Portfolio_Data,
  Stock_Observer, Stock, Stock_filtered_list;

type

  { tStockPricePanel }

  tStockPricePanel = class (TInterfacedObject,IObserver)
   private
    FForm           : TForm;
    FStockPriceEdit : TEdit;
    FStockPriceBtn  : TBitBtn;
    procedure OnStockPriceBtnClick(Sender : TObject);
   public
    constructor Create(AForm : TForm);
    procedure UpdateStock(stock : IStock);
    procedure UpdateFilteredStockList(StockFilteredList : TStockFilteredList);
  end;

implementation

{ tStockPricePanel }

constructor tStockPricePanel.Create(AForm: TForm);
begin
  FForm:=AForm;
  FStockPriceEdit :=FForm.FindComponent('StockPriceEdit') as TEdit ;

  FStockPriceBtn  :=FForm.FindComponent('StockPriceSaveBtn') as TBitBtn ;
  FStockPriceBtn.OnClick:=@OnStockPriceBtnClick;

  StocksData.registerObserver(self);
end;

procedure tStockPricePanel.UpdateStock(stock: IStock);
begin
  FStockPriceBtn.Enabled :=Assigned(stock);
  FStockPriceEdit.Enabled:=Assigned(stock);
  if Assigned(stock)
  then FStockPriceEdit.Text:=Format('%4.2f',[stock.CurrentPrice])
end;

procedure tStockPricePanel.UpdateFilteredStockList(StockFilteredList : TStockFilteredList);
begin

end;

procedure tStockPricePanel.OnStockPriceBtnClick(Sender: TObject);
begin
  StocksData.SaveCurrentStockPrice(strtofloat(FStockPriceEdit.Text));
  PortfolioData.UpdatePortfolioStats;
end;

end.

