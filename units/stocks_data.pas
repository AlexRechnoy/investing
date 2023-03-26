unit Stocks_Data;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Stock, Stock_Operation, stock_Observer;

type
  tStockEvent = procedure (sender : TObject; stock : IStock) of object;

  { tStocks_Data }
  tStocks_Data = class(TInterfacedObject,ISubject)
   private
    fOnAddStock   : tStockEvent; {Событие добавлена новая акция}
    fOnEditStock  : tStockEvent; {Событие изменены параметры выбранной акции}
    fOnSaved      : TNotifyEvent;{Событие при измении флага fIsSaved}
   private
    fObserverList : TObserverList;
    fIsSaved      : boolean;     {Данные сохранены}
    fChosenStock  : IStock;      {Выбранная акция}
    fStockList    : iStockList;  {Все акции}
    fCountryStocks: IStockList;  {Список акций выбранной страны}
    fIndustryList : TStringList; {Список отраслей}
    fCountryList  : TStringList; {Список стран}
    procedure DoOnSaved;
    procedure SetIsSaved(AVal : boolean);
   public
    property OnSaved : TNotifyEvent read fOnSaved write fOnSaved;
    property OnAddStock : tStockEvent read fOnAddStock write fOnAddStock;
    property OnEditStock : tStockEvent read fOnEditStock write fOnEditStock;
   public
    procedure registerObserver(O : IObserver);
    procedure removeObserver(O : IObserver);
    procedure notifyObservers();
    procedure notifyStockListObservers();
   public
    constructor Create;
    function getStock(const StockName : string):IStock;
    procedure ReadFromXML;
    procedure CheckStockProps;
    procedure AddStock(Stock: IStock);
    procedure EditStock(Country,Name,Industry : string);
    procedure WriteToXML;
    procedure setCountry(const countryName : string);
    procedure setStock(const stockIndex : integer); //изменилась выбранная акция
    procedure SetFirstStockFromCountry(countryName : string);
    function getStockStrList(countryName : string) : TStringlist;
    procedure AddOperationToChosenStock(aDate:TDate;aOperationType:tOperationType;aCount:integer; aPrice:single);
    procedure DeleteAllStockOperations;
    procedure DeleteLastStockOperation;

    property IsSaved : boolean read fIsSaved write SetIsSaved;
    property StockList: IStockList read fStockList;
    property IndustryList : TStringList read  fIndustryList write fIndustryList;
    property CountryList: TStringList read fCountryList write fCountryList;
    property ChosenStock : IStock read fChosenStock;
  end;

  function sort_by_name(const I1 ,I2 : IStock) : LongInt;

var
  StocksData: tStocks_Data;

implementation

uses FileUtil, XMLRead,XMLWrite,DOM, Dialogs;

const prop_file_name =  RootDir+'__stockProps.xml';

function sort_by_name(const I1 ,I2 : IStock) : LongInt;
begin
  if AnsiLowerCase(I1.Name)>AnsiLowerCase(I2.Name) then result:=1 else
    if  AnsiLowerCase(I1.Name)<AnsiLowerCase(I2.Name) then result:=-1 else
      result:=0;
end;

{ tStocks_Data }
constructor tStocks_Data.Create;
begin
  fObserverList := TObserverList.Create;
  fStockList    := IStockList.Create;
  fCountryStocks:= IStockList.Create;
  fIndustryList := TStringList.Create;
  fCountryList  := TStringList.Create;
  fChosenStock  :=nil;
  ReadFromXML;
  IsSaved:=true;
  fStockList.Sort(@sort_by_name);
  fCountryStocks.AddList(fStockList);
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

procedure tStocks_Data.notifyObservers;
var TekO : IObserver;
begin
  for TekO in FObserverList do
    TekO.UpdateStock(fChosenStock);
end;

procedure tStocks_Data.notifyStockListObservers;
var TekO : IObserver;
begin
  for TekO in FObserverList do
    TekO.UpdateStockList(fCountryStocks);
end;

procedure tStocks_Data.SetFirstStockFromCountry(countryName: string);
var i : integer;
begin
  for i:=0 to StockList.Count-1 do
    if (countryName='') or (AnsiLowerCase(countryName)=AnsiLowerCase(StockList[i].Country)) then
     begin
       FChosenStock:=StocksData.StockList[i];
       break;
     end;
  notifyObservers;
end;

procedure tStocks_Data.setStock(const stockIndex: integer);
begin
  FChosenStock:=fCountryStocks[stockIndex];
  notifyObservers();
end;

procedure tStocks_Data.setCountry(const countryName: string);
var i : integer;
begin
  fCountryStocks.Clear;
  if (countryName='')
  then fCountryStocks.AddList(fStockList)
  else
    begin
      for i:=0 to StockList.Count-1 do
        if (AnsiLowerCase(countryName)=AnsiLowerCase(StockList[i].Country))
        then fCountryStocks.Add(StockList[i]);
    end;
  notifyStockListObservers();
