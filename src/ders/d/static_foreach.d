Ddoc

$(DERS_BOLUMU $(IX foreach, static) $(IX static foreach) $(CH4 static foreach))

$(P
$(I Derleme zamanı $(C foreach))  olanağını daha önce $(LINK2 /ders/d/cokuzlular.html, Çokuzlular bölümünde) görmüştük. O olanak, döngünün derleme zamanında işletilmesini ve kod olarak $(I açılmasını) sağlar. Örnek olarak bir çokuzlu üzerinde işletilen aşağıdaki döngüye bakalım:
)

---
    auto t = tuple(42, "merhaba", 1.5);

    foreach (i, üye; $(HILITE t)) {
        writefln("%s: %s", i, üye);
    }
---

$(P
Derleyici döngüyü aşağıdaki eşdeğeri olarak $(I açar):
)

---
    {
        enum size_t i = 0;
        int üye = t[i];
        writefln("%s: %s", i, üye);
    }
    {
        enum size_t i = 1;
        string üye = t[i];
        writefln("%s: %s", i, üye);
    }
    {
        enum size_t i = 2;
        double üye = t[i];
        writefln("%s: %s", i, üye);
    }
---

$(P
Çok güçlü bir olanak olmasına karşılık, bu olanak her durumda kullanışlı olmayabilir:
)

$(UL

$(LI
Döngünün her açılımı farklı bir kapsam (ve isim alanı) tanımlar. Bu sayede, yukarıdaki koddaki $(C i) ve $(C üye) gibi değişkenler tanım tekrarı hatalarına neden olmadan kullanılabilirler. Bu bazı durumlarda yararlı olsa da, belirli bir döngü adımında açılan bir kodun başka bir döngü adımında açılan kod tarafından erişilmesini olanaksızlaştırır.
)

$(LI
Derleme zamanı $(C foreach) olanağı yalnızca çokuzlularla kullanılabilir ($(C AliasSeq) olarak erişilebilen şablon parameterleri dahil). Örneğin, aşağıdaki dizi sabit değeri derleme zamanında bilindiği halde, $(C foreach) döngüsünün doğası gereği kod çalışma zamanında işletilir (bazı durumlarda istenen de tam olarak budur):
)

)

---
void main() {
    $(HILITE enum) dizi = [1, 2];
    // Derleme zamanında açılmaz, çalışma zamanında işletilir
    foreach (i; dizi) {
        // ...
    }
}
---

$(UL

$(LI
Normal $(C foreach) gibi, derleme zamanı $(C foreach) döngüsü de yalnızca işlev içlerinde kullanılabilir. Örneğin, modül düzeyinde veya kullanıcı türlerinin içlerinde kullanılamaz.
)

)

---
import std.meta;

// Modül düzeyinde işlev yüklemeleri tanımlamaya çalışılıyor:
foreach (T; AliasSeq!(int, double)) {    $(DERLEME_HATASI)
    T ikiKatı(T sayı) {
        return sayı * 2;
    }
}

void main() {
}
---

$(SHELL
Error: declaration expected, not `foreach`
)

$(UL

$(LI
$(C break) ve $(C continue) deyimlerinin derleme zamanı $(C foreach)'inin kendisi ile mi yoksa açılan kodun parçası mı oldukları açık olmayabilir.
)

)

$(P
$(C static foreach) bu konularda daha fazla seçim sağlayan daha güçlü bir olanaktır:
)

$(UL

$(LI
Derleme zamanında işletilebilen her çeşit aralıkla kullanılabilir ($(C 1..10) gibi sayı aralıkları dahil). Örneğin, $(LINK2 /ders/d/araliklar.html, Aralıklar bölümünde) gördüğümüz $(C FibonacciSerisi) aralığı ve bir sayının çift olup olmadığını belirleyen bir işlev olduğunu varsayarak:
)

)

---
    $(HILITE static foreach) (n; FibonacciSerisi().take(10).filter!çift_mi) {
        writeln(n);
    }
---

$(P
Yukarıdaki döngü aşağıdaki eşdeğeri olarak açılır:
)

---
    writeln(0);
    writeln(2);
    writeln(8);
    writeln(34);
---

$(UL

$(LI Modül düzeyinde kullanılabilir)

$(LI
Döngünün her adımı için farklı kapsam getirmez. Örneğin, aşağıdaki kod bir işlevin iki yüklemesini modül düzeyinde tanımlamaktadır:
)

)

---
import std.meta;

static foreach (T; AliasSeq!(int, double)) {
    T ikiKatı(T sayı) {
        return sayı * 2;
    }
}

void main() {
}
---

$(P
Yukarıdaki döngü aşağıdaki eşdeğeri olarak açılır:
)

---
    int ikiKatı(int sayı) {
        return sayı * 2;
    }

    double ikiKatı(double sayı) {
        return sayı * 2;
    }
---

$(UL

$(LI
$(C static foreach) döngüleri içindeki $(C break) ve $(C continue) deyimlerinde etiket belirtilmesi şarttır. Örneğin, bir $(C switch) deyimi içine $(C case) bölümleri ekleyen aşağıdaki döngüde, açılmakta olan kodun parçası olan $(C break), ilgili olduğu $(C switch)'i bir etiketle bildirmektedir:
)

)

---
import std.stdio;

void main(string[] parametreler) {

$(HILITE switchDeyimi:)
    switch (parametreler.length) {
        static foreach (i; 1..3) {
            case i:
                writeln(i);
                break $(HILITE switchDeyimi);
        }

    default:
        writeln("varsayılan davranış");
        break;
    }
}
---

$(P
Yukarıdaki döngü açıldığında bütün $(C switch) deyimi aşağıdakinin eşdeğeridir:
)

---
    switch (parametreler.length) {
    case 1:
        writeln(1);
        break;

    case 2:
        writeln(2);
        break;

    default:
        writeln("varsayılan davranış");
        break;
    }
---

macros:
        SUBTITLE=static foreach

        DESCRIPTION=D'nin aralıklar üzerinde ilerleyerek kod üretmeyi sağlayan bir derleme zamanı olanağı.

        KEYWORDS=d programlama dili ders bölümler öğrenmek tutorial static foreach

SOZLER=
$(cokuzlu)
$(dongu_acilimi)
$(etiket)
$(hazir_deger)
$(isim_alani)
$(kapsam)
$(yukleme)
