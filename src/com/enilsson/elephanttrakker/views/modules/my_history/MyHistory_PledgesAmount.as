package com.enilsson.elephanttrakker.views.modules.my_history {
    import mx.controls.Label;
    import mx.controls.listClasses.*;

    public class MyHistory_PledgesAmount extends Label {

        private const POSITIVE_COLOR:uint = 0x000000; // Green
        private const NEGATIVE_COLOR:uint = 0xFF0000; // Red 

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            /* Set the font color based on the item price. */
            setStyle("color", (data.pledge_amount != data.contrib_total) ? NEGATIVE_COLOR : POSITIVE_COLOR);
        }
    }
}
