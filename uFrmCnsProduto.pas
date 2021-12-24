unit uFrmCnsProduto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uFrmCnsBase, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.Objects,
  FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, System.ImageList,
  FMX.ImgList;

type
  TfrmCnsProduto = class(TfrmCnsBase)
    imgFavorito: TImage;
    imgMarcado: TImage;
    imgDesmarcado: TImage;
    procedure FormCreate(Sender: TObject);
    procedure imgFavoritoClick(Sender: TObject);
    procedure lvConsultaItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure edtBuscaChangeTracking(Sender: TObject);
  private
    { Private declarations }
    procedure pCarregarProduto;
    procedure pAlterarFavorito;
    procedure pAtualizarImgFavorito;
    procedure pAdicionarProdutoLista(const barras, nome: String; const aUnit,
      desconto: Currency; favorito: Integer);
  public
    { Public declarations }
  end;

var
  frmCnsProduto: TfrmCnsProduto;

implementation

uses
  uDmPrincipal, uUtilitarios;

{$R *.fmx}

procedure TfrmCnsProduto.imgFavoritoClick(Sender: TObject);
begin
  inherited;
  pAtualizarImgFavorito;
  pCarregarProduto;
end;

procedure TfrmCnsProduto.lvConsultaItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
const ItemObject: TListItemDrawable);
var
  barras: String;
  favorito: integer;
begin
  barras := TListItemText(lvConsulta.items[ItemIndex].Objects.FindDrawable('Text1')).TagString;

  if ItemObject is TListItemImage then {FAVORITO}
  begin
    try

      if TListItemImage(lvConsulta.items[ItemIndex].Objects.FindDrawable('Image5')).Bitmap =
         imgDesmarcado.Bitmap then
      begin
        favorito := 1;
        TListItemImage(lvConsulta.items[ItemIndex].Objects.FindDrawable('Image5')).Bitmap
          := imgMarcado.Bitmap
      end
      else
      begin
        favorito := 0;
        TListItemImage(lvConsulta.items[ItemIndex].Objects.FindDrawable('Image5')).Bitmap
          := imgDesmarcado.Bitmap;
      end;

      dmPrincipal.MarcarFavorito('produto', 'cd_barras', barras, favorito);
      Exit;

    except on E: Exception do
      Log('Erro na lvConsultaItemClickEx : ', E.Message);
    end;
  end;

  retorno := barras;
  inherited;
end;

procedure TfrmCnsProduto.edtBuscaChangeTracking(Sender: TObject);
begin
  inherited;
  pCarregarProduto;
end;

procedure TfrmCnsProduto.FormCreate(Sender: TObject);
begin
  inherited;
  pCarregarProduto;
end;

procedure TfrmCnsProduto.pAlterarFavorito;
begin
  //Aqui fazer update produto para favoritar
end;

procedure TfrmCnsProduto.pAtualizarImgFavorito;
begin
  if imgFavorito.Tag = 0 then
  begin {DESMARCADO > MARCAR}
    imgFavorito.Bitmap := imgMarcado.Bitmap;
    imgFavorito.Tag := 1;
  end
  else
  begin {MARCADO > DESMARCAR}
    imgFavorito.Bitmap := imgDesmarcado.Bitmap;
    imgFavorito.Tag := 0;
  end;
end;

procedure TfrmCnsProduto.pAdicionarProdutoLista(const barras, nome: String; const aUnit,
  desconto: Currency; favorito: Integer);
var
  item: TListViewItem;
  txt: TListItemText;
  img: TListItemImage;
begin
  try
    item := lvConsulta.Items.Add;
    with item do
    begin
      {Barras}
      txt := TlistItemText(Objects.FindDrawable('Text1'));
      txt.Text := barras;
      txt.TagString := txt.Text;

      {Descrição}
      txt := TlistItemText(Objects.FindDrawable('Text2'));
      txt.Text := nome;
      txt.TagString := txt.Text;

      {Valor Desconto}
      txt := TlistItemText(Objects.FindDrawable('Text3'));
      txt.Text := FormatCurr('R$ 0.00', desconto);
      txt.TagString := txt.Text;

      {Preço Venda}
      txt := TlistItemText(Objects.FindDrawable('Text4'));
      txt.Text := FormatCurr('R$ 0.00', aUnit);
      txt.TagString := txt.Text;

      {Favorito}
      img := TListItemImage(Objects.FindDrawable('Image5'));
      img.TagString := favorito.ToString;
      case favorito of
        0: img.Bitmap := imgDesmarcado.Bitmap;
        1: img.Bitmap := imgMarcado.Bitmap;
      end;
    end;
  Except on E: Exception do
    Log('pAdicionarProdutoLista', E.Message);
  end;
end;

procedure TfrmCnsProduto.pCarregarProduto;
var
  SQL: String;
begin
  try
    try
      SQL := 'SELECT ' +
             '    PRODUTO.CD_PRODUTO, ' +
             '    PRODUTO.CD_BARRAS, ' +
             '    PRODUTO.DESCRICAO, ' +
             '    PRODUTO.PRECO, ' +
             '    PRODUTO.FAVORITO ' +
             'FROM ' +
             '    PRODUTO ' +
             'WHERE ' +
             '    PRODUTO.ATIVO = 1 ';

      if not edtBusca.Text.IsEmpty then {FILTRO NOME}
         SQL := SQL + ' AND UPPER(PRODUTO.DESCRICAO) LIKE ('+QuotedStr('%'+ edtBusca.Text +'%')+') ';

      if imgFavorito.Tag = 1 then {FILTRO FAVORITO}
        SQL := SQL + ' AND FAVORITO = 1 ';

      SQL := SQL + ' LIMIT 100 ';

      qryConsulta.Open(SQL);
      qryConsulta.First;
      lvConsulta.Items.Clear;
      while not qryConsulta.Eof do
      begin
        pAdicionarProdutoLista(qryConsulta.FieldByName('CD_BARRAS').AsString,
                               qryConsulta.FieldByName('DESCRICAO').AsString,
                               qryConsulta.FieldByName('PRECO').AsCurrency,
                               0,
                               qryConsulta.FieldByName('FAVORITO').AsInteger);
        qryConsulta.Next;
      end;
    finally
      qryConsulta.Close;
    end;
  except on E: Exception do
    Log('pCarregarProduto', E.Message);
  end;
end;

end.
