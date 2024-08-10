unit Portfolio_Data;
{Портфель акций}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, Portfolio_Observer, Portfolio_List, Stocks_Data,
  Stock, Stock_list;

type
  tOnPortfolioAdd = procedure (Sender : TObject ; Name : string) of object ; //событие по добавлению портфеля

  { tPortfolio_Data }
  tPortfolio_Data = class
   private
    fAddPortfolio     : tOnPortfolioAdd;       //Событие "добавление портфеля"
    fIndex            : integer;               //Порядковый номер выбранного портфеля в списке fPortfolioList
    fOutSideStock     : IStock;                //Выбранная акция вне портфеля
    fChosenStock      : IStock;                //Выбранная акция в портфеле
    fPortfolioList    : tPortfolioList;        //Список портфелей
    fOutStockList     : TStockList;            //Список акций вне выбранного портфелей
    fStockList        : TStockList;            //Список акции выбранного портфеля
    fObserverList     : TPortfolioObserverList;
    function GetPortfolioNames : TStringList;
    function GetActivePortfolio:boolean;
    function getPortfolioName:string;
    procedure Refresh_Outside_StockList;
    function find_stock(const Name : string; stockList : TStockList): IStock;
   public
    procedure registerObserver(O : IPortfolioObserver);
    procedure removeObserver(O : IPortfolioObserver);
    procedure notifyObservers();
   public
    constructor Create;
    destructor destroy; override;
    procedure Add_Portfolio(APortfolioName : string );
    procedure Delete_Portfolio;
    procedure SetPortfolio(const AportfolioIndex : integer);//Выбрать активный портфель
    procedure Add_Stock_To_Portfolio;
    procedure UpdatePortfolioStats;
    procedure Delete_Stock_From_Portfolio;
    function Get_Outside_Stock(const Name : string): IStock;
    function Get_Stock_In_Portfolio(const Name : string): IStock;
    property PortfolioName : String read getPortfolioName;
    property PortFolioList : tPortfolioList read fPortfolioList write fPortfolioList;
    property PortfolioNames : TStringList read GetPortfolioNames;
    property OutsideStock : IStock read fOutSideStock write fOutSideStock;
    property OutsideStockList : TStockList read fOutStockList;
    property ChosenStock  : IStock read fChosenStock write fChosenStock;
    property OnAddPortfolio : tOnPortfolioAdd read fAddPortfolio write fAddPortfolio;
    property HasActivePortfolio : boolean read GetActivePortfolio;
    property StockList:TStockList read FStockList; {Список акций выбранного портфеля}
  end;

    function PortfolioData : tPortfolio_Data;

implementation

uses Dialogs;

var MyPortfolioData : tPortfolio_Data;

  function PortfolioData : tPortfolio_Data;
  begin
    if MyPortfolioData=nil
    then MyPortfolioData:=tPortfolio_Data.Create;
    Result:=MyPortfolioData;
  end;

{ tPortfolio_Data }
constructor tPortfolio_Data.Create;
var currStock        : IStock;
    currPortfolioName: string;
begin
  fIndex            :=-1;
  fPortfolioList    :=tPortfolioList.Create;
  fStockList        :=TStockList.Create;
  fOutStockList     :=TStockList.Create; {Акции вне портфелей}
  for currStock in StocksData.StockList do
   begin
     for currPortfolioName in currStock.portfolios do
      begin
        fPortfolioList.AddStock(currPortfolioName,currStock,false);
      end;
   end;
  fObserverList:=TPortfolioObserverList.Create;
end;

destructor tPortfolio_Data.destroy;
begin
  fObserverList.Clear;
  fObserverList.Free;
  fStockList.Free;
  fOutStockList.Free;
  inherited destroy;
end;

//Выбрать активный портфель
procedure tPortfolio_Data.SetPortfolio(const AportfolioIndex: integer);
var currStock          : IStock;
    portfolioNameIndex : integer;     i:integer; s : string;
    tmpPortfolioName      : string;
