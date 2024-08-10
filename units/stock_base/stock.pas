unit Stock;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,stock_operation_list,Stock_Operation, fgl;

const
  RootStockDir = 'stocks/';
  prop_file_name =  RootStockDir+'__stockProps.xml';
type
  { IStock }
  IStock = interface ['{25875868-5C85-469C-9747-7949ACD297C2}']
    procedure WriteToXML(const StockDir : string = RootStockDir);
    procedure ReadFromXML(const fileName : string);
    function GetName : string;
    function GetCountry : string;
    function getStockCount : integer;
    function getSumPrice : double;
    function getAverageStockPrice : double;
    function getDeltaPricePercent : double;  {Разница между текущей ценой и средней, в процентах}
    function getBalance : double;
    function getPortfolios:tstringList;
    function GetIndustry:string;
    function GetIsCurrency : boolean;
    function GetCurrentPrice : double;
    function getOperationListStr : TStringList;
    function getIsInPortfolio(Aval : string) : boolean;
    procedure setPortfolios(AValue : TStringList);
    procedure SetCountry(Aval : string);
    procedure SetIndustry(Aval : string);
    procedure SetCurrentPrice(AVal : double);
    procedure SetName(Aval : string);
    procedure AddOperation(aDate:TDate;aOperationType:tOperationType;aCount:integer; aPrice:single);
    procedure DeleteLastOperation;
    procedure DeleteAllOperations;
    //
    property Name : string read GetName write SetName;
    property Country : string read GetCountry write SetCountry;
    property Industry : string read GetIndustry write SetIndustry;
    property Count : integer read getStockCount;
    property sumPrice : double read getSumPrice;
    property CurrentPrice : double read GetCurrentPrice write SetCurrentPrice;
    property DeltaPricePercent : double read getDeltaPricePercent;
    property balance : double read getBalance;
    property isCurrency : boolean read GetIsCurrency;
    property averagePrice : double read getAverageStockPrice;
    property portfolios : TStringList read getPortfolios write setPortfolios;
    property OperationListStr : tStringlist read getOperationListStr;
  end;


  { tStock }
  tStock = class(TInterfacedObject,IStock)
   private
    fIsCurrency    : boolean;       {Является валютой (не акция =((( )}
    fName          : string;        {Название}
    fCountry       : string;        {Страна}
    fIndustry      : string;        {Отрасль}
    fCurrentPrice  : double;        {Актуальная цена}
    fOperationList : tOperationList;
    fPortfolios    : tstringlist;
    function getStockCount : integer; //Кол-во акций
    function getSumPrice : double;    //Общая стоимость акций на руках
                                      //Если текущая цена неизвестна, то учитывается только стоимость покупки и продажи, которые в данный момент "на руках".
                                      //Например купили 2 по 15, сумма = 30; продали 1 за 20, сумма = 10
                                      //Иначе кол-во акций * текущую цену
    function getAverageStockPrice : double;
    function getDeltaPricePercent : double;  {Разница между текущей ценой и средней, в процентах}
    function getBalance : double;  //Баланс за операции по акциям.
                                   //Если текущая цена неизвестна, то учитывается только стоимость покупки и продажи. При покупке акций уходит в минус.
                                   //Например купили 2 по 15, баланс = -30; продали 1 за 20, баланс = -10
                                   //Иначе = суммарная стоимость акций на руках + их баланс
                                   //Например купили 2 по 15, баланс = -30; продали 1 за 20, (тек. цена = 30) баланс = 1*30 -10 = +20
    function GetIndustry:string;
    procedure SetName(Aval : string);
    procedure SetIndustry(Aval : string);
    function GetName : string;
    function GetCountry : string;
    function GetIsCurrency : boolean;
    function GetCurrentPrice : double;
    procedure SetCountry(Aval : string);
    procedure SetCurrentPrice(AVal : double);
    function getIsInPortfolio(Aval : string) : boolean;
    function getPortfolios:tstringList;
    function getOperationListStr : TStringList;
   public
    constructor Create(const aName,aCountry,aIndustry : string);
    procedure WriteToXML(const StockDir : string = RootStockDir);
    procedure ReadFromXML(const fileName : string);
    procedure DeleteLastOperation;
    procedure DeleteAllOperations;
    procedure AddOperation(aDate:TDate;aOperationType:tOperationType;aCount:integer; aPrice:single);
    procedure setPortfolios(AValue : tstringlist);
    property Name : string read GetName;
    property isCurrency : boolean read GetIsCurrency;
    property CurrentPrice : double read GetCurrentPrice write SetCurrentPrice;
    property DeltaPricePercent : double read getDeltaPricePercent;
    property Country : string read GetCountry write SetCountry;
    property Count : integer read getStockCount;
  end;
  ptStock =^tStock;



implementation

uses DOM,XMLRead,XMLWrite,FileUtil,Stocks_Data,Dialogs;


{ tStock }
constructor tStock.Create(const aName, aCountry, aIndustry: string);
begin
  //fCount        :=0;
  fCurrentPrice :=0;
  fIsCurrency   :=false;
  fName         :=aName;
  fCountry      :=aCountry;
  fIndustry     :=aIndustry;
  fPortfolios   :=tStringList.Create;
  fOperationList:=tOperationList.Create;
end;

function tStock.getOperationListStr: TStringList;
begin
  Result:=fOperationList.OperationStr;
end;

procedure tStock.AddOperation(aDate: TDate; aOperationType: tOperationType;
  aCount: integer; aPrice: single);
begin
  fOperationList.AddOperation(tStockOperation.Create(aDate,aOperationType,aCount,aPrice,fOperationList.getMaxOperationID+1));
  StocksData.IsSaved:=false;
end;

procedure tStock.DeleteLastOperation;
begin
  fOperationList.DeleteLastOperation;
  StocksData.IsSaved:=false;
end;

procedure tStock.DeleteAllOperations;
begin
  fOperationList.DeleteAllOperations;
  StocksData.IsSaved:=false;
end;

procedure tStock.WriteToXML(const StockDir: string);
var filename         : string;
    tekOperation     : IStockOperation;
    FileExist        : boolean=false;
    XMLDoc           : TXMLDocument;
    RootNode         : TDOMNode;
    domelement       : TDOMElement;
    portfolioElement : TDOMElement;
    portfolioNode    : TDOMElement;
    currPortfolioName: string;
begin
  filename:=StockDir+fName+'.xml';
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
  domelement.SetAttribute('current_price',FloatToStr(fCurrentPrice));
  domelement.SetAttribute('iscurrency',inttostr(byte(fIsCurrency)));

  portfolioElement:=XMLDoc.CreateElement(UTF8Decode('portfolios'));
  for currPortfolioName in fPortfolios do
   begin
     portfolioNode:=XMLDoc.CreateElement('portfolio');
     portfolioNode.AppendChild(XMLDOC.CreateTextNode(UTF8Decode(currPortfolioName)));
     portfolioElement.AppendChild(portfolioNode);
   end;
  domelement.AppendChild(portfolioElement);

  domelement.SetAttribute('industry',fIndustry);
  RootNode.AppendChild(domelement);
  for tekOperation in fOperationList do
   begin
      domelement:=XMLDoc.CreateElement(UTF8Decode('stock_operation'));
      domelement.SetAttribute('date',DateToStr(tekOperation.Date));
      domelement.SetAttribute('operation_buy',BoolToStr(tekOperation.OperationType=_Operation_Buy,'1','0'));
      domelement.SetAttribute('count',inttostr(tekOperation.Count));
      domelement.SetAttribute('price',format('%4.2f',[tekOperation.Price]));
      domelement.SetAttribute('id',inttostr(tekOperation.ID));
      RootNode.AppendChild(domelement);
   end;
  IF not FileExist then XMLDoc.AppendChild(RootNode);
  WriteXMLFile(XMLDoc,FileName);
end;

procedure tStock.ReadFromXML(const fileName : string);
var XMLDoc         : TXMLDocument;
    RootNode       : TDOMNode;
    tekNode        : TDOMNode;
    i,j            : integer; s:string;
    portfoliosNode : TDOMNode;
    function GetOperationType(const str : string) : tOperationType;
    begin
      if str='1' then result:=_Operation_Buy else result:=_Operation_Sell;
    end;
    function GetOperationID(const operationIDNode : TDOMNode) : integer;
    begin
      result:=-1;
      if operationIDNode<>nil
      then result:=StrToInt(operationIDNode.NodeValue);
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
        if tekNode.Attributes.GetNamedItem('current_price')<>nil
        then fCurrentPrice:=StrToFloat(tekNode.Attributes.GetNamedItem('current_price').NodeValue);
        if tekNode.Attributes.GetNamedItem('iscurrency')<>nil
        then fIsCurrency:=StrToBool(tekNode.Attributes.GetNamedItem('iscurrency').NodeValue);
        if tekNode.Attributes.GetNamedItem('industry')<>nil
        then fIndustry:=tekNode.Attributes.GetNamedItem('industry').NodeValue;

        portfoliosNode:=tekNode.FindNode('portfolios');
        if Assigned(portfoliosNode) then //tekNode.GetNamedItem('portfolio')<>nil then
         begin
           for j:=0 to portfoliosNode.ChildNodes.Count-1 do
             fPortfolios.Add(portfoliosNode.ChildNodes[j].TextContent);
         end;

        //then fPortFolioName:=tekNode.Attributes.GetNamedItem('portfolio').NodeValue;
      end
     else
       try
         fOperationList.AddOperation(tStockOperation.Create(StrToDate(tekNode.Attributes.GetNamedItem('date').NodeValue),
                                                            GetOperationType(tekNode.Attributes.GetNamedItem('operation_buy').NodeValue),
                                                            Strtoint(tekNode.Attributes.GetNamedItem('count').NodeValue),
                                                            StrToFloat(tekNode.Attributes.GetNamedItem('price').NodeValue),
                                                            GetOperationID(tekNode.Attributes.GetNamedItem('id'))
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

function tStock.getAverageStockPrice: double;
begin
  if fOperationList.StockCount=0
  then Result:=0
  else Result:=fOperationList.Sum/fOperationList.StockCount;
end;

function tStock.getDeltaPricePercent: double;
var tmpAverageStockPrice : double;
begin
  tmpAverageStockPrice:=getAverageStockPrice;
  if (tmpAverageStockPrice<=0) or (fCurrentPrice=0)
  then Result:=0
  else Result:=(fCurrentPrice-tmpAverageStockPrice)/tmpAverageStockPrice*100 ;
end;

//Общая стоимость акций на руках
function tStock.getSumPrice: double;
begin
  Result:=0;
  if Count=0 then exit;
  if fCurrentPrice=0
  then Result:=fOperationList.Sum
  else Result:=fCurrentPrice*fOperationList.StockCount;
end;

//Баланс за операции по акциям.
function tStock.getBalance: double;
begin
  if fCurrentPrice=0
  then Result:=fOperationList.Balance
  else Result:=fCurrentPrice*fOperationList.StockCount + fOperationList.Balance;
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

function tStock.GetIsCurrency: boolean;
begin
  Result:=fIsCurrency;
end;

function tStock.GetCurrentPrice: double;
begin
  Result:=fCurrentPrice;
end;

procedure tStock.SetCountry(Aval: string);
begin
  fCountry:=Aval;
end;

procedure tStock.SetCurrentPrice(AVal: double);
begin
  if fCurrentPrice<>Aval
  then fCurrentPrice:=AVal;
end;

function tStock.getIsInPortfolio(Aval: string): boolean;
var tekPortfolioName : string;
begin
  Result:=false;
  for tekPortfolioName in fportfolios do
    if AnsiLowerCase(tekPortfolioName)=AnsiLowerCase(Aval) then
     begin
       Result:=true;
       exit;
     end;
end;

function tStock.getPortfolios: tstringList;
begin
  Result:=fPortfolios;
end;

procedure tStock.setPortfolios(AValue: tstringlist);
begin
  fPortfolios:=AValue;
end;

end.

