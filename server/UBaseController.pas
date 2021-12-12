unit UBaseController;


interface

uses
  UNFCeWebModulle,
  MVCFramework,
  MVCFramework.Commons,
  UNFCeClass,
  System.DateUtils,
  System.SysUtils,
  System.IOUtils,
  System.Variants,
  System.Classes,
  System.math,
  IdCoderMIME,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.FBDef, FireDAC.Phys.FB,   MVCFramework.Logger;

type
  TBaseController = class(TMVCController)
  private
    function fBuscarMaxCodCliente: integer;
  protected
    FWebModule: TNFCEWebModule;
    FDConexao: TFDConnection;
    FDConexaoPostgreSQL : TFDConnection;

    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;

    function fGravarNfsc(Nota : TNFCe; const CNPJ: String) : string;
    function fCancelarNFSC (nrDocumento :Integer;StrXml :string) : boolean;
    function fCancelarNFSI (nrDocumento :Integer) : boolean;
    function fCancelarPGTO (nrDocumento :Integer) : boolean;
    function fFinalizaComandoSql(idComando: string) : boolean;

    function fTestarBanco(preco :string) :string;

    function fBuscarAdministradora (vNomeAdministradora : String) : integer;
    function fBuscarBandeira (vNomeBandeira: String; vIdAdministradora :integer) : integer;

    function fbuscaIdContagem(vNr_ECF:integer): integer;

    function fGravarVersao(vDispositivo, vCodigoVersao, vIdentificador: String) :boolean;
    function fBuscarNovoCodigoCliente: Integer;

    function fInserirContagemCabecalho(ecf, usuario: Integer; nm_deposito :string) :boolean;

    function fFinalizaContagem(ecf :Integer) :boolean;
    function fBuscarDadosEmpresa :TNFCeEmpresa;
    function fExisteNota(const IdDisp, Cancelado, Serie, nrNota: Integer; const Cnpj: String): String;
    function fGravarAutServer(const cnpj, iddispositivo, chavedanfe, xml_ori, xml_ret: String; const cancelamento, serie, nota: integer):String;
    function fBuscarXMLChaveDoc(const vChaveDoc :string; const vIdDispositivo :String): string;
    function base64Decode(const Text: String): String;
    function fRecebeuCarga(aDispositivo: String): Boolean;
    function fSalvarJsonOriginal(Dispositivo, chave_doc, texto: String; const cnpj: String) :Boolean;
    function fBuscarNumeracaoNota(vNRSERIE :integer) :integer;
    function fBuscarXML(const ANumero :integer; const ASerie: integer; const modelo :string) :string;
    function fDadosConsistentes(const vDocumento: Integer): Boolean;
    function fExisteRegistroBanco(const vTabela , vCampo,  vValor :string): boolean;
    function fGerarEstoqueDia: Boolean;
    function fExisteEstoqueDia: Boolean;
    procedure pApagarRegistrosCupom(const documento :integer);


  end;

implementation

   function EnviarDadosVenda(numeroSessao: Integer; codigoDeAtivacao: PAnsiChar; dadosVenda: PAnsiChar):PAnsiChar; stdcall; external 'dllsat.dll';
   function CancelarUltimaVenda(NumeroSessao:integer; CodAtivacao:PAnsiChar; Chave:PAnsiChar; DadosCancelamento:PAnsiChar):PAnsiChar; stdcall; external 'dllsat.dll';
   function ConsultarStatusOperacional(numeroSessao: integer; codigoDeAtivacao: PAnsiChar):PAnsiChar; stdcall; external 'dllsat.dll';



{ TBaseController }


function TBaseController.fExisteEstoqueDia: Boolean;
var
  qryAux: TFDQuery;
begin
  result := False;
  try
    qryAux := TFDQuery.Create(nil);
    qryAux.Connection := FDConexao;
    qryAux.Sql.Text := 'SELECT FIRST 1 ' +
                       '    CAST(DATAESTOQUE AS DATE) DTESTOQUE ' +
                       'FROM ' +
                       '    ESTOQUEDIA ' +
                       'WHERE ' +
                       '    DATAESTOQUE = ' + QuotedStr(FormatDateTime('dd.mm.yyyy', now));
    qryAux.Open;
    if not qryAux.IsEmpty then
      result := True;
  finally
    qryAux.Free;
  end;
end;

function TBaseController.fGerarEstoqueDia: Boolean;
var
  qryAux: TFDQuery;
  qryEstoque: TFDQuery;
  I: Integer;
begin
  result := False;
  I := 0;
  try
    try
//      if fExisteEstoqueDia then
//      begin
//        result := True;
//        exit;
//      end;

      qryAux := TFDQuery.Create(nil);
      qryAux.Connection := FDConexao;
      qryAux.FetchOptions.RowsetSize := 100000;

      qryEstoque := TFDQuery.Create(nil);
      qryEstoque.Connection := FDConexao;

      qryAux.Sql.Text := 'SELECT ' +
                         '    CD_PRODUTO, ' +
                         '    CD_BARRAS, ' +
                         '    NM_REDUZIDO, ' +
                         '    UN_MEDIDA, ' +
                         '    DT_ATZ, ' +
                         '    (CD_BARRAS || NM_REDUZIDO || UN_MEDIDA || CST_INT || PRECO_VENDA || cast(coalesce(QT_ESTOQUE, 0) as numeric(9,3)) ||COALESCE(CD_FISCAL, '''')||COALESCE(CEST_CODIGO, '''')) EAD, ' +
                         '    CST_INT, ' +
                         '    PRECO_VENDA, ' +
                         '    QT_ESTOQUE, ' +
                         '    CURRENT_DATE DATAESTOQUE, ' +
                         '    CURRENT_TIME HORAESTOQUE, ' +
                         '    SUBSTRING(CD_FISCAL FROM 1 FOR 8 ) CD_FISCAL, ' +
                         '    CEST_CODIGO ' +
                         'FROM ' +
                         '    PRODUTO P ' +
                         'WHERE ' +
                         '    P.FL_ATIVO = ''S'' ';
      qryAux.Open;

      qryEstoque.Sql.Text := 'UPDATE OR INSERT INTO ESTOQUEDIA (CD_PRODUTO, CD_BARRAS, NM_REDUZIDO, UN_MEDIDA, DT_ATZ, EAD, CST_INT, PRECO_VENDA, QT_ESTOQUE, DATAESTOQUE, HORAESTOQUE, CD_FISCAL, CEST_CODIGO) ' +
                             '    VALUES (:CD_PRODUTO, :CD_BARRAS, :NM_REDUZIDO, :UN_MEDIDA, :DT_ATZ, :EAD, :CST_INT, :PRECO_VENDA, :QT_ESTOQUE, :DATAESTOQUE, :HORAESTOQUE, :CD_FISCAL, :CEST_CODIGO) ' +
                             '    MATCHING (CD_PRODUTO); ';

      qryEstoque.Params.ArraySize := qryAux.RecordCount;
      qryAux.First;

      while not qryAux.Eof do
      begin
        qryEstoque.Params[0].AsStrings[i] := qryAux.FieldByName('CD_PRODUTO').AsString;
        qryEstoque.Params[1].AsStrings[i] := qryAux.FieldByName('CD_BARRAS').AsString;
        qryEstoque.Params[2].AsStrings[i] := qryAux.FieldByName('NM_REDUZIDO').AsString;
        qryEstoque.Params[3].AsStrings[i] := qryAux.FieldByName('UN_MEDIDA').AsString;
        qryEstoque.Params[4].AsDates[i] := qryAux.FieldByName('DT_ATZ').AsDateTime;
        qryEstoque.Params[5].AsStrings[i] := qryAux.FieldByName('EAD').AsString;
        qryEstoque.Params[6].AsStrings[i] := qryAux.FieldByName('CST_INT').AsString;
        qryEstoque.Params[7].AsCurrencys[i] := qryAux.FieldByName('PRECO_VENDA').AsCurrency;
        qryEstoque.Params[8].AsFloats[i] := qryAux.FieldByName('QT_ESTOQUE').AsFloat;
        qryEstoque.Params[9].AsDates[i] := qryAux.FieldByName('DATAESTOQUE').AsDateTime;
        qryEstoque.Params[10].AsTimes[i] := StrToTime(FormatDateTime('hh:mm:ss', qryAux.FieldByName('HORAESTOQUE').AsDateTime));
        qryEstoque.Params[11].AsStrings[i] := qryAux.FieldByName('CD_FISCAL').AsString;
        qryEstoque.Params[12].AsStrings[i] := qryAux.FieldByName('CEST_CODIGO').AsString;
        qryAux.Next;
        i := i + 1;
      end;
      qryEstoque.Execute(qryEstoque.Params.ArraySize);
      result := True;
    finally
      qryAux.Free;
      qryEstoque.Free;
    end;

  except on E:Exception do
    result := False;
  end;
end;

function TBaseController.fGravarNfsc(Nota: TNFCe; const CNPJ: String): string; // Grava XML, NFSC, CUPOM_PGTO, ,TEF_MOVIMENTACAO, CRPTITULO,NFSI e RESULTA O NR_DOCUMENTO DA NFSC GRAVADA
var
  qry :TFDQuery;
  vNrDocumento, vIdXml,vIdTEF : Integer;

//    function fGravarXML : integer;
//    var
//      qryGravaXml : TFDQuery;
//      idXML : integer;
//    begin
//      result := 0;
//      //gravar o xml na tabela e pega o id do xml
//      //se gravou com sucesso resulta o id xml;
//      try
//        qryGravaXml := TFDQuery.Create(nil);
//        qryGravaXml.Connection := FDConexao;
//        qryGravaXml.Active := false;
//        qryGravaXml.SQL.Clear;
//        qryGravaXml.SQL.text := 'SELECT FIRST 1 GEN_ID(GEN_XML_ID,1) as ID FROM FILIAL';
//        qryGravaXml.Active := true;
//        if not qryGravaXml.IsEmpty then
//        begin
//          idXml  := qryGravaXml.FieldByName('ID').AsInteger;
//          if idXML > 0 then
//          begin
//            qryGravaXml.Active := false;
//            qryGravaXml.SQL.Clear;
//            qryGravaXml.SQL.text := ' INSERT INTO XML (ID, XML, XML_OFFLINE, XML_ORIGINAL, autChave_ORIGINAL) ' +
//                                    ' VALUES  (:ID, :XML, :XML_OFFLINE, :XML_ORIGINAL, :autChave_ORIGINAL) ';
//            qryGravaXml.ParamByName('ID').AsInteger                   := idXML;
//            qryGravaXml.ParamByName('XML').AsBlob                     := nota.Xml;
//            qryGravaXml.ParamByName('XML_OFFLINE').AsBlob             := nota.Xml;
//            qryGravaXml.ParamByName('XML_ORIGINAL').AsBlob            := nota.Xml;
//            qryGravaXml.ParamByName('autChave_ORIGINAL').AsString  := nota.autChave;
//            qryGravaXml.ExecSQL;
//            result := idXML;
//          end;
//        end;
//
//      finally
//        qryGravaXml.Free
//      end;
//    end;
//    function fBuscarNrDocumento: integer;
//     var
//      qryBuscarDocumento : TFDQuery;
//    begin
//      result := 0;
//      //gravar o xml na tabela e pega o id do xml
//      //se gravou com sucesso resulta o id xml;
//      try
//        qryBuscarDocumento := TFDQuery.Create(nil);
//        qryBuscarDocumento.Connection := FDConexao;
//        qryBuscarDocumento.Active := false;
//        qryBuscarDocumento.SQL.Clear;
//        qryBuscarDocumento.SQL.text := ' SELECT FIRST 1 GEN_ID(GEN_NR_DOCUMENTO_NFSC,1) AS ID FROM FILIAL ';
//        qryBuscarDocumento.Active := true;
//        if not qryBuscarDocumento.IsEmpty then
//          result := qryBuscarDocumento.FieldByName('ID').AsInteger;
//      finally
//        qryBuscarDocumento.Free
//      end;
//    end;

//  procedure pUpdateXml;
//  var
//    qryUpdate: TFDQuery;
//  begin
//    try
//      qryUpdate := tfdQuery.create(nil);
//      qryUpdate.Connection := FDConexao;
//      qryUpdate.Active := false;
//      qryUpdate.SQL.Clear;
//      qryUpdate.SQL.text :=
//        ' UPDATE ' +
//        '   XML ' +
//        ' SET ' +
//        '   autChave_ORIGINAL = :autChave_ORIGINAL, ' +
//        '   XML_ORIGINAL = :XML, ' +
//        '   XML_OFFLINE  = :XML, ' +
//        '   XML  = :XML  ' +
//        ' WHERE ' +
//        '   ID = :ID';
//      qryUpdate.ParamByName('ID').AsInteger := NOTA.idXml;
//      qryUpdate.ParamByName('XML').AsBlob := NOTA.Xml;
//      qryUpdate.ParamByName('autChave_ORIGINAL').AsString := nota.autChave;
//      qryUpdate.ExecSQL;
//    finally
//      qryUpdate.Free;
//    end;
//  end;
//
//  procedure pVerificarNotaAutorizada;
//  var
//    qryAux: TFDQuery;
//  begin
//    try
//      FWebModule.ConnSQLite.Connected := True;
//      qryAux := TFDQuery.create(nil);
//      qryAux.connection := FWebModule.ConnSQLite;
//      qryAux.Active := false;
//      qryAux.sql.Text := 'SELECT ' + '    CHAVEDANFE, ' + '    XML_RETORNO ' + ' FROM  ' + '    DOCUMENTOS ' + ' WHERE ' + '    DISPOSITIVO = :DISPOSITIVO ' + ' AND ' + '    CHAVEDOC = :CHAVEDOC';
//      try
//        qryAux.ParamByName('DISPOSITIVO').AsString := nota.idDispositivo;
//        qryAux.ParamByName('CHAVEDOC').AsString := nota.autChave;
//        qryAux.Active := true;
//        qryAux.First;
//        if Length(qryAux.fieldbyname('CHAVEDANFE').AsString) > 0 then
//        begin
//          nota.autSituacao := 100;
//          nota.autChave   := qryAux.FieldByName('CHAVEDANFE').AsString;
//          NOTA.Xml           := qryAux.FieldByName('XML_RETORNO').AsString;
//          pUpdateXml;
//        end;
//      except
//        on E: Exception do
//        begin
//          raise Exception.Create(e.Message);
//        end;
//      end;
//      //exit;
//    finally
//      qryAux.Active := False;
//      qryAux.Free;
//      FWebModule.ConnSQLite.Connected := False;
//    end;
//  end;

