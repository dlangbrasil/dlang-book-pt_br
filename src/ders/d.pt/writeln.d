Ddoc

$(DERS_BOLUMU $(IX writeln) $(IX write) $(CH4 writeln) e $(CH4 write))

$(P
No capítulo anterior, vimos que $(C writeln) pega uma string dentro de parênteses e a imprime.
)

$(P
As partes dos programas que realmente fazem o trabalho, são chamadas de $(I funções) e as informações necessárias para concluirem seus objetivos são chamados de $(I parâmetros). O ato de fornecer tais informações às funções é chamado de $(I passar valores de parâmetro) para função. Parâmetros são passados para funções dentro de parênteses, separados por vírgulas.
)

$(P
$(I $(B Nota:) A palavra) parâmetro $(I descreve as informações que são passadas para uma função no nível conceitual. As informações concretas que são realmente passadas durante a execução do programa são chamadas de) argumento. $(I Embora tecnicamente não sejam iguais, esses termos por vezes são usados de forma intercambiável na indústria de software.)  
)

$(P
$(C writeln) pode levar mais de um argumento. Ela os imprime um após o outro na mesma linha:
)

---
import std.stdio;

void main() {
    writeln("Hello, World!", "Hello, fish!");
}
---

$(P
Às vezes, nem todas as informações a serem impressas na mesma linha podem estar prontamente disponíveis para serem passadas para $(C writeln). Nesses casos, as primeiras partes da linha podem ser impressas por $(C write) e a última parte da linha pode ser impressa por $(C writeln).
)

$(P
$(C writeln) avança para a próxima linha, $(C write) permanece na mesma linha:
)

---
import std.stdio;

void main() {
    // Vamos primeiro imprimir o que temos disponível:
    write("Hello,");

    // ... vamos assumir mais operações nesse ponto ...

    write("World!");

    // ... e finalmente:
    writeln();
}
---

$(P
Chamar $(C writeln) sem nenhum parâmetro apenas completa a linha atual ou, se nada foi gravado, gera uma linha em branco.
)

$(P
$(IX //) $(IX comentário) Linhas que começam com $(COMMENT //) são chamadas $(I linhas de comentários) ou abreviadamente $(I comentários). Um comentário não faz parte do código do programa, ou seja, não afeta o comportamento do programa. O seu único objetivo é explicar o que o código faz naquela parte em particular do programa. O público de um comentário é qualquer pessoa que possa estar lendo o código do programa posteriormente, incluindo o programador que escreveu o comentário em primeiro lugar.
)

$(PROBLEM_COK

$(PROBLEM
  
Ambos os programas deste capítulo imprimem as strings sem espaços entre elas. Altere os programas para que haja espaço entre os argumentos como em "Hello, World!". 

)

$(PROBLEM
Tente chamar $(C write) com mais de um parâmetro também.
)

)


Macros:
        SUBTITLE=writeln e write

        DESCRIPTION=Duas funções da biblioteca padãro D: writeln e write.

        KEYWORDS=d linguagem programação tutorial livro declaração condicional if

MINI_SOZLUK=
