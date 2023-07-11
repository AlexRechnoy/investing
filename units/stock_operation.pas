unit Stock_Operation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,fgl;

type

  { tStockOperation }
  tOperationType = (_Operation_Buy,_Operation_Sell);

  IStockOperation = interface  ['{BDCD03C2-0889-40C9-A366-0BD42BD6C14E}']
    function GetCount  : integer;
    function GetPrice : single;
    function GetOperationType : tOperationType;
    function GetDate : TDate;
    function GetID  : integer;
    property ID : integer read GetID;
    property Count : integer read GetCount;
    property Price : single read GetPrice;
    property OperationType : tOperationType read GetOperationType;
    property Date : TDate read GetDate;
  end;

  tStockOperation = class(TInterfacedObject,IStockOperation) {Операция по акции}
   private
    fDate         : TDate;          {Дата}
    fOperationType: tOperationType; {Тип операции}
    fCount        : integer;        {Кол-во акций за операцию}
    fPrice        : single;         {Стоимость покупуки/продажи}
    fID           : integer;        {Уникальный ID операции. Для выбранной акции}
   public
    constructor Create(aDate:TDate;aOperationType:tOperationType;aCount:integer; aPrice:single; aID : integer);
    function GetCount  : integer;
    function GetPrice : single;
    function GetID  : integer;
    function GetOperationType : tOperationType;
    function GetDate : TDate;
    property OperationType : tOperationType read GetOperationType;
    property Count : integer read GetCount;
    property Price : single read GetPrice;
    property Date : TDate read GetDate;
  end;


implementation

{ tStockOperation }
constructor tStockOperation.Create(aDate: TDate;
  aOperationType: tOperationType; aCount: integer; aPrice: single; aID: integer);
begin
  fDate:=aDate;
  fOperationType:=aOperationType;
  fCount:=aCount;
  fPrice:=aPrice;
  fID   :=aID;
end;

function tStockOperation.GetCount: integer;
begin
  Result:=fCount;
end;

function tStockOperation.GetPrice: single;
begin
  Result:=fPrice;
end;

function tStockOperation.GetID: integer;
begin
  Result:=FID;
end;

function tStockOperation.GetOperationType: tOperationType;
begin
  Result:=fOperationType;
end;

function tStockOperation.GetDate: TDate;
begin
  Result:=fDate;
end;

end.

