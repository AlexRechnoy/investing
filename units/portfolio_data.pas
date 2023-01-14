unit Portfolio_Data;
{Портфель акций}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Portfolio,Stocks_Data,Stock, fgl;

type
  tPortfolio_add = procedure (Sender : TObject ; Name : string) of object ; //событие по добавлению портфеля

  { tPortfolio_Data }
  tPortfolio_Data = class
   private
    fAddPortfolio     : tPortfolio_add;  {Событие "добавление портфеля"}
    fIndex            : integer;         {порядковый номер выбранного портфеля в списке fPortfolioList}
    fOutSideStock     : IStock;          {Выбранная акция вне портфеля}
    fChosenStock      : IStock;          {Выбранная акция в портфеле}
    fPortfolioList    : tPortfolio_List; {Список портфелей}
    fOutside_StockList: iStockList;      {Акции вне портфелей}
    function GetPortfolioNames : TStringList;
    function Get_portfolio_Index(const Name : string): integer;  {Существует ли портфель с таким именем}
    function GetActivePortfolio:boolean;
    function GetActivePortfolioStockList:IStockList;
    procedure Refresh_Outside_StockList;
    function find_stock(const Name : string; stockList : IStockList): IStock;
   public
    constructor Create;
    procedure Add_Portfolio(AName : string );
    procedure Delete_Portfolio;
    procedure Set_Active_Portfolio(const index : integer);
    procedure Add_Stock_To_Portfolio;
    procedure Delete_Stock_From_Portfolio;
    function Get_Outside_Stock(const Name : string): IStock;
    function Get_Stock_In_Portfolio(const Name : string): IStock;
    property PortFolioList : tPortfolio_List read fPortfolioList write fPortfolioList;
    property PortfolioNames : TStringList read GetPortfolioNames;
    property OutsideStock : IStock read fOutSideStock write fOutSideStock;
    property OutsideStockList : IStockList read fOutside_StockList;
    property ChosenStock  : IStock read fChosenStock write fChosenStock;
    property OnAddPortfolio : tPortfolio_add read fAddPortfolio write fAddPortfolio;
    property HasActivePortfolio : boolean read GetActivePortfolio;
    property StockList:IStockList read GetActivePortfolioStockList; {Список акций выбранного портфеля}
  end;

var PortfolioData : tPortfolio_Data;

implementation

uses Dialogs;

{ tPortfolio_Data }
constructor tPortfolio_Data.Create;
var TekStock         : IStock;
    portfolio_index  : integer;
    portfolio_name   : string;
begin
  fIndex            :=-1;
  fPortfolioList    :=tPortfolio_List.Create;
  fOutside_StockList:=iStockList.Create; {Акции вне портфелей}
  for TekStock in StocksData.StockList do
   begin
     if (TekStock.portfolio_name<>'') then
      begin
        portfolio_index:=Get_portfolio_Index(TekStock.portfolio_name);
        if portfolio_index=-1 then {портфель еще не создан}
         begin
           portfolio_name:=TekStock.portfolio_name;
           fPortfolioList.Add(tPortfolio.Create(portfolio_name,TekStock));
         end
        else
         begin
           fPortfolioList[portfolio_index].Add_Stock(TekStock);
           portfolio_name:=fPortfolioList[portfolio_index].PortfolioName;
         end;
        TekStock.portfolio_name:=portfolio_name;
      end
      else
       begin
         fOutside_StockList.Add(TekStock); {акции вне портфеля}
       end;
   end;
end;

procedure tPortfolio_Data.Delete_Portfolio;
var index    : integer;
    tekStock : IStock;
begin
  for tekStock in StockList do
    TekStock.portfolio_name:='';
  fPortfolioList.Delete(fIndex);
  fIndex:=-1;
  Refresh_Outside_StockList;
end;

procedure tPortfolio_Data.Set_Active_Portfolio(const index: integer);
begin
  fIndex:=index;
end;

procedure tPortfolio_Data.Add_Stock_To_Portfolio;
begin
  if HasActivePortfolio
  then fPortfolioList[fIndex].Add_Stock(OutsideStock);
  Refresh_Outside_StockList;
end;

procedure tPortfolio_Data.Delete_Stock_From_Portfolio;
begin
  fPortfolioList[fIndex].Delete_Stock(ChosenStock);
  Refresh_Outside_StockList
end;

function tPortfolio_Data.Get_portfolio_Index(const Name : string): integer;
var tekPortfolio : tPortfolio;
    index : integer=0;
begin
  Result:=-1;
  for tekPortfolio in fPortfolioList do
   begin
     if tekPortfolio.PortfolioName=Name then
      begin
        Result:=index;
        break;
      end;
     inc(index);
   end;
end;

function tPortfolio_Data.GetActivePortfolio: boolean;
begin
  Result:=(fIndex>=0);
end;

function tPortfolio_Data.GetActivePortfolioStockList: IStockList;
begin
  if HasActivePortfolio
  then Result:=fPortfolioList[fIndex].Stocks
  else Result:=IStockList.Create;
end;

function tPortfolio_Data.Get_Outside_Stock(const Name : string): IStock;
begin
  Result:=find_stock(Name,fOutside_StockList);
end;

function tPortfolio_Data.Get_Stock_In_Portfolio(const Name: string): IStock;
begin
  Result:=find_stock(Name,StockList);
end;

procedure tPortfolio_Data.Add_Portfolio(AName: string);
var TekPortfolio : tPortfolio;
begin
  for TekPortfolio in fPortfolioList do
    if TekPortfolio.PortfolioName=AName then
     begin
       Showmessage('Такой портфель уже создан!');
       exit;
     end;
  fPortfolioList.Add(tPortfolio.Create(AName));
  if Assigned(fAddPortfolio)
  then fAddPortfolio(Self,AName);
end;

{--private--}
function tPortfolio_Data.find_stock(const Name : string; stockList : IStockList): IStock;
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
var TekStock : IStock;
begin
  fOutside_StockList.Clear;
  for TekStock in StocksData.StockList do
    if TekStock.portfolio_name='' then fOutside_StockList.Add(TekStock);
end;

function tPortfolio_Data.GetPortfolioNames: TStringList;
var tekPortfolio : tPortfolio;
begin
  Result:=TStringList.Create;
  for tekPortfolio in fPortfolioList do
    Result.Add(tekPortfolio.PortfolioName);
end;

end.

