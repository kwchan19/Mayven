package app.mayven.mayven;

import io.realm.RealmObject;


public class userDB extends RealmObject {
    public String name;
    public String username;
    public String email;
    public String classOf;
    public int lastNotifications;
    public String programCode;
    public String programName;
    public String school;
    public String schoolName;

    public userDB (){

    }

    public  userDB(String name, String username, String email, String classOf, int lastNotification, String programCode, String programName, String school, String schoolName) {
        this.name = name;
        this.username = username;
        this.email = email;
        this.classOf = classOf;
        this.lastNotifications = lastNotification;
        this.programCode = programCode;
        this.programName = programName;
        this.school = school;
        this.schoolName = schoolName;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getUsername(String username) {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getClassOf() {
        return classOf;
    }

    public void setClassOf(String classOf) {
        this.classOf = classOf;
    }

    public int getLastNotification() {
        return lastNotifications;
    }

    public void setLastNotification(int lastNotification) {
        this.lastNotifications = lastNotification;
    }

    public String getProgramCode() {
        return programCode;
    }

    public void setProgramCode(String programCode) {
        this.programCode = programCode;
    }

    public String getProgramName() {
        return programName;
    }

    public void setProgramName(String programName) {
        this.programName = programName;
    }

    public String getSchool() {
        return school;
    }

    public void setSchool(String school) {
        this.school = school;
    }

    public String getSchoolName() {
        return schoolName;
    }

    public void setSchoolName(String schoolName) {
        this.schoolName = schoolName;
    }
}
