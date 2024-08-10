unit form_edit_props;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, ComCtrls;

type
  tProp  = ( _PROP_None,
             _PROP_Industry, //Режим редактирования свойства "Отрасль"
             _PROP_Country   //Режим редактирования свойства "Страна"
                );

  { TForm4 }
  TForm4 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtnAdd: TBitBtn;
    BitBtnEditDone: TBitBtn;
    BitBtnDelete: TBitBtn;
    Edit1: TEdit;
    USDEdit: TEdit;
    ImageList1: TImageList;
    Label1: TLabel;
    ListBox1: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    TabControl1: TTabControl;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtnAddClick(Sender: TObject);
    procedure BitBtnEditDoneClick(Sender: TObject);
    procedure BitBtnDeleteClick(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure USDEditKeyPress(Sender: TObject; var Key: char);
  private
    fProp      : tProp;
    procedure UpdateListBox;
  end;

var
  Form4: TForm4;

implementation

uses Stocks_Data, LCLType, form_exchange_property;

{$R *.lfm}

{ TForm4 }
procedure TForm4.FormShow(Sender: TObject);
begin
  Edit1.Clear;
  TabControl1Change(self);
  USDEdit.Text:=floattostr(StocksData.USDtoRUB);
end;

procedure TForm4.ListBox1Click(Sender: TObject);
begin
  Edit1.Text:=ListBox1.GetSelectedText;
end;

procedure TForm4.TabControl1Change(Sender: TObject);
begin
  Edit1.Clear;
  fProp:= tProp(TabControl1.TabIndex+1);
  UpdateListBox;
end;

procedure TForm4.USDEditKeyPress(Sender: TObject; var Key: char);
begin
  If Not (Key In ['0'..'9', DecimalSeparator, #8, #13])
  then Key:= #0;
end;

procedure TForm4.BitBtn1Click(Sender: TObject);
var valDouble : double;
begin
  if (TryStrToFloat(USDEdit.Text, valDouble)) and (valDouble>0)
  then StocksData.USDtoRUB:=valDouble;
end;

{Добавление свойства}
procedure TForm4.BitBtnAddClick(Sender: TObject);
begin
  if Edit1.Text<>'' then
   begin
     case fProp of
         _PROP_Country : begin
                           StocksData.AddCountry(edit1.text);
                           UpdateListBox;
                         end;
         _PROP_Industry: begin
                           StocksData.AddIndustry(edit1.text);
                           UpdateListBox;
                         end;
     end;
   end;
end;

{Переименовка свойства}
procedure TForm4.BitBtnEditDoneClick(Sender: TObject);
var oldProp : string;
begin
  case fProp of
      _PROP_Country :begin
                       oldProp:=StocksData.CountryList[ListBox1.ItemIndex];

                     end;
      _PROP_Industry:begin
                       oldProp:=StocksData.IndustryList[ListBox1.ItemIndex];
                       if MessageDlg('Замена названия отрасли ',Format('Заменить отрасль с "%s" на "%s"?',[oldProp,edit1.text]), mtConfirmation,[mbYes,mbNo,mbAbort],0)=mrYes then
                        begin
                          StocksData.IndustryList.Delete(ListBox1.ItemIndex);
                          StocksData.IndustryList.Add(edit1.text);
                          UpdateListBox;
                          StocksData.ExchangeIndustry(oldProp,edit1.text);
                        end;
                     end;
  end;
end;

{Удаление свойства из списка}
procedure TForm4.BitBtnDeleteClick(Sender: TObject);
var deletedIndustry : string;
begin
  case fProp of
      _PROP_Country :begin  end;
      _PROP_Industry:begin
                       if MessageDlg('Удаление отрасли ','Удалить отрасль из списка?', mtConfirmation,[mbYes,mbNo,mbAbort],0)=mrYes then
                        begin
                          deletedIndustry:=StocksData.IndustryList[ListBox1.ItemIndex];
                          StocksData.IndustryList.Delete(ListBox1.ItemIndex);
                          Form5.deletedIndustry:=deletedIndustry;
                          Form5.Show;
                          UpdateListBox;
                          Edit1.Text:='';
                          StocksData.IsSaved:=false;
                        end;
                     end;
  end;
end;


procedure TForm4.Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key=VK_RETURN
  then BitBtnEditDoneClick(self);
end;

procedure TForm4.UpdateListBox;
begin
  ListBox1.Clear;
  case fProp of
      _PROP_Country : ListBox1.Items.AddStrings(StocksData.CountryList)  ;
      _PROP_Industry: ListBox1.Items.AddStrings(StocksData.IndustryList);
  end;
end;

end.

