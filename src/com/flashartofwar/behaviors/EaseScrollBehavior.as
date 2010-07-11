/*
 * The MIT License
 *
 * Original Author:  Jesse Freeman of FlashArtOfWar.com
 * Copyright (c) 2010
 * Class File: EaseScrollBehavior.as
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.flashartofwar.behaviors
{
    import flash.events.EventDispatcher;

    public class EaseScrollBehavior extends EventDispatcher
    {

        public var targetX:Number;
        private var target:Object;

        public function EaseScrollBehavior(target:Object, targetX:Number = 0)
        {

            if (!target.hasOwnProperty("scrollX"))
            {
                throw new Error("Supplied target does not have a scrollX property.");
            }
            else
            {
                this.target = target;
                targetX = targetX;
            }

        }

        public function update():void
        {

            if ((target.scrollX == targetX))
            {
                return;
            }
            else
            {
                var c:Number = targetX - target.scrollX;
                var b:Number = target.scrollX;
                target.scrollX = c * 25.0 / 256.0 + b;

                if (c < .01 && c > -.01)
                {
                    target.scrollX = targetX;
                }
            }


        }
    }
}