var transTable = {};

function translate (domain) {
  var params = {
    domain: domain
  };

  var gt = new Gettext(params);

  $('.imperator-i18n').each(function (i, el) {
    var jq = $(el),
        msgid = transTable[i18nkey(jq)],
        msgctxt = jq.data('i18n-context');

    if (msgctxt.length === 0) {
      msgctxt = null;
    }

    jq.text(gt.pgettext(msgctxt, msgid));
  });
}

function i18nkey(jq) {
  return "" + jq.data('i18n-context') + '|' + jq.data('i18n-key');
}

$(function () {
  $('.imperator-i18n').each(function (i, el) {
    var jq = $(el);

    transTable[i18nkey(jq)] = $.trim(jq.text());
  });

  $('#use-en_US').click(function() {
    translate('en_US');
  });

  $('#use-es_US').click(function() {
    translate('es_US');
  });
});

// vim:ts=2:sw=2:et:tw=78
