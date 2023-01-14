unit Grid_Stocks;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Grids, Stocks_Data, Stock;

type
  ptStringGrid = ^TStringGrid;

  { tGrid_Stocks }
  tGrid_Stocks = class
   private
    fStocksGrid : ptStringGrid;
    fStockList  : IStockList;
   public
    constructor Create(aStocksGrid: ptStringGrid);
    procedure Update(const Country : string);
  end;

implementation

{ tGrid_Stocks }
constructor tGrid_Stocks.Create(aStocksGrid: ptStringGrid);
begin
  fStocksGrid:=aStocksGrid;
  fStockList :=IStockList.Create;
end;

procedure tGrid_Stocks.Update(const Country: string);
var tekStock : IStock;
    rowIndex : integer=1;
begin
  fStockList.Clear;
  if AnsiLowerCase(country)='все'
  then fStockList.Assign(StocksData.StockList)
  else
   begin
     for tekStock in StocksData.StockList do
       if AnsiLowerCase(tekStock.Country) = AnsiLowerCase(Country)
       then fStockList.Add(tekStock);
   end;
  fStocksGrid^.RowCount:=fStockList.Count+1;
  for tekStock in fStockList do
   begin
     fStocksGrid^.Cells[0,rowIndex]:=IntToStr(rowIndex);
     fStocksGrid^.Cells[1,rowIndex]:=tekStock.Name;
     fStocksGrid^.Cells[2,rowIndex]:=IntToStr(tekStock.stockCount);
     fStocksGrid^.Cells[3,rowIndex]:=tekStock.averagePrice;
     fStocksGrid^.Cells[4,rowIndex]:=tekStock.sumPrice;
     fStocksGrid^.Cells[5,rowIndex]:=tekStock.balance;

     inc(rowIndex);
   end;
end;

end.

