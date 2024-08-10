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
     fSum              : double;      {Общая стоимость акций, которые в данный момент "на руках". Например купили 2 по 15, сумма = 30; продали 1 за 20, сумма = 10
                                      (Учитывается только стоимость покупки и продажи, текущая цена неизвестна ....)}
     fBalance          : double;      {Баланс за операции по акциям. При покупке акций уходит в минус. Например купили 2 по 15, баланс = -30; продали 1 за 20, баланс = -10
                                      (Учитывается только стоимость покупки и продажи, текущая цена неизвестна ....)}
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
     function getMaxOperationID : integer;
     procedure DeleteLastOperation;
     procedure DeleteAllOperations;
  end;


implementation

uses Dialogs, Math;

function sortByDate(const stock1,stock2 : IStockOperation) : longint;
begin
  if stock1.Date>stock2.Date then result:=1 else
    if stock1.Date<stock2.Date then result:=-1 else
      begin
        if stock1.ID>stock2.ID then result:=1 else
          if stock1.ID<stock2.ID then result:=-1 else
            result:=0;
      end;
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
    index             : integer=0;
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
        TempList.Add(Format('%d)  Дата : %s. Куплено %d за %4.2f. Среднее = %4.2f. ID = %d',[index,
                                                                                             DateToStr(TekStockOperation.Date),
                                                                                             TekStockOperation.Count,
                                                                                             TekStockOperation.Price,
                                                                                             TekStockOperation.Price/TekStockOperation.Count,
                                                                                             TekStockOperation.ID])
                    )
      end
     else
      begin
        if processOperationSell(TekStockOperation)
        then TempList.Add(Format('%d)  Дата : %s. Продано %d за %4.2f. Среднее = %4.2f. ID = %d',[index,
                                                                                                  DateToStr(TekStockOperation.Date),
                                                                                                  TekStockOperation.Count,
                                                                                                  TekStockOperation.Price,
                                                                                                  TekStockOperation.Price/TekStockOperation.Count,
                                                                                                  TekStockOperation.ID]))
        else
          begin
            TempList.Add(Format('!!!Некорректная продажа!!! Дата : %s. Продано %d за %4.2f',[DateToStr(TekStockOperation.Date),TekStockOperation.Count,TekStockOperation.Price]));
            errTxt:=Format('Невозможно продать так много акций... Было:%d продаю:%d Дата :%s!!!',
                                               [fStockCount,TekStockOperation.Count,DateToStr(TekStockOperation.Date)])
          end;
      end;
      inc(index);
   end;


  fOperationStrList.Add(Format('Всего : %d за %4.2f',[fStockCount,fSum]));
  //fOperationStrList.AddStrings(TempList);
  for i:=TempList.Count-1 downto 0 do
    fOperationStrList.Add(TempList[i]);


  //if errTxt<>''
  //then raise EStockSellException.Create(errTxt);
end;

procedure tOperationList.AddOperation(Opearation : IStockOperation);
begin
  self.Add(Opearation);
  Calculate;
end;

function tOperationList.getMaxOperationID: integer;
var TekStockOperation : IStockOperation;
begin
  result:=-1;
  for TekStockOperation in Self do
    result:=Max(result,TekStockOperation.ID);
end;

procedure tOperationList.DeleteLastOperation;
begin
  if self.Count>0 then
   begin
     Self.Delete(IndexOf(Self.Last));
     Calculate;
   end;
end;

procedure tOperationList.DeleteAllOperations;
begin
  Self.Clear;
  Calculate;
end;


end.

