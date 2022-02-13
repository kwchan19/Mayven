package app.mayven.mayven;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import app.mayven.mayven.R;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.List;


public class tos extends AppCompatActivity {

    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference userRef = db.collection("Users");

    private TextView text;
    private Button button;
    @SuppressLint("SetTextI18n")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_tos);

        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUsername = qwe.get(0).username;

        text = findViewById(R.id.text);
        button = findViewById(R.id.button);
        text.setText("END USER LICENSE AGREEMENT\n\n\n\n" +
                "Last updated April 28, 2021\n\n" +
                " Mayven is licensed to You (End-User) by Mayven Software (hereinafter: Licensor), for use only under the terms of this License Agreement.\n\n" +
                "By downloading the Application from the Google Play Store, and any update thereto (as permitted by this License Agreement), You indicate that You agree to be bound by all of the terms and conditions of this License Agreement, and that You accept this License Agreement.\n\n" +
                "The parties of this License Agreement acknowledge that Alphabet Inc is not a Party to this License Agreement and is not bound by any provisions or obligations with regard to the Application, such as warranty, liability, maintenance and support thereof. Mayven Software, not Alphabet Inc, is solely responsible for the licensed Application and the content thereof.\n\n" +
                "This License Agreement may not provide for usage rules for the Application that are in conflict with the latest App Store Terms of Service. Mayven Software acknowledges that it had the opportunity to review said terms and this License Agreement is not conflicting with them.\n\n" +
                "All rights not expressly granted to You are reserved.\n\n" +
                "1. THE APPLICATION\n\n" +
                "Mayven (hereinafter: Application) is a piece of software created to social media platform for post secondary institutions - and customized for Google Android operating systems. It is used to create a space where students can communicate with one another.\n\n" +
                "2. SCOPE OF LICENSE\n\n" +
                "2.1  You are given a non-transferable, non-exclusive, non-sublicensable license to install and use the Licensed Application on any Google-branded Products that You (End-User) own or control and as permitted by the Usage Rules set forth in this section and the App Store Terms of Service, with the exception that such licensed Application may be accessed and used by other accounts associated with You (End-User, The Purchaser) via Family Sharing or volume purchasing.\n\n" +
                "2.2  This license will also govern any updates of the Application provided by Licensor that replace, repair, and/or supplement the first Application, unless a separate license is provided for such update in which case the terms of that new license will govern.\n\n" +
                "2.3  You may not share or make the Application available to third parties (unless to the degree allowed by the Alphabet Inc Terms and Conditions, and with Mayven Software's prior written consent), sell, rent, lend, lease or otherwise redistribute the Application.\n\n" +
                "2.4  You may not reverse engineer, translate, disassemble, integrate, decompile, integrate, remove, modify, combine, create derivative works or updates of, adapt, or attempt to derive the source code of the Application, or any part thereof (except with Mayven Software's prior written consent).\n\n" +
                "2.5  You may not copy (excluding when expressly authorized by this license and the Usage Rules) or alter the Application or portions thereof. You may create and store copies only on devices that You own or control for backup keeping under the terms of this license, the App Store Terms of Service, and any other terms and conditions that apply to the device or software used. You may not remove any intellectual property notices. You acknowledge that no unauthorized third parties may gain access to these copies at any time.\n\n" +
                "2.6  Violations of the obligations mentioned above, as well as the attempt of such infringement, may be subject to prosecution and damages.\n\n" +
                "2.7  Licensor reserves the right to modify the terms and conditions of licensing.\n\n" +
                "2.8  Nothing in this license should be interpreted to restrict third-party terms. When using the Application, You must ensure that You comply with applicable third-party terms and conditions.\n\n" +
                "3. TECHNICAL REQUIREMENTS\n\n" +
                "3.1  The Application requires a firmware version 1.0.0 or higher. Licensor recommends using the latest version of the firmware.\n\n" +
                "3.2  Licensor attempts to keep the Application updated so that it complies with modified/new versions of the firmware and new hardware. You are not granted rights to claim such an update.\n\n" +
                "3.3  You acknowledge that it is Your responsibility to confirm and determine that the app end-user device on which You intend to use the Application satisfies the technical  specifications mentioned above.\n\n" +
                "3.4  Licensor reserves the right to modify the technical specifications as it sees appropriate at any time.\n\n" +
                "4. MAINTENANCE AND SUPPORT\n\n" +
                "4.1  The Licensor is solely responsible for providing any maintenance and support services for this licensed Application. You can reach the Licensor at the email address listed in the App Store Overview for this licensed Application.\n\n" +
                "4.2  Mayven Software and the End-User acknowledge that Alphabet Inc has no obligation whatsoever to furnish any maintenance and support services with respect to the licensed Application.\n\n" +
                "5. USE OF DATA\n\n" +
                "You acknowledge that Licensor will be able to access and adjust Your downloaded licensed Application content and Your personal information, and that Licensor's use of such material and information is subject to Your legal agreements with Licensor and Licensor's privacy policy: mayven.app/privacy.\n\n" +
                "6. USER GENERATED CONTRIBUTIONS\n\n" +
                "The Application may invite you to chat, contribute to, or participate in blogs, message boards, online forums, and other functionality, and may provide you with the opportunity to create, submit, post, display, transmit, perform, publish, distribute, or broadcast content and materials to us or in the Application, including but not limited to text, writings, video, audio, photographs, graphics, comments, suggestions, or personal information or other material (collectively, \"Contributions\"). Contributions may be viewable by other users of the Application and through third-party websites or applications. As such, any Contributions you transmit may be treated as non-confidential and non-proprietary. When you create or make available any Contributions, you thereby represent and warrant that:\n\n" +
                "1. The creation, distribution, transmission, public display, or performance, and the accessing, downloading, or copying of your Contributions do not and will not infringe the proprietary rights, including but not limited to the copyright, patent, trademark, trade secret, or moral rights of any third party.\n\n" +
                "2. You are the creator and owner of or have the necessary licenses, rights, consents, releases, and permissions to use and to authorize us, the Application, and other users of the Application to use your Contributions in any manner contemplated by the Application and these Terms of Use.\n\n" +
                "3. You have the written consent, release, and/or permission of each and every identifiable individual person in your Contributions to use the name or likeness or each and every such identifiable individual person to enable inclusion and use of your Contributions in any manner contemplated by the Application and these Terms of Use.\n\n" +
                "4. Your Contributions are not false, inaccurate, or misleading.\n\n" +
                "5. Your Contributions are not unsolicited or unauthorized advertising, promotional materials, pyramid schemes, chain letters, spam, mass mailings, or other forms of solicitation.\n\n" +
                "6. Your Contributions are not obscene, lewd, lascivious, filthy, violent, harassing, libelous, slanderous, or otherwise objectionable (as determined by us).\n\n" +
                "7. Your Contributions do not ridicule, mock, disparage, intimidate, or abuse anyone.\n\n" +
                "8. Your Contributions are not used to harass or threaten (in the legal sense of those terms) any other person and to promote violence against a specific person or class of people.\n\n" +
                "9. Your Contributions do not violate any applicable law, regulation, or rule.\n\n" +
                "10. Your Contributions do not violate the privacy or publicity rights of any third party.\n\n" +
                "11. Your Contributions do not contain any material that solicits personal information from anyone under the age of 18 or exploits people under the age of 18 in a sexual or violent manner.\n\n" +
                "12. Your Contributions do not violate any applicable law concerning child pornography, or otherwise intended to protect the health or well-being of minors.\n\n" +
                "13. Your Contributions do not include any offensive comments that are connected to race, national origin, gender, sexual preference, or physical handicap.\n\n" +
                "14. Your Contributions do not otherwise violate, or link to material that violates, any provision of these Terms of Use, or any applicable law or regulation.\n\n" +
                "Any use of the Application in violation of the foregoing violates these Terms of Use and may result in, among other things, termination or suspension of your rights to use the Application.\n\n" +
                "7. CONTRIBUTION LICENSE\n\n" +
                "By posting your Contributions to any part of the Application or making Contributions accessible to the Application by linking your account from the Application to any of your social networking accounts, you automatically grant, and you represent and warrant that you have the right to grant, to us an unrestricted, unlimited, irrevocable, perpetual, non-exclusive, transferable, royalty-free, fully-paid, worldwide right, and license to host, use copy, reproduce, disclose, sell, resell, publish, broad cast, retitle, archive, store, cache, publicly display, reformat, translate, transmit, excerpt (in whole or in part), and distribute such Contributions (including, without limitation, your image and voice) for any purpose, commercial advertising, or otherwise, and to prepare derivative works of, or incorporate in other works, such as Contributions, and grant and authorize sublicenses of the foregoing. The use and distribution may occur in any media formats and through any media channels.\n\n" +
                "This license will apply to any form, media, or technology now known or hereafter developed, and includes our use of your name, company name, and franchise name, as applicable, and any of the trademarks, service marks, trade names, logos, and personal and commercial images you provide. You waive all moral rights in your Contributions, and you warrant that moral rights have not otherwise been asserted in your Contributions.\n\n" +
                "We do not assert any ownership over your Contributions. You retain full ownership of all of your Contributions and any intellectual property rights or other proprietary rights associated with your Contributions. We are not liable for any statements or representations in your Contributions provided by you in any area in the Application. You are solely responsible for your Contributions to the Application and you expressly agree to exonerate us from any and all responsibility and to refrain from any legal action against us regarding your Contributions.\n\n" +
                "We have the right, in our sole and absolute discretion, (1) to edit, redact, or otherwise change any Contributions; (2) to re-categorize any Contributions to place them in more appropriate locations in the Application; and (3) to pre-screen or delete any Contributions at any time and for any reason, without notice. We have no obligation to monitor your Contributions.\n\n" +
                "8. LIABILITY\n\n" +
                "8.1  Licensor's responsibility in the case of violation of obligations and tort shall be limited to intent and gross negligence. Only in case of a breach of essential contractual duties (cardinal obligations), Licensor shall also be liable in case of slight negligence. In any case, liability shall be limited to the foreseeable, contractually typical damages. The limitation mentioned above does not apply to injuries to life, limb, or health.\n\n" +
                "8.2  Licensor takes no accountability or responsibility for any damages caused due to a breach of duties according to Section 2 of this Agreement. To avoid data loss, You are required to make use of backup functions of the Application to the extent allowed by applicable third-party terms and conditions of use. You are aware that in case of alterations or manipulations of the Application, You will not have access to licensed Application.\n\n" +
                "9. WARRANTY\n\n" +
                "9.1  Licensor warrants that the Application is free of spyware, trojan horses, viruses, or any other malware at the time of Your download. Licensor warrants that the Application works as described in the user documentation.\n\n" +
                "9.2  No warranty is provided for the Application that is not executable on the device, that has been unauthorizedly modified, handled inappropriately or culpably, combined or installed with inappropriate hardware or software, used with inappropriate accessories, regardless if by Yourself or by third parties, or if there are any other reasons outside of Mayven Software's sphere of influence that affect the executability of the Application.\n\n" +
                "9.3  You are required to inspect the Application immediately after installing it and notify Mayven Software about issues discovered without delay by e-mail provided in Product Claims. The defect report will be taken into consideration and further investigated if it has been mailed within a period of ninety (90) days after discovery.\n\n" +
                "9.4  If we confirm that the Application is defective, Mayven Software reserves a choice to remedy the situation either by means of solving the defect or substitute delivery.\n\n" +
                "9.5  In the event of any failure of the Application to conform to any applicable warranty, You may notify the App-Store-Operator, and Your Application purchase price will be refunded to You. To the maximum extent permitted by applicable law, the App-Store-Operator will have no other warranty obligation whatsoever with respect to the App, and any other losses, claims, damages, liabilities, expenses and costs attributable to any negligence to adhere to any warranty.\n\n" +
                "9.6  If the user is an entrepreneur, any claim based on faults expires after a statutory period of limitation amounting to twelve (12) months after the Application was made available to the user. The statutory periods of limitation given by law apply for users who are consumers.\n\n" +
                "10. PRODUCT CLAIMS\n\n" +
                "Mayven Software and the End-User acknowledge that Mayven Software, and not Alphabet Inc, is responsible for addressing any claims of the End-User or any third party relating to the licensed Application or the End-User’s possession and/or use of that licensed Application, including, but not limited to:\n\n" +
                "(i) product liability claims;\n\n" +
                "(ii) any claim that the licensed Application fails to conform to any applicable legal or regulatory requirement; and\n\n" +
                "(iii) claims arising under consumer protection, privacy, or similar legislation, including in connection with Your Licensed Application’s use of the HealthKit and HomeKit.\n\n" +
                "11. LEGAL COMPLIANCE\n\n" +
                "You represent and warrant that You are not located in a country that is subject to a U.S. Government embargo, or that has been designated by the U.S. Government as a \"terrorist supporting\" country; and that You are not listed on any U.S. Government list of prohibited or restricted parties.\n\n" +
                "12. CONTACT INFORMATION\n\n" +
                "For general inquiries, complaints, questions or claims concerning the licensed Application, please contact:\n\n" +
                "Kevin Chan\n" +
                "kevin.chan@mayven.app\n\n" +
                "13. TERMINATION\n\n" +
                "The license is valid until terminated by Mayven Software or by You. Your rights under this license will terminate automatically and without notice from Mayven Software if You fail to adhere to any term(s) of this license. Upon License termination, You shall stop all use of the Application, and destroy all copies, full or partial, of the Application.\n\n" +
                "14. THIRD-PARTY TERMS OF AGREEMENTS AND BENEFICIARY\n\n" +
                "Mayven Software represents and warrants that Mayven Software will comply with applicable third-party terms of agreement when using licensed Application.\n\n" +
                "In Accordance with Section 9 of the \"Instructions for Minimum Terms of Developer's End-User License Agreement,\" Alphabet Inc and Alphabet Inc's subsidiaries shall be third-party beneficiaries of this End User License Agreement and - upon Your acceptance of the terms and conditions of this license agreement, Alphabet Inc will have the right (and will be deemed to have accepted the right) to enforce this End User License Agreement against You as a third-party beneficiary thereof.\n\n" +
                "15. INTELLECTUAL PROPERTY RIGHTS\n\n" +
                "Mayven Software and the End-User acknowledge that, in the event of any third-party claim that the licensed Application or the End-User's possession and use of that licensed Application infringes on the third party's intellectual property rights, Mayven Software, and not Alphabet Inc, will be solely responsible for the investigation, defense, settlement and discharge or any such intellectual property infringement claims.\n\n" +
                "16. APPLICABLE LAW\n\n" +
                "This license agreement is governed by the laws of Canada excluding its conflicts of law rules.\n\n" +
                "17. MISCELLANEOUS\n\n" +
                "17.1  If any of the terms of this agreement should be or become invalid, the validity of the remaining provisions shall not be affected. Invalid terms will be replaced by valid ones formulated in a way that will achieve the primary purpose.\n\n" +
                "17.2  Collateral agreements, changes and amendments are only valid if laid down in writing. The preceding clause can only be waived in writing.\n\n");

        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                userRef.document(signedInUsername).update(
                        "tos",true
                );
                startActivity(new Intent(getApplicationContext(), MainActivity.class));
                finish();
            }
        });

    }
}