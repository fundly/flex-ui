package com.enilsson.elephantadmin.views.common
{
	import mx.controls.ProgressBar;
	
	import org.osflash.thunderbolt.Logger;

	public class LimitBar extends ProgressBar
	{
		public function LimitBar()
		{
			super();
			
			mode = "manual";
            setStyle("trackHeight", 20);
            height = 20;
		}
		
		public function set limit ( value:int ):void
		{
			var l:Logger
			
			Logger.info( 'Set Progress', value );
			
			setProgress( value, 100 );
		}

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
        {
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			    
			 if(percentComplete < 21 )
                 this.setStyle("barColor","red");
             else if(percentComplete < 41 )
                 this.setStyle("barColor","#F1900E");
             else if(percentComplete < 61 )
                 this.setStyle("barColor","yellow");
             else if(percentComplete < 81 )
                 this.setStyle("barColor","#00FF33");
             else            
                 this.setStyle("barColor","green");     
             
        }

		
	}
}