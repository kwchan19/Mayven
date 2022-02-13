package app.mayven.mayven;

import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

import app.mayven.mayven.R;
import com.google.android.gms.ads.formats.MediaView;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;

public class UnifiedNativeAdViewHolder extends RecyclerView.ViewHolder {

    private UnifiedNativeAdView adView;

    public UnifiedNativeAdView getAdView() {
        return adView;
    }

    UnifiedNativeAdViewHolder(View view) {
        super(view);
        adView = (UnifiedNativeAdView) view.findViewById(R.id.ad_view);

        // The MediaView will display a video asset if one is present in the ad, and the
        // first image asset otherwise.
        adView.setMediaView((MediaView) adView.findViewById(R.id.ad_media));

        // Register the view used for each individual asset.
        adView.setHeadlineView(adView.findViewById(R.id.ad_headline));
        adView.setBodyView(adView.findViewById(R.id.ad_body));
        adView.setIconView(adView.findViewById(R.id.ad_icon));

        adView.setAdvertiserView(adView.findViewById(R.id.ad_advertiser));
    }
}