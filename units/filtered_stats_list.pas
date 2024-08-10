unit Filtered_stats_list;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Stock,  Stock_list, Stock_group_list;

type
  tFilteredStatsList = class (tGroupStatsList)
   private
    fSumPriceUSD  : double;     //Суммарная стоимость всех отфильтрованных акций
    fBalanceUSD   : double;     //Баланс в долларах
    fBalancePerc  : double;     //Баланс в процентах от вложенного
    fInvested     : double;     //Вложено денег
   public
    procedure addStockList(const AStockList: TStockList; const AUSDToRUB: double; const APortfolio : string = 'все'); override;
    property SumPriceUSD: double read fSumPriceUSD;
    property BalanceUSD: double read fBalanceUSD;
    property BalancePerc: double  read fBalancePerc;
    property Invested: double  read fInvested;
  end;

implementation

procedure tFilteredStatsList.addStockList(const AStockList: TStockList; const AUSDToRUB: double; const APortfolio : string = 'все');
var currStock : IStock; s : string;  d : double;
begin
  self.Clear;
  fSumPriceUSD:=0;
  fBalanceUSD:=0;
  for currStock in AstockList do
    begin
      //addStock(currStock,'filteredStats',aUSDToRUB);

      if ansilowercase(currStock.Country)='россия'
      then
        begin
          fSumPriceUSD:=fSumPriceUSD+currStock.sumPrice/AUSDToRUB;
          fBalanceUSD :=fBalanceUSD+currStock.balance/AUSDToRUB  ;
        end
      else
        begin
          if ansilowercase(currStock.Name)='usd' then continue;
          fSumPriceUSD:=fSumPriceUSD+currStock.sumPrice;
          fBalanceUSD :=fBalanceUSD+currStock.balance;
        end;
    end;

  if fSumPriceUSD-fBalanceUSD=0
  then fBalancePerc:=0
  else fBalancePerc:=fBalanceUSD/(fSumPriceUSD-fBalanceUSD)*100;
  fInvested:= fSumPriceUSD - fBalanceUSD;
end;


end.

