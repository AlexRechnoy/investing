unit Stock;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,stock_operation_list,Stock_Operation, fgl;

type
  { IStock }
  IStock = interface ['{25875868-5C85-469C-9747-7949ACD297C2}']
    procedure WriteToXML;
    procedure ReadFromXML(const fileName : string);
    function GetName : string;
    function GetCountry : string;
    function getStockCount : integer;
    function getSumPrice : string;
    function getAverageStockPrice : string;
    function getBalance : string;
    function get_portfolio_name:string;
    function GetIndustry:string;
    function getOperationListStr : TStringList;
    procedure set_portfolio_name(AValue : string);
    procedure SetCountry(Aval : string);
    procedure SetIndustry(Aval : string);
    procedure SetName(Aval : string);
    procedure AddOperation(aDate:TDate;aOperationType:tOperationType;aCount:integer; aPrice:single);
    procedure DeleteLastOperation;
    procedure DeleteAllOperations;
    //
    property Name : string read GetName write SetName;
    property Country : string read GetCountry write SetCountry;
    property Industry : string read GetIndustry write SetIndustry;
    property stockCount : integer read getStockCount;
    property sumPrice : string read getSumPrice;
    property balance : string read getBalance;
    property averagePrice : string read getAverageStockPrice;
    property portfolio_name : string read get_portfolio_name write set_portfolio_name;
    property OperationListStr : tStringlist read getOperationListStr;
  end;

  { tStock }
  tStock = class(TInterfacedObject,IStock)
   private
    fName          : string;
    fCountry       : string;
    fBalance       : single;
    fCount         : integer;
    fIndustry      : string;        {Отрасль}
    fOperationList : tOperationList;
    fPortFolioName : string;
    function getStockCount : integer;
    function getSumPrice : string;
    function getAverageStockPrice : string;
    function getBalance : string;
    function GetIndustry:string;
    procedure SetName(Aval : string);
    procedure SetIndustry(Aval : string);
    function GetName : string;
    function GetCountry : string;
    procedure SetCountry(Aval : string);
    function get_portfolio_name:string;
    function getOperationListStr : TStringList;
    function getAveragePrice : string;
   public
    constructor Create(const aName,aCountry,aIndustry : string);
    procedure WriteToXML;
    procedure ReadFromXML(const fileName : string);

    procedure DeleteLastOperation;
    procedure DeleteAllOperations;
    procedure AddOperation(aDate:TDate;aOperationType:tOperationType;aCount:integer; aPrice:single);
    procedure set_portfolio_name(AValue : string);
    property Name : string read GetName;
    property Country : string read GetCountry write SetCountry;
  end;
  ptStock =^tStock;

  IStockList = specialize TFPGInterfacedObjectList<IStock>;

  const RootDir = 'stocks/';

implementation

uses DOM,XMLRead,XMLWrite,FileUtil,Stocks_Data,Dialogs;


{ tStock }
constructor tStock.Create(const aName, aCountry, aIndustry: string);
begin
  fBalance      :=0;
  fCount        :=0;
  fName         :=aName;
  fCountry      :=aCountry;
  fIndustry     :=aIndustry;
  fPortFolioName:='';
  fOperationList:=tOperationList.Create;
end;

function tStock.getOperationListStr: TStringList;
begin
  Result:=fOperationList.OperationStr;
end;

function tStock.getAveragePrice: string;
begin

end;

procedure tStock.AddOperation(aDate: TDate; aOperationType: tOperationType;
  aCount: integer; aPrice: single);
begin
  fOperationList.AddOperation(tStockOperation.Create(aDate,aOperationType,aCount,aPrice));
  StocksData.IsSaved:=false;
end;

procedure tStock.DeleteLastOperation;
begin
  fOperationList.DeleteLastOperation;
  StocksData.IsSaved:=false;
end;

procedure tStock.DeleteAllOperations;
begin
  fOperationList.Clear;
  StocksData.IsSaved:=false;
end;

procedure tStock.WriteToXML;
var filename     : string;
    tekOperation : IStockOperation;
    FileExist    : boolean=false;
    XMLDoc       : TXMLDocument;
    RootNode     : TDOMNode;
    domelement   : TDOMElement;
