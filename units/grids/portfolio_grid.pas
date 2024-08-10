unit Portfolio_Grid;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls, Grids, Portfolio_Observer, Portfolio_List,
  Portfolio_Data, Portfolio;

type

  { tPortfolioGrid }
  tPortfolioGrid = class(TStringGrid,IPortfolioObserver)
  public
    constructor Create(AOwner : TComponent);
    procedure UpdatePortfolioStats(portfolioList : tPortfolioList);//Обновление
  end;

implementation

{ tPortfolioGrid }
function sortByBalance(const P1,P2 : tPortfolio ) : integer;
begin
  if P1.BalanceUSD>P2.BalanceUSD then Result:=-1 else
    if P1.BalanceUSD<P2.BalanceUSD then Result:=1 else
      Result:=0;
end;

constructor tPortfolioGrid.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  self.Parent  :=AOwner as TWinControl;
  self.Align   :=alClient;
  self.ColCount:=7;
  self.DefaultColWidth:=110;
  self.Cells[1,0]:='Название портфеля';
  self.Cells[2,0]:='Стоимость "на руках", USD';
  self.Cells[3,0]:='Баланс, USD';
  self.Cells[4,0]:='Баланс, %';
  self.Cells[5,0]:='Вложено, USD';
  self.Cells[6,0]:='Кол-во компаний';
  self.ColWidths[0]:=20;
  self.ColWidths[1]:=150;
  self.ColWidths[2]:=220;
  self.ColWidths[6]:=140;
  self.FixedCols:=1;
  self.BorderSpacing.Around:=5;

  self.Font.Size:=12;

  PortfolioData.registerObserver(self);
end;

procedure tPortfolioGrid.UpdatePortfolioStats(portfolioList: tPortfolioList);
var index         : integer=1;
    currPortfolio : tPortfolio;
    tmpPortfolioList : tPortfolioList;
begin
  tmpPortfolioList :=tPortfolioList.create;
  tmpPortfolioList.Assign(portfolioList);
  tmpPortfolioList.Sort(@sortByBalance);

  self.RowCount:=tmpPortfolioList.Count+1;
  for currPortfolio in tmpPortfolioList do
   begin
     self.Cells[0,index]:=inttostr(index);
     self.Cells[1,index]:=currPortfolio.PortfolioName;
     self.Cells[2,index]:=Format('%4.2f',[currPortfolio.SumPriceUSD]);
     self.Cells[3,index]:=Format('%4.2f',[currPortfolio.BalanceUSD]);
     self.Cells[4,index]:=Format('%4.1f',[currPortfolio.BalancePercent]);
     self.Cells[5,index]:=Format('%4.2f',[currPortfolio.SumPriceUSD-currPortfolio.BalanceUSD]);
     self.Cells[6,index]:=Format('%d',[currPortfolio.CompanyCount]);
     inc(index);
   end;
  tmpPortfolioList.Free;
end;

end.

