<?xml version="1.0"?>
<bindings>
    <!-- inputContexts -->
    <context name="TriggerModeCtrlContext" >
        <action name="TriggerSwap" map="TriggerSwap_Button" />
    </context>

    <context name="Combat" append="true">
        <include name="TriggerModeCtrlContext" />
    </context>

    <hold action="TriggerSwap" timeout="0.1" />

    <acceptedEvents action="TriggerSwap" >
        <event name="BUTTON_RELEASED" />
        <event name="BUTTON_HOLD_COMPLETE" />
    </acceptedEvents>

    <!-- inputUserMapping -->
    <mapping name="TriggerSwap_Button" type="Button" >
        <button id="IK_R" />
        <button id="IK_Pad_X_SQUARE" />
    </mapping>

</bindings>
