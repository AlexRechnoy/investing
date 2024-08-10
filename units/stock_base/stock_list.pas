unit Stock_list;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl,  Stock;

type
  TStockList = specialize TFPGInterfacedObjectList<IStock>;

  TSortStockListFunc = function (const I1 ,I2 : IStock) : Integer;

  function sort_stock_list_by_sum_price(const I1 ,I2 : IStock) : LongInt;
  function sort_stock_list_by_balance(const I1 ,I2 : IStock) : LongInt;
  function sort_stock_list_by_price_percent(const I1 ,I2 : IStock) : LongInt;
  function sort_stock_list_by_name(const I1 ,I2 : IStock) : LongInt;



implementation

function sort_stock_list_by_sum_price(const I1 ,I2 : IStock) : LongInt;
begin
  if I1.sumPrice<I2.sumPrice then result:=1 else
    if I1.sumPrice>I2.sumPrice then result:=-1 else
      begin
        if I1.balance<I2.balance then result:=1 else
          if I1.balance>I2.balance then result:=-1 else
            result:=0;
      end;
end;

function sort_stock_list_by_balance(const I1 ,I2 : IStock) : LongInt;
begin
  if I1.balance<I2.balance then result:=1 else
    if I1.balance>I2.balance then result:=-1 else
      result:=0;
end;

function sort_stock_list_by_price_percent(const I1, I2: IStock): LongInt;
begin
  if I1.DeltaPricePercent<I2.DeltaPricePercent then result:=1 else
    if I1.DeltaPricePercent>I2.DeltaPricePercent then result:=-1 else
      begin
        if I1.balance<I2.balance then result:=1 else
          if I1.balance>I2.balance then result:=-1 else
            result:=0;

      end;
end;

function sort_stock_list_by_name(const I1, I2: IStock): LongInt;
begin
if I1.Name>I2.Name then result:=1 else
  if I1.Name<I2.Name then result:=-1 else
    result:=0;
end;

end.

