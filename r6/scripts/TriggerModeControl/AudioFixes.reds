class FillSilencedSounds extends ScriptableService {

  private cb func OnLoad() {
    GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Loaded", this, n"OnAudioMetadataLoad").AddTarget(ResourceTarget.Type(n"audioCookedMetadataResource"));
  }

  private cb func OnAudioMetadataLoad(event: ref<ResourceEvent>) {
    let cookedMetadata = event.GetResource() as audioCookedMetadataResource;
    for audioData in cookedMetadata.entries {
      let weaponAudio = audioData as audioWeaponSettingsGroup;
      if IsDefined(weaponAudio) && Equals(weaponAudio.playerSilenced, n"") && !Equals(weaponAudio.playerSettings, n"") {
        weaponAudio.playerSilenced = n"wea_pla_yukimura";
      };
    };
  }

}