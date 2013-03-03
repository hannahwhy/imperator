var msgidTable = {};

function translate (domain) {
  var params = {
    domain: domain
  };

  var gt = new Gettext(params);

  $('.imperator-i18n').each(function (i, el) {
    var jq = $(el), msgid = msgidTable[jq.data('i18n-key')];
    jq.text(gt.gettext(msgid));
  });
}

$(function () {
  $('.imperator-i18n').each(function (i, el) {
    var jq = $(el);

    msgidTable[jq.data('i18n-key')] = jq.text();
  });

  $('#use-en_US').click(function() {
    translate('en_US');
  });

  $('#use-es_US').click(function() {
    translate('es_US');
  });
});

// vim:ts=2:sw=2:et:tw=78
