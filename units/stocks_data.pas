unit Stocks_Data;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Stock,  Stock_list, Stock_Operation, Stocks_stats,
  Stock_group, stock_Observer,FileUtil, Stocks_XML_Write, Stocks_XML_Read,
  Stock_filtered_list,  Dialogs;

type
  tStockEvent = procedure (sender : TObject; stock : IStock) of object;
  tIndustryEvent = procedure (sender : TObject; stock : tStockGroup) of object;

  { tStocks_Data }
  tStocks_Data = class(TInterfacedObject,ISubject)
   private
    fOnSortFilteredStocks : TNotifyEvent; {Событие сортировка списка отфильтрованных акций}
    fOnAddStock        : tStockEvent;  {Событие добавлена новая акция}
    fOnEditStock       : tStockEvent;  {Событие изменены параметры выбранной акции}
    fOnExchangeCountry : TNotifyEvent; {Событие изменение названия страны}
    fOnExchangeIndustry: TNotifyEvent; {Событие изменение отрасли }
    fOnSaved           : TNotifyEvent; {Событие при измении флага fIsSaved}
   private
    fObserverList         : TObserverList;
    fXMLWrite             : tStocks_XML_Write;
    fXMLRead              : tStocks_XML_Read;
    fIsSaved              : boolean;      {Данные сохранены}
    fChosenCountry        : string;       {Выбранная страна}
    fChosenIndustry       : string;       {Выбранная отрасль}
    fChosenPortfolio      : string;       {Выбранный портфель}
    fChosenPortfolioStats : string;       {Выбранный портфель для отображения статистики}
    fChosenStock          : IStock;       {Выбранная акция}
    fStockList            : TStockList;   {Все акции}
    fFilteredStocks       : TStockFilteredList;   {Список акций отфильтрованный (фильтр по стране/отрасле)}
    fIndustryList         : TStringList;  {Список отраслей}
    fStockStats           : tStockStats;  {Статистика по отраслям}
    fCountryList          : TStringList;  {Список стран}
    fUSDtoRUB             : double;       {Стоимость доллара (в рублях)}
    procedure DoOnSaved;
    procedure SetIsSaved(AVal : boolean);
    procedure setUSDtoRUB(Aval : double);
    procedure UpdateIndustryList; //Обновить список отраслей (перед сохранением)
   public
    property OnSortFilteredStocks : TNotifyEvent read fOnSortFilteredStocks write fOnSortFilteredStocks;
    property OnSaved : TNotifyEvent read fOnSaved write fOnSaved;
    property OnAddStock : tStockEvent read fOnAddStock write fOnAddStock;
    property OnEditStock : tStockEvent read fOnEditStock write fOnEditStock;
    property OnExchangeCountry : TNotifyEvent read fOnExchangeCountry write fOnExchangeCountry;
    property OnExchangeIndustry: TNotifyEvent read fOnExchangeIndustry write fOnExchangeIndustry;
   public
    procedure registerObserver(O : IObserver);
    procedure removeObserver(O : IObserver);
    procedure notifyObservers();
    procedure calcAndNotifyStatsObservers;
    procedure notifyFilteredStocksObservers();
   public
    constructor Create;
    destructor destroy; override;
    procedure ReadFromXML;
    procedure CheckStockProps;
    procedure AddStock(Stock: IStock);
    procedure EditStock(Country,Name,Industry : string);
    function WriteToSettingsXML(const StockDirName: string=''): boolean; //Сохранить выбранный портфель/страну/отрасль
    function WriteToXML(const StockDirName : string='') : boolean;
    function  BackUP (out backUpTime : double) : boolean ;
    procedure setCountry(const countryName : string);
    procedure setIndustry(const industryName : string);
    procedure SetPortfolio(const portfolioName : string);
    procedure SetPortfolioStats(const portfolioName : string);//выбрать портфель для отображения статистики
    procedure setStock(const stockIndex : integer); //изменилась выбранная акция
    procedure AddOperationToChosenStock(aDate:TDate;aOperationType:tOperationType;aCount:integer; aPrice:single);
    procedure SaveCurrentStockPrice(AVal : double; ADate : TDate); //Сохранить актуальную стоимость акции
    procedure DeleteAllStockOperations;
    procedure DeleteLastStockOperation;
    procedure SortFilteredList(ASortFunc : TSortStockListFunc);
    //Отрасли
    procedure AddIndustry(const AIndustry : string);
    procedure ExchangeIndustry(const AOldIndustry, ANewIndustry : string);
    //Страны
    procedure AddCountry(const ACountry : string);
    procedure ExchangeCountry(const AOldCountry, ANewCountry : string);
    //
    property USDtoRUB : double read fUSDtoRUB write setUSDtoRUB;
    property IsSaved : boolean read fIsSaved write SetIsSaved;
    property StockList: TStockList read fStockList;
    property IndustryList : TStringList read  fIndustryList {write fIndustryList};
    property StockStats : tStockStats read fStockStats;
    property FilteredStocks : TStockFilteredList read fFilteredStocks;
    property CountryList: TStringList read fCountryList write fCountryList;
    property ChosenStock : IStock read fChosenStock;
    property ChosenCountry : string read fChosenCountry;
    property ChosenIndustry : string read fChosenIndustry;
  end;

  function sort_by_name(const I1 ,I2 : IStock) : LongInt;