//  function fGravarCabecalho : boolean;
//  var
//    qryNFSC : TFdQuery;
//    idContagem : integer;
//  begin
//    try
//      result:= false;
//      qryNFSC := TFDQuery.Create(nil);
//      qryNFSC.Connection := FDConexao;
//      qryNFSC.Active := false;
//      qryNFSC.SQL.Clear;
//      qryNFSC.SQL.text :=
//  //
//        '  INSERT INTO NFSC (ID_XML, CD_FILIAL, NR_DOCUMENTO, CD_MODELO, NR_NF, NR_SERIE, NR_CUPOM, CD_ECF, NR_ECF, NR_CCF, STATUS, STATUS_EDICAO, SITUACAO_NF, CD_CANCELAMENTO,  '+
//        '  DT_EDICAO, DT_EMISSAO, DT_ATZ, CD_OPERACAO, CD_NATOPER, CD_CLIFOR, NM_CLIFOR, CPF_CNPJ, CPF_CNPJ_CUPOM, CD_USUARIO, CD_ESTACAO,  '+
//        '  VL_DESCONTOS, VL_MERCADORIAS, VL_SERVICOS, VL_TOTAL, CD_CONDPGTO, '+
//        '  PESO_TOTAL, OBS, DT_LANCAMENTO, DT_SAIDA, UF_ORIGEM, UF_DESTINO, PESO_LIQUIDO, VL_FRETE, VL_SEGURO, VL_BASE_ICM, VL_ICM, VL_BASE_ICM_SUBST,   '+
//        '  VL_ICM_SUBST, VL_IPI, VL_ISS, QT_VOLUMES, '+
//        '  VL_SIMPLES_NACIONAL, HR_EMISSAO, NR_PROTOCOLO_NFE, DT_PROCESSAMENTO_NFE, NR_LOTE_NFE, NR_RECIBO_NFE, NR_PROTOCOLO_CAN_NFE, autChave, VL_BASE_PIS,   '+
//        '  VL_PIS, VL_BASE_COFINS, VL_COFINS, EAD, HR_PROCESSAMENTO_NFE, SITUACAO_NFCE, EAD_UNICODE, FL_INTEGRADO, FL_INTEGRADO_CANCELAMENTO, FL_OBSERVACAO, FL_CONTINGENCIA_NFCE, '+
//        '  VL_REDUCAO, FL_INTEGRADO_CONTING, FL_FECHADO_REDUCAO, QTITENS, FL_CONSUMIDOR_FINAL, FL_CLIENTE_CONTRIBUINTE, VFCPUFDEST, VICMSUFDEST, VICMSUFREMET,   '+
//        '  NR_EXTRATOCFE, SEQ_CUPOM, EAD_J1, FL_SINCRET_EMISSAO, FL_SINCRET_CANCELAMENTO, NR_DOCUMENTORETAGUARDA, FL_IGNORAR_CXA_CTA,CD_TRANSPORTADORA, ID_DEPOSITO, TIPO_DCTO, ID_COMANDA)    '+
//        '  VALUES  (:ID_XML, :CD_FILIAL, :NR_DOCUMENTO, :CD_MODELO, :NR_NF, :NR_SERIE, :NR_CUPOM, :CD_ECF, :NR_ECF, :NR_CCF, :STATUS, :STATUS_EDICAO, :SITUACAO_NF, :CD_CANCELAMENTO, :DT_EDICAO, :DT_EMISSAO,   '+
//        '  :DT_ATZ, :CD_OPERACAO, :CD_NATOPER, :CD_CLIFOR, :NM_CLIFOR, :CPF_CNPJ, :CPF_CNPJ_CUPOM, :CD_USUARIO, :CD_ESTACAO,   '+
//        '  :VL_DESCONTOS, :VL_MERCADORIAS, :VL_SERVICOS, :VL_TOTAL, :CD_CONDPGTO, :PESO_TOTAL, :OBS, :DT_LANCAMENTO, :DT_SAIDA,  '+
//        '  :UF_ORIGEM, :UF_DESTINO, :PESO_LIQUIDO, :VL_FRETE, :VL_SEGURO, :VL_BASE_ICM, :VL_ICM, :VL_BASE_ICM_SUBST, :VL_ICM_SUBST, :VL_IPI, :VL_ISS, :QT_VOLUMES, '+
//        '  :VL_SIMPLES_NACIONAL, :HR_EMISSAO, :NR_PROTOCOLO_NFE, :DT_PROCESSAMENTO_NFE, :NR_LOTE_NFE,   '+
//        '  :NR_RECIBO_NFE, :NR_PROTOCOLO_CAN_NFE, :autChave, :VL_BASE_PIS, :VL_PIS, :VL_BASE_COFINS, :VL_COFINS, :EAD, :HR_PROCESSAMENTO_NFE, '+
//        '  :SITUACAO_NFCE, :EAD_UNICODE, :FL_INTEGRADO, :FL_INTEGRADO_CANCELAMENTO, :FL_OBSERVACAO,  '+
//        '  :FL_CONTINGENCIA_NFCE, :VL_REDUCAO, :FL_INTEGRADO_CONTING, :FL_FECHADO_REDUCAO, :QTITENS, :FL_CONSUMIDOR_FINAL, :FL_CLIENTE_CONTRIBUINTE, :VFCPUFDEST,   '+
//        '  :VICMSUFDEST, :VICMSUFREMET, :NR_EXTRATOCFE, :SEQ_CUPOM, :EAD_J1, :FL_SINCRET_EMISSAO, :FL_SINCRET_CANCELAMENTO, :NR_DOCUMENTORETAGUARDA, :FL_IGNORAR_CXA_CTA,:CD_TRANSPORTADORA, :ID_DEPOSITO, :TIPO_DCTO, :ID_COMANDA ) ';
//
//      Nota.idXml := vIdXml;
//      qryNFSC.ParamByName('ID_XML').AsInteger	                    := vIdXml;
//      qryNFSC.ParamByName('CD_FILIAL').AsInteger	                := 1;
//      qryNFSC.ParamByName('NR_DOCUMENTO').AsInteger	              := vNrDocumento;
//      qryNFSC.ParamByName('CD_MODELO').AsString	                  := nota.modelo;
//      if nota.modelo = 65  then
//        qryNFSC.ParamByName('NR_NF').AsInteger                    := Nota.nrNota;
//      qryNFSC.ParamByName('NR_SERIE').AsInteger	                  := Nota.nrSerie;
//      qryNFSC.ParamByName('STATUS').AsInteger	                    := Nota.status;
//
//      if nota.autSituacao = 0 then
//        nota.autSituacao := -1;
//
//      qryNFSC.ParamByName('SITUACAO_NFCE').AsInteger	            := nota.autSituacao;
//      qryNFSC.ParamByName('autChave').AsString	                := Nota.autChave;
//
//      if (Nota.modelo = 65) then
//      begin
//        pVerificarNotaAutorizada;
//        qryNFSC.ParamByName('STATUS').AsInteger := 2;
//      end;
//
//      qryNFSC.ParamByName('SITUACAO_NF').AsString	                := Nota.autSituacao;
//      qryNFSC.ParamByName('CD_CANCELAMENTO').AsInteger	          := Nota.cancelado;
//      qryNFSC.ParamByName('DT_EMISSAO').AsDateTime                := strToDate(Nota.dtEmissao);
//      qryNFSC.ParamByName('CD_OPERACAO').AsInteger	              := Nota.cdOperacao;
//      qryNFSC.ParamByName('CD_NATOPER').AsString	                :='1';
//      qryNFSC.ParamByName('CD_CLIFOR').AsInteger	                := Nota.cdCliente;
//      qryNFSC.ParamByName('NM_CLIFOR').AsString	                  := Nota.nmCliente;
//      qryNFSC.ParamByName('CPF_CNPJ').AsString	                  := Nota.cpf;
//      qryNFSC.ParamByName('CD_USUARIO').AsInteger	                := Nota.cdUsuario;
//      qryNFSC.ParamByName('VL_DESCONTOS').AsFloat	                := Nota.vlDescontos;
//      qryNFSC.ParamByName('VL_MERCADORIAS').AsFloat	              := Nota.vlMercadoria;
//      qryNFSC.ParamByName('VL_TOTAL').AsFloat	                    := Nota.vlTotal;
//      qryNFSC.ParamByName('OBS').AsString	                        := Nota.obs;
//      qryNFSC.ParamByName('DT_LANCAMENTO').AsDateTime             := strToDate(Nota.dtEmissao);
//      qryNFSC.ParamByName('DT_SAIDA').AsDateTime                  := strToDate(Nota.dtEmissao);
//      qryNFSC.ParamByName('UF_ORIGEM').AsString	                  := Nota.ufOrigem;
//      qryNFSC.ParamByName('UF_DESTINO').AsString	                := Nota.ufDestino;
//
//      qryNFSC.ParamByName('VL_BASE_ICM').AsFloat	                := Nota.vlBcIcms;
//      qryNFSC.ParamByName('VL_ICM').AsFloat	                      := Nota.vlIcms;
//      qryNFSC.ParamByName('HR_EMISSAO').AsDateTime                := now;
//      qryNFSC.ParamByName('NR_PROTOCOLO_NFE').AsString	          := Nota.autProtocolo;
//      qryNFSC.ParamByName('DT_PROCESSAMENTO_NFE').AsDateTime      := strToDate(Nota.dtEmissao);
//      qryNFSC.ParamByName('NR_LOTE_NFE').AsString	                := Nota.autLote;
//      qryNFSC.ParamByName('NR_RECIBO_NFE').AsString	              := Nota.autRecibo;
//      qryNFSC.ParamByName('NR_PROTOCOLO_CAN_NFE').AsString	      := Nota.autProtocoloCancel;
//      qryNFSC.ParamByName('VL_BASE_PIS').AsFloat	                := Nota.vlBcPis;
//      qryNFSC.ParamByName('VL_PIS').AsFloat	                      := Nota.vlPis;
//      qryNFSC.ParamByName('VL_BASE_COFINS').AsFloat	              := Nota.vlBcCofins;
//      qryNFSC.ParamByName('VL_COFINS').AsFloat	                  := Nota.vlCofins;
//      qryNFSC.ParamByName('HR_PROCESSAMENTO_NFE').AsDatetime	    := now;
//
//      qryNFSC.ParamByName('QTITENS').AsInteger	                  := Nota.qtItens;
//      qryNFSC.ParamByName('FL_CONSUMIDOR_FINAL').AsInteger	      := 1;
//      qryNFSC.ParamByName('FL_SINCRET_EMISSAO').AsInteger	        := Nota.sincEmissao;
//      qryNFSC.ParamByName('FL_SINCRET_CANCELAMENTO').AsInteger	  := Nota.sincCancel;
//      qryNFSC.ParamByName('NR_DOCUMENTORETAGUARDA').AsInteger	    := Nota.documentoServidor;
//      qryNFSC.ExecSQL;
//      result := true;
//    except on E:Exception do
//         begin
//               raise Exception.Create('Erro ao INSERIR A NFSC ' + E.Message);
//               exit;
//          end;
//    end;
//
//  end;