begin
  fIndex:=AportfolioIndex;
  if fIndex=-1 then
  begin
    fOutStockList.Assign(StocksData.StockList);
    exit;
  end;
  for i:=0 to fPortfolioList.Count-1 do
    s:=fPortfolioList[i].PortfolioName;
  if (fIndex>=0) and (fIndex<fPortfolioList.Count) then
   begin
     fStockList:=fPortfolioList[findex].Stocks;
     fOutStockList.Clear;
     for currStock in StocksData.StockList do
      begin
        if currStock.isCurrency then continue;
        tmpPortfolioName:=fPortfolioList[findex].PortfolioName;
        portfolioNameIndex:=currStock.portfolios.IndexOf(tmpPortfolioName);
        if portfolioNameIndex<0
        then fOutStockList.Add(currStock);
      end;
   end;
end;

//Добавить акцию в портфель
procedure tPortfolio_Data.Add_Stock_To_Portfolio;
begin
  if Assigned(fOutSideStock) then
   begin
     if HasActivePortfolio
     then fPortfolioList[fIndex].Add_Stock(fOutsideStock);
     Refresh_Outside_StockList;
     notifyObservers();
     fOutsideStock:=nil;
   end;
end;

procedure tPortfolio_Data.UpdatePortfolioStats;
begin
  fPortfolioList.UpdatePortfolioStats;
  notifyObservers();
end;

//Удалить акцию из портфеля
procedure tPortfolio_Data.Delete_Stock_From_Portfolio;
begin
  if Assigned(fChosenStock) then
   begin
     fPortfolioList[fIndex].Delete_Stock(fChosenStock);
     Refresh_Outside_StockList;
     notifyObservers();
     fChosenStock:=nil;
   end;
end;

//Удалить портфель
procedure tPortfolio_Data.Delete_Portfolio;
begin
  fPortfolioList.DeletePortfolio(findex);
  fIndex:=-1;
  Refresh_Outside_StockList;
  notifyObservers();
end;

//Добавить портфель
procedure tPortfolio_Data.Add_Portfolio(APortfolioName: string);
begin
  if fPortfolioList.AddPortfolio(APortfolioName)
  then
   begin
     if Assigned(fAddPortfolio)
     then fAddPortfolio(Self,APortfolioName);
     notifyObservers();
   end
  else
   begin
     Showmessage('Такой портфель уже создан!');
   end;
end;

function tPortfolio_Data.GetActivePortfolio: boolean;
begin
  Result:=(fIndex>=0);
end;

function tPortfolio_Data.getPortfolioName: string;
begin
  Result:=fPortfolioList.GetPortfolioName(fIndex);
end;

function tPortfolio_Data.Get_Outside_Stock(const Name : string): IStock;
begin
  Result:=find_stock(Name,fOutStockList);
end;

function tPortfolio_Data.Get_Stock_In_Portfolio(const Name: string): IStock;
begin
  Result:=find_stock(Name,StockList);
end;

{--private--}
function tPortfolio_Data.find_stock(const Name : string; stockList : TStockList): IStock;
var tekStock : IStock;
begin
  Result := nil;
  for tekStock in stockList do
    if lowercase(tekStock.Name) = lowercase(Name) then
     begin
       Result := tekStock;
       break;
     end;
end;

procedure tPortfolio_Data.Refresh_Outside_StockList;
var currStock          : IStock;
    portfolioNameIndex : integer;
begin
  if fIndex<0 then exit;
  fOutStockList.Clear;
  for currStock in StocksData.StockList do
   begin
     portfolioNameIndex:=currStock.portfolios.IndexOf(fPortfolioList[findex].PortfolioName);
     if portfolioNameIndex<0
     then fOutStockList.Add(currStock);
   end;
end;

function tPortfolio_Data.GetPortfolioNames: TStringList;
begin
  Result:=TStringList.Create;
  Result.Assign(fPortfolioList.PortfolioNames);
end;

{--Observer--}
procedure tPortfolio_Data.registerObserver(O: IPortfolioObserver);
begin
  FObserverList.Add(O);
end;

procedure tPortfolio_Data.removeObserver(O: IPortfolioObserver);
var OIndex : integer;
begin
  OIndex:=FObserverList.IndexOf(O);
  If OIndex>=0
  then FObserverList.Delete(OIndex);
end;

procedure tPortfolio_Data.notifyObservers;
var TekO : IPortfolioObserver;
begin
  for TekO in FObserverList do
    TekO.UpdatePortfolioStats(fPortfolioList);
end;

end.