var
  StocksData: tStocks_Data;

implementation

function sort_by_name(const I1 ,I2 : IStock) : LongInt;
begin
  if AnsiLowerCase(I1.Name)>AnsiLowerCase(I2.Name) then result:=1 else
    if  AnsiLowerCase(I1.Name)<AnsiLowerCase(I2.Name) then result:=-1 else
      result:=0;
end;

{ tStocks_Data }
constructor tStocks_Data.Create;
begin
  fObserverList       := TObserverList.Create;
  //fIndustryObserverList:=TIndustryObserverList.Create;
  fStockList          := TStockList.Create;
  fFilteredStocks     := TStockFilteredList.Create;
  fIndustryList       := TStringList.Create;
  fStockStats         := tStockStats.Create;
  fChosenPortfolioStats:='все';
  fIndustryList.Add('Не определено');
  fIndustryList.Sorted:=true;
  fCountryList        := TStringList.Create;
  fChosenStock        :=nil;
  fUSDtoRUB           :=USDtoRUBdefault;
  fXMLWrite           :=tStocks_XML_Write.Create;
  ReadFromXML;
  IsSaved:=true;
  fStockList.Sort(@sort_by_name);
  fFilteredStocks.AddList(fStockList);
end;

procedure tStocks_Data.registerObserver(O: IObserver);
begin
  FObserverList.Add(O);
end;

procedure tStocks_Data.removeObserver(O: IObserver);
var OIndex : integer;
begin
  OIndex:=FObserverList.IndexOf(O);
  If OIndex>=0
  then FObserverList.Delete(OIndex);
end;
     {
procedure tStocks_Data.registerIndustryObserver(O: IIndustryObserver);
begin
  fIndustryObserverList.Add(O);
end;

procedure tStocks_Data.removeIndustryObserver(O: IIndustryObserver);
var OIndex : integer;
begin
  OIndex:=fIndustryObserverList.IndexOf(O);
  If OIndex>=0
  then fIndustryObserverList.Delete(OIndex);
end; }

procedure tStocks_Data.notifyObservers;
var TekO : IObserver;
begin
  for TekO in FObserverList do
    TekO.UpdateStock(fChosenStock);
end;

procedure tStocks_Data.calcAndNotifyStatsObservers;
begin
  fStockStats.USDtoRUB:=fUSDtoRUB;
  fStockStats.AddStockListToStats(StockList, fFilteredStocks,  fChosenPortfolioStats);
  fStockStats.notifyStatsObservers();
end;

procedure tStocks_Data.notifyFilteredStocksObservers;
var TekO : IObserver;
begin
  for TekO in FObserverList do
    TekO.UpdateFilteredStockList(fFilteredStocks);
end;

procedure tStocks_Data.setStock(const stockIndex: integer);
begin
  if stockIndex>=0
  then FChosenStock:=fFilteredStocks[stockIndex]
  else FChosenStock:=nil;
  notifyObservers();
end;

procedure tStocks_Data.setCountry(const countryName: string);
begin
  fChosenPortfolio:='';
  fChosenCountry:=countryName;
  fFilteredStocks.UpdateFilteredStocks(fStockList, fChosenPortfolio, fChosenCountry, fChosenIndustry);
  if fFilteredStocks.Count>0
  then FChosenStock:=fFilteredStocks[0]
  else FChosenStock:=nil;
  notifyFilteredStocksObservers();
  notifyObservers;
  calcAndNotifyStatsObservers();
end;

