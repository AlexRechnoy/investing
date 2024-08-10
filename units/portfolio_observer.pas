unit Portfolio_Observer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl, Portfolio_List;

type
  IPortfolioObserver = interface['{62564DDB-46FE-4578-8CA8-E48BABE8CADA}']
    procedure UpdatePortfolioStats(portfolioList : tPortfolioList);//Обновление : Portfolio_Grid
  end;
  TPortfolioObserverList = specialize TFPGInterfacedObjectList<IPortfolioObserver>;

  ISubjectPortfolio = interface ['{8E1A75A8-65C3-4949-AED1-5385D4AD4404}']
    procedure registerObserver(O : IPortfolioObserver);
    procedure removeObserver(O : IPortfolioObserver);
    procedure notifyObservers();
  end;

implementation

end.

