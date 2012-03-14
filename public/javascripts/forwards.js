$(function() {
  var locale_id = "input#translation_locale_token";
  $(locale_id).tokenInput($(locale_id).data("url"), {
    crossDomain: false,
    allowCreation: true,
    tokenLimit: 1
  });
});
