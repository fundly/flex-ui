package com.enilsson.elephantadmin.views.manage_record_base
{
	import com.enilsson.elephantadmin.interfaces.IOptionView;
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	
	import flash.display.DisplayObject;
	
	import mx.containers.Canvas;
	import mx.containers.TabNavigator;

	public class OptionsBox extends Canvas
	{
		protected var tabNavigator:TabNavigator;
		protected var auditTrail:OptionsTab_AuditTrail;
	
		
		public function OptionsBox()
		{
			super();
 			
			this.horizontalScrollPolicy = 'off';
			this.clipContent = true;
		}
		
 		private var _presentationModel:RecordModel;
		public function set presentationModel ( value:RecordModel ):void
		{
			this._presentationModel = value;
		
 			for ( var i:int=0; i < this.tabNavigator.numChildren; i++ )
			{
				var child:* = this.tabNavigator.getChildAt(i);
				child.presentationModel = this._presentationModel;
			}
		}
		
		
 		override protected function createChildren():void
		{
 			super.createChildren();
 			
 			if(!tabNavigator)
			{
				tabNavigator = new TabNavigator();
				tabNavigator.styleName = 'optionsTabNav';
				addChild( tabNavigator );				
			}
			
			if( !auditTrail )
			{
				auditTrail = new OptionsTab_AuditTrail;
				tabNavigator.addChild( auditTrail );				
			}			 
		} 
		
 		override protected function commitProperties():void
		{
			super.commitProperties();
		} 
		
 		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
 			tabNavigator.height = height - 5;
			tabNavigator.width = unscaledWidth;
			tabNavigator.x = 0;
			tabNavigator.y = 5;					 
		} 
		
 		override public function addChild(child:DisplayObject):DisplayObject
		{
			if(child is IOptionView)
				tabNavigator.addChildAt(child, 0);				
			else
				super.addChild(child);

			return child;
		} 
	}
}