procedure tStocks_Data.setIndustry(const industryName: string);
begin
  fChosenIndustry:=industryName;
  fFilteredStocks.UpdateFilteredStocks(fStockList, fChosenPortfolio, fChosenCountry, fChosenIndustry);
  if fFilteredStocks.Count>0
  then FChosenStock:=fFilteredStocks[0]
  else FChosenStock:=nil;
  notifyFilteredStocksObservers();
  notifyObservers;
  calcAndNotifyStatsObservers();
end;

procedure tStocks_Data.SetPortfolio(const portfolioName: string);
begin
  fChosenPortfolio:=portfolioName;
  fChosenCountry  :='';
  fChosenIndustry :='';

  fFilteredStocks.UpdateFilteredStocks(fStockList, fChosenPortfolio, fChosenCountry, fChosenIndustry);
  if fFilteredStocks.Count>0
  then FChosenStock:=fFilteredStocks[0]
  else FChosenStock:=nil;
  notifyFilteredStocksObservers();
  notifyObservers;
end;

procedure tStocks_Data.SetPortfolioStats(const portfolioName: string);
begin
  fChosenPortfolioStats:=portfolioName;
  calcAndNotifyStatsObservers;
end;

procedure tStocks_Data.DoOnSaved;
begin
  if Assigned(fOnSaved)
  then fOnSaved(Self);
end;

procedure tStocks_Data.SetIsSaved(AVal: boolean);
begin
  if aVal<>fIsSaved then
   begin
     fIsSaved:=Aval;
     DoOnSaved;
   end;
end;

procedure tStocks_Data.setUSDtoRUB(Aval: double);
begin
  if fUSDtoRUB<>AVal then
   begin
     fUSDtoRUB:=AVal;
     SetIsSaved(false);
   end;
end;

procedure tStocks_Data.UpdateIndustryList;
var currStock : IStock;
begin
  fIndustryList.Clear;
  fIndustryList.Add('Не определено');
  for currStock in fStockList do
   begin
     if fIndustryList.IndexOf(currStock.Industry)<0
     then fIndustryList.Add(currStock.Industry);
   end;
end;

procedure tStocks_Data.CheckStockProps;
var tekStock : IStock;
    function findProp(const stockProp : string; propList : TStringList):boolean;
    var tekStr   : string;
    begin
      Result:=false;
      for tekStr in propList do
        if stockProp=tekStr then
         begin
           result:=true;
           exit;
         end;
      propList.Add(stockProp);
    end;
begin
  for tekStock in StockList do
   begin
     if not findProp(tekStock.Country,fCountryList) then
      begin
        tekStock.Country:='Нет';
        ShowMessage(Format('У акции "%s" не указана страна',[tekStock.Name]));
        IsSaved:=false;
      end;
     if not findProp(tekStock.Industry,fIndustryList) then
      begin
        tekStock.Industry:='Нет';
        ShowMessage(Format('У акции "%s" не указана отрасль',[tekStock.Name]));
        IsSaved:=false;
      end;
   end;
end;

{Основные действия}
procedure tStocks_Data.AddOperationToChosenStock(aDate: TDate;
  aOperationType: tOperationType; aCount: integer; aPrice: single);
begin
  if fChosenStock<>nil
  then fChosenStock.AddOperation(aDate,aOperationType,aCount,aPrice);
  notifyFilteredStocksObservers();
  notifyObservers();
  calcAndNotifyStatsObservers();
end;

procedure tStocks_Data.SaveCurrentStockPrice(AVal: double; ADate: TDate);
begin
  fChosenStock.CurrentPrice:=AVal;
  fChosenStock.CurrentPriceDate:=ADate;
  SetIsSaved(false);

  notifyFilteredStocksObservers();
  notifyObservers();
  calcAndNotifyStatsObservers();
end;

procedure tStocks_Data.DeleteAllStockOperations;
begin
  fChosenStock.DeleteAllOperations;
  notifyFilteredStocksObservers();
  notifyObservers();
  calcAndNotifyStatsObservers();
end;

procedure tStocks_Data.DeleteLastStockOperation;
begin
  fChosenStock.DeleteLastOperation;
  notifyFilteredStocksObservers();
  notifyObservers();
  calcAndNotifyStatsObservers();
end;

procedure tStocks_Data.SortFilteredList(ASortFunc: TSortStockListFunc);
begin
  fFilteredStocks.SortList(ASortFunc);
  notifyFilteredStocksObservers();
  if Assigned(fOnSortFilteredStocks)
  then  fOnSortFilteredStocks(self);
end;

procedure tStocks_Data.AddIndustry(const AIndustry: string);
begin
  FIndustryList.Add(AIndustry);
  calcAndNotifyStatsObservers;
