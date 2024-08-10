unit Stock_filtered_list;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl,  Stock, Stock_list;

type

  { TStockFilteredList }

  TStockFilteredList = class (TStockList)
   private
    FStockNames   : TStringList;  {Список названий отфильтрованных акций}
   public
    constructor Create;
    procedure UpdateFilteredStocks(AStockList : TStockList;
                                   const AChosenPortfolio, AChosenCountry, AChosenIndusrty : string);
    procedure SortList(Compare: TSortStockListFunc);
    property StockNames : TStringList read FStockNames;
    destructor destroy; override;
  end;

implementation

{ TStockFilteredList }

constructor TStockFilteredList.Create;
begin
  inherited Create;
  FStockNames:=TStringList.Create;
end;

procedure TStockFilteredList.UpdateFilteredStocks(AStockList : TStockList;
                                                  const AChosenPortfolio, AChosenCountry, AChosenIndusrty : string);
var i : integer;
    function filterIsPassed(const chosenProperty, stockProperty: string ) : boolean;
    begin
      if (chosenProperty='') or (chosenProperty='Все')
      then result:=true
      else result:=AnsiLowerCase(chosenProperty)=AnsiLowerCase(stockProperty);
    end;
    function isInChosenPortfolio(Stock : IStock) : boolean;
    var tekPortfolio  :string;
    begin
      Result:=false;
      if AChosenPortfolio='' then exit;
      for tekPortfolio in Stock.portfolios do
        if ansilowercase(tekPortfolio)=ansilowercase(AChosenPortfolio) then
         begin
           Result:=true;
           exit;
         end;
    end;
begin
  self.Clear;
  FStockNames.Clear;
  for i:=0 to AStockList.Count-1 do
    if  AChosenPortfolio<>'' then
     begin
       if isInChosenPortfolio(AStockList[i]) then
        begin
          self.Add(AStockList[i]);
          FStockNames.Add(AStockList[i].Name);
        end;
     end
    else
     begin
       if filterIsPassed(AChosenCountry,AStockList[i].Country) and filterIsPassed(AChosenIndusrty,AStockList[i].Industry) then
        begin
          self.Add(AStockList[i]);
          FStockNames.Add(AStockList[i].Name);
        end;
     end;
end;

procedure TStockFilteredList.SortList(Compare: TSortStockListFunc);
var i : integer;
begin
  Sort(Compare);
  FStockNames.Clear;
  for i:=0 to Self.Count-1 do
    FStockNames.Add(Self[i].Name);
end;

destructor TStockFilteredList.destroy;
begin
  FStockNames.Free;
  inherited destroy;
end;

end.

