package io.github.loshine.flutternga

import com.google.gson.Gson
import com.google.gson.JsonObject
import org.junit.Test
import java.nio.charset.Charset

class GbkDecodeTest {

    @Test
    fun decode() {
        val wrong = String("你好，世界".toByteArray(Charset.forName("gbk")), Charset.forName("utf8"))
        println(wrong)

        println(String(wrong.toByteArray(Charset.forName("utf8")), Charset.forName("gbk")))
    }

    @Test
    fun decodeJson() {
        val wrong = "{data:{attachments:'aid~-39t2Q5-6zzw~ext~jpg~url_utf8_org_name~wx_camera_1548231652774.jpg~path~mon_201901/23~url_dscp~~size~213542~name~-39t2Q5-6zzwZlT3cSps-1hc.jpg~w~928~h~1920~thumb~120',attachments_check:'ac9014e6eafd372291a4bfab01173aa3',url:'mon_201901/23/-39t2Q5-6zzwZlT3cSps-1hc.jpg',isImg:'1',thumb:'120'}}"
        val gson = Gson()
        val jsonObject = gson.fromJson(wrong, JsonObject::class.java)
        println(gson.toJson(jsonObject))
    }
}