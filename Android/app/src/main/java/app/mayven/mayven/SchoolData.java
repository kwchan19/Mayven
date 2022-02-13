package app.mayven.mayven;

import java.util.ArrayList;

public class SchoolData {

    private static ArrayList<SchoolData> SchoolDataList;
    private String code;
    private String name;

    public SchoolData(String code, String name) {
        this.code = code;
        this.name = name;
    }

    public static void initSchools(){
        SchoolDataList = new ArrayList<>();
    }

    public static void addSchool(String id, String name) {
        SchoolData school = new SchoolData(id, name);
        SchoolDataList.add(school);
    }

    public static String[] schoolNames() {
        String[] names = new String[SchoolDataList.size()];
        for(int i = 0; i < SchoolDataList.size(); i++) {
            names[i] = SchoolDataList.get(i).name;
        }
        return names;
    }

    public static ArrayList<SchoolData> getSchoolDataList() {
        return SchoolDataList;
    }

    public String getId() {
        return code;
    }

    public String getName() {
        return name;
    }
}