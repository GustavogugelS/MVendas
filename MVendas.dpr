program MVendas;

uses
  System.StartUpCopy,
  FMX.Forms,
  uFrmInicial in 'uFrmInicial.pas' {frmInicial},
  uFrmLogin in 'uFrmLogin.pas' {frmLogin},
  uFrmMenuPrincipal in 'uFrmMenuPrincipal.pas' {frmMenuPrincipal},
  uFrmVendas in 'uFrmVendas.pas' {frmVendas},
  uDmPrincipal in 'uDmPrincipal.pas' {dmPrincipal: TDataModule},
  uFrmEditor in 'uFrmEditor.pas' {frmEditor},
  uFrmMensagem in 'uFrmMensagem.pas' {frmMensagem},
  uConsultaBanco in 'uConsultaBanco.pas' {dados},
  G700Interface in 'Classes\G700Interface.pas',
  GEDIPrinter in 'Classes\GEDIPrinter.pas',
  uConfiguracao in 'Classes\uConfiguracao.pas',
  uFormat in 'Classes\uFormat.pas',
  uImpressao in 'Classes\uImpressao.pas',
  uUtilitarios in 'Classes\uUtilitarios.pas',
  UNFCeClass in 'Comum\UNFCeClass.pas',
  Androidapi.JNI.Toast in 'Classes\Androidapi.JNI.Toast.pas',
  uFrmCnsBase in 'uFrmCnsBase.pas' {frmCnsBase},
  uFrmCnsProduto in 'uFrmCnsProduto.pas' {frmCnsProduto},
  uFrmCnsNota in 'uFrmCnsNota.pas' {frmCnsNota},
  uFrmCnsCliente in 'uFrmCnsCliente.pas' {frmCnsCliente},
  uDmNfe in 'uDmNfe.pas' {dmNfe: TDataModule},
  uFrmEnviarReceber in 'uFrmEnviarReceber.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmPrincipal, dmPrincipal);
  Application.CreateForm(TfrmInicial, frmInicial);
  Application.CreateForm(TdmNfe, dmNfe);
  Application.Run;
end.
