unit Stock_group;
{Класс, описывающий группировку акций (например по отрасли, по стране)}

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  {  }
  tStockGroup = class
   private
    FName         : string; //Название отрасли
    FCompanyCount : integer;//Кол-во компаний отрасли
    FPrice        : double; //Суммарная цена акций, принадлежащих отрасли
   public
    constructor Create(AGroupName : string);
    constructor Create(AGroupName : string; APrice : double);
    procedure AddStock( APrice : double);
    property Name : string read FName;
    property CompanyCount : integer read FCompanyCount;
    property Price : double read FPrice;
  end;

implementation

{ tIndustry }

constructor tStockGroup.Create(AGroupName: string);
begin
  FName:=AGroupName;
  FCompanyCount:=0;
  FPrice:=0;
end;

constructor tStockGroup.Create(AGroupName: string; APrice: double);
begin
  FName:=AGroupName;
  FCompanyCount:=1;
  FPrice:=APrice;
end;

procedure tStockGroup.AddStock(APrice: double);
begin
  inc(FCompanyCount);
  FPrice:=FPrice+APrice;
end;

end.

