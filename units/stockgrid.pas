unit stockGrid;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Grids, Graphics, Controls,
  Stock;

type

  { tStockGrid }
  tStockGrid = class (TStringGrid)
   private
     fStock : IStock;
   public
     constructor Create(AOwner : TComponent);
     procedure updateData(stock : IStock);
     procedure OnGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
  end;

implementation

{ tStockGrid }

constructor tStockGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  self.parent:=AOwner as TWinControl;
  self.OnDrawCell:=@OnGridDrawCell;
  self.RowCount:=6;
  self.ColCount:=2;
  self.Height:=150;
  self.ColWidths[0]:=150;
  self.ColWidths[1]:=200;
  self.Cells[0,1]:='Отрасль';
  self.Cells[0,2]:='Количество акций';
  self.Cells[0,3]:='Цена акций';
  self.Cells[0,4]:='Средняя цена акции';
  self.Cells[0,5]:='Баланс';
end;

procedure tStockGrid.updateData(stock : IStock);
    function hideNegative(val : double):string;
    begin
      Result:='<0';
      if val>=0 then Result:=Format('%4.2f',[val]);
    end;
begin
  fStock:=stock;
  self.Cells[1,1]:=stock.industry;
  self.Cells[1,2]:=inttostr(stock.Count);
  if stock.Count=0
  then self.Cells[1,3]:='-'
  else self.Cells[1,3]:=hideNegative(stock.sumPrice);
  if stock.Count=0
  then self.Cells[1,4]:='-'
  else self.Cells[1,4]:=hideNegative(stock.averagePrice);
  if stock.Count=0
  then self.Cells[1,5]:=Format('%4.2f',[stock.balance])
  else
   begin
     if stock.sumPrice<0
     then self.Cells[1,5]:=Format('%4.2f + акции на руках',[stock.balance])
     else self.Cells[1,5]:='-';
   end;
end;

procedure tStockGrid.OnGridDrawCell(Sender: TObject; aCol, aRow: Integer;
                                    aRect: TRect; aState: TGridDrawState);
    function getColor(stock : IStock) : tcolor;
    var positiveColor : tcolor;
        negativeColor : tcolor;
    const balanceColors : array [boolean] of tcolor = (clRed,clGreen);
    begin
      positiveColor:=RGBToColor(128,230,140);
      negativeColor:=RGBToColor(248,123,105);
      Result:=clWhite;
      if stock.Count=0
      then
       begin
         if stock.balance>0 then result:=positiveColor else result:=negativeColor;
       end
      else if stock.sumPrice<0 then Result:=positiveColor;
    end;
begin
  if aCol=0 then
   begin
     self.Canvas.Font.Style:=[fsBold];
     self.Canvas.FillRect(aRect);
     self.Canvas.TextOut(aRect.Left,aRect.Top,self.Cells[ACol,ARow]);
   end;
  if (aCol=1) and (aRow>0) then
   begin
     self.Canvas.Brush.Color:=getColor(fStock);
     self.Canvas.FillRect(aRect);
     self.Canvas.TextOut(aRect.Left,aRect.Top,self.Cells[ACol,ARow]);
   end;
end;

end.

