#ifndef COMM_H_
#define COMM_H_

#define DLL_EXPORT __declspec(dllimport)

/**
  * @name  Base64ToAscii
  * @brief Decodifica retornos BASE64 das funções EnviarDadosVenda e CancelarUltimaVenda
  * @param nenhum
  * @return string decodificada em ASCII
  */
DLL_EXPORT char *__stdcall Base64ToAscii(void);

/**
  * @name  GetMapaPortasSAT
  * @brief Lista todos as portas que possuem SATs conectados
  * @param nenhum
  * @return string com a lista de portas separados por ;
  */

DLL_EXPORT char *__stdcall GetMapaPortasSAT(void);

/**
  * @name  GetPortaSAT
  * @brief Consulta a porta serial utilizada pelo SAT
  * @param nenhum
  * @return string com nome da porta
  */
DLL_EXPORT char *__stdcall GetPortaSAT(void);

/**
  * @name  SetPortaSAT
  * @brief Define a porta serial utilizada pelo SAT
  * @param porta
  * @return -1 : erro, 0 : sucesso
  */

DLL_EXPORT int __stdcall SetPortaSAT(char *porta);

/**
  * @name  GeraNumeroSessao
  * @brief Gera o numero de sessao para o AC
  * @param nenhum
  * @return inteiro de 6 digitos
  */

DLL_EXPORT int __stdcall GeraNumeroSessao(void);

/**
  * @name VersaoLib
  * @brief retorna o numero da versao e data de geracao da lib
  * @param nenhum
  * @return string com versao da lib
  */

DLL_EXPORT char *__stdcall VersaoLib(void);

/**
  * @name TrocarCodigoDeAtivacaoSAT
  * @brief O Aplicativo Comercial ou outro software fornecido pelo Fabricante
  * @brief poderá realizar a troca do código de ativação a qualquer momento
  * @param numeroSessao
  * @param CodigoAtivacao
  * @param opcao
  * @param novoCodigo
  * @param confNovoCodigo
  * @return pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall TrocarCodigoDeAtivacao(int nSessao, char *CodigoAtivacao, int opcao, char *novoCodigo,
                                   char *confNovoCodigo);
/**
 * @name AtivarSAT
 * @brief Metodo para ativar o uso do SAT
 * @param subComando
 * @param codigoDeAtivacao
 * @param CNPJ
 * @param cUF
 * @return CSR
 */

DLL_EXPORT char *__stdcall AtivarSAT(int nSessao, int subComando, char *codigoDeAtivacao, char *CNPJ, int cUF);

/**
  * @name EnviaDadosVenda
  * @brief Responsavel pelo comando de envio de dados de vendas
  * @param codigoDeAtivacao
  * @param numeroSessao
  * @param dadosVenda
  * @return pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall EnviarDadosVenda(int nSessao, char *codigoDeAtivacao, char *dadosVenda);

/**
 * @name CanclearUltimaVenda
 * @brief cancela o ultimo cupom fiscal
 * @param codigoDeAtivacao
 * @param chave
 * @param dadosCancelamento
 * @return pointer para area com retorno do comando enviado pelo dispositivo SAT
 */

DLL_EXPORT char *__stdcall CancelarUltimaVenda(int nSessao, char *codigoDeAtivacao, char *chave, char *dadosCancelamento);

/**
  * @name ConsultarSAT
  * @brief consultar SAT
  * @param numeroSessao
  * @return pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall ConsultarSAT(int numeroSessao);

/**
  *  @name TesteFimAFim
  *  @brief Esta função consiste em um teste de comunicação entre o AC, o Equipamento SAT e a SEFAZ
  *  @param numeroSessao
  *  @param codigoAtivacao
  *  @param dadosVenda
  *  @return pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall TesteFimAFim(int nSessao, char *codigoDeAtivacao, char *dadosVenda);

/**
  *  @name  ConsultarStatusOperacional
  *  @brief Essa função é responsável por verificar a situação de funcionamento do Equipamento SAT
  *  @param numeroSessao
  *  @param codigoAtivacao
  *  @return pointer para area com retorno do comando enviado pelo dispositivo SAT
  *
  */

