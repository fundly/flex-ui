/*
Copyright (c) 2008 Joel May.  See:
    http://www.connectedpixel.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Note: this will likely be moved to FlexLib soon, after I clean up the code.
*/

package com.enilsson.elephanttrakker.views.renderers.chart
{
    import com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollThumbSkin;
    import com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollTrackSkin;
    import com.enilsson.elephanttrakker.views.renderers.chart.SubRangeArrayCollection;
    
    import flash.events.Event;
    
    import mx.charts.LinearAxis;
    import mx.charts.chartClasses.CartesianChart;
    import mx.charts.chartClasses.IAxis;
    import mx.collections.IList;
    import mx.controls.HScrollBar;
    import mx.controls.VScrollBar;
    import mx.controls.scrollClasses.ScrollBar;
    import mx.controls.scrollClasses.ScrollBarDirection;
    import mx.core.UIComponent;
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.StyleManager;
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.connectedpixel.charts.skins.AxisScrollArrowSkin
 */
    [Style(name="downArrowDownSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.connectedpixel.charts.skins.AxisScrollArrowSkin
 */
    [Style(name="downArrowOverSkin", type="Class", inherit="no")]
    [Style(name="thumbIcon", type="Class", inherit="no")]
    
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.connectedpixel.charts.skins.AxisScrollThumbSkin
 */
 
    [Style(name="thumbDownSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.connectedpixel.charts.skins.AxisScrollThumbSkin
 */    
     [Style(name="thumbDownSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.connectedpixel.charts.skins.AxisScrollThumbSkin
 */    
    [Style(name="thumbOverSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.connectedpixel.charts.skins.AxisScrollThumbSkin
 */    
    [Style(name="thumbUpSkin", type="Class", inherit="no")]
    
    [Style(name="trackColors", type="Array", arrayType="uint", format="Color", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.connectedpixel.charts.skins.AxisScrollTrackSkin
 */    
    [Style(name="trackSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.connectedpixel.charts.skins.AxisScrollArrowSkin
 */    
    [Style(name="upArrowDisabledSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @defaultcom.connectedpixel.charts.skins.AxisScrollArrowSkin 
 */    
    [Style(name="upArrowDownSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.connectedpixel.charts.skins.AxisScrollArrowSkin
 */    
    [Style(name="upArrowOverSkin", type="Class", inherit="no")]
/**
 *  Name of the class to use as the skin for the down arrow button of the 
 *  scroll bar when it is disabled. 
 * 
 *  If you change the skin, either graphically or programmatically, 
 *  you should ensure that the new skin is the same height 
 *  (for horizontal ScrollBars) or width (for vertical ScrollBars) as the track.
 * 
 *  @default com.connectedpixel.charts.skins.AxisScrollArrowSkin
 */    
    [Style(name="upArrowUpSkin", type="Class", inherit="no")]
    
    // It would have been easier to extend ScrollBar instead of wrapping ScrollBar.  This would have
    // simplified all this skin style forwarding.  However, ScrollBar has some mx_internal data members
    // which need to be set (see HScrollBar for exampl).  This mucks it up, so wrapping wins over inheriting.
    
    public class ChartDataScrollBar extends UIComponent
    {
        // These skins are derived from the Halo scrollbar skins.  They have a nasty hack.  Because the flex
        // ScrollBar class hard-codes the minimum width and we desire a narrow width here, these appear to be
        // narrower, but have an alpha=0 background rectangle that is the same width as the normal ScrollBar.
        
        static private var defaultStyles:Array = [
            { name: "thumbDownSkin",             styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollThumbSkin },
            { name: "thumbOverSkin",             styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollThumbSkin },
            { name: "thumbUpSkin",                 styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollThumbSkin },
            { name: "thumbDownSkin",             styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollThumbSkin },
            
            { name: "downArrowDisabledSkin",     styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollArrowSkin },
            { name: "downArrowDownSkin",         styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollArrowSkin },
            { name: "downArrowOverSkin",         styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollArrowSkin },
            { name: "downArrowUpSkin",             styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollArrowSkin },
            
            { name: "upArrowDisabledSkin",         styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollArrowSkin },
            { name: "upArrowDownSkin",             styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollArrowSkin },
            { name: "upArrowOverSkin",             styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollArrowSkin },
            { name: "upArrowUpSkin",             styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollArrowSkin },
            
            { name: "trackSkin",                 styleValue: com.enilsson.elephanttrakker.views.renderers.chart.AxisScrollTrackSkin }
        ];
        
        // Code structure from "Programming Flex 2" by Chafic Kazoun and Joey Lott.
        
        private static var classConstructed:Boolean = classConstruct();
        
        private static function classConstruct():Boolean {
           var style:CSSStyleDeclaration = StyleManager.getStyleDeclaration("ChartDataScrollBar");
    
            if (!style)
            {
                style = new CSSStyleDeclaration();
                   StyleManager.setStyleDeclaration("ChartDataScrollBar", style, true);
            }
              for (var i:int = 0 ; i < defaultStyles.length ; i++){
                var styleItem:Object = defaultStyles[i];
                var styleName:String = styleItem.name;
                var styleValue:* = styleItem.styleValue;
                if (style.getStyle(styleName) == undefined){
                    style.setStyle(styleName, styleValue);
                }
            }
           
            return true;        
        }
        
        /////////////////////////////////////////////////////////////////
        
        private var nColumns:int = 5;    
        private var bnColumnsChanged:Boolean = false;
            
        private var iStartColumn:int = 0;
        private var biStartColumnChanged:Boolean = false;
            
        private var innerDP:IList;
        private var rangeWrapper:SubRangeArrayCollection;
        
        private var _alteredStyles:Object = new Object();
            
        private var _scrollBar:ScrollBar;
        
        private var _bMaxColumnsChanged:Boolean = false;
        private var _nMaxColumns:int = 5;
        
        private var _bInitialLeftColumnChanged:Boolean = false;
        private var _iInitialLeftColumn:int = 0;
        
        private var _chart:CartesianChart;
        
        // ScrollBarDirection.HORIZONTAL
        // ScrollBarDirection.VERTICAL    
        private var _direction:String;
        
        public function get direction():String { return _direction; }
        
        public function ChartDataScrollBar(scrollBarDirection:String)
        {
            super();
            if (scrollBarDirection != ScrollBarDirection.HORIZONTAL && 
                scrollBarDirection != ScrollBarDirection.VERTICAL      ){
                var msg:String = "ChartDataScrollBar: Invalid scrollBarDirection: " + scrollBarDirection;
                throw new ArgumentError(msg);
            }
            _direction = scrollBarDirection;
            
            initAlteredStyles();
        }
        
        private function initAlteredStyles():void
        {
            for (var i:int = 0 ; i < defaultStyles.length ; i++){
                var styleName:String = defaultStyles[i].name;
                _alteredStyles[styleName] = true;
            }
        }
        
        
        override public function styleChanged(styleProp:String):void
        {
            super.styleChanged(styleProp);
            
            _alteredStyles[styleProp] = true;
            
            invalidateDisplayList();
        }
        
        override public function setActualSize(w:Number, h:Number):void
        {
            super.setActualSize(w,h);
            
            if (_scrollBar != null){
                _scrollBar.setActualSize(w,h);
            }
        }
        
        override protected function createChildren():void
        {
            if (_scrollBar == null){
                _scrollBar = (_direction == ScrollBarDirection.HORIZONTAL) ? new HScrollBar() : new VScrollBar();
                _scrollBar.styleName = this;
                _scrollBar.addEventListener(Event.SCROLL,onScroll);

                addChild(_scrollBar);
            }
        }
        
        [Bindable]
        public function set chart(ch:CartesianChart):void
        {
            if (ch == _chart) return;
            
            _chart = ch;    
            
            // Prevent the chart from flashing the full data set 
            // during initialization -- hide it.  This will be restored in
            // updateDisplayList()
            _chart.alpha = 0;
            
            _bChartSynched = false;
            this.invalidateDisplayList();
            this.invalidateProperties();
            this.invalidateSize();
        }
        public function get chart():CartesianChart { return _chart; }
        
        private var _bChartSynched:Boolean = false;
        
        private function chartSynch():void
        {
            if (_chart == null) return;
            if (_chart.dataProvider == null){ 
                this.invalidateProperties();
                return; 
            }
            
            if (_bChartSynched) return;    
            
            _bChartSynched = true;
            
            var axis:IAxis = (direction == ScrollBarDirection.HORIZONTAL) ? _chart.verticalAxis : _chart.horizontalAxis;
            
            if (axis is LinearAxis){
                var linAxis:LinearAxis = axis as LinearAxis;
                if (isNaN(linAxis.minimum) || isNaN(linAxis.maximum)){
                    this.invalidateProperties();
                    return;
                } 
                // Hack: Max and min are now explicitly set, so altering the 
                // chart data provider won't change them.
                linAxis.minimum = linAxis.minimum;
                linAxis.maximum = linAxis.maximum;
            }
            
            innerDP = _chart.dataProvider as IList;
            
            if (innerDP != null){
                rangeWrapper = new SubRangeArrayCollection(innerDP,nColumns,iStartColumn);
                _chart.dataProvider = rangeWrapper; 
            }
        }
        
        [Bindable]
        public function set maxColumns(n:int):void
        {
            if (innerDP != null && n > innerDP.length){
                n = innerDP.length;
            }
            
            if (nColumns != n){
                
                if (innerDP != null){
                    var nColumnsExcessRight:int = iStartColumn + n - innerDP.length;
                    if (nColumnsExcessRight > 0){
                        firstIndexOffset = iStartColumn - nColumnsExcessRight;
                    }
                }
                
                nColumns = n;    
                bnColumnsChanged = true;
                
                invalidateDisplayList();
            }
        }
        public function get maxColumns():int
        {
            return this.nColumns;
        }
        
        [Bindable]
        public function set firstIndexOffset(iCol:int):void
        {
            if (this.iStartColumn != iCol){
                iStartColumn = iCol;
                this.bnColumnsChanged = true;
                this.invalidateProperties();
            }
        }
        public function get firstIndexOffset():int
        {
            return iStartColumn;
        }
        
        private function updateScrollBar():void
        {
            _scrollBar.minScrollPosition = 0;
            _scrollBar.maxScrollPosition =     innerDP.length - this.nColumns;        
            _scrollBar.pageSize = nColumns;
            
            if (this.direction == ScrollBarDirection.VERTICAL){
                _scrollBar.scrollPosition = innerDP.length - iStartColumn - this.nColumns;
            }
            else{
                _scrollBar.scrollPosition = iStartColumn;
            }

            _scrollBar.addEventListener(Event.SCROLL, onScroll);
        }
        
        ///////////////////////////////////////////////
        
        override protected function measure():void
        {
            super.measure();
            
            // Bubble up the values from the wrapped scrollbar.
            measuredWidth  = this._scrollBar.measuredWidth;
            measuredHeight = this._scrollBar.measuredHeight;
            measuredMinWidth  = this._scrollBar.measuredMinWidth;
            measuredMinHeight = this._scrollBar.measuredMinHeight;
        }
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);    
            
            _scrollBar.setActualSize(unscaledWidth, unscaledHeight);
            
            chartSynch();
            
            if (this.bnColumnsChanged){
                rangeWrapper.setRange(firstIndexOffset, nColumns);
                this.bnColumnsChanged = false;
            }
            
            updateScrollBar();
            
            updateScrollBarStyles();
            
            // Restore the chart to visibility now that it has the correct data and
            // any temporary flash of bad data will not happen now.
            _chart.alpha = 1.0;
        }
        
        private function updateScrollBarStyles():void
        {
            for (var styleProp:String in _alteredStyles){
                _scrollBar.setStyle(styleProp, this.getStyle(styleProp));
            }
            _alteredStyles = new Object();
        }

        private function onScroll(ev:Event):void
        {
            var scrollBar:ScrollBar = ScrollBar(ev.target);
            
            if (this.direction == ScrollBarDirection.VERTICAL){
                iStartColumn = innerDP.length - scrollBar.scrollPosition - this.nColumns; 
            }
            else{
                iStartColumn = scrollBar.scrollPosition;
            }
            
            if (rangeWrapper != null){
                rangeWrapper.firstIndexOffset = iStartColumn;
            }
        }
        
    }
}