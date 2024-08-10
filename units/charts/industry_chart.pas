unit Industry_chart;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,TAGraph, TASeries, Controls, stock_Observer,Stocks_Data,
  Stock_group_list, Graphics, Stock_group, TALegend, TAChartUtils;

type

  { tIndustryChart }

  tIndustryChart = class (TChart, IStatsObserver)
   public
     constructor Create(AOwner : TComponent; AAlign : TAlign);
     procedure UpdateStats(industryStatsList, countryStatsList,filteredStatsList : tGroupStatsList);
  end;

implementation

{ tIndustryChart }

constructor tIndustryChart.Create(AOwner: TComponent; AAlign: TAlign);
begin
  inherited Create(AOwner);
  self.parent  :=AOwner as TWinControl;
  self.Align   :=AAlign;
  self.AddSeries(TPieSeries.Create(self));
  StocksData.StockStats.registerStatsObserver(self);
end;

procedure tIndustryChart.UpdateStats(industryStatsList,countryStatsList,filteredStatsList: tGroupStatsList);
var a : integer;
    function getChartPieSeries(): TPieSeries;//отрисовка вертикальных зеленых линий, которые обозначают максимумы
    var i          : integer;
        MaxVal     : double;
        tekIndustry: tStockGroup;
    begin
       Result:=TPieSeries.Create(Self);
       Result.Marks.Style:=smsLabelPercent;
       for tekIndustry in industryStatsList do
        begin
          Result.AddPie(tekIndustry.Price,tekIndustry.Name,RGBToColor(random(255),random(255),random(255)));
        end;
        Result.Title:='Title';
    end;
begin
  self.Series.Clear;
  self.LeftAxis.Visible:=false;
  self.BottomAxis.Visible:=false;
  self.AddSeries(getChartPieSeries);
end;

end.