//  Function fGravarTEF(vIDTEFMOBILE : integer) :boolean;
//  var
//    qryGravaTEF : TFDQuery;
//    NFCeTEF: TNFCeTEF;
//    idTEF, I, cdBandeira, cdAdministradora : integer;
//    TemErro : boolean;
//    temp :String;
//    Buffer : TStringList;
//  begin
//    TemErro := false;
//    result :=true;
//    Buffer := TStringList.Create;
//    if Nota.TransacoesTEF.Count > 0 then
//    begin
//      result := false;
//      try
//        qryGravaTEF := TFDQuery.Create(nil);
//        qryGravaTEF.Connection := FDConexao;
//        qryGravaTEF.Active := false;
//        qryGravaTEF.SQL.Clear;
//        qryGravaTEF.SQL.text := 'SELECT FIRST 1 GEN_ID (GEN_TEF_MOVIMENTACAO_ID,1) as ID FROM FILIAL';
//        qryGravaTEF.Active := true;
//
//        if not qryGravaTEF.IsEmpty then
//        begin
//          idTEF  := qryGravaTEF.FieldByName('ID').AsInteger;
//          if idTEF > 0 then
//          begin
//            qryGravaTEF.Active := false;
//            qryGravaTEF.SQL.Clear;
//            qryGravaTEF.SQL.text := ' INSERT INTO TEF_MOVIMENTACAO (ID,CD_BANDEIRA,VL_TOTAL,DT_LANCAMENTO,NR_DOCUMENTO,TP_OPERACAO,NR_TRANSACAO,VL_TROCO,EAD_UNICODE,CD_ADMINISTRADORA,EAD, OBS) ' +
//                                    ' VALUES  (:ID, :CD_BANDEIRA, :VL_TOTAL, :DT_LANCAMENTO, :NR_DOCUMENTO, :TP_OPERACAO, :NR_TRANSACAO, :VL_TROCO, :EAD_UNICODE, :CD_ADMINISTRADORA, :EAD, :OBS) ';
//            qryGravaTEF.Params.ArraySize := Nota.TransacoesTEF.Count;
//            I := 0;
//            for NFCeTEF in Nota.TransacoesTEF do
//            begin
//
//               if vIDTEFMOBILE = NFCeTEF.Id then
//               begin
//
//                cdBandeira       := 1;
//                cdAdministradora := 1;
//                if NFCeTEF.bandeira = '' then
//                begin
//                   Buffer.Text:= NFCeTEF.Obs;
//                   NFCeTEF.bandeira := Trim(Buffer.Strings[2]);
//                   NFCeTEF.Tp_operacao := Copy(Buffer.Strings[7],Pos('VENDA A ',Buffer.Strings[7])+8,Length(Buffer.Strings[7]));
//                end;
//
//
//
//                cdAdministradora := fBuscarAdministradora(NFCeTEF.administrador);
//                cdbandeira       := fBuscarBandeira( NFCeTEF.bandeira,cdAdministradora);
//                try
//                  qryGravaTEF.ParamByName('ID').asINTEGERs[I]                 := idTEF;
//                  qryGravaTEF.ParamByName('CD_BANDEIRA').AsIntegers[I]        := cdbandeira;
//                  qryGravaTEF.ParamByName('VL_TOTAL').asCURRENCYs[I]          := NFCeTEF.VL_TOTAL;
//                  qryGravaTEF.ParamByName('DT_LANCAMENTO').asDATETimes[I]     := StrToDate(Nota.dtEmissao);
//                  qryGravaTEF.ParamByName('NR_DOCUMENTO').asINTEGERs[I]       := vNrDocumento;
//                  qryGravaTEF.ParamByName('TP_OPERACAO').asSTRINGs[I]         := NFCeTEF.TP_OPERACAO;
//                  qryGravaTEF.ParamByName('NR_TRANSACAO').asSTRINGs[I]        := NFCeTEF.NR_TRANSACAO;
//                  qryGravaTEF.ParamByName('VL_TROCO').asCURRENCYs[I]          := NFCeTEF.VL_TROCO;
//                  qryGravaTEF.ParamByName('EAD_UNICODE').asSTRINGs[I]         := NFCeTEF.EAD_UNICODE;
//                  qryGravaTEF.ParamByName('CD_ADMINISTRADORA').AsIntegers[I]  := cdAdministradora;
//                  qryGravaTEF.ParamByName('EAD').AsStrings[I]                 := NFCeTEF.EAD;
//                  qryGravaTEF.ParamByName('OBS').AsStrings[I]                 := NFCeTEF.Obs;
//                except on E:Exception do
//                  TemErro := true;
//                end;
//               end;
//              inc(I);
//            end;
//            vIdTEF := idTEF;
//            if not TemErro then
//            begin
//              try
//                qryGravaTEF.Execute(qryGravaTEF.Params.ArraySize);
//              except on E:Exception do
//                begin
//                  TemErro := true;
//                  temp := e.Message;
//                end;
//              end;
//
//            end;
//          end;
//        end;
//      finally
//        qryGravaTEF.Free;
////          NFCeTEF.Free; é destruido junto com o destroy da classe principal.
//      if not TemErro then
//        result := true;
//      end;//fim try
//    end;//fim do if tem tefMovimentacao
//  end;

//  Function fGravarTitulos:Boolean;
//  var
//    qryTitulo : TFdQuery;
//    NFCeTitulo: TNFCeTitulo;
//    i :Integer;
//    temErro: boolean;
//  begin
//    result := true;
//    temErro := false;
//    try
//      qryTitulo := TFDQuery.Create(nil);
//      qryTitulo.Connection := FDConexao;
//
//      if Nota.Titulos.Count > 0 then
//      begin
//        result:= false;
//        try
//          qryTitulo.Active := false;
//          qryTitulo.SQL.Clear;
//          qryTitulo.SQL.text :=
//              ' INSERT INTO CRPTITULO   '+
//              '		(CD_FILIAL,CD_TIPO_CONTA,CD_CLIFOR,NR_TITULO,PARCELA,DT_EMISSAO,DT_INCLUSAO,DT_VCTO_ORI,DT_VCTO,DT_ULT_PGTO,CD_BANCO_ORI,CD_BANCO,CD_TIPOCOBR_ORI,CD_TIPOCOBR,CD_VENDEDOR, ' + sLineBreak +
//              '    FL_PREV_REALIZADO,VL_COMISSAO,VL_NOMINAL,VL_JUROS,VL_BAIXAS_NOMINAL,VL_DESCONTOS,VL_SALDO,CD_CAIXA,DT_ATZ,NR_NF_ECF,PRAZO_PARCELA,PC_PARCELA,CD_CONTA,VL_ACRESCIMO,FL_REPARCELADO, ' +sLineBreak +
//              '    PC_PARCELA_TOTAL,NR_DOCUMENTO,OBS,NR_SEQUENCIAL,CUPOM_TIPO,FL_EXCLUIDO,MOTIVO_EXCLUSAO,SEQUENCIA_ID,CD_CONVENIO,EMISSAO,CD_FUNCIONARIOEXCLUSAO,DT_EXCLUSAO,ID_SINCRONIZADO,ID_CODIGO_MATRIZ,NR_CUPOM)  '+ sLineBreak +
//              ' VALUES   '+ sLineBreak +
//              ' (:CD_FILIAL,  :CD_TIPO_CONTA,  :CD_CLIFOR,  :NR_TITULO,  :PARCELA,  :DT_EMISSAO,  :DT_INCLUSAO,  :DT_VCTO_ORI,  :DT_VCTO,  :DT_ULT_PGTO,  :CD_BANCO_ORI,  :CD_BANCO,  :CD_TIPOCOBR_ORI,  :CD_TIPOCOBR,  :CD_VENDEDOR, '+sLineBreak+
//              '  :FL_PREV_REALIZADO,  :VL_COMISSAO,  :VL_NOMINAL,  :VL_JUROS,  :VL_BAIXAS_NOMINAL,  :VL_DESCONTOS,  :VL_SALDO,  :CD_CAIXA,  :DT_ATZ,  :NR_NF_ECF,  :PRAZO_PARCELA,  :PC_PARCELA,  :CD_CONTA,  :VL_ACRESCIMO,  :FL_REPARCELADO, '+sLineBreak+
//              '  :PC_PARCELA_TOTAL,  :NR_DOCUMENTO,  :OBS,  :NR_SEQUENCIAL,  :CUPOM_TIPO,  :FL_EXCLUIDO,  :MOTIVO_EXCLUSAO,  :SEQUENCIA_ID,  :CD_CONVENIO,  :EMISSAO,  :CD_FUNCIONARIOEXCLUSAO,  :DT_EXCLUSAO,  :ID_SINCRONIZADO,  :ID_CODIGO_MATRIZ,  :NR_CUPOM)	';
//
//          qryTitulo.Params.ArraySize := Nota.Titulos.Count;
//          I := 0;
//          for NFCeTitulo in Nota.Titulos do
//          begin
//            if NFCeTitulo.Cd_filial = 1 then
//            begin
//              qryTitulo.Params[0].AsINTEGERs[i]        :=  NFCeTitulo.Cd_filial;
//              qryTitulo.Params[1].AsINTEGERs[i]        :=  NFCeTitulo.Cd_tipo_conta;
//              qryTitulo.Params[2].AsINTEGERs[i]        :=  NFCeTitulo.Cd_clifor;
//              qryTitulo.Params[3].AsStrings[i]         :=  NFCeTitulo.Nr_titulo;
////              qryTitulo.Params[4].AsINTEGERs[i]        :=  NFCeTitulo.Parcela;
//              qryTitulo.Params[4].AsINTEGERs[i]        :=  I + 1;
//              qryTitulo.Params[5].AsDateTimes[i]       :=  strToDate(Nota.dtEmissao);
//              qryTitulo.Params[6].AsDateTimes[i]       :=  strToDate(Nota.dtEmissao);
//              qryTitulo.Params[7].AsDateTimes[i]       :=  strToDate(Nota.dtEmissao);
//              qryTitulo.Params[8].AsDateTimes[i]       :=  IncDay(strToDate(Nota.dtEmissao),30);
//    //          qryTitulo.Params[9].AsDateTime[i]         :=  NFCeTitulo.Dt_ult_pgto;
//              qryTitulo.Params[10].AsINTEGERs[i]       :=  NFCeTitulo.Cd_banco_ori;
//              qryTitulo.Params[11].AsINTEGERs[i]       :=  NFCeTitulo.Cd_banco;
//              qryTitulo.Params[12].AsINTEGERs[i]       :=  NFCeTitulo.Cd_tipocobr_ori;
//              qryTitulo.Params[13].AsINTEGERs[i]       :=  NFCeTitulo.Cd_tipocobr;
//              qryTitulo.Params[14].AsINTEGERs[i]       :=  NFCeTitulo.Cd_vendedor;
//              qryTitulo.Params[15].AsSTRINGs[i]        :=  NFCeTitulo.Fl_prev_realizado;
//              qryTitulo.Params[16].AsCURRENCYs[i]      :=  NFCeTitulo.Vl_comissao;
//              qryTitulo.Params[17].AsCURRENCYs[i]      :=  NFCeTitulo.Vl_nominal;
//              qryTitulo.Params[18].AsCURRENCYs[i]      :=  NFCeTitulo.Vl_juros;
//              qryTitulo.Params[19].AsCURRENCYs[i]      :=  NFCeTitulo.Vl_baixas_nominal;
//              qryTitulo.Params[20].AsCURRENCYs[i]      :=  NFCeTitulo.Vl_descontos;
//              qryTitulo.Params[21].AsCURRENCYs[i]      :=  NFCeTitulo.Vl_saldo;
//              qryTitulo.Params[22].AsINTEGERs[i]       :=  NFCeTitulo.Cd_caixa;
//              qryTitulo.Params[23].AsDateTimes[i]      :=  strToDate(Nota.dtEmissao);
//              qryTitulo.Params[24].AsINTEGERs[i]       :=  NFCeTitulo.Nr_nf_ecf;
//              qryTitulo.Params[25].AsINTEGERs[i]       :=  NFCeTitulo.Prazo_parcela;
//              qryTitulo.Params[26].AsCURRENCYs[i]      :=  NFCeTitulo.Pc_parcela;
//              qryTitulo.Params[27].AsINTEGERs[i]       :=  NFCeTitulo.Cd_conta;
//              qryTitulo.Params[28].AsCURRENCYs[i]      :=  NFCeTitulo.Vl_acrescimo;
//              qryTitulo.Params[29].AsSTRINGs[i]        :=  NFCeTitulo.Fl_reparcelado;
//              qryTitulo.Params[30].AsCURRENCYs[i]      :=  NFCeTitulo.Pc_parcela_total;
//              qryTitulo.Params[31].AsINTEGERs[i]       :=  vNrDocumento;
//              qryTitulo.Params[32].AsSTRINGs[i]        :=  NFCeTitulo.Obs;
//    //          qryTitulo.Params[33].AsINTEGERs[i]       :=  NFCeTitulo.Nr_sequencial;
//    //          qryTitulo.Params[34].AsSTRINGs[i]        :=  NFCeTitulo.Cupom_tipo;
//              qryTitulo.Params[35].AsSTRINGs[i]        :=  NFCeTitulo.Fl_excluido;
//    //          qryTitulo.Params[36].AsSTRINGs[i]        :=  NFCeTitulo.Motivo_exclusao;
//    //          qryTitulo.Params[37].AsINTEGERs[i]       :=  NFCeTitulo.Sequencia_id;
//    //          qryTitulo.Params[38].AsINTEGERs[i]       :=  NFCeTitulo.Cd_convenio;
//              qryTitulo.Params[39].AsDateTimes[i]        :=  strToDate(Nota.dtEmissao);
//    //          qryTitulo.Params[40].AsINTEGERs[i]       :=  NFCeTitulo.Cd_funcionarioexclusao;
//    //          qryTitulo.Params[41].AsStrings[i]        :=  NFCeTitulo.Dt_exclusao;
//              qryTitulo.Params[42].AsINTEGERs[i]       :=  NFCeTitulo.Id_sincronizado;
//    //          qryTitulo.Params[43].AsINTEGERs[i]       :=  NFCeTitulo.Id_codigo_matriz;
//              qryTitulo.Params[44].AsINTEGERs[i]       :=  NFCeTitulo.Nr_cupom;
//            end;
//
//            Inc(I);
//          end;
//          qryTitulo.Execute(qryTitulo.Params.ArraySize);
//
//        except on E:Exception do
//             begin
//                   raise Exception.Create('Erro ao INSERIR A CRPTITULO' + E.Message);
//                   TemErro :=true;
//              end;
//        end;
//      end;
//    finally
//      qryTitulo.Free;
//      if not temErro then
//        result := true
//      else
//        result := false;
//    end;
//  end;

