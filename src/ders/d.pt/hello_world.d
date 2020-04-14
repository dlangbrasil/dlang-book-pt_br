Ddoc

$(DIV_CLASS page_one,

$(DERS_BOLUMU $(IX hello world) O Programa Hello World)

$(P
O primeiro programa a ser exibido na maioria dos livros de linguagem de programação é o programa $(I hello world). Este programa muito curto e simples apenas escreve "hello world" e termina. Este programa é importante porque inclui alguns dos conceitos essenciais dessa linguagem.
)

$(P
Aqui está um programa $(I hello world) em D:
)

---
import std.stdio;

void main() {
    writeln("Hello world!");
}
---

$(P
O $(I código fonte) acima precisa ser compilado por um compilador D para produzir um programa executável.
)

$(H5 $(IX instalação do compilador) $(IX instalação, compilador) Instalação do Compilador)

$(P
$(IX gdc) $(IX ldc) No momento em que escrevo este capítulo, existem três compiladores D para escolher: $(C dmd), o compilador da Digital Mars; $(C gdc), o compilador D do GCC; e $(C ldc), o compilador D para a infraestrutura de compilador LLVM.
)

$(P
$(IX dmd) $(C dmd) é o compilador D que tem sido usado durante o design e desenvolvimento da linguagem ao longo dos anos. Todos os exemplos deste livro foram testados com $(C dmd). Por essa razão, seria mais fácil iniciar com $(C dmd) e tentar outros compiladores somente se você precisar. Os códigos de exemplos deste livor foram compilados com $(C dmd) versão $(DVER).
)

$(P
Para instalar a versão mais recente do $(C dmd), vá para a $(LINK2 http://www.dlang.org/download.html, página de download na Digital Mars) e selecione o compilador que corresponda ao seu ambiente de computador. Você deve selecionar o build de acordo com o seu sistema operacional e sistema de gerencimento de pacotes, e se possui uma CPU e um sistema operacional de 32 ou 64 bits. Não instale um compilador D1. Este livro aborda somente $(I D versão dois).
)

$(P
Os etapas de instalação são diferentes em ambientes diferentes, mas devem ser tão fáceis quanto seguir as instruções na tela e clicar em alguns botões.
)

$(H5 $(IX source file) Arquivo Fonte)

$(P
O arquivo que o programador escreve para o compilador D compilar é chamado de $(I arquivo fonte). Como D é geralmente usado como uma linguagem compilada, o arquivo fonte em sí não é um programa executável. O arquivo fonte deve ser convertido para um programa executável pelo compilador.
)

$(P
Como em qualquer arquivo, o arquivo fonte deve ter um nome. Embora o nome possa ser qualquer um que for permitido no sistema de arquivos, é comum usar a $(I extensão de arquivo) $(C .d) para os arquivos fontes D, porque ambientes de desenvolvimento, ferramentas de programação e programadores esperam que esse seja o caso. Por exemplo, $(C test.d), $(C game.d), $(C invoice.d), etc. são nomes de arquivos fontes D apropriados.
)

$(H5 Compilando o programa hello world)

$(P
$(IX editor de texto) $(IX editor, texto) Você irá escrever o arquivo fonte em um $(LINK2 http://wiki.dlang.org/Editors, editor de texto) (ou em uma $(I IDE) como mencionada abaixo). Copie ou digite o programa hello world acima em um arquivo de texto a salve-o com o nome $(C hello.d).
)

$(P
O compilador irá préviamente verificar se a sintaxe desse código fonte está correta (ou seja, é válida de acordo com as regras da linguagem) e criará um programa traduzindo-o em código de máquina. Siga estas etapas para compilar o programa:
)

$(OL

$(LI Abra uma janela do terminal.)

$(LI Vá para o diretório em que você salvou $(C hello.d).)

$(LI Digite o seguinte comando. (Não digite o caractere $(C $); ele está ali para indicar o prompt na linha de comando.))

)

$(SHELL
$(SHELL_OBSERVED $) dmd hello.d
)

$(P
Se você não cometeu nenhum erro, pode pensar que nada aconteceu. Ao contrário, significa que tudo correu bem. Deve haver um arquivo executável chamado $ (C hello) (ou $ (C hello.exe) no Windows) que acabou de ser criado pelo compilador.
)

$(P
Se o compilador imprimiu algumas mensagems, você provavelmente cometeu algum erro ao copiar o código do programa. Tente identificar o erro, corrija-o e tente compilar novamente. Você rotineiramente cometerá muitos erros ao programar, portanto o processo de corregir e compilar se tornará familiar para você.
)

$(P
Uma vez que o programa foi criado com sucesso, digite o nome do programa executável para executá-lo. Você deve ver que o programa imprime "Hello world!":
)

$(SHELL
$(SHELL_OBSERVED $) ./hello     $(SHELL_NOTE executando o programa)
Hello world!  $(SHELL_NOTE a mensagem que ele imprime)
)

$(P
Parabéns! Seu primeiro programa em D funciona como esperado.
)

$(H5 $(IX opções do compilador) Opções do Compilador)

$(P
O compilador possui muitas opções de linha de comando que são usadas para influenciar a maneira como compila o programa. Para ver uma lista de opções do compilador, digite apenas o nome do compilador:
)

$(SHELL
$(SHELL_OBSERVED $) dmd    $(SHELL_NOTE digite apenas o nome)
DMD64 D Compiler v$(DVER)
...
  -de            show use of deprecated features as errors (halt compilation)
...
  -unittest      compile in unit tests
...
  -w             warnings as errors (compilation will halt)
...
)

$(P
A saída abreviada acima mostra apenas as opções de linha de comando que eu recomendo que você sempre use. Embora isso não faça diferença com o programa hello world neste caítulo, a linha de comando seguinte iria compilar o programa, habilitando testes de unidade e não iria permitir nenhum aviso ou recursos obsoletos. Veremos essas e outras opções em mais detalhe nos próximos capítulos:
)

$(SHELL
$(SHELL_OBSERVED $) dmd hello.d -de -w -unittest
)

$(P
A lista completa das opções de linha de commando do $(C dmd) pode ser encontrada no $(LINK2 http://dlang.org/dmd-linux.html, Documentação do Coompilador DMD).
)

$(P
  Uma outra opção de linha de comando que você pode achar útil é $(C -run). Isto compila o código fonte, produz o programa executável e o executa com um único comando: $(C -run) deve ser a última opção do compilador, especificamente após o nome do arquivo fonte:
)

$(SHELL
$(SHELL_OBSERVED $) dmd $(HILITE -run) hello.d -w -unittest
Hello world!  $(SHELL_NOTE o programa é executado automáticamente)
)

$(H5 $(IX IDE) IDE)

$(P
Além do compilador, você pode considerar instalar uma IDE (integrated development environment). IDEs foram projetadas para facilitar o desenvolvimento de programa, simplificando as etapas de escrita, compilação e depuração.
)

$(P
Se você instalar uma IDE, compilar e executar o programa será tão simples quanto pressionar uma tecla ou clicar em um botão na IDE. Eu ainda recomendo que você se familiarize com a compilação de programas manualmente em uma janela do terminal.
)

$(P
Se você decidir instalar uma IDE, vá para $(LINK2 http://wiki.dlang.org/IDEs, a página de IDEs na dlang.org) ver uma lista de IDEs disponíveis.
)

$(H5 Conteúdo do programa hello world)

$(P
Aqui está uma lista rápida dos muitos conceitos em D que apareceram neste pequeno programa:
)

$(P $(B Recurso principal): Cada linguagem define sua sintaxe, tipos fundamentais, palavras reservadas, regras, etc. Tudo isso gera os $(I recursos principais) dessa linguagem. Os parênteses, ponto e vírgula, e palavras como $(C main) e $(C void) são todos colocados de acordo com as regras do D. São semelhantes as regras do Inglês: sujeito, verbo, pontuação, estrutura da frase, etc.
)

$(P $(B Biblioteca e função): Os recursos principais definem somente a estrutura da linguagem. Eles são usados para definir funções e tipos do usuário e estes por sua vez, são usados para construção de bibliotecas. Bibliotecas são coleções de partes reutilizáveis do programa que são $(I vinculadas) com seus programas para ajudá-los a atingir seus objetivos.
)

$(P $(C writeln) acima é uma $(I função) na $(I biblioteca) padrão do D. É usada para imprimir uma linha de texto, como o nome sugere: write(escrever) line(linha).
)

$(P $(B Módulo): O conteúdo da biblioteca é agrupado pelos tipos de tárefas que eles se propõem a executar. Esse grupo é chamado de módulo. O único módulo que este programa utiliza é o $(C std.stdio), que lida com a entrada e saída de dados.
)

$(P $(B Caracteres e string): Espressões como $(STRING "Hello world!") são chamados de $(I strings), e os elementos da string são chamados de $(I caracteres). A única string neste programa contém os caracteres $(STRING 'H'), $(STRING 'e'), $(STRING '!'), e outros.
)

$(P $(B Ordem de operações): Programas completam suas tarefas, executando operações em uma determinada ordem. Essas tarefas começam com as operações que estão escritas na função chamada $(C main). A única operação neste programa escreve "Hello world!".
)

$(P $(B Significância de Letras Maiscúlas e Minúsculas): Você pode escolher digitar qualquer caractere dentro de strings, mas você deve digitar os outros caracteres exatamente como eles aparecem no programa. Isso ocorre porque letras minúsculas e maiscúlas são significantes nos programas em D. Por exemplo, $(C writeln) e $(C Writeln) são dois nomes diferentes.
)

$(P
$(IX palavras reservadas) $(B Palavras reservadas): Palavras especiais que fazem parte dos recursos principais da linguagem são $(I palavras reservadas). Essas palavras são reservadas para a própria linguagem, a não podem ser usadas para nenhum outro propósito em um programa D. Existem duas palavras reservadas nesse programa: $(C import), usada para introduzir um módulo no programa; e $(C void), que aqui significa "não retornando nada".
)

$(P
A lista completa de palavras reservadas D é $(C abstract), $(C alias), $(C align), $(C asm), $(C assert), $(C auto), $(C body), $(C bool), $(C break), $(C byte), $(C case), $(C cast), $(C catch), $(C cdouble), $(C cent), $(C cfloat), $(C char), $(C class), $(C const), $(C continue), $(C creal), $(C dchar), $(C debug), $(C default), $(C delegate), $(C delete), $(C deprecated), $(C do), $(C double), $(C else), $(C enum), $(C export), $(C extern), $(C false), $(C final), $(C finally), $(C float), $(C for), $(C foreach), $(C foreach_reverse), $(C function), $(C goto), $(C idouble), $(C if), $(C ifloat), $(C immutable), $(C import), $(C in), $(C inout), $(C int), $(C interface), $(C invariant), $(C ireal), $(C is), $(C lazy), $(C long), $(C macro), $(C mixin), $(C module), $(C new), $(C nothrow), $(C null), $(C out), $(C override), $(C package), $(C pragma), $(C private), $(C protected), $(C public), $(C pure), $(C real), $(C ref), $(C return), $(C scope), $(C shared), $(C short), $(C static), $(C struct), $(C super), $(C switch), $(C synchronized), $(C template), $(C this), $(C throw), $(C true), $(C try), $(C typedef), $(C typeid), $(C typeof), $(C ubyte), $(C ucent), $(C uint), $(C ulong), $(C union), $(C unittest), $(C ushort), $(C version), $(C void), $(C volatile), $(C wchar), $(C while), $(C with), $(C __FILE__), $(C __FILE_FULL_PATH__), $(C __MODULE__), $(C __LINE__), $(C __FUNCTION__), $(C __PRETTY_FUNCTION__), $(C __gshared), $(C __traits), $(C __vector), and $(C __parameters).
)

$(P
$(IX asm) $(IX body) $(IX __vector) $(IX delete) $(IX typedef) $(IX volatile) $(IX macro) Nós iremos abordar-las  nos próximos capítulos com exceção das palavras reservadas: $(LINK2 http://dlang.org/statement.html#AsmStatement, $(C asm)) e $(LINK2 http://dlang.org/phobos/core_simd.html#.Vector, $(C __vector)) estão fora do escopo deste livro; $(C body), $(C delete), $(C typedef), e $(C volatile) estão obsoletas; e $(C macro) não é utilizada por D no momento.
)

$(PROBLEM_COK

$(PROBLEM Faça o programa imprimir outra coisa.)

$(PROBLEM Altere o programa para imprimir mais de uma linha. Você pode fazer isso adicionando mais uma linha $(C writeln) no programa.)

$(PROBLEM Tente compilar o programa depois de fazer outras alterações; por exemplo, remova o ponto e vírgula do fim de uma linha com $(C writeln) e observe um erro de compilação.
)

)

)

$(Ergin)

Macros:
        SUBTITLE=O Programa Hello World

        DESCRIPTION=O primeiro programa em D: Hello World!

        KEYWORDS=d programação linguagem tutorial livro

    	SOZLER= 
