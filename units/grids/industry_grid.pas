unit Industry_Grid;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Grids, Graphics, Controls, Stock_group_list,Stock_group,
  stock_Observer, Stocks_Data;

type

  { tIndustryGrid }
  tIndustryGrid = class (TStringGrid, IStatsObserver)
   private
    procedure OnGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
   public
    constructor Create(AOwner : TComponent; AAlign : TAlign);
    procedure UpdateStats(industryStatsList, countryStatsList,filteredStatsList : tGroupStatsList);
  end;

implementation


{ tIndustryGrid }
constructor tIndustryGrid.Create(AOwner: TComponent; AAlign : TAlign);
begin
  inherited Create(AOwner);
  self.parent  :=AOwner as TWinControl;
  self.Align   :=AAlign;
  self.RowCount:=1;
  self.ColCount:=4;
  self.Height:=150;
  self.Width:=600;
  self.DefaultRowHeight:=30;
  self.ColWidths[0]:=150;
  self.ColWidths[1]:=120;
  self.ColWidths[2]:=160;
  self.ColWidths[3]:=80;
  self.Cells[0,0]:='Отрасль';
  self.Cells[1,0]:='Кол-во компаний';
  self.Cells[2,0]:='Стоимость акций(USD)';
  self.Cells[3,0]:='В процентах';
  self.OnDrawCell:=@OnGridDrawCell;
  StocksData.StockStats.registerStatsObserver(self);
end;

procedure tIndustryGrid.UpdateStats(industryStatsList, countryStatsList,filteredStatsList : tGroupStatsList);
var currIndustry: tStockGroup;
    tekRow      : integer=1;
    currPercent : double=0;
    sumPercent  : double=0;
begin
  self.RowCount:=industryStatsList.Count+2;
  for currIndustry in industryStatsList do
   begin
     self.Cells[0,tekRow]:=currIndustry.Name;
     self.Cells[1,tekRow]:=inttostr(currIndustry.CompanyCount);
     self.Cells[2,tekRow]:=Format('%4.2f',[currIndustry.Price]);
     currPercent:=(currIndustry.Price/industryStatsList.SumPriceUSD)*100;
     sumPercent+=currPercent;
     self.Cells[3,tekRow]:=Format('%4.2f',[currPercent]);
     inc(tekRow);
   end;
   self.Cells[0,tekRow]:='Суммарно';
   self.Cells[1,tekRow]:=inttostr(industryStatsList.CompanyCount);
   self.Cells[2,tekRow]:=Format('%4.2f',[industryStatsList.SumPriceUSD]);
   self.Cells[3,tekRow]:=Format('%4.2f',[sumPercent]);
end;


procedure tIndustryGrid.OnGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if (aRow=0) or (aRow=self.RowCount-1) then
   begin
     self.Canvas.Font.Style:=[fsBold];
     self.Canvas.FillRect(aRect);
     self.Canvas.TextOut(aRect.Left+2,aRect.Top+2,self.Cells[ACol,ARow]);
   end;
end;

end.