//  function fBuscarTipoFinalizadora (vCd_finalizadora : integer): string;
//  var
//    qryTipoFinalizadora :TFDQuery;
//  begin
//    try
//      qryTipoFinalizadora := TFDQuery.Create(nil);
//      qryTipoFinalizadora.Connection := FDConexao;
//      qryTipoFinalizadora.Active := false;
//      qryTipoFinalizadora.SQL.Clear;
//      qryTipoFinalizadora.SQL.text :=
//        ' SELECT '+
//        '   TP_FINALIZADORA '+
//        ' FROM '+
//        '   FINALIZADORAS '+
//        ' WHERE '+
//        '   FINALIZADORAS.CD_FINALIZADORA = :CD_FINALIZADORA';
//      qryTipoFinalizadora.ParamByName('CD_FINALIZADORA').AsInteger := vCd_finalizadora;
//      qryTipoFinalizadora.active := true;
//      if not qryTipoFinalizadora.eof then
//        result := qryTipoFinalizadora.FieldByName('TP_FINALIZADORA').asString;
//    finally
//      qryTipoFinalizadora.Free;
//    end;
//  end;

//  function fBuscarCodigoPagNFCE(vCd_finalizadora : integer): string;
//  var
//    qryTipoFinalizadora :TFDQuery;
//  begin
//    try
//      qryTipoFinalizadora := TFDQuery.Create(nil);
//      qryTipoFinalizadora.Connection := FDConexao;
//      qryTipoFinalizadora.Active := false;
//      qryTipoFinalizadora.SQL.Clear;
//      qryTipoFinalizadora.SQL.text :=
//        ' SELECT '+
//        '   CODIGO_PAG_NFCE '+
//        ' FROM '+
//        '   FINALIZADORAS '+
//        ' WHERE '+
//        '   FINALIZADORAS.CD_FINALIZADORA = :CD_FINALIZADORA';
//      qryTipoFinalizadora.ParamByName('CD_FINALIZADORA').AsInteger := vCd_finalizadora;
//      qryTipoFinalizadora.active := true;
//      if not qryTipoFinalizadora.eof then
//        result := qryTipoFinalizadora.FieldByName('CODIGO_PAG_NFCE').asString;
//    finally
//      qryTipoFinalizadora.Free;
//    end;
//  end;

//  function fBuscarNomeFinalizadora (vCd_finalizadora : integer): string;
//  var
//    qryTipoFinalizadora :TFDQuery;
//  begin
//    try
//      qryTipoFinalizadora := TFDQuery.Create(nil);
//      qryTipoFinalizadora.Connection := FDConexao;
//      qryTipoFinalizadora.Active := false;
//      qryTipoFinalizadora.SQL.Clear;
//      qryTipoFinalizadora.SQL.text :=
//        ' SELECT '+
//        '   NM_FINALIZADORA '+
//        ' FROM '+
//        '   FINALIZADORAS '+
//        ' WHERE '+
//        '   FINALIZADORAS.CD_FINALIZADORA = :CD_FINALIZADORA';
//
//      qryTipoFinalizadora.ParamByName('CD_FINALIZADORA').AsInteger := vCd_finalizadora;
//      qryTipoFinalizadora.active := true;
//      if not qryTipoFinalizadora.eof then
//        result := qryTipoFinalizadora.FieldByName('NM_FINALIZADORA').asString;
//    finally
//      qryTipoFinalizadora.Free;
//    end;
//  end;