DLL_EXPORT char *__stdcall ConsultarStatusOperacional(int nSessao, char *codigoDeAtivacao);

/**
  * @name ConsultarNumeroSessao
  * @brief O AC poderá verificar se a última sessão requisitada foi processada em caso de não
  * @brief recebimento do retorno da operação. O equipamento SAT-CF-e retornará exatamente o resultado da
  * @brief sessão consultada
  * @return pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall ConsultarNumeroSessao(int nSessao, char *CodAtivacao, int numeroSessao);

/**
  * @name ConsultarNumeroSessao
  * @brief O AC poderá verificar se a última sessão fiscal requisitada foi processada em caso de não
  * @brief recebimento do retorno da operação. O equipamento SAT-CF-e retornará exatamente o resultado da
  * @brief sessão consultada
  * @return pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall ConsultarUltimaSessaoFiscal(int sessao, char *codigoDeAtivacao);

/**
  * @name  ConfigurarInterfaceDeRede
  * @brief Responsavel pela configuracao da interface de rede do SAT (Ver espec:2.6.10)
  * @param numeroSessao
  * @param codigoDeAtivacao
  * @param dadosVenda
  * @return pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall ConfigurarInterfaceDeRede(int nSessao, char *codigoDeAtivacao, char *DadosConfiguracao);

/**
  * @name AssociarAssinatura
  * @brief Responsavel pelo comando de associar o AC ao SAT
  * @param numeroSessao
  * @param CodigoAtivacao
  * @param CNPJ
  * @param assinaturaCNPJs
  * @return pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall AssociarAssinatura(int nSessao, char *codativacao, char *CNPJvalue, char *assinaturaCNPJs);

/**
  * @name AtualizarSoftwateSAT
  * @brief O Contribuinte utilizará a função AtualizarSoftwareSAT para a atualização imediata do
  * @brief software básico do Equipamento SAT
  * @param numeroSessao
  * @param codigoAtivacao
  * @return pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall AtualizarSoftwareSAT(int nSessao, char *CodigoAtivacao);

/**
  * @name ExtrairLogs
  * @brief O Aplicativo Comercial poderá extrair os arquivos de registro do
  * @brief Equipamento SAT por meio da função ExtrairLogs
  * @param numeroSessao
  * @param codigoAtivacao
  * @return  pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall ExtrairLogs(int nSessao, char *CodigoAtivacao);

/**
  * @name BloquearSAT
  * @brief O Aplicativo Comercial ou outro software fornecido pelo Fabricante poderá
  * @brief realizar o bloqueio operacional do Equipamento SAT
  * @return  pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall BloquearSAT(int nSessao, char *CodigoAtivacao);

/**
  * @name DesbloquearSAT
  * @brief O Aplicativo Comercial ou outro software fornecido pelo
  * @brief Fabricante poderá realizar o desbloqueio operacional do Equipamento SAT
  * @param numeroSessao
  * @param codigoAtivacao
  * @return pointer para area com retorno do comando enviado pelo dispositivo SAT
  */

DLL_EXPORT char *__stdcall DesbloquearSAT(int nSessao, char *CodigoAtivacao);

/**
+  * @name  ComunicarCertificadoICPBRASIL
+  * @brief Comunica o certificado icp Brasil
+  * @param numeroSessao
+  * @param codigoDeAtivacao
+  * @param Certificado
+  * @return pointer para area com retorno do comando enviado pelo dispositivo SAT
+  **/

DLL_EXPORT char *__stdcall ComunicarCertificadoICPBRASIL(int nSessao, char *codigoDeAtivacao, char *Certificado);

#endif /* COMM_H_ */