end;


function tStocks_Data.getStockStrList(countryName: string): TStringlist;
var i : integer;
begin
  Result:=TStringList.Create;
  for i:=0 to StockList.Count-1 do
    if (countryName='') or (AnsiLowerCase(countryName)=AnsiLowerCase(StockList[i].Country))
    then Result.Add(StockList[i].Name);
end;

procedure tStocks_Data.AddOperationToChosenStock(aDate: TDate;
  aOperationType: tOperationType; aCount: integer; aPrice: single);
begin
  if fChosenStock<>nil
  then fChosenStock.AddOperation(aDate,aOperationType,aCount,aPrice);
  notifyStockListObservers();
  notifyObservers();
end;

procedure tStocks_Data.DeleteAllStockOperations;
begin
  fChosenStock.DeleteAllOperations;
  notifyStockListObservers();
  notifyObservers();
end;

procedure tStocks_Data.DeleteLastStockOperation;
begin
  fChosenStock.DeleteLastOperation;
  notifyStockListObservers();
  notifyObservers();
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

function tStocks_Data.getStock(const StockName: string): IStock;
var tekStock : IStock;
begin
  Result:=nil;
  for tekStock in StockList do
   begin
     if AnsiLowerCase(tekStock.Name)=AnsiLowerCase(StockName) then
      begin
        Result:=tekStock;
        exit;
      end;
   end;
end;

procedure tStocks_Data.ReadFromXML;
var fileList: TStringList;
    tekStock: IStock;
    tekFileName: string;
    procedure ReadStocks;
    begin
      fileList := FindAllFiles(RootDir, '*.xml', True);
      for tekFileName in fileList do
       begin
         if pos('__stockProps.xml',tekFileName)>0
         then continue;
         tekStock := tStock.Create(tekFileName,'','');
         tekStock.ReadFromXML(tekFileName);
         fStockList.Add(tekStock);
       end;
    end;
    procedure ReadProps;
    var XMLDoc     : TXMLDocument;
        RootNode   : TDOMNode;
        domelement : TDOMElement;
        procedure ReadProp(list : tstringlist; nodeName : string);
        var tekChild   : TDOMNode;
        begin
          tekChild:=RootNode.FindNode(nodeName).FirstChild;
          while tekChild<>nil do
           begin
             if tekChild.HasChildNodes
             then list.Add(tekChild.FirstChild.TextContent);
             tekChild:=tekChild.NextSibling;
           end;
        end;

    begin
      try
        ReadXMLFile(XMLDoc,prop_file_name);
        RootNode:=XMLDoc.DocumentElement;
        ReadProp(fCountryList,'country');
        ReadProp(fIndustryList,'industry');
      except
        XmlDoc  :=TXMLDocument.Create;
        RootNode:=XMLDoc.CreateElement('Main');
        domelement:=XMLDoc.CreateElement('country');
        RootNode.AppendChild(domelement);
        domelement:=XMLDoc.CreateElement('industry');
        RootNode.AppendChild(domelement);
        XMLDoc.AppendChild(RootNode);
        WriteXMLFile(XMLDoc,prop_file_name);
      end;
    end;
begin
  ReadProps;
  ReadStocks;
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
  notifyStockListObservers();
end;

procedure tStocks_Data.WriteToXML;
    procedure WriteStocks;
    var tekStock : IStock;
    begin
      for tekStock in fStockList do
        tekStock.WriteToXML
    end;
    procedure WriteProps;
    var RootNode     : TDOMNode;
        XMLDoc       : TXMLDocument;
        procedure WriteProp(list : tstringlist; nodeName : string);
        var propNode : tDOMNode;
            tekelem  : TDOMElement;
            tekName  : string;
        begin
          propNode:=RootNode.FindNode(nodeName);
          while Assigned(propNode.FirstChild) do
            propNode.FirstChild.Destroy;
          for tekName in list do
            if propNode<>nil then
             begin
               tekelem:=XMLDoc.CreateElement('item');
               tekelem.AppendChild(XMLDOC.CreateTextNode(tekName));
               propNode.AppendChild(tekelem);
           end;

        end;

    begin
      try
        ReadXMLFile(XMLDoc,prop_file_name);
        RootNode:=XMLDoc.DocumentElement;
        WriteProp(fCountryList,'country');
        WriteProp(fIndustryList,'industry');
        WriteXMLFile(XMLDoc,prop_file_name);
      except

      end;
    end;
begin
  WriteStocks;
  WriteProps;
  IsSaved:=true;
end;

initialization
  StocksData := tStocks_Data.Create;

end.
