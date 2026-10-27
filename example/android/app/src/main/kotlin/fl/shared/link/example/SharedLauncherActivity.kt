package fl.shared.link.example

import android.annotation.SuppressLint
import android.content.Intent
import androidx.activity.ComponentActivity

/**
 * 分享 / 打开文件的中转 Activity。
 *
 * 将该 Activity 收到的 Intent 转交给 [MainActivity]，
 * 避免应用在系统分享列表中重复出现，同时保证冷启动和热启动都能收到参数。
 */
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
        startActivity(newIntent)
        finish()
    }
}
