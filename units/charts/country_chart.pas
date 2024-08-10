unit Country_chart;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, TAGraph, fgl, TASeries, Controls, stock_Observer,Stocks_Data,
  Stock_group_list, Graphics, Stock_group, TALegend, TAChartUtils;

type

  { tCountryChart }
  tColorList = specialize TFPGList<TColor>;

  tCountryChart = class (TChart, IStatsObserver)
    private
      FCountryColors : tColorList;
    public
      constructor Create(AOwner : TComponent; AAlign : TAlign);
      procedure UpdateStats(industryStatsList, countryStatsList,filteredStatsList : tGroupStatsList);

  end;

implementation

const countryColors: array of TColor = (clred);

{ tCountryChart }

constructor tCountryChart.Create(AOwner: TComponent; AAlign: TAlign);
begin
  inherited Create(AOwner);
  FCountryColors:=tColorList.Create;
  FCountryColors.Add(RGBToColor(236,124,124));
  FCountryColors.Add(RGBToColor(220,139,40));
  FCountryColors.Add(RGBToColor(174,195,238));
  FCountryColors.Add(RGBToColor(238,210,175));

  self.parent  :=AOwner as TWinControl;
  self.Align   :=AAlign;
  self.AddSeries(TPieSeries.Create(self));
  StocksData.StockStats.registerStatsObserver(self);
end;

procedure tCountryChart.UpdateStats(industryStatsList,countryStatsList,filteredStatsList: tGroupStatsList);
var a : integer;
    function getChartPieSeries(): TPieSeries;//отрисовка вертикальных зеленых линий, которые обозначают максимумы
    var i          : integer;
        MaxVal     : double;
        tekCountry : tStockGroup;
        index      : integer=0;
    begin
       Result:=TPieSeries.Create(Self);
      // Result.Legend.Multiplicity:=lmPoint;
       Result.Marks.Style:=smsLabelPercent;
       for tekCountry in countryStatsList do
        begin
          if index>FCountryColors.Count-1
          then index:=0;
          Result.AddPie(tekCountry.Price,tekCountry.Name,FCountryColors[index]);
          inc(index);
        end;
        Result.Title:='Title';
       //Result.MarkPositions:=lmpPositive;
       //Result.Marks.Style:=smsValue;
       //Result.Marks.OverlapPolicy:=opHideNeighbour;
       {for i:=0 to FCore.GetDayBetList.Count-1 do
        begin
          tekVal:=tekVal+FCore.GetDayBetList[i].Stat.Sum;
          if TekVal>MaxVal then
           begin
             if i>=MinDay
             then Result.AddXY(i,TekVal,'',clGreen);
             MaxVal:=TekVal;
           end;
        end;  }
    end;
begin
  self.Series.Clear;
 // self.Legend.Visible:=true;

  self.LeftAxis.Visible:=false;
  self.BottomAxis.Visible:=false;

  self.AddSeries(getChartPieSeries);

{ Chart1PieSeries1.Clear;
  Chart1PieSeries1.Legend.Visible:=true;
  Chart1PieSeries1.Legend.Multiplicity:=lmPoint;
  Chart1PieSeries1.Marks.Style:=smsLabelPercent;
  case ComboBox5.ItemIndex of
      0 : DrawChart(BeerData.DateBeer.Sum.VolumeCountry);
      1 : DrawChart(BeerData.DateBeer.Sum.VolumeStyle);
      2 : DrawChart(BeerData.DateBeer.Sum.VolumeColor);
      3 : DrawChart(BeerData.DateBeer.Sum.VolumeBrand);
  end;
  Chart1PieSeries1.Title:=ChartTitle[ComboBox5.ItemIndex];
  Chart1PieSeries1.Legend.Visible:=true;  }
end;

end.