//  Function fGravarPagamento :Boolean;
//  var
//    qryCupomPgto : TFdQuery;
//    NFCePgto: TNFCePagto;
//    i :Integer;
//  begin
//    result := false;
//    try
//      qryCupomPgto := TFDQuery.Create(nil);
//      qryCupomPgto.Connection := FDConexao;
//      qryCupomPgto.Active := false;
//      qryCupomPgto.SQL.Clear;
//      qryCupomPgto.SQL.text :=
//
//
//
//          ' INSERT INTO CUPOM_PGTO   '+
//          '		(CD_FILIAL,NR_COO,NR_ECF,NR_SEQ,DT_MOVIMENTO,CD_FINALIZADORA,VL_FINALIZADORA,NM_FINALIZADORA,TIPO,CD_ECF,NR_CCF,NR_GNF,FL_CANCELADA,EAD,NR_DCTO,TP_DOC,CD_MODELO,  '+
//          '		SERIE_NF,EAD_UNICODE,PGT_CODIGO,TROCO_CARTAO,TROCO_DINHEIRO,NR_TRANSACAO,CODIGO_PAG_NFCE)  '+
//          ' VALUES   '+
//          '		(:CD_FILIAL, :NR_COO, :NR_ECF, :NR_SEQ, :DT_MOVIMENTO, :CD_FINALIZADORA, :VL_FINALIZADORA, :NM_FINALIZADORA, :TIPO, :CD_ECF, :NR_CCF, :NR_GNF,  '+
//          '		  :FL_CANCELADA, :EAD, :NR_DCTO, :TP_DOC, :CD_MODELO, :SERIE_NF, :EAD_UNICODE, :PGT_CODIGO, :TROCO_CARTAO, :TROCO_DINHEIRO, :NR_TRANSACAO, :CODIGO_PAG_NFCE)  ';
//
//
//      qryCupomPgto.Params.ArraySize := Nota.Pagamentos.Count;
//      if Nota.Pagamentos.Count = 0 then
//        raise Exception.Create('Sem Itens');
//
//      I := 0;
//      for NFCePgto in Nota.Pagamentos do
//      begin
//        qryCupomPgto.Params[0].AsIntegers[i]                 := 1;
//        qryCupomPgto.Params[1].AsIntegers[i]                 := nota.Nr_cupom;
//        qryCupomPgto.Params[2].AsIntegers[i]                 := nota.Nr_ecf;
//        qryCupomPgto.Params[3].AsIntegers[i]                 := NFCePgto.Nr_sequencia;
//        qryCupomPgto.Params[4].AsDateTimes[i]                    := strtodate(Nota.dtEmissao);
//        qryCupomPgto.Params[5].AsIntegers[i]                 := NFCePgto.CD_FINALIZADORA;
//        qryCupomPgto.Params[6].AsCurrencys[i]                := NFCePgto.VL_FINALIZADORA;
//        qryCupomPgto.Params[7].AsStrings[i]                  := fBuscarNomeFinalizadora(NFCePgto.CD_FINALIZADORA);
//        qryCupomPgto.Params[8].AsStrings[i]                  := fBuscarTipoFinalizadora(NFCePgto.CD_FINALIZADORA);
//        qryCupomPgto.Params[9].AsIntegers[i]                 := nota.Nr_ecf;
//        qryCupomPgto.Params[10].AsIntegers[i]                := nota.Nr_cupom;
//        qryCupomPgto.Params[11].AsIntegers[i]                := 0;//NFCePgto.NR_GNF;
//
//        if NFCePgto.Cd_cancelamento = 99 then
//          qryCupomPgto.Params[12].AsStrings[i]               := 'S'
//        else
//          qryCupomPgto.Params[12].AsStrings[i]               := 'N';
//
//        qryCupomPgto.Params[13].AsStrings[i]                 := '';//NFCePgto.EAD;
//        qryCupomPgto.Params[14].AsIntegers[i]                := vNrDocumento;
//        qryCupomPgto.Params[15].AsStrings[i]                 := '';//NFCePgto.TP_DOC;
//        qryCupomPgto.Params[16].AsStrings[i]                 := nota.modelo;
//        qryCupomPgto.Params[17].AsIntegers[i]                := nota.Serie;
//        qryCupomPgto.Params[18].AsStrings[i]                 := '';//NFCePgto.EAD_UNICODE;
////          qryCupomPgto.Params[19].AsIntegers[i]              := 1;//NFCePgto.PGT_CODIGO;
////          qryCupomPgto.Params[20].AsStrings[i]               := NFCePgto.TROCO_CARTAO;
//        qryCupomPgto.Params[21].AsFloats[i]                  := NFCePgto.Vl_troco;
//
//        if fgravarTef(NFCePgto.Tef_id) then
//          qryCupomPgto.Params[22].AsStrings[i]               := vIdTEF.ToString;
//        qryCupomPgto.Params[23].AsStrings[i]                 := fBuscarCodigoPagNFCE(NFCePgto.CD_FINALIZADORA);
//        Inc(I);
//      end;
//      qryCupomPgto.Execute(qryCupomPgto.Params.ArraySize);
//    except on E:Exception do
//         begin
//               raise Exception.Create('Erro ao INSERIR A CUPOMPGTO' + E.Message);
//               exit;
//          end;
//    end;
//    result := true;
//    qryCupomPgto.Free;
//  end;
//  Function fGravarItens : boolean;
//  var
//    qryNFSI : TFdQuery;
//    NFCeItem: TNFCeItem;
//    i :Integer;
//  begin
//    result := false;
//    try
//      qryNFSI := TFDQuery.Create(nil);
//      qryNfsi.Connection := FDConexao;
//      qryNFSI.Active := false;
//      qryNFSI.SQL.Clear;
//      qryNFSI.SQL.text :=
//
//          '	INSERT INTO NFSI  '+
//                    '(CD_FILIAL,NR_DOCUMENTO,NR_SEQUENCIA,CD_PRODSERV,NM_PRODSERV,FL_SERVICO,QT_PRODUTO,VL_BRUTO,PC_DESCONTO,VL_LIQUIDO,VL_TOTAL,  '+
//                    ' PRECO_MINIMO,CD_FUNCIONARIO,DT_EMISSAO,PESO_LIQUIDO,CD_CANCELAMENTO,CST,PC_RED_BASE_ICM,ALIC_ICM,ALIC_ICM_SUBST,ALIC_IPI,ALIC_ISS,  '+
//                    ' VL_BASE_ICM,VL_ICM,VL_ICM_SUBST,VL_IPI,VL_ISS,FL_TRIBUTACAO_INF,VL_BASE_COMISSAO,VL_COMISSAO,PC_COMISSAO,FL_COMISSAO_INF,COMPL,DT_ATZ,UN,FL_CONTROLAR_ESTOQUE,  '+
//                    ' PLACA_VEICULO,KILOMETRAGEM,CD_CONTA,VL_ISS_SUBST,FL_COMPOSTO,COMPOSICAO,CD_PRODUTO,CFOP,ALIQ_PIS,VL_BASE_PIS,VL_PIS,ALIQ_COFINS,VL_BASE_COFINS,VL_COFINS,  '+
//                    ' VL_BASE_ICM_ST,PC_MVA_ST,EAD,NR_COO,NR_CCF,CST_PIS,CST_COFINS,VL_FRETE_RAT,NATUREZA_RECEITA_PIS,NATUREZA_RECEITA_COFINS,VL_DESCONTO,NF_REFERENCIA,FL_TRUNCAMENTO,  '+
//                    ' VL_DESC_ITEM,VL_ACRESCIMO_RAT,VL_SEGURO_RAT,CD_CLIFOR,FL_CONTROLAR_COTA,VL_IMPOSTO_APROXIMADO,VL_BASE_IPI,CST_IPI,DT_PRESTACAO_SERVICO,DT_INCLUSAO_ITEM,DIR_FISCAL,EAD_UNICODE,  '+
//                    ' FL_CANCELADOPELOPDV,VL_REDUCAO,ITEM_AJUSTADO_DIF_BASE,ITEM_AJUSTADO_DIF_ICMS,ITEM_AJUSTADO_DIF_TOTAL,VL_FUNDO_COMBATE_POBREZA,VL_ICMS_PARTILHA_UFDEST,VL_ICMS_PARTILHA_UFORI,  '+
//                    ' PC_ICMS_PARTILHA_UFDEST,PC_ICMS_PARTILHA_UFORI,ALIQICMS_INTERNA_UFDESTINO,ALIQICMS_INTERESTADUAL,PC_FUNDO_COMBATE_POBREZA,CEST,STATUS,EAD_J2,ID_CBENEF,  '+
//                    ' VL_AJ_APUR,VL_BASE_FCP,ALIC_FCP,VL_FCP,VL_BASE_FCP_ST,ALIC_FCP_ST,VL_FCP_ST,VL_BASE_FCP_ST_RET,ALIC_FCP_ST_RET,VL_FCP_ST_RET,NR_PEDIDOITEM,NR_PEDIDO)  '+
//          '       VALUES   '+
//                    '(:CD_FILIAL, :NR_DOCUMENTO, :NR_SEQUENCIA, :CD_PRODSERV, :NM_PRODSERV, :FL_SERVICO, :QT_PRODUTO, :VL_BRUTO, :PC_DESCONTO, :VL_LIQUIDO, :VL_TOTAL, :PRECO_MINIMO, :CD_FUNCIONARIO,   '+
//                    ' :DT_EMISSAO, :PESO_LIQUIDO, :CD_CANCELAMENTO, :CST, :PC_RED_BASE_ICM, :ALIC_ICM, :ALIC_ICM_SUBST, :ALIC_IPI, :ALIC_ISS, :VL_BASE_ICM, :VL_ICM, :VL_ICM_SUBST, :VL_IPI, :VL_ISS,   '+
//                    ' :FL_TRIBUTACAO_INF, :VL_BASE_COMISSAO, :VL_COMISSAO, :PC_COMISSAO, :FL_COMISSAO_INF, :COMPL, :DT_ATZ, :UN, :FL_CONTROLAR_ESTOQUE, :PLACA_VEICULO, :KILOMETRAGEM, :CD_CONTA,   '+
//                    ' :VL_ISS_SUBST, :FL_COMPOSTO, :COMPOSICAO, :CD_PRODUTO, :CFOP, :ALIQ_PIS, :VL_BASE_PIS, :VL_PIS, :ALIQ_COFINS, :VL_BASE_COFINS, :VL_COFINS, :VL_BASE_ICM_ST, :PC_MVA_ST, :EAD,   '+
//                    ' :NR_COO, :NR_CCF, :CST_PIS, :CST_COFINS, :VL_FRETE_RAT, :NATUREZA_RECEITA_PIS, :NATUREZA_RECEITA_COFINS, :VL_DESCONTO, :NF_REFERENCIA, :FL_TRUNCAMENTO, :VL_DESC_ITEM, :VL_ACRESCIMO_RAT,  '+
//                    ' :VL_SEGURO_RAT, :CD_CLIFOR, :FL_CONTROLAR_COTA, :VL_IMPOSTO_APROXIMADO, :VL_BASE_IPI, :CST_IPI, :DT_PRESTACAO_SERVICO, :DT_INCLUSAO_ITEM, :DIR_FISCAL, :EAD_UNICODE, :FL_CANCELADOPELOPDV,  '+
//                    ' :VL_REDUCAO, :ITEM_AJUSTADO_DIF_BASE, :ITEM_AJUSTADO_DIF_ICMS, :ITEM_AJUSTADO_DIF_TOTAL, :VL_FUNDO_COMBATE_POBREZA, :VL_ICMS_PARTILHA_UFDEST, :VL_ICMS_PARTILHA_UFORI, :PC_ICMS_PARTILHA_UFDEST,  '+
//                    ' :PC_ICMS_PARTILHA_UFORI, :ALIQICMS_INTERNA_UFDESTINO, :ALIQICMS_INTERESTADUAL, :PC_FUNDO_COMBATE_POBREZA, :CEST, :STATUS, :EAD_J2, :ID_CBENEF, :VL_AJ_APUR, :VL_BASE_FCP, :ALIC_FCP, :VL_FCP,  '+
//                    ' :VL_BASE_FCP_ST, :ALIC_FCP_ST, :VL_FCP_ST, :VL_BASE_FCP_ST_RET, :ALIC_FCP_ST_RET, :VL_FCP_ST_RET, :NR_PEDIDOITEM, :NR_PEDIDO)  ';
//
//      qryNFSI.Params.ArraySize := Nota.Itens.Count;
//      if Nota.Itens.Count = 0 then
//        raise Exception.Create('Sem Itens');
//
//      I := 0;
//      for NFCeItem in Nota.Itens do
//      begin
//        qryNFSI.Params[0].AsIntegers[I]          := 1;
//        qryNFSI.Params[1].AsIntegers[I]          := vNrDocumento;
//        qryNFSI.Params[2].AsIntegers[I]          := NFCeItem.NR_SEQUENCIA;
//        qryNFSI.Params[3].AsStrings[I]           := NFCeItem.CD_PRODSERV;
//        qryNFSI.Params[4].AsStrings[I]           := NFCeItem.NM_PRODSERV;
//        qryNFSI.Params[5].AsStrings[I]           := 'P';
//        qryNFSI.Params[6].AsFloats[I]            := NFCeItem.QT_PRODUTO;
//        qryNFSI.Params[7].AsFloats[I]            := NFCeItem.VL_BRUTO;
//        qryNFSI.Params[8].AsFloats[I]            := NFCeItem.PC_DESCONTO;
//        qryNFSI.Params[9].AsCurrencys[I]         := NFCeItem.VL_LIQUIDO;
//        qryNFSI.Params[10].AsCurrencys[I]        := NFCeItem.VL_TOTAL;
//        qryNFSI.Params[11].AsCurrencys[I]        := 0;
//        qryNFSI.Params[12].AsIntegers[I]         := NFCeItem.CD_FUNCIONARIO;
//        qryNFSI.Params[13].AsDateTimes[I]            := strToDate(Nota.dtEmissao);
//        qryNFSI.Params[14].AsFloats[I]           := NFCeItem.PESO_LIQUIDO;
//        qryNFSI.Params[15].AsIntegers[I]         := NFCeItem.CD_CANCELAMENTO;
//        qryNFSI.Params[16].AsStrings[I]          := NFCeItem.CST;
//        qryNFSI.Params[17].AsFloats[I]           := NFCeItem.PC_RED_BASE_ICM;
//        qryNFSI.Params[18].AsFloats[I]           := NFCeItem.ALIC_ICM;
//        qryNFSI.Params[19].AsFloats[I]           := NFCeItem.ALIC_ICM_SUBST;
//        qryNFSI.Params[20].AsFloats[I]           := 0;//NFCeItem.ALIC_IPI;
//        qryNFSI.Params[21].AsFloats[I]           := 0;//NFCeItem.ALIC_ISS;
//        if NFCeItem.CST = '000' then
//        begin
//          qryNFSI.Params[22].AsCurrencys[I]        := NFCeItem.VL_TOTAL;
//          qryNFSI.Params[23].AsCurrencys[I]        := NFCeItem.VL_TOTAL * NFCeItem.ALIC_ICM / 100;
//        end;
//        qryNFSI.Params[24].AsCurrencys[I]        := NFCeItem.VL_ICM_SUBST;
//        qryNFSI.Params[25].AsCurrencys[I]        := 0;// NFCeItem.VL_IPI;
//        qryNFSI.Params[26].AsCurrencys[I]        := 0; //NFCeItem.VL_ISS;
//        qryNFSI.Params[27].AsStrings[I]          := 'N' ;//NFCeItem.FL_TRIBUTACAO_INF;
//        qryNFSI.Params[28].AsCurrencys[I]        := 0;// NFCeItem.VL_BASE_COMISSAO;
//        qryNFSI.Params[29].AsCurrencys[I]        := 0;//NFCeItem.VL_COMISSAO;
//        qryNFSI.Params[30].AsFloats[I]           := 0;//NFCeItem.PC_COMISSAO;
//        qryNFSI.Params[31].AsStrings[I]          := 'N';//NFCeItem.FL_COMISSAO_INF;
//        qryNFSI.Params[32].AsBlobs[I]            := 'MOBILE'; //NFCeItem.COMPL;
//        qryNFSI.Params[33].AsDateTimes[I]        := strToDate(Nota.dtEmissao);
//        qryNFSI.Params[34].AsStrings[I]          := NFCeItem.UN;
//        qryNFSI.Params[35].AsStrings[I]          := 'S';//NFCeItem.FL_CONTROLAR_ESTOQUE;
//        qryNFSI.Params[36].AsStrings[I]          := '';//NFCeItem.PLACA_VEICULO;
//        qryNFSI.Params[37].AsIntegers[I]         := 0;//NFCeItem.KILOMETRAGEM;
//        qryNFSI.Params[38].AsIntegers[I]         := 43; //NFCeItem.CD_CONTA;
//        qryNFSI.Params[39].AsCurrencys[I]        := 0;//NFCeItem.VL_ISS_SUBST;
//        qryNFSI.Params[40].AsStrings[I]          := nfceItem.Fl_composto;
//        qryNFSI.Params[41].AsBlobs[I]            := '';//NFCeItem.COMPOSICAO;
//        qryNFSI.Params[42].AsStrings[I]          := NFCeItem.CD_PRODUTO;
//        qryNFSI.Params[43].AsStrings[I]          := NFCeItem.CFOP;
//
//        {Pis/Cofins}
//        if NFCeItem.Vl_base_pis = 0 then
//          NFCeItem.Aliq_pis := 0;
//
//        qryNFSI.Params[44].AsCurrencys[I]        := NFCeItem.ALIQ_PIS;
//        if NFCeItem.CST_PIS = 1 then
//        begin
//          qryNFSI.Params[45].AsCurrencys[I]        := NFCeItem.Vl_total;
//          qryNFSI.Params[46].AsCurrencys[I]        := roundto((NFCeItem.Vl_total * NFCeItem.ALIQ_PIS / 100),-2);
//        end;
//
//        if NFCeItem.Vl_base_cofins = 0 then
//        NFCeItem.Aliq_cofins := 0;
//
//        qryNFSI.Params[47].AsCurrencys[I]        := NFCeItem.ALIQ_COFINS;
//        if NFCeItem.CST_PIS = 1 then
//        begin
//          qryNFSI.Params[48].AsCurrencys[I]        := NFCeItem.Vl_total;
//          qryNFSI.Params[49].AsCurrencys[I]        := roundto( (NFCeItem.Vl_total * NFCeItem.ALIQ_COFINS / 100), -2);
//        end;
//
//        qryNFSI.Params[50].AsCurrencys[I]        := NFCeItem.VL_BASE_ICM_ST;
//        qryNFSI.Params[51].AsCurrencys[I]        := NFCeItem.PC_MVA_ST;
//        qryNFSI.Params[52].AsStrings[I]          := '' ;//NFCeItem.EAD;
//        qryNFSI.Params[53].AsIntegers[I]         := nota.Nr_cupom;
//        qryNFSI.Params[54].AsIntegers[I]         := nota.Nr_cupom;
//        qryNFSI.Params[55].AsIntegers[I]         := NFCeItem.CST_PIS;
//        qryNFSI.Params[56].AsIntegers[I]         := NFCeItem.CST_COFINS;
//        qryNFSI.Params[57].AsCurrencys[I]        := 0;//NFCeItem.VL_FRETE_RAT;
////          qryNFSI.Params[58].AsIntegers[I]         := NFCeItem.NATUREZA_RECEITA_PIS;
////          qryNFSI.Params[59].AsIntegers[I]         := NFCeItem.NATUREZA_RECEITA_COFINS;
//        qryNFSI.Params[60].AsCurrencys[I]        := NFCeItem.VL_DESCONTO;
////          qryNFSI.Params[61].AsStrings[I]           := 'NULL';
//        qryNFSI.Params[62].AsStrings[I]          := 'T' ;//NFCeItem.FL_TRUNCAMENTO;
//        qryNFSI.Params[63].AsCurrencys[I]        := NFCeItem.VL_DESC_ITEM;
//        qryNFSI.Params[64].AsCurrencys[I]        := 0;//NFCeItem.VL_ACRESCIMO_RAT;
//        qryNFSI.Params[65].AsCurrencys[I]        := 0;//NFCeItem.VL_SEGURO_RAT;
//        qryNFSI.Params[66].AsIntegers[I]         := nota.CD_CLIFOR;
//        qryNFSI.Params[67].AsStrings[I]          := 'S';//NFCeItem.FL_CONTROLAR_COTA;
//        qryNFSI.Params[68].AsFloats[I]           := NFCeItem.VL_IMPOSTO_APROXIMADO;
//        qryNFSI.Params[69].AsCurrencys[I]        := 0;//NFCeItem.VL_BASE_IPI;
//        qryNFSI.Params[70].AsIntegers[I]         := 0;//NFCeItem.CST_IPI;
//        qryNFSI.Params[71].AsDate            := strToDate(Nota.dtEmissao);
//        qryNFSI.Params[72].AsDate            := strToDate(Nota.dtEmissao);
//        qryNFSI.Params[73].AsStrings[I]          := NFCeItem.DIR_FISCAL;
//        qryNFSI.Params[74].AsStrings[I]          := '' ;//NFCeItem.EAD_UNICODE;
//        qryNFSI.Params[75].AsIntegers[I]         := 0 ; //NFCeItem.FL_CANCELADOPELOPDV;
//        qryNFSI.Params[76].AsFloats[I]           := 0 ;//NFCeItem.VL_REDUCAO;
//        qryNFSI.Params[77].AsFloats[I]           := NFCeItem.ITEM_AJUSTADO_DIF_BASE;
//        qryNFSI.Params[78].AsFloats[I]           := NFCeItem.ITEM_AJUSTADO_DIF_ICMS;
//        qryNFSI.Params[79].AsFloats[I]           := NFCeItem.ITEM_AJUSTADO_DIF_TOTAL;
//        qryNFSI.Params[80].AsFloats[I]           := NFCeItem.VL_FUNDO_COMBATE_POBREZA;
//        qryNFSI.Params[81].AsFloats[I]           := NFCeItem.VL_ICMS_PARTILHA_UFDEST;
//        qryNFSI.Params[82].AsFloats[I]           := NFCeItem.VL_ICMS_PARTILHA_UFORI;
//        qryNFSI.Params[83].AsFloats[I]           := NFCeItem.PC_ICMS_PARTILHA_UFDEST;
//        qryNFSI.Params[84].AsFloats[I]           := NFCeItem.PC_ICMS_PARTILHA_UFORI;
//        qryNFSI.Params[85].AsFloats[I]           := NFCeItem.ALIQICMS_INTERNA_UFDESTINO;
//        qryNFSI.Params[86].AsFloats[I]           := NFCeItem.ALIQICMS_INTERESTADUAL;
//        qryNFSI.Params[87].AsFloats[I]           := NFCeItem.PC_FUNDO_COMBATE_POBREZA;
//        qryNFSI.Params[88].AsStrings[I]          := NFCeItem.CEST;
//        qryNFSI.Params[89].AsIntegers[I]         := NFCeItem.STATUS;
//        qryNFSI.Params[90].AsStrings[I]          := ''; //NFCeItem.EAD_J2;
//        qryNFSI.Params[91].AsIntegers[I]         := NfceItem.CD_CBENEF;
//        qryNFSI.Params[92].AsCurrencys[I]        := NFCeItem.VL_AJ_APUR;
//        qryNFSI.Params[93].AsCurrencys[I]        := NFCeItem.VL_BASE_FCP;
//        qryNFSI.Params[94].AsCurrencys[I]        := NFCeItem.ALIC_FCP;
//        qryNFSI.Params[95].AsCurrencys[I]        := NFCeItem.VL_FCP;
//        qryNFSI.Params[96].AsCurrencys[I]        := NFCeItem.VL_BASE_FCP_ST;
//        qryNFSI.Params[97].AsCurrencys[I]        := NFCeItem.ALIC_FCP_ST;
//        qryNFSI.Params[98].AsCurrencys[I]        := NFCeItem.VL_FCP_ST;
//        qryNFSI.Params[99].AsCurrencys[I]        := NFCeItem.VL_BASE_FCP_ST_RET;
//        qryNFSI.Params[100].AsCurrencys[I]       := NFCeItem.ALIC_FCP_ST_RET;
//        qryNFSI.Params[101].AsCurrencys[I]       := NFCeItem.VL_FCP_ST_RET;
//        Inc(I);
//      end;
//      try
//        qryNFSI.Execute(qryNFSI.Params.ArraySize);
//      except
//        on e:exception do
//         raise Exception.Create(e.Message);
//      end;
//    except on E:Exception do
//         begin
//               raise Exception.Create('Erro ao INSERIR A NFSI ' + E.Message);
//               exit;
//          end;
//    end;
//    result := true;
//    qryNfsi.Free;
//  end;

