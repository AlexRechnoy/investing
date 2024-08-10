unit Portfolio_List;
{Список портфелей }

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl, Portfolio, Stock;

type

  { tPortfolioList }
  tPortfolioList = class (specialize TFPGList<tPortfolio>)
    private
     FPortfolioNames : TStringList;
     procedure AddPortfolio(const APortfolioName : string ; AStock : IStock);
     procedure AddStockToPortfolio(const APortfolioIndex : integer; AStock : IStock; const AddToPortfolio : boolean = true);
     function GetPortfolioIndex(const APortfolioName : string): integer;
     function GetPortfolioNames : tstringlist;  //Список названий портфелей
    public
     constructor create;
     destructor destroy; override;
     procedure UpdatePortfolioStats; //Обновить статистику портфелей
     procedure AddStock(const APortfolioName : string; AStock : IStock;  const addToPortfolio: boolean);
     function AddPortfolio(const APortfolioName : string) : boolean;
     function GetPortfolioName(const APortfolioIndex : integer) : string; //Выбранный портфель
     procedure DeletePortfolio(const AportfolioIndex : integer);
     property PortfolioNames : TStringList read GetPortfolioNames;
  end;

implementation

{ tPortfolioList }
constructor tPortfolioList.create;
begin
  FPortfolioNames:=tstringlist.Create;
  inherited create;
end;

procedure tPortfolioList.AddPortfolio(const APortfolioName: string; AStock: IStock);
var s : string;
begin
  s:= APortfolioName;
  self.Add(tPortfolio.Create(APortfolioName,AStock));
end;

procedure tPortfolioList.AddStockToPortfolio(const APortfolioIndex: integer;
  AStock: IStock; const AddToPortfolio: boolean);
begin
  self[APortfolioIndex].Add_Stock(AStock,AddToPortfolio);
end;

procedure tPortfolioList.UpdatePortfolioStats;
var i : integer;
begin
  for i:=0 to self.count-1 do
    self[i].UpdatePortfolioStats;
end;

procedure tPortfolioList.AddStock(const APortfolioName: string; AStock: IStock;
  const addToPortfolio: boolean);
var index : integer;
begin
  if (APortfolioName<>'') then
   begin
     index:=GetPortfolioIndex(APortfolioName);
     if index=-1  {портфель еще не создан}
     then self.AddPortfolio(APortfolioName,AStock)
     else self.AddStockToPortfolio(index,AStock,addToPortfolio);
  end;
end;

function tPortfolioList.AddPortfolio(const APortfolioName: string) : boolean;
var portfolioIndex : integer;
begin
  Result:=true;
  portfolioIndex:=GetPortfolioIndex(APortfolioName);
  if portfolioIndex=-1
  then self.Add(tPortfolio.Create(APortfolioName))
  else Result:=false;
end;

procedure tPortfolioList.DeletePortfolio(const AportfolioIndex: integer);
var currStock : IStock;
    index     : integer;
begin
  for currStock in self[AportfolioIndex].Stocks do
   begin
     index:= currStock.portfolios.IndexOf(self[AportfolioIndex].PortfolioName);
     if index>=0
     then currStock.portfolios.Delete(index);
   end;
  self.Delete(AportfolioIndex);
end;

function tPortfolioList.GetPortfolioIndex(const APortfolioName : string) : integer;
var tekPortfolio : tPortfolio;
    i            : integer;
begin
  Result:=-1;
  for i:=0 to self.count-1 do
   begin
     if self[i].PortfolioName=APortfolioName then
      begin
        Result:=i;
        break;
      end;
   end;
end;

function tPortfolioList.GetPortfolioNames: tstringlist;
var cuttPortfolio : tPortfolio;
begin
  FPortfolioNames.Clear;
  for cuttPortfolio in self do
    FPortfolioNames.Add(cuttPortfolio.PortfolioName);
  Result:=FPortfolioNames;
end;

function tPortfolioList.GetPortfolioName(const APortfolioIndex : integer): string;
begin
  Result:='';
  if (APortfolioIndex>=0) and (APortfolioIndex<self.Count)
  then Result:=self[APortfolioIndex].PortfolioName;
end;

destructor tPortfolioList.destroy;
begin
  FPortfolioNames.Free;
  inherited destroy;
end;



end.

