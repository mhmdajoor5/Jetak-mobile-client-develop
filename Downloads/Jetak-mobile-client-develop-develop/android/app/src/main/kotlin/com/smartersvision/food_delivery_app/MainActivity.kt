//package com.carryeats.customer
//
//import androidx.core.content.ContextCompat
//import com.carryeats.customer.R
//import io.flutter.embedding.android.DrawableSplashScreen
//import io.flutter.embedding.android.SplashScreen
//import io.flutter.embedding.android.FlutterActivity;
//
//class MainActivity : FlutterActivity() {
//
//    override fun provideSplashScreen(): SplashScreen {
//        // ...
//        return DrawableSplashScreen(
//            ContextCompat.getDrawable(this, R.drawable.carry_eats_hub_splash)!!
//        );
//    }
//}
package com.carryeats.customer

import android.os.Build
import android.os.Bundle
import android.window.SplashScreen
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Show the splash screen
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }
}