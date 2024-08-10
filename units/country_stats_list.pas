unit Country_stats_list;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Stock,  Stock_list, Stock_group_list;

type
  tCountryStatsList = class (tGroupStatsList)
   public
    procedure addStockList(const AStockList: TStockList; const AUSDToRUB: double; const APortfolio : string = 'все'); override;
  end;

implementation

procedure tCountryStatsList.addStockList(const AStockList: TStockList; const AUSDToRUB: double; const APortfolio : string = 'все');
var tekStock : IStock;
begin
  self.Clear;
  for tekStock in AstockList do
    addStock(tekStock,tekStock.Country,aUSDToRUB);
end;

end.
