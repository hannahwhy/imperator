$(function () {
  function evaluateDependencies (startAt) {

  }
  
  function evaluateAllDependencies() {
    $('.imperator-question').each(function() {
      var uuid = $(this).attr('id');

      console.log(uuid);
      evaluateDependencies(uuid);
    });
  }

  $('.imperator-answer').change(function() {
    var el = $(this), q = el.data('q-uuid');

    evaluateDependencies(q);
  });

  evaluateAllDependencies();
});

// vim:ts=2:sw=2:et:tw=78
