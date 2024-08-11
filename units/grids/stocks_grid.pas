unit Stocks_Grid;
{Таблица, в которой отображается список акций (отфильтрованный по              }
{стране/отрасли/портфелю)                                                      }

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl, Grids, Controls, Graphics,  Filtered_stats_list,
  Stocks_Data, Stock, Stock_list, Stock_filtered_list, Stock_group_list,  stock_Observer;

type
  ptStringGrid = ^TStringGrid;
  tRowStockMap = specialize TFPGMap<integer,IStock>;

  { tStocksGrid }
  tStocksGrid = class(TStringGrid, IObserver, IStatsObserver)
   private
    fRowStockMap       : tRowStockMap;
    fStockList         : TStockList;
    fHasSumRow         : boolean;
    fFilteredStatsList : tFilteredStatsList;
    FSortedFunc        : TSortStockListFunc;
    FSortedColumnIndex : byte; //Номер выбранного столбца (щелчок по заголовку)
    procedure GridHeaderClick(Sender: TObject; IsColumn: Boolean; Index: Integer);
    procedure DrawSumStats;
   public
    constructor Create(const AOwner : TComponent);
    procedure UpdateStock(stock : IStock);
    procedure UpdateFilteredStockList(StockFilteredList : TStockFilteredList);
    procedure UpdateStats(industryStatsList, countryStatsList, filteredStatsList : tGroupStatsList);
    procedure OnGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
  end;

implementation

const name_col   = 1;
      currPrice_col=4;
      percent_col= 5;
      price_col  = 6;
      balance_col= 7;

      sort_rows = [name_col, percent_col, price_col, balance_col];

{ tGrid_Stocks }
constructor tStocksGrid.Create(const AOwner : TComponent);
begin
  inherited create(AOwner);
  fRowStockMap     :=tRowStockMap.Create;
  self.Parent      :=AOwner as TWinControl;
  self.Align       :=alClient;
  self.ColCount    :=8;
  self.OnDrawCell  :=@OnGridDrawCell;
  self.ColWidths[0]:=20;
  self.ColWidths[name_col]:=150;
  self.Cells[1,0]  :='Название';
  self.Cells[2,0]  :='Кол-во';
  self.Cells[3,0]  :='Ср.стоимость';
  self.Cells[4,0]  :='Тек.цена';
  self.Cells[5,0]  :='% цены';
  self.Cells[6,0]  :='Сумма';
  self.Cells[7,0]  :='Баланс';
  self.OnHeaderClick:=@GridHeaderClick;
  self.Options:=[goFixedHorzLine,goFixedVertLine,goHorzLine,goVertLine,goSmoothScroll,goThumbTracking];
  fStockList:=TStockList.Create;
  fFilteredStatsList :=tFilteredStatsList.Create;
  StocksData.registerObserver(self);
  StocksData.StockStats.registerStatsObserver(self);
  self.RowCount:=1;
end;

procedure tStocksGrid.UpdateStock(stock: IStock);
begin

end;

procedure tStocksGrid.GridHeaderClick(Sender: TObject; IsColumn: Boolean; Index: Integer);
begin
  if not (index in sort_rows)
  then exit;

  FSortedColumnIndex:=Index;
  case FSortedColumnIndex of
      name_col   : FSortedFunc:=@sort_stock_list_by_name;
      percent_col: FSortedFunc:=@sort_stock_list_by_price_percent;
      price_col  : FSortedFunc:=@sort_stock_list_by_sum_price;
      balance_col: FSortedFunc:=@sort_stock_list_by_balance;
  end;
  StocksData.SortFilteredList(FSortedFunc);
  //fStockList.Sort(FSortedFunc);
  //UpdateFilteredStockList(fStockList);
  DrawSumStats;
end;

procedure tStocksGrid.OnGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
   function getColor(stock : IStock) : tcolor;
   var positiveColor      : tcolor;
       negativeColor      : tcolor;
       notActualDateColor : tcolor;{Кол-во акций>0 , дата текущей цены устарела (указана больше месяца назад)}
       successfulColor    : TColor;{Кол-во акций =0 и баланс >0 ; Кол-во акций>0, указана текущая цена и средняя стоимость <0}
   const balanceColors : array [boolean] of tcolor = (clRed,clGreen);
   begin
     positiveColor     :=RGBToColor(145,238,160);
     successfulColor   :=RGBToColor(55,215,75);
     negativeColor     :=RGBToColor(248,123,105);
     notActualDateColor:=RGBToColor(242,242,151);
     Result:=clWhite;
     if stock.Count=0
     then
      begin
        if stock.balance>0
        then result:=successfulColor
        else result:=negativeColor;
      end
     else
      begin
        if (aCol=currPrice_col) and (not stock.GetCurrentPriceDateIsActual  ) then
          begin
            Result:=notActualDateColor;
            exit;
          end;
        if stock.CurrentPrice>0 then //указана текущая цена
         begin
           if stock.averagePrice<0
           then Result:=successfulColor
           else
             begin
               if stock.balance>0
               then Result:=positiveColor
               else Result:=negativeColor;
             end;
         end
        else
         begin
           if stock.sumPrice<0
           then Result:=positiveColor;
         end;
      end;
   end;
