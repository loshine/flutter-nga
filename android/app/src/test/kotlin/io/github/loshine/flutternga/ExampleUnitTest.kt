package io.github.loshine.flutternga

import kotlinx.coroutines.runBlocking
import org.junit.Test
import java.io.ByteArrayOutputStream
import java.net.URL

class ExampleUnitTest {

    @Test
    fun testFile() {
        runBlocking {
            URL("https://img.nga.178.com/attachments/mon_202105/23/dbQ2o-obK18T1kSh2-eb.jpg").openStream()
                .use {
                    val bos = ByteArrayOutputStream()
                    val b = ByteArray(8192)
                    var len: Int
                    while (it.read(b, 0, 8192).also { len = it } != -1) {
                        bos.write(b, 0, len)
                    }
                    println(bos.toByteArray())
                }
        }
    }
}