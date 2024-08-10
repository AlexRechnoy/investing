unit Country_Grid;
{Вкладка "Статистика". Нижняя часть}

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Grids, Controls, Stock_group_list,Stock_group, Stock_Observer,
  Stocks_Data, Graphics;

type

  { tCountryGrid }
  tCountryGrid = class (TStringGrid, IStatsObserver)
   public
    constructor Create(AOwner : TComponent; AAlign : TAlign);
    procedure UpdateStats(industryStatsList, countryStatsList,filteredStatsList : tGroupStatsList);
    procedure OnGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
  end;

implementation

{ tIndustryGrid }
constructor tCountryGrid.Create(AOwner: TComponent; AAlign : TAlign);
begin
  inherited Create(AOwner);
  self.parent  :=AOwner as TWinControl;
  self.Align   :=AAlign;
  self.DefaultRowHeight:=30;
  self.RowCount:=1;
  self.ColCount:=4;
  self.Height:=150;
  self.Width:=600;
  self.ColWidths[0]:=150;
  self.ColWidths[1]:=120;
  self.ColWidths[2]:=160;
  self.ColWidths[3]:=80;
  self.Cells[0,0]:='Страна';
  self.Cells[1,0]:='Кол-во компаний';
  self.Cells[2,0]:='Стоимость акций(USD)';
  self.Cells[3,0]:='В процентах';
  self.OnDrawCell:=@OnGridDrawCell;
  StocksData.StockStats.registerStatsObserver(self);
end;

procedure tCountryGrid.UpdateStats(industryStatsList, countryStatsList,filteredStatsList : tGroupStatsList);
var tekCountry  : tStockGroup;
    tekRow      : integer=1;
    sumPercent  : double=0;
    currPercent : double=0;
begin
  self.RowCount:=countryStatsList.Count+2;
  for tekCountry in countryStatsList do
   begin
     self.Cells[0,tekRow]:=tekCountry.Name;
     self.Cells[1,tekRow]:=inttostr(tekCountry.CompanyCount);
     self.Cells[2,tekRow]:=Format('%4.2f',[tekCountry.Price]);
     currPercent:=(tekCountry.Price/countryStatsList.SumPriceUSD)*100;
     self.Cells[3,tekRow]:=Format('%4.2f',[currPercent]);
     sumPercent+=currPercent;
     inc(tekRow);
   end;
   self.Cells[0,tekRow]:='Суммарно';
   self.Cells[1,tekRow]:=inttostr(countryStatsList.CompanyCount);
   self.Cells[2,tekRow]:=Format('%4.2f',[countryStatsList.SumPriceUSD]);
   self.Cells[3,tekRow]:=Format('%4.2f',[sumPercent]);
end;

procedure tCountryGrid.OnGridDrawCell(Sender: TObject; aCol, aRow: Integer;
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

