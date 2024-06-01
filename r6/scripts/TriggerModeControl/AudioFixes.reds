class FillMissingGunSounds extends ScriptableService {

  private cb func OnLoad() {
    GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Loaded", this, n"OnAudioMetadataLoad").AddTarget(ResourceTarget.Type(n"audioCookedMetadataResource"));
  }

  private cb func OnAudioMetadataLoad(event: ref<ResourceEvent>) {
    let cookedMetadata = event.GetResource() as audioCookedMetadataResource;
    for audioData in cookedMetadata.entries {
      let audioWeaponSet = audioData as audioWeaponSettingsGroup;
      if IsDefined(audioWeaponSet) && !Equals(audioWeaponSet.playerSettings, n"") && Equals(audioWeaponSet.playerSilenced, n"") {
        audioWeaponSet.playerSilenced = n"wea_pla_yukimura";
      };
      let audioPlayerSet = audioData as audioPlayerWeaponSettings;
      if IsDefined(audioPlayerSet) && !Equals(audioPlayerSet.name, n"") {
	    if Equals(audioPlayerSet.chargeStartSound, n"") {
          audioPlayerSet.chargeStartSound = n"w_gun_revol_tech_burya_charge";
		};
		if !Equals(audioPlayerSet.fireSound, n"") {
          audioPlayerSet.preFireSound = audioPlayerSet.fireSound;
          audioPlayerSet.fireSound = n"";
          audioPlayerSet.burstFireSound = n"";
		};
      };
    };
  }

}
