package fl.shared.link.example

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import androidx.activity.ComponentActivity

class SharedLauncherActivity : ComponentActivity() {

    override fun onStart() {
        super.onStart()
        startMain(intent)
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        startMain(intent)
    }

    @SuppressLint("IntentReset")
    private fun startMain(intent: Intent?) {
        val newIntent = Intent(this, MainActivity::class.java)
        newIntent.action = intent?.action
        newIntent.data = intent?.data
        newIntent.type = intent?.type
        intent?.extras?.let { newIntent.putExtras(it) }
        this.startActivity(newIntent)
        finish()
    }

}