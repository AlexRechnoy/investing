unit Stocks_stats;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Stock,  Stock_list, Stock_Observer,
  Industry_stats_list,
  Country_stats_list,
  Filtered_stats_list;

type


  { tStockStats }
  tStockStats = class (TInterfacedObject,ISubjectStats)
   private
     fUSDtoRUB             : double;
     fIndustryStatsList    : tIndustryStatsList;
     fCountryStatsList     : tCountryStatsList;
     fFilteredStatsList    : tFilteredStatsList; //Суммарная статистика по выбранным акциям (страна / отрасль)
     fStatsObserverList    : TStatsObserverList;
     procedure SetUSDToRUB(AVal : double);
   public
     constructor Create;
     procedure registerStatsObserver(O : IStatsObserver);
     procedure removeStatsObserver(O : IStatsObserver);
     procedure notifyStatsObservers();
   public
     property USDtoRUB : double read fUSDtoRUB write SetUSDToRUB;
     procedure AddStockListToStats(AStockList, AFilteredStockList : TStockList; APortfolioName : string = 'все');
  end;

const
  USDtoRUBdefault     = 90;

implementation

{ tStocksStats }

procedure tStockStats.SetUSDToRUB(AVal: double);
begin
  fUSDtoRUB:=Aval;
end;

constructor tStockStats.Create;
begin
  fUSDtoRUB            :=USDtoRUBdefault;
  fIndustryStatsList   :=tIndustryStatsList.Create;
  fCountryStatsList    :=tCountryStatsList.Create;
  fFilteredStatsList   :=tFilteredStatsList.Create;
  fStatsObserverList   :=TStatsObserverList.Create;
end;

procedure tStockStats.registerStatsObserver(O: IStatsObserver);
begin
  fStatsObserverList.Add(O);
end;

procedure tStockStats.removeStatsObserver(O: IStatsObserver);
var OIndex : integer;
begin
  OIndex:=fStatsObserverList.IndexOf(O);
  If OIndex>=0
  then fStatsObserverList.Delete(OIndex)
end;

procedure tStockStats.notifyStatsObservers;
var TekO : IStatsObserver;
begin
  for TekO in fStatsObserverList do
    TekO.UpdateStats(fIndustryStatsList,fCountryStatsList, fFilteredStatsList);
end;

procedure tStockStats.AddStockListToStats(AStockList, AFilteredStockList: TStockList; APortfolioName: string);
begin
  fIndustryStatsList.addStockList(AStockList,fUSDtoRUB,APortfolioName);
  fIndustryStatsList.SortByPrice;

  fCountryStatsList.addStockList(AStockList,fUSDtoRUB);
  fCountryStatsList.SortByPrice;

  fFilteredStatsList.addStockList(AFilteredStockList,fUSDtoRUB);
  fFilteredStatsList.SortByPrice;
end;

end.

