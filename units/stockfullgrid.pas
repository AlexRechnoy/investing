unit stockFullGrid;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Grids, Controls, Graphics,
  Stocks_Data, Stock, stock_Observer;

type
  ptStringGrid = ^TStringGrid;

  { tGrid_Stocks }
  tGrid_Stocks = class(TStringGrid, IObserver)
   private
    fStockList: IStockList;
   public
    constructor Create(const AOwner : TComponent);
    procedure UpdateStock(stock : IStock);
    procedure UpdateStockList(stockList : IStockList);
    procedure OnGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
  end;

implementation

{ tGrid_Stocks }
constructor tGrid_Stocks.Create(const AOwner : TComponent);
begin
  inherited create(AOwner);
  self.Parent      :=AOwner as TWinControl;
  self.Align       :=alClient;
  self.ColCount    :=6;
  self.OnDrawCell  :=@OnGridDrawCell;
  self.ColWidths[0]:=20;
  self.ColWidths[1]:=150;
  self.Cells[1,0]  :='Название';
  self.Cells[2,0]  :='Кол-во';
  self.Cells[3,0]  :='Ср.стоимость';
  self.Cells[4,0]  :='Сумма';
  self.Cells[5,0]  :='Баланс';
  self.Options:=[goFixedHorzLine,goFixedVertLine,goHorzLine,goVertLine,goSmoothScroll,goThumbTracking];
  fStockList:=IStockList.Create;
  StocksData.registerObserver(self);
end;

procedure tGrid_Stocks.UpdateStock(stock: IStock);
begin
end;

procedure tGrid_Stocks.OnGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
   function getColor(stock : IStock) : tcolor;
   var positiveColor : tcolor;
       negativeColor : tcolor;
   const balanceColors : array [boolean] of tcolor = (clRed,clGreen);
   begin
     positiveColor:=RGBToColor(128,230,140);
     negativeColor:=RGBToColor(248,123,105);
     Result:=clWhite;
     if stock.Count=0
     then
      begin
        if stock.balance>0 then result:=positiveColor else result:=negativeColor;
      end
     else if stock.sumPrice<0 then Result:=positiveColor;
   end;
begin
  if (aRow>0) and (aCol>0) then
   begin
     if aCol=1
     then self.Canvas.Font.Style:=[fsBold];
     self.Canvas.Brush.Color:=getColor(fStockList[aRow-1]);
     self.Canvas.FillRect(aRect);
     self.Canvas.TextOut(aRect.Left,aRect.Top,self.Cells[ACol,ARow]);
   end;
end;

procedure tGrid_Stocks.UpdateStockList(stockList: IStockList);
var rowIndex : integer=1;
    stock    : IStock;
    function hideNegative(val : double):string;
    begin
      Result:='<0';
      if val>=0 then Result:=Format('%4.2f',[val]);
    end;
begin
  fStockList:=stockList;
  self.RowCount:=stockList.Count+1;
  for stock in stockList do
   begin
     self.Cells[1,rowIndex]:=stock.Name;
     self.Cells[2,rowIndex]:=inttostr(stock.Count);
     if stock.Count=0
     then self.Cells[3,rowIndex]:='-'
     else self.Cells[3,rowIndex]:=hideNegative(stock.averagePrice);
     if stock.Count=0
     then self.Cells[4,rowIndex]:='-'
     else self.Cells[4,rowIndex]:=hideNegative(stock.sumPrice);
     if stock.Count=0
     then self.Cells[5,rowIndex]:=Format('%4.2f',[stock.balance])
     else
      begin
        if stock.sumPrice<0
        then self.Cells[5,rowIndex]:=Format('%4.2f + акции на руках',[stock.balance])
        else self.Cells[5,rowIndex]:='-';
      end;
     inc(rowIndex);
   end;
end;

end.

