unit Portfolio;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, Stock,  Stock_list, Stocks_Data;

type

  { tPortfolio }
  tPortfolio = class
   private
    fCompanyCount : integer;    //Кол-во компаний в портфеле
    fSumPriceUSD  : double;     //Суммарная стоимость всех акций в портфеле
    fBalanceUSD   : double;     //Баланс в долларах
    fBalancePerc  : double;     //Баланс в процентах от вложенного
    fName         : string;     //Название порфеля
    fStockList    : TStockList; //Список акций портфеля
   public
    constructor Create(aName : string);
    constructor Create(aName : string; aStock : IStock);
    procedure UpdatePortfolioStats;
    function Get_Stock(const Name : string) : IStock; //найти акцию в портфеле по названию
    procedure Add_Stock(aStock : IStock; const addToPortfolio : boolean =true); //В варианте инициализации
                                                 //не надо добавлять название портфеля в список портфелей выбранной акции, т.к.
                                                 //список портефелей уже считан из xml-файла
    procedure Delete_Stock(aStock : IStock);
    property PortfolioName : string read fName;
    property Stocks : TStockList read fStockList;
    property SumPriceUSD : double read fSumPriceUSD;
    property BalanceUSD : double read fBalanceUSD;
    property BalancePercent : double read fBalancePerc;
    property CompanyCount : integer read fCompanyCount;
  end;
  ptPortfolio = ^ tPortfolio;

//tPortfolio_List = specialize TFPGList<tPortfolio>;

implementation

{ tStock_Portfolio }
constructor tPortfolio.Create(aName: string);
begin
  fName:=AName;
  fStockList :=TStockList.Create;
end;

constructor tPortfolio.Create(aName: string; aStock: IStock);
begin
  Create(AName);
  fStockList.Add(aStock);
end;

function tPortfolio.Get_Stock(const Name: string): IStock;
var tekStock : IStock;
begin
  Result := nil;
  for tekStock in fStockList do
    if lowercase(tekStock.Name) = lowercase(Name) then
    begin
      Result := tekStock;
      break;
    end;
end;

procedure tPortfolio.Add_Stock(aStock: IStock; const addToPortfolio: boolean);
begin
  if addToPortfolio
  then aStock.portfolios.Add(fName);
  fStockList.Add(aStock);
  UpdatePortfolioStats;
end;

procedure tPortfolio.Delete_Stock(aStock: IStock);
var i     : integer;
    index : integer;
begin
  index:=aStock.portfolios.IndexOf(fName);
  if index>=0
  then aStock.portfolios.Delete(index);

  index:=fStockList.IndexOf(aStock);
  if index>=0
  then fStockList.Delete(index);

  UpdatePortfolioStats;
end;


procedure tPortfolio.UpdatePortfolioStats;
var currStock : IStock;
begin
  fCompanyCount:=fStockList.Count;
  fSumPriceUSD :=0;
  fBalanceUSD  :=0;
  for currStock in fStockList do
   begin
     if ansilowercase(currStock.Country)='россия'
     then
      begin
        fSumPriceUSD:=fSumPriceUSD+currStock.sumPrice/StocksData.USDtoRUB;
        fBalanceUSD :=fBalanceUSD+currStock.balance/StocksData.USDtoRUB   ;
      end
     else
      begin
        fSumPriceUSD:=fSumPriceUSD+currStock.sumPrice;
        fBalanceUSD :=fBalanceUSD+currStock.balance;
      end;
   end;
  if fSumPriceUSD-fBalanceUSD=0
  then fBalancePerc:=0
  else fBalancePerc:=fBalanceUSD/(fSumPriceUSD-fBalanceUSD)*100;
end;

end.

