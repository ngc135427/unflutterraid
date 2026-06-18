package com.example.unflutterraid

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "unflutterraid/login_preferences"
        ).setMethodCallHandler { call, result ->
            val preferences = getSharedPreferences("login_preferences", Context.MODE_PRIVATE)

            when (call.method) {
                "load" -> {
                    result.success(
                        mapOf(
                            "rememberMe" to preferences.getBoolean("rememberMe", false),
                            "domain" to preferences.getString("domain", ""),
                            "apiKey" to preferences.getString("apiKey", ""),
                            "useHttps" to preferences.getBoolean("useHttps", false),
                        )
                    )
                }
                "save" -> {
                    val rememberMe = call.argument<Boolean>("rememberMe") ?: false
                    val editor = preferences.edit().putBoolean("rememberMe", rememberMe)

                    if (rememberMe) {
                        editor
                            .putString("domain", call.argument<String>("domain") ?: "")
                            .putString("apiKey", call.argument<String>("apiKey") ?: "")
                            .putBoolean("useHttps", call.argument<Boolean>("useHttps") ?: false)
                    } else {
                        editor
                            .remove("domain")
                            .remove("apiKey")
                            .remove("useHttps")
                    }

                    editor.apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
