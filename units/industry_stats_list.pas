unit Industry_stats_list;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Stock_group_list, Stock,  Stock_list;

type

  { tIndustryStatsList }
  tIndustryStatsList = class (tGroupStatsList)
   public
    procedure addStockList(const AStockList: TStockList; const AUSDToRUB: double; const APortfolio : string = 'все'); override;
  end;

implementation

procedure tIndustryStatsList.addStockList(const AStockList: TStockList;  const AUSDToRUB: double; const APortfolio: string);
var tekStock : IStock;
begin
  self.Clear;
  for tekStock in AstockList do
    addStock(tekStock,tekStock.Industry,aUSDToRUB,APortfolio);
end;

end.

