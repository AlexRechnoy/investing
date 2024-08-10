unit Stocks_XML_Read;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Stock, Stock_list, XMLRead, XMLWrite, DOM;

type

  { tStocks_XML_Read }
  tStocks_XML_Read = class
    private
      function ReadProp(propsNode : TDOMNode; propName : string) : string;
    public
      procedure ReadFromXML(var AStockList : TStockList; var AUSDtoRUB : double;
                            var ACountryList , AIndustryList : TStringList;
                            var AChosenCountry, AChosenIndustry, AChosenPortfolio : string);
  end;

implementation



function tStocks_XML_Read.ReadProp(propsNode : TDOMNode; propName : string) : string;
var propNode : TDOMNode;
    childNode : TDOMNode;
begin
  result:='';
  propNode:=propsNode.FindNode(propName);
  if Assigned(propNode) then
   begin
    childNode:=propNode.FirstChild;
    if Assigned(childNode)
    then result:=childNode.TextContent;
  end;
end;

procedure tStocks_XML_Read.ReadFromXML(var AStockList: TStockList;
  var AUSDtoRUB: double; var ACountryList, AIndustryList: TStringList;
  var AChosenCountry, AChosenIndustry, AChosenPortfolio: string);
var fileList: TStringList;
    tekStock: IStock;
    tekFileName: string;
    procedure ReadStocks;
    begin
      fileList := FindAllFiles(RootStockDir, '*.xml', True);
      for tekFileName in fileList do
       begin
         if pos('__stockProps.xml',tekFileName)>0
         then continue;
         tekStock := tStock.Create(tekFileName,'','');
         tekStock.ReadFromXML(tekFileName);
         AStockList.Add(tekStock);
       end;
    end;
    procedure ReadProps;
    var XMLDoc     : TXMLDocument;
        RootNode   : TDOMNode;
        domelement : TDOMElement;
        procedure ReadPropList(list : tstringlist; nodeName : string);
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
        procedure ReadOtherProps(const nodeName : string);
        var propsNode : TDOMNode;
            propTxt   : string;
            propDouble: double;
        begin
          propsNode:= RootNode.FindNode(nodeName);
          if propsNode<>nil then
           begin
             propTxt:=ReadProp(propsNode,'usd_to_rub');
             if TryStrToFloat(propTxt,propDouble)
             then AUSDtoRUB:=propDouble;
           end
          else
           begin
             domelement:=XMLDoc.CreateElement('other');
             RootNode.AppendChild(domelement);
             WriteXMLFile(XMLDoc,prop_file_name);
           end;
        end;
        procedure ReadSettingsProps(const nodeName : string);
        var propsNode : TDOMNode;
        begin
          propsNode:= RootNode.FindNode(nodeName);
          if propsNode=nil
          then exit;
          AChosenCountry  :=ReadProp(propsNode,'chosen_country');
          AChosenIndustry :=ReadProp(propsNode,'chosen_industry');
          AChosenPortfolio:=ReadProp(propsNode,'chosen_portfolio');
        end;

    begin
      try
        ReadXMLFile(XMLDoc,prop_file_name);
        RootNode:=XMLDoc.DocumentElement;
        ReadPropList(ACountryList,'country');
        ReadPropList(AIndustryList,'industry');
        ReadOtherProps('other');
        ReadSettingsProps('settings');
      except
        XmlDoc  :=TXMLDocument.Create;
        RootNode:=XMLDoc.CreateElement('Main');

        domelement:=XMLDoc.CreateElement('country');
        RootNode.AppendChild(domelement);

        domelement:=XMLDoc.CreateElement('industry');
        RootNode.AppendChild(domelement);

        domelement:=XMLDoc.CreateElement('other');
        RootNode.AppendChild(domelement);

        XMLDoc.AppendChild(RootNode);
        WriteXMLFile(XMLDoc,prop_file_name);
      end;
    end;
begin
  ReadProps;
  ReadStocks;
end;
end.

