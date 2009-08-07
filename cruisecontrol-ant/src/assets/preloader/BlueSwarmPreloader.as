package assets.preloader
{
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.utils.Timer;
    
    import mx.events.FlexEvent;
    import mx.preloaders.DownloadProgressBar;
    
    import org.osflash.thunderbolt.Logger;

    public class BlueSwarmPreloader extends DownloadProgressBar
    {
        
    //----------------------------------
    //  Static Properties
    //----------------------------------
    
        [Embed(source="/assets/images/preloader/BlueSwarm_Preloader_logo.png")]
        private static const BLUESWARM_LOGO:Class;
        
    //----------------------------------
    //  Constructor
    //----------------------------------
        
        /**
         * Constructor.
         */
        public function BlueSwarmPreloader()
        {
            super();
            this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            
            this._progressBar = new Shape();
            this.addChild(this._progressBar);
            
            this._logo = new BLUESWARM_LOGO();
            this._logo.alpha = 0;
            this.addChild(this._logo);
            
            this._logoTimer = new Timer(10);
            this._logoTimer.addEventListener(TimerEvent.TIMER, timerUpdateHandler);
            this._logoTimer.start();
        }
        
    //----------------------------------
    //  Properties
    //----------------------------------
        
        /**
         * @private
         * A simple progress bar to track the download.
         */
        private var _progressBar:Shape;
        
        /**
         * @private
         * BlueSwarm Logo
         */
        private var _logo:DisplayObject;
        
        /**
         * @private
         * A timer used for animations.
         */
        private var _logoTimer:Timer;
        
        /**
         * @private
         * Flag used to track whether the animation and the load are both complete.
         */
        private var _otherIsDone:Boolean = false;
        
        /**
         * @private
         */
        override public function set preloader( preloader:Sprite ):void 
        {                   
            preloader.addEventListener( ProgressEvent.PROGRESS , swfProgressHandler );
            preloader.addEventListener( FlexEvent.INIT_COMPLETE , initCompleteHandler );
        }
        
    //----------------------------------
    //  Private Methods
    //----------------------------------
        
        /**
         * @private
         * Position the logo and draw the progress bar. 
         */
        private function redraw():void
        {    
            this._logo.x = (this.stage.stageWidth - this._logo.width) / 2;
            this._logo.y = (this.stage.stageHeight - this._logo.height) / 2;
            
            var perc:Number = this.loaderInfo.bytesLoaded / this.loaderInfo.bytesTotal;
            
            var pbX:int = this._logo.x;
            var pbY:int = this._logo.y + this._logo.height + 10;
            
            this._progressBar.graphics.clear();
            this._progressBar.graphics.beginFill(0x52bdec);
            this._progressBar.graphics.drawRect(pbX, pbY, Number(this._logo.width * perc), 1);
            this._progressBar.graphics.endFill();
        }
        
        /**
         * @private
         * Fade out the logo. 
         */
        private function preloadComplete():void
        {
            if(!this._otherIsDone)
            {
                this._otherIsDone = true;
                return;
            }
            this._logoTimer.addEventListener(TimerEvent.TIMER, timerUpdateHandler2);
            this._logoTimer.start();
            
        }
        
    //----------------------------------
    //  Private Event Handlers
    //----------------------------------
        
        /**
         * @private
         * Listen for the stage resize so that we can reposition the logo.
         */
        private function addedToStageHandler(event:Event):void
        {
            this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            this.stage.addEventListener(Event.RESIZE, stageResizeHandler, false, 0, true);
        }
        
        /**
         * @private
         * Redraw the progress bar when we get a new progress indicator. 
         */
        private function swfProgressHandler(event:ProgressEvent):void
        {
            this.redraw();
        }
        
        /**
         * @private
         * Redraw when the stage resizes.
         */
        private function stageResizeHandler(event:Event):void
        {
            this.redraw();
        }
        
        /**
         * @private
         * App is ready, let's go!
         */
        private function initCompleteHandler(event:FlexEvent):void
        {
            this.preloadComplete();
        }
        
        /**
         * @private
         * Handles fading in the logo.
         */
        private function timerUpdateHandler(event:TimerEvent):void
        {
            var timeElapsed:Number = this._logoTimer.currentCount * 40; //roughly...
            var newAlpha:Number = Math.min(timeElapsed / 800, 1);
            this._logo.alpha = newAlpha;
            
            if(newAlpha == 1)
            {
                this._logoTimer.removeEventListener(TimerEvent.TIMER, timerUpdateHandler);
                this._logoTimer.stop();
                this._logoTimer.reset();
                this.preloadComplete();
            }
        }
        
        /**
         * @private
         * Handles fading out the logo.
         */
        private function timerUpdateHandler2(event:TimerEvent):void
        {
            var timeElapsed:Number = this._logoTimer.currentCount * 40;
            var newAlpha:Number = Math.max((350 - timeElapsed) / 350, 0);
            this._logo.alpha = newAlpha;
            this._progressBar.alpha = newAlpha;
            
            if(newAlpha == 0)
            {
                this._logoTimer.stop();
                this._logoTimer.removeEventListener(TimerEvent.TIMER, timerUpdateHandler2);
                this.stage.removeEventListener(Event.RESIZE, stageResizeHandler);
                this.dispatchEvent(new Event(Event.COMPLETE));
            }
        }

        
    }
}