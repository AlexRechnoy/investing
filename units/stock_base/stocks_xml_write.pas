unit Stocks_XML_Write;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Stock, Stock_list, XMLWrite, XMLRead, DOM;

type
  tStocks_XML_Write = class
    private
      procedure WriteProp(var XMLDoc : TXMLDocument; var propNode: TDOMNode; const name : string; const val : string);
    public
      procedure WriteToSettingsXML(const StockDirName: string; AChosenCountry, AChosenIndustry, AChosenPortfolio : string);
      function WriteToXML(const StockDirName: string; AStockList : TStockList; ACountryList, AIndustryList : TStringList; AUSDToRUB : double ) : boolean;
  end;

implementation

procedure tStocks_XML_Write.WriteProp(var XMLDoc : TXMLDocument; var propNode: TDOMNode; const name : string; const val : string);
var domelement   : TDOMElement;
begin
  domelement:=XMLDoc.CreateElement(UTF8Decode(name));
  domelement.AppendChild(XMLDOC.CreateTextNode(val));
  propNode.AppendChild(domelement);
end;

procedure tStocks_XML_Write.WriteToSettingsXML(const StockDirName: string; AChosenCountry, AChosenIndustry, AChosenPortfolio : string);
var propNode   : tDOMNode;
    RootNode   : TDOMNode;
    XMLDoc     : TXMLDocument;
    domelement : TDOMElement;
const  nodeName='settings';
begin
  try
    ReadXMLFile(XMLDoc,prop_file_name);
    RootNode:=XMLDoc.DocumentElement;
    propNode:=RootNode.FindNode(nodeName);
    if propNode=nil
    then
      begin
        propNode:=XMLDoc.CreateElement(nodeName);
        RootNode.AppendChild(propNode);
      end
    else
      begin
        while Assigned(propNode.FirstChild) do
          propNode.FirstChild.Destroy;
      end;
    WriteProp(XMLDoc,propNode,'chosen_country',AChosenCountry);
    WriteProp(XMLDoc,propNode,'chosen_industry',AChosenIndustry);
    WriteProp(XMLDoc,propNode,'chosen_portfolio',AChosenPortfolio);

    WriteXMLFile(XMLDoc,prop_file_name);
  except

  end;
end;

function tStocks_XML_Write.WriteToXML(const StockDirName: string; AStockList : TStockList; ACountryList, AIndustryList : TStringList; AUSDToRUB : double ) : boolean;
    procedure WriteStocks;
    var tekStock : IStock;
    begin
      for tekStock in AStockList do
        if StockDirName=''
        then tekStock.WriteToXML
        else tekStock.WriteToXML(StockDirName);
    end;
    procedure WriteProps;
    var RootNode     : TDOMNode;
        XMLDoc       : TXMLDocument;
        procedure WritePropList(list : tstringlist; nodeName : string);
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
        procedure WriteOtherProps(nodeName : string);
        var propNode : tDOMNode;
        begin
          propNode:=RootNode.FindNode(nodeName);
          while Assigned(propNode.FirstChild) do
            propNode.FirstChild.Destroy;
          WriteProp(XMLDoc,propNode,'usd_to_rub',FloatToStr(AUSDToRUB));
        end;

    begin
      try
        ReadXMLFile(XMLDoc,prop_file_name);
        RootNode:=XMLDoc.DocumentElement;
        WritePropList(ACountryList,'country');
        WritePropList(AIndustryList,'industry');
        WriteOtherProps('other');
        WriteXMLFile(XMLDoc,prop_file_name);
      except

      end;
    end;
begin
  Result:=false;
  WriteStocks;
  WriteProps;
  Result:=true;
end;

end.

