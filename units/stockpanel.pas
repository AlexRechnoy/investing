unit stockPanel;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Controls, StdCtrls,
  stockGrid, Stocks_Data, stock_Observer, Stock;

type

  { tStockPanel }

  tStockPanel = class (TPanel, IObserver)
   private
     fGrid  : tStockGrid;
     fList  : TListBox;
     fLabel : TLabel;
   public
     constructor create(AOwner : TComponent);
     procedure UpdateStock(stock : IStock);
     procedure UpdateStockList(stock : IStockList);
  end;

implementation

{ tStockPanel }

constructor tStockPanel.create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  self.Parent:=AOwner as TWinControl;
  self.Align:=alClient;
  fLabel:=TLabel.Create(self);
  fLabel.parent:=self;
  fLabel.Caption:='История операций';
  fLabel.Align:=alTop;
  fGrid:=tStockGrid.Create(self);
  fGrid.Align:=alTop;
  fList:=TListBox.Create(self);
  fList.Parent:=self;
  fList.Align:=alClient;
  StocksData.registerObserver(self);
end;

procedure tStockPanel.UpdateStock(stock : IStock);
begin
  fGrid.updateData(stock);
  fList.Clear;
  fList.Items.AddStrings(stock.OperationListStr);
end;

procedure tStockPanel.UpdateStockList(stock: IStockList);
begin

end;

end.

