/**
 * Created by matthew on 3/9/17.
 */
//http://brandonhilkert.com/blog/page-specific-javascript-in-rails/
(function ($) {
    var ready = $.fn.ready;
    $.fn.ready = function (fn) {
        if (this.context === undefined) {
            // The $().ready(fn) case.
            ready(fn);
        } else if (this.selector) {
            ready($.proxy(function(){
                $(this.selector, this.context).each(fn);
            }, this));
        } else {
            ready($.proxy(function(){
                $(this).each(fn);
            }, this));
        }
    }
})(jQuery);