unit Tab_Statistics;
{Вкладка "Портфель". Граф элементы панели , относящиесли к портфелю            }

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls,
  Industry_Grid, Industry_chart, Country_Grid, Portfolio_Data, Stocks_Data,
  Country_chart;

type

  { tStatisticsTab }
  tStatisticsTab = class
   private
    FForm             : TForm;    //Ссылка на главную форму
    fcountryChart     : tCountryChart;
    findustryChart    : tIndustryChart;
    findustryGrid     : tIndustryGrid;
    fcountryGrid      : tCountryGrid;
    FportfolioCombo   : TComboBox;   //Комобобокс выбора портфеля


    FPortfolioPanel   : TPanel;   //Панель статистики по портфелям
    FCountryPanel     : TPanel;   //Панель статистики по странам
    procedure ChangePortfolioCombo(Sender: TObject);
    procedure SetPortfolioCombo;
   public
    constructor Create(AForm : TForm);
  end;

implementation

{ tStatisticsTab }

procedure tStatisticsTab.SetPortfolioCombo;
begin
  FportfolioCombo.Clear;
  FportfolioCombo.Items.Add('Все');
  FportfolioCombo.Items.AddStrings(PortfolioData.PortfolioNames);
  FportfolioCombo.ItemIndex:=0;
end;

constructor tStatisticsTab.Create(AForm: TForm);
begin
  FForm:=AForm;
  FportfolioCombo              :=FForm.FindComponent('StatsPortfolioCombo') as TComboBox;
  FportfolioCombo.OnChange     :=@ChangePortfolioCombo;
  FCountryPanel                :=FForm.FindComponent('StatsCountryPanel') as TPanel;
  FPortfolioPanel              :=FForm.FindComponent('StatsPortfolioPanel') as TPanel;
  //Вкладка "Статистика"
  findustryGrid                :=tIndustryGrid.Create(FPortfolioPanel,alLeft);
  findustryChart               :=tIndustryChart.Create(FPortfolioPanel,alClient);
  fcountryGrid                 :=tCountryGrid.Create(FCountryPanel,alleft);
  fcountryChart                :=tCountryChart.Create(FCountryPanel,alClient);
  //
  SetPortfolioCombo;
end;

procedure tStatisticsTab.ChangePortfolioCombo(Sender: TObject);
begin
  StocksData.SetPortfolioStats(FportfolioCombo.Text);
end;


end.

