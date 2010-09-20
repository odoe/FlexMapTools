package net.odoe.FlexMapTools.components.events {
import flash.events.Event;

public class IdentifyToolEvent extends Event {
	public static const IDENTIFY_TOOL_ACTIVE:String = "identifyToolActive";
	
	public function IdentifyToolEvent(type:String) {
		super(type, true, true);
	}
	
	override public function clone():Event {
		return new IdentifyToolEvent(type);
	}
}
}