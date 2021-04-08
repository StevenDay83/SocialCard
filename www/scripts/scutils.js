// Web helper functions

function getURLAttribute(param) {
  var urlSearchParams = new URLSearchParams(window.location.search);

  return urlSearchParams.get(param);
}
