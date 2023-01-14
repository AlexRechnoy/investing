unit stock_operation_list;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, Stock_Operation;

type
   EStockSellException = Class(Exception);

   { tOperationList }
   tOperationList = class(specialize TFPGInterfacedObjectList<IStockOperation>)
   private
     fOperationStrList : TStringList;
     fStockCount       : integer;     {Кол-во акций}
     fSum              : double;      {Общая стоимость акций}
     fBalance          : double;
     procedure processOperationBuy(stockOperation : IStockOperation);
     function processOperationSell(stockOperation : IStockOperation): boolean;
     procedure ClearOperationListData;
   published
     property StockCount : integer read fStockCount;
     property Sum : double read  fSum;
     property Balance : double read fBalance;
     property OperationStr : TStringList read fOperationStrList;
   public
     constructor Create;
     procedure Calculate;
     procedure AddOperation(Opearation : IStockOperation);
     procedure DeleteLastOperation;
  end;


implementation

uses Dialogs;

function sortByDate(const stock1,stock2 : IStockOperation) : longint;
begin
  if stock1.Date>stock2.Date then result:=1 else
    if stock1.Date<stock2.Date then result:=-1 else
      result:=0;
end;

{ tOpeationList }
constructor tOperationList.Create;
begin
  fOperationStrList :=TStringList.Create;
  ClearOperationListData;
  inherited Create;
end;

procedure tOperationList.ClearOperationListData;
begin
  fStockCount:=0;
  fSum       :=0;
  fBalance   :=0;
  fOperationStrList.Clear;
end;

procedure tOperationList.processOperationBuy(stockOperation: IStockOperation);
begin
  fStockCount:=fStockCount+stockOperation.Count;
  fSum       :=fSum+stockOperation.Price;
  fBalance   :=fBalance-stockOperation.Price;
end;

function tOperationList.processOperationSell(stockOperation: IStockOperation) : boolean;
begin
  Result     :=not(fStockCount-stockOperation.Count<0);
  fStockCount:=fStockCount-stockOperation.Count;
  fSum       :=fSum-stockOperation.Price;
  fBalance   :=fBalance+stockOperation.Price;
end;

procedure tOperationList.Calculate;
var TekStockOperation : IStockOperation;
    TempList          : TStringList;
    i                 : integer;
    errTxt            : string='';
begin
  ClearOperationListData;
  TempList:=TStringList.Create;
  Self.Sort(@sortByDate);

  for TekStockOperation in Self do
   begin
     if TekStockOperation.OperationType=_Operation_Buy
     then
      begin
        processOperationBuy(TekStockOperation);
        TempList.Add(Format('Дата : %s. Куплено %d за %4.2f',[DateToStr(TekStockOperation.Date), TekStockOperation.Count,TekStockOperation.Price]))
      end
     else
      begin
        if processOperationSell(TekStockOperation)
        then TempList.Add(Format('Дата : %s. Продано %d за %4.2f',[DateToStr(TekStockOperation.Date),TekStockOperation.Count,TekStockOperation.Price]))
        else
          begin
            TempList.Add(Format('!!!Некорректная продажа!!! Дата : %s. Продано %d за %4.2f',[DateToStr(TekStockOperation.Date),TekStockOperation.Count,TekStockOperation.Price]));
            errTxt:=Format('Невозможно продать так много акций... Было:%d продаю:%d Дата :%s!!!',
                                               [fStockCount,TekStockOperation.Count,DateToStr(TekStockOperation.Date)])
          end;
      end;
   end;

  fOperationStrList.Add(Format('Всего : %d за %4.2f',[fStockCount,fSum]));
  for i:=TempList.Count-1 downto 0 do
    fOperationStrList.Add(TempList[i]);
  //if errTxt<>''
  //then raise EStockSellException.Create(errTxt);
end;

procedure tOperationList.AddOperation(Opearation : IStockOperation);
begin
  add(Opearation);
  Calculate;
end;

procedure tOperationList.DeleteLastOperation;
begin
  Self.Delete(IndexOf(Self.Last));
  Calculate;
end;


end.