begin
  filename:=RootDir+fName+'.xml';
  try
    ReadXMLFile(XMLDoc,FileName);
    FileExist:=true;
    RootNode:=XMLDoc.DocumentElement;
    while Assigned(RootNode.FirstChild) do
      RootNode.FirstChild.Destroy;
  except
    XmlDoc  :=TXMLDocument.Create;
    RootNode:=XMLDoc.CreateElement('Main');
  end;

  domelement:=XMLDoc.CreateElement(UTF8Decode('other'));
  domelement.SetAttribute('country',fCountry);
  domelement.SetAttribute('name',fName);
  domelement.SetAttribute('portfolio',fportfolioName);
  domelement.SetAttribute('industry',fIndustry);
  RootNode.AppendChild(domelement);
  for tekOperation in fOperationList do
   begin
      domelement:=XMLDoc.CreateElement(UTF8Decode('stock_operation'));
      domelement.SetAttribute('date',DateToStr(tekOperation.Date));
      domelement.SetAttribute('operation_buy',BoolToStr(tekOperation.OperationType=_Operation_Buy,'1','0'));
      domelement.SetAttribute('count',inttostr(tekOperation.Count));
      domelement.SetAttribute('price',format('%4.2f',[tekOperation.Price]));
      RootNode.AppendChild(domelement);
   end;
  IF not FileExist then XMLDoc.AppendChild(RootNode);
  WriteXMLFile(XMLDoc,FileName);
end;

procedure tStock.ReadFromXML(const fileName : string);
var XMLDoc         : TXMLDocument;
    RootNode       : TDOMNode;
    tekNode        : TDOMNode;
    i              : integer;
    function GetOperationType(const str : string) : tOperationType;
    begin
      if str='1' then result:=_Operation_Buy else result:=_Operation_Sell;
    end;
begin
  ReadXMLFile(XMLDoc, fileName);
  RootNode := XMLDoc.DocumentElement;
  for i := 0 to RootNode.ChildNodes.Count - 1 do // перебор всех дней по ставкам
   begin
     tekNode:=RootNode.ChildNodes[i];
     if tekNode.NodeName='other'
     then
      begin
        fName         :=tekNode.Attributes.GetNamedItem('name').NodeValue;
        fCountry      :=tekNode.Attributes.GetNamedItem('country').NodeValue;
        if tekNode.Attributes.GetNamedItem('industry')<>nil
        then fIndustry:=tekNode.Attributes.GetNamedItem('industry').NodeValue;
        if tekNode.Attributes.GetNamedItem('portfolio')<>nil
        then fPortFolioName:=tekNode.Attributes.GetNamedItem('portfolio').NodeValue;
      end
     else
       try
         fOperationList.AddOperation(tStockOperation.Create(StrToDate(tekNode.Attributes.GetNamedItem('date').NodeValue),
                                                            GetOperationType(tekNode.Attributes.GetNamedItem('operation_buy').NodeValue),
                                                            Strtoint(tekNode.Attributes.GetNamedItem('count').NodeValue),
                                                            StrToFloat(tekNode.Attributes.GetNamedItem('price').NodeValue)
                                                           )
                                    );

       except
         on E : EStockSellException do MessageDlg(Format('"%s" акция "%s"',[E.Message,self.Name]), mtWarning,[mbOK],0)
       end;
   end;
end;

function tStock.getStockCount: integer;
begin
  Result:=fOperationList.StockCount;
end;

function tStock.getSumPrice: string;
begin
  if fOperationList.StockCount=0 then Result:='-' else
    if fOperationList.Sum<0 then Result:='<0' else
      Result:=Format('%4.2f',[fOperationList.Sum])
end;

function tStock.getAverageStockPrice: string;
var price : double;
begin
  if fOperationList.StockCount=0
  then Result:='-'
  else
   begin
     price:=fOperationList.Sum/fOperationList.StockCount;
     if price>0
     then Result:=format('%4.2f',[price])
     else Result:='<0';
   end
end;

function tStock.getBalance: string;
begin
  if fOperationList.StockCount=0
  then Result:=format('%4.2f',[fOperationList.Balance])
  else Result:='-';
end;

function tStock.GetIndustry: string;
begin
  Result:=fIndustry;
end;

procedure tStock.SetName(Aval: string);
begin
  fName:=Aval;
end;

procedure tStock.SetIndustry(Aval: string);
begin
  if fIndustry<>Aval
  then fIndustry:=Aval;
end;

function tStock.GetName: string;
begin
  Result:=fName;
end;

function tStock.GetCountry: string;
begin
  Result:=fCountry;
end;

procedure tStock.SetCountry(Aval: string);
begin
  fCountry:=Aval;
end;

function tStock.get_portfolio_name: string;
begin
  Result:=fPortFolioName;
end;

procedure tStock.set_portfolio_name(AValue: string);
begin
  fPortFolioName:=AValue;
end;

end.