//  function fNotaIsServer: boolean;
//  var
//    qryConsulta : TFDQuery;
//  begin
//    result := false;
//    try
//      qryConsulta := TFDQuery.Create(nil);
//      qryConsulta.Connection := FDConexao;
//      qryConsulta.Active := false;
//      qryConsulta.SQL.Clear;
//      if nota.modelo = '59' then
//        qryConsulta.SQL.Text := ' SELECT first 1 nr_documento from nfsc where autChave = '  + QuotedStr(nota.autChave)
//      else
//        qryConsulta.SQL.Text :=
//              '  SELECT    '+
//              '      FIRST 1 NR_DOCUMENTO    '+
//              '  FROM    '+
//              '      NFSC    '+
//              '  WHERE    '+
//              '      NFSC.NR_NF =   '+ Nota.Nr_nf.ToString +
//              '  AND    '+
//              '      NFSC.NR_SERIE =    '+ nota.Nr_serie.ToString +
//              '  AND    '+
//              '      NFSC.NR_ECF   = '+ nota.Nr_ecf.ToString;
//      qryConsulta.Open;
//      if not qryConsulta.IsEmpty then
//      begin
//        vNrDocumento := qryConsulta.FieldByName('NR_DOCUMENTO').AsInteger;
//        result := true;
//      end;
//    finally
//      qryConsulta.Free;
//    end;
//  end;
begin

//  result := '';
//  try
//    fSalvarJsonOriginal(Nota.idDispositivo, nota.chave_doc, Nota.AsJsonString, cnpj);
//
//    if fNotaIsServer then
//    begin
//      result := vNrDocumento.toString;
//      exit;
//    end;
//    //XML
//    vIdXml := fGravarXML;
//    if vIdXml = 0 then
//      raise exception.Create('Erro Gravar xml');
//    //Busca do código NR_DOCUMENTO
//    vNrDocumento := fBuscarNrDocumento;
//
//    if vNrDocumento = 0 then
//      raise exception.Create('Erro Buscar NR documento');
//
//    //GravaNFSC
//    if not fGravarCabecalho then
//      raise exception.Create('Erro Gravar Cabecalho');
//
//    if not fGravarItens  then
//      raise exception.Create('Erro Gravar Itens');
//
//    if not fGravarPagamento then
//      raise exception.Create('Erro Gravar Pagamento');
//
//    if not fGravarTitulos then
//      raise exception.Create('Erro Gravar Titulos');
//
//    result := vNrDocumento.toString;
//  except on e:exception do
//    begin
//        MVCFramework.Logger.LogE('Erro na grvacao do documento=' + vnrDocumento.ToString +
//                                ', Erro:' + e.Message);
//    end
//
//  end;

end;

function TBaseController.fSalvarJsonOriginal(Dispositivo, chave_doc,
  texto: String; const cnpj: String): Boolean;
var
 vArquivo: TStringList;
 vCaminho,vNomeArq :String;
begin
  try
    vArquivo := TStringList.Create;
    vCaminho := ExtractFilePath(ParamStr(0)) + '\Documentos\Envio\' + cnpj + '\' + Dispositivo + '\' +
                 IntToStr(YearOf(Date)) + '\' +
                 FormatFloat('00',MonthOf(Date)) + '\' +
                 FormatFloat('00',DayOf(Date)) + '\' ;
    vArquivo.Clear;
    vArquivo.add(texto);
    ForceDirectories(vCaminho);
    vArquivo.SaveToFile(vCaminho + chave_doc + '.txt');

  finally
    vArquivo.free;
  end;
end;

function TBaseController.fTestarBanco(preco: string): string;
    function fBuscarNrDocumento: integer;
    var
      qryBuscarDocumento : TFDQuery;
    begin
      result := 0;
      //gravar o xml na tabela e pega o id do xml
      //se gravou com sucesso resulta o id xml;
      try
        qryBuscarDocumento := TFDQuery.Create(nil);
        qryBuscarDocumento.Connection := FDConexao;
        qryBuscarDocumento.Active := false;
        qryBuscarDocumento.SQL.Clear;
        qryBuscarDocumento.SQL.text := ' SELECT FIRST 1 GEN_ID(GEN_NR_DOCUMENTO_NFSC,1) AS ID FROM FILIAL ';
        qryBuscarDocumento.Active := true;
        if not qryBuscarDocumento.IsEmpty then
          result := qryBuscarDocumento.FieldByName('ID').AsInteger;
      finally
        qryBuscarDocumento.Free
      end;
    end;


    Function fGravarTemp1(doc:String):Boolean;
    var
      qryCupomPgto : TFdQuery;
      NFCePgto: TNFCePagto;
      i :Integer;
    begin
      result := false;
      try
        qryCupomPgto := TFDQuery.Create(nil);
        qryCupomPgto.Connection := FDConexao;
        qryCupomPgto.Active := false;
        qryCupomPgto.SQL.Clear;
        qryCupomPgto.SQL.text :=

            '  insert into teste1 values ('+doc+',' + preco + ')';
         qryCupomPgto.ExecSQL;
      except on E:Exception do
           begin
                 raise Exception.Create('Erro ao INSERIR A CUPOMPGTO' + E.Message);
                 exit;
            end;
      end;
      result := true;
      qryCupomPgto.Free;
    end;

Function fGravarTemp2(doc:String):Boolean;
    var
      qryCupomPgto : TFdQuery;
      NFCePgto: TNFCePagto;
      i :Integer;
    begin
      result := false;
      try
        qryCupomPgto := TFDQuery.Create(nil);
        qryCupomPgto.Connection := FDConexao;
        qryCupomPgto.Active := false;
        qryCupomPgto.SQL.Clear;
        qryCupomPgto.SQL.text :=

            '  insert into teste2 values ('+doc+',' + preco + ')';
         qryCupomPgto.ExecSQL;
      except on E:Exception do
           begin
                 raise Exception.Create('Erro ao INSERIR A CUPOMPGTO' + E.Message);
                 exit;
            end;
      end;
      result := true;
      qryCupomPgto.Free;
    end;


    Function fGravarTemp3(doc:String):Boolean;
    var
      qryCupomPgto : TFdQuery;
      NFCePgto: TNFCePagto;
      i :Integer;
    begin
      result := false;
      try
        qryCupomPgto := TFDQuery.Create(nil);
        qryCupomPgto.Connection := FDConexao;
        qryCupomPgto.Active := false;
        qryCupomPgto.SQL.Clear;
        qryCupomPgto.SQL.text :=

            '  insert into teste3 values ('+doc+',' + preco + ')';
         qryCupomPgto.ExecSQL;
      except on E:Exception do
           begin
                 raise Exception.Create('Erro ao INSERIR A CUPOMPGTO' + E.Message);
                 exit;
            end;
      end;
      result := true;
      qryCupomPgto.Free;
    end;


var
  qryAlteracao : TfdQuery;
  qryTemp: TfdQuery;
  documento :String;

begin
  result := '';
  documento:=fBuscarNrDocumento.ToString;

  if StrToIntDef(documento,0) = 0 then
     exit;

  try
    if not fGravarTemp1(documento) then
      exit;

    if not fGravarTemp2(documento) then
      exit;

    if not fGravarTemp3(documento) then
      exit;

  eXCEPT
    EXIT;
  end;

  RESULT := documento;

end;

function TBaseController.fGravarAutServer(const cnpj, iddispositivo, chavedanfe, xml_ori, xml_ret: String; const cancelamento, serie, nota: integer):String;
var
  qryAutServer: TFDQuery;
begin
  try
    try
      qryAutServer := TFDQuery.create(nil);
      qryAutServer.connection := FWebModule.ConnSQLite;

      qryAutServer.Sql.Text := 'INSERT INTO DOCUMENTOS (ID_DISP, CANCELADO, CHAVEDANFE, XML_ENVIO, XML_RETORNO, SERIE, NR_NOTA, CNPJ) ' +
        'VALUES (:ID_DISP, :CANCELADO, :CHAVEDANFE, :XML_ENVIO, :XML_RETORNO, :SERIE, :NR_NOTA, :CNPJ)' ;

      qryAutServer.paramByName('ID_DISP').AsInteger := IdDispositivo.ToInteger;
      qryAutServer.paramByName('CANCELADO').AsInteger := Cancelamento;
      qryAutServer.paramByName('CHAVEDANFE').AsString := ChaveDanfe;
      qryAutServer.paramByName('XML_ENVIO').AsString := xml_ori;
      qryAutServer.paramByName('XML_RETORNO').AsString := xml_ret;
      qryAutServer.paramByName('SERIE').AsInteger := Serie;
      qryAutServer.paramByName('NR_NOTA').AsInteger := Nota;
      qryAutServer.paramByName('CNPJ').AsString := cnpj;
      qryAutServer.ExecSQL;

    finally
      qryAutServer.Free;
      FWebModule.ConnSQLite.Connected := False;
    end;
  except

  end;
end;

function TBaseController.fBuscarXML(const ANumero, ASerie: integer;
  const modelo: string): string;
var
  qry : TFDQuery;
  temErro :boolean;
  aux, xml : string;
begin

  result  := '';
  temErro := false;

  try

    FWebModule.ConnSQLite.Connected := True;



    qry := TFDQuery.Create(nil);
    qry.Connection := FWebModule.ConnSQLite;
    qry.Active := false;
    qry.SQL.Clear;

    try
      qry.SQL.text := ' SELECT ' + sLineBreak +
                      '   XML_RETORNO ' +sLineBreak +
                      ' FROM ' +sLineBreak +
                      '   DOCUMENTOS ' +sLineBreak +
                      ' WHERE ' +sLineBreak +
                      '   NR_SERIE = :NR_SERIE ' +sLineBreak +
                      ' AND ' +sLineBreak +
                      '   NR_NF = :NR_NF ' +
                      ' AND ' +sLineBreak +
                      '   CD_MODELO = :CD_MODELO ';;


      qry.ParamByName('NR_SERIE').AsInteger   := ASerie;
      qry.ParamByName('NR_NF').AsInteger      := ANumero;
      qry.ParamByName('CD_MODELO').AsString   := modelo;

      qry.Active := true;

      xml:=  qry.FieldByName('XML_RETORNO').asString;


    except on E:Exception do
      begin
         temErro := true;
      end;

    end;

  finally
    qry.Free;
    FWebModule.ConnSQLite.Connected := false;
    if not temErro then
      result := xml;
  end;
end;

function TBaseController.fBuscarXMLChaveDoc(const vChaveDoc :string; const vIdDispositivo: String): string;
var
  qry : TFDQuery;
  temErro :boolean;
  aux, xml : string;
begin

  result  := '';
  temErro := false;

  try

    FWebModule.ConnSQLite.Connected := True;



    qry := TFDQuery.Create(nil);
    qry.Connection := FWebModule.ConnSQLite;
    qry.Active := false;
    qry.SQL.Clear;

    try
      qry.SQL.text := ' SELECT ' + sLineBreak +
                      '   XML_RETORNO ' +sLineBreak +
                      ' FROM ' +sLineBreak +
                      '   DOCUMENTOS ' +sLineBreak +
                      ' WHERE ' +sLineBreak +
                      '   DISPOSITIVO = :DISPOSITIVO ' +sLineBreak +
                      ' AND ' +sLineBreak +
                      '   CHAVEDOC = :CHAVEDOC ';


      qry.ParamByName('DISPOSITIVO').AsString := vIdDispositivo;
      qry.ParamByName('CHAVEDOC').AsString    := vChaveDoc;
      qry.Active := true;

  //    xml:=  qry.FieldByName('XML_RETORNO').asString;

      if qry.FieldByName('XML_RETORNO').asString <> '' then
      begin
         aux := qry.FieldByName('XML_RETORNO').asString;
         aux := copy(aux,pos('|', aux)+1,aux.Length);
         aux := copy(aux,pos('|', aux)+1,aux.Length);
         aux := copy(aux,pos('|', aux)+1,aux.Length);
         aux := copy(aux,pos('|', aux)+1,aux.Length);
         aux := copy(aux,pos('|', aux)+1,aux.Length);
         aux := copy(aux,pos('|', aux)+1,aux.Length);
         aux := copy(aux, 0,pos('|', aux));

         xml := base64Decode(aux);

      end;


    except on E:Exception do
      begin
         temErro := true;
      end;

    end;

  finally
    qry.Free;
    FWebModule.ConnSQLite.Connected := false;
    if not temErro then
      result := xml;
  end;
end;

function TBaseController.fExisteRegistroBanco(const vTabela, vCampo,
  vValor: string): boolean;
var
  qryConsulta: TFDQuery;
