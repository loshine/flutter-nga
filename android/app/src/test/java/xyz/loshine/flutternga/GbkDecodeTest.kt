package xyz.loshine.flutternga

import org.junit.Test
import java.nio.charset.Charset

class GbkDecodeTest {

    @Test
    fun decode() {
        val wrong = String("你好，世界".toByteArray(Charset.forName("gbk")), Charset.forName("utf8"))
        println(wrong)

        println(String(wrong.toByteArray(Charset.forName("utf8")), Charset.forName("gbk")))
    }
}