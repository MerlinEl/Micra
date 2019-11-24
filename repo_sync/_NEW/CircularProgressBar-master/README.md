# <img src="CircularProgressBar/Icon.png" width="42" alt="Icon"> Circular ProgressBar for WinForm [.Net3.5+]
[![](https://img.shields.io/github/license/falahati/CircularProgressBar.svg?style=flat-square)](https://github.com/falahati/CircularProgressBar/blob/master/LICENSE)
[![](https://img.shields.io/github/commit-activity/y/falahati/CircularProgressBar.svg?style=flat-square)](https://github.com/falahati/CircularProgressBar/commits/master)
[![](https://img.shields.io/github/issues/falahati/CircularProgressBar.svg?style=flat-square)](https://github.com/falahati/CircularProgressBar/issues)

Circular ProgressBar is a custom control and inplace replacement of 'ProgressBar' for WinForm with animation.

## WHERE TO FIND
[![](https://img.shields.io/nuget/dt/CircularProgressBar.svg?style=flat-square)](https://www.nuget.org/packages/CircularProgressBar)
[![](https://img.shields.io/nuget/v/CircularProgressBar.svg?style=flat-square)](https://www.nuget.org/packages/CircularProgressBar)

This library is available as a NuGet package at [nuget.org](https://www.nuget.org/packages/CircularProgressBar/).

## DONATION
Donations assist development and are greatly appreciated; also always remember that [every coffee counts!](https://media.makeameme.org/created/one-simply-does-i9k8kx.jpg) :)

[![](https://img.shields.io/badge/fiat-PayPal-8a00a3.svg?style=flat-square)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=WR3KK2B6TYYQ4&item_name=Donation&currency_code=USD&source=url)
[![](https://img.shields.io/badge/crypto-CoinPayments-8a00a3.svg?style=flat-square)](https://www.coinpayments.net/index.php?cmd=_donate&reset=1&merchant=820707aded07845511b841f9c4c335cd&item_name=Donate&currency=USD&amountf=20.00000000&allow_amount=1&want_shipping=0&allow_extra=1)
[![](https://img.shields.io/badge/shetab-ZarinPal-8a00a3.svg?style=flat-square)](https://zarinp.al/@falahati)

**--OR--**

You can always donate your time by contributing to the project or by introducing it to others.

## HOW TO USE
Use toolbox to add the control to your forms.

Check the 'CircularProgressBarSample' project for tons of usage examples.
![Screenshot](/screenshot.gif?raw=true "Screenshot")

## MEMBERS
#### [Properties]

* `CircularProgressBar.Maximum`: Shows and changes the maximum acceptable value for the progress bar.
* `CircularProgressBar.Minimum`: Shows and changes the minimum acceptable value for the progress bar.
* `CircularProgressBar.Value`: Shows and changes the current value of the progress bar.
* `CircularProgressBar.Style`: Shows and changes the style of the progress bar. Only `Continues` and `Marquee` is now supported. `Blocks` behaves as same as `Continues`.
* `CircularProgressBar.BackColor`: Background color of control, transparent is not supported
* `CircularProgressBar.Text`: Primary text
* `CircularProgressBar.TextMargin`: Margin of the primary text
* `CircularProgressBar.Font`: Font of the primary text
* `CircularProgressBar.SuperscriptText`: Superscript text
* `CircularProgressBar.SuperscriptMargin`: Margin of the superscript text
* `CircularProgressBar.SuperscriptColor`: Font color of the superscript text
* `CircularProgressBar.SubscriptText`: Subscript text
* `CircularProgressBar.SubscriptMargin`: Margin of the subscript text
* `CircularProgressBar.SubscriptColor`: Font color of the subscript text
* `CircularProgressBar.SecondaryFont`: Font of subscript as superscript text
* `CircularProgressBar.AnimationFunction`: Contains the function that controls the animation. Use `WinFormAnimation.Functions` namespace for some of the basic implementations.
* `CircularProgressBar.AnimationSpeed`: Speed of the animation. Applies to the main progress animation.
* `CircularProgressBar.StartAngle`: Start angle of the progress bar. 270 being top of the control.
* `CircularProgressBar.InnerColor`: Color of the inner circle.
* `CircularProgressBar.InnerWidth`: Width of the inner circle. -1 means full fill.
* `CircularProgressBar.InnerMargin`: Margin of the inner circle.
* `CircularProgressBar.ProgressWidth`: Width of the main progress bar circle. -1 means full fill.
* `CircularProgressBar.ProgressColor`: Color of the main progress bar circle.
* `CircularProgressBar.OuterColor`: Color of the outer circle.
* `CircularProgressBar.OuterWidth`: Width of the outer circle. -1 means full fill.
* `CircularProgressBar.OuterMargin`: Margin of the outer circle.


## LICENSE
The MIT License (MIT)

Copyright (c) 2016 Soroush Falahati

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

