{{flutter_js}}
{{flutter_build_config}}

(function () {
  var config = {
    canvasKitBaseUrl: '/canvaskit/',
  };

  _flutter.loader.load({ config: config }).catch(function (err) {
    console.error('MadBeauty bootstrap failed:', err);
  });
})();
