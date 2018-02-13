#!/bin/bash

###############################################################################
# AUTOR   : Viniciusalopes                                                    #
# DATA    : 07/02/2018                                                        #
# OBJETIVO: Criar novo projeto Kdenlive a partir de um modelo                 #
# VERSÃO  : 0.1                                                               #
###############################################################################

###############################################################################
# VARIÁVEIS PARA OS ARQUIVOS                                                  #
###############################################################################

# Ícone das caixas de diálogo
window_icon="/home/vinicius/Projetos/Video/imagens/icone-janela-100px.png"

# Texto para substitução da / nos arquivos
b="_BARRA_"

# Caminho do TEMPLATE + nome do arquivo.kdenlive
TEMPLATE=""

# Caminho do TEMPLATE
TEMPLATE_ROOT=""

# ID do TEMPLATE
TEMPLATE_ID=""

# Caminho do NOVO PROJETO + nome do arquivo.kdenlive
NOVO=""

# Caminho do NOVO PROJETO
NOVO_ROOT=""

# Nome do arquivo do NOVO PROJETO
NOVO_NOME=""

# ID do NOVO PROJETO
NOVO_ID=""

###############################################################################
# VARIÁVEIS PARA CAIXAS DE DIÁLOGOS                                           #
###############################################################################

iniciar_titulo="Clone de Template do Kdenlive V0.1 | Viniciusalopes Tecnologia"
iniciar_texto="<b>OPA! Belesma?</b>\n\n\
O <b>Kdenlive</b> é um software poderosíssimo para produção de vídeos para as \
mais variadas finalidades.\nVisto que não encontrei uma solução para o <b>gere\
nciamento de templates</b> que fosse automatizada\ndentro do próprio Kdenlive,\
 desenvolvi este <b>script bash</b> somente com programas para <b>GNU/Linux</b\
>.\n\nEste script clona <b>automaGicamente</b> um projeto do Kdenlive, em ambi\
ente gráfico, sem a necessidade\nde manipular arquivos.\n\nO <b>resultado</b> \
é o aproveitamento de cofigurações, arquivos e bibliotecas, integridade das re\
ferências\ndos projetos e ganho de <b>produtividade</b>."
iniciar_ok="Iniciar"
iniciar_cancel="Sair"

abrir_titulo="Clonagem concluída!"
abrir_texto="Deseja abrir o projeto "
abrir_ok="Sim"
abrir_cancel="Não"

arquivo_titulo="Nome do Projeto"
arquivo_texto="Digite um nome para o NOVO projeto: "

confirmar_titulo="Confirma a clonagem?"
confirmar_texto="Confirma a clonagem do TEMPLATE para o NOVO PROJETO?"
confirmar_ok="Sim"
confirmar_cancel="Não"

fim_titulo="Viniciusalopes Tecnologia"
fim_texto="Compartilhe seu <b>conhecimento</b> e seja <b>LIVRE!</b>\n\
(<i>Vinicius A. Lopes</i>)\n\n\
youtube.com/user/viniciusalopesGO\n\
www.viniciusalopes.com.br"

# MENSAGENS DE ERRO
erro_titulo="Opa!"
erro_arquivo_texto="Você não selecionou nenhum arquivo!"
erro_local_texto="Você não selecionou nenhum local!"
erro_nome_texto="O nome digitado é inválido, ou a operação foi Cancelada!"
erro_selecao_texto="Ocorreu um erro."
erro_diretorio_texto="Já existe uma pasta com o mesmo nome do NOVO PROJETO!"
encerrado="O script será encerrado."

###############################################################################
# FUNÇÕES DE CAIXAS DE DIÁLOGO                                                #
###############################################################################

# Exibe a mensagem final
function cx_dialogo_informa_fim(){

    # Exibe a caixa de diálogo de informação final
    zenity --info \
        --no-wrap \
        --window-icon=$window_icon \
        --title="$fim_titulo" \
        --text="$fim_texto"
}

