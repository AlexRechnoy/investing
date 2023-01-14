unit Portfolio;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, Stock;

{ tStock_Portfolio }
type

  { tPortfolio }

  tPortfolio = class
   private
    fName       : string;
    fStock_List : IStockList;
   public
    constructor Create(aName : string);
    constructor Create(aName : string; aStock : IStock);
    function Get_Stock(const Name : string) : IStock; //найти акцию в портфеле по названию
    procedure Add_Stock(aStock : IStock);
    procedure Delete_Stock(aStock : IStock);
    property PortfolioName : string read fName;
    property Stocks : IStockList read fStock_List;
  end;
  ptPortfolio = ^ tPortfolio;

tPortfolio_List = specialize TFPGList<tPortfolio>;

implementation

{ tStock_Portfolio }

constructor tPortfolio.Create(aName: string);
begin
  fName:=AName;
  fStock_List :=IStockList.Create;
end;

constructor tPortfolio.Create(aName: string; aStock: IStock);
begin
  Create(AName);
  fStock_List.Add(aStock);
end;

function tPortfolio.Get_Stock(const Name: string): IStock;
var tekStock : IStock;
begin
  Result := nil;
  for tekStock in fStock_List do
    if lowercase(tekStock.Name) = lowercase(Name) then
    begin
      Result := tekStock;
      break;
    end;
end;

procedure tPortfolio.Add_Stock(aStock: IStock);
begin
  aStock.portfolio_name:=fName;
  fStock_List.Add(aStock);
end;

procedure tPortfolio.Delete_Stock(aStock: IStock);
var i : integer;
begin
  aStock.portfolio_name:='';
  for i:=0 to fStock_List.Count-1 do
    if fStock_List[i]=aStock then
     begin
       fStock_List.Delete(i);
       break;
     end;
end;

end.

