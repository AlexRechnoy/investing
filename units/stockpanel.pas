unit stockPanel;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Controls, StdCtrls, ComCtrls,
  Stock_Property_Grid, Stocks_Data, Stock_filtered_list, Graphics,
  stock_Observer, Stock, Stock_Operation, Dialogs;

type

  { tStockPanel }

  tStockPanel = class (TPanel, IObserver)
   private
     fGrid          : tStockPropertyGrid;
     fToolBar       : TToolBar;
     fList          : TListBox;
     fLabel         : TLabel;
     fSelectedStock : IStock;
     procedure DeleteLastOperation(Sender : TObject);
     procedure DeleteAllOperations(Sender : TObject);
     procedure ListDrawItem(Control: TWinControl; Index: Integer;
                            ARect: TRect; State: TOwnerDrawState);
   public
     constructor create(AOwner: TComponent; AImageList : TImageList);
     procedure UpdateStock(stock : IStock);
     procedure UpdateFilteredStockList(StockFilteredList : TStockFilteredList);
  end;

implementation

{ tStockPanel }
constructor tStockPanel.create(AOwner: TComponent; AImageList : TImageList);
    function createToolButton(const AImageIndex : integer = -1;
                              const AHint : string = '';
                              AOnClick : TNotifyEvent = nil ;
                              const isSeparator : boolean = false) : TToolButton;
    begin
      result:=TToolButton.Create(fToolBar);
      result.Parent    :=fToolBar;
      result.Hint      :=AHint;
      result.BorderSpacing.Left:=20;
      result.ImageIndex:=AImageIndex;
      result.OnClick   :=AOnClick;
      if isSeparator
      then result.Style:=tbsSeparator;
    end;

begin
  inherited Create(AOwner);
  fSelectedStock:=nil;
  self.Parent:=AOwner as TWinControl;
  self.Align:=alClient;
  fLabel:=TLabel.Create(self);
  fLabel.parent:=self;
  fLabel.Caption:='История операций';
  fLabel.Align:=alTop;

  fToolBar:=TToolBar.Create(Self);
  fToolBar.Parent:=self;
  fToolBar.Align :=alTop;
  fToolBar.Images:=AImageList;
  fToolBar.ButtonHeight:=22;
  fToolBar.ButtonWidth:=22;
  fToolBar.ShowHint:=true;
  fToolBar.ButtonList.Add(createToolButton(5,'Удалить последнюю операцию',@DeleteLastOperation));
  fToolBar.ButtonList.Add(createToolButton(-1,'',nil,true));
  fToolBar.ButtonList.Add(createToolButton(6,'Удалить все операции',@DeleteAllOperations));

  fGrid:=tStockPropertyGrid.Create(self);
  fGrid.Align:=alTop;
  fList:=TListBox.Create(self);
  fList.Style:=lbOwnerDrawVariable;
  fList.Parent:=self;
  fList.OnDrawItem:=@ListDrawItem;
  fList.Align:=alClient;
  StocksData.registerObserver(self);
end;

procedure tStockPanel.DeleteLastOperation(Sender: TObject);
begin
  StocksData.DeleteLastStockOperation;
end;

procedure tStockPanel.DeleteAllOperations(Sender: TObject);
begin
  If MessageDlg('Подтверждение удаления','Точно удалить все операции?', mtConfirmation,[mbYes,mbNo,mbAbort],0)=mrYes
  then StocksData.DeleteAllStockOperations;
end;

procedure tStockPanel.ListDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    function getOperationNum(const ATxtOperationNum : integer) : integer;
    begin
      Result:=fSelectedStock.OperationList.Count-ATxtOperationNum;
    end;

begin
  if Assigned(fSelectedStock) and
     (Index>0) and
     (fSelectedStock.OperationList[getOperationNum(Index)].GetOperationType=_Operation_Buy) then
    begin
      fList.Canvas.Brush.Color:=RGBToColor(145,238,160);
    end;
  fList.Canvas.FillRect(ARect);
  fList.Canvas.TextOut(ARect.Left, ARect.Top, fList.Items[Index])
end;

procedure tStockPanel.UpdateStock(stock : IStock);
begin
  fSelectedStock:=Stock;
  fList.Clear;
  if stock=nil then
   begin
     fGrid.Visible:=false;
     exit;
   end;
  fGrid.updateData(stock);
  fList.Clear;
  fList.Items.AddStrings(stock.OperationListStr);
end;

procedure tStockPanel.UpdateFilteredStockList(StockFilteredList : TStockFilteredList);
begin

end;

end.

