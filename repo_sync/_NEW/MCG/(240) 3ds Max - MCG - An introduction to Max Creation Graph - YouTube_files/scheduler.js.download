(function(){/*

 Copyright The Closure Library Authors.
 SPDX-License-Identifier: Apache-2.0
*/
var f,aa="function"==typeof Object.create?Object.create:function(a){function b(){}
b.prototype=a;return new b},g;
if("function"==typeof Object.setPrototypeOf)g=Object.setPrototypeOf;else{var h;a:{var ba={J:!0},k={};try{k.__proto__=ba;h=k.J;break a}catch(a){}h=!1}g=h?function(a,b){a.__proto__=b;if(a.__proto__!==b)throw new TypeError(a+" is not extensible");return a}:null}var l=g,m=this||self;
function n(a){a=a.split(".");for(var b=m,c=0;c<a.length;c++)if(b=b[a[c]],null==b)return null;return b}
function ca(a,b,c){return a.call.apply(a.bind,arguments)}
function da(a,b,c){if(!a)throw Error();if(2<arguments.length){var e=Array.prototype.slice.call(arguments,2);return function(){var d=Array.prototype.slice.call(arguments);Array.prototype.unshift.apply(d,e);return a.apply(b,d)}}return function(){return a.apply(b,arguments)}}
function p(a,b,c){Function.prototype.bind&&-1!=Function.prototype.bind.toString().indexOf("native code")?p=ca:p=da;return p.apply(null,arguments)}
var q=Date.now||function(){return+new Date};
function r(a,b){var c=a.split("."),e=m;c[0]in e||"undefined"==typeof e.execScript||e.execScript("var "+c[0]);for(var d;c.length&&(d=c.shift());)c.length||void 0===b?e[d]&&e[d]!==Object.prototype[d]?e=e[d]:e=e[d]={}:e[d]=b}
;function t(){this.j=this.j;this.o=this.o}
t.prototype.j=!1;t.prototype.dispose=function(){this.j||(this.j=!0,this.u())};
t.prototype.u=function(){if(this.o)for(;this.o.length;)this.o.shift()()};var u=window.yt&&window.yt.config_||window.ytcfg&&window.ytcfg.data_||{};r("yt.config_",u);function w(a,b){return a in u?u[a]:b}
function x(){return w("SCHEDULER_SOFT_STATE_TIMER",800)}
;function y(a){var b=w("EXPERIMENTS_FORCED_FLAGS",{});return void 0!==b[a]?b[a]:w("EXPERIMENT_FLAGS",{})[a]}
;var z,A=y("web_emulated_idle_callback_delay");z=void 0===A?300:Number(A||0);var C=1E3/60-3;
function D(a){a=void 0===a?{}:a;t.call(this);this.a=[];this.a[8]=[];this.a[4]=[];this.a[3]=[];this.a[2]=[];this.a[1]=[];this.a[0]=[];this.f=0;this.I=a.timeout||1;this.c={};this.i=C;this.v=this.b=this.h=0;this.w=this.g=!1;this.l=[];this.B=p(this.M,this);this.H=p(this.O,this);this.D=p(this.K,this);this.F=p(this.L,this);this.G=p(this.N,this);this.m=this.A=!1;var b;if(b=!!window.requestIdleCallback)b=y("disable_scheduler_requestIdleCallback"),b=!("string"===typeof b&&"false"===b?0:b);this.C=b;(this.s=
!!a.useRaf&&!!window.requestAnimationFrame)&&document.addEventListener("visibilitychange",this.B)}
D.prototype=aa(t.prototype);D.prototype.constructor=D;if(l)l(D,t);else for(var E in t)if("prototype"!=E)if(Object.defineProperties){var F=Object.getOwnPropertyDescriptor(t,E);F&&Object.defineProperty(D,E,F)}else D[E]=t[E];function G(a,b){var c=q();H(b);c=q()-c;a.g||(a.i-=c)}
function I(a,b,c,e){++a.v;if(10==c)return G(a,b),a.v;var d=a.v;a.c[d]=b;a.g&&!e?a.l.push({id:d,priority:c}):(a.a[c].push(d),a.w||a.g||(0!=a.b&&J(a)!=a.h&&K(a),a.start()));return d}
function L(a){a.l.length=0;for(var b=4;0<=b;b--)a.a[b].length=0;a.a[8].length=0;a.c={};K(a)}
function J(a){if(a.a[8].length){if(a.m)return 4;if(!document.hidden&&a.s)return 3}for(var b=4;b>=a.f;b--)if(0<a.a[b].length)return 0<b?!document.hidden&&a.s?3:2:1;return 0}
function H(a){try{a()}catch(b){(a=n("yt.logging.errors.log"))&&a(b)}}
function M(a){if(a.a[8].length)return!0;for(var b=3;0<=b;b--)if(a.a[b].length)return!0;return!1}
f=D.prototype;f.L=function(a){var b=void 0;a&&(b=a.timeRemaining());this.A=!0;N(this,b);this.A=!1};
f.O=function(){N(this)};
f.K=function(){O(this)};
f.N=function(){this.m=!0;var a=J(this);4==a&&a!=this.h&&(K(this),this.start());N(this);this.m=!1};
f.M=function(){document.hidden||O(this);this.b&&(K(this),this.start())};
function O(a){K(a);a.g=!0;for(var b=q(),c=a.a[8];c.length;){var e=c.shift(),d=a.c[e];delete a.c[e];d&&H(d)}P(a);a.g=!1;M(a)&&a.start();b=q()-b;a.i-=b}
function P(a){for(var b=0,c=a.l.length;b<c;b++){var e=a.l[b];a.a[e.priority].push(e.id)}a.l.length=0}
function N(a,b){a.m&&4==a.h&&a.b||K(a);a.g=!0;for(var c=q()+(b||a.i),e=a.a[4];e.length;){var d=e.shift(),v=a.c[d];delete a.c[d];v&&H(v)}e=a.A?0:1;e=a.f>e?a.f:e;if(!(q()>=c)){do{a:{d=a;v=e;for(var B=3;B>=v;B--)for(var U=d.a[B];U.length;){var V=U.shift(),W=d.c[V];delete d.c[V];if(W){d=W;break a}}d=null}d&&H(d)}while(d&&q()<c)}a.g=!1;P(a);a.i=C;M(a)&&a.start()}
f.start=function(){this.w=!1;if(0==this.b)switch(this.h=J(this),this.h){case 1:var a=this.F;this.b=this.C?window.requestIdleCallback(a,{timeout:3E3}):window.setTimeout(a,z);break;case 2:this.b=window.setTimeout(this.H,this.I);break;case 3:this.b=window.requestAnimationFrame(this.G);break;case 4:this.b=window.setTimeout(this.D,0)}};
function K(a){if(a.b){switch(a.h){case 1:var b=a.b;a.C?window.cancelIdleCallback(b):window.clearTimeout(b);break;case 2:case 4:window.clearTimeout(a.b);break;case 3:window.cancelAnimationFrame(a.b)}a.b=0}}
f.u=function(){L(this);K(this);this.s&&document.removeEventListener("visibilitychange",this.B);t.prototype.u.call(this)};var Q=n("yt.scheduler.instance.timerIdMap_")||{},R=0,S=0;function T(){var a=n("ytglobal.schedulerInstanceInstance_");if(!a||a.j)a=new D(w("scheduler",void 0)||{}),r("ytglobal.schedulerInstanceInstance_",a);return a}
function ea(){var a=n("ytglobal.schedulerInstanceInstance_");a&&(a&&"function"==typeof a.dispose&&a.dispose(),r("ytglobal.schedulerInstanceInstance_",null))}
function fa(){L(T())}
function ha(a,b,c){if(0==c||void 0===c)return c=void 0===c,-I(T(),a,b,c);var e=window.setTimeout(function(){var d=I(T(),a,b);Q[e]=d},c);
return e}
function ia(a){var b=T();G(b,a)}
function ja(a){var b=T();if(0>a)delete b.c[-a];else{var c=Q[a];c?(delete b.c[c],delete Q[a]):window.clearTimeout(a)}}
function X(a){var b=n("ytcsi.tick");b&&b(a)}
function ka(){X("jse");Y()}
function Y(){window.clearTimeout(R);T().start()}
function la(){var a=T();K(a);a.w=!0;window.clearTimeout(R);R=window.setTimeout(ka,x())}
function Z(){window.clearTimeout(S);S=window.setTimeout(function(){X("jset");ma(0)},x())}
function ma(a){Z();var b=T();b.f=a;b.start()}
function na(a){Z();var b=T();b.f>a&&(b.f=a,b.start())}
function oa(){window.clearTimeout(S);var a=T();a.f=0;a.start()}
;n("yt.scheduler.initialized")||(r("yt.scheduler.instance.dispose",ea),r("yt.scheduler.instance.addJob",ha),r("yt.scheduler.instance.addImmediateJob",ia),r("yt.scheduler.instance.cancelJob",ja),r("yt.scheduler.instance.cancelAllJobs",fa),r("yt.scheduler.instance.start",Y),r("yt.scheduler.instance.pause",la),r("yt.scheduler.instance.setPriorityThreshold",ma),r("yt.scheduler.instance.enablePriorityThreshold",na),r("yt.scheduler.instance.clearPriorityThreshold",oa),r("yt.scheduler.initialized",!0));}).call(this);