# Exibe uma pergunta
function cx_dialogo_pergunta(){
    
    # Seleciona o Título e o Texto
    case $1 in
        "iniciar")
            titulo=$iniciar_titulo
            texto=$iniciar_texto
            lb_ok=$iniciar_ok
            lb_cancel=$iniciar_cancel
            ;;

        "confirmar")
            txt_template="<b>TEMPLATE:</b> $TEMPLATE\n(ID: $TEMPLATE_ID)"            
            txt_novo="<b>NOVO PROJETO:</b> $NOVO\n(ID: $NOVO_ID)"

            titulo=$confirmar_titulo
            texto="$txt_template\n\n$txt_novo\n\n$confirmar_texto"
            lb_ok=$confirmar_ok
            lb_cancel=$confirmar_cancel
            ;;
        
        "abrir")
            titulo=$abrir_titulo
            texto="$abrir_texto$NOVO_NOME agora?"
            lb_ok=$abrir_ok
            lb_cancel=$abrir_cancel
            ;;
    esac

    # Exibe a caixa de diálogo
    zenity --question \
        --no-wrap \
        --window-icon=$window_icon \
        --title="$titulo" \
        --text="$texto" \
        --ok-label="$lb_ok" \
        --cancel-label="$lb_cancel"
}

# Exibe uma caixa de diálogo para pesquisa de arquivos .kdenlive
function cx_dialogo_pesquisa_arquivo(){
    
    # Exibe a caixa de diálogo
    zenity --file-selection \
        --window-icon=$window_icon \
        --title="Selecione o TEMPLATE" \
        --file-filter="*.kdenlive"
}

# Exibe uma caixa de diálogo para digitar o nome do arquivo
function cx_dialogo_nome_do_arquivo(){

    # Exibe a caixa de diálogo
    zenity --entry \
        --window-icon=$window_icon \
        --title="$arquivo_titulo" \
        --text "$arquivo_texto"
}

# Exibe uma caixa de diálogo para pesquisa de diretórios
function cx_dialogo_pesquisa_diretorio(){
    
    # Exibe a caixa de diálogo
    zenity --file-selection \
        --window-icon=$window_icon \
        --title="Selecione o local do NOVO PROJETO" \
        --directory
}

# Exibe uma mensagem de erro
function cx_dialogo_erro(){

    # Seleciona o texto da mensagem
    case $1 in
        "nenhum-arquivo")
            texto=$erro_arquivo_texto
            ;;
        
        "nenhum-local")
            texto=$erro_local_texto
            ;;
        
        "nenhum-nome")
            texto=$erro_nome_texto
            ;;
        
        "selecao")
            texto=$erro_selecao_texto
            ;;
        
        "diretorio-ja-existe")
            texto=$erro_diretorio_texto
            ;;
            
    esac

    # Concatena o texto selecionado com a mensagem de encerramento
    texto="$texto\n\n$encerrado"

    # Exibe a caixa de diálogo
    zenity --error \
        --no-wrap \
        --window-icon=$window_icon \
        --title="$erro_titulo" \
        --text="$texto"
    sair
}

###############################################################################
# FUNÇÕES DO SCRIPT                                                           #
###############################################################################