end;

procedure tStocks_Data.ExchangeIndustry(const AOldIndustry, ANewIndustry: string);
var tekStock : IStock;
begin
  if self.IndustryList.IndexOf(ANewIndustry)<0
  then self.IndustryList.Add(ANewIndustry);
  for tekStock in self.StockList do
    if tekStock.Industry=AOldIndustry then
     begin
       ShowMessage(Format('%s : замена отрасли с "%s" на "%s"',[tekStock.Name,AOldIndustry,ANewIndustry]));
       tekStock.Industry:=ANewIndustry;
       IsSaved:=false;
     end;
  notifyFilteredStocksObservers();
  notifyObservers();
  calcAndNotifyStatsObservers();
  if Assigned(fOnExchangeIndustry)
  then fOnExchangeIndustry(self);
end;

procedure tStocks_Data.AddCountry(const ACountry: string);
begin
  fCountryList.Add(ACountry);
 // notifyIndustryObservers();
end;

procedure tStocks_Data.ExchangeCountry(const AOldCountry, ANewCountry: string);
var tekStock : IStock;
begin
  for tekStock in self.StockList do
    if tekStock.Country=AOldCountry then
     begin
       ShowMessage(Format('%s : замена страны с "%s" на "%s"',[tekStock.Name,AOldCountry,ANewCountry]));
       tekStock.Country:=ANewCountry;
       IsSaved:=false;
     end;
  notifyFilteredStocksObservers();
  notifyObservers();
  if Assigned(fOnExchangeCountry)
  then fOnExchangeCountry(self);
end;

procedure tStocks_Data.AddStock(Stock: IStock); {Добавление акции}
begin
  fStockList.Add(Stock);
  IsSaved:=false;
  fStockList.Sort(@sort_by_name);
  if Assigned(fOnAddStock)
  then fOnAddStock(self,Stock);
end;

procedure tStocks_Data.EditStock(Country, Name, Industry: string);
begin
  fChosenStock.Country :=Country;
  fChosenStock.Name    :=Name;
  fChosenStock.Industry:=Industry;
  IsSaved:=false;
  if Assigned(fOnEditStock)
  then fOnEditStock(self,fChosenStock);
  notifyObservers();
  notifyFilteredStocksObservers();
  calcAndNotifyStatsObservers();
end;



{XML }
procedure tStocks_Data.ReadFromXML;
begin
  fXMLRead.ReadFromXML(fStockList,fUSDtoRUB,fCountryList,fIndustryList,fChosenCountry,fChosenIndustry,fChosenPortfolio);
end;

function tStocks_Data.WriteToSettingsXML(const StockDirName: string): boolean;
begin
  fXMLWrite.WriteToSettingsXML(StockDirName,fChosenCountry,fChosenIndustry,fChosenPortfolio);
end;

function tStocks_Data.WriteToXML(const StockDirName: string) : boolean;
begin
  Result:=false;
  if (StockDirName<>'') then
   begin
     if (not DirectoryExists(StockDirName)) then
       if not ForceDirectories(ExtractFileDir(ParamStr(0))+'/'+StockDirName)
       then exit;
   end;
  UpdateIndustryList;

  if not fXMLWrite.WriteToXML(StockDirName,fStockList,fCountryList,fIndustryList,fUSDtoRUB)
  then exit;
  Result:=true;
  IsSaved:=true;
end;

{BackUP}
function tStocks_Data.BackUP(out backUpTime: double): boolean;
var myFormatSettings : TFormatSettings;
var stockDir   : string;
    date_str   : string;
    time_str   : string;
    startTime  : QWord;
begin
  Result:=false;
  startTime:=GetTickCount64;
  myFormatSettings:=DefaultFormatSettings;
  myFormatSettings.ShortDateFormat:='yyyy_MM_dd';
  myFormatSettings.LongTimeFormat:='hh_nn_ss';
  date_str:=DateToStr(Now,myFormatSettings);
  time_str:=TimeToStr(Now,myFormatSettings);
  stockDir:=Format('stocks_backup/stocks %s___%s/',[date_str,time_str]);
  if WriteToXML(stockDir) then
   begin
     backUpTime:=(GetTickCount64-startTime)/1000;
     Result:=true;
   end;
end;

destructor tStocks_Data.destroy;
begin
  fIndustryList.Free;
  fCountryList.Free;
  fStockStats.Free;
  inherited destroy;
end;

initialization
  StocksData := tStocks_Data.Create;

end.
