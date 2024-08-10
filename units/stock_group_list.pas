unit Stock_group_list;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl, Stock, Stock_list, Stock_group;

type

  { tGroupStatsList }
  tGroupStatsList = class(specialize TFPGList<tStockGroup>)
   private
     fCompanyCount : integer;
     fSumPriceUSD  : double;
   protected
     function getIndex(const GroupName : string): integer;
     procedure CalcSummaryStats;
   public
     constructor  Create;
     procedure addStock    (const AStock: IStock; const AGroupName : string;  const AUSDToRUB: double; const APortfolio : string='все');
     procedure addStockList(const AStockList: TStockList; const AUSDToRUB: double; const APortfolio : string = 'все'); virtual; abstract;
     procedure SortByPrice;
     property CompanyCount: integer read fCompanyCount;
     property SumPriceUSD : double read fSumPriceUSD;
  end;



implementation

function sort_by_sum_price(const I1 ,I2 : tStockGroup) : LongInt;
begin
  if I1.Price<I2.Price then result:=1 else
    if I1.Price>I2.Price then result:=-1 else
      result:=0;
end;

{ tIndustryList }
constructor tGroupStatsList.Create;
begin
  Inherited Create;
end;

function tGroupStatsList.getIndex(const GroupName: string): integer;
var tekGroup    : tStockGroup;
    index       : integer=0;
begin
  result:=-1;
  for tekGroup in self do
   begin
     if tekGroup.Name=GroupName then
      begin
        result:=index;
        exit;
      end;
     inc(index);
    end;
end;

procedure tGroupStatsList.CalcSummaryStats;
var tekGroup : tStockGroup;
begin
  fCompanyCount:=0;
  fSumPriceUSD :=0;
  for tekGroup in self do
   begin
     fCompanyCount:=fCompanyCount+tekGroup.CompanyCount;
     fSumPriceUSD :=fSumPriceUSD+tekGroup.Price;
   end;
end;

procedure tGroupStatsList.addStock(const AStock: IStock; const AGroupName: string;
                                   const AUSDToRUB: double; const APortfolio: string);
var index       : integer;
    PriceUSD    : double;
begin
  if (ansilowercase(APortfolio)<>'все') then
    if not AStock.getIsInPortfolio(APortfolio)
    then exit;

  if ansilowercase(AStock.Name)='usd' then exit;
  if ansilowercase(AStock.Country)='россия'
  then PriceUSD:=AStock.sumPrice/aUSDToRUB
  else PriceUSD:=AStock.sumPrice;
  index:=getIndex(AGroupName);
  if index=-1
  then self.Add(tStockGroup.Create(AGroupName,PriceUSD))
  else self[index].AddStock(PriceUSD);
end;

procedure tGroupStatsList.SortByPrice;
begin
  self.Sort(@sort_by_sum_price);
  CalcSummaryStats;
end;

end.

