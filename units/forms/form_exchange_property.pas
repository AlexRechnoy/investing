unit form_exchange_property;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type
  { TForm5 }

  TForm5 = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FdeletedIndustry : string;
  public
    property deletedIndustry : string read FdeletedIndustry write FdeletedIndustry;
  end;

var
  Form5: TForm5;

implementation

uses Stocks_Data;

{$R *.lfm}

{ TForm3 }

procedure TForm5.FormCreate(Sender: TObject);
begin

end;

procedure TForm5.Button1Click(Sender: TObject);
begin
  StocksData.ExchangeIndustry(deletedIndustry,ComboBox1.Text);
  Hide;
end;

procedure TForm5.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  StocksData.ExchangeIndustry(deletedIndustry,ComboBox1.Text);
end;

procedure TForm5.FormShow(Sender: TObject);
begin
  ComboBox1.Clear;
  ComboBox1.Items.AddStrings(StocksData.IndustryList);
  ComboBox1.ItemIndex:=0;
end;

end.

