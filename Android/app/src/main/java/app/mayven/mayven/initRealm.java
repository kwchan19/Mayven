package app.mayven.mayven;

import android.app.Application;

import io.realm.Realm;
import io.realm.RealmConfiguration;

 public class initRealm extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        Realm.init(this);
        RealmConfiguration config = new RealmConfiguration.Builder()
                .build();
        Realm.setDefaultConfiguration(config);
    }
}
