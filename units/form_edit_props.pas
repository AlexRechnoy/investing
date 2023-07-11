unit form_edit_props;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons;

type

  { TForm4 }

  TForm4 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    Button1: TButton;
    Edit1: TEdit;
    ImageList1: TImageList;
    ListBox1: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    fisCountry : boolean;
    fOnUpdate  : TNotifyEvent;
    procedure UpdateListBox;
  published
    property OnUpdate : TNotifyEvent read fOnUpdate write fOnUpdate;
  public
    procedure loadList(const isCountryList : boolean);
  end;

var
  Form4: TForm4;

implementation

uses Stocks_Data, LCLType;

{$R *.lfm}

{ TForm4 }
procedure TForm4.FormShow(Sender: TObject);
begin
  Edit1.Clear;
end;

procedure TForm4.ListBox1Click(Sender: TObject);
begin
  Edit1.Text:=ListBox1.GetSelectedText;
end;

procedure TForm4.BitBtn2Click(Sender: TObject);
begin
  ListBox1.Items[ListBox1.ItemIndex]:=edit1.text;
end;

procedure TForm4.BitBtn3Click(Sender: TObject);
begin
  if MessageDlg('Удаление отрасли ','Удалить отрасль из списка?', mtConfirmation,[mbYes,mbNo,mbAbort],0)=mrYes then
   begin
     StocksData.IndustryList.Delete(ListBox1.ItemIndex);
     UpdateListBox;
     Edit1.Text:='';
   end;
end;

procedure TForm4.Button1Click(Sender: TObject);
begin
  if fisCountry
  then
   begin
     StocksData.CountryList.Clear;
     StocksData.CountryList.AddStrings(ListBox1.Items);
   end
  else
   begin
     StocksData.IndustryList.Clear;
     StocksData.IndustryList.AddStrings(ListBox1.Items);
   end;
   if Assigned(fOnUpdate)
   then fOnUpdate(Self);
   StocksData.IsSaved:=false;
   self.Hide;
end;

procedure TForm4.Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key=VK_RETURN
  then BitBtn2Click(self);
end;

procedure TForm4.loadList(const isCountryList: boolean);
begin
  fisCountry:=isCountryList;
  UpdateListBox;
end;

procedure TForm4.UpdateListBox;
begin
  ListBox1.Clear;
  if fisCountry
  then ListBox1.Items.AddStrings(StocksData.CountryList)
  else ListBox1.Items.AddStrings(StocksData.IndustryList);
end;

procedure TForm4.BitBtn1Click(Sender: TObject);
begin
  if Edit1.Text<>''
  then ListBox1.Items.Add(edit1.text);
end;

end.