begin
  try
    result := false;
    qryConsulta := TFDquery.Create(nil);
    qryConsulta.Connection := FDConexao;
    qryConsulta.SQL.Text := ' SELECT first 1 ' +
                             vcampo +
                            '  FROM ' +
                             vTabela +
                           '  WHERE  '+
                             vCampo + ' = ' + QuotedStr(vValor);

     qryConsulta.Open;
    if not qryConsulta.IsEmpty then
      result := qryConsulta.FieldByName(vcampo).AsString = vValor;
  finally
    qryConsulta.Free;
  end;
end;


function TBaseController.fBuscarNovoCodigoCliente: Integer;
var
  qryCodigo: TFDQuery;
begin
  try
    result := 0;
    qryCodigo := TFDquery.Create(nil);
    qryCodigo.Connection := FDConexao;
    qryCodigo.SQL.Text := 'SELECT ' +
                          '    (MAX(COALESCE(CD_CLIENTE, 0)) + 1) NEW_CODIGO ' +
                          'FROM ' +
                          '    CLIENTE ';
    if not qryCodigo.IsEmpty then
      result := qryCodigo.FieldByName('NEW_CODIGO').AsInteger;
  finally
    qryCodigo.Free;
  end;
end;

function TBaseController.base64Decode(const Text: String): String;
var
  Decoder : TIdDecoderMime;
begin
  Decoder := TIdDecoderMime.Create(nil);
  try
    Result := Decoder.DecodeString(Text);
  finally
    FreeAndNil(Decoder)
  end
end;

function TBaseController.fbuscaIdContagem(vNr_ECF: integer): integer;
var
  qryBuscaID :TFDQuery;
begin

  try
    result := 0;
    qryBuscaID := TFDQuery.Create(nil);
    qryBuscaID.Connection := FDConexao;
    qryBuscaID.Active := false;
    qryBuscaID.SQL.Clear;
    qryBuscaID.SQL.text := 'SELECT MAX(ID) as ID FROM CONTAGEM_MOBILE_C WHERE STATUS = 1 AND NR_ECF = :NR_ECF';
    qryBuscaID.ParamByName('NR_ECF').AsInteger := vNr_ECF;

    qryBuscaID.Active := true;
    if not qryBuscaID.FieldByName('ID').IsNull then
       result :=  qryBuscaID.FieldByName('ID').AsInteger;

  finally
    qryBuscaID.free;
  end;
end;
function TBaseController.fBuscarAdministradora(vNomeAdministradora : sTRING): integer;
  function fAchaMaxId : integer;
  var
    qryMax :TFDQuery;
  begin

    try
      qryMax := TFDQuery.Create(nil);
      qryMax.Connection := FDConexao;
      qryMax.Active := false;
      qryMax.SQL.Clear;
      qryMax.SQL.text := 'SELECT MAX(CD_ADMINISTRADORA) as CD_ADMINISTRADORA FROM ADMINISTRADORA';

      qryMax.Active := true;
      if not qryMax.FieldByName('CD_ADMINISTRADORA').IsNull then
         result :=  qryMax.FieldByName('CD_ADMINISTRADORA').AsInteger + 1;

    finally
      qryMax.free;
    end;
  end;
var
  qry :TFDQuery;
  cdAdministradora : integer;
begin
      cdAdministradora := 0;
      try
        qry := TFDQuery.Create(nil);
        qry.Connection := FDConexao;
        qry.Active := false;
        qry.SQL.Clear;
        qry.SQL.text := 'SELECT FIRST 1 CD_ADMINISTRADORA FROM ADMINISTRADORA WHERE UPPER(NM_ADMINISTRADORA) = UPPER(:NM_ADMINISTRADORA) ';
        qry.ParamByName('NM_ADMINISTRADORA').AsString := vNomeAdministradora;

        qry.Active := true;
        if not qry.FieldByName('CD_ADMINISTRADORA').IsNull then  //encontrou a administradora
        begin
          cdAdministradora := qry.FieldByName('CD_ADMINISTRADORA').AsInteger;
          exit;
        end
        else  //Insere a Administradora
        begin
          cdAdministradora :=  fAchaMaxId;
          qry.SQL.Clear;
          qry.SQL.Text := ' INSERT INTO ADMINISTRADORA (CD_ADMINISTRADORA,NM_ADMINISTRADORA,PC_COBRANCA,DIAS_PAGAMENTO,DT_ATZ,END_NUMERO,END_COMPLEMENTO,ENDERECO,BAIRRO,CD_CIDADE,IE,CNPJ,NR_FONE,NR_FAX,CEP) ' + sLineBreak +
                          ' VALUES (:CD_ADMINISTRADORA,  :NM_ADMINISTRADORA,  :PC_COBRANCA,  :DIAS_PAGAMENTO,  :DT_ATZ,  :END_NUMERO,  :END_COMPLEMENTO,  :ENDERECO,  :BAIRRO,  :CD_CIDADE,  :IE,  :CNPJ,  :NR_FONE,  :NR_FAX,  :CEP )';


          qry.paramByName('CD_ADMINISTRADORA').Asinteger    := cdAdministradora;
          qry.paramByName('NM_ADMINISTRADORA').AsString     := vNomeAdministradora;
          qry.paramByName('PC_COBRANCA').Ascurrency         := 0;
          qry.paramByName('DIAS_PAGAMENTO').Asinteger       := 0;
          qry.paramByName('DT_ATZ').AsDateTime              := now;
          qry.paramByName('END_NUMERO').Asstring            := '';
          qry.paramByName('END_COMPLEMENTO').Asstring       := '';
          qry.paramByName('ENDERECO').Asstring              := '';
          qry.paramByName('BAIRRO').Asstring                := '';
          qry.paramByName('CD_CIDADE').Asinteger            := 1;
          qry.paramByName('IE').Asstring                    := '';
          qry.paramByName('CNPJ').Asstring                  := '';
          qry.paramByName('NR_FONE').Asstring               := '';
          qry.paramByName('NR_FAX').Asstring                := '';
          qry.paramByName('CEP').Asstring                   := '';
          qry.ExecSQL;
        end;

      finally
        qry.Free;
        result := cdAdministradora;
      end;
end;

function TBaseController.fBuscarBandeira (vNomeBandeira: String; vIdAdministradora :integer) : integer;
function fAchaMaxId : integer;
  var
    qryMax :TFDQuery;
  begin

    try
      qryMax := TFDQuery.Create(nil);
      qryMax.Connection := FDConexao;
      qryMax.Active := false;
      qryMax.SQL.Clear;
      qryMax.SQL.text := 'SELECT MAX(CD_BANDEIRA) as CD_BANDEIRA FROM BANDEIRA';


      qryMax.Active := true;
      if not qryMax.FieldByName('CD_BANDEIRA').IsNull then
         result :=  qryMax.FieldByName('CD_BANDEIRA').AsInteger + 1;

    finally
      qryMax.free;
    end;
  end;
var
  qry :TFDQuery;
  cdBandeira : integer;
begin
    cdBandeira := 0;
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := FDConexao;
      qry.Active := false;
      qry.SQL.Clear;
      qry.SQL.text := 'SELECT FIRST 1 CD_BANDEIRA FROM BANDEIRA  WHERE UPPER(DESCRICAO) = UPPER(:DESCRICAO) ';
      qry.ParamByName('DESCRICAO').AsString := vNomeBandeira;
      qry.Active := true;

      if not qry.FieldByName('CD_BANDEIRA').IsNull then  //encontrou a BANDEIRA
      begin
        cdBandeira := qry.FieldByName('CD_BANDEIRA').AsInteger;
        exit;
      end
      else  //Insere a BANDEIRA
      begin
        cdBandeira :=  fAchaMaxId;
        qry.SQL.Clear;
        qry.SQL.Text := ' INSERT INTO BANDEIRA (CD_BANDEIRA, CD_ADMINISTRADORA, DESCRICAO) ' + sLineBreak +
                        ' VALUES (:CD_BANDEIRA, :CD_ADMINISTRADORA, :DESCRICAO)';

        qry.paramByName('CD_BANDEIRA').Asinteger           := cdBandeira;
        qry.paramByName('CD_ADMINISTRADORA').AsInteger     := vIdAdministradora;
        qry.paramByName('DESCRICAO').AsString              := vNomeBandeira;
        qry.ExecSQL;
      end;

    finally
      qry.Free;
      result := cdBandeira;
    end;
end;


function TBaseController.fBuscarDadosEmpresa: TNFCeEmpresa;
var
  empresa: TNFceEmpresa;
begin
  empresa := TNFceEmpresa.Create;
  try
    empresa.nmEmpresa := 'ERECHIM DENTALMED';
    empresa.id := 1;
    empresa.endEndereco := 'R SEVERIANO DE ALMEIDA';
    empresa.endBairro := 'CENTRO';
    empresa.endCidade := 'ERECHIM';
    empresa.endUf := 'RS';
    empresa.endCep := '99700406';
    empresa.endNumero := '184';
    empresa.endComplemento := 'SALA';
    empresa.endIbge := '4307005';
    empresa.fone := '(54) 3712-2007';
    empresa.cnpj := '33625081000174';
    empresa.ie := '0390181978';
    empresa.im := '';
    empresa.email := '';
    empresa.autCertificado := '555821072740F334';
    empresa.autIdToken := '1';
    empresa.autToken := '13FFA4E4-5A7A-4E7D-9477-2A99B212E9A3';
    empresa.autAmbiente := 'H';
  finally
    result := empresa;
  end;
end;


function TBaseController.fBuscarNumeracaoNota(vNRSERIE: Integer): integer;
var
  qryBusca : TFDQuery;
begin
  result := 1;
  try
    FWebModule.ConnSQLite.Connected := True;
    qryBusca := TFDQuery.create(nil);
    qryBusca.connection := FWebModule.ConnSQLite;

    qryBusca.Active := false;
    qryBusca.SQL.Clear;
    qryBusca.SQL.text := 'SELECT max(NR_NF) as MAIOR FROM DOCUMENTOS WHERE NR_SERIE = :NR_SERIE AND CD_MODELO = ''65''';
    qryBusca.ParamByName('NR_SERIE').AsInteger := vNRSERIE;
    qryBusca.Active := true;
    if not qryBusca.fieldByName('MAIOR').isnull then
    begin
      if qryBusca.fieldByName('MAIOR').asInteger > 0 then
      begin
        result := qryBusca.fieldByName('MAIOR').asInteger +1;
      end
      else
        result := 1;
    end;
  finally
    qryBusca.Free;
    FWebModule.ConnSQLite.Connected := False;
  end;
end;
function TBaseController.fCancelarNFSC(nrDocumento : Integer; StrXml :string): boolean;
var
  qry : TFDQuery;
  xml : integer;
  temErro :boolean;
  function fGravarXML : integer;
    var
      qryGravaXml : TFDQuery;
      idXML_Gen : integer;
    begin
      result := 0;
      //gravar o xml na tabela e pega o id do xml
      //se gravou com sucesso resulta o id xml;
      try
        qryGravaXml := TFDQuery.Create(nil);
        qryGravaXml.Connection := FDConexao;
        qryGravaXml.Active := false;
        qryGravaXml.SQL.Clear;
        qryGravaXml.SQL.text := 'SELECT FIRST 1 GEN_ID(GEN_XML_ID,1) as ID FROM FILIAL';
        qryGravaXml.Active := true;
        if not qryGravaXml.IsEmpty then
        begin
          idxml_gen  := qryGravaXml.FieldByName('ID').AsInteger;
          if idxml_gen > 0 then
          begin
            qryGravaXml.Active := false;
            qryGravaXml.SQL.Clear;
            qryGravaXml.SQL.text := ' INSERT INTO XML (ID, XML, XML_OFFLINE, XML_ORIGINAL) ' +
                                    ' VALUES  (:ID, :XML, :XML_OFFLINE, :XML_ORIGINAL ) ';
            qryGravaXml.ParamByName('ID').AsInteger                   := idxml_gen;
            qryGravaXml.ParamByName('XML').AsBlob                     := StrXml;
            qryGravaXml.ParamByName('XML_OFFLINE').AsBlob             := StrXml;
            qryGravaXml.ParamByName('XML_ORIGINAL').AsBlob            := StrXml;
            qryGravaXml.ExecSQL;
            result := idxml_gen;
          end;
        end;

      finally
        qryGravaXml.Free
      end;
    end;

begin

  result  := false;
  temErro := false;
  xml := fGravarXML;

  if xml = 0 then
  begin
    temErro := true;
    exit;
  end;

  try
    qry := TFDQuery.Create(nil);
    qry.Connection := FDConexao;
    qry.Active := false;
    qry.SQL.Clear;

    try
      qry.SQL.text := ' UPDATE                  ' + sLineBreak +
                      '    NFSC                 ' + sLineBreak +
                      ' SET                     ' + sLineBreak +
                      '   CD_CANCELAMENTO = 99, ' + sLineBreak +
                      '   SITUACAO_NFCE = 101,  ' + sLineBreak +
                      '   STATUS = 3,           ' + sLineBreak +
                      '   ID_XML_CANCELADO=  :ID' + sLineBreak +
                      ' WHERE                   ' + sLineBreak +
                      '   NR_DOCUMENTO =  :DOCUMENTO  ';

      qry.ParamByName('ID').AsInteger           := xml;
      qry.ParamByName('DOCUMENTO').AsInteger := nrDocumento;
      qry.ExecSQL;
    except on E:Exception do
      begin
        temErro := true;
        exit;
      end;

    end;

  finally
    qry.Free;

    if not TemErro then
      result := true;
  end;


end;

function TBaseController.fCancelarNFSI(nrDocumento: Integer): boolean;
var
  qry : TFDQuery;
  temErro :boolean;
