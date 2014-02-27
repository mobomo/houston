var WebFontConfig = {
  fontdeck: {
    id: '18035'
  }
};

(function() {
  var s, wf;
  wf = document.createElement('script');
  wf.src = ('https:' === document.location.protocol ? 'https' : 'http') + '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
  wf.async = 'true';
  s = document.getElementsByTagName('script')[0];
  return s.parentNode.insertBefore(wf, s);
})();
