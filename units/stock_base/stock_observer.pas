unit Stock_Observer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl, Stock, Stock_list, Stock_filtered_list, Stock_group_list ;

type
  IObserver = interface ['{C9D24B98-156D-4975-BB60-729F60FBB8F1}']
    procedure UpdateStock(stock : IStock);    //Обновление : tStockPanel (->Stock_Property_Grid) ,form_add_stock
    procedure UpdateFilteredStockList(StockFilteredList : TStockFilteredList);//Обновление : Stocks_Grid(Основная таблица с перечнем акций)
  end;
  TObserverList = specialize TFPGInterfacedObjectList<IObserver>;

  {Интерфейс субъекта. Используется объектами для регистрации в качестве наблюдателя}
  {а так же исключения из списка}
  ISubject = interface['{06B97802-AADC-4E74-B895-4ACD30AA75BC}']
    procedure registerObserver(O : IObserver);
    procedure removeObserver(O : IObserver);
    procedure notifyObservers();  //Оповестить наблюдатей за выбранной акцией
    //procedure notifyIndustryObservers();
  end;

  IStatsObserver = interface['{129F3E0B-8456-46AA-BBF3-CDF86A9A208D}']
    procedure UpdateStats(industryStatsList, countryStatsList, filteredStatsList : tGroupStatsList);//Обновление : Industry_Grid,Country_Grid,Country_Chart, Stocks_Grid(Основная таблица с перечнем акций)
  end;
  TStatsObserverList = specialize TFPGInterfacedObjectList<IStatsObserver>;

  ISubjectStats = interface ['{8E1A75A8-65C3-4949-AED1-5385D4AD4404}']
    procedure registerStatsObserver(O : IStatsObserver);
    procedure removeStatsObserver(O : IStatsObserver);
    procedure notifyStatsObservers();
  end;



implementation

end.