begin

  result  := false;
  temErro := false;
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := FDConexao;
    qry.Active := false;
    qry.SQL.Clear;

    try
      qry.SQL.text := ' UPDATE                      ' + sLineBreak +
                      '    NFSI                     ' + sLineBreak +
                      ' SET                         ' + sLineBreak +
                      '   CD_CANCELAMENTO = 99,     ' + sLineBreak +
                      '   STATUS = 3                ' + sLineBreak +
                      ' WHERE                       ' + sLineBreak +
                      '   NR_DOCUMENTO =  :NR_DOCUMENTO  ';

      qry.ParamByName('NR_DOCUMENTO').AsInteger := nrDocumento;
      qry.ExecSQL;
    except on E:Exception do
        temErro := true;
    end;

  finally
    qry.Free;

    if not TemErro then
      result := true;
  end;
end;

function TBaseController.fCancelarPGTO(nrDocumento: Integer): boolean;
var
  qry : TFDQuery;
  temErro :boolean;
begin
  result  := false;
  temErro := false;
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := FDConexao;
    qry.Active := false;
    qry.SQL.Clear;

    try
      qry.SQL.text := ' UPDATE                      ' + sLineBreak +
                      '    CUPOM_PGTO               ' + sLineBreak +
                      ' SET                         ' + sLineBreak +
                      '   FL_CANCELADA  = ''S''     ' + sLineBreak +
                      ' WHERE                       ' + sLineBreak +
                      '   NR_DCTO =  :NR_DOCUMENTO  ';

      qry.ParamByName('NR_DOCUMENTO').AsInteger := nrDocumento;
      qry.ExecSQL;
    except on E:Exception do
        temErro := true;
    end;

  finally
    qry.Free;

    if not TemErro then
      result := true;
  end;
end;

function TBaseController.fDadosConsistentes(const vDocumento: Integer): Boolean;
begin
  result := False;

  if fExisteRegistroBanco('NFSC', 'NR_DOCUMENTO', vDocumento.ToString) then
    if fExisteRegistroBanco('NFSI', 'NR_DOCUMENTO', vDocumento.ToString) then
      if fExisteRegistroBanco('CUPOM_PGTO', 'NR_DCTO', vDocumento.ToString) then
        result:= true;

end;

function TBaseController.fFinalizaComandoSql(idComando: string): boolean;
var
  qry : TFDQuery;
  temErro :boolean;
  ERRO : STRING;
begin
  result  := false;
  temErro := false;
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := FDConexao;

    FDConexao.StartTransaction;
    qry.Active := false;
    qry.SQL.Clear;

    try
      qry.SQL.text := ' UPDATE                                ' + sLineBreak +
                      '    COMANDOS_MOBILE                    ' + sLineBreak +
                      ' SET                                   ' + sLineBreak +
                      '   FL_EXECUTADO =  ''S''               ' + sLineBreak +
                      ' WHERE                                 ' + sLineBreak +
                      '   ID  =  :ID   ';

      qry.ParamByName('ID').AsString := idComando;
      qry.ExecSQL;
    except on E:Exception do
      begin
        temErro := true;
        ERRO := E.MESSAGE;
     end;
    end;

  finally
    qry.Free;

    if not TemErro then
    begin
      FDConexao.Commit;
      result := true;
    end
    else
      FDConexao.Rollback;
  end;
end;


function TBaseController.fFinalizaContagem(ecf: Integer): boolean;
var
  qry : TFDQuery;
  temErro :boolean;
begin
  result  := false;
  temErro := false;
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := FDConexao;

    FDConexao.StartTransaction;
    qry.Active := false;
    qry.SQL.Clear;

    try
      qry.SQL.text := ' UPDATE                      ' + sLineBreak +
                      '    CONTAGEM_MOBILE_C        ' + sLineBreak +
                      ' SET                         ' + sLineBreak +
                      '   STATUS = 2                ' + sLineBreak +
                      ' WHERE                       ' + sLineBreak +
                      '   NR_ECF =  :NR_ECF         ' + sLineBreak +
                      ' AND                         ' + sLineBreak +
                      '   STATUS = 1 '  ;

      qry.ParamByName('NR_ECF').AsInteger := ecf;
      qry.ExecSQL;
    except on E:Exception do
        temErro := true;
    end;

  finally
    qry.Free;

    if not TemErro then
    begin
      FDConexao.Commit;
      result := true;
    end
    else
      FDConexao.Rollback;
  end;
end;


function TBaseController.fGravarVersao(vDispositivo, vCodigoVersao,  vIdentificador: String): boolean;
 var
    qryGravaVersao : TFDQuery;
 begin
    result := true;
    try
      qryGravaVersao := TFDQuery.Create(nil);
      qryGravaVersao.Connection := FDConexao;
      qryGravaVersao.Active := false;
      qryGravaVersao.SQL.Clear;
      qryGravaVersao.SQL.Text := 'UPDATE CONFIG_MOBILE SET VERSAO_SISTEMA = :VERSAO_SISTEMA, IDENTIFICADOR = :IDENTIFICADOR WHERE UPPER(ID_DISPOSITIVO) = UPPER(:ID_DISPOSITIVO)';
      qryGravaVersao.ParamByName('VERSAO_SISTEMA').AsString := vCodigoVersao;
      qryGravaVersao.ParamByName('ID_DISPOSITIVO').AsString := vDispositivo;
      qryGravaVersao.ParamByName('IDENTIFICADOR').AsString := vIdentificador;
      qryGravaVersao.ExecSQL;
    finally
      qryGravaVersao.Free;
    end;
end;



function TBaseController.fInserirContagemCabecalho(ecf, usuario: Integer;
  nm_deposito: string): boolean;
var
  qryContagem : TFDQuery;
  temErro : Boolean;
begin

  try
    temErro := false;
    result  := false;
    qryContagem := tfdQuery.create(nil);
    qryContagem.connection := FDConexao;
    FDConexao.startTransaction;

    try
      qryContagem.SQL.Clear;
      qryContagem.active := false;
      qryContagem.sql.TExt := ' UPDATE CONTAGEM_MOBILE_C SET STATUS = 2 WHERE NR_ECF = :NR_ECF AND STATUS = 1 ';
      qryContagem.ParamByName('NR_ECF').asInteger :=ecf;
      qryContagem.ExecSQL;
    Except on E:Exception do
      TemErro := true;
    end;

    try
      qryContagem.SQL.Clear;
      qryContagem.active := false;
      qryContagem.SQL.Text :=
      ' INSERT INTO CONTAGEM_MOBILE_C (NR_ECF, STATUS, NM_DEPOSITO, DATA, CD_USUARIO ) ' +
      ' VALUES  (:NR_ECF, :STATUS, :NM_DEPOSITO, :DATA, :CD_USUARIO) ';

      qryContagem.paramByName('NR_ECF').asInteger        := ecf;
      qryContagem.paramByName('STATUS').asInteger        := 1;
      qryContagem.paramByName('NM_DEPOSITO').asString    := nm_deposito;
      qryContagem.paramByName('DATA').AsDateTime         := now;
      qryContagem.paramByName('CD_USUARIO').asInteger := usuario;
      qryContagem.ExecSQL;


    Except on E:Exception do
      TemErro := true;
    end;



  finally
    if not temErro then
    begin
      FDConexao.commit;
      result := true;
    end
    else
      FDConexao.rollback;


  end;
end;

function TBaseController.fRecebeuCarga(aDispositivo: String): Boolean;
var
  qryAux : TfdQuery;
begin
  result := False;
  try
    qryAux := TfdQuery.Create(nil);
    qryAux.Connection := FdConexao;
    qryAux.Sql.text :=  ' UPDATE                  ' + sLineBreak +
                      '    CONFIG_MOBILE        ' + sLineBreak +
                      ' SET                     ' + sLineBreak +
                      '   RECEBE_CARGA = ''N''  ' + sLineBreak +
                      ' WHERE                   ' + sLineBreak +
                      '   UPPER(ID_DISPOSITIVO) =  UPPER(' + QuotedStr(aDispositivo) + ')';
    qryAux.ExecSql;
    Result := True;
  finally
    qryAux.Free;
  end;
end;



function TBaseController.fExisteNota(const IdDisp, Cancelado, Serie, nrNota: Integer; const Cnpj: String): String;
var
  qryCnsServer : TfdQuery;
begin
  try
    try
      qryCnsServer := TFDQuery.Create(nil);
      qryCnsServer.connection := FWebModule.ConnSQLite;
      qryCnsServer.Sql.Text := 'SELECT ' +
                               '   XML_RETORNO ' +
                               'FROM ' +
                               '   DOCUMENTOS ' +
                               ' WHERE '+
                               '   CNPJ = :CNPJ AND ' +
                               '   ID_DISP = :ID_DISP AND ' +
                               '   SERIE = :SERIE AND ' +
                               '   NR_NOTA = :NR_NOTA AND ' +
                               '   CANCELADO = :CANCELADO ';

      qryCnsServer.ParamByName('CNPJ').AsString := cnpj;
      qryCnsServer.ParamByName('ID_DISP').AsInteger := idDisp;
      qryCnsServer.ParamByName('SERIE').AsInteger := Serie;
      qryCnsServer.ParamByName('NR_NOTA').AsInteger := nrNota;
      qryCnsServer.ParamByName('CANCELADO').AsInteger := cancelado;
      qryCnsServer.Open;

      if not qryCnsServer.FieldByName('XML_RETORNO').isNull then
        result := qryCnsServer.FieldByName('XML_RETORNO').AsString
      else
        result := '';
    except on E: Exception do
      begin
        raise Exception.Create('Erro ao consultar nota no server.');
        exit;
      end;
    end;
  finally
    qryCnsServer.Free;
    FWebModule.ConnSQLite.Connected := False;
  end;
end;

procedure TBaseController.OnAfterAction(Context: TWebContext;
  const AActionName: string);
begin
  FDConexao.Free;
  inherited;
end;

procedure TBaseController.OnBeforeAction(Context: TWebContext;
  const AActionName: string; var Handled: Boolean);
begin
  if not Assigned(FWebModule) then
    FWebModule := GetCurrentWebModule as TNFCEWebModule;

  if not Assigned(FDConexao) then
    FDConexao := TFDConnection.Create(nil);

   FDConexao.ConnectionDefName := CONEXAO_PG;

  inherited;
end;

function TBaseController.fBuscarMaxCodCliente : integer;
var
  qryAux: TFDQuery;
begin
  try
    result := 0;
    qryAux := TFDQuery.Create(nil);
    qryAux.connection := FDConexao;

    qryAux.SQL.Text := 'SELECT MAX(CD_CLIENTE) FROM CLIENTE';
    try
      qryAux.Open();
    Except on e:exception do
      begin
        writeln(e.Message);
      end;

    end;
    result := qryAux.FieldByName('MAX').AsInteger + 1;
  finally
    qryAux.Free;
  end;
end;

procedure TBaseController.pApagarRegistrosCupom(const documento: integer);
var
  qryDelete: TFDQuery;
  qryConsulta: TFDQuery;
  chaveXML, chaveTEF: Integer;
  dimiTemp :string;
begin
  try

    qryConsulta := tfdQuery.create(nil);
    qryConsulta.Connection := FDConexao;
    qryConsulta.Active := false;

    qryDelete := tfdQuery.create(nil);
    qryDelete.Connection := FDConexao;
    qryDelete.Active := false;

    qryConsulta.SQL.Clear;
    qryConsulta.SQL.text :=

      '  	SELECT  '+
      '          NFSC.NR_DOCUMENTO,  '+
      '          COALESCE(NFSC.ID_XML,0) AS ID_XML , '+
      '          COALESCE(CUPOM_PGTO.NR_TRANSACAO,0) as  ID_TEF'+
      '      FROM  '+
      '          NFSC  '+
      '            left JOIN CUPOM_PGTO ON NFSC.NR_DOCUMENTO = CUPOM_PGTO.NR_DCTO  '+
      '      WHERE  '+
      '          NFSC.NR_DOCUMENTO =  '+ documento.ToString;

    qryConsulta.Open;

    if not qryConsulta.IsEmpty then
    begin
      chaveXML := qryConsulta.FieldByName('ID_XML').AsInteger;
      chaveTEF := qryConsulta.FieldByName('ID_TEF').AsInteger;

      try

        qryDelete.SQL.Clear;
        qryDelete.SQL.text := 'DELETE FROM TEF_MOVIMENTACAO WHERE ID = '+ documento.ToString;
        qryDelete.ExecSQL;


        qryDelete.SQL.Clear;
        qryDelete.SQL.text := 'DELETE FROM CRPTITULO WHERE NR_DOCUMENTO = '+ documento.ToString;
        qryDelete.ExecSQL;


        qryDelete.SQL.Clear;
        qryDelete.SQL.text := 'DELETE FROM NFSI WHERE NR_DOCUMENTO = '+ documento.ToString;
        qryDelete.ExecSQL;

        qryDelete.SQL.Clear;
        qryDelete.SQL.text := 'DELETE FROM CUPOM_PGTO WHERE NR_DCTO = '+ documento.ToString;
        qryDelete.ExecSQL;

        qryDelete.SQL.Clear;
        qryDelete.SQL.text := 'DELETE FROM NFSC WHERE NR_DOCUMENTO = '+ documento.ToString;
        qryDelete.ExecSQL;


        qryDelete.SQL.Clear;
        qryDelete.SQL.text := 'DELETE FROM XML WHERE ID = '+ chaveXML.ToString;
        qryDelete.ExecSQL;


      except on e:exception do
        dimiTemp:= e.Message;


      end;
    end;
  finally
    qryDelete.Free;
    qryConsulta.Free;
  end;
end;

end.