begin
  self.font.Style:=[];
  if Col=0 then exit;

  if (acol=FSortedColumnIndex)
  then self.font.Style:=[fsBold];

  if (aRow>0) then
    begin
      if (fHasSumRow) and (ARow = self.RowCount-1) then
        begin
          self.Canvas.Font.Style:=[fsBold];
          self.Canvas.Font.Size:=10;
        end;
      if (aCol=name_col) and (fRowStockMap.IndexOf(aRow)>=0) and (fRowStockMap.KeyData[aRow].Count>0)
      then self.Canvas.Font.Style:=[fsBold];
      if (fRowStockMap.IndexOf(aRow)>=0)
      then self.Canvas.Brush.Color:=getColor(fRowStockMap.KeyData[aRow]);
    end;

  self.Canvas.FillRect(aRect);
  self.Canvas.TextOut(aRect.Left,aRect.Top,self.Cells[ACol,ARow]);
end;

procedure tStocksGrid.UpdateFilteredStockList(
  StockFilteredList: TStockFilteredList);
var rowIndex : integer=1;
    stock    : IStock;
    function hideZero(const valTxt : string; val : double):string;
    begin
      Result:=valTxt;
      if val=0
      then Result:='-';
    end;
    function hideNegative(stockCount : integer; val : double):string;
    begin
      if stockCount=0 then
       begin
         Result:='-';
         exit;
       end;
      Result:='<0';
      if val>=0 then Result:=Format('%4.2f',[val]);
    end;
begin
  fStockList:=StockFilteredList;

  fRowStockMap.Clear;
  self.RowCount:=1;
  for stock in StockFilteredList do
   begin
     if stock.isCurrency then continue;
     fRowStockMap.Add(rowIndex,stock);
     self.RowCount:=self.RowCount+1;
     self.Cells[0,rowIndex]:=Format('%d',[rowIndex]);
     self.Cells[1,rowIndex]:=stock.Name;
     self.Cells[2,rowIndex]:=inttostr(stock.Count);
     self.Cells[3,rowIndex]:=hideNegative(stock.Count,stock.averagePrice);
     self.Cells[4,rowIndex]:=Format('%4.2f',[stock.CurrentPrice]);
     self.Cells[5,rowIndex]:=hideZero(Format('%4.1f %%',[stock.DeltaPricePercent]), stock.DeltaPricePercent );
     self.Cells[6,rowIndex]:=hideNegative(stock.Count,stock.sumPrice);

     if stock.Count=0
     then self.Cells[7,rowIndex]:=Format('%4.2f',[stock.balance])
     else
      begin
        if stock.CurrentPrice>0
        then self.Cells[7,rowIndex]:=Format('%4.2f',[stock.balance])
        else
         begin
           if stock.balance>0
           then self.Cells[7,rowIndex]:=Format('%4.2f + акции на руках',[stock.balance])
           else self.Cells[7,rowIndex]:='-';
         end;
      end;

     inc(rowIndex);
   end;
  fHasSumRow:=self.RowCount>2;
  if fHasSumRow then
    begin
      Self.RowCount:=Self.RowCount+1;

    end;
end;

procedure tStocksGrid.UpdateStats(industryStatsList, countryStatsList, filteredStatsList: tGroupStatsList);
begin
  fFilteredStatsList:= filteredStatsList as tFilteredStatsList;
  DrawSumStats;
end;

procedure tStocksGrid.DrawSumStats;
begin
  if fHasSumRow then
    begin
      self.Cells[1,self.RowCount-1]:=Format('Вложено: %4.0f USD',[fFilteredStatsList.Invested]);
      self.Cells[5,self.RowCount-1]:=Format('%4.1f %%',[fFilteredStatsList.BalancePerc]);
      self.Cells[6,self.RowCount-1]:=Format('%4.0f USD',[fFilteredStatsList.SumPriceUSD]);
      self.Cells[7,self.RowCount-1]:=Format('%4.0f USD',[fFilteredStatsList.BalanceUSD]);
    end;
end;

end.

