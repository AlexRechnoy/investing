unit stock_Observer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl, Stock ;

type
  IObserver = interface ['{C9D24B98-156D-4975-BB60-729F60FBB8F1}']
    procedure UpdateStock(stock : IStock);
    procedure UpdateStockList(stockList : IStockList);
  end;
  TObserverList = specialize TFPGInterfacedObjectList<IObserver>;

  {Интерфейс субъекта. Используется объектами для регистрации в качестве наблюдателя}
  {а так же исключения из списка}
  ISubject = interface['{06B97802-AADC-4E74-B895-4ACD30AA75BC}']
    procedure registerObserver(O : IObserver);
    procedure removeObserver(O : IObserver);
    procedure notifyObservers();
  end;

implementation

end.

