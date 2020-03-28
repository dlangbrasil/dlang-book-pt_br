Ddoc

$(DERS_BOLUMU $(IX alias this) $(CH4 alias this))

$(P
Başka bağlamlarda başka anlamlara gelen $(C alias) ve $(C this) anahtar sözcükleri bir arada kullanıldıklarında farklı bir anlam kazanırlar. Bu yüzden, ikisi bir arada kullanıldığında tek bir anahtar sözcük olarak kabul edilmelidirler.
)

$(P
$(IX otomatik tür dönüşümü) $(IX tür dönüşümü, otomatik)  $(C alias this), bir yapının veya sınıfın otomatik tür dönüşümü yoluyla başka türler yerine geçmesini sağlar. Tür dönüşümü için başka bir seçenek $(LINK2 /ders/d/islec_yukleme.html, İşleç Yükleme bölümünde) gördüğümüz $(C opCast) işlecidir. Farkları, $(C opCast)'in açıkça yapılan tür dönüşümleri için, $(C alias this)'in ise otomatik tür dönüşümleri için kullanılmasıdır.
)

$(P
Bu iki sözcük birbirlerinden ayrı olarak yazılırlar; aralarına yapının veya sınıfın bir üyesi gelir:
)

---
    alias $(I üye_değişken_veya_işlev) this;
---

$(P
$(C alias this) yapının veya sınıfın türünü gerektiğinde belirtilen üyenin türüne otomatik olarak dönüştürmeyi sağlar. Dönüşüm sonucunda üretilen değer o üyenin değeridir.
)

$(P
Aşağıdaki $(C Kesir) örneği $(C alias this)'i bir $(I üye işlev) ile kullanıyor. Daha aşağıdaki $(C AraştırmaGörevlisi) örneğinde ise $(C alias this)'in $(I üye değişkenlerle) kullanımlarını göreceğiz.
)

$(P
$(C değeri) işlevinin dönüş değeri $(C double) olduğundan, aşağıdaki $(C alias this) bildirimi $(C Kesir) nesnelerinin $(C double) değerler yerine kullanılabilmelerini sağlar:
)

---
import std.stdio;

struct Kesir {
    long pay;
    long payda;

    $(HILITE double değeri()) const {
        return double(pay) / payda;
    }

    alias $(HILITE değeri) this;

    // ...
}

double hesap(double soldaki, double sağdaki) {
    return 2 * soldaki + sağdaki;
}

void main() {
    auto kesir = Kesir(1, 4);    // 1/4 anlamında
    writeln(hesap($(HILITE kesir), 0.75));
}
---

$(P
Yukarıdaki yapının nesneleri $(C double) türünde değer beklenen ifadelerde geçtiklerinde $(C değeri) işlevi çağrılır ve o işlevin döndürdüğü değer kullanılır. Yukarıdaki kodda aslında $(C double) bekleyen $(C hesap) işlevine bir $(C Kesir) nesnesi gönderilebilmiş ve o hesapta $(C değeri) işlevinin döndürdüğü 0.25 kullanılmıştır. Program, 2 * 0.25 + 0.75 hesabının sonucunu yazdırır:
)

$(SHELL
1.25
)

Macros:
        SUBTITLE=alias this

        DESCRIPTION=Nesnelerin otomatik olarak başka tür olarak kullanılmalarını sağlayan 'alias this'.

        KEYWORDS=d programlama dili ders bölümler öğrenmek tutorial alias takma isim alias this