# Seta os dados dos projetos
function set_dados(){

    # Obtém o ROOT do TEMPLATE
    TEMPLATE_ROOT=`cat "$TEMPLATE" | grep "<mlt title" | cut -d'"' -f6`
        
    #Obtém o ID do TEMPLATE
    TEMPLATE_ID=`cat "$TEMPLATE" | grep "documentid" | cut -d'>' -f2 | cut -d'<' -f1`
    
    # Define o caminho completo do NOVO PROJETO
    NOVO=`echo "$NOVO_ROOT/$NOVO_NOME.kdenlive"`
        
    # Obtém a quantidade de segundos desde 1970-01-01 00:00:00 UTC
    segundos=`date +%s`
    
    # Obtém um numero aleatório > 100, com a variável $RANDOM do sistema
    num=$(($RANDOM+99))
    
    # Gera o NOVO_ID, com os segundos UTC + 3 dígitos do numero aleatório
    NOVO_ID="$segundos${num:0:3}"
}
# Clona o TEMPLATE para o NOVO PROJETO
function clonar(){

    # Cria a pasta do NOVO PROJETO
    mkdir "$NOVO_ROOT"

    # Entra na pasta do NOVO PROJETO
    cd "$NOVO_ROOT"
        
    ## Cria variáveis temporárias para os ROOTs
    tmp_template_root=`echo $TEMPLATE_ROOT | sed "s/\//$b/g"`
    tmp_novo_root=`echo $NOVO_ROOT | sed "s/\//$b/g"`

    # Clona o conteúdo do TEMPLATE para o arquivo do NOVO PROJETO
    cat "$TEMPLATE" \
         | sed "s/\//$b/g" \
         | sed "s/$tmp_template_root/$tmp_novo_root/g" \
         | sed "s/$TEMPLATE_ID/$NOVO_ID/g" \
         | sed "s/$b/\//g" > "$NOVO_NOME.kdenlive"
         
    # Cria as pastas do NOVO PROJETO, se existir a tag 'storagefolder'
    if [ ! `cat "$NOVO" | grep -c "docproperties.storagefolder"` == 0 ]
    then
        mkdir "proxy"
        mkdir "$NOVO_ID"
        mkdir "$NOVO_ID/audiothumbs"
        mkdir "$NOVO_ID/preview"
        mkdir "$NOVO_ID/videothumbs"
    fi
}



###############################################################################
# FUNÇÕES DO FLUXO DE EXECUÇÃO DO SCRIPT                                      #
###############################################################################

# Tela Inicial
function iniciar(){
    if cx_dialogo_pergunta iniciar
    then
        seleciona_template
    else
        sair
    fi 
}

# Seleciona o caminho do template
function seleciona_template(){
    TEMPLATE=$(cx_dialogo_pesquisa_arquivo)
    
    # Testa o retorno da caixa de diálogo de pesquisa de arquivo
    case $? in
        0)
            cx_dialogo_solicita_nome
            ;;
        
        1)
            cx_dialogo_erro nenhum-arquivo
            ;;
        
        -1)
            cx_dialogo_erro selecao
            ;;
    esac
}

function cx_dialogo_solicita_nome(){
    NOVO_NOME=$(cx_dialogo_nome_do_arquivo arquivo)
    # -z == Testa se a string do retorno da caixa de texto é vazia
    if [ -z "$NOVO_NOME" ]
    then
        cx_dialogo_erro nenhum-nome
    else
        cx_dialogo_seleciona_novo
    fi
}

# Seleciona o caminho do novo projeto
function cx_dialogo_seleciona_novo(){
    NOVO_ROOT=$(cx_dialogo_pesquisa_diretorio)/$NOVO_NOME

    # Testa o retorno da caixa de diálogo de pesquisa de diretório
    case $? in
        0)
            verifica
            ;;
        
        1)
            cx_dialogo_erro nenhum-local
            ;;
        
        -1)
            cx_dialogo_erro selecao
            ;;
    esac
}

# Valida os arquivos selecionados
function verifica(){

    # Verifica se a pasta do projeto já existe

    if [ -e "$NOVO_ROOT" ]
    then
        cx_dialogo_erro diretorio-ja-existe
    else
        set_dados
        confirmacao
    fi
    
}

# Confirma a clonagem do NOVO PROJETO
function confirmacao(){

    # Solicita confirmação para clonar o TEMPLATE
    if cx_dialogo_pergunta confirmar
    then
        clonar
        
        # Solicita confirmação para abrir o NOVO PROJETO
        if cx_dialogo_pergunta abrir
        then
            abrir
        else
            sair
        fi 
    else
        sair
    fi
    
}

# Abre o NOVO PROJETO recém clonado
function abrir(){
    cx_dialogo_informa_fim
    kdenlive "$NOVO" && exit
}

# Encerra a execução do script
function sair(){
    cx_dialogo_informa_fim
    exit
}

# Inicia o script
iniciar
