package com.carryeats.hub

import android.app.Application
import android.util.Log
import io.intercom.android.sdk.Intercom

class IntercomApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        try {
            Log.d("IntercomDebug", "Starting Intercom initialization...")
            
            // تهيئة Intercom فقط إذا لم تكن مهيأة بالفعل
            if (!Intercom.isInitialized()) {
                Intercom.initialize(
                    this,
                    "j3he2pue",
                    "android_sdk-d8df6307ae07677807b288a2d5138821b8bfe4f9"
                )
                
                Log.d("IntercomDebug", "Intercom initialized successfully")
                
                // تسجيل مستخدم غير محدد (سيتم تحديثه لاحقاً من Flutter)
                Intercom.client().loginUnidentifiedUser()
                
                Log.d("IntercomDebug", "Unidentified user logged in")
                
                // إخفاء الـ launcher الافتراضي (سنستخدم Flutter للتحكم)
                Intercom.client().setLauncherVisibility(Intercom.Visibility.GONE)
                
                Log.d("IntercomDebug", "Launcher visibility set to GONE")
            } else {
                Log.d("IntercomDebug", "Intercom already initialized, skipping...")
            }
            
        } catch (e: Exception) {
            Log.e("IntercomDebug", "Error initializing Intercom: ${e.message}", e)
        }
    }
}
