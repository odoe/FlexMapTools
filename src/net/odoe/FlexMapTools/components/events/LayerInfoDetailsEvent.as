package net.odoe.FlexMapTools.components.events {
import flash.events.Event;

public class LayerInfoDetailsEvent extends Event {
	public static const VISIBLE_LAYER_ID:String = "visibleLayerID";
	
	public var layerID:int;
	public var visible:Boolean;
	
	public function LayerInfoDetailsEvent(type:String, layerID:int, visible:Boolean) {
		this.layerID = layerID;
		this.visible = visible;
		super(type, true, true);
	}
	
	override public function clone():Event {
		return new LayerInfoDetailsEvent(this.type, this.layerID,this.visible);
	}
}
}